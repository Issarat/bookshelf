# 3. Category และ Bar Chart

Bar chart ใช้ความยาวของแท่งเปรียบเทียบค่าระหว่าง Category เหมาะกับจำนวน ยอดรวม ค่าเฉลี่ย หรือสัดส่วน

## นับจำนวนแต่ละ Category

```python
import matplotlib.pyplot as plt
import pandas as pd

customers = pd.DataFrame({
    "segment": ["A", "A", "A", "B", "B", "C"],
})

counts = customers["segment"].value_counts().sort_values()
counts.plot(kind="barh")
plt.xlabel("Number of customers")
plt.ylabel("Segment")
plt.show()
```

ใช้ Bar แนวนอนเมื่อชื่อ Category ยาว และเรียงค่าช่วยให้เปรียบเทียบง่ายขึ้น

## Aggregate ก่อนวาด

ต้องระบุให้ชัดว่าแท่งแสดง Sum, Mean, Median หรือ Count:

```python
sales = pd.DataFrame({
    "region": ["North", "North", "Central", "Central", "South"],
    "amount": [100, 150, 200, 260, 180],
})

summary = (
    sales.groupby("region", as_index=False)
    .agg(total_sales=("amount", "sum"), orders=("amount", "size"))
    .sort_values("total_sales")
)

plt.barh(summary["region"], summary["total_sales"])
plt.xlabel("Total sales (THB)")
plt.show()
```

ยอดรวมสูงอาจเกิดจากมีรายการมาก ไม่ได้หมายความว่าค่าเฉลี่ยต่อรายการสูง ควรดูจำนวนข้อมูลควบคู่กัน

## ค่าเฉลี่ยและ Error bar

```python
import seaborn as sns

sns.barplot(
    data=sales,
    x="region",
    y="amount",
    estimator="mean",
    errorbar=("ci", 95),
)
plt.ylabel("Mean order amount (THB)")
plt.show()
```

Error bar แสดงความไม่แน่นอนของค่าประมาณ ไม่ได้แสดงช่วงค่าดิบทั้งหมด และ Sample เล็กมักให้ช่วงกว้าง

## Grouped และ Stacked Bar

- Grouped bar เหมาะกับการเปรียบเทียบกลุ่มย่อยโดยตรง
- Stacked bar เหมาะกับการดูองค์ประกอบรวม
- 100% stacked bar เหมาะกับการเทียบสัดส่วน แต่ซ่อนความต่างของยอดรวม

หากมี Category และกลุ่มย่อยจำนวนมาก ควรใช้ Facet หรือ Heatmap แทน

## ต้องเริ่มแกนที่ศูนย์

Bar chart ใช้ความยาวแทนขนาด การตัดแกนทำให้ความต่างดูเกินจริง จึงควรเริ่ม Value axis ที่ศูนย์ในกรณีทั่วไป

```python
plt.ylim(bottom=0)
```

## ข้อผิดพลาดที่พบบ่อย

- ใช้ Pie chart กับ Category จำนวนมาก
- ไม่บอกว่าแท่งคือ Sum หรือ Mean
- ใช้ค่าเฉลี่ยโดยไม่แสดงจำนวนข้อมูลหรือความไม่แน่นอน
- เรียง Category แบบสุ่มทั้งที่ไม่มีลำดับตามธรรมชาติ
- ใช้สีต่างกันทุกแท่งทั้งที่สีไม่ได้มีความหมาย
- ตัดแกนเพื่อขยายความต่าง

---

[← บทก่อนหน้า](02-distribution.md) | [สารบัญ](index.md) | [บทถัดไป: ความสัมพันธ์ →](04-relationships.md)
