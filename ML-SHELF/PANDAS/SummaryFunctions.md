---
title: "Summary Functions"
description: "การสรุปสถิติ ค่าที่ไม่ซ้ำ และความถี่ของข้อมูล"
tags:
  - python
  - pandas
---

# Summary Functions

pandas มีคำสั่งสำหรับสรุปข้อมูลใน Series และ DataFrame
เช่น ค่าเฉลี่ย ผลรวม ค่าสูงสุด และความถี่ของแต่ละค่า
ช่วยให้เห็นภาพรวมโดยไม่ต้องตรวจทุกแถวเอง

บทนี้สรุปข้อมูลทั้งชุด ส่วน [Grouping](Grouping.md) ใช้คำสั่งเหล่านี้
สรุปข้อมูลแยกตามกลุ่ม

## 1. เตรียมข้อมูล

```python
import pandas as pd

products = pd.DataFrame({
    "name": ["Book", "Pen", "Bag", "Pencil"],
    "price": [150, 20, 350, 10],
    "stock": [10, 50, 5, 30]
})
```

## 2. describe(): สรุปสถิติ

```python
print(products["price"].describe())
```

ผลลัพธ์:

```text
count      4.000000
mean     132.500000
std      158.403493
min       10.000000
25%       17.500000
50%       85.000000
75%      200.000000
max      350.000000
Name: price, dtype: float64
```

| รายการ | ความหมาย |
| --- | --- |
| count | จำนวนค่าที่ไม่ว่าง |
| mean | ค่าเฉลี่ย |
| std | ส่วนเบี่ยงเบนมาตรฐานของตัวอย่าง |
| min | ค่าต่ำสุด |
| 25%, 50%, 75% | เปอร์เซ็นไทล์ โดย 50% คือมัธยฐาน |
| max | ค่าสูงสุด |

ใช้กับ DataFrame เพื่อสรุปคอลัมน์ตัวเลขในตัวอย่างนี้:

```python
print(products.describe())
```

หากต้องการรวมคอลัมน์ข้อความด้วย ให้ใช้ `include="all"`:

```python
print(products.describe(include="all"))
```

คอลัมน์ข้อความจะแสดง count, unique, top และ freq
โดย top คือค่าที่พบบ่อยที่สุด และ freq คือความถี่ของค่านั้น
หากหลายค่ามีความถี่สูงสุดเท่ากัน top อาจเป็นค่าใดก็ได้ในกลุ่มนั้น
ช่องสถิติที่ไม่ใช้กับชนิดข้อมูลนั้นจะแสดงเป็นค่าว่าง

## 3. คำนวณสถิติแต่ละแบบ

```python
print(products["price"].mean())   # ค่าเฉลี่ย: 132.5
print(products["price"].median()) # มัธยฐาน: 85.0
print(products["price"].min())    # ค่าต่ำสุด: 10
print(products["price"].max())    # ค่าสูงสุด: 350
print(products["stock"].sum())    # สต็อกรวม: 95
print(products["price"].count())  # จำนวนราคาที่ไม่ว่าง: 4
```

ค่าเฉลี่ยคือผลรวมหารด้วยจำนวนข้อมูล
ส่วนมัธยฐานคือค่ากึ่งกลางหลังเรียงข้อมูล
เมื่อมีข้อมูลจำนวนคู่ จะใช้ค่าเฉลี่ยของสองค่าตรงกลาง
ตัวอย่างราคาที่เรียงแล้วคือ 10, 20, 150, 350 จึงมีมัธยฐาน `(20 + 150) / 2 = 85`

## 4. unique(): ดูค่าที่ไม่ซ้ำกัน

```python
categories = pd.Series([
    "Stationery", "Stationery", "Accessories", "Stationery"
])

print(categories.unique().tolist())
```

ผลลัพธ์:

```text
['Stationery', 'Accessories']
```

`unique()` คืนค่าที่แตกต่างกันตามลำดับที่พบ โดยไม่ได้เรียงค่า
ตัวอย่างใช้ `.tolist()` เพื่อแสดงผลเป็น Python List

## 5. nunique(): นับจำนวนค่าที่ไม่ซ้ำกัน

```python
print(categories.nunique())
# 2
```

`unique()` ใช้ดูว่ามีค่าอะไรบ้าง ส่วน `nunique()` ใช้นับว่ามีกี่ค่า
โดย `nunique()` ข้ามค่าว่างตามค่าเริ่มต้น

## 6. value_counts(): นับความถี่

```python
print(categories.value_counts())
```

Stationery พบ 3 ครั้ง และ Accessories พบ 1 ครั้ง
โดยค่าเริ่มต้นจะเรียงจากความถี่มากไปน้อยและไม่นับค่าว่าง

แสดงเป็นสัดส่วนด้วย `normalize=True`:

```python
print(categories.value_counts(normalize=True))
# Stationery: 0.75, Accessories: 0.25
```

## 7. agg(): สรุปหลายสถิติพร้อมกัน

ใช้ List ของชื่อคำสั่งกับ Series:

```python
print(products["price"].agg(["min", "max", "mean"]))
```

ผลลัพธ์:

```text
min      10.0
max     350.0
mean    132.5
Name: price, dtype: float64
```

ใช้ Dictionary เพื่อกำหนดสถิติแยกตามคอลัมน์ใน DataFrame:

```python
summary = products.agg({
    "price": ["min", "max", "mean"],
    "stock": ["sum"]
})

print(summary)
```

ผลลัพธ์มีแถวตามชื่อสถิติและคอลัมน์ตามข้อมูลที่เลือก
คู่ที่ไม่ได้สั่งคำนวณ เช่น sum ของ price จะแสดงเป็นค่าว่าง

## 8. ค่าว่างกับการสรุปข้อมูล

```python
prices = pd.Series([150, 20, None, 10])

print(prices.count()) # 3: จำนวนค่าที่ไม่ว่าง
print(prices.size)    # 4: จำนวนรายการทั้งหมด
print(prices.mean())  # 60.0: ข้ามค่าว่างตามค่าเริ่มต้น
```

`size` ของ Series เป็น attribute จึงไม่ใส่ `()`
ส่วน `count()` เป็นเมธอดที่นับเฉพาะค่าที่ไม่ว่าง

ฝึกนับค่าว่างเป็นอีกค่าหนึ่ง:

```python
labels = pd.Series(["Stationery", "Stationery", None, "Accessories"])

print(labels.nunique())               # 2
print(labels.nunique(dropna=False))   # 3: รวมค่าว่าง
print(labels.value_counts(dropna=False))
```

อ่านเพิ่มเติมเรื่องการจัดการค่าว่างได้ใน [MissingData](MissingData.md)

---

## แบบฝึกหัด

ใช้ `products` จากหัวข้อ 1 แล้วลอง:

1. แสดงสถิติของ price ด้วย `describe()`

```python
print(products["price"].describe())
```

2. หาราคาเฉลี่ยและมัธยฐาน

```python
print(products["price"].mean())   # ค่าเฉลี่ย: 132.5
print(products["price"].median()) # มัธยฐาน: 85.0
```

3. หาสต็อกรวมของสินค้าทั้งหมด

```python
print(products["stock"].sum())
```

4. นับชื่อสินค้าที่ไม่ซ้ำกันด้วย `nunique()`

```python
print(products["name"].nunique())
```

5. สรุปราคาต่ำสุด สูงสุด และเฉลี่ยด้วย `agg()`

```python
print(products["price"].agg(["min", "max", "mean"]))
```

แบบฝึกเพิ่มเติม ใช้ `categories` จากหัวข้อ 4:

6. ดูชื่อหมวดที่ไม่ซ้ำกันด้วย `unique()`

```python
print(categories.unique().tolist())
```

7. นับความถี่ของแต่ละหมวดด้วย `value_counts()`

```python
print(categories.value_counts())
```

ลองเขียนคำตอบเอง แล้วใช้ `print()` ตรวจผลลัพธ์

## แหล่งอ้างอิง

- [pandas: Descriptive statistics](https://pandas.pydata.org/docs/user_guide/basics.html#descriptive-statistics)
- [pandas: Series.value_counts](https://pandas.pydata.org/docs/reference/api/pandas.Series.value_counts.html)
