# 4. ความสัมพันธ์ระหว่างตัวแปร

Scatter plot ใช้ตำแหน่งของจุดแสดงตัวเลขสองตัว โดยหนึ่งจุดมักแทนข้อมูลหนึ่งแถว

## Scatter plot พื้นฐาน

```python
import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns

customers = pd.DataFrame({
    "age": [22, 25, 29, 35, 42, 48, 55, 61],
    "income": [18000, 22000, 30000, 42000, 55000, 65000, 72000, 80000],
    "spending": [5000, 7000, 9000, 15000, 18000, 21000, 17000, 16000],
    "segment": ["A", "A", "A", "B", "B", "B", "C", "C"],
})

sns.scatterplot(
    data=customers,
    x="income",
    y="spending",
    hue="segment",
    size="age",
    alpha=0.7,
)
plt.show()
```

## รูปแบบที่ควรมองหา

- แนวโน้มเชิงบวกหรือลบ
- เส้นโค้งหรือความสัมพันธ์ไม่เป็นเส้นตรง
- กลุ่มข้อมูล
- จุดที่อยู่ห่างจากกลุ่ม
- รูปกรวยซึ่งอาจบ่งชี้ Heteroscedasticity

Correlation วัดความสัมพันธ์บางรูปแบบ แต่ไม่ได้ยืนยันเหตุและผล

## เส้นแนวโน้ม

```python
sns.regplot(
    data=customers,
    x="income",
    y="spending",
    scatter_kws={"alpha": 0.6},
    line_kws={"color": "red"},
)
plt.show()
```

เส้น Linear Regression อาจสรุปข้อมูลโค้งไม่ดี และ Outlier อาจดึงเส้นให้เอียง

## Overplotting และ Hexbin

เริ่มจากลดขนาดจุดและเพิ่มความโปร่งใส หากมีข้อมูลมากให้ใช้ Hexbin:

```python
plt.hexbin(
    customers["income"],
    customers["spending"],
    gridsize=20,
    mincnt=1,
    cmap="Blues",
)
plt.colorbar(label="Number of rows")
plt.show()
```

## Pair plot

```python
sns.pairplot(
    data=customers,
    vars=["age", "income", "spending"],
    hue="segment",
)
plt.show()
```

Pair plot สร้างกราฟทุกคู่ จำนวนกราฟจึงเพิ่มประมาณกำลังสองของจำนวน Features ควรเลือกเฉพาะตัวแปรสำคัญ

## Correlation heatmap

Pearson correlation:

$$
r=\frac{\operatorname{cov}(X,Y)}{\sigma_X\sigma_Y}
$$

```python
numeric = customers.select_dtypes(include="number")
correlation = numeric.corr(method="pearson")

sns.heatmap(
    correlation,
    annot=True,
    fmt=".2f",
    cmap="coolwarm",
    center=0,
    vmin=-1,
    vmax=1,
)
plt.show()
```

ข้อควรระวัง:

- Pearson เน้นความสัมพันธ์เชิงเส้น
- Spearman ใช้อันดับและเหมาะกับแนวโน้มทางเดียวที่ไม่จำเป็นต้องเป็นเส้นตรง
- Correlation สูงอาจเกิดจากตัวแปรร่วม เวลา หรือ Data Leakage
- Correlation ใกล้ศูนย์ไม่ได้แปลว่าไม่มีความสัมพันธ์แบบโค้ง

## Scatter plot บอกไม่ได้

- X เป็นสาเหตุของ Y หรือไม่
- รูปแบบเกิดซ้ำในข้อมูลใหม่หรือไม่
- ตัวแปรที่ไม่ได้วัดเป็นสาเหตุร่วมอยู่หรือไม่
- Outlier ควรถูกลบหรือไม่

---

[← บทก่อนหน้า](03-category-bar-chart.md) | [สารบัญ](index.md) | [บทถัดไป: ข้อมูลตามเวลา →](05-time-series.md)
