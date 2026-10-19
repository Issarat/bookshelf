# 9. Transaction และการทำงานพร้อมกัน

[สารบัญ](README.md) · [บทก่อนหน้า](sql-vs-nosql.md) · [บทถัดไป](isolation-and-mvcc.md)

## Atomicity

ใช้ `BEGIN` และ `COMMIT` รวมงานที่ต้องสำเร็จด้วยกัน เช่น บันทึกคำสั่งซื้อกับตัดสต็อก หากเกิดข้อผิดพลาดให้ `ROLLBACK` ไม่ปล่อยให้สำเร็จบางส่วน

Transaction อย่างเดียวไม่ได้แก้ทุกปัญหาการทำงานพร้อมกัน ต้องเลือกคำสั่งและ Lock ให้เหมาะสมด้วย ตัวอย่างต่อไปสมมติ isolation level ปกติคือ Read Committed; ระดับอื่นอาจเกิดข้อผิดพลาดที่ต้องลองใหม่

## ตรวจและตัดสต็อกในคำสั่งเดียว

```sql
UPDATE products
SET stock = stock - :quantity
WHERE product_id = :product_id
  AND stock >= :quantity
RETURNING product_id, stock;
```

โปรแกรมต้องตรวจว่า `quantity > 0` และได้หนึ่งแถวก่อนบันทึกคำสั่งซื้อใน Transaction เดียวกัน หากไม่ได้แถวให้ยกเลิก และเพิ่ม `CHECK(stock >= 0)` เป็นกฎป้องกันอีกชั้น

## Row-level Lock

```sql
BEGIN;
SELECT status FROM orders WHERE order_id = 1001 FOR UPDATE;
-- ตรวจสถานะหลังได้ล็อก แล้วแก้สถานะและเพิ่มประวัติ
COMMIT;
```

คำขอที่ล็อกแถวเดียวกันต้องรอ ตรวจเงื่อนไขหลังได้ล็อก และถือ Transaction ให้สั้น ไม่รอผู้ใช้กรอกฟอร์มหรือรอบริการภายนอก

ถ้ากฎง่าย ใช้ Conditional UPDATE ได้:

```sql
UPDATE orders SET status = 'paid'
WHERE order_id = 1001 AND status = 'pending'
RETURNING order_id;
```

ทำขั้นตอนถัดไปเฉพาะเมื่อคืนแถว แล้วบันทึกประวัติใน Transaction เดียวกัน

## ล็อกแถวต้นทางสำหรับกฎผลรวม

กฎยืมได้ไม่เกิน 5 เล่ม: ล็อก `members` ก่อนนับรายการยืมค้าง กฎรับนักเรียนได้ 30 คน: ล็อก `course_offerings` ก่อนนับการลงทะเบียน active

หากล็อกเฉพาะรายการลูกเดิม เมื่อยังไม่มีรายการเลยก็ไม่มีแถวให้ล็อก การล็อกแม่จึงเป็นจุดร่วมได้ แต่ทุกช่องทางเขียนต้องทำตามกติกาเดียวกัน หรือบังคับผ่านกลไกฐานข้อมูลที่ออกแบบไว้

## Optimistic Locking

เหมาะกับฟอร์มที่เปิดค้าง ใช้เลข version ตรวจว่าข้อมูลเปลี่ยนระหว่างทางหรือไม่:

```sql
UPDATE orders
SET status = 'paid', version = version + 1
WHERE order_id = 1001 AND version = 3 AND status = 'pending'
RETURNING order_id, version;
```

ถ้าไม่คืนแถว ต้องตรวจสาเหตุและให้ผู้ใช้ดูข้อมูลล่าสุด ไม่อ่าน version ใหม่แล้วส่งข้อมูลเก่าทับทันที ทุกเส้นทางแก้ข้อมูลต้องเพิ่ม version ตามกติกา และตอน UPDATE ยังมี Lock ตามปกติ

## Deadlock

เกิดเมื่อ T1 ถือ A รอ B และ T2 ถือ B รอ A ลดโอกาสโดยล็อกตามลำดับเดียวกัน เช่น:

```sql
SELECT member_id FROM members
WHERE member_id IN (10, 20)
ORDER BY member_id FOR UPDATE;
```

เมื่อ PostgreSQL ยกเลิก Transaction เพราะ Deadlock ให้ลองใหม่ทั้ง Transaction อ่านและตรวจเงื่อนไขใหม่ ใช้จำนวนครั้งจำกัด และไม่ทำผลภายนอกซ้ำ

## เปลี่ยนหมวดหมู่หลัก

ถ้าใช้ Partial Unique Index ห้ามมีหมวดหมู่หลักเกินหนึ่ง: ล็อกสินค้า ปิด A แล้วเปิด B ใน Transaction เดียวกัน แต่กฎนี้ยังอนุญาตให้ไม่มีหมวดหมู่หลัก

หากต้องมีหนึ่งเสมอ อาจใช้ `products.primary_category_id NOT NULL` แทน flag และ Composite Foreign Key ไป `product_categories(product_id, category_id)` การอ้างอิงวนกันอาจต้องใช้ `DEFERRABLE INITIALLY DEFERRED` เพื่อเลื่อนตรวจ Foreign Key ไปตอน COMMIT หากเพิ่มข้อมูลคู่ไม่ครบ COMMIT จะไม่สำเร็จ
