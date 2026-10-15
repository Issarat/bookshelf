# Gradient Boosting

Gradient Boosting คือการสร้างต้นไม้หลายต้นแบบ **ต่อกันเป็นลำดับ** โดยต้นไม้ต้นใหม่พยายามแก้ข้อผิดพลาดที่โมเดลก่อนหน้าทำไว้

```mermaid
flowchart LR
    B["ค่าทำนายเริ่มต้น"] --> T1["Tree 1<br/>แก้ข้อผิดพลาดรอบแรก"]
    T1 --> T2["Tree 2<br/>แก้ข้อผิดพลาดที่เหลือ"]
    T2 --> T3["Tree 3<br/>แก้ต่ออีกเล็กน้อย"]
    T3 --> P["ผลทำนายสุดท้าย"]
```

## 1. ต่างจาก Random Forest อย่างไร?

| หัวข้อ | Random Forest | Gradient Boosting |
|---|---|---|
| การสร้างต้นไม้ | แต่ละต้นค่อนข้างอิสระ | สร้างต่อกันทีละรอบ |
| การรวมผล | เฉลี่ยหรือรวมเสียง | บวกค่าปรับแก้จากทุกต้น |
| เป้าหมาย | ลดความแปรปรวน | ลดข้อผิดพลาดทีละรอบ |
| การฝึกขนาน | ทำได้ง่ายกว่า | ทำได้ยากกว่าเพราะแต่ละรอบพึ่งรอบก่อน |
| การปรับค่า | มักเริ่มต้นง่าย | ต้องระวัง `learning_rate` และจำนวนรอบ |

## 2. แนวคิด Regression แบบทีละขั้น

สมมติ Target จริงคือ:

$$
y=[10,20,30]
$$

โมเดลเริ่มทำนายด้วยค่าเฉลี่ย:

$$
F_0(x)=\bar{y}=20
$$

Residual รอบแรก:

$$
r_1=y-F_0(x)=[-10,0,10]
$$

Tree 1 เรียนรู้ Residual เหล่านี้ แล้วนำค่าปรับแก้มาบวกกับคำทำนายเดิม:

$$
F_1(x)=F_0(x)+\eta h_1(x)
$$

โดย:

- $h_1(x)$ คือคำตอบจากต้นไม้ต้นที่ 1
- $\eta$ คือ `learning_rate`
- ค่า `learning_rate` เล็กทำให้แต่ละต้นแก้ทีละน้อย

สูตรรวมหลังสร้าง $M$ ต้นคือ:

$$
F_M(x)=F_0(x)+\eta\sum_{m=1}^{M}h_m(x)
$$

## 3. `learning_rate` กับจำนวนต้นไม้

สองค่านี้สัมพันธ์กัน:

- `learning_rate` เล็ก มักต้องใช้ต้นไม้มากขึ้น
- `learning_rate` ใหญ่ เรียนรู้เร็ว แต่เสี่ยง Overfitting หรือแก้แรงเกินไป

จุดเริ่มต้นที่ใช้ทดลองได้:

```python
learning_rate=0.05
n_estimators=200
```

ต้องเลือกจาก Validation หรือ Cross-validation

## 4. ตัวอย่าง Classification

```python
from sklearn.datasets import make_classification
from sklearn.ensemble import GradientBoostingClassifier
from sklearn.metrics import classification_report
from sklearn.model_selection import train_test_split

SEED = 42

X, y = make_classification(
    n_samples=1200,
    n_features=10,
    n_informative=6,
    weights=[0.75, 0.25],
    random_state=SEED,
)

X_train, X_test, y_train, y_test = train_test_split(
    X,
    y,
    test_size=0.2,
    stratify=y,
    random_state=SEED,
)

model = GradientBoostingClassifier(
    n_estimators=200,
    learning_rate=0.05,
    max_depth=3,
    random_state=SEED,
)

model.fit(X_train, y_train)
predictions = model.predict(X_test)
print(classification_report(y_test, predictions))
```

## 5. ตัวอย่าง Regression

```python
import numpy as np
from sklearn.datasets import make_regression
from sklearn.ensemble import GradientBoostingRegressor
from sklearn.metrics import mean_squared_error
from sklearn.model_selection import train_test_split

SEED = 42

X, y = make_regression(
    n_samples=1200,
    n_features=8,
    n_informative=5,
    noise=20,
    random_state=SEED,
)

X_train, X_test, y_train, y_test = train_test_split(
    X,
    y,
    test_size=0.2,
    random_state=SEED,
)

model = GradientBoostingRegressor(
    n_estimators=200,
    learning_rate=0.05,
    max_depth=3,
    random_state=SEED,
)

model.fit(X_train, y_train)
predictions = model.predict(X_test)
rmse = np.sqrt(mean_squared_error(y_test, predictions))
print("Test RMSE:", rmse)
```

## 6. HistGradientBoosting

scikit-learn มี `HistGradientBoostingClassifier` และ `HistGradientBoostingRegressor` ซึ่งแบ่งค่าต่อเนื่องเป็นช่วงก่อนสร้างต้นไม้ จึงเหมาะกับข้อมูลจำนวนมากกว่า และรองรับ Missing values โดยตรง

```python
from sklearn.ensemble import HistGradientBoostingClassifier

model = HistGradientBoostingClassifier(
    learning_rate=0.05,
    max_iter=200,
    max_leaf_nodes=31,
    random_state=42,
)
```

สังเกตว่า HistGradientBoosting ใช้ `max_iter` แทน `n_estimators`

## 7. Hyperparameters สำคัญ

| Parameter | หน้าที่ |
|---|---|
| `n_estimators` หรือ `max_iter` | จำนวนรอบที่เพิ่มต้นไม้ |
| `learning_rate` | ขนาดการปรับแก้ในแต่ละรอบ |
| `max_depth` | ความลึกของต้นไม้แต่ละต้น |
| `max_leaf_nodes` | จำนวน Leaf สูงสุด |
| `min_samples_leaf` | จำนวนข้อมูลขั้นต่ำใน Leaf |
| `subsample` | สัดส่วนข้อมูลที่ใช้ในแต่ละรอบสำหรับ GradientBoosting |

## 8. Checklist

- สร้าง Baseline ก่อน
- แยก Test ไว้จนถึงขั้นสุดท้าย
- ปรับ `learning_rate` คู่กับจำนวนรอบ
- ตรวจคะแนน Train และ Validation เพื่อหา Overfitting
- ใช้ Early stopping เมื่อเหมาะสม
- เลือก Metric ให้ตรงกับงาน
- ตรวจ Feature Importance ด้วยข้อมูล Validation

## 9. แหล่งอ้างอิง

- [scikit-learn: Gradient-boosted trees](https://scikit-learn.org/stable/modules/ensemble.html#gradient-boosting)
- [scikit-learn: HistGradientBoostingClassifier](https://scikit-learn.org/stable/modules/generated/sklearn.ensemble.HistGradientBoostingClassifier.html)
- [scikit-learn: GradientBoostingRegressor](https://scikit-learn.org/stable/modules/generated/sklearn.ensemble.GradientBoostingRegressor.html)

---

[สารบัญ Machine Learning](../ML/index.md) · [Decision Tree](DecisionTree.md) · [Random Forest](RandomForest.md)
