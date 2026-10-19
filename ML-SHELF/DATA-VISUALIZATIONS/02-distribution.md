# 2. Distribution: ข้อมูลกระจายอย่างไร

Distribution ช่วยตอบว่าค่าส่วนใหญ่อยู่บริเวณใด กระจายกว้างแค่ไหน เบ้หรือไม่ มีหลายยอดหรือมี Outliers หรือไม่

## Histogram

Histogram แบ่งช่วงค่าเป็น Bins แล้วนับจำนวนข้อมูลในแต่ละช่วง

```python
import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns

income = pd.DataFrame({
    "income": [18000, 22000, 24000, 30000, 42000, 55000, 65000, 72000, 80000]
})

sns.histplot(data=income, x="income", bins=5)
plt.xlabel("Monthly income (THB)")
plt.ylabel("Number of people")
plt.show()
```

จำนวน Bins เปลี่ยนเรื่องที่มองเห็น:

- น้อยเกินไปซ่อนรูปแบบ
- มากเกินไปทำให้ Noise ดูสำคัญ
- ควรลองหลายค่าและรายงานค่าที่ใช้

## Count กับ Density

`stat="count"` แสดงจำนวนแถว ส่วน `stat="density"` ปรับพื้นที่รวมใต้กราฟให้ประมาณ 1 เหมาะกับการเปรียบเทียบกลุ่มที่มีขนาดต่างกัน

```python
sns.histplot(
    data=income,
    x="income",
    bins=5,
    stat="density",
)
plt.show()
```

## KDE

KDE สร้างเส้นประมาณความหนาแน่นที่ต่อเนื่อง ค่า `bw_adjust` ควบคุมความเรียบ:

```python
sns.kdeplot(
    data=income,
    x="income",
    bw_adjust=0.8,
    fill=True,
)
plt.show()
```

KDE อาจทำให้เส้นเลยขอบเขตจริง เช่น รายได้ติดลบ และไม่น่าเชื่อถือเมื่อ Sample เล็ก จึงควรแสดง Histogram หรือ Rug plot ร่วมด้วย

## ECDF

ECDF แสดงสัดส่วนข้อมูลที่มีค่าน้อยกว่าหรือเท่ากับค่า X:

$$
F_n(x)=\frac{1}{n}\sum_{i=1}^{n}I(X_i\leq x)
$$

```python
sns.ecdfplot(data=income, x="income")
plt.ylabel("Proportion ≤ x")
plt.show()
```

ECDF ไม่ต้องเลือก Bins หรือ Bandwidth และอ่าน Percentile ได้โดยตรง

## Box plot

Box plot สรุป Median, Quartiles และ Whiskers:

$$
IQR=Q_3-Q_1
$$

ขอบเขตที่นิยมใช้ตรวจค่าห่าง:

$$
[Q_1-1.5IQR,\;Q_3+1.5IQR]
$$

```python
sns.boxplot(data=income, x="income")
plt.show()
```

จุดนอก Whiskers คือค่าที่ควรตรวจ ไม่ใช่ค่าที่ต้องลบอัตโนมัติ

## Violin plot

Violin plot รวม Box plot กับรูปร่างจาก KDE เหมาะกับการเปรียบเทียบรูปทรงของ Distribution หลายกลุ่ม:

```python
data = pd.DataFrame({
    "segment": ["A"] * 5 + ["B"] * 5,
    "spending": [5, 6, 7, 8, 20, 12, 13, 14, 15, 16],
})

sns.violinplot(data=data, x="segment", y="spending", inner="quartile")
plt.show()
```

เมื่อแต่ละกลุ่มมีข้อมูลน้อย รูปร่าง Violin อาจดูละเอียดเกินหลักฐาน ควรเพิ่มจุดจริงด้วย `stripplot()` และรายงานจำนวนข้อมูล

## เลือกกราฟใด

| ต้องการดู | กราฟ |
|---|---|
| จำนวนในแต่ละช่วง | Histogram |
| รูปร่างแบบเส้นต่อเนื่อง | KDE |
| Percentile โดยไม่เลือก Bins | ECDF |
| สรุปและ Outliers | Box plot |
| รูปร่างหลายกลุ่ม | Violin plot |

---

[← บทก่อนหน้า](01-foundations.md) | [สารบัญ](index.md) | [บทถัดไป: Category และ Bar Chart →](03-category-bar-chart.md)
