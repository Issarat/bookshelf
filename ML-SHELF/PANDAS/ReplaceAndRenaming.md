---
title: "Replace & Renaming"
description: "การแทนค่า เปลี่ยนชื่อ และจัดรูปแบบข้อความให้สม่ำเสมอ"
tags:
  - python
  - pandas
---

# Replace & Renaming

`replace()` ใช้แทนค่าภายในข้อมูล ส่วน `rename()` ใช้เปลี่ยนชื่อคอลัมน์
หรือป้ายกำกับ index โดยไม่เปลี่ยนค่าที่เก็บอยู่ในตาราง

บทนี้ต่อจาก [Maps](Maps.md) เพื่อฝึกปรับข้อมูลและชื่อให้ใช้งานสะดวกขึ้น
ตัวอย่างแต่ละหัวข้อใช้ข้อมูลต้นฉบับเดียวกัน และเก็บผลลัพธ์ในตัวแปรใหม่

## 1. เตรียมข้อมูล

```python
import pandas as pd

products = pd.DataFrame({
    "name": ["Book", "Pen", "Bag", "Pencil"],
    "category": ["S", "S", "A", "Unknown"],
    "price": [150, 20, 350, 10],
    "stock": [10, 50, -1, 30]
})

print(products)
```

สมมติว่าระบบต้นทางใช้ -1 แทนสต็อกที่ยังไม่ทราบจำนวน
และใช้ Unknown แทนหมวดสินค้าที่ยังไม่ได้ระบุ

## 2. replace(): แทนค่าหนึ่งค่าด้วยอีกค่า

```python
renamed_values = products["name"].replace("Book", "Notebook")
print(renamed_values.tolist())
# ['Notebook', 'Pen', 'Bag', 'Pencil']
```

คำสั่งนี้เปลี่ยนค่าชื่อสินค้า ไม่ได้เปลี่ยนชื่อคอลัมน์ name
การแทนข้อความแบบปกติจับคู่ทั้งค่า เช่น Book จะไม่จับคู่กับ Bookcase

## 3. แทนหลายค่าด้วย Dictionary

```python
category_map = {
    "S": "Stationery",
    "A": "Accessories"
}

replaced_categories = products["category"].replace(category_map)
print(replaced_categories.tolist())
# ['Stationery', 'Stationery', 'Accessories', 'Unknown']
```

ค่าที่ไม่มีอยู่ใน Dictionary เช่น Unknown จะคงค่าเดิม
ต่างจาก `map()` ด้วย Dictionary ปกติที่เปลี่ยนค่าซึ่งจับคู่ไม่ได้เป็นค่าว่าง:

```python
mapped_categories = products["category"].map(category_map)
print(mapped_categories.isna().tolist())
# [False, False, False, True]
```

## 4. แทนค่าเฉพาะคอลัมน์ใน DataFrame

ใช้ Dictionary ซ้อนกัน โดยชั้นนอกเป็นชื่อคอลัมน์
และชั้นในเป็นคู่ค่าเดิมกับค่าใหม่:

```python
cleaned_products = products.replace({
    "category": {
        "S": "Stationery",
        "A": "Accessories",
        "Unknown": pd.NA
    },
    "stock": {-1: pd.NA}
})

print(cleaned_products)
print(cleaned_products.isna().sum())
```

category และ stock มีค่าว่างอย่างละหนึ่งรายการ
หากต้องการให้ stock เป็นจำนวนเต็มที่รองรับค่าว่าง กำหนด dtype เพิ่ม:

```python
cleaned_products["stock"] = cleaned_products["stock"].astype("Int64")
```

การแทนค่าเป็นค่าว่างเหมาะกับตัวอย่างนี้เพราะเรารู้ความหมายของ -1
อ่านวิธีจัดการค่าว่างต่อได้ใน [MissingData](MissingData.md)

## 5. rename(): เปลี่ยนชื่อคอลัมน์

ใช้ `columns` ระบุคู่ชื่อเดิมกับชื่อใหม่:

```python
renamed_products = products.rename(columns={
    "name": "product_name",
    "price": "unit_price",
    "stock": "quantity"
})

print(renamed_products.columns.tolist())
# ['product_name', 'category', 'unit_price', 'quantity']
```

คอลัมน์ที่ไม่อยู่ใน Dictionary จะคงชื่อเดิม
หลังเปลี่ยนชื่อแล้ว ให้เลือกข้อมูลด้วยชื่อใหม่:

```python
print(renamed_products["unit_price"])
```

### ตรวจจับชื่อที่ไม่มีอยู่

ค่าเริ่มต้นของ rename จะข้ามชื่อที่หาไม่พบ
ใช้ `errors="raise"` หากต้องการให้แจ้งข้อผิดพลาดเมื่อชื่อเดิมไม่ถูกต้อง:

```python
checked_products = products.rename(
    columns={"price": "unit_price"},
    errors="raise"
)
```

ถ้าเขียนชื่อเดิมเป็น prcie แทน price คำสั่งนี้จะเกิด KeyError

## 6. เปลี่ยนป้ายกำกับ index

กำหนดชื่อสินค้าเป็น index แล้วเปลี่ยนป้ายกำกับ Book เป็น Notebook:

```python
by_name = products.set_index("name")
renamed_index = by_name.rename(index={"Book": "Notebook"})

print(renamed_index.index.tolist())
# ['Notebook', 'Pen', 'Bag', 'Pencil']
```

เมื่อ name เป็น index แล้ว จะไม่ใช่คอลัมน์ปกติใน by_name

### เปลี่ยนชื่อของแกนด้วย rename_axis()

ชื่อแกน index เป็นคนละส่วนกับป้ายกำกับแต่ละแถว:

```python
named_axis = by_name.rename_axis("product_name")

print(named_axis.index.name)     # product_name
print(named_axis.index.tolist()) # ['Book', 'Pen', 'Bag', 'Pencil']
```

`rename_axis()` เปลี่ยนชื่อแกน ส่วน `rename(index=...)` เปลี่ยนป้ายกำกับในแกน

## 7. เปลี่ยนชื่อด้วยฟังก์ชัน

ส่งฟังก์ชันเพื่อแปลงชื่อคอลัมน์ทุกชื่อ:

```python
upper_columns = products.rename(columns=str.upper)
print(upper_columns.columns.tolist())
# ['NAME', 'CATEGORY', 'PRICE', 'STOCK']
```

ตัวอย่างนี้ใช้ได้เพราะชื่อคอลัมน์ทั้งหมดเป็นข้อความ
สำหรับชื่อที่มีช่องว่าง สามารถใช้ lambda จัดรูปแบบได้:

```python
raw = pd.DataFrame({"Product Name": ["Book"], "Unit Price": [150]})
tidy = raw.rename(columns=lambda column: column.lower().replace(" ", "_"))

print(tidy.columns.tolist())
# ['product_name', 'unit_price']
```

`replace()` ภายใน lambda นี้เป็นเมธอดของข้อความ Python
ที่แทนช่องว่าง ไม่ใช่ `DataFrame.replace()`

## 8. เก็บผลลัพธ์กลับในตัวแปร

replace และ rename คืนผลลัพธ์ใหม่ตามค่าเริ่มต้น
หากต้องการใช้งานข้อมูลที่เปลี่ยนแล้ว ต้องเก็บผลลัพธ์:

```python
working_products = products.copy()
working_products["category"] = working_products["category"].replace(category_map)
working_products = working_products.rename(columns={"price": "unit_price"})
```

## 9. Normalize column names: จัดรูปแบบชื่อคอลัมน์

Normalize ในหัวข้อนี้หมายถึงการจัดรูปแบบข้อความให้สม่ำเสมอ
เช่น ใช้ตัวพิมพ์เล็กและเชื่อมคำด้วย underscore เพื่อเลือกคอลัมน์ได้ง่าย

### เตรียมข้อมูลที่มีรูปแบบไม่สม่ำเสมอ

```python
raw_products = pd.DataFrame({
    " Product   Name ": ["  BOOK ", "Pen", " BAG", None],
    " CATEGORY ": [" stationery ", "STATIONARY", " accessories", "  "],
    " Unit Price ": [150, 20, 350, 10],
    " Stock ": [10, 50, 5, 30]
})

normalized_products = raw_products.copy()
```

### ลบช่องว่างหัวท้าย เปลี่ยนตัวพิมพ์ และรวมช่องว่างระหว่างคำ

ตัวอย่างนี้ชื่อคอลัมน์ทั้งหมดเป็นข้อความ:

```python
normalized_columns = (
    normalized_products.columns
    .str.strip()
    .str.lower()
    .str.replace(r"\s+", "_", regex=True)
)

# ตรวจชื่อที่อาจซ้ำกันหลังจัดรูปแบบ ก่อนกำหนดกลับ
if normalized_columns.duplicated().any():
    raise ValueError("ชื่อคอลัมน์ซ้ำกันหลัง normalize")

normalized_products.columns = normalized_columns
print(normalized_products.columns.tolist())
# ['product_name', 'category', 'unit_price', 'stock']
```

- `str.strip()` ลบ whitespace ที่หัวและท้ายข้อความ
- `str.lower()` เปลี่ยนเป็นตัวพิมพ์เล็ก
- `str.replace(r"\s+", "_", regex=True)` แทน whitespace ต่อเนื่องด้วย underscore หนึ่งตัว

`\s` จับ whitespace เช่น ช่องว่างและแท็บ ส่วน `+` หมายถึงหนึ่งตัวขึ้นไป
การตรวจชื่อซ้ำช่วยจับกรณีที่ชื่อเดิม เช่น Price และ PRICE กลายเป็น price เหมือนกัน
หากเกิดกรณีนี้ ให้กำหนดชื่อที่แตกต่างกันตามความหมายก่อนใช้งานต่อ

## 10. Normalize data: จัดรูปแบบข้อมูลข้อความ

ใช้ normalized_products จากหัวข้อ 9 เพื่อจัดชื่อสินค้าและหมวดสินค้า
โดยเลือกเฉพาะคอลัมน์ข้อความ ไม่แปลงราคาและสต็อกเป็นข้อความ

### จัดรูปแบบหลายคอลัมน์

```python
text_columns = ["product_name", "category"]

for column in text_columns:
    normalized_products[column] = (
        normalized_products[column]
        .astype("string")
        .str.strip()
        .str.lower()
        .str.replace(r"\s+", " ", regex=True)
        .replace("", pd.NA)
    )
```

ในข้อมูลเราใช้ช่องว่างหนึ่งตัวระหว่างคำ ส่วนชื่อคอลัมน์ใช้ underscore
`astype("string")` เก็บค่าว่างเป็น `<NA>` และเมธอด `.str` จะข้ามค่าว่าง
ข้อความที่เหลือว่างหลัง strip ถูกแทนด้วย `pd.NA` เพื่อให้ `isna()` ตรวจพบ

### รวมชื่อที่มีความหมายเดียวกัน

การเปลี่ยนตัวพิมพ์ไม่แก้คำสะกดผิดโดยอัตโนมัติ
ใช้ replace เพิ่มเมื่อทราบว่าค่าใดควรเป็นชื่อเดียวกัน:

```python
normalized_products["category"] = normalized_products["category"].replace({
    "stationary": "stationery"
})

print(normalized_products)
```

ผลลัพธ์:

```text
  product_name     category  unit_price  stock
0         book   stationery         150     10
1          pen   stationery          20     50
2          bag  accessories         350      5
3         <NA>         <NA>          10     30
```

ตรวจข้อมูลหลังจัดรูปแบบ:

```python
print(normalized_products["category"].value_counts(dropna=False))
print(normalized_products.isna().sum())
print(normalized_products.dtypes)
```

category มี stationery 2 รายการ, accessories 1 รายการ และค่าว่าง 1 รายการ
product_name และ category มีค่าว่างอย่างละหนึ่งค่า
ส่วน unit_price และ stock ยังเป็นข้อมูลตัวเลข

เลือกกฎ normalize ตามความหมายของข้อมูล เช่น รหัสที่แยกตัวพิมพ์ใหญ่กับเล็ก
ไม่ควรเปลี่ยนเป็นตัวพิมพ์เล็กทั้งหมด

## สรุปการเลือกคำสั่ง

| สิ่งที่ต้องการเปลี่ยน | คำสั่ง |
| --- | --- |
| ค่าในข้อมูล | `replace()` |
| ค่าแต่ละรายการตาม Dictionary หรือฟังก์ชัน | `Series.map()` |
| ชื่อคอลัมน์ | `rename(columns=...)` |
| ป้ายกำกับ index | `rename(index=...)` |
| ชื่อแกน index | `rename_axis()` |
| รูปแบบชื่อคอลัมน์ | `columns.str.strip()` และเมธอด `.str` อื่น ๆ |
| รูปแบบข้อมูลข้อความ | `Series.str.strip()`, `.str.lower()`, `.str.replace()` |

---

## แบบฝึกหัด

ใช้ products ต้นฉบับจากหัวข้อ 1 และเก็บผลแต่ละข้อในตัวแปรใหม่:

1. ใช้ replace แทนค่า Pen เป็น Ballpoint Pen ในคอลัมน์ name

```python

```

2. ใช้ Dictionary แทน S เป็น Stationery และ A เป็น Accessories โดยเก็บ Unknown ไว้

```python

```

3. สร้าง cleaned_products โดยแทน -1 ใน stock เป็น pd.NA แล้วแปลง stock เป็น Int64

```python

```

4. สร้าง renamed_products โดยเปลี่ยนชื่อ name เป็น product_name และ price เป็น unit_price

```python

```

5. ตั้ง name เป็น index แล้วใช้ rename เปลี่ยนป้ายกำกับ Bag เป็น Backpack

```python

```

6. ใช้ rename_axis เปลี่ยนชื่อแกน index จาก name เป็น product_name โดยคงป้ายกำกับเดิม

```python

```

7. ใช้ฟังก์ชันกับ rename เปลี่ยนชื่อคอลัมน์ทั้งหมดเป็นตัวพิมพ์ใหญ่

```python

```


ลองเขียนคำตอบเอง แล้วใช้ print ตรวจผลลัพธ์

### แบบฝึกเพิ่มเติม: Normalize

ใช้ raw_products จากหัวข้อ 9 แล้วสร้างสำเนาใหม่ชื่อ tidy_products:

8. จัดชื่อคอลัมน์เป็นตัวพิมพ์เล็ก ลบช่องว่างหัวท้าย และแทนช่องว่างระหว่างคำด้วย underscore โดยตรวจว่าชื่อไม่ซ้ำกัน

```python

```

9. จัด product_name ให้เป็นตัวพิมพ์เล็ก ลบช่องว่างหัวท้าย และรวมช่องว่างระหว่างคำให้เหลือหนึ่งตัว โดยเก็บค่าว่างไว้

```python

```

10. จัด category ด้วยกฎเดียวกับข้อ 9 แล้วแทนข้อความว่างด้วย pd.NA

```python

```

11. แทน stationary เป็น stationery แล้วนับความถี่ของ category โดยรวมค่าว่างด้วย

```python

```

12. ตรวจว่า unit_price และ stock ยังเป็นชนิดตัวเลข และนับค่าว่างของแต่ละคอลัมน์

```python

```


## แหล่งอ้างอิง

- [pandas: DataFrame.replace](https://pandas.pydata.org/docs/reference/api/pandas.DataFrame.replace.html)
- [pandas: DataFrame.rename](https://pandas.pydata.org/docs/reference/api/pandas.DataFrame.rename.html)
- [pandas: DataFrame.rename_axis](https://pandas.pydata.org/docs/reference/api/pandas.DataFrame.rename_axis.html)
- [pandas: Working with text data](https://pandas.pydata.org/docs/user_guide/text.html)
