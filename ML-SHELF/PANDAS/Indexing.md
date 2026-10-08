---
title: "Indexing and selecting data"
description: "การเลือกแถวและคอลัมน์ด้วย loc iloc และเงื่อนไข"
tags:
  - python
  - pandas
---

# Indexing and selecting data

Indexing คือการเลือกข้อมูลบางส่วนจาก Series หรือ DataFrame
เช่น เลือกคอลัมน์ เลือกแถว กรองข้อมูล และแก้ไขค่าที่ต้องการ

บทนี้ต่อจาก [DataFrame](DataFrame.md) โดยใช้ข้อมูลสินค้าเดิม
ตัวอย่างสามารถรันตามลำดับได้ และไม่ต้อง import NumPy

## 1. เตรียมข้อมูล

```python
import pandas as pd

products = pd.DataFrame({
    "name": ["Book", "Pen", "Bag"],
    "price": [150, 20, 350],
    "stock": [10, 50, 5]
})

print(products)
```

ผลลัพธ์:

```text
   name  price  stock
0  Book    150     10
1   Pen     20     50
2   Bag    350      5
```

## 2. เลือกคอลัมน์ด้วย []

เลือกคอลัมน์เดียวด้วยชื่อคอลัมน์ จะได้ Series:

```python
print(products["price"])
```

เลือกหลายคอลัมน์ด้วย List ของชื่อคอลัมน์ จะได้ DataFrame:

```python
print(products[["name", "price"]])
```

หากต้องการคอลัมน์เดียวในรูปแบบ DataFrame ให้ใช้ List เช่นกัน:

```python
print(products[["price"]])
```

## 3. เลือกด้วยป้ายกำกับ: loc

รูปแบบคือ `DataFrame.loc[แถว, คอลัมน์]`
โดยใช้ป้ายกำกับ index และชื่อคอลัมน์

```python
print(products.loc[0])                   # แถวที่มี index เป็น 0
print(products.loc[2, "price"])          # 350
print(products.loc[[0, 2], ["name", "price"]])
print(products.loc[:, ["name", "stock"]]) # ทุกแถวของสองคอลัมน์
```

เครื่องหมาย `:` หมายถึงเลือกทั้งหมดในแกนนั้น
ถ้าไม่ระบุคอลัมน์ จะเลือกทุกคอลัมน์ของแถวที่กำหนด

## 4. เลือกด้วยตำแหน่ง: iloc

รูปแบบคือ `DataFrame.iloc[ตำแหน่งแถว, ตำแหน่งคอลัมน์]`
ตำแหน่งเริ่มจาก 0 โดยไม่ขึ้นกับชื่อ index หรือชื่อคอลัมน์

```python
print(products.iloc[0])          # แถวแรก
print(products.iloc[2, 1])       # 350: แถวที่สาม คอลัมน์ที่สอง
print(products.iloc[[0, 2], [0, 1]])
print(products.iloc[-1])         # แถวสุดท้าย
```

### loc กับ iloc ต่างกันอย่างไร?

กำหนดชื่อสินค้าเป็น index เพื่อให้เห็นความแตกต่าง:

```python
by_name = products.set_index("name")

print(by_name.loc["Bag", "price"]) # ใช้ป้ายกำกับ: 350
print(by_name.iloc[2, 0])          # ใช้ตำแหน่ง: 350
```

`set_index()` ในตัวอย่างนี้คืน DataFrame ใหม่
และย้ายคอลัมน์ `name` ไปเป็น index ของ `by_name`

| วิธี | ความหมาย | ตัวอย่าง |
| --- | --- | --- |
| `[]` | เลือกคอลัมน์ด้วยชื่อ | `products["price"]` |
| `.loc[]` | เลือกด้วยป้ายกำกับ | `by_name.loc["Bag", "price"]` |
| `.iloc[]` | เลือกด้วยตำแหน่ง | `by_name.iloc[2, 0]` |

แม้ index เป็นตัวเลข `loc[0]` ก็หมายถึงป้ายกำกับ 0
ส่วน `iloc[0]` หมายถึงแถวตำแหน่งแรกเสมอ

## 5. เลือกช่วงข้อมูล: Slicing

`loc` รวมป้ายกำกับปลายทาง ส่วน `iloc` ไม่รวมตำแหน่งปลายทาง:

```python
print(products.loc[0:1])   # แถวที่มีป้ายกำกับ 0 และ 1
print(products.iloc[0:2])  # ตำแหน่ง 0 และ 1
```

ทั้งสองคำสั่งได้ Book และ Pen ในข้อมูลชุดนี้

เลือกช่วงแถวและคอลัมน์พร้อมกัน:

```python
print(products.loc[0:1, "name":"price"])
print(products.iloc[:2, :2])
```

## 6. กรองข้อมูล: Boolean indexing

เงื่อนไขจะสร้าง Series ของค่า True และ False
แล้วเลือกเฉพาะแถวที่เป็น True

```python
mask = products["price"] > 100
print(mask)
print(products[mask])
```

ผลการกรองจะเหลือ Book และ Bag
สามารถกรองแถวและเลือกคอลัมน์ด้วย loc ในคำสั่งเดียว:

```python
print(products.loc[products["price"] > 100, ["name", "price"]])
```

### กรองหลายเงื่อนไข

ใช้ `&` สำหรับ AND, `|` สำหรับ OR และ `~` สำหรับ NOT
โดยใส่วงเล็บครอบแต่ละเงื่อนไขเมื่อเชื่อมด้วย `&` หรือ `|`
ไม่ใช้ `and` และ `or` กับ Series ของเงื่อนไข

```python
# ราคามากกว่า 100 และมีสต็อกตั้งแต่ 10 ชิ้น: Book
print(products[(products["price"] > 100) & (products["stock"] >= 10)])

# ราคาน้อยกว่า 100 หรือมีสต็อกน้อยกว่า 10 ชิ้น: Pen และ Bag
print(products[(products["price"] < 100) | (products["stock"] < 10)])

# เลือกสินค้าที่ชื่ออยู่ในรายการ
print(products[products["name"].isin(["Book", "Bag"])])

# เลือกสินค้าที่ไม่ใช่ Pen
print(products[~products["name"].isin(["Pen"])])
```

## 7. แก้ไขค่าด้วย loc

เลือกแถวและคอลัมน์ในคำสั่งเดียว แล้วกำหนดค่าใหม่
ตัวอย่างนี้ใช้สำเนาเพื่อให้ข้อมูล `products` เดิมยังใช้ทำแบบฝึกหัดได้:

```python
updated_products = products.copy()

# เปลี่ยนราคา Bag เป็น 400
updated_products.loc[updated_products["name"] == "Bag", "price"] = 400

# เพิ่มสต็อกสินค้าที่ราคาตั้งแต่ 100 ขึ้นไปอีก 5 ชิ้น
updated_products.loc[updated_products["price"] >= 100, "stock"] += 5

print(updated_products)
```

ผลลัพธ์:

```text
   name  price  stock
0  Book    150     15
1   Pen     20     50
2   Bag    400     10
```

หลีกเลี่ยงการเลือกต่อกันแล้วกำหนดค่า เช่น
`products[products["name"] == "Bag"]["price"] = 400`
เพราะไม่ใช่วิธีแก้ไข DataFrame ต้นฉบับที่เชื่อถือได้
ให้ใช้ `.loc[เงื่อนไข, ชื่อคอลัมน์] = ค่า` แทน

---

## แบบฝึกหัด

ใช้ `products` จากหัวข้อ 1 แล้วลอง:

1. เลือกคอลัมน์ `name` และ `stock` ด้วย `[]`

```python
print(products[["name", "stock"]])
```

2. เลือกสองแถวแรกด้วย `iloc`

```python
print(products.iloc[[0,1]])
```

3. เลือกราคาของ Bag ด้วย `loc` หลังตั้ง `name` เป็น index

```python
by_name = products.set_index("name")

print(by_name.loc["Bag", "price"])
```

4. กรองสินค้าที่ราคามากกว่า 100 และมีสต็อกน้อยกว่า 10

```python
print(products[(products["price"] > 100) & (products["stock"]< 10)])
```

5. เลือกเฉพาะคอลัมน์ `name` ของสินค้าที่มีสต็อกตั้งแต่ 10 ขึ้นไปด้วย `loc`

```python
print(products.loc[products["stock"] >= 10, ["name"]])
```

6. สร้างสำเนา แล้วเปลี่ยนราคา Pen เป็น 25 ด้วย `loc`

```python
updated_products = products.copy()
updated_products.loc[updated_products["name"] == "Pen", "price"] = 25
print(updated_products)
```

ลองเขียนคำตอบเองก่อน แล้วใช้ `print()` ตรวจผลลัพธ์

---

## แหล่งอ้างอิง

- [pandas: Indexing and selecting data](https://pandas.pydata.org/docs/user_guide/indexing.html)
