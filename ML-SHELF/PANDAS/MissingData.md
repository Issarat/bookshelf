---
title: "Working with missing data"
description: "การตรวจสอบ ลบ และเติมข้อมูลที่ขาดหาย"
tags:
  - python
  - pandas
---

# Working with missing data

ข้อมูลจริงอาจมีค่าที่ไม่ได้บันทึก เช่น ราคาสินค้าที่ยังไม่ทราบ
หรือจำนวนสต็อกที่ยังไม่ได้ตรวจนับ เราเรียกข้อมูลเหล่านี้ว่าค่าว่าง
(missing data)

บทนี้ต่อจาก [Indexing](Indexing.md) โดยฝึกตรวจสอบ ลบ และเติมค่าว่าง
ตัวอย่างแต่ละวิธีสร้างผลลัพธ์ใหม่ จึงรันตามลำดับได้โดยไม่แก้ข้อมูลต้นฉบับ

## 1. เตรียมข้อมูล

```python
import pandas as pd

products = pd.DataFrame({
    "name": ["Book", "Pen", "Bag", "Pencil"],
    "price": [150, 20, None, 10],
    "stock": [10, None, 5, 30]
})

print(products)
```

ผลลัพธ์:

```text
     name  price  stock
0    Book  150.0   10.0
1     Pen   20.0    NaN
2     Bag    NaN    5.0
3  Pencil   10.0   30.0
```

ในตัวอย่างนี้ pandas แปลง `None` ในคอลัมน์ตัวเลขเป็น `NaN`
และใช้ชนิด `float64` ทำให้จำนวนเต็มแสดงพร้อมจุดทศนิยม
ไม่ต้อง import NumPy สำหรับตัวอย่างในบทนี้

## 2. รูปแบบของค่าว่าง

| ค่า | ความหมายและการใช้งาน |
| --- | --- |
| `None` | ค่าของ Python ที่ pandas ตรวจพบว่าเป็นค่าว่าง |
| `NaN` | ค่าว่างที่พบได้ในคอลัมน์ตัวเลขชนิด float |
| `pd.NA` | ค่าว่างสำหรับชนิดข้อมูลที่รองรับ เช่น `Int64` และ `boolean` |
| `pd.NaT` | ค่าว่างสำหรับข้อมูลวันเวลา |

ตัวแทนค่าว่างขึ้นอยู่กับ dtype ของข้อมูล
หากต้องการเก็บจำนวนเต็มที่มีค่าว่าง สามารถกำหนด `Int64` ได้:

```python
stock = pd.Series([10, None, 5, 30], dtype="Int64")
print(stock)
```

ผลลัพธ์:

```text
0      10
1    <NA>
2       5
3      30
dtype: Int64
```

`Int64` ที่ขึ้นต้นด้วย I ตัวใหญ่รองรับค่าว่าง
ต่างจาก `int64` ที่ไม่รองรับค่าว่างโดยตรง

## 3. ตรวจสอบค่าว่าง

### isna(): ตรวจว่าค่าไหนว่าง

```python
print(products.isna())
```

ผลลัพธ์:

```text
    name  price  stock
0  False  False  False
1  False  False   True
2  False   True  False
3  False  False  False
```

`True` หมายถึงค่าว่าง ส่วน `False` หมายถึงมีข้อมูล
ใช้ `isna()` แทนการเปรียบเทียบกับ `None`, `NaN` หรือ `pd.NA` ด้วย `==`

### notna(): ตรวจว่าค่าไหนมีข้อมูล

```python
print(products["price"].notna())
```

### นับค่าว่างแต่ละคอลัมน์

```python
print(products.isna().sum())
```

ผลลัพธ์:

```text
name     0
price    1
stock    1
dtype: int64
```

`sum()` นับค่า True เป็น 1 และ False เป็น 0

## 4. เลือกแถวที่มีค่าว่าง

เลือกสินค้าที่ยังไม่มีราคา:

```python
print(products.loc[products["price"].isna()])
# ได้แถว Bag
```

เลือกสินค้าที่มีราคา:

```python
print(products.loc[products["price"].notna()])
# ได้ Book, Pen และ Pencil
```

เลือกแถวที่มีค่าว่างอย่างน้อยหนึ่งคอลัมน์:

```python
print(products.loc[products.isna().any(axis=1)])
# ได้ Pen และ Bag
```

`any(axis=1)` ตรวจแต่ละแถวว่ามีค่า True อย่างน้อยหนึ่งตำแหน่งหรือไม่

## 5. ลบข้อมูลที่มีค่าว่าง: dropna

### ลบแถวที่มีค่าว่างอย่างน้อยหนึ่งค่า

```python
complete_products = products.dropna()
print(complete_products)
```

เหลือ Book และ Pencil ส่วน index เดิมยังคงเป็น 0 และ 3

### ลบเฉพาะแถวที่ไม่มีราคา

```python
priced_products = products.dropna(subset=["price"])
print(priced_products)
```

เหลือ Book, Pen และ Pencil แม้ Pen จะยังมีค่าว่างใน stock

### ลบคอลัมน์ที่มีค่าว่าง

```python
complete_columns = products.dropna(axis=1)
print(complete_columns)
```

เหลือเฉพาะคอลัมน์ name เพราะ price และ stock มีค่าว่าง

`dropna()` ใช้ `how="any"` เป็นค่าเริ่มต้น
หากต้องการลบเฉพาะแถวที่ว่างทุกคอลัมน์ ให้ใช้ `how="all"`

## 6. เติมค่าว่าง: fillna

### เติมค่าที่กำหนดลงในคอลัมน์เดียว

```python
filled_stock = products.copy()
filled_stock["stock"] = filled_stock["stock"].fillna(0)
print(filled_stock)
```

สต็อกของ Pen เปลี่ยนเป็น 0 ส่วนราคาของ Bag ยังว่าง
ตัวอย่างนี้ใช้ฝึกคำสั่ง การเติม 0 เหมาะเมื่อรู้ว่าค่าว่างหมายถึงไม่มีสินค้า
หากยังไม่ทราบจำนวนจริง ควรเก็บเป็นค่าว่างไว้

### กำหนดค่าเติมแยกตามคอลัมน์

```python
filled_products = products.fillna({
    "price": products["price"].mean(),
    "stock": 0
})

print(filled_products)
```

ราคาเฉลี่ยจากข้อมูลที่มีอยู่คือ `(150 + 20 + 10) / 3 = 60`
จึงเติมราคา Bag เป็น 60 และสต็อก Pen เป็น 0
นี่เป็นตัวอย่างการแทนค่า ไม่ได้ยืนยันว่าราคาและสต็อกจริงเป็นเท่านี้

หากต้องการเก็บผลลัพธ์ในตัวแปรเดิม ให้กำหนดค่ากลับ เช่น
`products = products.fillna({"stock": 0})`
หลีกเลี่ยง `products["stock"].fillna(0, inplace=True)`
ให้กำหนดผลกลับไปที่คอลัมน์โดยตรงเหมือนตัวอย่างด้านบน

## 7. ค่าว่างกับการคำนวณ

`mean()` ข้ามค่าว่างโดยค่าเริ่มต้น:

```python
print(products["price"].mean())             # 60.0
print(products["price"].mean(skipna=False)) # NaN
```

การคูณค่าที่ว่างจะทำให้ผลลัพธ์ในตำแหน่งนั้นว่างด้วย:

```python
valued_products = products.copy()
valued_products["total_value"] = (
    valued_products["price"] * valued_products["stock"]
)

print(valued_products)
```

Book มีมูลค่า 1500 และ Pencil มีมูลค่า 300
ส่วน Pen และ Bag ยังหามูลค่าไม่ได้เพราะข้อมูลไม่ครบ

## 8. เลือกวิธีจัดการอย่างไร?

- เก็บค่าว่างไว้ เมื่อข้อมูลยังไม่ทราบและยังไม่จำเป็นต้องแทนค่า
- ใช้ `dropna(subset=[...])` เมื่อจำเป็นต้องมีข้อมูลในคอลัมน์นั้นเพื่อทำงานต่อ
- ใช้ `fillna()` เมื่อมีเหตุผลรองรับค่าที่นำมาแทน

ค่าว่างไม่เท่ากับ 0 และข้อความว่าง `""` ไม่ถูกนับเป็นค่าว่างโดย `isna()` ตามปกติ
ควรตรวจความหมายของข้อมูลก่อนเลือกวิธีจัดการ

---

## แบบฝึกหัด

ใช้ `products` จากหัวข้อ 1 ที่ยังไม่ได้เติมหรือลบค่าว่าง แล้วลอง:

1. นับค่าว่างของแต่ละคอลัมน์

```python
print(products.isna().sum())
```

2. เลือกแถวที่ stock เป็นค่าว่างด้วย `loc`

```python
print(products.loc[products["stock"].isna()])
```

3. เลือกเฉพาะชื่อสินค้าที่มีราคา ด้วย `notna()` และ `loc`

```python
print(products.loc[products["price"].notna(), ["name"]])
```

4. ลบเฉพาะแถวที่ไม่มีราคา แล้วเก็บใน `priced_products`

```python
priced_products = products.dropna(subset=["price"])
print(priced_products)
```

5. สร้างสำเนาชื่อ `filled_products` แล้วเติม stock ที่ว่างด้วย 0 โดยไม่เปลี่ยน price

```python
filled_products = products.copy()
filled_products["stock"] = filled_products["stock"].fillna(0)
print(filled_products)
```

6. คำนวณราคาเฉลี่ยจากข้อมูลต้นฉบับ แล้วเติมราคาที่ว่างในสำเนาชื่อ `estimated_products`

```python
estimated_products = products.fillna({
    "price": products["price"].mean()
})

print(estimated_products)
```

7. ตรวจจำนวนค่าว่างใน `estimated_products` อีกครั้ง: คอลัมน์ใดยังมีค่าว่าง?

```python
print(estimated_products.isna().sum())
```

ลองเขียนคำตอบเอง แล้วใช้ `print()` ตรวจผลลัพธ์

---

## แหล่งอ้างอิง

- [pandas: Working with missing data](https://pandas.pydata.org/docs/user_guide/missing_data.html)
