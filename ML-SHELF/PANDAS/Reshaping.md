---
title: "Reshaping: pivot, pivot_table & melt"
description: "การปรับรูปตารางด้วย pivot pivot_table melt และ crosstab"
tags:
  - python
  - pandas
---

# Reshaping: pivot, pivot_table & melt

การปรับรูปตารางช่วยจัดข้อมูลให้เหมาะกับรายงานหรือการวิเคราะห์
แบบ long เก็บรายการหลายแถว ส่วนแบบ wide กระจายบางค่าเป็นคอลัมน์

## 1. เตรียมข้อมูลแบบ long

```python
import pandas as pd

sales = pd.DataFrame({
    "store": ["A", "A", "B", "B"],
    "name": ["Book", "Pen", "Book", "Pen"],
    "quantity": [2, 3, 1, 4]
})
```

## 2. pivot: เปลี่ยนเป็น wide โดยไม่คำนวณสรุป

```python
wide = sales.pivot(index="store", columns="name", values="quantity")
print(wide)
```

ผลลัพธ์:

```text
name   Book  Pen
store
A         2    3
B         1    4
```

แต่ละคู่ store และ name ต้องมีค่าเดียว หากคู่ซ้ำ pivot จะเกิด ValueError
ชื่อแกน columns เป็น name ส่วนชื่อแกน index เป็น store

## 3. pivot_table: สรุปก่อนปรับรูป

```python
extra_sale = pd.DataFrame({"store": ["A"], "name": ["Book"], "quantity": [5]})
repeated_sales = pd.concat([sales, extra_sale], ignore_index=True)

summary = repeated_sales.pivot_table(
    index="store",
    columns="name",
    values="quantity",
    aggfunc="sum",
    fill_value=0
)
print(summary)
```

A ขาย Book รวม 7, Pen 3 ส่วน B ขาย Book 1, Pen 4
ต้องระบุ aggfunc ให้ตรงโจทย์ เพราะค่าเริ่มต้นเป็น mean
fill_value เติมช่องว่างในตารางสรุป ไม่ได้เติมข้อมูลต้นทาง
ใช้ 0 เมื่อช่องที่ไม่มีรายการหมายถึงไม่มียอดขายจริง

## 4. melt: เปลี่ยน wide กลับเป็น long

```python
long_again = wide.reset_index().melt(
    id_vars="store",
    value_vars=["Book", "Pen"],
    var_name="name",
    value_name="quantity"
)
print(long_again)
```

id_vars คือคอลัมน์ที่เก็บไว้ ส่วน value_vars คือคอลัมน์ที่ย้ายไปเป็นแถว
การ melt ได้ค่ากลับครบแต่ลำดับแถวอาจต่างจาก sales เดิม
หาก pivot_table รวมหลายแถวไปแล้ว melt จะไม่คืนรายละเอียดรายการเดิม

## 5. crosstab: นับความถี่ข้ามสองหมวด

```python
counts = pd.crosstab(repeated_sales["store"], repeated_sales["name"])
print(counts)
```

นับจำนวนแถว ไม่ใช่ผลรวม quantity: คู่ A และ Book มี 2 แถว

## แบบฝึกหัด

1. ใช้ pivot สร้างตาราง quantity ที่แถวเป็น name และคอลัมน์เป็น store

```python

```

2. ใช้ repeated_sales สรุป quantity ด้วย pivot_table และ aggfunc="sum"

```python

```

3. ใช้ melt เปลี่ยน wide กลับเป็น long แล้วเรียงตาม store และ name

```python

```

4. ใช้ crosstab นับจำนวนรายการขายของแต่ละร้านและชื่อสินค้า

```python

```


## แหล่งอ้างอิง

- [pandas: Reshaping and pivot tables](https://pandas.pydata.org/docs/user_guide/reshaping.html)
