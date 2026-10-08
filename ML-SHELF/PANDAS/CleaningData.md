---
title: "Cleaning Data"
description: "ขั้นตอนทำความสะอาดข้อมูลพร้อมตรวจสอบและบันทึกผล"
tags:
  - python
  - pandas
---

# Cleaning Data

การทำความสะอาดข้อมูลคือการตรวจปัญหาและปรับข้อมูลให้ตรงกฎของงาน
เช่น ชื่อไม่สม่ำเสมอ ตัวเลขที่เป็นข้อความ ค่าว่าง แถวซ้ำ และค่าที่เป็นไปไม่ได้
บทนี้นำ [DataTypes](DataTypes.md), [MissingData](MissingData.md),
[ReplaceAndRenaming](ReplaceAndRenaming.md) และ [DuplicatesAndSorting](DuplicatesAndSorting.md)
มาต่อกันเป็นตัวอย่างเดียว รันโค้ดตามลำดับจากหัวข้อ 1

## 1. เตรียมข้อมูลและกำหนดกฎ

```python
import pandas as pd

raw_products = pd.DataFrame({
    " Product ID ": ["001", "002", "003", "001", "004", "005", "006"],
    " Name ": [" Book ", "PEN", "Bag", "book", "Pencil", "Pouch", "Eraser"],
    " Category ": [" Stationery ", "stationary", "Accessories", "stationery",
                   " ", "Accessories", "Stationery"],
    " Price ": ["150", "20", "unknown", "150", "-10", "120", "5"],
    " Stock ": ["10", None, "5", "10", "30", "2.5", "8"],
    " Updated At ": ["2026-01-01", "2026-01-02", "invalid", "2026-01-01",
                     "2026-01-03", "2026-01-04", "2026-01-05"]
})

print(raw_products.shape)
raw_products.info()
print(raw_products.isna().sum())
```

สำหรับตารางสินค้าร้านเดียวในตัวอย่างนี้ กำหนดว่า:

- product_id และ name ต้องมีค่า และ product_id ต้องไม่ซ้ำในผลลัพธ์
- price ต้องเป็นตัวเลขตั้งแต่ 0 ขึ้นไป
- stock ต้องเป็นจำนวนเต็มตั้งแต่ 0 ขึ้นไป หากยังไม่ทราบให้เก็บค่าว่าง
- category ต้องเป็น stationery หรือ accessories หากยังไม่ทราบให้เก็บค่าว่าง
- updated_at ต้องเป็นวันที่ที่อ่านได้

ข้อมูลต้นฉบับมี 7 แถว การตรวจ isna อย่างเดียวไม่พบข้อความ unknown
หรือข้อความที่มีแต่ช่องว่าง จึงต้องจัดรูปแบบและแปลงข้อมูลก่อนตรวจซ้ำ

## 2. จัดชื่อคอลัมน์และข้อความ

```python
products = raw_products.copy()
columns = products.columns.str.strip().str.lower().str.replace(r"\s+", "_", regex=True)
if columns.duplicated().any():
    raise ValueError("ชื่อคอลัมน์ซ้ำหลัง normalize")
products.columns = columns

for column in ["product_id", "name", "category"]:
    products[column] = products[column].astype("string").str.strip().replace("", pd.NA)

for column in ["name", "category"]:
    products[column] = products[column].str.lower().str.replace(r"\s+", " ", regex=True)

products["category"] = products["category"].replace({"stationary": "stationery"})
```

product_id เก็บเป็นข้อความเพื่อรักษา 001
ชื่อสินค้าและหมวดใช้ตัวพิมพ์เล็กตามกฎของตัวอย่างนี้
เก็บ raw_products ไว้เปรียบเทียบกับค่าที่แปลงแล้ว

## 3. แปลงตัวเลขและวันที่ พร้อมตรวจค่าที่แปลงไม่ได้

```python
price_text = products["price"].astype("string").str.strip().replace("", pd.NA)
stock_text = products["stock"].astype("string").str.strip().replace("", pd.NA)
date_text = products["updated_at"].astype("string").str.strip().replace("", pd.NA)

products["price"] = pd.to_numeric(price_text, errors="coerce").astype("Float64")
products["stock"] = pd.to_numeric(stock_text, errors="coerce").astype("Float64")
products["updated_at"] = pd.to_datetime(date_text, format="%Y-%m-%d", errors="coerce")

invalid_price_text = price_text.notna() & products["price"].isna()
invalid_stock_text = stock_text.notna() & products["stock"].isna()
invalid_date_text = date_text.notna() & products["updated_at"].isna()

print(products.loc[invalid_price_text, ["product_id", "price"]])
print(products.loc[invalid_date_text, ["product_id", "updated_at"]])
```

สินค้า 003 มีราคาที่แปลงไม่ได้และวันที่เสีย
errors="coerce" ทำให้ตรวจและแยกรายการได้ แต่ไม่ได้แก้ค่าที่ถูกต้องให้เอง
stock ยังใช้ Float64 ชั่วคราว เพื่อจับค่าทศนิยมก่อนแปลงเป็น Int64

## 4. ตรวจค่าตามกฎและเก็บเหตุผล

```python
issues = pd.DataFrame(index=products.index)
issues["missing_id"] = products["product_id"].isna()
issues["missing_name"] = products["name"].isna()
issues["missing_or_invalid_price"] = products["price"].isna()
issues["negative_price"] = products["price"].lt(0).fillna(False)
issues["negative_stock"] = products["stock"].lt(0).fillna(False)
issues["fractional_stock"] = products["stock"].mod(1).ne(0).fillna(False)
issues["invalid_stock_text"] = invalid_stock_text
issues["unknown_category"] = (
    products["category"].notna()
    & ~products["category"].isin(["stationery", "accessories"])
)
issues["missing_or_invalid_date"] = products["updated_at"].isna()

has_issue = issues.any(axis=1)
rejected_products = products.loc[has_issue].copy()
rejection_reasons = issues.loc[has_issue].copy()
accepted_products = products.loc[~has_issue].copy()

print(rejected_products)
print(rejection_reasons)
```

แยกสินค้า 003, 004 และ 005 ไว้ตรวจแก้ โดยไม่ลบทิ้งจากต้นฉบับ
สินค้า 004 มีราคาติดลบ ส่วน 005 มี stock เป็น 2.5 ซึ่งไม่ตรงกฎจำนวนชิ้น
stock ที่ว่างของ Pen ไม่ถูกปฏิเสธ เพราะกฎอนุญาตค่าว่าง
category ที่ว่างก็ได้รับอนุญาต แต่ข้อความหมวดอื่นที่ไม่รู้จักต้องตรวจเพิ่ม

ค่าสูงผิดปกติไม่จำเป็นต้องผิด เช่น กระเป๋าราคาแพงอาจเป็นราคาจริง
ใช้กฎหรือข้อมูลอ้างอิงของงานเพื่อตัดสิน ไม่ลบ outlier เพียงเพราะต่างจากรายการอื่น

## 5. ลบแถวซ้ำและตรวจ key ที่ขัดแย้ง

```python
# เก็บแถวซ้ำไว้ดูย้อนหลัง แล้วลบเฉพาะรายการที่เหมือนกันทุกคอลัมน์
duplicate_rows = accepted_products.loc[accepted_products.duplicated()].copy()
deduplicated = accepted_products.drop_duplicates().copy()

# key ซ้ำแต่รายละเอียดต่างกัน ต้องตัดสินจากกฎของงานก่อนรวม
conflicting_keys = deduplicated.loc[
    deduplicated.duplicated(subset=["product_id"], keep=False)
]
if not conflicting_keys.empty:
    raise ValueError("พบ product_id ซ้ำที่รายละเอียดต่างกัน ต้องตรวจแก้ก่อน")

clean_products = deduplicated.reset_index(drop=True)
clean_products["stock"] = clean_products["stock"].astype("Int64")
```

Book ที่เดิมเขียนต่างรูปแบบกลายเป็นแถวเหมือนกันหลัง normalize
จึงเก็บไว้หนึ่งแถว หากสินค้าเดียวกันมีหลายร้าน ต้องใช้ key เช่น product_id และ store
แทนการใช้ product_id เพียงอย่างเดียว

## 6. ตรวจผลลัพธ์ก่อนนำไปใช้

```python
assert clean_products["product_id"].notna().all()
assert clean_products["product_id"].is_unique
assert clean_products["name"].notna().all()
assert clean_products["price"].notna().all()
assert clean_products["price"].ge(0).all()
assert clean_products["stock"].dropna().ge(0).all()
assert clean_products["updated_at"].notna().all()

print(clean_products[["product_id", "name", "price", "stock"]])
print(clean_products.isna().sum())

report = pd.Series({
    "input_rows": len(raw_products),
    "rejected_rows": len(rejected_products),
    "duplicate_rows_removed": len(duplicate_rows),
    "output_rows": len(clean_products)
})
print(report)
assert len(raw_products) == len(rejected_products) + len(duplicate_rows) + len(clean_products)
```

ผลลัพธ์สะอาดเหลือสินค้า 001 (book), 002 (pen) และ 006 (eraser)
ราคาเป็น 150, 20 และ 5 ส่วน stock เป็น 10, ค่าว่าง และ 8
รายงานจำนวนแถว: รับเข้า 7, แยกตรวจแก้ 3, ลบซ้ำ 1, พร้อมใช้ 3
assert ใช้ตรวจระหว่างฝึก หากทำระบบจริงให้ใช้ validation ที่แจ้งข้อผิดพลาดชัดเจน

ไม่เติม stock ที่ไม่ทราบเป็น 0 หรือราคาเสียด้วยค่าเฉลี่ยในตัวอย่างนี้
เพราะยังไม่มีข้อมูลยืนยันค่าจริง

## 7. บันทึกผลและรายการที่ต้องแก้

```python
clean_products.to_csv("clean_products_example.csv", index=False, encoding="utf-8-sig")

# เก็บ source row เพื่อจับคู่กับข้อมูลต้นทาง
audit = rejected_products.join(rejection_reasons.add_prefix("issue_"))
audit.to_csv("rejected_products_example.csv", index=True, index_label="source_row")
```

ไฟล์ถูกบันทึกในโฟลเดอร์ที่รัน Python และเขียนทับไฟล์ชื่อเดียวกัน
อ่านผลกลับโดยกำหนด product_id เป็น string เพื่อเก็บศูนย์นำหน้า
source_row ในตัวอย่างอ้างอิง index เดิมของ raw_products

## แบบฝึกหัด

1. ตรวจ raw_products แล้วบอกว่าปัญหาใดที่ isna อย่างเดียวตรวจไม่พบ

```python

```

2. Normalize ชื่อคอลัมน์ ชื่อสินค้า และหมวด โดยรักษา product_id เป็นข้อความ

```python

```

3. แปลงราคา สต็อก และวันที่ พร้อมเลือกแถวที่แปลงไม่ได้

```python

```

4. ตรวจราคาติดลบและ stock ที่เป็นทศนิยม แล้วแยกไว้พร้อมเหตุผล

```python

```

5. ลบแถวที่เหมือนกันทุกคอลัมน์ และตรวจว่า key ที่เหลือไม่ซ้ำ

```python

```

6. สรุปจำนวนแถวรับเข้า แยกตรวจแก้ ลบซ้ำ และพร้อมใช้

```python

```

7. เพิ่มสินค้าใหม่ที่ category เป็น Toys แล้วตรวจว่ากฎแยกรายการนี้ได้

```python

```


## แหล่งอ้างอิง

- [pandas: Working with missing data](https://pandas.pydata.org/docs/user_guide/missing_data.html)
- [pandas: Working with text data](https://pandas.pydata.org/docs/user_guide/text.html)
- [pandas: to_numeric](https://pandas.pydata.org/docs/reference/api/pandas.to_numeric.html)
- [pandas: DataFrame.drop_duplicates](https://pandas.pydata.org/docs/reference/api/pandas.DataFrame.drop_duplicates.html)
