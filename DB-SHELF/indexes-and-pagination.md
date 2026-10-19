# 11. Index และ Pagination

[สารบัญ](README.md) · [บทก่อนหน้า](isolation-and-mvcc.md) · [บทถัดไป](time-language-and-collation.md)

## เริ่มจาก Query

Index ช่วยอ่าน แต่ใช้พื้นที่และเพิ่มงานตอนเขียน ไม่ต้องสร้างทุกคอลัมน์ Primary Key และ UNIQUE สร้าง Index รองรับให้อัตโนมัติ ส่วน Foreign Key ไม่สร้าง Index ฝั่งอ้างอิงให้อัตโนมัติ

```sql
CREATE INDEX idx_orders_member_status_date
ON orders(member_id, status, ordered_at DESC);
```

เหมาะกับ `WHERE member_id = ... AND status = 'paid' ORDER BY ordered_at DESC LIMIT 20` ลำดับสองคอลัมน์แรกพิจารณา Query อื่นด้วย ไม่มีกฎว่าคอลัมน์ที่มีค่าหลากหลายกว่าต้องอยู่หน้าทุกกรณี

Index เริ่มด้วยสมาชิกไม่ได้เรียงวันของทุกสมาชิกรวมกัน จึงอาจไม่เหมาะกับหน้ารายการล่าสุดของทุกคน

## EXPLAIN

```sql
EXPLAIN ANALYZE
SELECT * FROM loans
WHERE member_id = 10 AND returned_at IS NULL;
```

`EXPLAIN` แสดงแผน ส่วน `EXPLAIN ANALYZE` รันจริงและวัดผล รวมถึงคำสั่งแก้ข้อมูลหากนำไปใช้กับคำสั่งเหล่านั้น

Seq Scan ไม่ได้แปลว่าผิด ตาราง 20 แถวหรือ Query ที่อ่านข้อมูลส่วนใหญ่อาจเหมาะกับการอ่านทั้งตาราง อย่าบังคับใช้ Index โดยไม่มีหลักฐาน

## OFFSET กับ Keyset

OFFSET ใช้ง่ายและกระโดดเลขหน้าได้ แต่หน้าลึกต้องผ่านรายการที่ข้ามไปก่อน

```sql
SELECT order_id, ordered_at FROM orders
WHERE member_id = 10
  AND (ordered_at, order_id) < (:last_time, :last_id)
ORDER BY ordered_at DESC, order_id DESC
LIMIT 20;
```

Keyset ใช้ค่าของรายการสุดท้ายเป็น cursor โดยทั้งสองคอลัมน์ควร NOT NULL ใช้หน้าแรกโดยไม่ใส่เงื่อนไข cursor

```sql
CREATE INDEX idx_orders_member_cursor
ON orders(member_id, ordered_at DESC, order_id DESC);
```

ต้องใช้ `order_id` ตัดสินเมื่อเวลาเท่ากัน มิฉะนั้นรายการที่ยังไม่แสดงและมีเวลาเดียวกับท้ายหน้าก่อนจะถูกข้าม Keyset ไม่ได้ทำให้หลายหน้าเป็น snapshot เดียวกันโดยอัตโนมัติ หากคีย์เรียงเปลี่ยนระหว่างอ่านยังต้องพิจารณาพฤติกรรมที่ต้องการ
