# 20. Partitioning — เรียนเมื่อข้อมูลและงานรองรับ

[สารบัญ](README.md) · [บทก่อนหน้า](performance-and-maintenance.md) · [บทถัดไป](replication.md)

## แบ่งตารางเพื่ออะไร

Partitioning แบ่งตารางเชิงตรรกะออกเป็นส่วนย่อย เช่น ตามเดือน ประโยชน์อาจเป็นการตัดส่วนที่ไม่เกี่ยวกับ Query ออก และจัดการข้อมูลเก่าทีละส่วน ไม่ได้ทำให้ทุก Query เร็วขึ้น

```sql
CREATE TABLE activity_events (
    occurred_at TIMESTAMPTZ NOT NULL,
    event_id BIGINT GENERATED ALWAYS AS IDENTITY,
    event_type TEXT NOT NULL,
    PRIMARY KEY (occurred_at, event_id)
) PARTITION BY RANGE (occurred_at);

CREATE TABLE activity_events_2026_10
PARTITION OF activity_events
FOR VALUES FROM ('2026-10-01 00:00:00+00')
         TO ('2026-11-01 00:00:00+00');
```

ขอบเขตใช้ UTC อย่างชัดเจน หากรายงานใช้วันท้องถิ่นต้องแปลงขอบเขตให้ตรง กำหนดแผนสร้าง partition ถัดไป เพราะรายการนอกช่วงที่รองรับจะไม่เข้า partition นี้

## ข้อแลกเปลี่ยน

Query ต้องมีเงื่อนไขที่ช่วย pruning หากอ่านทุกช่วงก็ยังต้องอ่านหลายส่วน จำนวน partition มากเกินไปเพิ่มภาระ planning และดูแล Index ยังมีความจำเป็นตาม Query

ใน PostgreSQL 18 ข้อกำหนด PRIMARY KEY/UNIQUE บนตาราง partitioned ต้องรวมคอลัมน์ partition key ตามข้อจำกัดที่เอกสารระบุ ตัวอย่างจึงใช้คู่เวลาและรหัส ไม่ได้บังคับ event_id ไม่ซ้ำข้ามทุก partition ด้วยตัวมันเอง

การเก็บข้อมูลเก่าต้องตรวจ Foreign Key, retention, Backup และ Lock ก่อน detach/drop ไม่ใช่ลบเพื่อแก้ดิสก์เต็มโดยไม่พิจารณาประวัติ

## เมื่อใดควรพิจารณา

มีข้อมูลเติบโตต่อเนื่อง Query เลือกช่วงชัด หรือจำเป็นต้องจัดการข้อมูลเก่าเป็นชุด และมีผลวัดว่าการแบ่งช่วยจริง หากปัญหาเป็น Query ผิดหรือขาด Index ให้แก้สิ่งนั้นก่อน

## แบบฝึกหัด

ตารางเหตุการณ์แบ่งรายเดือน แต่หน้าจอค้นหาด้วย event_id อย่างเดียว คุณคาดว่าต้องตรวจส่วนใดบ้าง และจะเปลี่ยนรูปแบบค้นหาหรือการออกแบบอย่างไร?

อ่านต่อ: [Table Partitioning](https://www.postgresql.org/docs/18/ddl-partitioning.html)
