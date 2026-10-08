---
title: "Frontmatter & Document Format"
description: "มาตรฐาน metadata และรูปแบบ Markdown สำหรับเอกสาร pandas"
tags:
  - python
  - pandas
---

# Frontmatter & Document Format

คู่มือนี้กำหนดรูปแบบเดียวกันสำหรับบทเรียนและสารบัญในโฟลเดอร์ PANDAS
ใช้ [DataTypes.md](../DataTypes.md) เป็นตัวอย่าง และ [AGENTS.md](AGENTS.md) เป็นกฎการแก้ไข

## 1. Frontmatter มาตรฐาน

วาง YAML frontmatter ที่ต้นไฟล์ก่อนหัวข้อแรก ไม่มีข้อความนำหน้า
ใช้ชื่อฟิลด์และลำดับเดียวกันทุกไฟล์:

```yaml
---
title: "Data Types & Conversion"
description: "การตรวจและแปลงชนิดข้อมูล รวมถึงชนิดที่รองรับค่าว่าง"
tags:
  - python
  - pandas
---
```

| ฟิลด์ | รูปแบบ | กฎ |
| --- | --- | --- |
| title | ข้อความใน double quotes | ตรงกับหัวข้อระดับ 1 ของบท |
| description | ข้อความใน double quotes | สรุปเนื้อหาของไฟล์เป็นภาษาไทยหนึ่งบรรทัด |
| tags | YAML list ของข้อความ | ใช้ python และ pandas ตามลำดับ |

title และ description เปลี่ยนตามเนื้อหาแต่ละไฟล์ ไม่คัดลอกค่าเดียวกันทุกบท
หากข้อความมี double quote ให้ escape เป็น \" ภายใน YAML string
ไม่เพิ่มฟิลด์ใหม่ เช่น date หรือ order จนกว่าจะกำหนดมาตรฐานร่วมกัน
ลำดับอ่านเก็บใน [README.md](../README.md)

## 2. โครงบทเรียน

ใช้รูปแบบต่อไปนี้โดยแทนชื่อและเนื้อหาให้ตรงกับบท:

````markdown
---
title: "ชื่อบท"
description: "คำอธิบายเนื้อหาของบทหนึ่งบรรทัด"
tags:
  - python
  - pandas
---

# ชื่อบท

บทนำและสิ่งที่จะได้เรียน

## 1. เตรียมข้อมูล

```python
import pandas as pd
```

## 2. หัวข้อเรียน

คำอธิบาย ตามด้วยโค้ดและผลลัพธ์เมื่อจำเป็น

## แบบฝึกหัด

ระบุข้อมูลที่ใช้ทำแบบฝึกหัด

1. ข้อความโจทย์

```python

```

2. ข้อความโจทย์

```python

```

## แหล่งอ้างอิง

- [pandas User Guide](https://pandas.pydata.org/docs/user_guide/index.html)
````

## 3. ข้อยกเว้น

- README.md มี frontmatter แต่ใช้สารบัญและแบบฝึกหัดรวมแทนโครงบทเรียน
- Frontmatter.md มี frontmatter แต่เป็นคู่มือเอกสาร ไม่ต้องมีแบบฝึกหัด pandas
- AGENTS.md เป็นไฟล์กฎสำหรับผู้แก้ไข จึงไม่มี frontmatter

## 4. การตรวจรูปแบบ

ตรวจว่า frontmatter อยู่ต้นไฟล์ มี title, description และ tags ครบ
หัวข้อระดับ 1 ตรงกับ title และทุก code block เปิดปิดครบ
ลิงก์ภายในต้องชี้ไปยังไฟล์ที่มีจริง ส่วนช่องคำตอบที่ยังไม่ได้ทำให้คงว่างไว้
