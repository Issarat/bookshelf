# 14. คำสั่งซื้อ การชำระเงิน และ Event

[สารบัญ](README.md) · [บทก่อนหน้า](history-and-hierarchies.md) · [บทถัดไป](audit-logs.md)

## หัวรายการและรายละเอียด

`orders` เก็บผู้ซื้อ เวลา สถานะ สกุลเงิน และยอดที่ตกลง ส่วน `order_items` เก็บแต่ละบรรทัด ได้แก่ `order_item_id`, `order_id`, `line_no`, `product_id`, ชื่อ Snapshot, จำนวน และราคาที่ซื้อ

ใช้ `UNIQUE(order_id, line_no)` ถ้าสินค้าชนิดเดิมอยู่หลายบรรทัดได้ ไม่ใช้ UNIQUE(order_id, product_id)

ยอดตะกร้าอาจคำนวณใหม่ ส่วนยอดที่ยืนยันแล้วต้องรักษาตามกฎส่วนลด ภาษี ค่าจัดส่ง และการปัดเศษ การแก้หลังยืนยันอาจต้องเป็นกระบวนการปรับยอดแยก

## Payments และ Refunds

หนึ่งคำสั่งซื้อมีหลาย Payment ได้ เช่น มัดจำแล้วจ่ายส่วนที่เหลือ แต่ละรายการมี amount, currency, status, paid_at และรหัสจากผู้ให้บริการ

- รวมเฉพาะการจ่าย succeeded ไม่รวม failed หรือ pending
- ใช้ UNIQUE(provider, provider_reference) ถ้ารหัสไม่ซ้ำเฉพาะในผู้ให้บริการนั้น
- ใช้ Composite Foreign Key `(order_id, currency)` ไป orders เพื่อบังคับสกุลเงินเดียวกัน โดยฝั่ง orders มี UNIQUE ของคู่นี้และ currency เป็น NOT NULL
- รหัสอ้างอิง nullable อาจซ้ำเป็น NULL ได้ตาม UNIQUE แบบปกติ ต้องกำหนดว่ารหัสจำเป็นเมื่อใด

การคืนเงินใช้ `refunds` แยก มี payment_id, amount, status, reason, created_at, refunded_at ไม่ลด payments.amount เพราะต้องรักษายอดรับเดิมและประวัติคืนบางส่วนหลายครั้ง

กฎคืนไม่เกินยอดรับต้องควบคุมข้ามแถว และควรพิจารณายอด pending ที่จองไว้ด้วย การตรวจยอดจ่ายเกินก็เช่นกัน แต่หากเงินจริงเข้ามาแล้วต้องบันทึกข้อเท็จจริงและจัดการยอดเกิน ไม่ทิ้งประวัติ

## ระวัง JOIN แล้วรวมซ้ำ

Payment 1,000 บาทมี Refund สองรายการ เมื่อ JOIN ตรง ๆ Payment จะซ้ำสองแถว `SUM(DISTINCT amount)` ก็แก้ไม่ได้ เพราะคนละ Payment อาจยอดเท่ากัน

```sql
WITH refund_totals AS (
    SELECT payment_id, SUM(amount) AS refunded_amount
    FROM refunds WHERE status = 'succeeded'
    GROUP BY payment_id
)
SELECT p.order_id, p.currency,
       SUM(p.amount) AS paid_amount,
       SUM(COALESCE(r.refunded_amount, 0)) AS refunded_amount,
       SUM(p.amount - COALESCE(r.refunded_amount, 0)) AS net_amount
FROM payments p
LEFT JOIN refund_totals r ON r.payment_id = p.payment_id
WHERE p.status = 'succeeded'
GROUP BY p.order_id, p.currency;
```

## Idempotency

UNIQUE ป้องกันแถวซ้ำ แต่ต้องป้องกันผลการทำงานซ้ำด้วย เช่น เพิ่มยอดสะสมเฉพาะเมื่อเปลี่ยน Payment จาก pending เป็น succeeded ได้จริง แล้วทำทั้งคู่ใน Transaction เดียวกัน อย่าเพิ่มยอดทุกครั้งที่ได้รับ webhook

## Transactional Outbox

Transaction ของฐานข้อมูลไม่ได้ครอบคลุมการส่งข้อความภายนอกอัตโนมัติ บันทึกคำสั่งซื้อและ `outbox_events` ใน Transaction เดียวกัน แล้วให้ worker ส่งภายหลังพร้อม retry

worker อาจส่งสำเร็จแล้วหยุดก่อนบันทึกว่าส่งแล้ว จึงอาจส่งซ้ำ Outbox ไม่ได้รับรองว่าปลายทางจะได้รับครั้งเดียว

## Transactional Inbox

ฝั่งคลังเก็บ event_id ที่ประมวลผลแล้ว:

```sql
CREATE TABLE processed_events (
    event_id UUID PRIMARY KEY,
    processed_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```

ใน Transaction เดียวกัน:

1. INSERT event_id ใช้ `ON CONFLICT DO NOTHING RETURNING event_id`
2. ถ้าได้แถวจึงสร้างงานเตรียมสินค้า ถ้าไม่ได้แถวให้ข้าม
3. COMMIT ทั้งคู่ หากสร้างงานล้มเหลว ROLLBACK ทั้งคู่

ผลที่ป้องกันได้คือการสร้างงานซ้ำภายในฐานข้อมูลนั้น หากมีผลภายนอกอีกต้องออกแบบ idempotency หรือ outbox ในขั้นถัดไปด้วย
