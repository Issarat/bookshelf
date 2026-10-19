# 16. เตรียมข้อมูลจริง: Missing Values และ Category

ข้อมูลจริงมักมีทั้งตัวเลข ข้อความ และค่าว่าง แต่โมเดลส่วนใหญ่ต้องรับข้อมูลตัวเลขที่มีรูปแบบคงที่ จึงต้องเตรียมแต่ละชนิดให้เหมาะสม

```text
ข้อมูลดิบ
├── ตัวเลข → เติมค่าว่าง → ปรับสเกล
└── Category → เติมค่าว่าง → One-hot encode
                         ↓
                       โมเดล
```

## 1. Missing Values

ตัวอย่างค่าว่าง:

| อายุ | เมือง | รายได้ |
|---:|---|---:|
| 25 | Bangkok | 30,000 |
| ว่าง | Chiang Mai | 25,000 |
| 40 | ว่าง | ว่าง |

วิธีพื้นฐาน:

- ตัวเลข: เติมด้วย Median ซึ่งทนต่อ Outlier มากกว่า Mean
- Category: เติมด้วยค่าที่พบบ่อยที่สุด หรือคำว่า `missing`

```python
from sklearn.impute import SimpleImputer

numeric_imputer = SimpleImputer(strategy="median")
category_imputer = SimpleImputer(strategy="most_frequent")
```

> [!IMPORTANT]
> Imputer ต้องเรียนรู้ค่าจาก Train เท่านั้น การใส่ไว้ใน Pipeline ช่วยป้องกัน Data Leakage

## 2. One-Hot Encoding

Feature `city` ที่มีสามค่า:

```text
Bangkok, Chiang Mai, Phuket
```

จะถูกแปลงเป็น:

| city_Bangkok | city_Chiang Mai | city_Phuket |
|---:|---:|---:|
| 1 | 0 | 0 |
| 0 | 1 | 0 |
| 0 | 0 | 1 |

```python
from sklearn.preprocessing import OneHotEncoder

encoder = OneHotEncoder(
    handle_unknown="ignore",
)
```

`handle_unknown="ignore"` ช่วยให้ระบบทำนายข้อมูลที่พบ Category ใหม่ได้โดยไม่หยุดด้วย Error แต่ควรติดตามว่า Category ใหม่เกิดบ่อยเพียงใด

## 3. ColumnTransformer

`ColumnTransformer` ใช้ขั้นตอนต่างกันตามกลุ่มคอลัมน์:

```python
from sklearn.compose import ColumnTransformer
from sklearn.impute import SimpleImputer
from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import OneHotEncoder, StandardScaler

numeric_features = ["age", "income", "usage_count"]
category_features = ["city", "plan"]

numeric_pipeline = make_pipeline(
    SimpleImputer(strategy="median"),
    StandardScaler(),
)

category_pipeline = make_pipeline(
    SimpleImputer(strategy="most_frequent"),
    OneHotEncoder(handle_unknown="ignore"),
)

preprocessor = ColumnTransformer([
    ("numeric", numeric_pipeline, numeric_features),
    ("category", category_pipeline, category_features),
])
```

## 4. Pipeline แบบครบขั้นตอน

```python
import pandas as pd
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import train_test_split
from sklearn.pipeline import make_pipeline

df = pd.DataFrame({
    "age": [25, None, 40, 31, 52, 28, 45, 36],
    "income": [30000, 25000, None, 42000, 65000, 28000, 52000, 39000],
    "usage_count": [3, 5, 12, 8, 20, 4, 16, 7],
    "city": ["Bangkok", "Chiang Mai", None, "Bangkok", "Phuket", "Bangkok", "Phuket", "Chiang Mai"],
    "plan": ["basic", "basic", "premium", "basic", "premium", "basic", "premium", "basic"],
    "churn": [1, 1, 0, 0, 0, 1, 0, 0],
})

X = df.drop(columns="churn")
y = df["churn"]

X_train, X_test, y_train, y_test = train_test_split(
    X,
    y,
    test_size=0.25,
    stratify=y,
    random_state=42,
)

model = make_pipeline(
    preprocessor,
    LogisticRegression(max_iter=1000, random_state=42),
)

model.fit(X_train, y_train)
predictions = model.predict(X_test)
print(predictions)
```

เมื่อเรียก `fit()` Pipeline จะเรียนรู้ Median, Category, Scale และโมเดลจาก Train ตามลำดับ เมื่อเรียก `predict()` จะนำค่าที่เรียนรู้แล้วไปแปลงข้อมูลใหม่

## 5. สิ่งที่ต้องตรวจ

- ค่าว่างหมายถึง “ไม่ทราบ” หรือมีความหมายทางธุรกิจอื่น
- Category เป็นแบบไม่มีลำดับหรือมีลำดับ
- Category ที่มีค่าหลากหลายมากอาจทำให้จำนวนคอลัมน์เพิ่มมาก
- ชื่อและชนิดคอลัมน์ตอนทำนายต้องตรงกับตอน Train
- ห้าม `fit_transform()` ข้อมูลทั้งหมดก่อนแบ่ง Train/Test

## 6. แหล่งอ้างอิง

- [scikit-learn: Pipelines and composite estimators](https://scikit-learn.org/stable/modules/compose.html)
- [scikit-learn: Imputation of missing values](https://scikit-learn.org/stable/modules/impute.html)
- [scikit-learn: OneHotEncoder](https://scikit-learn.org/stable/modules/generated/sklearn.preprocessing.OneHotEncoder.html)

---

[← บทก่อนหน้า: Pipeline ช่วยทำขั้นตอนให้ถูกลำดับ](pipeline.md) · [สารบัญ](index.md) · [บทถัดไป: Outliers: ค่าที่ห่างจากข้อมูลส่วนใหญ่ →](outliers.md)
