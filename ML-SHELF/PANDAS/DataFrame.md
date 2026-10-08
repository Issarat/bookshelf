---
title: "pandas DataFrame"
description: "การสร้างและจัดการตารางข้อมูลด้วย DataFrame"
tags:
  - python
  - pandas
---

# pandas DataFrame

DataFrame เป็นโครงสร้างข้อมูลสองมิติของ pandas
ประกอบด้วยแถวและคอลัมน์ คล้ายตารางใน Excel

แต่ละคอลัมน์เป็น Series และสามารถมีชนิดข้อมูลต่างกันได้
เช่น คอลัมน์ชื่อเป็นข้อความ ส่วนคอลัมน์คะแนนเป็นตัวเลข

## 1. การสร้าง DataFrame

สร้างจาก Dictionary โดย key เป็นชื่อคอลัมน์
และ List ของแต่ละคอลัมน์ต้องมีจำนวนรายการเท่ากัน

```python
import pandas as pd

students = pd.DataFrame({
    "name": ["Ann", "Bank", "Chai"],
    "age": [20, 21, 20],
    "score": [80, 90, 75]
})

print(students)
```

ผลลัพธ์:

```text
   name  age  score
0   Ann   20     80
1  Bank   21     90
2  Chai   20     75
```

- index ด้านซ้ายใช้ระบุแต่ละแถว
- แต่ละแถวเก็บข้อมูลนักเรียนหนึ่งคน
- แต่ละคอลัมน์เก็บข้อมูลหนึ่งประเภท

## 2. การดูข้อมูลเบื้องต้น

```python
print(students.head(2))  # สองแถวแรก
print(students.shape)    # (3, 3): จำนวนแถวและคอลัมน์
print(students.columns)  # ชื่อคอลัมน์
print(students.dtypes)   # ชนิดข้อมูลแต่ละคอลัมน์

students.info()          # ข้อมูลโครงสร้างและจำนวนค่าที่ไม่ว่าง
print(students.describe())  # สถิติของคอลัมน์ตัวเลข
```

## 3. การเลือกคอลัมน์

เลือกคอลัมน์เดียว จะได้ Series:

```python
print(students["name"])
```

เลือกหลายคอลัมน์ จะได้ DataFrame:

```python
print(students[["name", "score"]])
```

หากต้องการคอลัมน์เดียวแต่ให้ผลลัพธ์เป็น DataFrame
ให้ใช้ List ของชื่อคอลัมน์:

```python
print(students[["name"]])
```

## 4. การเลือกแถวและคอลัมน์

### เลือกด้วยป้ายกำกับ: loc

```python
print(students.loc[0])           # แถวที่มี index เป็น 0
print(students.loc[0, "name"])   # Ann
```

### เลือกด้วยตำแหน่ง: iloc

ตำแหน่งเริ่มจาก 0:

```python
print(students.iloc[0])     # แถวแรก
print(students.iloc[0, 2])  # 80
```

ในตัวอย่างนี้ index และตำแหน่งเป็นตัวเลขตรงกัน
แต่จะมีความหมายต่างกันเมื่อกำหนด index เอง:

```python
by_name = students.set_index("name")

print(by_name.loc["Bank", "score"])  # 90
print(by_name.iloc[1, 1])            # 90
```

## 5. การกรองข้อมูล

เลือกนักเรียนที่ได้คะแนนตั้งแต่ 80 ขึ้นไป:

```python
passed = students[students["score"] >= 80]
print(passed)
```

ผลลัพธ์:

```text
   name  age  score
0   Ann   20     80
1  Bank   21     90
```

กรองหลายเงื่อนไข โดยใช้ `&` แทน AND
และใส่วงเล็บครอบแต่ละเงื่อนไข:

```python
selected = students[
    (students["age"] == 20) & (students["score"] >= 80)
]

print(selected)
```

หากต้องการ OR ให้ใช้ `|`

## 6. การเพิ่มและแก้ไขคอลัมน์

เพิ่มคอลัมน์คะแนนโบนัส:

```python
students["bonus_score"] = students["score"] + 5
```

แก้ไขคะแนนของ Bank โดยเลือกแถวและคอลัมน์ด้วย loc:

```python
students.loc[students["name"] == "Bank", "score"] = 95
```

คอลัมน์ `bonus_score` เก็บค่าที่คำนวณตอนสร้าง
หากแก้ `score` ภายหลัง ต้องคำนวณโบนัสใหม่เอง:

```python
students["bonus_score"] = students["score"] + 5
```

## 7. การคำนวณและเรียงลำดับ

```python
print(students["score"].mean())  # คะแนนเฉลี่ย
print(students["score"].max())   # คะแนนสูงสุด
```

เรียงคะแนนจากมากไปน้อย:

```python
ranked = students.sort_values("score", ascending=False)
print(ranked)
```

`sort_values()` คืน DataFrame ใหม่
หากต้องการเก็บลำดับใหม่ไว้ในตัวแปรเดิม ให้เขียน:

```python
students = students.sort_values("score", ascending=False)
```

## 8. การอ่านและบันทึกไฟล์ CSV

บันทึกข้อมูลโดยไม่เขียน index ลงไฟล์:

```python
students.to_csv("students.csv", index=False)
```

อ่านไฟล์กลับมาเป็น DataFrame:

```python
loaded_students = pd.read_csv("students.csv")
print(loaded_students)
```

---

## แบบฝึกหัด

สร้าง DataFrame รายการสินค้าดังนี้:

```python
products = pd.DataFrame({
    "name": ["Book", "Pen", "Bag"],
    "price": [150, 20, 350],
    "stock": [10, 50, 5]
})
```

จากนั้นลอง:

1. เลือกคอลัมน์ name และ price

```python
columns = ["name","price"]
product_price = products[columns]
product_price.head()
```

2. เลือกแถวแรกด้วย iloc

```python
print(products.iloc[0])
```

3. กรองสินค้าที่ราคามากกว่า 100

```python
print(products[products["price"] > 100])
```

4. เพิ่มคอลัมน์ total_value จาก price คูณ stock

```python
products["total_value"] = products["price"] * products["stock"]
```

5. เรียงสินค้าตามราคาจากมากไปน้อย

```python
ranked = products.sort_values("price", ascending=False)
```

6. บันทึกข้อมูลเป็นไฟล์ products.csv

```python
products.to_csv("products.csv", index=False)
```

---

## แหล่งอ้างอิง

- [pandas: Intro to data structures — dataframe](https://pandas.pydata.org/docs/user_guide/dsintro.html#dataframe)
