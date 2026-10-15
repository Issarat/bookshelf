# 5. Baseline: เกณฑ์ขั้นต่ำสำหรับเปรียบเทียบโมเดล

**Baseline** คือวิธีทำนายแบบง่ายที่ใช้เป็นจุดอ้างอิงก่อนทดลองโมเดลจริง ช่วยตอบคำถามว่า:

> โมเดลที่ซับซ้อนขึ้นทำนายได้ดีกว่าวิธีง่าย ๆ จริงหรือไม่?

ถ้าโมเดลยังทำคะแนนไม่ดีกว่า Baseline ควรตรวจข้อมูล Features วิธีแบ่งข้อมูล Metric และขั้นตอนการฝึกก่อนนำโมเดลไปใช้

## 1. Baseline ไม่จำเป็นต้องใช้ Features

Baseline พื้นฐานอาจดูเพียงการกระจายของ Target เช่น:

- Regression: ทายค่าเฉลี่ยหรือค่ามัธยฐานทุกแถว
- Classification: ทายคลาสที่พบบ่อยที่สุดทุกแถว
- Time series: ทายว่าค่าถัดไปเท่ากับค่าล่าสุด

Baseline จึงไม่ได้มีเป้าหมายเพื่อเป็นโมเดลที่ดีที่สุด แต่ใช้ตรวจว่าโมเดลจริงสร้างประโยชน์เพิ่มขึ้นเพียงใด

## 2. Baseline สำหรับ Regression

### ทายค่าเฉลี่ย

ถ้า Target ใน Train มี $n$ ค่า ค่าเฉลี่ยคือ:

$$
\bar{y}_{\text{train}}=\frac{1}{n}\sum_{i=1}^{n}y_i
$$

Baseline จะทำนายทุกแถวด้วยค่าเดียวกัน:

$$
\hat{y}_i=\bar{y}_{\text{train}}
$$

สมมติราคาบ้านใน Train คือ `2.0, 2.5, 3.0, 3.5, 4.0` ล้านบาท:

$$
\bar{y}_{\text{train}}
=\frac{2.0+2.5+3.0+3.5+4.0}{5}
=3.0
$$

Baseline จึงทำนายบ้านทุกหลังเป็น 3 ล้านบาท

| ค่าจริง | ค่าที่ Baseline ทำนาย | ความผิดพลาด |
|---:|---:|---:|
| 2.2 | 3.0 | 0.8 |
| 3.4 | 3.0 | 0.4 |
| 4.1 | 3.0 | 1.1 |

### ทายค่ามัธยฐาน

ถ้าข้อมูลมี Outliers ค่ามัธยฐานอาจเป็น Baseline ที่เหมาะกว่า เช่น Target `2, 3, 4, 5, 100` มีค่าเฉลี่ย `22.8` แต่ค่ามัธยฐานเท่ากับ `4`

## 3. ตัวอย่าง `DummyRegressor`

```python
from sklearn.dummy import DummyRegressor
from sklearn.metrics import mean_absolute_error, root_mean_squared_error
from sklearn.model_selection import train_test_split

X = [[50], [60], [70], [80], [90], [100], [110], [120]]
y = [1.5, 1.8, 2.0, 2.4, 2.8, 3.1, 3.4, 3.8]

X_train, X_valid, y_train, y_valid = train_test_split(
    X,
    y,
    test_size=0.25,
    random_state=42,
)

baseline = DummyRegressor(strategy="mean")
baseline.fit(X_train, y_train)
y_pred = baseline.predict(X_valid)

print("ค่าคงที่ที่ใช้ทำนาย:", baseline.constant_)
print("MAE:", mean_absolute_error(y_valid, y_pred))
print("RMSE:", root_mean_squared_error(y_valid, y_pred))
```

`DummyRegressor` มี Strategy ที่ใช้บ่อย:

| Strategy   | วิธีทำนาย           | เหมาะเมื่อ                              |
| ---------- | ------------------- | --------------------------------------- |
| `mean`     | ค่าเฉลี่ยของ Train  | ต้องการ Baseline ทั่วไป                 |
| `median`   | ค่ามัธยฐานของ Train | Target มี Outliers                      |
| `quantile` | Quantile ที่กำหนด   | สนใจค่าตำแหน่งอื่น เช่น 90th percentile |
| `constant` | ค่าคงที่ที่กำหนดเอง | มีค่ามาตรฐานจากงานอยู่แล้ว              |

> [!IMPORTANT]
> ค่าเฉลี่ยหรือค่ามัธยฐานต้องคำนวณจาก Train เท่านั้น หากรวม Validation หรือ Test ก่อนคำนวณจะเกิด Data Leakage

## 4. Baseline สำหรับ Classification

สมมติมีข้อมูล 100 แถว:

- ไม่โกง 90 แถว
- โกง 10 แถว

Baseline แบบเลือกคลาสที่พบบ่อยที่สุดจะทายทุกแถวว่า “ไม่โกง” และได้ Accuracy:

$$
\mathrm{Accuracy}=\frac{90}{100}=90\%
$$

Accuracy ดูสูง แต่ Recall ของคลาส “โกง” เท่ากับ 0 เพราะตรวจไม่พบคนโกงเลย ตัวอย่างนี้แสดงว่าต้องเลือก Metric ให้ตรงกับปัญหา

## 5. ตัวอย่าง `DummyClassifier`

```python
from sklearn.dummy import DummyClassifier
from sklearn.metrics import classification_report
from sklearn.model_selection import train_test_split

X = [[i] for i in range(20)]
y = [0] * 16 + [1] * 4

X_train, X_valid, y_train, y_valid = train_test_split(
    X,
    y,
    test_size=0.30,
    random_state=42,
    stratify=y,
)

baseline = DummyClassifier(strategy="most_frequent")
baseline.fit(X_train, y_train)
y_pred = baseline.predict(X_valid)

print(classification_report(y_valid, y_pred, zero_division=0))
```

`DummyClassifier` มี Strategy ที่ใช้บ่อย:

| Strategy | วิธีทำนาย |
|---|---|
| `most_frequent` | เลือกคลาสที่พบมากที่สุดเสมอ |
| `prior` | `predict` เลือกคลาสที่พบบ่อย และ `predict_proba` คืนสัดส่วนคลาส |
| `stratified` | สุ่มตามสัดส่วนคลาสใน Train |
| `uniform` | สุ่มทุกคลาสด้วยโอกาสเท่ากัน |
| `constant` | เลือกคลาสที่กำหนดเองเสมอ |

การสุ่มอาจให้ผลต่างกันในแต่ละรอบ จึงควรกำหนด `random_state` เมื่อใช้ Strategy ที่มีการสุ่ม

## 6. เปรียบเทียบอย่างยุติธรรม

Baseline และโมเดลจริงต้องใช้:

1. Train และ Validation ชุดเดียวกัน
2. Cross-validation Folds ชุดเดียวกัน
3. Preprocessing ที่เหมาะกับแต่ละโมเดล
4. Metric เดียวกัน

ตัวอย่างผล Regression:

| โมเดล | RMSE |
|---|---:|
| Baseline ทายค่าเฉลี่ย | 850,000 |
| Linear Regression | 620,000 |
| Random Forest | 410,000 |

RMSE ยิ่งต่ำยิ่งดี Random Forest จึงลดความผิดพลาดจาก Baseline ได้มากที่สุดในตัวอย่างนี้

สำหรับ Metric ที่ยิ่งต่ำยิ่งดี เช่น MAE และ RMSE คำนวณการพัฒนาได้ว่า:

$$
\text{Improvement (\%)}=
\frac{\text{Baseline score}-\text{Model score}}
{\text{Baseline score}}\times100
$$

จากตัวอย่าง Random Forest:

$$
\frac{850{,}000-410{,}000}{850{,}000}\times100
\approx51.8\%
$$

## 7. Baseline สำหรับ Time Series

Time series ต้องรักษาลำดับเวลา Baseline ที่พบบ่อยคือ **Naive forecast** ซึ่งทายว่าค่าถัดไปเท่ากับค่าล่าสุด:

$$
\hat{y}_t=y_{t-1}
$$

```python
import pandas as pd

data = pd.DataFrame({"sales": [100, 120, 115, 130, 128]})
data["baseline_prediction"] = data["sales"].shift(1)

print(data)
```

ถ้าข้อมูลมีฤดูกาล อาจใช้ค่าจากฤดูกาลก่อน เช่นยอดขายวันจันทร์นี้เทียบกับวันจันทร์ที่แล้ว:

$$
\hat{y}_t=y_{t-s}
$$

$s$ คือความยาวของฤดูกาล เช่น $s=7$ สำหรับรูปแบบรายสัปดาห์ของข้อมูลรายวัน

## 8. อ่านผล Baseline อย่างไร

- **โมเดลดีกว่า Baseline ชัดเจน:** Features น่าจะมีข้อมูลที่ช่วยทำนาย
- **โมเดลใกล้เคียง Baseline:** Features อาจมีข้อมูลน้อย โมเดลอาจยังไม่เหมาะ หรือขั้นตอนประเมินอาจมีปัญหา
- **โมเดลแย่กว่า Baseline:** ตรวจโค้ด Data Leakage การแบ่งข้อมูล Metric และ Hyperparameters
- **คะแนนทั้งคู่สูงผิดปกติ:** ตรวจว่ามี Target Leakage หรือข้อมูลซ้ำข้ามชุดหรือไม่

Baseline เป็นเพียงเกณฑ์ขั้นต่ำ การชนะ Baseline ไม่ได้แปลว่าโมเดลพร้อมใช้งาน ต้องตรวจความเสถียร ต้นทุนของข้อผิดพลาด และผลกับข้อมูลใหม่ด้วย

## 9. Checklist

- สร้าง Baseline ก่อนทดลองโมเดลซับซ้อน
- คำนวณค่าของ Baseline จาก Train เท่านั้น
- ใช้ข้อมูลและ Metric เดียวกับโมเดลจริง
- Classification ที่คลาสไม่สมดุลต้องดูมากกว่า Accuracy
- Time series ต้องแบ่งข้อมูลตามเวลา
- บันทึกคะแนน Baseline ไว้ในรายงานการทดลอง
- ตรวจว่าความต่างจาก Baseline มากพอที่จะมีประโยชน์กับงานจริง

## แหล่งอ้างอิง

- [scikit-learn: Dummy estimators](https://scikit-learn.org/stable/modules/model_evaluation.html#dummy-estimators)
- [scikit-learn: DummyRegressor](https://scikit-learn.org/stable/modules/generated/sklearn.dummy.DummyRegressor.html)
- [scikit-learn: DummyClassifier](https://scikit-learn.org/stable/modules/generated/sklearn.dummy.DummyClassifier.html)

---

[← บทก่อนหน้า: Exploratory Data Analysis (EDA)](04-eda.md) · [สารบัญ](index.md) · [บทถัดไป: จะรู้ได้อย่างไรว่าทำนายราคาพลาดแค่ไหน? →](06-mse-rmse.md)
