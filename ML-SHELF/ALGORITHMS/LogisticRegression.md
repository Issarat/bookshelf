# Logistic Regression

Logistic Regression เป็นโมเดลสำหรับ **Classification** แม้ชื่อจะมีคำว่า Regression ก็ตาม โมเดลคำนวณความน่าจะเป็นของแต่ละคลาส แล้วใช้ Threshold เปลี่ยนความน่าจะเป็นเป็นคำตอบ

ตัวอย่างโจทย์:

- ลูกค้าจะยกเลิกหรือไม่
- อีเมลเป็น Spam หรือไม่
- ธุรกรรมเป็นการทุจริตหรือไม่

## 1. จาก Features ไปเป็นคะแนน

โมเดลเริ่มจากคำนวณคะแนนเชิงเส้น:

$$
s=w_1x_1+w_2x_2+\cdots+w_px_p+b
$$

| สัญลักษณ์ | ความหมาย |
|---|---|
| $x_j$ | Feature ตัวที่ $j$ |
| $w_j$ | Weight ของ Feature ตัวที่ $j$ |
| $b$ | Bias |
| $s$ | คะแนนที่ยังไม่ใช่ความน่าจะเป็น |

คะแนน $s$ เป็นได้ตั้งแต่ลบมากถึงบวกมาก จึงต้องแปลงให้อยู่ระหว่าง 0 ถึง 1

## 2. Sigmoid เปลี่ยนคะแนนเป็นความน่าจะเป็น

$$
p=\sigma(s)=\frac{1}{1+e^{-s}}
$$

โดย $p$ คือค่าประมาณของ $P(y=1\mid X)$

| คะแนน $s$ | ความน่าจะเป็น $p$ โดยประมาณ |
|---:|---:|
| -2 | 0.119 |
| 0 | 0.500 |
| 2 | 0.881 |

```python
import numpy as np

def sigmoid(score):
    return 1 / (1 + np.exp(-score))

for score in [-2, 0, 2]:
    print(score, round(sigmoid(score), 3))
```

## 3. Threshold เปลี่ยน Probability เป็น Class

เมื่อใช้ Threshold เท่ากับ 0.5:

$$
\hat{y}=\begin{cases}
1 & \text{เมื่อ }p\ge0.5\\
0 & \text{เมื่อ }p<0.5
\end{cases}
$$

```text
p = 0.78 → ทำนายคลาส 1
p = 0.32 → ทำนายคลาส 0
```

การลด Threshold มักเพิ่ม Recall ของคลาส 1 แต่ทำให้ False Positives เพิ่มขึ้น จึงควรเลือก Threshold จาก Validation ตามต้นทุนของความผิดพลาด

## 4. โมเดลเรียนรู้ Weight อย่างไร?

โมเดลพยายามทำให้ Log Loss ต่ำลง สำหรับข้อมูลหนึ่งแถว:

$$
L=-\left[y\log(p)+(1-y)\log(1-p)\right]
$$

- ถ้า $y=1$ โมเดลเสียค่าปรับมากเมื่อ $p$ เข้าใกล้ 0
- ถ้า $y=0$ โมเดลเสียค่าปรับมากเมื่อ $p$ เข้าใกล้ 1
- การทำนายถูกและมั่นใจทำให้ Loss ต่ำ

ค่าเฉลี่ยของทุกแถวคือ:

$$
\operatorname{LogLoss}
=-\frac{1}{n}\sum_{i=1}^{n}
\left[y_i\log(p_i)+(1-y_i)\log(1-p_i)\right]
$$

## 5. ตัวอย่าง Classification แบบครบขั้นตอน

```python
from sklearn.datasets import make_classification
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import classification_report, confusion_matrix
from sklearn.model_selection import train_test_split
from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler

SEED = 42

X, y = make_classification(
    n_samples=1000,
    n_features=8,
    n_informative=5,
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

model = make_pipeline(
    StandardScaler(),
    LogisticRegression(random_state=SEED),
)

model.fit(X_train, y_train)
predictions = model.predict(X_test)

print(confusion_matrix(y_test, predictions))
print(classification_report(y_test, predictions))
```

ใช้ `StandardScaler` ภายใน Pipeline เพื่อให้แต่ละ Feature อยู่ในสเกลที่เหมาะสม และป้องกัน Data Leakage ระหว่างการประเมินแบบ Cross-validation

## 6. ดู Probability และปรับ Threshold

```python
from sklearn.metrics import precision_score, recall_score

probabilities = model.predict_proba(X_test)[:, 1]

for threshold in [0.30, 0.50, 0.70]:
    predictions = (probabilities >= threshold).astype(int)
    precision = precision_score(y_test, predictions, zero_division=0)
    recall = recall_score(y_test, predictions, zero_division=0)

    print(
        "threshold=", threshold,
        "precision=", round(precision, 3),
        "recall=", round(recall, 3),
    )
```

> [!CAUTION]
> ห้ามลอง Threshold หลายค่าบน Test แล้วเลือกค่าที่ดีที่สุด เพราะ Test จะเข้ามาช่วยตัดสินใจ ให้เลือกด้วย Validation หรือ Cross-validation แล้วประเมิน Test เพียงครั้งสุดท้าย

## 7. Regularization และค่า `C`

Logistic Regression ใช้ Regularization เพื่อลด Weight ที่ใหญ่เกินไป ใน scikit-learn ค่า `C` เป็นค่ากลับของความแรง Regularization:

$$
C=\frac{1}{\lambda}
$$

| ค่า `C` | ผลโดยทั่วไป |
|---|---|
| เล็ก | Regularization แรง Weight ถูกกดมากขึ้น |
| ใหญ่ | Regularization อ่อน โมเดลยืดหยุ่นมากขึ้น |

```python
model = LogisticRegression(
    C=1.0,
    max_iter=1000,
    random_state=42,
)
```

เลือก `C` ด้วย Validation หรือ Cross-validation ไม่ควรเดาจากคะแนน Train เพียงอย่างเดียว

## 8. อ่านทิศทางของ Weight

สำหรับ Binary Classification:

- Weight เป็นบวก: Feature เพิ่มแล้วโอกาสของคลาส 1 มีแนวโน้มเพิ่ม เมื่อ Feature อื่นคงที่
- Weight เป็นลบ: Feature เพิ่มแล้วโอกาสของคลาส 1 มีแนวโน้มลด
- ขนาด Weight เปรียบเทียบกันง่ายขึ้นเมื่อ Features ถูกปรับสเกลเหมือนกัน

> [!IMPORTANT]
> Weight แสดงความสัมพันธ์ที่โมเดลเรียนรู้ ไม่ได้ยืนยันความเป็นเหตุเป็นผล และ Features ที่สัมพันธ์กันสูงอาจทำให้ Weight เปลี่ยนได้

## 9. Logistic Regression เหมาะเมื่อไร?

เหมาะเมื่อ:

- ต้องการ Baseline ที่ฝึกเร็ว
- ต้องการ Probability
- ความสัมพันธ์กับ Log-odds ค่อนข้างเป็นเส้นตรง
- ต้องการดูทิศทางของ Weight

อาจไม่เหมาะเมื่อรูปแบบซับซ้อนและมีปฏิสัมพันธ์ระหว่าง Features จำนวนมากโดยไม่ได้สร้าง Features เพิ่ม

## 10. Checklist

- แบ่ง Train, Validation และ Test ก่อน
- ใส่ preprocessing ใน Pipeline
- ใช้ `stratify` เมื่อคลาสไม่สมดุล
- ตรวจ Precision, Recall และ F1 เพิ่มจาก Accuracy
- เลือก `C` และ Threshold จาก Validation
- ตรวจ Probability calibration เมื่อใช้ Probability ตัดสินใจเรื่องสำคัญ
- ประเมิน Test หลังเลือกทุกอย่างแล้ว

## 11. แหล่งอ้างอิง

- [scikit-learn: LogisticRegression](https://scikit-learn.org/stable/modules/generated/sklearn.linear_model.LogisticRegression.html)
- [scikit-learn: Tuning the decision threshold](https://scikit-learn.org/stable/modules/classification_threshold.html)
- [scikit-learn: Model evaluation](https://scikit-learn.org/stable/modules/model_evaluation.html)

---

[สารบัญ Machine Learning](../ML/index.md) · [Classification Metrics](../ML/08-classification-metrics.md) · [Decision Tree](DecisionTree.md)
