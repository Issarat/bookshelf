# รัน SQL: Kaggle Database Design และ Migration

[กลับโจทย์ Workshop](../kaggle-design-and-migration.md) · [สารบัญ Workshop](../README.md)

ชุดนี้เตรียมสำหรับนำเข้า CSV หลัก 6 ไฟล์ของ Olist โดยใช้ `psql` กับ PostgreSQL **16 ขึ้นไป** เก็บ Raw ทำ Data Cleansing แยกชั้น ตรวจข้อมูล แล้วนำเข้าตารางสัมพันธ์และยืนยันแถว/ยอดก่อน COMMIT มีข้อมูลจำลองใน `fixtures` สำหรับทดลองโดยไม่ต้องดาวน์โหลด Kaggle

ใช้ฐานข้อมูลทดลองว่างที่แยกจากงานอื่น บัญชีต้องสร้าง schema/table/function ได้ ไม่ต้องมี Superuser สำหรับนำเข้าไฟล์ เพราะใช้ client-side `\copy` ชื่อ schema ทุกตัวขึ้นต้น `kw_` เพื่อแยกจากตัวอย่าง SQL ในบทเรียน

หากเคยใช้ 00_setup.sql รุ่นก่อนมี Cleansing ให้สร้างฐานทดลองใหม่สำหรับชุดรุ่นนี้ เพราะเพิ่มตาราง ฟังก์ชัน และสถานะ batch ไม่มีการแก้ฐานเก่าหรือลบข้อมูลเก่าให้อัตโนมัติ

## ลำดับข้อมูลและนโยบาย Cleansing

```text
CSV → kw_staging.records (Raw)
    → kw_staging.cleaned_records (Cleansed)
    → Validation → kw_app → Reconciliation
```

กฎรุ่น `v1` ตัดช่องว่าง ASCII รอบค่าฟิลด์ CSV (`space`, `tab`, `CR`, `LF`) แปลงข้อความว่างเป็น JSON null และจัดรูปแบบจำนวนเต็ม/เงินเฉพาะเมื่อแทนค่าได้ตรง ไม่เปลี่ยนตัวพิมพ์ ไม่เติมค่าที่หาย ไม่ลบ Outlier และไม่ลบแถวซ้ำ

จำนวนเต็มยอมรับ `40` หรือ `40.0` แต่ไม่ปัด `40.5` เงิน `15.0` กลายเป็น `15.00` ได้ แต่ `15.001` ค่าติดลบหรือเกินช่วงยังเป็นค่าที่ผิดและถูก Validation ปฏิเสธ รหัสไปรษณีย์ไม่ถูกแปลงเป็นตัวเลข และวันที่ผิดจะไม่ถูกซ่อมโดยเดา

ฟิลด์ที่เปลี่ยนถูกบันทึกใน `kw_migration.cleansing_changes` พร้อมค่าเดิม ค่าใหม่ รายชื่อกฎ รุ่น และ record ต้นทาง สองชั้น Staging มีแถวหนึ่งต่อหนึ่ง ไม่ deduplicate หากคีย์ชนกันหลังตัดช่องว่าง Validation จะ Reject ทุกแถวในกลุ่มนั้น

## ขอบเขตของชุดรัน

- นำเข้าข้อมูลแบบ **frozen snapshot** ครั้งแรก แล้วอนุญาตให้รันซ้ำด้วยเนื้อหาเดิมได้
- ถ้าชุดต้นทางเปลี่ยน เพิ่ม หรือลบแถวหลังนำเข้าสำเร็จแล้ว จะปฏิเสธ ไม่เขียนทับข้อมูลเงียบ ๆ ใช้ฐานข้อมูลทดลองใหม่หากต้องเปลี่ยน Dataset
- เก็บ raw batches และ rejects ไว้ตรวจย้อนหลัง ไม่ล้างตารางงานเดิมให้อัตโนมัติ
- Cleansing ไม่เขียนทับ Raw; typed views, Validation และ Migration อ่านจาก Cleansed ส่วน snapshot ป้องกัน source เปลี่ยนยังเทียบ Raw เดิมอย่างเข้มงวด
- หาก validation มีปัญหาแม้เพียงแถวเดียว จะไม่ย้ายข้อมูลทั้ง batch และไม่รายงานผลว่าสำเร็จบางส่วน
- สคริปต์ใช้ Advisory Lock ร่วมกันเพื่อกันสคริปต์ชุดนี้ชนกัน แต่ไม่ได้ควบคุม writer ภายนอก ใช้กับฐานทดลองที่ไม่มีโปรแกรมอื่นเขียนระหว่างนำเข้า
- ไม่มีการจำลองสกุลเงิน สถานะจ่าย หรือ Refund ที่ต้นทางไม่ได้ให้มา เวลาไม่มี offset เก็บเป็น TIMESTAMP โดยไม่สมมติเขตเวลา
- จำนวนเต็มยอมรับทั้ง `40` และ `40.0` ที่เศษเป็นศูนย์เท่านั้น ไม่ปัด `40.5` ให้เป็นจำนวนเต็ม ส่วนเงินปฏิเสธค่าติดลบ ทศนิยมเกินสองหลัก หรือค่าที่เกิน NUMERIC(14,2)
- ครอบคลุมเฉพาะ 6 ไฟล์ที่ระบุ ไม่ได้นำเข้า reviews, geolocation หรือไฟล์แปลหมวดหมู่

## ลำดับไฟล์

| ไฟล์ | ทำอะไร | รันซ้ำได้อย่างไร |
|---|---|---|
| [00_setup.sql](00_setup.sql) | สร้าง Raw/Cleansed Staging, ประวัติกฎแปลง Metadata, typed views และตารางปลายทาง | ครั้งเดียว; ถ้ามี schema อยู่แล้วจะ error และ rollback |
| [01_load.sql](01_load.sql) | อ่าน CSV, ตรวจ header และเก็บ batch ใหม่ทั้งชุด | ได้ สร้าง batch ใหม่ทุกครั้ง |
| [01_cleanse.sql](01_cleanse.sql) | สร้าง Cleansed และหลักฐานค่าก่อน/หลังตามกฎ v1 | ได้สำหรับ batch เดิมที่ยังไม่ completed; ต้อง Validate ใหม่ |
| [02_validate.sql](02_validate.sql) | ตรวจ Cleansed: ค่าว่าง ชนิด คีย์ซ้ำหลังแปลง และ orphan พร้อมเก็บ Raw ใน rejects | ได้หลัง Cleansing |
| [03_migrate.sql](03_migrate.sql) | ย้ายตาม dependency และตรวจผลก่อน COMMIT | ได้เมื่อ snapshot เดิมและยังไม่ Contract |
| [04_verify.sql](04_verify.sql) | เทียบทุกแถวทุกฟิลด์หลังแปลงชนิด และยอดต่อ order | ได้ก่อน/หลัง Contract ถ้าไม่เปลี่ยนข้อมูลธุรกิจ |
| [05_expand.sql](05_expand.sql) | เพิ่ม order_status และ Trigger รองรับ writer เก่า/ใหม่ | ได้ก่อน Contract |
| [06_backfill.sql](06_backfill.sql) | เติม order_status และเพิ่ม NOT NULL | ได้หลัง Expand ก่อน Contract |
| [07_contract.sql](07_contract.sql) | นำ status เดิมออกหลังหยุด writer เก่า | ได้หลัง Backfill; ครั้งถัดไปข้าม |
| [run_import.sql](run_import.sql) | รัน Load → Cleanse → Validate → Migrate → Verify ใน session เดียว | snapshot เดิม ก่อน Contract |
| [test.ps1](test.ps1) | ทดสอบ Cleansing/Audit, retry, ข้อมูลผิด และ Schema Migration ด้วย fixtures | ต้องใช้ฐานทดลองว่างใหม่สำหรับแต่ละรอบ |

ใช้ชื่อ `01_cleanse.sql` เพื่อแทรกระหว่าง `01_load.sql` กับ `02_validate.sql` โดยไม่เปลี่ยนเลขไฟล์ Schema Migration เดิม ให้รันตามตารางหรือ run_import.sql ไม่อาศัยการเรียงชื่อไฟล์ตามตัวอักษร

## 1. เตรียม psql และฐานทดลอง

ตัวอย่างต่อไปใช้ PowerShell เปลี่ยน path เวอร์ชัน PostgreSQL และบัญชีตามเครื่องจริง ใช้รหัสผ่านผ่าน prompt หรือการตั้งค่าการรับรองตัวตนของ PostgreSQL ไม่ใส่รหัสผ่านลงไฟล์ใน Git

```powershell
$pgBin = 'C:/Program Files/PostgreSQL/17/bin'
$psqlPath = Join-Path $pgBin 'psql.exe'
$createdbPath = Join-Path $pgBin 'createdb.exe'
$sqlDir = (Resolve-Path 'DB-SHELF/WORKSHOPS/kaggle-sql').Path

& $createdbPath -h localhost -p 5432 -U postgres kaggle_workshop
if ($LASTEXITCODE -ne 0) { throw 'Create database failed' }

$connectionArgs = @('-X', '-h', 'localhost', '-p', '5432', '-U', 'postgres', '-d', 'kaggle_workshop')
& $psqlPath @connectionArgs -v ON_ERROR_STOP=1 -f "$sqlDir/00_setup.sql"
if ($LASTEXITCODE -ne 0) { throw 'Setup failed' }
```

เริ่มคำสั่งจาก root ของ bookshelf หรือกำหนด `$sqlDir` เป็น absolute path เอง หากใช้ macOS/Linux หลักการเดียวกัน: `createdb` แล้ว `psql -X -v ON_ERROR_STOP=1 -d kaggle_workshop -f /absolute/path/00_setup.sql`

## 2. เลือกข้อมูลจำลองหรือไฟล์ Kaggle

ทดลองครั้งแรกด้วยข้อมูลที่สร้างขึ้นเอง ไม่ใช่ข้อมูลจริงที่คัดลอกจาก Kaggle:

```powershell
$dataDir = Join-Path $sqlDir 'fixtures'
$sourceVersion = 'synthetic-fixture-v1'
```

สำหรับข้อมูลจริง ดาวน์โหลดและแตกไฟล์จาก [Olist บน Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) ลงโฟลเดอร์บนเครื่องที่รัน psql โดยมีไฟล์ต่อไปนี้อยู่ตรงในโฟลเดอร์ ไม่ซ้อนอีกชั้น:

```text
olist_customers_dataset.csv
olist_orders_dataset.csv
olist_products_dataset.csv
olist_sellers_dataset.csv
olist_order_items_dataset.csv
olist_order_payments_dataset.csv
```

```powershell
$dataDir = 'C:/data/olist'
$sourceVersion = 'olist-version-and-download-date-you-recorded'
Get-ChildItem -LiteralPath $dataDir -Filter '*.csv' | Get-FileHash -Algorithm SHA256
```

เก็บผล hash พร้อมเวอร์ชันและเงื่อนไขใช้ข้อมูลในบันทึกการทดลอง header ต้องตรงชื่อและลำดับต้นฉบับ รวมการสะกด `product_name_lenght` และ `product_description_lenght` หากเปลี่ยนเวอร์ชันจน header ต่าง ให้ทบทวน Mapping ไม่ปิดการตรวจ header เพื่อให้รันผ่าน

## 3. นำเข้าและย้ายทั้งชุด

```powershell
& $psqlPath @connectionArgs -v ON_ERROR_STOP=1 -v "data_dir=$dataDir" -v "source_version=$sourceVersion" -f "$sqlDir/run_import.sql"
if ($LASTEXITCODE -ne 0) { throw 'Import stopped; inspect the reported step and rejects' }
```

ใช้ absolute path สำหรับ data_dir ชื่อโฟลเดอร์มีช่องว่างได้ คำสั่ง `\cd` เปลี่ยน client working directory เฉพาะ psql และ `\ir` ยังอ้างไฟล์ SQL ตามตำแหน่งของสคริปต์ ไม่ต้องแก้ path ทั้ง 6 จุด

สคริปต์เปิด/ปิด Transaction เอง ไม่ส่ง `--single-transaction` ครอบทั้งชุด เพราะ validation ต้องเก็บ rejects ให้เสร็จก่อนหยุดด้วย error แต่การย้ายตารางปลายทางและการตรวจผลก่อนสำเร็จอยู่ใน Transaction เดียวกัน

เมื่อผ่านจะเห็น `PASS: exact rows, mappings, values and per-order totals match` และ batch เป็น completed จด batch_id จากผล `01_load.sql` ไว้ ไม่เดาว่าเป็น 1 โดยเฉพาะหลังรันซ้ำ

สถานะ batch เดินจาก `loaded → cleansed → validated → completed` หาก validation ไม่ผ่านจะเป็น `rejected` Cleansing อาจเสร็จได้แม้บางค่ายังผิด เพราะมีหน้าที่แปลงเฉพาะกฎที่รู้แน่ ไม่ใช่ซ่อมทุกค่าให้ผ่าน

Fixtures ต้องได้ **1 customer, 2 contexts, 2 products, 1 seller, 2 orders, 2 items, 2 payment records** ราคา 30.00 ค่าขนส่ง 5.00 และยอดจ่าย 35.00 ข้อมูลจริงให้เทียบกับต้นทางที่ใช้ ไม่ hardcode จำนวนหรือบังคับว่าทุกคำสั่งซื้อต้องมี item/payment

## 4. รันทีละขั้นและตรวจข้อผิดพลาด

แทน `$batchId` ด้วย batch ที่โหลดจริง สามารถรันขั้น 01 แยกก่อน แล้วอ่าน batch_id จากผล:

```powershell
& $psqlPath @connectionArgs -v ON_ERROR_STOP=1 -v "data_dir=$dataDir" -v "source_version=$sourceVersion" -f "$sqlDir/01_load.sql"
if ($LASTEXITCODE -ne 0) { throw 'Load failed' }

$batchId = 1 # เปลี่ยนตามผล Load
foreach ($step in @('01_cleanse.sql', '02_validate.sql', '03_migrate.sql', '04_verify.sql')) {
    & $psqlPath @connectionArgs -v ON_ERROR_STOP=1 -v "batch_id=$batchId" -f (Join-Path $sqlDir $step)
    if ($LASTEXITCODE -ne 0) { throw "Stopped at $step" }
}
```

ตรวจสถานะและหลักฐานด้วย psql หรือโปรแกรม SQL:

```sql
SELECT * FROM kw_migration.batches ORDER BY batch_id DESC;
SELECT entity,reason,count(*) FROM kw_migration.rejects
WHERE batch_id=1 GROUP BY entity,reason;
SELECT record_id,entity,reason,payload FROM kw_migration.rejects
WHERE batch_id=1 ORDER BY entity,record_id LIMIT 20;

-- ดูค่าก่อน/หลังและกฎที่ใช้ โดย Raw ไม่เปลี่ยน
SELECT record_id,entity,field_name,original_value,cleaned_value,applied_rules,rule_version
FROM kw_migration.cleansing_changes WHERE batch_id=1
ORDER BY record_id,field_name;

SELECT r.record_id,r.entity,r.payload AS raw_payload,c.payload AS cleansed_payload
FROM kw_staging.records r
JOIN kw_staging.cleaned_records c USING(record_id)
WHERE r.batch_id=1 AND r.payload IS DISTINCT FROM c.payload
ORDER BY r.record_id;
```

หนึ่งแถวอาจมีหลาย reason จึงหาจำนวนแถวที่ปฏิเสธด้วย COUNT(DISTINCT record_id) แยก entity; record_id=0 หมายถึง source entity ว่าง ไม่ใช่ record CSV

Rejects เก็บ payload ดิบไว้เป็นหลักฐาน ส่วนเหตุผลตรวจจากค่าชั้น Cleansed ใช้ record_id เชื่อมกลับเพื่อดูว่าฟิลด์นั้นผ่านกฎใดมา หนึ่งแถวที่เปลี่ยนหลายฟิลด์จะมีหลายรายการใน cleansing_changes จึงไม่นับจำนวน log เป็นจำนวนแถวที่ทำความสะอาด

แก้สำเนาไฟล์ต้นทาง แล้วรัน Load เป็น batch ใหม่ ไม่แก้ raw batch เดิมให้สูญหลักฐาน CSV ผิดโครงสร้าง/header หรือไฟล์หายจะทำให้ Load rollback ทั้ง batch ส่วน validation ผิดจะคง raw กับ rejects และไม่เขียน target

ถ้าข้อมูลจริงชนกฎห้องทดลอง เช่น ค่าว่างที่ชุดนี้กำหนดว่าจำเป็น ให้ตรวจและปรับกฎอย่างมีเหตุผลในฐานทดลองใหม่ ไม่เติมค่าที่เดาเพื่อให้ผ่าน ทุกกฎและข้อจำกัดของ parser อยู่ใน 00/02

## 5. ทดลองรันซ้ำและตรวจ Mapping

ก่อน Schema Migration รัน `run_import.sql` ด้วยไฟล์เดิมอีกครั้ง ต้องได้ผลตรวจผ่านและจำนวน target เท่าเดิม แม้ identity sequence อาจมีช่องว่าง นี่ไม่ใช่ข้อมูลซ้ำ

```sql
SELECT o.source_order_id,o.order_id,c.source_customer_id,
       u.source_unique_id,u.customer_id
FROM kw_app.orders o
JOIN kw_app.customer_order_contexts c USING(context_id)
JOIN kw_app.customers u USING(customer_id)
ORDER BY o.source_order_id;
```

ลูกค้าคนเดียวมีหลายบริบทได้ ตารางลูกใช้ bigint ภายในและยังตามกลับ source key ได้ สินค้าชนิดเดียวซ้ำหลายบรรทัดได้ Payment แยก sequential ไม่ใช้จำนวนเงินเป็นตัวระบุ

## 6. รัน Expand → Backfill → Contract

```powershell
foreach ($step in @('05_expand.sql', '06_backfill.sql')) {
    & $psqlPath @connectionArgs -v ON_ERROR_STOP=1 -f (Join-Path $sqlDir $step)
    if ($LASTEXITCODE -ne 0) { throw "Stopped at $step" }
}
```

ระหว่างนี้ทดสอบ UPDATE `status` จากโปรแกรมเก่า และ UPDATE `order_status` จากโปรแกรมใหม่ Trigger ต้อง sync อีกฝั่ง หากส่งทั้งสองค่าไม่ตรงกันจะปฏิเสธ ทดสอบภายใน BEGIN/ROLLBACK เพื่อไม่เปลี่ยนข้อมูลจริงของ snapshot

เมื่อยืนยันว่าไม่มี client ใช้ status เดิมแล้วจึงรัน Contract แบบแยกขั้นที่ตั้งใจ:

ก่อนตรวจหลัง Contract ให้กำหนด `$batchId` เป็น batch ที่นำเข้าสำเร็จจริงตามผล Load หากไม่ได้ใช้ตัวอย่างรันทีละขั้นในหัวข้อ 4

```powershell
& $psqlPath @connectionArgs -v ON_ERROR_STOP=1 -f "$sqlDir/07_contract.sql"
if ($LASTEXITCODE -ne 0) { throw 'Contract failed' }
& $psqlPath @connectionArgs -v ON_ERROR_STOP=1 -v "batch_id=$batchId" -f "$sqlDir/04_verify.sql"
if ($LASTEXITCODE -ne 0) { throw 'Post-migration verification failed' }
```

การตรวจผลรองรับชื่อเก่า/ใหม่ แต่ Import เวอร์ชันแรกนี้จะปฏิเสธหลัง Contract เพราะยังเขียน status เดิม ใช้ฐานทดลองใหม่ถ้าต้องกลับไปฝึก Import ตั้งแต่ต้น ไม่มีไฟล์ reset ที่ DROP ข้อมูลให้โดยอัตโนมัติ

## 7. รันชุดทดสอบ

สร้างฐานทดลองว่างอีกชื่อ แล้วเรียก [test.ps1](test.ps1) โดยระบุการเชื่อมต่อ ไม่ใช้ฐานที่ทำขั้นข้างบนแล้ว:

```powershell
& $createdbPath -h localhost -p 5432 -U postgres kaggle_workshop_test
if ($LASTEXITCODE -ne 0) { throw 'Create test database failed' }
& "$sqlDir/test.ps1" -PsqlPath $psqlPath -Database kaggle_workshop_test -DbHost localhost -Port 5432 -DbUser postgres
```

ชุดทดสอบใช้ fixtures ที่มีช่องว่าง ค่าว่าง และจำนวนเต็มรูปแบบทศนิยม ตรวจว่า Raw คงเดิม กฎแปลงถูกต้องมี Audit รัน Cleansing ซ้ำไม่สร้าง log ซ้ำ และคีย์ชนหลังตัดช่องว่างถูกปฏิเสธ จากนั้นทดสอบ orphan วันที่ผิด ราคา precision เกิน header ผิด source เปลี่ยน Trigger และ Contract ไม่ดาวน์โหลดหรืออ้างว่าได้ตรวจครบทุกแถวของ Kaggle จริง

## ผลตรวจชุดรันที่ให้มา

ทดสอบบน PostgreSQL 17.2 ด้วย fixtures แล้วผ่าน 18 กรณี ครอบคลุม Cleansing/Audit และการตรวจ provenance เพิ่มจากการนำเข้า รันซ้ำ ข้อมูลผิด การตรวจยอด และ writer เก่า/ใหม่ระหว่าง Schema Migration ยังไม่ได้รันกับไฟล์ Kaggle จริงทั้งชุด ให้ตรวจผลของเวอร์ชันที่ใช้ตามขั้นตอนข้างต้น

อ่านเพิ่มเรื่อง client commands และ ON_ERROR_STOP: [คู่มือ psql](https://www.postgresql.org/docs/18/app-psql.html)
