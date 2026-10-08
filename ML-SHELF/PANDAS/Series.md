---
title: "pandas Series"
description: "การสร้าง เลือก และคำนวณข้อมูลหนึ่งมิติด้วย Series"
tags:
  - python
  - pandas
---

# pandas Series

Series เป็นโครงสร้างข้อมูลหนึ่งมิติของ pandas
ประกอบด้วยค่าข้อมูลและ index ที่ใช้ระบุแต่ละรายการ

ตัวอย่างการใช้งาน เช่น คะแนนนักเรียน ราคาสินค้า
หรือข้อมูลหนึ่งคอลัมน์จาก DataFrame

## 1. การสร้าง Series

### สร้างจาก List

```python
import pandas as pd

scores = pd.Series([80, 90, 75])
print(scores)
```

ผลลัพธ์:

```text
0    80
1    90
2    75
dtype: int64
```

- ด้านซ้ายคือ index ซึ่งเริ่มจาก 0 หากไม่ได้กำหนดเอง
- ด้านขวาคือค่าข้อมูล
- `dtype` คือชนิดข้อมูลของ Series นี้ เช่น `int64` สำหรับจำนวนเต็ม

### กำหนด index และชื่อ Series

```python
scores = pd.Series(
	[80, 90, 75],
	index=["Ann", "Bank", "Chai"],
	name="score"
)

print(scores)
```

ผลลัพธ์:

```text
Ann     80
Bank    90
Chai    75
Name: score, dtype: int64
```

ในตัวอย่างนี้ ชื่อนักเรียนเป็น index
ส่วน `score` เป็นชื่อของ Series

เมื่อสร้างจาก List จำนวน index ต้องเท่ากับจำนวนข้อมูล

### สร้างจาก Dictionary

key จะเป็น index และ value จะเป็นค่าข้อมูล

```python
scores = pd.Series({
    "Ann": 80,
    "Bank": 90,
    "Chai": 75
}, name="score")
```

## 2. การดูข้อมูลเบื้องต้น

```python
print(scores.index)   # ป้ายกำกับของแต่ละรายการ
print(scores.dtype)   # ชนิดข้อมูล
print(scores.name)    # ชื่อ Series
print(scores.size)    # จำนวนรายการ: 3
print(scores.head(2)) # สองรายการแรก
```

Series มี dtype เดียว แม้บางชนิด เช่น object
จะสามารถเก็บ Python objects หลายชนิดไว้ภายในได้

## 3. การเลือกข้อมูล

### เลือกด้วยชื่อ index: loc

```python
print(scores.loc["Bank"])
# 90
```

เลือกหลายรายการโดยส่ง List ของชื่อ index:

```python
print(scores.loc[["Ann", "Chai"]])
```

### เลือกด้วยตำแหน่ง: iloc

ตำแหน่งเริ่มจาก 0

```python
print(scores.iloc[0])
# 80
```

เลือกสองรายการแรก:

```python
print(scores.iloc[:2])
```

`loc` ใช้ป้ายกำกับ ส่วน `iloc` ใช้ตำแหน่ง
ควรเลือกใช้ให้ชัดเจน โดยเฉพาะเมื่อ index เป็นตัวเลข

## 4. การกรองข้อมูลตามเงื่อนไข

เลือกเฉพาะนักเรียนที่ได้คะแนนตั้งแต่ 80 ขึ้นไป:

```python
passed = scores[scores >= 80]
print(passed)
```

ผลลัพธ์:

```text
Ann     80
Bank    90
Name: score, dtype: int64
```

`scores >= 80` สร้าง Series ของค่า True และ False
จากนั้นใช้เลือกเฉพาะรายการที่เป็น True

## 5. การคำนวณ

### คำนวณกับทุกค่า

```python
bonus_scores = scores + 5
print(bonus_scores)
```

ผลลัพธ์:

```text
Ann     85
Bank    95
Chai    80
Name: score, dtype: int64
```

การบวก 5 จะใช้กับทุกค่า โดยไม่ต้องเขียนลูปเอง

### สรุปข้อมูล

```python
print(scores.sum())   # ผลรวม: 245
print(scores.mean())  # ค่าเฉลี่ย: 81.66666666666667
print(scores.min())   # ค่าน้อยที่สุด: 75
print(scores.max())   # ค่ามากที่สุด: 90
```

## 6. การคำนวณระหว่าง Series

pandas จับคู่ข้อมูลตาม index เมื่อคำนวณระหว่าง Series

```python
first = pd.Series([10, 20], index=["Ann", "Bank"])
second = pd.Series([1, 2], index=["Bank", "Ann"])

result = first + second

print(result.loc["Ann"])   # 12
print(result.loc["Bank"])  # 21
```

แม้ลำดับข้อมูลต่างกัน pandas ก็จับคู่ชื่อตรงกันก่อนบวก
หาก index มีอยู่เพียงฝั่งเดียว ผลลัพธ์ตำแหน่งนั้นจะเป็นค่าว่าง
ในการบวกตามปกติ

## 7. การจัดการข้อมูลที่ขาดหาย

```python
scores_with_missing = pd.Series(
    [80, None, 75],
    index=["Ann", "Bank", "Chai"],
    dtype="Int64"
)
```

`Int64` ที่ขึ้นต้นด้วย I ตัวใหญ่เป็นชนิดจำนวนเต็ม
ที่รองรับค่าว่าง ซึ่งแสดงเป็น `<NA>`

ตรวจสอบค่าว่าง:

```python
print(scores_with_missing.isna())
```

แทนค่าว่างด้วย 0:

```python
filled_scores = scores_with_missing.fillna(0)
```

หรือลบรายการที่มีค่าว่าง:

```python
available_scores = scores_with_missing.dropna()
```

ควรเลือกวิธีจัดการค่าว่างตามความหมายของข้อมูล
เช่น คะแนนที่ยังไม่ได้บันทึกอาจไม่ได้หมายถึงคะแนน 0

---

## แบบฝึกหัด

สร้าง Series ราคาสินค้าโดยมีข้อมูลดังนี้:

- Book: 150
- Pen: 20
- Bag: 350

จากนั้นลอง:

```python
data = pd.Series(
    [150, 20, 350],
    index=["Book", "Pen", "Bag"],
    dtype="Int64"
)
```

1. เลือกราคาของ Bag ด้วย loc

```python
print(data.loc["Bag"])
```

2. เลือกสินค้ารายการแรกด้วย iloc

```python
print(data.iloc[0])
```

3. กรองสินค้าที่ราคามากกว่า 100

```python
print((data[data > 100])
```

4. คำนวณราคาเฉลี่ย

```python
print(data.mean())
```

5. เพิ่มราคาสินค้าทุกรายการอีก 10

```python
add_data = data+10
print(add_data)
```

---

## แหล่งอ้างอิง

- [pandas: Intro to data structures — Series](https://pandas.pydata.org/docs/user_guide/dsintro.html#series)
