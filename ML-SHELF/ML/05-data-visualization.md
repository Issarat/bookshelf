# 5. Data Visualization

Data Visualization คือการใช้กราฟช่วยสำรวจ อธิบาย และสื่อสารข้อมูล กราฟที่ดีต้องเริ่มจากคำถาม ไม่ใช่เริ่มจากชนิดกราฟที่ดูสวย

```mermaid
flowchart LR
    A[ตั้งคำถาม] --> B[เลือกข้อมูล]
    B --> C[เลือกชนิดกราฟ]
    C --> D[ตรวจแกน หน่วย และสี]
    D --> E[เขียนข้อสรุปที่กราฟสนับสนุน]
```

## 1. เลือกกราฟจากคำถาม

| คำถาม | กราฟที่เหมาะ |
|---|---|
| ค่ากระจายอย่างไร? | Histogram, KDE, Box plot |
| Category ใดมากที่สุด? | Bar chart |
| ค่าเปลี่ยนตามเวลาอย่างไร? | Line chart |
| ตัวเลขสองตัวสัมพันธ์กันหรือไม่? | Scatter plot |
| เปรียบเทียบ Distribution หลายกลุ่ม | Box plot, Violin plot |
| ต้องการเห็น Missing values | Missing-value bar/heatmap |
| ต้องการดูความสัมพันธ์หลาย Features | Correlation heatmap, Pair plot |

## 2. เตรียมเครื่องมือและข้อมูลตัวอย่าง

```python
import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns

sns.set_theme(style="whitegrid")

customers = pd.DataFrame(
    {
        "age": [22, 25, 29, 35, 42, 48, 55, 61],
        "income": [18000, 22000, 30000, 42000, 55000, 65000, 72000, 80000],
        "spending": [5000, 7000, 9000, 15000, 18000, 21000, 17000, 16000],
        "segment": ["A", "A", "A", "B", "B", "B", "C", "C"],
    }
)
```

## 3. Histogram: ดู Distribution

```python
sns.histplot(
    data=customers,
    x="income",
    bins=6,
    kde=True,
)
plt.title("Income distribution")
plt.xlabel("Monthly income (THB)")
plt.ylabel("Number of customers")
plt.show()
```

จำนวน Bins ที่น้อยเกินไปอาจซ่อนรายละเอียด ส่วนมากเกินไปอาจทำให้เห็น Noise ควรทดลองหลายค่าและรายงานการตั้งค่า

## 4. Bar chart: เปรียบเทียบ Category

```python
segment_counts = customers["segment"].value_counts().sort_values()

segment_counts.plot(kind="barh")
plt.title("Customers by segment")
plt.xlabel("Number of customers")
plt.ylabel("Segment")
plt.show()
```

Bar chart ต้องเริ่มแกนค่าที่ศูนย์ในกรณีทั่วไป เพราะความยาวแท่งใช้แทนขนาด การตัดแกนอาจทำให้ความต่างดูมากเกินจริง

## 5. Scatter plot: ดูความสัมพันธ์

```python
sns.scatterplot(
    data=customers,
    x="income",
    y="spending",
    hue="segment",
    s=80,
)
plt.title("Income and spending")
plt.xlabel("Monthly income (THB)")
plt.ylabel("Monthly spending (THB)")
plt.show()
```

Scatter plot ช่วยเห็นแนวโน้ม กลุ่ม และ Outliers แต่ความสัมพันธ์ที่เห็นไม่ยืนยันเหตุและผล

## 6. Box plot: เปรียบเทียบหลายกลุ่ม

```python
sns.boxplot(
    data=customers,
    x="segment",
    y="spending",
)
plt.title("Spending by segment")
plt.xlabel("Segment")
plt.ylabel("Monthly spending (THB)")
plt.show()
```

Box plot แสดง Median, Quartiles และค่าที่อยู่นอก Whiskers จุดนอก Whiskers เป็นค่าที่ควรตรวจ ไม่ใช่ข้อมูลที่ต้องลบอัตโนมัติ

## 7. Line chart: ข้อมูลตามเวลา

```python
sales = pd.DataFrame(
    {
        "date": pd.date_range("2026-01-01", periods=7, freq="D"),
        "sales": [100, 120, 115, 140, 135, 160, 155],
    }
)

sns.lineplot(data=sales, x="date", y="sales", marker="o")
plt.title("Daily sales")
plt.xlabel("Date")
plt.ylabel("Sales")
plt.xticks(rotation=45)
plt.tight_layout()
plt.show()
```

ต้องเรียงเวลาและตรวจช่วงที่ข้อมูลขาดก่อนเชื่อมเส้น เพราะเส้นอาจทำให้ดูเหมือนมีข้อมูลต่อเนื่องทั้งที่บางช่วงไม่มีการวัด

## 8. Correlation heatmap

```python
numeric = customers.select_dtypes(include="number")
correlation = numeric.corr()

sns.heatmap(
    correlation,
    annot=True,
    fmt=".2f",
    cmap="coolwarm",
    center=0,
    vmin=-1,
    vmax=1,
)
plt.title("Correlation matrix")
plt.show()
```

Correlation matrix อาจอ่านยากเมื่อ Features มาก ควรเลือกเฉพาะ Features ที่เกี่ยวข้องหรือจัดกลุ่มก่อนแสดง

## 9. ดู Missing values

```python
missing_percent = customers.isna().mean().mul(100)
missing_percent = missing_percent[missing_percent > 0].sort_values()

missing_percent.plot(kind="barh")
plt.xlabel("Missing values (%)")
plt.ylabel("Column")
plt.title("Missing values by column")
plt.show()
```

ถ้าไม่มี Missing กราฟจะว่าง ควรตรวจจำนวนข้อมูลร่วมด้วย ไม่ควรดูเปอร์เซ็นต์อย่างเดียว

## 10. เปรียบเทียบ Train กับ Validation

กราฟช่วยตรวจ Distribution shift เบื้องต้น:

```python
train_plot = X_train.assign(dataset="train")
valid_plot = X_valid.assign(dataset="validation")
comparison = pd.concat([train_plot, valid_plot], ignore_index=True)

sns.histplot(
    data=comparison,
    x="income",
    hue="dataset",
    stat="density",
    common_norm=False,
    element="step",
)
plt.show()
```

กราฟต่างกันไม่ได้ยืนยัน Drift เสมอไป โดยเฉพาะเมื่อ Sample เล็ก ต้องตรวจช่วงเวลา วิธีเก็บข้อมูล และตัววัดอื่นร่วมด้วย

## 11. กราฟประเมินโมเดล

| งาน | กราฟ |
|---|---|
| Regression | Actual vs Predicted, Residual plot |
| Binary classification | Confusion matrix, ROC, PR curve, Calibration curve |
| Tuning | Validation curve |
| ตรวจ Under/Overfitting | Learning curve |
| Explainability | Permutation importance, Partial dependence |

ตัวอย่าง Actual vs Predicted:

```python
import matplotlib.pyplot as plt

plt.scatter(y_valid, y_pred, alpha=0.7)
lower = min(y_valid.min(), y_pred.min())
upper = max(y_valid.max(), y_pred.max())
plt.plot([lower, upper], [lower, upper], linestyle="--", color="black")
plt.xlabel("Actual")
plt.ylabel("Predicted")
plt.title("Actual vs predicted")
plt.show()
```

## 12. หลักการออกแบบให้อ่านง่าย

- ตั้งชื่อกราฟให้บอกคำถามหรือข้อค้นพบ
- ใส่ชื่อแกนและหน่วย
- เรียง Bar chart เมื่อไม่มีลำดับตามธรรมชาติ
- ใช้สีจำนวนน้อยและความหมายสม่ำเสมอ
- ใช้ Color palette ที่ผู้มีภาวะตาบอดสีอ่านได้
- หลีกเลี่ยงกราฟ 3 มิติเมื่อข้อมูลมีเพียงสองแกน
- แสดงจำนวนข้อมูลเมื่อเปรียบเทียบกลุ่ม
- ใช้ `tight_layout()` ป้องกันข้อความถูกตัด

## 13. กราฟที่อาจทำให้เข้าใจผิด

### ตัดแกน Bar chart

การเริ่มแกน Y ที่ 95 แทน 0 อาจทำให้ค่า 98 กับ 100 ดูต่างกันมาก

### ใช้สองแกน Y

Dual-axis chart สามารถปรับ Scale ให้เส้นสองเส้นดูสัมพันธ์กันได้ง่าย ควรแยกกราฟหรือ Normalize พร้อมอธิบายให้ชัด

### เลือกช่วงเวลาที่สนับสนุนข้อสรุป

ควรแสดงช่วงเวลาที่เหมาะสมและบอกเหตุผล ไม่เลือกเฉพาะช่วงที่กราฟดูเพิ่มหรือลดตามข้อสรุปที่ต้องการ

### ใช้ Area แทนความยาวโดยไม่จำเป็น

มนุษย์เปรียบเทียบความยาวได้แม่นกว่า Area และ Volume จึงควรใช้ Bar chart แทน Bubble หรือกราฟ 3 มิติเมื่อเปรียบเทียบค่าทั่วไป

## 14. บันทึกกราฟ

```python
plt.figure(figsize=(8, 5))
sns.scatterplot(data=customers, x="income", y="spending")
plt.title("Income and spending")
plt.tight_layout()
plt.savefig(
    "income-spending.png",
    dpi=150,
    bbox_inches="tight",
)
plt.close()
```

สำหรับรายงานควรเก็บโค้ด ข้อมูล เวอร์ชัน และวันที่สร้างกราฟ เพื่อให้สร้างซ้ำได้

## 15. Checklist

- เริ่มจากคำถามที่ต้องการตอบ
- เลือกกราฟให้ตรงกับชนิดข้อมูล
- ระบุแกน หน่วย ช่วงเวลา และจำนวนข้อมูล
- ตรวจ Missing, Outliers และ Scale ก่อนสรุป
- ใช้สีอย่างมีความหมายและอ่านได้
- ไม่สรุป Causation จาก Correlation
- ไม่ใช้ Test เพื่อสำรวจแล้วกลับไปปรับโมเดล
- เขียนข้อสรุปเฉพาะสิ่งที่กราฟสนับสนุน

## แหล่งอ้างอิง

- [Matplotlib: Tutorials](https://matplotlib.org/stable/tutorials/index.html)
- [seaborn: User guide](https://seaborn.pydata.org/tutorial.html)
- [pandas: Chart visualization](https://pandas.pydata.org/docs/user_guide/visualization.html)

---

[← บทก่อนหน้า: Exploratory Data Analysis (EDA)](04-eda.md) · [สารบัญ](index.md) · [บทถัดไป: Data Cleansing และ Missing Data →](06-data-cleansing-missing-data.md)
