---
title: "Data Types & Conversion"
description: "การตรวจและแปลงชนิดข้อมูล รวมถึงชนิดที่รองรับค่าว่าง"
tags:
  - python
  - pandas
---

# Data Types & Conversion

ข้อมูลที่ดูเหมือนตัวเลขอาจยังเป็นข้อความ จึงต้องตรวจ dtype ก่อนคำนวณ
บทนี้ต่อจาก [ReadingData](ReadingData.md) และ [MissingData](MissingData.md)

## 1. ตรวจชนิดข้อมูล

```python
import pandas as pd

raw = pd.DataFrame({
    "product_id": ["001", "002", "003"],
    "price": ["150", "20", "unknown"],
    "stock": ["10", None, "5"],
    "category": ["Stationery", "Stationery", "Accessories"]
})
print(raw.dtypes)
raw.info()
```

dtype ของข้อความที่ pandas อนุมานอาจต่างกันตามเวอร์ชัน
ใช้ชนิดที่ระบุชัดเจนเมื่อต้องการพฤติกรรมแน่นอน

## 2. แปลงตัวเลขด้วย to_numeric

```python
products = raw.copy()
products["price"] = pd.to_numeric(products["price"], errors="coerce")
products["stock"] = pd.to_numeric(products["stock"], errors="coerce").astype("Int64")
print(products)
print(products.dtypes)
```

errors="coerce" ทำให้ข้อความที่แปลงไม่ได้กลายเป็นค่าว่าง
errors="raise" เป็นค่าเริ่มต้นและจะเกิดข้อผิดพลาดเมื่อแปลงไม่ได้
ตรวจค่าที่เสียหายก่อนแทนค่า เพื่อไม่ให้ปัญหาในข้อมูลหายไปโดยไม่ทราบสาเหตุ:

```python
invalid_prices = raw.loc[raw["price"].notna() & products["price"].isna()]
print(invalid_prices) # แถว product_id 003
```

## 3. astype และ nullable types

```python
products["product_id"] = products["product_id"].astype("string")
products["category"] = products["category"].astype("category")
print(products.select_dtypes(include="number"))
```

| dtype    | เหมาะกับ                             |
| -------- | ------------------------------------ |
| string   | ข้อความและรหัสที่ต้องเก็บศูนย์นำหน้า |
| Int64    | จำนวนเต็มที่รองรับ pd.NA             |
| Float64  | ทศนิยมที่รองรับ pd.NA                |
| boolean  | True/False ที่รองรับ pd.NA           |
| category | ชุดค่าที่มีหมวดซ้ำกัน                |

astype ไม่ได้ตรวจความหมายของข้อมูลให้เรา
เช่น การแปลงข้อความ "False" ด้วย astype(bool) ไม่ใช่วิธีอ่านค่าบูลีนที่ถูกต้อง
ใช้ map กำหนดความหมายแทน:

```python
flags = pd.Series(["yes", "no", None], dtype="string")
active = flags.map({"yes": True, "no": False}).astype("boolean")
print(active)
```

## 4. convert_dtypes

```python
converted = products.convert_dtypes()
print(converted.dtypes)
```

ช่วยเลือกชนิดที่รองรับค่าว่าง แต่ไม่ใช่ตัวแปลงข้อความตัวเลขโดยอัตโนมัติ
ต้องใช้ to_numeric ก่อนหากค่าต้นทางยังเป็นข้อความ

---

## แบบฝึกหัด

1. แปลง price เป็นตัวเลข แล้วนับค่าที่แปลงไม่ได้

```python
invalid = raw["price"].notna() & products["price"].isna()
print(invalid.sum())
```

2. แปลง stock เป็น Int64 และตรวจว่าค่าว่างยังอยู่

```python
products["stock"] = pd.to_numeric(
    products["stock"], errors="coerce"
).astype("Int64")

print(products["stock"].dtype)        # Int64
print(products["stock"].isna().sum()) # 1
```

3. เก็บ product_id เป็น string และตรวจว่า 001 ยังมีศูนย์นำหน้า

```python
products["product_id"] = products["product_id"].astype("string")

print(products["product_id"].iloc[0])
# 001
```

4. แปลง Series `["Y", "N", None]` เป็น boolean ด้วย map

```python
flags = pd.Series(["Y", "N", None], dtype="string")
active = flags.map({"Y": True, "N": False}).astype("boolean")

print(active)
```

---

## แหล่งอ้างอิง

- [pandas: Data types](https://pandas.pydata.org/docs/user_guide/basics.html#dtypes)
- [pandas: to_numeric](https://pandas.pydata.org/docs/reference/api/pandas.to_numeric.html)
