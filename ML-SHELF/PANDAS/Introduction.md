---
title: "Introduction to pandas"
description: "ภาพรวม pandas การติดตั้ง และโครงสร้างข้อมูลหลัก"
tags:
  - python
  - pandas
---

# Introduction to pandas

pandas เป็นไลบรารีของ Python สำหรับจัดการและวิเคราะห์ข้อมูล
โดยเฉพาะข้อมูลแบบตารางที่ประกอบด้วยแถวและคอลัมน์ เช่น ข้อมูลจากไฟล์ CSV

ในงาน Machine Learning เราใช้ pandas เพื่อสำรวจและเตรียมข้อมูล
ก่อนนำไปสร้างโมเดล

## pandas ใช้ทำอะไรได้บ้าง?

- อ่านและบันทึกข้อมูล เช่น ไฟล์ CSV
- เลือกคอลัมน์และกรองแถวตามเงื่อนไข
- จัดการข้อมูลที่ขาดหายหรือซ้ำกัน
- คำนวณสถิติและสรุปข้อมูล
- รวมข้อมูลจากหลายตาราง

## การติดตั้ง

```bash
pip install pandas
```

## การเริ่มใช้งาน

```python
import pandas as pd
```

`pd` เป็นชื่อย่อที่นิยมใช้ ทำให้เรียกใช้งาน pandas ได้สะดวกขึ้น

## โครงสร้างข้อมูลหลัก

### Series

ข้อมูลหนึ่งมิติที่มี index กำกับแต่ละค่า
เช่น รายการคะแนนของนักเรียน

```python
scores = pd.Series([80, 90, 75])
print(scores)
```

### DataFrame

ข้อมูลสองมิติที่มีแถวและคอลัมน์ คล้ายตารางใน Excel
แต่ละคอลัมน์สามารถเก็บข้อมูลคนละชนิดกันได้

```python
df = pd.DataFrame({
    "name": ["Ann", "Bank", "Chai"],
    "score": [80, 90, 75]
})

print(df)
```

ผลลัพธ์:

```text
   name  score
0   Ann     80
1  Bank     90
2  Chai     75
```

ตัวเลขด้านซ้ายคือ index ของแต่ละแถว
ส่วน `name` และ `score` คือชื่อคอลัมน์

## ตัวอย่างการวิเคราะห์ข้อมูล

เลือกคอลัมน์คะแนนและคำนวณค่าเฉลี่ย:

```python
average_score = df["score"].mean()
print(average_score)
```

ผลลัพธ์:

```text
81.66666666666667
```

เมื่อเลือกคอลัมน์เดียวด้วย `df["score"]` จะได้ข้อมูลชนิด Series
จากนั้นใช้ `.mean()` เพื่อคำนวณค่าเฉลี่ย

## แหล่งเรียนรู้เพิ่มเติม

- [pandas Getting Started](https://pandas.pydata.org/docs/getting_started/index.html)
- [Kaggle: Learn pandas](https://www.kaggle.com/learn/pandas)
