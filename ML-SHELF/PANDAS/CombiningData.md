---
title: "Combining Data: concat, merge & join"
description: "การรวมตารางด้วย concat merge และ join"
tags:
  - python
  - pandas
---

# Combining Data: concat, merge & join

concat ต่อข้อมูลตามแกน ส่วน merge จับคู่แถวตาม key
เช่น รวมยอดขายกับรายละเอียดสินค้า บทนี้ใช้ตารางที่สร้างเองทั้งหมด

## 1. ต่อแถวด้วย concat

```python
import pandas as pd

day_one = pd.DataFrame({"product_id": ["001", "002"], "quantity": [2, 3]})
day_two = pd.DataFrame({"product_id": ["001", "003"], "quantity": [1, 4]})
sales = pd.concat([day_one, day_two], ignore_index=True)
print(sales)
```

ได้ 4 แถวและ index ใหม่ 0–3
หากคอลัมน์ต่างกัน concat ตามค่าเริ่มต้นจะรวมชื่อคอลัมน์
และเติมค่าว่างในตำแหน่งที่ไม่มีข้อมูล
concat(axis=1) ต่อคอลัมน์โดยจับคู่ index ไม่ได้จับคู่ตามตำแหน่งอย่างเดียว

## 2. merge จับคู่ด้วย key

```python
products = pd.DataFrame({
    "product_id": ["001", "002"],
    "name": ["Book", "Pen"],
    "unit_price": [150, 20]
})

details = sales.merge(
    products,
    on="product_id",
    how="left",
    validate="many_to_one",
    indicator=True
)
print(details)
```

left เก็บทุกแถวของ sales โดย product_id 003 มี name และ unit_price ว่าง
indicator สร้างคอลัมน์ _merge: both หมายถึงจับคู่ได้ และ left_only หมายถึงมีเฉพาะฝั่งซ้าย
validate="many_to_one" ตรวจว่า key ใน products ไม่ซ้ำ เพราะยอดขายหลายแถว
จับคู่กับรายละเอียดสินค้าหนึ่งแถวได้

| how | แถวที่เก็บ |
| --- | --- |
| inner | key ที่มีทั้งสองฝั่ง |
| left | ทุกแถวฝั่งซ้าย พร้อมข้อมูลที่จับคู่ได้จากขวา |
| right | ทุกแถวฝั่งขวา พร้อมข้อมูลที่จับคู่ได้จากซ้าย |
| outer | key จากทั้งสองฝั่ง |

## 3. ตรวจรายการที่จับคู่ไม่ได้และคำนวณ

```python
unmatched = details.loc[details["_merge"] == "left_only"]
print(unmatched["product_id"].tolist()) # ['003']

details["amount"] = details["quantity"] * details["unit_price"]
print(details[["product_id", "amount"]])
```

ยอดขาย 003 ยังหามูลค่าไม่ได้ อย่าแทนราคาที่ไม่พบด้วย 0 โดยไม่มีเหตุผล
ถ้าทั้งสองฝั่งมี key ซ้ำ merge อาจสร้างหลายคู่และเพิ่มจำนวนแถว
จึงควรตรวจ key และใช้ validate ให้ตรงความสัมพันธ์
ค่าว่างใน key ของ pandas สามารถจับคู่กันได้ ต่างจากพฤติกรรม NULL ของ SQL ทั่วไป

## 4. key คนละชื่อและคอลัมน์ซ้ำ

```python
catalog = products.rename(columns={"product_id": "id"})
matched = sales.merge(catalog, left_on="product_id", right_on="id", how="left")
print(matched)
```

หากมีชื่อคอลัมน์ข้อมูลซ้ำกันทั้งสองฝั่ง ใช้ suffixes=("_sale", "_catalog")
เพื่อแยกชื่อผลลัพธ์

## 5. join ด้วย index ฝั่งขวา

```python
catalog_index = products.set_index("product_id")
joined = sales.join(catalog_index, on="product_id", how="left", validate="many_to_one")
print(joined)
```

on ระบุคอลัมน์ฝั่งซ้ายที่จะจับคู่กับ index ของฝั่งขวา
ถ้าไม่ระบุ on จะจับคู่ index ทั้งสองฝั่ง

## แบบฝึกหัด

1. ต่อ day_one กับ day_two โดยสร้าง index ใหม่

```python

```

2. ทำ inner merge กับ products แล้วตรวจจำนวนแถว

```python

```

3. ทำ left merge พร้อม indicator แล้วหาสินค้าที่ไม่มีรายละเอียด

```python

```

4. เพิ่มสินค้า 003 ชื่อ Bag ราคา 350 ในตารางรายละเอียด แล้ว merge ใหม่

```python

```

5. คำนวณ amount และสรุปยอดขายรวมแยกตาม name ด้วย groupby

```python

```


## แหล่งอ้างอิง

- [pandas: Merge, join, concatenate and compare](https://pandas.pydata.org/docs/user_guide/merging.html)
