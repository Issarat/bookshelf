# 13. ประวัติ ช่วงเวลา และลำดับชั้น

[สารบัญ](README.md) · [บทก่อนหน้า](time-language-and-collation.md) · [บทถัดไป](orders-payments-and-events.md)

## สถานะกับประวัติ

`orders.status` บอกปัจจุบัน ส่วน `order_status_history` บอกว่าเปลี่ยนเป็นอะไรเมื่อไร หากเก็บทั้งคู่ต้องแก้พร้อมกันใน Transaction และควรกำหนดตัวเรียงที่แน่นอนเมื่อเวลาเท่ากัน

`CHECK(status IN (...))` ตรวจชื่อสถานะ แต่ไม่ได้ตรวจว่าข้ามจาก pending ไป shipped ได้หรือไม่ ต้องออกแบบ transition เพิ่ม

## ช่วงเวลาที่มีผล

ประวัติราคาและการสังกัดแผนกอาจใช้ `valid_from`, `valid_to` โดยกำหนดช่วง `[)` คือรวมเริ่ม ไม่รวมจบ ทำให้ช่วงที่ต่อกันไม่ทับซ้อน

```sql
CREATE TABLE product_prices (
    price_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_id BIGINT NOT NULL REFERENCES products(product_id),
    price NUMERIC(10,2) NOT NULL CHECK (price >= 0),
    valid_from TIMESTAMPTZ NOT NULL,
    valid_to TIMESTAMPTZ,
    CHECK (valid_to IS NULL OR valid_to > valid_from)
);

CREATE EXTENSION IF NOT EXISTS btree_gist;

ALTER TABLE product_prices
ADD CONSTRAINT product_prices_no_overlap
EXCLUDE USING gist (
    product_id WITH =,
    tstzrange(valid_from, valid_to, '[)') WITH &&
);
```

การติดตั้ง extension ต้องมีสิทธิ์ที่เหมาะสม `valid_to` เป็น NULL ใน range นี้หมายถึงไม่มีขอบเขตสิ้นสุด Constraint ห้ามช่วงทับซ้อน แต่ยังยอมให้มีช่วงว่างหรือไม่มีราคาได้

หา ณ เวลาเป้าหมายด้วย `valid_from <= :time AND (valid_to IS NULL OR :time < valid_to)` การเพิ่ม `is_active` ไม่ได้แก้ช่วงทับซ้อนหรือการค้นหาอดีต

พนักงานกลับแผนกเดิมได้จึงไม่ควร UNIQUE(employee_id, department_id) ถ้าสังกัดได้ครั้งละหนึ่งแผนก ต้องกันช่วงทับซ้อนด้วย employee_id อย่างเดียวร่วมกับ `daterange` ไม่ใช่แยกตามแผนก

## Adjacency List

```sql
CREATE TABLE categories (
    category_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name TEXT NOT NULL,
    parent_id BIGINT REFERENCES categories(category_id) ON DELETE RESTRICT,
    CHECK (parent_id IS NULL OR parent_id <> category_id)
);
CREATE INDEX idx_categories_parent ON categories(parent_id);
```

CHECK กันการอ้างตัวเองตรง ๆ แต่กันวงจร A → B → A ไม่ได้ ก่อนย้ายต้องตรวจว่าแม่ใหม่ไม่ใช่ตัวเองหรือลูกหลาน และควบคุมการย้ายพร้อมกันด้วย

```sql
WITH RECURSIVE tree AS (
    SELECT category_id, name, parent_id, 0 AS depth
    FROM categories WHERE category_id = 1
    UNION ALL
    SELECT c.category_id, c.name, c.parent_id, t.depth + 1
    FROM categories c JOIN tree t ON c.parent_id = t.category_id
)
SELECT * FROM tree;
```

ตัวอย่างสมมติข้อมูลไม่มีวงจร และไม่ได้รับรองลำดับแสดงผล PostgreSQL มี CYCLE clause สำหรับช่วยตรวจวงจรใน Recursive Query ได้ตามเวอร์ชันที่ใช้งาน

## Closure Table

เก็บ `(ancestor_id, descendant_id, depth)` และใช้คู่ ancestor/descendant เป็น Primary Key รวมคู่ตัวเอง depth 0 ด้วย ช่วยอ่านลูกหลานได้ตรง ๆ แต่เพิ่มพื้นที่และภาระดูแลเส้นทางตอนย้าย ข้อกำหนดคีย์อย่างเดียวไม่รับรองว่าเส้นทางครบหรือถูกต้อง

หมวดหมู่ไม่มากและไม่ได้ค้นหาหลายระดับบ่อย เริ่มด้วย Adjacency List ก็เพียงพอ
