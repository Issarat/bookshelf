# 6. Data Cleansing และ Missing Data

**Data Cleansing** คือการตรวจและแก้ข้อมูลให้ถูกต้อง สม่ำเสมอ และพร้อมสำหรับการวิเคราะห์หรือสร้างโมเดล งานส่วนใหญ่มักใช้เวลากับขั้นตอนนี้มากกว่าการเลือกโมเดล

```mermaid
flowchart LR
    A[ตรวจ Schema] --> B[แก้ชนิดข้อมูล]
    B --> C[จัดการ Missing]
    C --> D[จัดการ Duplicate]
    D --> E[ทำค่าข้อความให้สม่ำเสมอ]
    E --> F[ตรวจช่วงค่าและ Outliers]
    F --> G[ตรวจผลและบันทึกกฎ]
```

## 1. เริ่มจากกำหนดความหมายของข้อมูล

ก่อนแก้ข้อมูลควรมี Data dictionary อย่างน้อย:

| ข้อมูลที่ต้องรู้ | ตัวอย่าง |
|---|---|
| ชื่อคอลัมน์ | `monthly_income` |
| ความหมาย | รายได้ต่อเดือนก่อนหักภาษี |
| ชนิดข้อมูล | ตัวเลขทศนิยม |
| หน่วย | บาท |
| ค่าที่อนุญาต | มากกว่าหรือเท่ากับ 0 |
| Missing หมายถึง | ลูกค้าไม่ระบุ |
| เวลาที่ข้อมูลพร้อมใช้ | ตอนยื่นใบสมัคร |

ถ้าไม่รู้ความหมายของ Missing หรือหน่วย การเติมค่าทางสถิติอาจทำให้ข้อมูลผิดความหมาย

## 2. ตรวจภาพรวม

```python
import pandas as pd

df = pd.read_csv("customers.csv")

print("Shape:", df.shape)
df.info()
print(df.head())
print(df.describe(include="all").T)
print("Duplicates:", df.duplicated().sum())
print("Missing ratio:")
print(df.isna().mean().sort_values(ascending=False))
```

ควรตรวจตัวอย่างแถวจริงร่วมกับค่ารวม เพราะ Summary อาจไม่แสดงช่องว่าง ข้อความสะกดต่างกัน หรือหน่วยที่ปะปน

## 3. ทำชื่อคอลัมน์ให้สม่ำเสมอ

```python
df.columns = (
    df.columns
    .str.strip()
    .str.lower()
    .str.replace(" ", "_", regex=False)
)
```

ตรวจชื่อซ้ำหลังแปลงเสมอ เพราะ `Customer ID` และ `customer_id` อาจกลายเป็นชื่อเดียวกัน

## 4. แก้ชนิดข้อมูล

```python
df["age"] = pd.to_numeric(df["age"], errors="coerce")
df["signup_date"] = pd.to_datetime(
    df["signup_date"],
    errors="coerce",
)
df["is_active"] = df["is_active"].astype("boolean")
```

`errors="coerce"` เปลี่ยนค่าที่แปลงไม่ได้เป็น Missing จึงต้องนับจำนวนค่าที่เพิ่มเป็น Missing และตรวจสาเหตุ ไม่ควรใช้แล้วมองข้ามข้อมูลที่เสีย

## 5. Missing Data คืออะไร?

Missing อาจปรากฏเป็น `NaN`, `None`, ช่องว่าง หรือรหัสพิเศษ เช่น `-999`, `N/A`, `unknown`

```python
missing_tokens = ["", " ", "N/A", "NA", "null", "unknown", -999]
df = df.replace(missing_tokens, pd.NA)
```

รหัสอย่าง `0` หรือ `unknown` อาจเป็นค่าจริงในบางคอลัมน์ ต้องตรวจตามความหมายก่อนแทนที่

### ประเภทของ Missing

- **MCAR:** หายโดยไม่เกี่ยวกับข้อมูลใด
- **MAR:** การหายสัมพันธ์กับข้อมูลที่สังเกตได้
- **MNAR:** การหายสัมพันธ์กับค่าที่หายเอง เช่นผู้มีรายได้สูงไม่ต้องการระบุรายได้

ประเภทของ Missing มีผลต่อ Bias การเติมค่าธรรมดาไม่สามารถแก้ Bias ทุกกรณีได้

## 6. วัด Missing values

```python
missing_summary = pd.DataFrame(
    {
        "missing_count": df.isna().sum(),
        "missing_percent": df.isna().mean().mul(100),
    }
).sort_values("missing_percent", ascending=False)

print(missing_summary)
```

ควรตรวจ Missing แยกตามเวลา แหล่งข้อมูล หรือกลุ่มผู้ใช้ด้วย เพราะค่าเฉลี่ยรวมอาจซ่อนปัญหาเฉพาะกลุ่ม

## 7. วิธีจัดการ Missing

| วิธี | เหมาะเมื่อ | ความเสี่ยง |
|---|---|---|
| ลบแถว | หายน้อยและสุ่มจริง | สูญเสียข้อมูลและอาจเกิด Bias |
| ลบคอลัมน์ | หายมากและไม่มีประโยชน์ | สูญเสียสัญญาณสำคัญ |
| เติม Median | ตัวเลขมี Outliers | ลดความแปรปรวน |
| เติม Mean | ข้อมูลค่อนข้างสมมาตร | ถูก Outliers ดึง |
| เติม Mode | Category | ทำให้คลาสที่พบบ่อยยิ่งมากขึ้น |
| เติมค่าพิเศษ | Missing มีความหมาย | โมเดลต้องรองรับ Category ใหม่ |
| เพิ่ม Missing indicator | การหายอาจมีข้อมูล | เพิ่ม Features |

```python
df["income_was_missing"] = df["income"].isna().astype(int)
df["income"] = df["income"].fillna(df["income"].median())
df["city"] = df["city"].fillna("missing")
```

ตัวอย่างด้านบนเหมาะกับการสำรวจเท่านั้น ในงาน Machine Learning ต้องหา Median จาก Train ผ่าน Pipeline

## 8. จัดการ Duplicate

```python
duplicate_rows = df[df.duplicated(keep=False)]
print(duplicate_rows)

df = df.drop_duplicates()
```

Duplicate ที่เหมือนทุกคอลัมน์อาจลบได้ แต่หลายธุรกรรมที่เหมือนกันอาจเป็นเหตุการณ์จริง ควรใช้ Business key เช่น `customer_id` กับ `transaction_id` และตรวจ Timestamp ก่อนลบ

ข้อมูลบุคคลเดียวกันที่หลุดข้าม Train และ Validation ทำให้คะแนนสูงเกินจริง แม้แต่ละแถวไม่เหมือนกันทั้งหมด

## 9. ทำข้อความและ Category ให้สม่ำเสมอ

```python
df["city"] = (
    df["city"]
    .astype("string")
    .str.strip()
    .str.lower()
)

city_mapping = {
    "bkk": "bangkok",
    "กรุงเทพ": "bangkok",
    "bangkok ": "bangkok",
}
df["city"] = df["city"].replace(city_mapping)
```

Mapping ควรเก็บเป็นกฎที่ตรวจสอบย้อนกลับได้ ไม่ควรแก้ข้อความด้วยการเดา

## 10. ตรวจช่วงค่าและกฎของงาน

```python
invalid_age = ~df["age"].between(0, 120) & df["age"].notna()
invalid_income = (df["income"] < 0) & df["income"].notna()

print(df.loc[invalid_age, ["customer_id", "age"]])
print(df.loc[invalid_income, ["customer_id", "income"]])
```

การใช้ `clip()` เพื่อบังคับค่าเข้าช่วงอาจซ่อนข้อผิดพลาด ควรแยกข้อมูลผิดออกมาตรวจและเลือกแก้ตามสาเหตุ

## 11. ทำ Missing preprocessing ใน Pipeline

```python
from sklearn.compose import ColumnTransformer
from sklearn.impute import SimpleImputer
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import OneHotEncoder, StandardScaler

numeric_features = ["age", "income"]
categorical_features = ["city", "job_type"]

numeric_pipeline = Pipeline(
    steps=[
        ("imputer", SimpleImputer(strategy="median", add_indicator=True)),
        ("scaler", StandardScaler()),
    ]
)

categorical_pipeline = Pipeline(
    steps=[
        ("imputer", SimpleImputer(strategy="most_frequent")),
        ("encoder", OneHotEncoder(handle_unknown="ignore")),
    ]
)

preprocessor = ColumnTransformer(
    transformers=[
        ("numeric", numeric_pipeline, numeric_features),
        ("categorical", categorical_pipeline, categorical_features),
    ]
)
```

เมื่อ Pipeline ถูกฝึกใน Cross-validation ค่า Median, Mode และ Scale จะมาจาก Train ของ Fold นั้น ลดความเสี่ยง Data Leakage

## 12. Cleaning กับ Preprocessing ต่างกันอย่างไร?

| Cleaning | Preprocessing สำหรับโมเดล |
|---|---|
| แก้ข้อมูลผิดและรูปแบบไม่สม่ำเสมอ | แปลงข้อมูลให้อัลกอริทึมใช้ได้ |
| แก้หน่วย ชนิดข้อมูล และ Duplicate | Imputation, Encoding และ Scaling |
| กฎมักมาจากความหมายของงาน | ค่าบางส่วนต้องเรียนรู้จาก Train |

บางขั้นตอนทับซ้อนกัน สิ่งสำคัญคือบันทึกว่ากฎใดเป็นกฎตายตัว และค่าใดต้อง `fit` จาก Train

## 13. Validation หลัง Cleaning

```python
required_columns = {"customer_id", "age", "income", "city"}
missing_columns = required_columns - set(df.columns)

assert not missing_columns, f"Missing columns: {missing_columns}"
assert df["customer_id"].notna().all()
assert df["customer_id"].is_unique
assert df["age"].dropna().between(0, 120).all()
```

ควรรายงานจำนวนแถวก่อนและหลัง Cleaning จำนวนค่าที่ถูกแก้ และสัดส่วน Missing เพื่อให้ตรวจสอบย้อนหลังได้

## 14. Checklist

- มี Data dictionary หน่วย และช่วงค่าที่อนุญาต
- เก็บข้อมูลดิบไว้โดยไม่เขียนทับ
- แยกค่าผิดออกจาก Missing ที่เกิดขึ้นจริง
- ตรวจ Duplicate ด้วย Business key
- ตรวจผลของ `errors="coerce"`
- หา Imputation statistics จาก Train เท่านั้น
- ใช้ Pipeline กับขั้นตอนที่ต้องเรียนรู้จากข้อมูล
- บันทึกกฎ Cleaning และจำนวนข้อมูลที่ได้รับผล
- ทดสอบ Schema และกฎสำคัญก่อนฝึกและก่อน Predict

## แหล่งอ้างอิง

- [pandas: Working with missing data](https://pandas.pydata.org/docs/user_guide/missing_data.html)
- [scikit-learn: Imputation of missing values](https://scikit-learn.org/stable/modules/impute.html)
- [scikit-learn: Common pitfalls](https://scikit-learn.org/stable/common_pitfalls.html)

---

[← บทก่อนหน้า: Data Visualization](data-visualization.md) · [สารบัญ](index.md) · [บทถัดไป: Baseline: เกณฑ์ขั้นต่ำสำหรับเปรียบเทียบโมเดล →](baseline.md)
