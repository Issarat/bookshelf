\set ON_ERROR_STOP on
\if :{?data_dir}
\else
  \echo 'Required: -v data_dir=C:/path/to/extracted/csv'
  SELECT kw_migration.assert_ok(false, 'Required psql variable: data_dir');
\endif
\if :{?source_version}
\else
  \set source_version manual-unversioned
\endif
-- Paths are client-side. HEADER MATCH checks names AND column order (PG 16+).
\cd :data_dir
BEGIN;
SELECT pg_advisory_xact_lock(718204, 1);
INSERT INTO kw_migration.batches(source_version,status)
VALUES (:'source_version','loaded') RETURNING batch_id \gset
SELECT set_config('kw.batch_id', :'batch_id', false);

CREATE TEMP TABLE csv_customers (
 customer_id TEXT, customer_unique_id TEXT, customer_zip_code_prefix TEXT,
 customer_city TEXT, customer_state TEXT
) ON COMMIT DROP;
CREATE TEMP TABLE csv_orders (
 order_id TEXT, customer_id TEXT, order_status TEXT, order_purchase_timestamp TEXT,
 order_approved_at TEXT, order_delivered_carrier_date TEXT,
 order_delivered_customer_date TEXT, order_estimated_delivery_date TEXT
) ON COMMIT DROP;
CREATE TEMP TABLE csv_products (
 product_id TEXT, product_category_name TEXT, product_name_lenght TEXT,
 product_description_lenght TEXT, product_photos_qty TEXT, product_weight_g TEXT,
 product_length_cm TEXT, product_height_cm TEXT, product_width_cm TEXT
) ON COMMIT DROP;
CREATE TEMP TABLE csv_sellers (
 seller_id TEXT, seller_zip_code_prefix TEXT, seller_city TEXT, seller_state TEXT
) ON COMMIT DROP;
CREATE TEMP TABLE csv_items (
 order_id TEXT, order_item_id TEXT, product_id TEXT, seller_id TEXT,
 shipping_limit_date TEXT, price TEXT, freight_value TEXT
) ON COMMIT DROP;
CREATE TEMP TABLE csv_payments (
 order_id TEXT, payment_sequential TEXT, payment_type TEXT,
 payment_installments TEXT, payment_value TEXT
) ON COMMIT DROP;

\copy csv_customers FROM 'olist_customers_dataset.csv' WITH (FORMAT csv, HEADER MATCH, ENCODING 'UTF8')
\copy csv_orders FROM 'olist_orders_dataset.csv' WITH (FORMAT csv, HEADER MATCH, ENCODING 'UTF8')
\copy csv_products FROM 'olist_products_dataset.csv' WITH (FORMAT csv, HEADER MATCH, ENCODING 'UTF8')
\copy csv_sellers FROM 'olist_sellers_dataset.csv' WITH (FORMAT csv, HEADER MATCH, ENCODING 'UTF8')
\copy csv_items FROM 'olist_order_items_dataset.csv' WITH (FORMAT csv, HEADER MATCH, ENCODING 'UTF8')
\copy csv_payments FROM 'olist_order_payments_dataset.csv' WITH (FORMAT csv, HEADER MATCH, ENCODING 'UTF8')

-- Preserve every imported raw batch. record_id is not the physical CSV line number.
INSERT INTO kw_staging.records(batch_id,entity,payload)
SELECT :batch_id,'customers',to_jsonb(c) FROM csv_customers c UNION ALL
SELECT :batch_id,'orders',to_jsonb(c) FROM csv_orders c UNION ALL
SELECT :batch_id,'products',to_jsonb(c) FROM csv_products c UNION ALL
SELECT :batch_id,'sellers',to_jsonb(c) FROM csv_sellers c UNION ALL
SELECT :batch_id,'items',to_jsonb(c) FROM csv_items c UNION ALL
SELECT :batch_id,'payments',to_jsonb(c) FROM csv_payments c;
COMMIT;
SELECT batch_id,entity,count(*) AS raw_rows
FROM kw_staging.records WHERE batch_id=:batch_id GROUP BY batch_id,entity ORDER BY entity;
\echo 'Loaded batch_id=' :batch_id
