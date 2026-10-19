\set ON_ERROR_STOP on
BEGIN;
SELECT pg_advisory_xact_lock(718204, 1);
SELECT set_config('kw.batch_id', :'batch_id', false);
SELECT kw_migration.assert_cleansed(:batch_id);
SELECT kw_migration.assert_ok(EXISTS(SELECT 1 FROM kw_migration.batches
 WHERE batch_id=:batch_id AND status IN ('validated','completed')), 'Run validation first');
SELECT kw_migration.assert_ok(NOT EXISTS(SELECT 1 FROM kw_migration.schema_steps WHERE step='07_contract'),
 'Import after Contract is not supported. Use a new lab database or import before Schema Migration.');

-- Snapshot comparison intentionally uses RAW payloads: cleansing never hides changed source data.
-- A frozen-snapshot lab: identical retry allowed; changed, added or deleted source records refused.
SELECT kw_migration.assert_ok(
 NOT EXISTS(SELECT 1 FROM kw_migration.source_snapshot) OR NOT EXISTS (
  (SELECT entity,kw_migration.source_key(entity,payload),payload FROM kw_staging.records WHERE batch_id=:batch_id
   EXCEPT SELECT entity,source_key,payload FROM kw_migration.source_snapshot)
  UNION ALL
  (SELECT entity,source_key,payload FROM kw_migration.source_snapshot
   EXCEPT SELECT entity,kw_migration.source_key(entity,payload),payload FROM kw_staging.records WHERE batch_id=:batch_id)
 ), 'Source differs from the imported snapshot. No silent overwrite; use a new lab database.');
SELECT kw_migration.assert_ok(EXISTS(SELECT 1 FROM kw_migration.source_snapshot) OR
 NOT EXISTS(SELECT 1 FROM kw_app.customers UNION ALL SELECT 1 FROM kw_app.products
 UNION ALL SELECT 1 FROM kw_app.sellers UNION ALL SELECT 1 FROM kw_app.orders),
 'Initial target must be empty.');

INSERT INTO kw_app.customers(source_unique_id)
SELECT DISTINCT source_unique_id FROM kw_staging.customers WHERE batch_id=:batch_id
ON CONFLICT(source_unique_id) DO NOTHING;
INSERT INTO kw_app.customer_order_contexts(source_customer_id,customer_id,zip_code_prefix,city,state)
SELECT s.source_customer_id,c.customer_id,s.zip_code_prefix,s.city,s.state
FROM kw_staging.customers s JOIN kw_app.customers c USING(source_unique_id)
WHERE s.batch_id=:batch_id ON CONFLICT(source_customer_id) DO NOTHING;
INSERT INTO kw_app.products(source_product_id,category,name_length,description_length,photos_qty,weight_g,length_cm,height_cm,width_cm)
SELECT source_product_id,category,name_length,description_length,photos_qty,weight_g,length_cm,height_cm,width_cm
FROM kw_staging.products WHERE batch_id=:batch_id ON CONFLICT(source_product_id) DO NOTHING;
INSERT INTO kw_app.sellers(source_seller_id,zip_code_prefix,city,state)
SELECT source_seller_id,zip_code_prefix,city,state FROM kw_staging.sellers WHERE batch_id=:batch_id
ON CONFLICT(source_seller_id) DO NOTHING;
INSERT INTO kw_app.orders(source_order_id,context_id,status,purchased_at,approved_at,
 delivered_carrier_at,delivered_customer_at,estimated_delivery_at)
SELECT s.source_order_id,c.context_id,s.status,s.purchased_at,s.approved_at,
 s.delivered_carrier_at,s.delivered_customer_at,s.estimated_delivery_at
FROM kw_staging.orders s JOIN kw_app.customer_order_contexts c USING(source_customer_id)
WHERE s.batch_id=:batch_id ON CONFLICT(source_order_id) DO NOTHING;
INSERT INTO kw_app.order_items(order_id,line_no,product_id,seller_id,shipping_limit_at,price,freight_value)
SELECT o.order_id,s.line_no,p.product_id,v.seller_id,s.shipping_limit_at,s.price,s.freight_value
FROM kw_staging.items s JOIN kw_app.orders o USING(source_order_id)
JOIN kw_app.products p USING(source_product_id) JOIN kw_app.sellers v USING(source_seller_id)
WHERE s.batch_id=:batch_id ON CONFLICT(order_id,line_no) DO NOTHING;
INSERT INTO kw_app.payment_records(order_id,sequential,payment_type,installments,value)
SELECT o.order_id,s.sequential,s.payment_type,s.installments,s.value
FROM kw_staging.payments s JOIN kw_app.orders o USING(source_order_id)
WHERE s.batch_id=:batch_id ON CONFLICT(order_id,sequential) DO NOTHING;

INSERT INTO kw_migration.source_snapshot(entity,source_key,payload)
SELECT entity,kw_migration.source_key(entity,payload),payload
FROM kw_staging.records WHERE batch_id=:batch_id
ON CONFLICT(entity,source_key) DO NOTHING;

-- Includes assertions inside this Transaction, before marking the batch complete.
\ir 04_verify.sql
UPDATE kw_migration.batches SET status='completed' WHERE batch_id=:batch_id;
COMMIT;
