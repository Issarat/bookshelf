---
title: "Duplicates & Sorting"
description: "การตรวจและลบข้อมูลซ้ำ พร้อมเรียงข้อมูลและจัด index"
tags:
  - python
  - pandas
---

# Duplicates & Sorting

ข้อมูลซ้ำต้องพิจารณาจากความหมายของแถว เช่น สินค้าต่างร้านไม่ใช่แถวซ้ำ
บทนี้ฝึกตรวจแถวซ้ำ เลือกแถวที่จะเก็บ และเรียงข้อมูล

## 1. เตรียมข้อมูล

```python
import pandas as pd

products = pd.DataFrame({
    "name": ["Book", "Pen", "Book", "Book", "Bag"],
    "store": ["A", "A", "A", "B", "A"],
    "price": [150, 20, 150, 160, 350],
    "stock": [10, 50, 10, 8, 5]
})
```

## 2. ตรวจข้อมูลซ้ำ

```python
print(products.duplicated())
print(products.duplicated().sum()) # 1 แถวที่ซ้ำกับแถวก่อนหน้า
print(products.loc[products.duplicated(keep=False)])
```

ค่าเริ่มต้น keep="first" เก็บแถวแรกว่าไม่ซ้ำและทำเครื่องหมายแถวถัดไป
keep=False ทำเครื่องหมายทุกแถวที่อยู่ในชุดซ้ำ
แถว index 0 และ 2 ในตัวอย่างเหมือนกันทุกคอลัมน์

ตรวจตาม key เฉพาะ name และ store:

```python
print(products.loc[products.duplicated(subset=["name", "store"], keep=False)])
```

อย่าใช้ name เพียงคอลัมน์เดียว หากสินค้าชื่อเดียวกันต่างร้านถือเป็นคนละรายการ
แถวซ้ำในที่นี้ต่างจาก index ซ้ำ ซึ่งตรวจด้วย products.index.duplicated()

## 3. ลบแถวซ้ำ

```python
unique_products = products.drop_duplicates()
print(unique_products.shape) # (4, 4)

unique_keys = products.drop_duplicates(subset=["name", "store"], keep="first")
```

keep="last" เก็บแถวสุดท้าย ส่วน keep=False ลบทุกแถวในชุดซ้ำ
การเลือก first หรือ last ขึ้นกับลำดับปัจจุบัน หากต้องเก็บรายการล่าสุด
ต้องเรียงตามเวลาบันทึกก่อน ไม่ใช่สมมติว่าแถวท้ายสุดใหม่ที่สุดเสมอ

## 4. เรียงข้อมูลและจัด index ใหม่

```python
ranked = unique_products.sort_values(
    ["price", "stock"], ascending=[False, True]
)
print(ranked)

tidy = ranked.reset_index(drop=True)
print(tidy.index.tolist()) # [0, 1, 2, 3]
```

เรียงราคามากไปน้อย ถ้าราคาเท่ากันเรียงสต็อกน้อยไปมาก
sort_values เรียงตามค่า ส่วน sort_index เรียงตามป้ายกำกับ:

```python
print(ranked.sort_index())
```

## แบบฝึกหัด

1. แสดงทุกแถวที่ซ้ำกันทั้งแถวด้วย keep=False

```python

```

2. ลบแถวซ้ำโดยเก็บแถวแรก แล้วตรวจจำนวนแถว

```python

```

3. ตรวจ key ซ้ำจาก name และ store

```python

```

4. เรียงตารางที่ลบซ้ำแล้วตาม stock จากมากไปน้อย แล้วสร้าง index ใหม่

```python

```


## แหล่งอ้างอิง

- [pandas: Duplicate data](https://pandas.pydata.org/docs/user_guide/indexing.html#duplicate-data)
- [pandas: DataFrame.sort_values](https://pandas.pydata.org/docs/reference/api/pandas.DataFrame.sort_values.html)
