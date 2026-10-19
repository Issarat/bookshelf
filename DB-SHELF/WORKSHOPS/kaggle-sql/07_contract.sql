\set ON_ERROR_STOP on
-- Explicit final step: run only when old clients have stopped using status.
BEGIN;
SELECT pg_advisory_xact_lock(718204, 1);
SELECT kw_migration.assert_ok(EXISTS(SELECT 1 FROM kw_migration.schema_steps WHERE step='06_backfill'),
 'Run Backfill before Contract');
SELECT EXISTS(SELECT 1 FROM kw_migration.schema_steps WHERE step='07_contract') AS contracted \gset
\if :contracted
  \echo 'Contract already applied; nothing to change.'
\else
  SELECT kw_migration.assert_ok(NOT EXISTS(SELECT 1 FROM kw_app.orders
    WHERE order_status IS NULL OR order_status IS DISTINCT FROM status), 'Cannot Contract mismatched statuses');
  DROP TRIGGER sync_order_status ON kw_app.orders;
  DROP FUNCTION kw_migration.sync_order_status();
  ALTER TABLE kw_app.orders DROP COLUMN status;
  INSERT INTO kw_migration.schema_steps(step) VALUES('07_contract');
\endif
COMMIT;
