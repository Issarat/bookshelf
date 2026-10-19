param(
    [Parameter(Mandatory = $true)][string]$PsqlPath,
    [Parameter(Mandatory = $true)][string]$Database,
    [string]$DbHost = 'localhost',
    [int]$Port = 5432,
    [string]$DbUser = 'postgres'
)
$ErrorActionPreference = 'Stop'
$baseArgs = @('-X', '-h', $DbHost, '-p', "$Port", '-U', $DbUser, '-d', $Database,
              '-v', 'ON_ERROR_STOP=1', '-P', 'pager=off')
$scriptDir = $PSScriptRoot
$fixtureDir = Join-Path $scriptDir 'fixtures'
$scratch = Join-Path ([IO.Path]::GetTempPath()) ('bookshelf-kaggle-test-' + [guid]::NewGuid())
New-Item -ItemType Directory -Path $scratch | Out-Null
$results = [Collections.Generic.List[string]]::new()

function Invoke-CheckedPsql {
    param([string[]]$Arguments, [bool]$ExpectFailure = $false, [string]$ExpectedMessage = '')
    # Preserve native stderr for assertions across Windows PowerShell and PowerShell 7.
    $savedPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try { $output = (& $PsqlPath @baseArgs @Arguments 2>&1 | Out-String); $code = $LASTEXITCODE }
    finally { $ErrorActionPreference = $savedPreference }
    if ($ExpectFailure) {
        if ($code -eq 0 -or ($ExpectedMessage -and -not $output.Contains($ExpectedMessage))) {
            throw "Expected failure '$ExpectedMessage', exit=$code`n$output"
        }
    } elseif ($code -ne 0) { throw "psql failed, exit=$code`n$output" }
    return $output
}
function Invoke-Step([string]$Name) {
    Invoke-CheckedPsql -Arguments @('-f', (Join-Path $scriptDir $Name)) | Out-Null
}
function Invoke-Import([string]$Directory, [bool]$Fail = $false, [string]$Message = '') {
    Invoke-CheckedPsql -Arguments @('-v', "data_dir=$Directory", '-v', 'source_version=synthetic-test',
        '-f', (Join-Path $scriptDir 'run_import.sql')) -ExpectFailure $Fail -ExpectedMessage $Message | Out-Null
}
function Invoke-Sql([string]$Text, [bool]$Fail = $false, [string]$Message = '') {
    Invoke-CheckedPsql -Arguments @('-c', $Text) -ExpectFailure $Fail -ExpectedMessage $Message | Out-Null
}
function Invoke-BatchStep([string]$Name,[long]$BatchId,[bool]$Fail=$false,[string]$Message='') {
    Invoke-CheckedPsql -Arguments @('-v',"batch_id=$BatchId",'-f',(Join-Path $scriptDir $Name)) `
        -ExpectFailure $Fail -ExpectedMessage $Message | Out-Null
}
function Copy-Fixture([string]$Name) {
    $directory = Join-Path $scratch $Name
    New-Item -ItemType Directory -Path $directory | Out-Null
    Copy-Item -Path (Join-Path $fixtureDir '*.csv') -Destination $directory
    return $directory
}
function Change-File([string]$Directory, [string]$Name, [string]$Old, [string]$New) {
    $file = Join-Path $Directory $Name
    $text = [IO.File]::ReadAllText($file)
    if (-not $text.Contains($Old)) { throw "Fixture edit did not match: $Name" }
    [IO.File]::WriteAllText($file, $text.Replace($Old, $New), [Text.UTF8Encoding]::new($false))
}

try {
    Invoke-Step '00_setup.sql'
    Invoke-CheckedPsql -Arguments @('-f', (Join-Path $scriptDir '01_load.sql')) `
        -ExpectFailure $true -ExpectedMessage 'Required psql variable: data_dir' | Out-Null
    $results.Add('PASS: missing data_dir returns nonzero exit code')
    Invoke-Sql @'
SELECT kw_migration.assert_ok(
 kw_migration.safe_int('40.0')=40 AND
 kw_migration.safe_int('40.5') IS NULL AND
 kw_migration.safe_int('2147483648') IS NULL AND
 kw_migration.safe_money('-1.00') IS NULL AND
 kw_migration.safe_money('1000000000000.00') IS NULL,
 'Parser rounded, overflowed or accepted negative money');
'@
    $results.Add('PASS: integral decimal export accepted; fractional integers, overflow and negative money rejected')
    Invoke-Import $fixtureDir
    Invoke-Sql @'
SELECT kw_migration.assert_ok(
 (SELECT count(*) FROM kw_app.customers)=1 AND
 (SELECT count(*) FROM kw_app.customer_order_contexts)=2 AND
 (SELECT count(*) FROM kw_app.orders)=2 AND
 (SELECT count(*) FROM kw_app.order_items)=2 AND
 (SELECT sum(price) FROM kw_app.order_items)=30 AND
 (SELECT sum(freight_value) FROM kw_app.order_items)=5 AND
 (SELECT sum(value) FROM kw_app.payment_records)=35,
 'Unexpected fixture counts or amounts');
'@
    $results.Add('PASS: first import, shared customer identity, NULLs, leading-zero postal codes and totals')
    Invoke-Sql @'
SELECT kw_migration.assert_ok(
 EXISTS(SELECT 1 FROM kw_staging.records WHERE batch_id=1 AND entity='customers' AND payload->>'customer_id'=' c1 ') AND
 EXISTS(SELECT 1 FROM kw_staging.cleaned_records WHERE batch_id=1 AND entity='customers' AND payload->>'customer_id'='c1') AND
 EXISTS(SELECT 1 FROM kw_app.customer_order_contexts WHERE source_customer_id='c1' AND city='city_a' AND zip_code_prefix='00123') AND
 EXISTS(SELECT 1 FROM kw_app.sellers WHERE zip_code_prefix='00111') AND
 EXISTS(SELECT 1 FROM kw_app.products WHERE source_product_id='p2' AND category IS NULL) AND
 EXISTS(SELECT 1 FROM kw_app.orders WHERE source_order_id='o2' AND approved_at IS NULL),
 'Cleansing overwrote raw data, lost postal zeros, or failed normalization');
SELECT kw_migration.assert_ok(EXISTS(
 SELECT 1 FROM kw_migration.cleansing_changes WHERE batch_id=1 AND field_name='customer_id'
 AND original_value='" c1 "'::JSONB AND cleaned_value='"c1"'::JSONB
 AND applied_rules=ARRAY['trim_outer_whitespace'] AND rule_version='v1'), 'Missing cleansing audit');
SELECT kw_migration.assert_ok(
 EXISTS(SELECT 1 FROM kw_migration.cleansing_changes WHERE batch_id=1 AND field_name='product_name_lenght'
  AND original_value='"10.0"'::JSONB AND cleaned_value='"10"'::JSONB AND 'canonical_integer'=ANY(applied_rules)) AND
 EXISTS(SELECT 1 FROM kw_migration.cleansing_changes WHERE batch_id=1 AND field_name='payment_value'
  AND original_value='"15.0"'::JSONB AND cleaned_value='"15.00"'::JSONB AND 'canonical_money'=ANY(applied_rules)),
 'Missing exact numeric normalization audit');
'@
    $results.Add('PASS: raw preserved; whitespace/blank normalization, postal zeros and per-field audit verified')

    Invoke-CheckedPsql -Arguments @('-v',"data_dir=$fixtureDir",'-v','source_version=cleansing-rerun',
        '-f',(Join-Path $scriptDir '01_load.sql')) | Out-Null
    $cleanBatch=[long](Invoke-CheckedPsql -Arguments @('-At','-c','SELECT max(batch_id) FROM kw_migration.batches')).Trim()
    Invoke-BatchStep '02_validate.sql' $cleanBatch $true 'Run 01_cleanse.sql first'
    Invoke-BatchStep '01_cleanse.sql' $cleanBatch
    $auditBefore=(Invoke-CheckedPsql -Arguments @('-At','-c',"SELECT count(*) FROM kw_migration.cleansing_changes WHERE batch_id=$cleanBatch")).Trim()
    Invoke-BatchStep '01_cleanse.sql' $cleanBatch
    $auditAfter=(Invoke-CheckedPsql -Arguments @('-At','-c',"SELECT count(*) FROM kw_migration.cleansing_changes WHERE batch_id=$cleanBatch")).Trim()
    if($auditBefore -ne $auditAfter){throw 'Cleansing rerun duplicated audit rows'}
    Invoke-BatchStep '02_validate.sql' $cleanBatch
    Invoke-BatchStep '03_migrate.sql' $cleanBatch
    $results.Add('PASS: validation requires cleansing; same-batch cleansing retry preserves audit and target counts')

    Invoke-Sql @'
BEGIN;
UPDATE kw_staging.records SET payload=jsonb_set(payload,'{customer_city}','"tampered"')
WHERE batch_id=1 AND entity='customers' AND payload->>'customer_id'=' c1 ';
DO $$
DECLARE rejected BOOLEAN:=false;
BEGIN
 BEGIN PERFORM kw_migration.assert_cleansed(1);
 EXCEPTION WHEN raise_exception THEN rejected:=true; END;
 PERFORM kw_migration.assert_ok(rejected,'Changed raw data passed provenance check');
END $$;
ROLLBACK;
'@
    $results.Add('PASS: changing raw after cleansing is detected')
    Invoke-Import $fixtureDir
    Invoke-Sql "SELECT kw_migration.assert_ok((SELECT count(*) FROM kw_app.order_items)=2, 'Retry duplicated items')"
    $results.Add('PASS: identical source retry')
    $spaced = Copy-Fixture 'path with spaces'
    Invoke-Import $spaced
    $results.Add('PASS: client CSV directory containing spaces')

    $bad = Copy-Fixture 'bad-date'
    Change-File $bad 'olist_orders_dataset.csv' '2018-01-01 10:00:00' '2018-02-30 10:00:00'
    Invoke-Import $bad $true 'Validation failed'
    Invoke-Sql "SELECT kw_migration.assert_ok(EXISTS(SELECT 1 FROM kw_migration.rejects WHERE reason='invalid timestamp: order_purchase_timestamp'), 'Missing date reject')"
    $results.Add('PASS: invalid calendar date rejected with persisted evidence')

    $bad = Copy-Fixture 'bad-precision'
    Change-File $bad 'olist_order_items_dataset.csv' '10.00,2.00' '10.001,2.00'
    Invoke-Import $bad $true 'Validation failed'
    $results.Add('PASS: excess money precision rejected instead of rounded silently')

    $bad = Copy-Fixture 'orphan'
    Change-File $bad 'olist_order_items_dataset.csv' 'o1,1,p1,s1' 'o1,1,missing,s1'
    Invoke-Import $bad $true 'Validation failed'
    $results.Add('PASS: orphan rejected')

    $bad = Copy-Fixture 'duplicate'
    $file = Join-Path $bad 'olist_order_items_dataset.csv'
    $text = [IO.File]::ReadAllText($file).TrimEnd() + "`no1,1,p1,s1,2018-01-04 10:00:00,10.00,2.00`n"
    [IO.File]::WriteAllText($file, $text, [Text.UTF8Encoding]::new($false))
    Invoke-Import $bad $true 'Validation failed'
    Invoke-Sql "SELECT kw_migration.assert_ok((SELECT count(*) FROM kw_app.order_items)=2, 'Rejected import touched target')"
    $results.Add('PASS: duplicate source key rejected; target untouched')

    $bad=Copy-Fixture 'cleansing-key-collision'
    $file=Join-Path $bad 'olist_customers_dataset.csv'
    $text=[IO.File]::ReadAllText($file).TrimEnd()+"`nc1,u1,00123,city_a,SP`n"
    [IO.File]::WriteAllText($file,$text,[Text.UTF8Encoding]::new($false))
    Invoke-Import $bad $true 'Validation failed'
    Invoke-Sql @'
SELECT kw_migration.assert_ok((SELECT count(*) FROM kw_migration.rejects
 WHERE batch_id=(SELECT max(batch_id) FROM kw_migration.batches)
 AND entity='customers' AND reason='duplicate source key')=2,
 'Cleansing key collision was silently deduplicated');
'@
    $results.Add('PASS: keys colliding after trimming are rejected, never silently merged')

    $bad = Copy-Fixture 'header'
    Change-File $bad 'olist_customers_dataset.csv' 'customer_unique_id' 'unexpected_header'
    Invoke-Import $bad $true 'column name mismatch'
    $results.Add('PASS: unexpected CSV header stops atomic Load')

    $bad = Copy-Fixture 'changed-source'
    Change-File $bad 'olist_order_items_dataset.csv' '10.00,2.00' '11.00,2.00'
    Invoke-Import $bad $true 'Source differs'
    Invoke-Sql "SELECT kw_migration.assert_ok((SELECT sum(price) FROM kw_app.order_items)=30, 'Changed source overwrote target')"
    $results.Add('PASS: changed source snapshot refused')

    # Corrupt a target value deliberately; 04 must detect it, then restore fixture value.
    Invoke-Sql "UPDATE kw_app.order_items SET price=11 WHERE line_no=1"
    Invoke-CheckedPsql -Arguments @('-v', 'batch_id=1', '-f', (Join-Path $scriptDir '04_verify.sql')) `
        -ExpectFailure $true -ExpectedMessage 'Reconciliation failed' | Out-Null
    Invoke-Sql "UPDATE kw_app.order_items SET price=10 WHERE line_no=1"
    $results.Add('PASS: target drift detected by exact reconciliation')

    Invoke-Step '05_expand.sql'
    Invoke-Step '05_expand.sql'
    Invoke-Sql @'
BEGIN;
UPDATE kw_app.orders SET status='test_old_writer' WHERE source_order_id='o1';
SELECT kw_migration.assert_ok((SELECT order_status='test_old_writer' FROM kw_app.orders WHERE source_order_id='o1'), 'Old writer not synced');
UPDATE kw_app.orders SET order_status='test_new_writer' WHERE source_order_id='o1';
SELECT kw_migration.assert_ok((SELECT status='test_new_writer' FROM kw_app.orders WHERE source_order_id='o1'), 'New writer not synced');
DO $$
DECLARE rejected BOOLEAN:=false;
BEGIN
 BEGIN
  UPDATE kw_app.orders SET status='a',order_status='b' WHERE source_order_id='o1';
 EXCEPTION WHEN raise_exception THEN rejected:=true;
 END;
 PERFORM kw_migration.assert_ok(rejected,'Conflicting writers accepted');
END $$;
ROLLBACK;
'@
    $results.Add('PASS: old/new writers synchronized; conflicting values rejected')
    Invoke-Step '06_backfill.sql'
    Invoke-Step '06_backfill.sql'
    Invoke-Step '07_contract.sql'
    Invoke-Step '07_contract.sql'
    Invoke-CheckedPsql -Arguments @('-v', 'batch_id=1', '-f', (Join-Path $scriptDir '04_verify.sql')) | Out-Null
    Invoke-Import $fixtureDir $true 'Import after Contract is not supported'
    $results.Add('PASS: Expand/Backfill/Contract reruns, post-Contract verification and import guard')
    $results | ForEach-Object { Write-Output $_ }
    Write-Output "All $($results.Count) scenarios passed. Test database retained: $Database"
} finally {
    # Only delete the unique scratch directory this script created, never a caller's data path.
    $resolvedScratch = [IO.Path]::GetFullPath($scratch)
    $tempRoot = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd('\', '/') + [IO.Path]::DirectorySeparatorChar
    if ($resolvedScratch.StartsWith($tempRoot, [StringComparison]::OrdinalIgnoreCase) -and
        (Split-Path $resolvedScratch -Leaf).StartsWith('bookshelf-kaggle-test-')) {
        Remove-Item -LiteralPath $resolvedScratch -Recurse -Force
    }
}
