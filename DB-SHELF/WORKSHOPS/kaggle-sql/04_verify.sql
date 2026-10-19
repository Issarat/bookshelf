\set ON_ERROR_STOP on
SELECT kw_migration.assert_ok(EXISTS(SELECT 1 FROM kw_migration.batches
 WHERE batch_id=:batch_id AND status IN ('validated','completed')), 'Expected a validated batch');
SELECT set_config('kw.batch_id', :'batch_id', false);
SELECT kw_migration.assert_cleansed(:batch_id);
SELECT kw_migration.assert_ok(
 (SELECT count(*) FROM kw_staging.records WHERE batch_id=:batch_id)=
 (SELECT count(*) FROM kw_staging.cleaned_records WHERE batch_id=:batch_id),
 'Raw/cleansed record counts differ');

CREATE OR REPLACE TEMP VIEW expected_records AS
SELECT 'customers'::TEXT AS entity,jsonb_build_array(source_unique_id) AS source_key,
       jsonb_build_object('source_unique_id',source_unique_id) AS data
FROM kw_staging.customers WHERE batch_id=:batch_id GROUP BY source_unique_id
UNION ALL
SELECT 'contexts',jsonb_build_array(source_customer_id),to_jsonb(s)-'batch_id'
FROM kw_staging.customers s WHERE batch_id=:batch_id
UNION ALL
SELECT 'products',jsonb_build_array(source_product_id),to_jsonb(s)-'batch_id'
FROM kw_staging.products s WHERE batch_id=:batch_id
UNION ALL
SELECT 'sellers',jsonb_build_array(source_seller_id),to_jsonb(s)-'batch_id'
FROM kw_staging.sellers s WHERE batch_id=:batch_id
UNION ALL
SELECT 'orders',jsonb_build_array(source_order_id),to_jsonb(s)-'batch_id'
FROM kw_staging.orders s WHERE batch_id=:batch_id
UNION ALL
SELECT 'items',jsonb_build_array(source_order_id,line_no),to_jsonb(s)-'batch_id'
FROM kw_staging.items s WHERE batch_id=:batch_id
UNION ALL
SELECT 'payments',jsonb_build_array(source_order_id,sequential),to_jsonb(s)-'batch_id'
FROM kw_staging.payments s WHERE batch_id=:batch_id;

CREATE OR REPLACE TEMP VIEW actual_records AS
SELECT 'customers'::TEXT AS entity,jsonb_build_array(source_unique_id) AS source_key,
       to_jsonb(c)-'customer_id' AS data FROM kw_app.customers c
UNION ALL
SELECT 'contexts',jsonb_build_array(source_customer_id),to_jsonb(x)
FROM (SELECT c.source_customer_id,p.source_unique_id,c.zip_code_prefix,c.city,c.state
      FROM kw_app.customer_order_contexts c JOIN kw_app.customers p USING(customer_id)) x
UNION ALL
SELECT 'products',jsonb_build_array(source_product_id),to_jsonb(p)-'product_id' FROM kw_app.products p
UNION ALL
SELECT 'sellers',jsonb_build_array(source_seller_id),to_jsonb(s)-'seller_id' FROM kw_app.sellers s
UNION ALL
SELECT 'orders',jsonb_build_array(source_order_id),to_jsonb(x)
FROM (SELECT o.source_order_id,c.source_customer_id,
      COALESCE(to_jsonb(o)->>'order_status',to_jsonb(o)->>'status') AS status,
      o.purchased_at,o.approved_at,o.delivered_carrier_at,o.delivered_customer_at,o.estimated_delivery_at
      FROM kw_app.orders o JOIN kw_app.customer_order_contexts c USING(context_id)) x
UNION ALL
SELECT 'items',jsonb_build_array(source_order_id,line_no),to_jsonb(x)
FROM (SELECT o.source_order_id,i.line_no,p.source_product_id,s.source_seller_id,
      i.shipping_limit_at,i.price,i.freight_value
      FROM kw_app.order_items i JOIN kw_app.orders o USING(order_id)
      JOIN kw_app.products p USING(product_id) JOIN kw_app.sellers s USING(seller_id)) x
UNION ALL
SELECT 'payments',jsonb_build_array(source_order_id,sequential),to_jsonb(x)
FROM (SELECT o.source_order_id,p.sequential,p.payment_type,p.installments,p.value
      FROM kw_app.payment_records p JOIN kw_app.orders o USING(order_id)) x;

-- Exact typed reconciliation includes NULLs, field values, identities and unexpected rows.
CREATE OR REPLACE TEMP VIEW differences AS
SELECT 'missing_or_changed_target'::TEXT AS issue,* FROM (
 SELECT * FROM expected_records EXCEPT ALL SELECT * FROM actual_records
) a
UNION ALL
SELECT 'unexpected_or_changed_target',* FROM (
 SELECT * FROM actual_records EXCEPT ALL SELECT * FROM expected_records
) b;
SELECT * FROM differences ORDER BY entity,source_key LIMIT 20;
SELECT kw_migration.assert_ok(NOT EXISTS(SELECT 1 FROM differences),
 'Reconciliation failed: target differs from typed source. No success may be reported.');

SELECT e.entity,e.rows AS expected_rows,a.rows AS actual_rows FROM
 (SELECT entity,count(*) AS rows FROM expected_records GROUP BY entity) e
 JOIN (SELECT entity,count(*) AS rows FROM actual_records GROUP BY entity) a USING(entity)
ORDER BY entity;

-- Aggregate each child independently: joining items directly to payments multiplies rows.
WITH src AS (
 SELECT source_order_id,sum(price) AS price,sum(freight_value) AS freight
 FROM kw_staging.items WHERE batch_id=:batch_id GROUP BY source_order_id
), dst AS (
 SELECT o.source_order_id,sum(i.price) AS price,sum(i.freight_value) AS freight
 FROM kw_app.order_items i JOIN kw_app.orders o USING(order_id) GROUP BY o.source_order_id
)
SELECT kw_migration.assert_ok(NOT EXISTS(
 SELECT 1 FROM src FULL JOIN dst USING(source_order_id)
 WHERE ROW(src.price,src.freight) IS DISTINCT FROM ROW(dst.price,dst.freight)
), 'Item totals differ by order');
WITH src AS (
 SELECT source_order_id,sum(value) AS value FROM kw_staging.payments
 WHERE batch_id=:batch_id GROUP BY source_order_id
), dst AS (
 SELECT o.source_order_id,sum(p.value) AS value
 FROM kw_app.payment_records p JOIN kw_app.orders o USING(order_id) GROUP BY o.source_order_id
)
SELECT kw_migration.assert_ok(NOT EXISTS(
 SELECT 1 FROM src FULL JOIN dst USING(source_order_id) WHERE src.value IS DISTINCT FROM dst.value
), 'Payment totals differ by order');
SELECT 'PASS: exact rows, mappings, values and per-order totals match' AS verification;
