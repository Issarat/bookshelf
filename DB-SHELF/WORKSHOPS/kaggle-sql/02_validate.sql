\set ON_ERROR_STOP on
-- Standalone execution requires -v batch_id=N from 01_load.sql output.
SELECT kw_migration.assert_ok(EXISTS(SELECT 1 FROM kw_migration.batches WHERE batch_id=:batch_id),
                             'Unknown batch_id');
BEGIN;
SELECT pg_advisory_xact_lock(718204, 1);
SELECT set_config('kw.batch_id', :'batch_id', false);
SELECT kw_migration.assert_cleansed(:batch_id);
SELECT kw_migration.assert_ok(EXISTS(SELECT 1 FROM kw_migration.batches
 WHERE batch_id=:batch_id AND status IN ('cleansed','validated','rejected','completed')),
 'Run 01_cleanse.sql before validation');

CREATE OR REPLACE FUNCTION kw_migration.row_errors(e TEXT,p JSONB) RETURNS TEXT[]
LANGUAGE plpgsql STABLE AS $$
DECLARE required TEXT[]; ints TEXT[] := '{}'; times TEXT[] := '{}';
        money TEXT[] := '{}'; errors TEXT[] := '{}'; f TEXT; v TEXT;
BEGIN
 CASE e
 WHEN 'customers' THEN required:=ARRAY['customer_id','customer_unique_id',
      'customer_zip_code_prefix','customer_city','customer_state'];
 WHEN 'products' THEN
      required:=ARRAY['product_id'];
      ints:=ARRAY['product_name_lenght','product_description_lenght','product_photos_qty',
                  'product_weight_g','product_length_cm','product_height_cm','product_width_cm'];
 WHEN 'sellers' THEN required:=ARRAY['seller_id','seller_zip_code_prefix','seller_city','seller_state'];
 WHEN 'orders' THEN
      required:=ARRAY['order_id','customer_id','order_status','order_purchase_timestamp'];
      times:=ARRAY['order_purchase_timestamp','order_approved_at','order_delivered_carrier_date',
                   'order_delivered_customer_date','order_estimated_delivery_date'];
 WHEN 'items' THEN
      required:=ARRAY['order_id','order_item_id','product_id','seller_id','shipping_limit_date','price','freight_value'];
      ints:=ARRAY['order_item_id']; times:=ARRAY['shipping_limit_date']; money:=ARRAY['price','freight_value'];
 WHEN 'payments' THEN
      required:=ARRAY['order_id','payment_sequential','payment_type','payment_installments','payment_value'];
      ints:=ARRAY['payment_sequential','payment_installments']; money:=ARRAY['payment_value'];
 ELSE RETURN ARRAY['unknown entity'];
 END CASE;
 FOREACH f IN ARRAY required LOOP
   v:=p->>f;
   IF NULLIF(btrim(v),'') IS NULL THEN errors:=array_append(errors,'missing: '||f);
   ELSIF v<>btrim(v) THEN errors:=array_append(errors,'outer whitespace: '||f); END IF;
 END LOOP;
 FOREACH f IN ARRAY ints LOOP
   v:=p->>f;
   IF NULLIF(v,'') IS NOT NULL AND kw_migration.safe_int(v) IS NULL
   THEN errors:=array_append(errors,'invalid nonnegative integer: '||f); END IF;
 END LOOP;
 FOREACH f IN ARRAY times LOOP
   v:=p->>f;
   IF NULLIF(v,'') IS NOT NULL AND kw_migration.safe_time(v) IS NULL
   THEN errors:=array_append(errors,'invalid timestamp: '||f); END IF;
 END LOOP;
 FOREACH f IN ARRAY money LOOP
   v:=p->>f;
   IF NULLIF(v,'') IS NOT NULL AND kw_migration.safe_money(v) IS NULL
   THEN errors:=array_append(errors,'invalid nonnegative numeric(14,2): '||f); END IF;
 END LOOP;
 IF e='items' AND kw_migration.safe_int(p->>'order_item_id')=0
 THEN errors:=array_append(errors,'line number must be positive'); END IF;
 IF e='payments' AND kw_migration.safe_int(p->>'payment_sequential')=0
 THEN errors:=array_append(errors,'payment sequential must be positive'); END IF;
 RETURN errors;
END $$;

DELETE FROM kw_migration.rejects WHERE batch_id=:batch_id;
INSERT INTO kw_migration.rejects
SELECT c.batch_id,c.record_id,c.entity,reason,r.payload
FROM kw_staging.cleaned_records c JOIN kw_staging.records r USING(record_id)
CROSS JOIN LATERAL unnest(kw_migration.row_errors(c.entity,c.payload)) AS err(reason)
WHERE c.batch_id=:batch_id;

-- Reject every member of a duplicate group, not an arbitrary surviving row.
INSERT INTO kw_migration.rejects
SELECT d.batch_id,d.record_id,d.entity,'duplicate source key',r.payload FROM (
 SELECT c.*, count(*) OVER(PARTITION BY entity,kw_migration.source_key(entity,payload)) AS n
 FROM kw_staging.cleaned_records c WHERE batch_id=:batch_id
) d JOIN kw_staging.records r USING(record_id) WHERE n>1 ON CONFLICT DO NOTHING;

-- Materialize/index parent keys once, avoiding a JSON scan per child on large CSVs.
CREATE TEMP TABLE parent_keys ON COMMIT DROP AS
SELECT DISTINCT entity,kw_migration.source_key(entity,payload)->>0 AS source_id
FROM kw_staging.cleaned_records
WHERE batch_id=:batch_id AND entity IN ('customers','orders','products','sellers');
CREATE INDEX ON parent_keys(entity,source_id);
ANALYZE parent_keys;

INSERT INTO kw_migration.rejects
SELECT r.batch_id,r.record_id,r.entity,'missing parent: '||f.field,raw.payload
FROM kw_staging.cleaned_records r JOIN kw_staging.records raw USING(record_id)
JOIN (VALUES
 ('orders','customer_id','customers','customer_id'),
 ('items','order_id','orders','order_id'),
 ('items','product_id','products','product_id'),
 ('items','seller_id','sellers','seller_id'),
 ('payments','order_id','orders','order_id')
) AS f(child,field,parent,parent_field) ON f.child=r.entity
WHERE r.batch_id=:batch_id AND NOT EXISTS (
 SELECT 1 FROM parent_keys p WHERE p.entity=f.parent AND p.source_id=r.payload->>f.field
);

-- Empty inputs commonly mean a wrong download/path. This workshop requires all six nonempty files.
INSERT INTO kw_migration.rejects
SELECT :batch_id,0,e,'missing or empty source entity','{}'::JSONB
FROM unnest(ARRAY['customers','products','sellers','orders','items','payments']) AS x(e)
WHERE NOT EXISTS(SELECT 1 FROM kw_staging.cleaned_records WHERE batch_id=:batch_id AND entity=e);

UPDATE kw_migration.batches
SET status=CASE WHEN EXISTS(SELECT 1 FROM kw_migration.rejects WHERE batch_id=:batch_id)
                THEN 'rejected' ELSE 'validated' END
WHERE batch_id=:batch_id;
COMMIT;
-- Reject evidence is committed BEFORE failing the script. Targets are untouched.
SELECT entity,reason,count(*) FROM kw_migration.rejects
WHERE batch_id=:batch_id GROUP BY entity,reason ORDER BY entity,reason;
SELECT kw_migration.assert_ok(NOT EXISTS(SELECT 1 FROM kw_migration.rejects WHERE batch_id=:batch_id),
 'Validation failed. Inspect kw_migration.rejects; fix the source copy and import a NEW batch.');
