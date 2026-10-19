# 3. Keys และ Constraints

[สารบัญ](README.md) · [บทก่อนหน้า](data-types.md) · [บทถัดไป](normalization-and-snapshots.md)

## Primary Key กับรหัสธุรกิจ

Primary Key ระบุแต่ละแถว ไม่ซ้ำและไม่เป็น `NULL` เช่น:

```sql
member_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY
```

Identity อาจมีเลขขาดช่วง จึงไม่ควรใช้เป็นเลขเอกสารที่ต้องต่อเนื่อง หรือใช้คำนวณจำนวนสมาชิก UUID ก็เป็นทางเลือกของรหัสแถว แต่ไม่ได้ป้องกันข้อมูลธุรกิจซ้ำโดยอัตโนมัติ

อีเมลเปลี่ยนได้และอาจถูกใช้ใหม่หลังปิดบัญชี จึงมักแยกจาก `member_id`

## Composite Primary Key

เป็น Primary Key หนึ่งชุดที่ประกอบด้วยหลายคอลัมน์ แต่ละคอลัมน์ซ้ำได้ แต่ค่ารวมทั้งชุดต้องไม่ซ้ำ:

```sql
CREATE TABLE book_authors (
    book_id BIGINT REFERENCES books(book_id),
    author_id BIGINT REFERENCES authors(author_id),
    author_order INT NOT NULL CHECK (author_order > 0),
    PRIMARY KEY (book_id, author_id),
    UNIQUE (book_id, author_order)
);
```

`(1,10)` กับ `(1,20)` อยู่ร่วมกันได้ แต่ `(1,10)` ซ้ำไม่ได้ ทั้งสองคอลัมน์ของ Primary Key ห้ามเป็น `NULL` อัตโนมัติ

ถ้าใช้ `id` หรือ UUID เป็น Primary Key แยก ยังต้องมี `UNIQUE(book_id, author_id)` เพื่อห้ามคู่เดิมซ้ำ

## Candidate Key, Alternate Key และ Superkey

- Candidate Key: ชุดคอลัมน์ที่ระบุแถวได้ไม่ซ้ำ และไม่มีคอลัมน์เกินจำเป็น
- Primary Key: Candidate Key ที่เลือกเป็นคีย์หลัก
- Alternate Key: Candidate Key อื่นที่ไม่ได้เลือก
- Superkey: ชุดคอลัมน์ที่ระบุแถวได้ แต่อาจมีคอลัมน์เกิน เช่น `(member_id, name)` เมื่อ `member_id` เพียงตัวเดียวพอ

ถ้ารหัสสมาชิกซ้ำข้ามบริษัทได้ Candidate Key ทางธุรกิจคือ `(tenant_id, member_code)` โดยทั้งสองคอลัมน์ควร `NOT NULL`

## CHECK และ Foreign Key

```sql
CREATE TABLE loans (
    loan_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    copy_id BIGINT NOT NULL REFERENCES book_copies(copy_id),
    member_id BIGINT NOT NULL REFERENCES members(member_id)
        ON DELETE RESTRICT,
    borrowed_at TIMESTAMPTZ NOT NULL,
    due_at TIMESTAMPTZ NOT NULL,
    returned_at TIMESTAMPTZ,
    CHECK (due_at >= borrowed_at),
    CHECK (returned_at IS NULL OR returned_at >= borrowed_at)
);
```

Foreign Key ตรวจว่าข้อมูลต้นทางมีอยู่ แต่ไม่ตรวจว่าสมาชิกถูก Soft Delete แล้วหรือไม่ และ `CHECK` บนแถวไม่ได้บังคับกฎผลรวมข้ามแถว

## Partial Unique Index

ห้ามสำเนาเดียวกันมีรายการยืมค้างพร้อมกัน:

```sql
CREATE UNIQUE INDEX uq_loans_active_copy
ON loans(copy_id)
WHERE returned_at IS NULL;
```

อนุญาตให้บัญชีใหม่ใช้อีเมลของบัญชีที่ปิดแล้ว:

```sql
CREATE UNIQUE INDEX uq_members_active_email
ON members(LOWER(email))
WHERE deleted_at IS NULL;
```

ต้องนำ `UNIQUE(email)` เดิมออกหากขัดกับกฎใหม่ และการกู้บัญชีเก่าอาจชนกับอีเมลของบัญชีใหม่ ประวัติเดิมต้องยังอ้าง `member_id` เก่า

## Composite Foreign Key

Foreign Key แยกกันตรวจว่าค่าแต่ละตัวมีอยู่ แต่ไม่ตรวจว่าเป็นคู่ที่ถูกต้อง เช่น คำสั่งซื้อของ A อาจเลือกที่อยู่ของ B ได้

```sql
ALTER TABLE member_addresses
ADD CONSTRAINT uq_address_member UNIQUE (member_id, address_id);

ALTER TABLE orders
ADD CONSTRAINT fk_order_member_address
FOREIGN KEY (member_id, shipping_address_id)
REFERENCES member_addresses(member_id, address_id);
```

กำหนด `NOT NULL` ตามกฎด้วย เพราะ Composite Foreign Key แบบปกติอาจไม่ตรวจคู่เมื่อมีบางคอลัมน์เป็น `NULL`

## การลบข้อมูล

| วิธี | ผลและตัวอย่าง |
|---|---|
| `RESTRICT` | ห้ามลบเมื่อมีแถวอ้างถึง เช่น สมาชิกที่มีประวัติยืม |
| `CASCADE` | ลบแถวลูกตาม เช่น รายละเอียดที่ไม่มีความหมายเมื่อไม่มีสินค้าต้นทาง |
| `SET NULL` | เก็บแถวลูก แต่ล้างการอ้างอิง คอลัมน์ต้องยอมรับ `NULL` |
| Soft Delete | ใช้ `deleted_at` ปิดใช้งานโดยยังเก็บแถว |

Soft Delete เป็น `UPDATE` จึงไม่กระตุ้น `ON DELETE` และต้องออกแบบ Query กับกฎห้ามทำรายการใหม่แยกต่างหาก สินค้าที่มีคำสั่งซื้อเก่ามักใช้ `RESTRICT` และปิดขายแทนลบจริง
