# เข้าใจ Database Design ทีละขั้น

เรียบเรียงจากบทสนทนาสำหรับผู้ที่เขียน SQL และสร้างตารางได้แล้ว พร้อมตัวอย่าง PostgreSQL และแบบฝึกหัด เน้นออกแบบจากกฎธุรกิจ รักษาความถูกต้อง และเลือกความซับซ้อนให้เหมาะกับงาน ต่อด้วยภาพรวม Data Warehouse, Data Lake, Big Data และ Data Center

**วิธีอ่าน:** ใช้ลำดับเรียนในสารบัญด้านล่าง เริ่มจากพื้นฐานที่จำเป็น แล้วต่อด้วยการรักษาความถูกต้อง การดูแลระบบ และฝึกปฏิบัติในหมวด Workshop แยกต่างหาก ส่วนการขยายระบบบท 20–22 เรียนเมื่อมีโจทย์รองรับ บท 23–26 เป็นภาพรวมระบบวิเคราะห์และโครงสร้างพื้นฐาน สามารถอ่านหลังบท 1–19 หรือ Workshop ได้โดยไม่ต้องติดตั้งระบบกระจายก่อน เลขบทและลิงก์ก่อนหน้า/ถัดไปตรงกับลำดับในสารบัญ

## เตรียมเครื่องมือสำหรับรันโค้ด

ใช้ PostgreSQL กับเครื่องมือส่ง SQL เช่น psql หรือ pgAdmin และเตรียมฐานข้อมูลทดลองแยกจากข้อมูลจริง บทที่ทดสอบการทำงานพร้อมกันต้องเปิดอย่างน้อยสอง Connection

- SQL แต่ละส่วนเป็นตัวอย่างเฉพาะหัวข้อ ไม่ใช่ Migration ชุดเดียวที่รันต่อกันทั้งหมด ตารางที่อ้างถึงอาจต้องสร้างก่อน
- ตัวอย่างรหัสอ้างอิงใช้ `BIGINT` ให้ตรงกัน หากเปลี่ยนเป็น UUID ต้องเปลี่ยนทั้งคีย์ต้นทางและ Foreign Key
- `:parameter` หมายถึงค่าที่โปรแกรมส่งผ่าน parameter binding ไม่ใช่ไวยากรณ์ที่รันได้ตรง ๆ ทุกเครื่องมือ
- บทที่อ้างอิงเอกสาร PostgreSQL 18 ควรตรวจรายละเอียดให้ตรงเวอร์ชันที่ใช้งาน โดยเฉพาะ extension และสิทธิ์ที่ต้องใช้

## สารบัญตามลำดับเรียน

ลำดับนี้พิจารณาความรู้ที่ต้องใช้ก่อนและความสำคัญร่วมกัน ความยากเป็นค่าประเมินสำหรับผู้ที่เขียน SQL ได้แล้ว หัวข้อยากบางเรื่องควรเรียนก่อนใช้งานจริง เช่น Transaction และการทดสอบ

เลขบท 1–26 เรียงตามเส้นทางเรียนนี้แล้ว ใช้ลิงก์บทก่อนหน้า/ถัดไปในแต่ละบทเพื่ออ่านต่อเนื่องได้

| บท | หัวข้อ | ความสำคัญ / เรียนเมื่อ | ความยาก | สิ่งที่จะได้เรียนรู้ |
| --: | --- | --- | --- | --- |
| 1 | [พื้นฐาน ความสัมพันธ์ และความหมายของหนึ่งแถว](foundations.md) | พื้นฐานจำเป็น | พื้นฐาน | Entity, Relationship, Grain และตารางเชื่อม |
| 2 | [ชนิดข้อมูล NULL และ DEFAULT](data-types.md) | พื้นฐานจำเป็น | พื้นฐาน | DATE, TIMESTAMPTZ, NUMERIC, NULL และ DEFAULT |
| 3 | [Keys, Constraints และการลบข้อมูล](keys-and-constraints.md) | พื้นฐานจำเป็น | พื้นฐาน–กลาง | Primary/Foreign Key, UNIQUE, CHECK และ Soft Delete |
| 4 | [Normalization, Snapshot และข้อมูลซ้ำ](normalization-and-snapshots.md) | พื้นฐานจำเป็น | กลาง | Functional Dependency, 1NF–3NF และ Snapshot |
| 5 | [หลีกเลี่ยง Overengineering และแบบฝึกหัด](practical-design.md) | หลักคิดจำเป็น | พื้นฐาน | เลือกความซับซ้อนให้พอดีและฝึกออกแบบระบบลงทะเบียน |
| 6 | [สถานะและวงจรชีวิตข้อมูล](data-lifecycle.md) | ก่อนใช้งานจริง | กลาง | State Transition, การปิดใช้งาน และนโยบายเก็บข้อมูล |
| 7 | [Data Governance](data-governance.md) | ก่อนใช้ข้อมูลร่วมกัน | พื้นฐาน–กลาง | Ownership, นิยามข้อมูล คุณภาพ สิทธิ์ Lineage และนโยบายเก็บข้อมูล |
| 8 | [เลือกใช้ SQL กับ NoSQL อย่างไร](sql-vs-nosql.md) | ก่อนเลือกเทคโนโลยี | พื้นฐาน–กลาง | เปรียบเทียบ Relational, Document, Key-value และ Graph |
| 9 | [Transaction, Lock และการทำงานพร้อมกัน](transactions-and-concurrency.md) | จำเป็นเมื่องานเขียนหลายขั้น | กลาง | Atomicity, Row Lock, Optimistic Lock และ Deadlock |
| 10 | [Isolation Level และ MVCC](isolation-and-mvcc.md) | จำเป็นเมื่องานพร้อมกัน | กลาง–สูง | Snapshot, Read Committed, Repeatable Read และ Serializable |
| 11 | [Index, EXPLAIN และ Pagination](indexes-and-pagination.md) | จำเป็นตาม Query | กลาง | Composite Index, EXPLAIN และ Keyset Pagination |
| 12 | [เวลา ภาษา และการเปรียบเทียบข้อความ](time-language-and-collation.md) | จำเป็นเมื่อมีวันเวลา/ข้อความ | กลาง | เขตเวลา ขอบเขตวัน Collation และ Unicode |
| 13 | [ประวัติ ช่วงเวลา และลำดับชั้น](history-and-hierarchies.md) | ตามความต้องการข้อมูล | กลาง–สูง | ประวัติสถานะ ช่วงเวลา Exclusion Constraint และต้นไม้ |
| 14 | [คำสั่งซื้อ การชำระเงิน และ Event](orders-payments-and-events.md) | ตามระบบธุรกรรม | กลาง–สูง | Order Items, Payments, Refunds, Idempotency, Outbox และ Inbox |
| 15 | [Audit Log และประวัติทางธุรกิจ](audit-logs.md) | เมื่อจำเป็นต้องตรวจย้อนหลัง | กลาง | ผู้แก้ไข ค่าเดิม ค่าใหม่ และความน่าเชื่อถือของประวัติ |
| 16 | [Multi-tenant, RLS, View และ Migration](security-views-and-migrations.md) | เมื่อมีสิทธิ์/หลายบริษัท/Migration | สูง | Tenant Constraints, RLS, View และ Expand–Migrate–Contract |
| 17 | [ทดสอบกฎของฐานข้อมูล](database-testing.md) | ก่อนใช้งานจริง | กลาง–สูง | ทดสอบ Constraints, Concurrency, สิทธิ์ และ Migration |
| 18 | [Backup และ Restore](backup-and-restore.md) | ก่อนมีข้อมูลจริงที่สูญเสียไม่ได้ | กลาง | RPO, RTO, Logical Backup, PITR และการซ้อมกู้คืน |
| 19 | [ติดตามประสิทธิภาพและบำรุงรักษา](performance-and-maintenance.md) | เมื่อใช้งานจริง | กลาง–สูง | Query Plan, Statistics, Lock Wait, VACUUM และ ANALYZE |
| 20 | [Partitioning](partitioning.md) | เมื่อมีปัญหาขนาดตาราง | สูง | แบ่งตาราง Pruning ข้อจำกัดคีย์ และภาระดูแล |
| 21 | [Replication และความพร้อมใช้งาน](replication.md) | เมื่อมีโจทย์ความพร้อมใช้งาน | สูง | Replica Lag, Read-after-write และ Failover |
| 22 | [Sharding และการกระจายฐานข้อมูล](sharding.md) | เมื่อข้อจำกัดบังคับให้กระจายข้อมูล | สูงมาก | Shard Key, Routing, Hotspot และธุรกรรมข้าม Shard |
| 23 | [Data Warehouse](data-warehouse.md) | เมื่อเริ่มรวมข้อมูลเพื่อรายงาน | กลาง | OLTP/OLAP, Fact/Dimension, Grain, Star Schema, ETL/ELT และประวัติ Dimension |
| 24 | [Data Lake](data-lake.md) | เมื่อต้องจัดข้อมูลหลายรูปแบบเพื่อใช้ต่อ | กลาง | Raw/Cleansed/Curated, Catalog, Parquet, Table Format และ Lakehouse |
| 25 | [Big Data](big-data.md) | เมื่อประเมินข้อจำกัดด้านปริมาณ ความเร็ว และความหลากหลาย | กลาง–สูง | 3V, Batch/Streaming, Distributed Processing, Shuffle และ Skew |
| 26 | [Data Center](data-center.md) | เมื่อเชื่อมการออกแบบกับโครงสร้างพื้นฐาน | พื้นฐาน–กลาง | Compute, Storage, Network, Cloud, Failure Domain และการกู้บริการ |

## เส้นทางการเรียน

| บท | เป้าหมาย |
|---|---|
| 1–5 | ออกแบบตาราง คีย์ ชนิดข้อมูล ลดข้อมูลซ้ำ และเลือกความซับซ้อนให้พอดี |
| 6–8 | กำหนดวงจรชีวิต ความรับผิดชอบต่อข้อมูล และเลือกประเภทฐานข้อมูล |
| 9–12 | รักษาความถูกต้องเมื่อทำงานพร้อมกัน และรองรับ Query เวลา และภาษา |
| 13–16 | ต่อยอดประวัติ ธุรกรรม Audit สิทธิ์ และ Migration ตามโจทย์ |
| 17–19 | ทดสอบ สำรอง/กู้คืน และติดตามประสิทธิภาพก่อนและระหว่างใช้งานจริง |
| 20–22 | เรียน Partitioning, Replication และ Sharding เมื่อมีข้อจำกัดที่วัดได้ |
| 23–24 | ออกแบบข้อมูลเพื่อวิเคราะห์ เปรียบเทียบ Warehouse กับ Lake และเชื่อมกับ Cleansing |
| 25–26 | เข้าใจโจทย์ Big Data และโครงสร้างพื้นฐาน Data Center โดยแยกจากการเลือกฐานข้อมูล |

สำหรับเส้นทางวิเคราะห์ข้อมูล แนะนำอ่าน Warehouse → Lake → Big Data → Data Center ตามบท 23–26 แล้วกลับมาพิจารณาบท 20–22 เมื่อมีข้อจำกัดจริง การอ่านภาพรวมไม่จำเป็นต้องนำทุกส่วนไปใช้พร้อมกัน

**ถ้าเวลาจำกัด:** เริ่มบท 1–5 แล้วเรียน Transaction, Isolation และ Index ในบท 9–11 จากนั้นทดสอบและซ้อมกู้คืนในบท 17–18 ก่อนทำ Workshop ระบบยืมหนังสือในหมวดฝึกปฏิบัติ หัวข้อสิทธิ์ วงจรชีวิต และ Governance ให้เพิ่มตามข้อมูลและผู้ใช้ของระบบ ไม่ควรข้ามหากเป็นข้อกำหนดของงานจริง

## Workshop — ฝึกปฏิบัติ

แยกจากเลขบทเรียนหลัก สามารถเริ่มหลังเรียนบท 1–19 หรือใช้ทบทวนระหว่างเรียนได้ โดยไม่ต้องรอเรียนหัวข้อขยายระบบบท 20–22

เปิด [สารบัญ Workshop และวิธีฝึก](WORKSHOPS/README.md) เพื่อเลือกโจทย์ฝึกปฏิบัติ

ทั้งสอง Workshop ใช้รูปแบบ **เป้าหมาย → ขั้นฝึก 6 หัวข้อ → สิ่งที่ส่งมอบและเกณฑ์ตรวจ** โดยฝึกกฎธุรกิจและข้อยกเว้น Grain/Constraints, Workflow, Query/Index, การทดสอบ และ Migration/การกู้คืน

| Workshop | ความยาก | สิ่งที่จะได้ฝึก |
|---|---|---|
| [ออกแบบระบบยืมหนังสือให้ครบวงจร](WORKSHOPS/database-design-workshop.md) | กลาง–สูง | ตั้งกฎธุรกิจ ออกแบบ Schema และ Transaction ทดสอบ Query และซ้อมกู้คืน |
| [Database Design และ Migration ด้วย Dataset จาก Kaggle](WORKSHOPS/kaggle-design-and-migration.md) | กลาง–สูง | ออกแบบจาก Olist CSV, Workflow ผ่าน Raw/Cleansed Staging พร้อมประวัติกฎแปลง Query/Index, Reconciliation และ Schema Migration |

Workshop Kaggle แยก [ชุด SQL และวิธีรัน](WORKSHOPS/kaggle-sql/README.md) พร้อม Data Cleansing ที่รักษาค่าดิบ ข้อมูลจำลอง และชุดทดสอบออกจากหน้าโจทย์ ใช้ทดลองหรือเทียบหลังออกแบบเอง แล้วตรวจผลงานตามตารางสิ่งที่ส่งมอบในแต่ละ Workshop

## คำถามก่อนออกแบบ

1. หนึ่งแถวแทนอะไร?
2. อะไรต้องมีค่า อะไรห้ามซ้ำ และห้ามซ้ำในขอบเขตใด?
3. ความสัมพันธ์เป็นหนึ่งต่อหนึ่ง หนึ่งต่อหลาย หรือหลายต่อหลาย?
4. ต้องรู้ข้อมูลปัจจุบัน หรือรักษาข้อมูล ณ เวลาที่เกิดเหตุการณ์?
5. เมื่อมีคำขอพร้อมกัน กฎใดอาจถูกละเมิด?
6. ถ้าลบข้อมูลต้นทาง ประวัติควรเป็นอย่างไร?
7. Query หลักคืออะไร และจำเป็นต้องเพิ่มความซับซ้อนตอนนี้หรือไม่?
