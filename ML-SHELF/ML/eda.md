# 4. Exploratory Data Analysis (EDA)

EDA คือการสำรวจข้อมูลก่อนสร้างโมเดล เพื่อเข้าใจความหมาย คุณภาพ การกระจาย และความสัมพันธ์ของข้อมูล

## สิ่งที่ต้องตรวจ

1. จำนวนแถวและคอลัมน์
2. ชนิดข้อมูลและหน่วย
3. Missing values และข้อมูลซ้ำ
4. การกระจายและ Outliers
5. จำนวนค่าที่ไม่ซ้ำของ Category
6. ความสัมพันธ์ระหว่าง Features กับ Target
7. ความต่างของ Train, Validation และข้อมูลใช้งานจริง

```python
import pandas as pd

df = pd.read_csv("customers.csv")

print(df.shape)
print(df.info())
print(df.describe(include="all").T)
print(df.isna().mean().sort_values(ascending=False))
print("Duplicated rows:", df.duplicated().sum())
```

## การดู Distribution

```python
import matplotlib.pyplot as plt
import seaborn as sns

sns.histplot(data=df, x="income", kde=True)
plt.show()

sns.boxplot(data=df, x="income")
plt.show()
```

Histogram แสดงรูปการกระจาย ส่วน Box plot ช่วยชี้ค่าที่ควรตรวจเพิ่ม

## Category และ Cardinality

Cardinality คือจำนวนค่าที่แตกต่างกันในคอลัมน์:

```python
for column in df.select_dtypes(include="object"):
    print(column, df[column].nunique(dropna=False))
    print(df[column].value_counts(dropna=False).head())
```

Category ที่มีค่าจำนวนมาก เช่นรหัสลูกค้า อาจทำให้ One-hot encoding สร้างคอลัมน์มากเกินไป และรหัสเฉพาะแถวมักไม่ใช่ Feature ที่ช่วย Generalize

## Correlation

```python
numeric = df.select_dtypes(include="number")
correlation = numeric.corr()

sns.heatmap(correlation, cmap="coolwarm", center=0)
plt.show()
```

Correlation วัดความสัมพันธ์เชิงเส้น ไม่ยืนยันเหตุและผล และอาจพลาดความสัมพันธ์แบบโค้ง

## ป้องกัน Data Leakage

EDA ที่ใช้ตัดสินใจเกี่ยวกับโมเดลควรเน้น Train การดู Test อย่างละเอียดแล้วกลับมาปรับ Features เท่ากับใช้ Test ช่วยพัฒนาโมเดล

> [!IMPORTANT]
> ตรวจความหมายและช่วงค่ากับเจ้าของข้อมูลเสมอ ตัวเลขที่ดูผิดปกติทางสถิติอาจเป็นเหตุการณ์จริงของงาน

## Checklist

- มี Data dictionary และหน่วยของแต่ละคอลัมน์
- ตรวจ Missing, Duplicate, Outlier และค่าที่เป็นไปไม่ได้
- ตรวจ Target distribution และ Class imbalance
- ตรวจข้อมูลซ้ำข้าม Train/Validation/Test
- บันทึกข้อสังเกตและการตัดสินใจทุกครั้ง

## แหล่งอ้างอิง

- [NIST: Exploratory Data Analysis](https://www.itl.nist.gov/div898/handbook/eda/eda.htm)
- [pandas: Descriptive statistics](https://pandas.pydata.org/docs/user_guide/basics.html#descriptive-statistics)

---

[← บทก่อนหน้า: Probability และ Statistics สำหรับ Machine Learning](probability-statistics.md) | [สารบัญ](index.md) | [บทถัดไป: Data Visualization →](data-visualization.md)
