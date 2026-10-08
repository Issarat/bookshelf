---
title: "Plotting: การสร้างกราฟด้วย pandas"
description: "การสร้าง ปรับแต่ง และบันทึกกราฟด้วย pandas และ Matplotlib"
tags:
  - python
  - pandas
---

# Plotting: การสร้างกราฟด้วย pandas

กราฟช่วยเปรียบเทียบข้อมูล ดูแนวโน้ม และสำรวจการกระจายของค่า
pandas มี `.plot()` สำหรับ Series และ DataFrame
บทนี้ใช้ backend เริ่มต้นคือ Matplotlib และต่อยอดจาก [Grouping](Grouping.md)
กับ [DateTime](DateTime.md)

## 1. ติดตั้งและเตรียมข้อมูล

หากยังไม่มีไลบรารี ให้ติดตั้งใน Python environment ที่ใช้งาน:

```bash
pip install pandas matplotlib
```

```python
import pandas as pd
import matplotlib.pyplot as plt

products = pd.DataFrame({
    "name": ["Book", "Pen", "Bag", "Pencil", "Notebook", "Pouch"],
    "category": ["Stationery", "Stationery", "Accessories",
                 "Stationery", "Stationery", "Accessories"],
    "price": [150, 20, 350, 10, 80, 120],
    "stock": [10, 50, 5, 30, 15, 8]
})
```

รันตัวอย่างจากส่วนเตรียมข้อมูลก่อน ไม่ต้อง import NumPy
ในไฟล์ .py ใช้ `plt.show()` เพื่อเปิดกราฟ
ใน Jupyter มักแสดงกราฟใน notebook ได้เช่นกัน
แต่ละตัวอย่างด้านล่างปิด figure หลังแสดง เพื่อไม่ให้กราฟสะสม

## 2. Bar chart: เปรียบเทียบแต่ละสินค้า

```python
ax = products.plot.bar(
    x="name", y="stock", title="Stock by product",
    figsize=(8, 4), color="steelblue", legend=False, rot=0
)
ax.set_xlabel("Product")
ax.set_ylabel("Stock (units)")
ax.set_ylim(bottom=0)
ax.figure.tight_layout()
plt.show()
plt.close(ax.figure)
```

x ระบุชื่อคอลัมน์บนแกนนอน ส่วน y ระบุค่าที่ต้องการเปรียบเทียบ
Pen มีสต็อกสูงสุด 50 ชิ้น
กราฟแท่งสำหรับจำนวนควรเริ่มแกนค่าที่ 0 เพื่อให้ความยาวแท่งเปรียบเทียบกันได้ตรง

ใช้กราฟแนวนอนเมื่อชื่อยาว หรือมีรายการจำนวนมาก:

```python
ranked = products.sort_values("price")
ax = ranked.plot.barh(
    x="name", y="price", title="Price by product",
    legend=False, figsize=(7, 4)
)
ax.set_xlabel("Price (THB)")
ax.set_ylabel("Product")
ax.figure.tight_layout()
plt.show()
plt.close(ax.figure)
```

## 3. Line chart: ดูแนวโน้มตามเวลา

```python
sales = pd.DataFrame({
    "date": ["2026-01-01", "2026-01-02", "2026-01-03",
             "2026-01-04", "2026-01-05"],
    "amount": [300, 450, 200, 600, 500]
})
sales["date"] = pd.to_datetime(sales["date"], format="%Y-%m-%d")
sales = sales.sort_values("date")

ax = sales.plot.line(
    x="date", y="amount", marker="o", title="Daily sales",
    figsize=(8, 4), legend=False
)
ax.set_xlabel("Date")
ax.set_ylabel("Sales (THB)")
ax.figure.tight_layout()
plt.show()
plt.close(ax.figure)
```

เรียงวันที่ก่อนวาด เพราะเส้นเชื่อมจุดตามลำดับข้อมูล
กราฟเส้นเหมาะกับแกนที่มีลำดับต่อเนื่อง เช่น เวลา

## 4. Histogram: ดูการกระจาย

```python
ax = products["price"].plot.hist(
    bins=4, title="Price distribution", edgecolor="white", figsize=(7, 4)
)
ax.set_xlabel("Price (THB)")
ax.set_ylabel("Number of products")
ax.figure.tight_layout()
plt.show()
plt.close(ax.figure)
```

bins คือจำนวนช่วงราคาที่ใช้แบ่งข้อมูล
แกนตั้งแสดงจำนวนรายการในแต่ละช่วง ไม่ใช่ราคาของสินค้าแต่ละชื่อ
ข้อมูลหกแถวใช้ฝึกคำสั่งได้ แต่ยังน้อยสำหรับสรุปรูปแบบการกระจายของตลาด

## 5. Scatter plot: ดูความสัมพันธ์สองตัวแปร

```python
ax = products.plot.scatter(
    x="price", y="stock", title="Price vs stock", figsize=(7, 4)
)
ax.set_xlabel("Price (THB)")
ax.set_ylabel("Stock (units)")
ax.figure.tight_layout()
plt.show()
plt.close(ax.figure)
```

แต่ละจุดแทนสินค้าหนึ่งแถว ใช้สำรวจว่าราคาและสต็อกเคลื่อนไปด้วยกันหรือไม่
ความสัมพันธ์ที่เห็นจากกราฟไม่ได้ยืนยันว่าตัวแปรหนึ่งเป็นสาเหตุของอีกตัวแปร

## 6. Box plot: สำรวจค่ากลางและการกระจาย

```python
ax = products["price"].plot.box(title="Product prices", figsize=(5, 4))
ax.set_ylabel("Price (THB)")
ax.figure.tight_layout()
plt.show()
plt.close(ax.figure)
```

เส้นในกล่องแสดงมัธยฐาน กล่องแสดงช่วงระหว่างเปอร์เซ็นไทล์ที่ 25 และ 75
จุดนอก whiskers เป็นค่าที่เข้ากฎการแสดง outlier ของกราฟ
ไม่ใช่หลักฐานว่าข้อมูลผิด จึงควรตรวจบริบทก่อนลบทิ้ง

## 7. สรุปข้อมูลก่อนวาดกราฟ

```python
valued_products = products.copy()
valued_products["total_value"] = valued_products["price"] * valued_products["stock"]
category_value = valued_products.groupby("category")["total_value"].sum()

ax = category_value.plot.bar(
    title="Inventory value by category", rot=0, legend=False, figsize=(7, 4)
)
ax.set_xlabel("Category")
ax.set_ylabel("Inventory value (THB)")
ax.figure.tight_layout()
plt.show()
plt.close(ax.figure)
```

Stationery มีมูลค่าสต็อก 4000 บาท ส่วน Accessories มี 2710 บาท
เป็นมูลค่าสินค้าที่มีอยู่ ไม่ใช่ยอดขาย
หากวาดข้อมูลที่ชื่อหมวดซ้ำโดยไม่สรุป จะได้แท่งตามแถว ไม่ใช่ผลรวมตามหมวด

## 8. หลายกราฟใน figure เดียวและการบันทึก

```python
fig, axes = plt.subplots(1, 2, figsize=(11, 4))

products.plot.bar(x="name", y="stock", ax=axes[0], legend=False, rot=45)
axes[0].set_title("Stock")
axes[0].set_ylabel("Units")

products.plot.bar(x="name", y="price", ax=axes[1], legend=False, rot=45)
axes[1].set_title("Price")
axes[1].set_ylabel("THB")

fig.tight_layout()
fig.savefig("product_charts.png", dpi=150, bbox_inches="tight")
plt.show()
plt.close(fig)
```

ax ระบุพื้นที่ที่จะวาดกราฟ ส่วน figsize ใช้หน่วยนิ้ว
บันทึกก่อน show เพื่อให้ได้ figure ที่ต้องการแม้หน้าต่างถูกปิดหลังแสดง
ไฟล์บันทึกในโฟลเดอร์ที่รัน Python และเขียนทับไฟล์ชื่อเดียวกัน
เปลี่ยนนามสกุลเป็น .svg หรือ .pdf ได้หากต้องการไฟล์เวกเตอร์

ตัวอย่างใช้ข้อความอังกฤษเพื่อไม่ขึ้นกับฟอนต์ไทยในเครื่อง
หากใช้ชื่อกราฟภาษาไทย ต้องเลือกฟอนต์ที่รองรับและติดตั้งอยู่ในเครื่อง

## เลือกกราฟแบบไหน?

| จุดประสงค์ | กราฟ |
| --- | --- |
| เปรียบเทียบค่าแยกตามชื่อหรือหมวด | bar / barh |
| ดูแนวโน้มตามเวลา | line |
| ดูจำนวนค่าในแต่ละช่วง | hist |
| สำรวจความสัมพันธ์สองตัวแปรตัวเลข | scatter |
| ดูมัธยฐาน การกระจาย และค่าที่ควรตรวจเพิ่มเติม | box |

ตรวจชนิดข้อมูลและค่าว่างก่อน plot การข้ามค่าว่างหรือเติม 0 อาจทำให้ภาพต่างกัน
ให้เลือกวิธีจัดการตามความหมายของข้อมูลก่อนวาด

## แบบฝึกหัด

ใช้ products และ sales จากตัวอย่างในบทนี้:

1. วาดกราฟแท่งเปรียบเทียบ price ของแต่ละสินค้า พร้อมชื่อแกนและหน่วย

```python

```

2. เรียง stock แล้ววาดกราฟแท่งแนวนอน

```python

```

3. วาด histogram ของ price โดยใช้ bins=3 แล้วลองเปลี่ยนเป็น 6 เพื่อเปรียบเทียบ

```python

```

4. วาด scatter ของ price กับ stock

```python

```

5. สรุปสต็อกรวมแต่ละ category แล้ววาดกราฟแท่ง

```python

```

6. วาดกราฟเส้นของยอดขายรายวันจาก sales

```python

```

7. สร้างสองกราฟใน figure เดียว แล้วบันทึกเป็นไฟล์ชื่อใหม่ก่อน show

```python

```


## แหล่งอ้างอิง

- [pandas: Chart visualization](https://pandas.pydata.org/docs/user_guide/visualization.html)
