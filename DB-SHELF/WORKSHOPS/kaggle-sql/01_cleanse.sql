\set ON_ERROR_STOP on
-- Run AFTER Load and BEFORE Validate. Raw records are never modified.
BEGIN;
SELECT pg_advisory_xact_lock(718204, 1);
SELECT kw_migration.assert_ok(EXISTS(SELECT 1 FROM kw_migration.batches
 WHERE batch_id=:batch_id AND status IN ('loaded','cleansed','validated','rejected')),
 'Cleansing requires a loaded, uncompleted batch');

CREATE TEMP TABLE cleansing_fields ON COMMIT DROP AS
SELECT r.record_id,r.batch_id,r.entity,p.key AS field_name,p.value AS original_value,
       c.cleaned_value,c.applied_rules
FROM kw_staging.records r CROSS JOIN LATERAL jsonb_each(r.payload) p
CROSS JOIN LATERAL kw_migration.clean_field(r.entity,p.key,p.value) c
WHERE r.batch_id=:batch_id;
CREATE TEMP TABLE cleansing_result ON COMMIT DROP AS
SELECT r.record_id,r.batch_id,r.entity,r.payload AS source_payload,
       jsonb_object_agg(f.field_name,f.cleaned_value) AS payload
FROM kw_staging.records r JOIN cleansing_fields f USING(record_id,batch_id,entity)
WHERE r.batch_id=:batch_id GROUP BY r.record_id,r.batch_id,r.entity,r.payload;

-- Same-batch reruns are deterministic; changing raw/policy underneath a batch is refused.
SELECT kw_migration.assert_ok(NOT EXISTS(
 SELECT 1 FROM cleansing_result n JOIN kw_staging.cleaned_records c USING(record_id)
 WHERE ROW(c.batch_id,c.entity,c.source_payload,c.payload,c.rule_version)
       IS DISTINCT FROM ROW(n.batch_id,n.entity,n.source_payload,n.payload,'v1'::TEXT)
), 'Existing cleansing output differs. Import a new raw batch instead of rewriting history.');

INSERT INTO kw_staging.cleaned_records(record_id,batch_id,entity,source_payload,payload,rule_version)
SELECT record_id,batch_id,entity,source_payload,payload,'v1' FROM cleansing_result
ON CONFLICT(record_id) DO NOTHING;
INSERT INTO kw_migration.cleansing_changes(batch_id,record_id,entity,field_name,
 original_value,cleaned_value,applied_rules,rule_version)
SELECT batch_id,record_id,entity,field_name,original_value,cleaned_value,applied_rules,'v1'
FROM cleansing_fields WHERE original_value IS DISTINCT FROM cleaned_value
ON CONFLICT(batch_id,record_id,field_name) DO NOTHING;

SELECT kw_migration.assert_cleansed(:batch_id);
UPDATE kw_migration.batches SET status='cleansed' WHERE batch_id=:batch_id;
COMMIT;
SELECT entity,field_name,applied_rules,count(*) AS changed_fields
FROM kw_migration.cleansing_changes WHERE batch_id=:batch_id
GROUP BY entity,field_name,applied_rules ORDER BY entity,field_name;
SELECT 'Cleansed values are ready; invalid or ambiguous values still require validation.' AS result;
