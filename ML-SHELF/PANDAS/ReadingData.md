---
title: "Reading & Writing Data"
description: "การอ่านและบันทึกข้อมูล CSV Excel และ JSON"
tags:
  - python
  - pandas
---

# Reading & Writing Data

ก่อนวิเคราะห์ข้อมูล ต้องอ่านไฟล์ให้ได้ชนิดข้อมูลและค่าว่างที่ถูกต้อง
บทนี้ต่อยอดตัวอย่าง CSV ใน [DataFrame](DataFrame.md)

## 1. อ่าน CSV ที่รันได้โดยไม่ต้องเตรียมไฟล์

```python
import pandas as pd
from io import StringIO

csv_text = """product_id,name,price,stock
001,Book,150,10
002,Pen,20,unknown
003,Bag,350,5
"""

products = pd.read_csv(
    StringIO(csv_text),
    dtype={"product_id": "string", "stock": "Int64"},
    na_values=["unknown"]
)

print(products)
products.info()
```

product_id เป็นข้อความเพื่อเก็บเลขศูนย์นำหน้า ส่วน stock ของ Pen เป็นค่าว่าง
StringIO ทำให้ข้อความทำงานเหมือนไฟล์ ใช้ฝึกโดยไม่ต้องมี products.csv

## 2. อ่านจากไฟล์จริง

ตัวอย่างนี้บันทึกไฟล์ชื่อใหม่จากข้อมูลด้านบนก่อน แล้วอ่านกลับ:

```python
from pathlib import Path

output_path = Path("products_io_example.csv")
products.to_csv(output_path, index=False, encoding="utf-8-sig")

loaded = pd.read_csv(
    output_path,
    encoding="utf-8-sig",
    dtype={"product_id": "string", "stock": "Int64"}
)
print(loaded.head())
print(loaded.shape)
print(loaded.isna().sum())
```

path แบบสัมพัทธ์อ้างอิงโฟลเดอร์ที่รัน Python ไม่ใช่ตำแหน่งไฟล์ Markdown
to_csv จะเขียนทับหากมีไฟล์ชื่อเดียวกัน จึงควรเลือกชื่อผลลัพธ์ก่อนรัน
index=False ป้องกันการบันทึก index เป็นคอลัมน์เพิ่มเติม

## 3. ตัวเลือก read_csv ที่ใช้บ่อย

| ตัวเลือก | การใช้งาน |
| --- | --- |
| sep | ตัวคั่น เช่น `sep=";"` |
| usecols | อ่านเฉพาะคอลัมน์ เช่น `["name", "price"]` |
| dtype | กำหนดชนิดข้อมูลของคอลัมน์ |
| na_values | ระบุข้อความที่ต้องตีความเป็นค่าว่าง |
| nrows | อ่านเฉพาะจำนวนแถวที่กำหนด |
| encoding | ระบุการเข้ารหัสข้อความ |

```python
preview = pd.read_csv(StringIO(csv_text), usecols=["name", "price"], nrows=2)
print(preview)
```

usecols ไม่รับประกันลำดับตาม List หากต้องการลำดับเฉพาะ ให้เลือกคอลัมน์ซ้ำหลังอ่าน
หากรหัสจริงเป็น NA แต่ไม่ต้องการให้กลายเป็นค่าว่าง ใช้ keep_default_na=False
ร่วมกับ na_values ที่กำหนดเอง

## 4. Excel และ JSON

สำหรับไฟล์ Excel ที่มีอยู่แล้ว:

```python
# ต้องมีไฟล์ inventory.xlsx และชีต Products ก่อนรัน
# ต้องติดตั้ง engine สำหรับ .xlsx เช่น openpyxl
# excel_products = pd.read_excel("inventory.xlsx", sheet_name="Products")
# excel_products.to_excel("inventory_export.xlsx", index=False)
```

JSON แบบหนึ่ง object ต่อแถวใช้ orient="records":

```python
json_text = products.to_json(orient="records", force_ascii=False)
from_json = pd.read_json(StringIO(json_text), orient="records")
print(from_json)
```

แต่ละรูปแบบอาจตีความ dtype ต่างกัน ตรวจ dtypes หลังอ่านเสมอ
หากรหัสต้องเก็บศูนย์นำหน้า ให้กำหนด dtype ตอนอ่าน JSON ด้วย

---

## แบบฝึกหัด

1. อ่าน csv_text โดยเก็บ product_id เป็น string และ unknown เป็นค่าว่าง

```python
import pandas as pd
from io import StringIO

csv_text = """product_id,name,price,stock
001,Book,150,10
002,Pen,20,unknown
003,Bag,350,5
"""

products = pd.read_csv(
    StringIO(csv_text),
    dtype={"product_id": "string"},
    na_values=["unknown"]
)

print(products)
products.info()
```

2. อ่านเฉพาะ name และ stock โดยกำหนด stock เป็น Int64

```python
preview = pd.read_csv(StringIO(csv_text),
usecols=["name", "stock"],
dtype={"stock": "Int64"},
na_values=["unknown"]
)

print(preview)
```

3. ตรวจจำนวนแถว ชนิดข้อมูล และจำนวนค่าว่าง

```python
print(len(products))
print(products.shape)
print(products.dtypes)
print(products.isna().sum())
```

4. บันทึกผลเป็นไฟล์ชื่อใหม่โดยไม่รวม index แล้วอ่านกลับพร้อมกำหนด dtype

```python
products.to_csv(
    "products_reading_exercise.csv",
    index=False,
    encoding="utf-8-sig"
)

loaded = pd.read_csv(
    "products_reading_exercise.csv",
    encoding="utf-8-sig",
    dtype={
        "product_id": "string",
        "name": "string",
        "price": "Int64",
        "stock": "Int64"
    }
)

print(loaded)
print(loaded.dtypes)
```

---

## แหล่งอ้างอิง

- [pandas: IO tools](https://pandas.pydata.org/docs/user_guide/io.html)
