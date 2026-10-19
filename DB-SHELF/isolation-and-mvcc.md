# 10. Isolation Level และ MVCC

[สารบัญ](README.md) · [บทก่อนหน้า](transactions-and-concurrency.md) · [บทถัดไป](indexes-and-pagination.md)

## Transaction เห็นข้อมูลชุดไหน

MVCC เก็บข้อมูลหลายเวอร์ชันเพื่อให้การอ่านใช้ snapshot ที่เหมาะสม ผู้อ่านทั่วไปจึงไม่ต้องรอผู้เขียนแถวเดียวกันเสมอไป แต่ไม่ได้หมายความว่าไม่มี Lock เช่น SELECT FOR UPDATE และการเปลี่ยนโครงสร้างยังมีผลต่อการรอได้

| ระดับใน PostgreSQL | การมองเห็น | สิ่งที่ต้องเตรียม |
|---|---|---|
| Read Committed | SELECT ปกติเริ่ม snapshot ใหม่แต่ละคำสั่ง | อ่านซ้ำอาจได้ข้อมูลต่างกัน |
| Repeatable Read | ใช้ snapshot จากคำสั่งแรกที่ไม่ใช่คำสั่งควบคุม Transaction | ยังมี serialization anomaly และอาจต้อง retry |
| Serializable | Transaction ที่สำเร็จให้ผลเทียบเท่าลำดับการทำงานทีละชุด | รับมือ serialization failure โดย retry ทั้งชุด |

Read Committed เป็นค่าเริ่มต้น ส่วน Read Uncommitted ทำงานเหมือน Read Committed ใน PostgreSQL แต่ละระดับยังเห็นการแก้ของ Transaction ตัวเองตามปกติ

## ทดลองอ่านซ้ำด้วยสอง Session

ใช้ฐานข้อมูลทดลอง สร้าง `isolation_demo(id INT PRIMARY KEY, value INT NOT NULL)` และใส่ `(1, 10)`

| ขั้น | Session A | Session B |
|---|---|---|
| 1 | BEGIN ISOLATION LEVEL READ COMMITTED; | |
| 2 | SELECT value FROM isolation_demo WHERE id = 1; | |
| 3 | | UPDATE isolation_demo SET value = 20 WHERE id = 1; แล้ว COMMIT หากไม่ได้ใช้ autocommit |
| 4 | SELECT value FROM isolation_demo WHERE id = 1; | |
| 5 | ROLLBACK; | |

ผลอ่านใน A เปลี่ยนจาก 10 เป็น 20 ลองใหม่โดยตั้งข้อมูลเริ่มต้นและเปลี่ยนเป็น REPEATABLE READ: A จะยังเห็นค่าเดิมจาก snapshot ของตัวเอง

## Snapshot คงที่ไม่ได้บังคับทุกกฎ

สมมติต้องมีเจ้าหน้าที่เวรอย่างน้อยหนึ่งคน A และ B เห็นว่าอีกคนยังอยู่ จึงต่างแก้แถวตัวเองเป็นออกเวร แม้แต่ละคนใช้ snapshot คงที่ ก็อาจทำให้ไม่มีใครอยู่เวรได้ เรียกว่า Write Skew

ทางเลือกคือออกแบบจุดล็อกร่วม หรือใช้ Serializable กับทุก Transaction ที่เกี่ยวข้อง และรองรับการลองใหม่ อย่าเพียงเพิ่ม isolation level แล้วตัดการตรวจข้อผิดพลาดออก

## Retry และอายุ Transaction

แยก SQLSTATE เช่น `40001` (serialization failure) กับ `40P01` (deadlock) จากข้อผิดพลาดธุรกิจ ลองใหม่ทั้ง Transaction แบบจำกัดครั้งและเว้นระยะ ห้ามทำการจ่ายเงินภายนอกซ้ำโดยไม่มี idempotency

Transaction ที่เปิดค้างอาจขัดขวางการเก็บกวาดเวอร์ชันเก่า ควรติดตามอายุ Transaction และหลีกเลี่ยง idle in transaction

## แบบฝึกหัด

รายงานที่อ่านยอดหัวรายการแล้วค่อยอ่านรายละเอียดควรยอมให้สองคำสั่งเห็นคนละจังหวะไหม? หากไม่ได้ ต้องเลือก snapshot ที่เหมาะสมและกำหนดอายุ Transaction ให้สั้นอย่างไร?

อ่านต่อ: [Transaction Isolation](https://www.postgresql.org/docs/18/transaction-iso.html) และ [MVCC](https://www.postgresql.org/docs/18/mvcc-intro.html) — อ้างอิง PostgreSQL 18; ตรวจเอกสารให้ตรงเวอร์ชันที่ใช้งาน
