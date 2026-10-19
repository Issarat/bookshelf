\set ON_ERROR_STOP on
BEGIN;
SELECT pg_advisory_xact_lock(718204, 1);
SELECT kw_migration.assert_ok(EXISTS(SELECT 1 FROM kw_migration.batches WHERE status='completed'),
 'Complete an import before Schema Migration');
SELECT kw_migration.assert_ok(NOT EXISTS(SELECT 1 FROM kw_migration.schema_steps WHERE step='07_contract'),
 'Already contracted; Expand cannot run after Contract');
ALTER TABLE kw_app.orders ADD COLUMN IF NOT EXISTS order_status TEXT;
CREATE OR REPLACE FUNCTION kw_migration.sync_order_status() RETURNS TRIGGER
LANGUAGE plpgsql AS $$
BEGIN
 IF TG_OP='INSERT' THEN
   IF NEW.status IS NOT NULL AND NEW.order_status IS NOT NULL AND NEW.status<>NEW.order_status
   THEN RAISE EXCEPTION 'Conflicting status values'; END IF;
   NEW.status:=COALESCE(NEW.status,NEW.order_status);
   NEW.order_status:=NEW.status;
 ELSE
   IF NEW.status IS DISTINCT FROM OLD.status AND NEW.order_status IS DISTINCT FROM OLD.order_status THEN
     IF NEW.status IS DISTINCT FROM NEW.order_status THEN RAISE EXCEPTION 'Conflicting status updates'; END IF;
   ELSIF NEW.status IS DISTINCT FROM OLD.status THEN NEW.order_status:=NEW.status;
   ELSIF NEW.order_status IS DISTINCT FROM OLD.order_status THEN NEW.status:=NEW.order_status;
   ELSE NEW.order_status:=NEW.status;
   END IF;
 END IF;
 RETURN NEW;
END $$;
CREATE OR REPLACE TRIGGER sync_order_status
BEFORE INSERT OR UPDATE ON kw_app.orders
FOR EACH ROW EXECUTE FUNCTION kw_migration.sync_order_status();
INSERT INTO kw_migration.schema_steps(step) VALUES('05_expand') ON CONFLICT DO NOTHING;
COMMIT;
