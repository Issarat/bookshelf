\set ON_ERROR_STOP on
-- Run once in a dedicated PostgreSQL 16+ lab database. No DROP/CASCADE.
BEGIN;
CREATE SCHEMA kw_migration;
CREATE SCHEMA kw_staging;
CREATE SCHEMA kw_app;

CREATE TABLE kw_migration.batches (
    batch_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    source_version TEXT NOT NULL,
    started_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status TEXT NOT NULL CHECK (status IN ('loaded','cleansed','validated','rejected','completed'))
);
CREATE TABLE kw_staging.records (
    record_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    batch_id BIGINT NOT NULL REFERENCES kw_migration.batches,
    entity TEXT NOT NULL,
    payload JSONB NOT NULL
);
CREATE INDEX ON kw_staging.records(batch_id, entity);
CREATE TABLE kw_staging.cleaned_records (
    record_id BIGINT PRIMARY KEY REFERENCES kw_staging.records,
    batch_id BIGINT NOT NULL REFERENCES kw_migration.batches,
    entity TEXT NOT NULL,
    source_payload JSONB NOT NULL,
    payload JSONB NOT NULL,
    rule_version TEXT NOT NULL CHECK(rule_version='v1')
);
CREATE INDEX ON kw_staging.cleaned_records(batch_id,entity);
CREATE TABLE kw_migration.cleansing_changes (
    batch_id BIGINT NOT NULL REFERENCES kw_migration.batches,
    record_id BIGINT NOT NULL REFERENCES kw_staging.records,
    entity TEXT NOT NULL,
    field_name TEXT NOT NULL,
    original_value JSONB NOT NULL,
    cleaned_value JSONB NOT NULL,
    applied_rules TEXT[] NOT NULL,
    rule_version TEXT NOT NULL CHECK(rule_version='v1'),
    changed_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY(batch_id,record_id,field_name)
);
CREATE TABLE kw_migration.rejects (
    batch_id BIGINT NOT NULL REFERENCES kw_migration.batches,
    record_id BIGINT NOT NULL,
    entity TEXT NOT NULL,
    reason TEXT NOT NULL,
    payload JSONB NOT NULL,
    PRIMARY KEY(batch_id, record_id, reason)
);
CREATE TABLE kw_migration.source_snapshot (
    entity TEXT NOT NULL,
    source_key JSONB NOT NULL,
    payload JSONB NOT NULL,
    PRIMARY KEY(entity, source_key)
);
CREATE TABLE kw_migration.schema_steps (
    step TEXT PRIMARY KEY,
    applied_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE FUNCTION kw_migration.assert_ok(ok BOOLEAN, message TEXT)
RETURNS VOID LANGUAGE plpgsql AS $$
BEGIN
    IF ok IS DISTINCT FROM TRUE THEN RAISE EXCEPTION '%', message; END IF;
END $$;

-- Guard casts: malformed source values become NULL for validation, not silent fixes.
CREATE FUNCTION kw_migration.safe_int(value TEXT) RETURNS INT
LANGUAGE plpgsql STABLE AS $$
BEGIN
    -- Accept integral exports such as 40.0 without rounding 40.5 to 41.
    IF value ~ '^[0-9]+([.]0+)?$' AND pg_input_is_valid(split_part(value,'.',1), 'integer')
    THEN RETURN split_part(value,'.',1)::INT; END IF;
    RETURN NULL;
END $$;
CREATE FUNCTION kw_migration.safe_money(value TEXT) RETURNS NUMERIC
LANGUAGE plpgsql STABLE AS $$
BEGIN
    IF value ~ '^[0-9]+([.][0-9]{1,2})?$'
       AND pg_input_is_valid(value, 'numeric(14,2)')
    THEN RETURN value::NUMERIC(14,2); END IF;
    RETURN NULL;
END $$;
CREATE FUNCTION kw_migration.safe_time(value TEXT) RETURNS TIMESTAMP
LANGUAGE plpgsql STABLE AS $$
BEGIN
    IF value ~ '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$'
       AND pg_input_is_valid(value, 'timestamp without time zone')
    THEN RETURN value::TIMESTAMP; END IF;
    RETURN NULL;
END $$;

CREATE FUNCTION kw_migration.source_key(entity TEXT, p JSONB) RETURNS JSONB
LANGUAGE sql STABLE AS $$
SELECT CASE entity
    WHEN 'customers' THEN jsonb_build_array(p->>'customer_id')
    WHEN 'products' THEN jsonb_build_array(p->>'product_id')
    WHEN 'sellers' THEN jsonb_build_array(p->>'seller_id')
    WHEN 'orders' THEN jsonb_build_array(p->>'order_id')
    WHEN 'items' THEN jsonb_build_array(p->>'order_id', kw_migration.safe_int(p->>'order_item_id'))
    WHEN 'payments' THEN jsonb_build_array(p->>'order_id', kw_migration.safe_int(p->>'payment_sequential'))
END
$$;

-- Lab policy v1: trim outer ASCII whitespace, blank -> JSON null, exact numeric canonicalization.
-- No imputation, rounding, case folding, fuzzy matching or deduplication.
CREATE FUNCTION kw_migration.clean_field(e TEXT,f TEXT,original JSONB)
RETURNS TABLE(cleaned_value JSONB,applied_rules TEXT[]) LANGUAGE plpgsql STABLE AS $$
DECLARE value TEXT; trimmed TEXT; canonical TEXT;
BEGIN
 cleaned_value:=original; applied_rules:='{}';
 IF original='null'::JSONB THEN RETURN NEXT; RETURN; END IF;
 IF jsonb_typeof(original)<>'string' THEN RAISE EXCEPTION 'Expected raw CSV string or null'; END IF;
 value:=original #>> '{}';
 trimmed:=btrim(value,E' \t\r\n');
 IF trimmed<>value THEN applied_rules:=array_append(applied_rules,'trim_outer_whitespace'); END IF;
 value:=trimmed;
 IF value='' THEN
   cleaned_value:='null'::JSONB;
   applied_rules:=array_append(applied_rules,'empty_to_null');
   RETURN NEXT; RETURN;
 END IF;
 IF (e='products' AND f=ANY(ARRAY['product_name_lenght','product_description_lenght',
      'product_photos_qty','product_weight_g','product_length_cm','product_height_cm','product_width_cm']))
    OR (e='items' AND f='order_item_id')
    OR (e='payments' AND f=ANY(ARRAY['payment_sequential','payment_installments'])) THEN
   canonical:=kw_migration.safe_int(value)::TEXT;
   IF canonical IS NOT NULL AND canonical<>value THEN
     value:=canonical; applied_rules:=array_append(applied_rules,'canonical_integer');
   END IF;
 ELSIF (e='items' AND f=ANY(ARRAY['price','freight_value']))
    OR (e='payments' AND f='payment_value') THEN
   canonical:=kw_migration.safe_money(value)::TEXT;
   IF canonical IS NOT NULL AND canonical<>value THEN
     value:=canonical; applied_rules:=array_append(applied_rules,'canonical_money');
   END IF;
 END IF;
 cleaned_value:=to_jsonb(value);
 RETURN NEXT;
END $$;

CREATE FUNCTION kw_migration.assert_cleansed(wanted_batch BIGINT) RETURNS VOID
LANGUAGE plpgsql STABLE AS $$
BEGIN
 PERFORM kw_migration.assert_ok(NOT EXISTS(
   SELECT 1 FROM kw_staging.records r
   LEFT JOIN kw_staging.cleaned_records c USING(record_id)
   WHERE r.batch_id=wanted_batch AND (c.record_id IS NULL OR c.batch_id<>r.batch_id
    OR c.entity<>r.entity OR c.source_payload IS DISTINCT FROM r.payload OR c.rule_version<>'v1')
 ),'Run 01_cleanse.sql first; raw/cleansed provenance is missing or changed');
END $$;

CREATE TABLE kw_app.customers (
    customer_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    source_unique_id TEXT NOT NULL UNIQUE
);
CREATE TABLE kw_app.customer_order_contexts (
    context_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    source_customer_id TEXT NOT NULL UNIQUE,
    customer_id BIGINT NOT NULL REFERENCES kw_app.customers,
    zip_code_prefix TEXT NOT NULL,
    city TEXT NOT NULL,
    state TEXT NOT NULL
);
CREATE TABLE kw_app.products (
    product_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    source_product_id TEXT NOT NULL UNIQUE,
    category TEXT,
    name_length INT CHECK(name_length >= 0),
    description_length INT CHECK(description_length >= 0),
    photos_qty INT CHECK(photos_qty >= 0),
    weight_g INT CHECK(weight_g >= 0),
    length_cm INT CHECK(length_cm >= 0),
    height_cm INT CHECK(height_cm >= 0),
    width_cm INT CHECK(width_cm >= 0)
);
CREATE TABLE kw_app.sellers (
    seller_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    source_seller_id TEXT NOT NULL UNIQUE,
    zip_code_prefix TEXT NOT NULL,
    city TEXT NOT NULL,
    state TEXT NOT NULL
);
CREATE TABLE kw_app.orders (
    order_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    source_order_id TEXT NOT NULL UNIQUE,
    context_id BIGINT NOT NULL REFERENCES kw_app.customer_order_contexts,
    status TEXT NOT NULL,
    purchased_at TIMESTAMP NOT NULL,
    approved_at TIMESTAMP,
    delivered_carrier_at TIMESTAMP,
    delivered_customer_at TIMESTAMP,
    estimated_delivery_at TIMESTAMP
);
CREATE TABLE kw_app.order_items (
    order_id BIGINT NOT NULL REFERENCES kw_app.orders,
    line_no INT NOT NULL CHECK(line_no > 0),
    product_id BIGINT NOT NULL REFERENCES kw_app.products,
    seller_id BIGINT NOT NULL REFERENCES kw_app.sellers,
    shipping_limit_at TIMESTAMP NOT NULL,
    price NUMERIC(14,2) NOT NULL CHECK(price >= 0),
    freight_value NUMERIC(14,2) NOT NULL CHECK(freight_value >= 0),
    PRIMARY KEY(order_id, line_no)
);
CREATE TABLE kw_app.payment_records (
    order_id BIGINT NOT NULL REFERENCES kw_app.orders,
    sequential INT NOT NULL CHECK(sequential > 0),
    payment_type TEXT NOT NULL,
    installments INT NOT NULL CHECK(installments >= 0),
    value NUMERIC(14,2) NOT NULL CHECK(value >= 0),
    PRIMARY KEY(order_id, sequential)
);
CREATE INDEX ON kw_app.customer_order_contexts(customer_id);
CREATE INDEX ON kw_app.orders(context_id);
CREATE INDEX ON kw_app.order_items(product_id);
CREATE INDEX ON kw_app.order_items(seller_id);

-- Typed records read only the cleansed layer. Raw CSV payloads remain unchanged.
CREATE VIEW kw_staging.customers AS
SELECT batch_id, payload->>'customer_id' AS source_customer_id,
       payload->>'customer_unique_id' AS source_unique_id,
       payload->>'customer_zip_code_prefix' AS zip_code_prefix,
       payload->>'customer_city' AS city, payload->>'customer_state' AS state
FROM kw_staging.cleaned_records WHERE entity='customers';
CREATE VIEW kw_staging.products AS
SELECT batch_id, payload->>'product_id' AS source_product_id,
       NULLIF(payload->>'product_category_name','') AS category,
       kw_migration.safe_int(payload->>'product_name_lenght') AS name_length,
       kw_migration.safe_int(payload->>'product_description_lenght') AS description_length,
       kw_migration.safe_int(payload->>'product_photos_qty') AS photos_qty,
       kw_migration.safe_int(payload->>'product_weight_g') AS weight_g,
       kw_migration.safe_int(payload->>'product_length_cm') AS length_cm,
       kw_migration.safe_int(payload->>'product_height_cm') AS height_cm,
       kw_migration.safe_int(payload->>'product_width_cm') AS width_cm
FROM kw_staging.cleaned_records WHERE entity='products';
CREATE VIEW kw_staging.sellers AS
SELECT batch_id, payload->>'seller_id' AS source_seller_id,
       payload->>'seller_zip_code_prefix' AS zip_code_prefix,
       payload->>'seller_city' AS city, payload->>'seller_state' AS state
FROM kw_staging.cleaned_records WHERE entity='sellers';
CREATE VIEW kw_staging.orders AS
SELECT batch_id, payload->>'order_id' AS source_order_id,
       payload->>'customer_id' AS source_customer_id,
       payload->>'order_status' AS status,
       kw_migration.safe_time(payload->>'order_purchase_timestamp') AS purchased_at,
       kw_migration.safe_time(payload->>'order_approved_at') AS approved_at,
       kw_migration.safe_time(payload->>'order_delivered_carrier_date') AS delivered_carrier_at,
       kw_migration.safe_time(payload->>'order_delivered_customer_date') AS delivered_customer_at,
       kw_migration.safe_time(payload->>'order_estimated_delivery_date') AS estimated_delivery_at
FROM kw_staging.cleaned_records WHERE entity='orders';
CREATE VIEW kw_staging.items AS
SELECT batch_id, payload->>'order_id' AS source_order_id,
       kw_migration.safe_int(payload->>'order_item_id') AS line_no,
       payload->>'product_id' AS source_product_id,
       payload->>'seller_id' AS source_seller_id,
       kw_migration.safe_time(payload->>'shipping_limit_date') AS shipping_limit_at,
       kw_migration.safe_money(payload->>'price') AS price,
       kw_migration.safe_money(payload->>'freight_value') AS freight_value
FROM kw_staging.cleaned_records WHERE entity='items';
CREATE VIEW kw_staging.payments AS
SELECT batch_id, payload->>'order_id' AS source_order_id,
       kw_migration.safe_int(payload->>'payment_sequential') AS sequential,
       payload->>'payment_type' AS payment_type,
       kw_migration.safe_int(payload->>'payment_installments') AS installments,
       kw_migration.safe_money(payload->>'payment_value') AS value
FROM kw_staging.cleaned_records WHERE entity='payments';
COMMIT;
