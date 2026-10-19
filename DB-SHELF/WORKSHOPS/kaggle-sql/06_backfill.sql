\set ON_ERROR_STOP on
BEGIN;
SELECT pg_advisory_xact_lock(718204, 1);
SELECT kw_migration.assert_ok(EXISTS(SELECT 1 FROM kw_migration.schema_steps WHERE step='05_expand')
 AND NOT EXISTS(SELECT 1 FROM kw_migration.schema_steps WHERE step='07_contract'), 'Run Expand before Backfill');
-- Whole-table backfill for the lab. Production may need bounded batches and lock budgets.
UPDATE kw_app.orders SET order_status=status WHERE order_status IS NULL;
SELECT kw_migration.assert_ok(NOT EXISTS(SELECT 1 FROM kw_app.orders
 WHERE order_status IS NULL OR order_status IS DISTINCT FROM status), 'Status mismatch after backfill');
ALTER TABLE kw_app.orders ALTER COLUMN order_status SET NOT NULL;
INSERT INTO kw_migration.schema_steps(step) VALUES('06_backfill') ON CONFLICT DO NOTHING;
COMMIT;
