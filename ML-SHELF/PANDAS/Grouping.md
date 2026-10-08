---
title: "Group by: split-apply-combine"
description: "การแบ่งกลุ่มและสรุปข้อมูลด้วย groupby และ agg"
tags:
  - python
  - pandas
---

# Group by: split-apply-combine

Grouping คือการแบ่งข้อมูลเป็นกลุ่ม แล้วคำนวณหรือสรุปข้อมูลแต่ละกลุ่ม
เช่น ราคาเฉลี่ยของสินค้าแต่ละหมวด หรือสต็อกรวมของแต่ละร้าน

บทนี้ต่อจาก [MissingData](MissingData.md) โดยเพิ่มหมวดสินค้าและร้าน
เพื่อฝึกใช้ `groupby()` และ `agg()`

## 1. เตรียมข้อมูล

แต่ละแถวเป็นสินค้าหนึ่งรายการในร้านหนึ่งร้าน
สินค้าเดียวกันจึงปรากฏได้หลายแถวเมื่ออยู่คนละร้าน

```python
import pandas as pd

products = pd.DataFrame({
    "name": ["Book", "Pen", "Bag", "Pencil", "Book", "Bag"],
    "category": ["Stationery", "Stationery", "Accessories",
                 "Stationery", "Stationery", "Accessories"],
    "store": ["A", "A", "A", "B", "B", "B"],
    "price": [150, 20, 350, 10, 160, 400],
    "stock": [10, 50, 5, 30, 8, 3]
})

print(products)
```

## 2. แนวคิด split-apply-combine

การสรุปข้อมูลแบบกลุ่มมีสามขั้นตอน:

1. **Split:** แบ่งแถวตามหมวดสินค้า
2. **Apply:** คำนวณแต่ละกลุ่ม เช่น รวมสต็อก
3. **Combine:** รวมผลลัพธ์เป็น Series หรือ DataFrame

```python
grouped = products.groupby("category")
stock_by_category = grouped["stock"].sum()
print(stock_by_category)
```

ผลลัพธ์:

```text
category
Accessories     8
Stationery     98
Name: stock, dtype: int64
```

`groupby()` สร้าง GroupBy object ซึ่งยังไม่ใช่ตารางสรุป
ต้องเรียกคำสั่งคำนวณ เช่น `sum()` หรือ `mean()` ต่อ

## 3. สรุปข้อมูลคอลัมน์เดียว

### ราคาเฉลี่ยแต่ละหมวด

```python
average_price = products.groupby("category")["price"].mean()
print(average_price)
```

Accessories มีราคาเฉลี่ย 375 และ Stationery มีราคาเฉลี่ย 85
ค่าเฉลี่ยนี้ให้น้ำหนักแต่ละแถวเท่ากัน ไม่ใช่ค่าเฉลี่ยถ่วงน้ำหนักตาม stock

### คำสั่งสรุปที่ใช้บ่อย

```python
print(products.groupby("category")["price"].min())
print(products.groupby("category")["price"].max())
print(products.groupby("store")["stock"].sum())
```

| คำสั่ง | ความหมาย |
| --- | --- |
| `sum()` | ผลรวม |
| `mean()` | ค่าเฉลี่ย |
| `min()` | ค่าต่ำสุด |
| `max()` | ค่าสูงสุด |
| `size()` | จำนวนแถวในกลุ่ม |
| `count()` | จำนวนค่าที่ไม่ว่างในคอลัมน์ที่เลือก |
| `nunique()` | จำนวนค่าที่แตกต่างกัน โดยข้ามค่าว่างตามค่าเริ่มต้น |

นับจำนวนแถวและชื่อสินค้าที่ไม่ซ้ำกัน:

```python
print(products.groupby("category").size())
# Accessories: 2 แถว, Stationery: 4 แถว

print(products.groupby("category")["name"].nunique())
# Accessories: 1 ชื่อ, Stationery: 3 ชื่อ
```

จำนวนแถวไม่เท่ากับจำนวนสินค้าที่ไม่ซ้ำกัน เพราะ Book และ Bag มีหลายร้าน

## 4. คำนวณหลายค่า: agg

ใช้ `agg()` เพื่อสรุปหลายสถิติของคอลัมน์เดียว:

```python
price_summary = products.groupby("category")["price"].agg(
    ["min", "max", "mean"]
)
print(price_summary)
```

ผลลัพธ์:

```text
             min  max   mean
category
Accessories  350  400  375.0
Stationery    10  160   85.0
```

### สรุปหลายคอลัมน์และตั้งชื่อผลลัพธ์

แต่ละชื่อคอลัมน์ใหม่ระบุคู่ `(คอลัมน์ต้นทาง, วิธีคำนวณ)`:

```python
summary = products.groupby("category", as_index=False).agg(
    row_count=("name", "size"),
    unique_products=("name", "nunique"),
    average_price=("price", "mean"),
    total_stock=("stock", "sum")
)

print(summary)
```

จะได้หมวด Accessories มี 2 แถว, 1 ชื่อสินค้า, ราคาเฉลี่ย 375, สต็อกรวม 8
ส่วน Stationery มี 4 แถว, 3 ชื่อสินค้า, ราคาเฉลี่ย 85, สต็อกรวม 98

## 5. เก็บชื่อกลุ่มเป็นคอลัมน์

ค่าเริ่มต้นของการสรุปด้วย `groupby()` ใช้ชื่อกลุ่มเป็น index
ใช้ `as_index=False` เพื่อให้ชื่อกลุ่มเป็นคอลัมน์ปกติ:

```python
stock_summary = products.groupby("category", as_index=False)["stock"].sum()
print(stock_summary)
```

หรือเปลี่ยน index ของผลลัพธ์กลับมาเป็นคอลัมน์ด้วย `reset_index()`:

```python
stock_summary = products.groupby("category")["stock"].sum().reset_index()
```

## 6. แบ่งกลุ่มด้วยหลายคอลัมน์

ส่ง List ของคอลัมน์เพื่อแยกกลุ่มตามทั้งร้านและหมวดสินค้า:

```python
store_summary = products.groupby(
    ["store", "category"], as_index=False
)["stock"].sum()

print(store_summary)
```

ผลรวมแต่ละกลุ่ม:

| store | category | stock |
| --- | --- | --- |
| A | Accessories | 5 |
| A | Stationery | 60 |
| B | Accessories | 3 |
| B | Stationery | 38 |

## 7. สรุปมูลค่าสต็อกแล้วเรียงลำดับ

คำนวณมูลค่าแต่ละแถวก่อน แล้วรวมตามหมวด:

```python
valued_products = products.copy()
valued_products["total_value"] = (
    valued_products["price"] * valued_products["stock"]
)

value_summary = valued_products.groupby(
    "category", as_index=False
)["total_value"].sum()

ranked = value_summary.sort_values("total_value", ascending=False)
print(ranked)
```

Stationery มีมูลค่า 4080 และ Accessories มีมูลค่า 2950
มูลค่านี้เป็นมูลค่าสินค้าในสต็อก ไม่ใช่ยอดขาย

## 8. ค่าว่างกับการแบ่งกลุ่ม

### size กับ count ต่างกันอย่างไร?

```python
with_missing = products.copy()
with_missing.loc[0, "price"] = float("nan")

print(with_missing.groupby("category").size())
print(with_missing.groupby("category")["price"].count())
```

Stationery ยังมี 4 แถวเมื่อใช้ `size()`
แต่มีราคาไม่ว่างเพียง 3 ค่าเมื่อใช้ `count()`
ส่วน `mean()` คำนวณจากราคาที่ไม่ว่างตามค่าเริ่มต้น

### ค่าว่างในคอลัมน์ที่ใช้แบ่งกลุ่ม

`groupby()` ข้ามแถวที่คอลัมน์แบ่งกลุ่มเป็นค่าว่างตามค่าเริ่มต้น
ใช้ `dropna=False` หากต้องการให้ค่าว่างเป็นอีกกลุ่มหนึ่ง:

```python
unknown_category = products.copy()
unknown_category.loc[0, "category"] = None

print(unknown_category.groupby("category", dropna=False)["stock"].sum())
```

ผลรวมกลุ่ม Accessories เท่ากับ 8, Stationery เท่ากับ 88
และกลุ่มที่ไม่ทราบหมวดมีสต็อก 10
`dropna=False` ควบคุมค่าว่างในชื่อกลุ่ม ไม่ได้เติมค่าว่างในข้อมูล

---

## แบบฝึกหัด

ใช้ `products` จากหัวข้อ 1 แล้วลอง:

1. หาสต็อกรวมของแต่ละร้านด้วย `groupby()` และ `sum()`

```python
print(products.groupby("store")["stock"].sum())
```

2. หาราคาสูงสุดของแต่ละหมวดสินค้า

```python
print(products.groupby("category")["price"].max())
```

3. นับจำนวนแถวของแต่ละหมวดด้วย `size()`

```python
print(products.groupby("category").size())
```

4. นับจำนวนชื่อสินค้าที่ไม่ซ้ำกันของแต่ละร้านด้วย `nunique()`

```python
print(products.groupby("store")["name"].nunique())
```

5. สร้างตารางสรุปแต่ละหมวดด้วย `agg()` โดยมีคอลัมน์ `average_price` และ `total_stock` และให้ `category` เป็นคอลัมน์ปกติ

```python
summary = products.groupby("category", as_index=False).agg(
    average_price=("price", "mean"),
    total_stock=("stock", "sum")
)

print(summary)
```

6. หาสต็อกรวมแยกตาม `store` และ `category` พร้อมกัน

```python
store_summary = products.groupby(
    ["store", "category"], as_index=False
)["stock"].sum()

print(store_summary)
```

7. สร้างสำเนา เพิ่ม `total_value` จาก price คูณ stock แล้วหามูลค่าสต็อกรวมแต่ละร้าน เรียงจากมากไปน้อย

```python
valued_products = products.copy()
valued_products["total_value"] = (
    valued_products["price"] * valued_products["stock"]
)

value_summary = valued_products.groupby(
    "store", as_index=False
)["total_value"].sum()

ranked = value_summary.sort_values("total_value", ascending=False)
print(ranked)
```

ลองเขียนคำตอบเอง แล้วใช้ `print()` ตรวจผลลัพธ์

---

## แหล่งอ้างอิง

- [pandas: Group by — split-apply-combine](https://pandas.pydata.org/docs/user_guide/groupby.html)
