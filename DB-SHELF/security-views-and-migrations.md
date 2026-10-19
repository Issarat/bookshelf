# 16. Multi-tenant, View และ Migration

[สารบัญ](README.md) · [บทก่อนหน้า](audit-logs.md) · [บทถัดไป](database-testing.md)

## Multi-tenant

เมื่อหลายบริษัทใช้ระบบเดียว รหัสสินค้าอาจ UNIQUE เฉพาะ `(tenant_id, sku)` และใช้ Composite Foreign Key `(tenant_id, product_id)` กับ `(tenant_id, order_id)` ป้องกันรายการสินค้าข้ามบริษัท

Constraints ป้องกันการเชื่อมผิด แต่ไม่ได้ป้องกัน SELECT เห็นข้อมูลข้ามบริษัท

## Row-Level Security

```sql
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;

CREATE POLICY orders_tenant_policy ON orders
USING (tenant_id = current_setting('app.tenant_id')::BIGINT)
WITH CHECK (tenant_id = current_setting('app.tenant_id')::BIGINT);
```

โปรแกรมกำหนดบริบทหลังตรวจสิทธิ์ผู้ใช้แล้ว:

```sql
BEGIN;
SET LOCAL app.tenant_id = '10';
SELECT * FROM orders;
COMMIT;
```

USING คุมแถวที่เข้าถึง ส่วน WITH CHECK คุมค่าแถวใหม่จาก INSERT/UPDATE ต้องออกแบบให้ครบทุกตารางที่ต้องแยกบริษัท ไม่ได้ส่งต่อไปตารางลูกเอง

บัญชีแอปควรแยกจากบัญชี Migration ไม่เป็นเจ้าของตาราง ไม่เป็น Superuser และไม่มี BYPASSRLS เจ้าของตารางปกติข้าม RLS ได้ หากจำเป็นมี FORCE ROW LEVEL SECURITY สำหรับบังคับเจ้าของตามเงื่อนไขของ PostgreSQL

Policy นี้เชื่อค่า tenant ที่โปรแกรมตั้ง ไม่ใช่กลไกพิสูจน์สิทธิ์ผู้ใช้เอง SET LOCAL ช่วยจำกัดขอบเขตกับ Connection Pool แต่ไม่แทน authentication หรือการป้องกัน SQL injection

## View และ Materialized View

- View เก็บนิยาม Query ไม่เก็บผลลัพธ์ล่วงหน้า ไม่ทำให้เร็วขึ้นอัตโนมัติ
- Materialized View เก็บผลลัพธ์ เหมาะกับรายงานหนักที่ยอมให้ล่าช้า ต้องสั่ง REFRESH ผ่าน scheduler แยก

```sql
REFRESH MATERIALIZED VIEW monthly_sales;
REFRESH MATERIALIZED VIEW CONCURRENTLY monthly_sales;
```

แบบปกติอาจบล็อกการอ่าน แบบ CONCURRENTLY ยังให้อ่านได้ แต่ต้องมี Unique Index ที่ใช้คอลัมน์ ครอบคลุมทุกแถว ไม่เป็น expression หรือ partial index และ Materialized View ต้องถูกเติมข้อมูลแล้ว

Refresh ทุกชั่วโมงไม่รับรองว่าล่าช้าไม่เกินหนึ่งชั่วโมง ต้องเผื่อเวลาประมวลผลและงานล้มเหลว หากใช้ View กับ RLS ต้องตรวจสิทธิ์ของเจ้าของ View และรูปแบบ security invoker ตาม PostgreSQL เวอร์ชันที่ใช้ ไม่สมมติว่าสิทธิ์ส่งผ่านเหมือน Query ตรงเสมอ

## Expand → Migrate → Contract

เปลี่ยน `name` เป็น `full_name` โดยไม่ทำให้โปรแกรมเก่าพัง:

1. เพิ่ม full_name แต่ยังเก็บ name
2. ปรับเส้นทางเขียนให้ค่าตรงกันทุกเวอร์ชัน อาจใช้ Trigger ที่กำหนดแหล่งข้อมูลหลักชัดเจน
3. เติมข้อมูลเก่าเป็นชุดตามความเหมาะสม และตรวจสอบ
4. เปลี่ยนเส้นทางอ่าน รอจนโปรแกรมเก่าเลิกใช้
5. เพิ่มข้อกำหนดที่ต้องการ แล้วลบคอลัมน์เก่า

การคัดลอกครั้งเดียวไม่พอหากโปรแกรมเก่ายังแก้ name ได้ การเพิ่ม NOT NULL ให้ข้อมูลเก่าต้องเติมและตรวจค่าก่อน ส่วนเพิ่ม UNIQUE ต้องตรวจซ้ำตาม expression และเงื่อนไขเดียวกับ Index เช่น LOWER(email) เฉพาะบัญชี active

ระหว่างเตรียมข้อมูลอาจมีค่าซ้ำใหม่เข้ามา ต้องวางแผน concurrency, Lock และวิธีสร้าง Index ให้เหมาะกับระบบจริง

การเพิ่ม Snapshot ย้อนหลังมีข้อจำกัด: ชื่อสินค้าปัจจุบันอาจไม่ใช่ชื่อวันที่ซื้อ หากไม่เคยเก็บประวัติจะกู้จากข้อมูลปัจจุบันอย่างแน่นอนไม่ได้
