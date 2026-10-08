---
title: "Query & Filter"
description: "การกรองแถวด้วย query และเลือกป้ายกำกับด้วย filter"
tags:
  - python
  - pandas
---

# Query & Filter

`query()` เลือกแถวตามเงื่อนไขของค่าข้อมูลที่เขียนเป็นข้อความ
ส่วน `filter()` เลือกตามชื่อคอลัมน์หรือป้ายกำกับ index

บทนี้ต่อจาก [Indexing](Indexing.md) และ [Replace & Renaming](ReplaceAndRenaming.md)
เพื่อฝึกเลือกข้อมูลด้วยคำสั่งอีกสองรูปแบบ

## 1. เตรียมข้อมูล

```python
import pandas as pd

products = pd.DataFrame({
    "name": ["Book", "Pen", "Bag", "Pencil"],
    "category": ["Stationery", "Stationery", "Accessories", "Stationery"],
    "unit_price": [150, 20, 350, 10],
    "stock": [10, 50, 5, 30]
})

print(products)
```

## 2. query(): กรองแถวด้วยเงื่อนไข

เลือกสินค้าที่ราคามากกว่า 100:

```python
expensive = products.query("unit_price > 100")
print(expensive)
# ได้ Book และ Bag
```

ภายใน query ใช้ชื่อคอลัมน์ได้โดยตรง
คำสั่งนี้ได้ผลเหมือน Boolean indexing:

```python
expensive = products[products["unit_price"] > 100]
```

## 3. กรองหลายเงื่อนไข

ภายใน query ใช้ `and`, `or` และ `not` ได้ตาม parser เริ่มต้นของ pandas:

```python
# ราคาเกิน 100 และสต็อกอย่างน้อย 10: Book
print(products.query("unit_price > 100 and stock >= 10"))

# ราคาต่ำกว่า 100 หรือสต็อกต่ำกว่า 10: Pen, Bag, Pencil
print(products.query("unit_price < 100 or stock < 10"))

# สินค้าที่ไม่ใช่หมวด Stationery: Bag
print(products.query("not (category == 'Stationery')"))
```

เลือกช่วงราคาแบบรวมขอบทั้งสองด้าน:

```python
print(products.query("20 <= unit_price <= 150"))
# ได้ Book และ Pen
```

ข้อความ Stationery ใช้ single quotes ภายใน double quotes
เพื่อแยกค่าข้อความออกจากชื่อคอลัมน์
ส่วน Boolean indexing นอก query ยังคงใช้ `&`, `|`, `~`
และใส่วงเล็บครอบแต่ละเงื่อนไขตามบท Indexing

## 4. ใช้ตัวแปรภายนอกด้วย @

เติม `@` หน้าชื่อตัวแปร Python เพื่อใช้ค่าของตัวแปรใน query:

```python
minimum_price = 100
minimum_stock = 10

selected = products.query(
    "unit_price >= @minimum_price and stock >= @minimum_stock"
)
print(selected)
# ได้ Book
```

ใช้ List เพื่อเลือกหลายชื่อด้วย `in` และ `not in`:

```python
selected_names = ["Book", "Bag"]

print(products.query("name in @selected_names"))
print(products.query("name not in @selected_names"))
```

ใช้ query expression ที่เขียนไว้เอง และส่งค่าที่เปลี่ยนแปลงผ่านตัวแปร `@`
ไม่ควรนำข้อความเงื่อนไขจากผู้ใช้ภายนอกมารันตรง ๆ เพราะ query สามารถเรียกใช้โค้ดได้

## 5. ชื่อคอลัมน์ที่มีช่องว่าง

ครอบชื่อคอลัมน์ด้วย backticks เมื่อชื่อมีช่องว่าง:

```python
with_spaces = products.rename(columns={"unit_price": "Unit Price"})
print(with_spaces.query("`Unit Price` > 100"))
```

หรือ normalize ชื่อคอลัมน์ก่อนใช้งานตามบท Replace & Renaming

## 6. filter(): เลือกตามชื่อคอลัมน์

### items: ระบุชื่อที่ต้องการ

```python
selected_columns = products.filter(items=["name", "unit_price"], axis=1)
print(selected_columns)
```

ได้ทุกแถว แต่เหลือเฉพาะ name และ unit_price ตามลำดับที่ระบุ
items ที่ไม่มีอยู่จะถูกข้าม ต่างจาก `products[[...]]` ที่เกิด KeyError
เมื่อมีชื่อคอลัมน์ที่หาไม่พบ

### like: เลือกชื่อที่มีข้อความนั้นอยู่

```python
print(products.filter(like="price", axis=1))
# ได้คอลัมน์ unit_price
```

### regex: เลือกชื่อที่ตรงกับรูปแบบ

```python
print(products.filter(regex=r"^(name|stock)$", axis=1))
# ได้คอลัมน์ name และ stock
```

`^` หมายถึงต้นข้อความ, `$` หมายถึงท้ายข้อความ
และ `|` หมายถึงเลือกอย่างใดอย่างหนึ่ง
ตัวอย่างจึงจับคู่ชื่อ name หรือ stock แบบตรงทั้งชื่อ

เลือกใช้ items, like หรือ regex เพียงอย่างใดอย่างหนึ่งต่อการเรียก filter
สำหรับ DataFrame หากไม่ระบุ axis จะเลือกคอลัมน์ตามค่าเริ่มต้น
ตัวอย่างระบุ `axis=1` ไว้เพื่อให้ชัดเจน

## 7. filter(): เลือกตาม index

ใช้ `axis=0` เพื่อเลือกป้ายกำกับแถว:

```python
by_name = products.set_index("name")

print(by_name.filter(items=["Book", "Bag"], axis=0))
print(by_name.filter(like="Pen", axis=0))
# like="Pen" ได้ Pen และ Pencil เพราะชื่อทั้งสองมีข้อความ Pen
```

filter จับคู่กับป้ายกำกับ ไม่ใช่ค่าภายในคอลัมน์
เช่น `products.filter(like="Book", axis=0)` จะไม่ค้น Book ในคอลัมน์ name
เพราะ products เดิมมี index เป็นตัวเลข

## 8. ใช้ query และ filter ต่อกัน

กรองแถวก่อน แล้วเลือกคอลัมน์ที่ต้องการ:

```python
result = (
    products
    .query("unit_price > 100")
    .filter(items=["name", "unit_price"], axis=1)
)

print(result)
```

ผลลัพธ์:

```text
   name  unit_price
0  Book         150
2   Bag         350
```

query และ filter คืนผลลัพธ์ใหม่ตามตัวอย่างนี้
index เดิมยังอยู่ จึงเห็น 0 และ 2 หลังกรอง
หากต้องการ index ใหม่ต่อเนื่อง ใช้ `result.reset_index(drop=True)`

## สรุปการเลือกคำสั่ง

| งาน | คำสั่ง |
| --- | --- |
| เลือกแถวตามค่าข้อมูลด้วย expression | `query()` |
| เลือกคอลัมน์ตามชื่อหรือรูปแบบชื่อ | `filter(..., axis=1)` |
| เลือกแถวตามป้ายกำกับ index | `filter(..., axis=0)` |
| กรองแถวแล้วเลือกคอลัมน์พร้อมกัน | `loc[เงื่อนไข, คอลัมน์]` |

---

## แบบฝึกหัด

ใช้ products จากหัวข้อ 1 แล้วลอง:

1. ใช้ query เลือกสินค้าที่ราคาตั้งแต่ 100 ขึ้นไป

```python
expensive = products.query("unit_price >= 100")
print(expensive)
```

2. ใช้ query เลือกหมวด Stationery ที่มีสต็อกมากกว่า 20

```python
print(products.query("category == 'Stationery' and stock > 20"))
```

3. กำหนดตัวแปร maximum_price เท่ากับ 150 แล้วใช้ @ เลือกสินค้าที่ราคาไม่เกินค่านี้

```python
maximum_price = 150

selected = products.query(
    "unit_price <= @maximum_price"
)
```

4. ใช้ query และ List เลือกสินค้าชื่อ Book หรือ Pencil

```python
selected_names = ["Book", "Pencil"]
print(products.query("name in @selected_names"))
```

5. ใช้ filter แบบ items เลือกคอลัมน์ name และ stock

```python
selected_columns = products.filter(items=["name", "stock"], axis=1)
print(selected_columns)
```

6. ใช้ filter แบบ like เลือกคอลัมน์ที่มีคำว่า price ในชื่อ

```python
print(products.filter(like="price", axis=1))
```

7. ตั้ง name เป็น index แล้วใช้ filter เลือกแถว Book และ Bag

```python
by_name = products.set_index("name")
print(by_name.filter(items=["Book", "Bag"], axis=0))
```

8. ใช้ query กรองสินค้าที่สต็อกอย่างน้อย 10 แล้วต่อด้วย filter เพื่อแสดงเฉพาะ name และ unit_price

```python
print(products.query("stock >= 10").filter(items=["name", "unit_price"], axis=1))
```

ลองเขียนคำตอบเอง แล้วใช้ print ตรวจผลลัพธ์

## แหล่งอ้างอิง

- [pandas: DataFrame.query](https://pandas.pydata.org/docs/reference/api/pandas.DataFrame.query.html)
- [pandas: DataFrame.filter](https://pandas.pydata.org/docs/reference/api/pandas.DataFrame.filter.html)
