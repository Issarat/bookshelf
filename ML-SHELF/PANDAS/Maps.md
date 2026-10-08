---
title: "Maps"
description: "การแปลงข้อมูลด้วย map ฟังก์ชัน lambda และ apply"
tags:
  - python
  - pandas
---

# Maps

Mapping คือการแปลงค่าข้อมูลตามกฎที่กำหนด
เช่น เปลี่ยนรหัสหมวดสินค้าเป็นชื่อหมวด หรือจัดระดับราคาสินค้า
ต่างจาก [Summary Functions](SummaryFunctions.md) ที่สรุปข้อมูลหลายค่า
เป็นสถิติ การใช้ `Series.map()` แปลงแต่ละค่าโดยคง index เดิมไว้

## 1. เตรียมข้อมูล

```python
import pandas as pd

products = pd.DataFrame({
    "name": ["Book", "Pen", "Bag", "Pencil"],
    "category_code": ["S", "S", "A", "S"],
    "price": [150, 20, 350, 10],
    "stock": [10, 50, 5, 30]
})
```

## 2. map() ด้วย Dictionary

key คือค่าต้นทาง ส่วน value คือค่าที่ต้องการนำมาแทน

```python
category_map = {
    "S": "Stationery",
    "A": "Accessories"
}

products["category"] = products["category_code"].map(category_map)
print(products[["name", "category"]])
```

ผลลัพธ์:

```text
     name     category
0    Book   Stationery
1     Pen   Stationery
2     Bag  Accessories
3  Pencil   Stationery
```

`map()` คืน Series ใหม่ ต้องกำหนดผลลัพธ์กลับหากต้องการเก็บเป็นคอลัมน์
คอลัมน์ category_code ในตัวอย่างนี้ยังมีรหัสเดิมอยู่

### ค่าที่ไม่มีใน Dictionary

เมื่อใช้ Dictionary ปกติ ค่าที่ไม่มี key ตรงกันจะกลายเป็นค่าว่าง:

```python
codes = pd.Series(["S", "A", "X"])
mapped = codes.map(category_map)

print(mapped.isna().tolist()) # [False, False, True]
print(mapped.fillna("Unknown").tolist())
# ['Stationery', 'Accessories', 'Unknown']
```

หากต้นทางมีค่าว่างด้วย `fillna("Unknown")` จะเติมทั้งค่าที่จับคู่ไม่ได้
และค่าว่างจากต้นทาง จึงควรเลือกค่าแทนให้ตรงความหมายของข้อมูล

## 3. map() ด้วยฟังก์ชัน

ฟังก์ชันรับข้อมูลทีละค่าและคืนค่าใหม่
ตัวอย่างจัดราคาเป็น Expensive เมื่อราคาตั้งแต่ 100 ขึ้นไป:

```python
def classify_price(price):
    if price >= 100:
        return "Expensive"
    return "Affordable"

products["price_level"] = products["price"].map(classify_price)
print(products[["name", "price_level"]])
```

Book และ Bag จะเป็น Expensive ส่วน Pen และ Pencil เป็น Affordable
ส่งชื่อฟังก์ชัน `classify_price` ให้ map โดยไม่ใส่ `()`
เพราะต้องให้ pandas เรียกฟังก์ชันกับแต่ละค่าเอง

## 4. map() ด้วย lambda

`lambda` คือฟังก์ชันสั้นที่เขียนเป็น expression เดียว
เหมาะกับการแปลงค่าง่าย ๆ:

```python
products["discount_price"] = products["price"].map(
    lambda price: price * 0.9
)

print(products["discount_price"].tolist())
# [135.0, 18.0, 315.0, 9.0]
```

นี่คือราคาหลังลด 10% ไม่ใช่จำนวนเงินส่วนลด
สำหรับการคำนวณแบบนี้ เขียนกับ Series โดยตรงได้กระชับกว่า:

```python
products["discount_price"] = products["price"] * 0.9
```

## 5. ค่าว่างกับ map()

เมื่อ map ด้วยฟังก์ชัน ค่าเริ่มต้นจะส่งค่าว่างเข้าไปในฟังก์ชันด้วย
ใช้ `na_action="ignore"` เพื่อข้ามค่าว่างและเก็บค่าว่างไว้:

```python
names = pd.Series(["Book", None, "Bag"], dtype="string")

upper_names = names.map(lambda name: name.upper(), na_action="ignore")
print(upper_names)
```

ผลลัพธ์:

```text
0    BOOK
1    <NA>
2     BAG
dtype: string
```

หากไม่ข้ามค่าว่าง ฟังก์ชันที่คาดว่าจะได้รับข้อความอาจเกิดข้อผิดพลาด
สำหรับการแปลงข้อความเป็นตัวพิมพ์ใหญ่ pandas มีคำสั่งเฉพาะให้ใช้ได้เช่นกัน:

```python
print(names.str.upper())
```

## 6. apply() กับ Series

สำหรับฟังก์ชัน Python ปกติ `Series.apply()` เรียกฟังก์ชันกับแต่ละค่าได้:

```python
products["price_level"] = products["price"].apply(classify_price)
```

ตัวอย่างนี้ได้ผลเหมือน `map(classify_price)`
สำหรับการแทนค่าด้วย Dictionary ให้ใช้ `map()`

## 7. apply() กับ DataFrame

หากฟังก์ชันต้องใช้หลายคอลัมน์ในแถวเดียวกัน ใช้ `axis=1`
เพื่อส่งแต่ละแถวเป็น Series ให้ฟังก์ชัน:

```python
def calculate_value(row):
    return row["price"] * row["stock"]

products["total_value"] = products.apply(calculate_value, axis=1)
print(products["total_value"].tolist())
# [1500, 1000, 1750, 300]
```

`DataFrame.apply()` ใช้ `axis=0` เป็นค่าเริ่มต้น ซึ่งส่งแต่ละคอลัมน์
ให้ฟังก์ชัน ส่วน `axis=1` ส่งแต่ละแถว

การคูณสองคอลัมน์ในตัวอย่างนี้ใช้คำสั่งโดยตรงได้เช่นกัน:

```python
products["total_value"] = products["price"] * products["stock"]
```

ควรเริ่มจากคำสั่ง pandas ที่มีอยู่หรือการคำนวณกับ Series โดยตรง
แล้วใช้ฟังก์ชันเมื่อกฎการแปลงต้องการตรรกะเพิ่มเติม

## 8. เลือกใช้แบบไหน?

| งาน | วิธีที่ใช้ได้ |
| --- | --- |
| แปลงรหัสตาม Dictionary | `Series.map(dictionary)` |
| แปลงแต่ละค่าด้วยกฎของเรา | `Series.map(function)` |
| เรียกฟังก์ชันกับแต่ละค่าใน Series | `Series.apply(function)` |
| คำนวณจากหลายคอลัมน์ต่อแถว | `DataFrame.apply(function, axis=1)` |
| บวก ลบ คูณ หารคอลัมน์ | คำนวณกับ Series โดยตรง |
| แปลงข้อความเป็นตัวพิมพ์ใหญ่ | `Series.str.upper()` |

---

## แบบฝึกหัด

สร้าง `products` ใหม่จากหัวข้อ 1 แล้วลอง:

1. ใช้ Dictionary และ `map()` แปลง category_code เป็นชื่อหมวดในคอลัมน์ category

```python

```

2. สร้างคอลัมน์ name_upper โดยใช้ `map()` แปลงชื่อสินค้าเป็นตัวพิมพ์ใหญ่

```python

```

3. ใช้ฟังก์ชันและ `map()` สร้าง price_level: ราคาตั้งแต่ 100 เป็น Expensive และราคาต่ำกว่า 100 เป็น Affordable

```python

```

4. ใช้ lambda กับ `map()` สร้าง discount_price ซึ่งเป็นราคาหลังลด 20%

```python

```

5. ใช้ `apply(axis=1)` สร้าง total_value จาก price คูณ stock

```python

```

6. สร้าง Series ของรหัส `["S", "A", "X"]` แล้ว map ด้วย Dictionary จากข้อ 1 และเติมค่าที่จับคู่ไม่ได้ด้วย Unknown

```python

```

7. สร้าง Series `["Book", None, "Bag"]` โดยกำหนด `dtype="string"` แล้วใช้ `map()` แปลงข้อความเป็นตัวพิมพ์เล็ก พร้อมข้ามค่าว่าง

```python

```


ลองเขียนคำตอบเอง แล้วใช้ `print()` ตรวจผลลัพธ์

## แหล่งอ้างอิง

- [pandas: Series.map](https://pandas.pydata.org/docs/reference/api/pandas.Series.map.html)
- [pandas: Series.apply](https://pandas.pydata.org/docs/reference/api/pandas.Series.apply.html)
- [pandas: DataFrame.apply](https://pandas.pydata.org/docs/reference/api/pandas.DataFrame.apply.html)
