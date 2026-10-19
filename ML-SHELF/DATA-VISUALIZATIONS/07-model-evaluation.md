# 7. กราฟประเมินโมเดล

กราฟประเมินโมเดลช่วยเห็นรูปแบบความผิดพลาดที่ Metric ค่าเดียวซ่อนไว้

## Regression: Actual vs Predicted

```python
import matplotlib.pyplot as plt
import numpy as np

y_true = np.array([10, 15, 20, 25, 30])
y_pred = np.array([12, 14, 19, 28, 27])

plt.scatter(y_true, y_pred, alpha=0.7)
lower = min(y_true.min(), y_pred.min())
upper = max(y_true.max(), y_pred.max())
plt.plot([lower, upper], [lower, upper], "--", color="black")
plt.xlabel("Actual")
plt.ylabel("Predicted")
plt.show()
```

จุดใกล้เส้นทแยงคือทำนายใกล้ค่าจริง ควรใช้ Scale เท่ากันทั้งสองแกนเพื่อไม่ให้ความคลาดเคลื่อนดูบิดเบือน

## Residual plot

Residual:

$$
e_i=y_i-\hat{y}_i
$$

```python
residual = y_true - y_pred

plt.scatter(y_pred, residual)
plt.axhline(0, linestyle="--", color="black")
plt.xlabel("Predicted")
plt.ylabel("Residual")
plt.show()
```

รูปโค้งอาจบ่งชี้ความสัมพันธ์ที่โมเดลยังจับไม่ได้ ส่วนรูปกรวยอาจบ่งชี้ความแปรปรวนไม่คงที่

## Classification: Confusion matrix

```python
from sklearn.metrics import ConfusionMatrixDisplay

y_true_class = [0, 0, 0, 1, 1, 1]
y_pred_class = [0, 0, 1, 0, 1, 1]

ConfusionMatrixDisplay.from_predictions(
    y_true_class,
    y_pred_class,
    normalize=None,
)
plt.show()
```

ดูทั้งจำนวนจริงและแบบ Normalize โดยเฉพาะเมื่อ Class ไม่สมดุล

## ROC และ Precision–Recall

```python
from sklearn.metrics import PrecisionRecallDisplay, RocCurveDisplay

y_score = [0.05, 0.20, 0.65, 0.40, 0.75, 0.90]

RocCurveDisplay.from_predictions(y_true_class, y_score)
plt.show()

PrecisionRecallDisplay.from_predictions(y_true_class, y_score)
plt.show()
```

PR curve มักให้ข้อมูลชัดกว่า ROC เมื่อ Positive class พบไม่บ่อย ต้องประเมินบนข้อมูลที่ไม่ได้ใช้ Train

## Calibration curve

```python
from sklearn.calibration import CalibrationDisplay

CalibrationDisplay.from_predictions(
    y_true_class,
    y_score,
    n_bins=3,
)
plt.show()
```

Calibration ตรวจว่ากลุ่มที่โมเดลให้ Probability ประมาณ 0.8 เกิด Positive จริงใกล้ 80% หรือไม่ Sample ต่อ Bin ต้องมากพอ

## Learning curve

Learning curve เปรียบเทียบคะแนน Train และ Validation เมื่อเพิ่มจำนวนข้อมูล:

- ทั้งคู่ต่ำ: อาจ Underfitting
- Train สูงแต่ Validation ต่ำ: อาจ Overfitting
- Validation ยังดีขึ้น: ข้อมูลเพิ่มอาจช่วย

ต้องดูความแปรปรวนของแต่ละจุดและใช้ Cross-validation ที่เหมาะกับข้อมูล

## หลักการสำคัญ

- เลือกกราฟตามชนิดงานและต้นทุนความผิดพลาด
- คำนวณจาก Validation/Test ที่เหมาะสม
- แยกดูตามกลุ่มสำคัญเพื่อค้นหาความผิดพลาดเฉพาะกลุ่ม
- รายงาน Metric และจำนวนข้อมูลร่วมกับกราฟ

---

[← บทก่อนหน้า](06-data-quality-shift.md) | [สารบัญ](index.md) | [บทถัดไป: ออกแบบและส่งออก →](08-design-export.md)
