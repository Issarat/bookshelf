# 11. ROC, Precision–Recall และ Probability Calibration

Classification metrics ที่ Threshold เดียวไม่แสดงพฤติกรรมทุกจุด ROC และ Precision–Recall curves ช่วยเปรียบเทียบหลาย Threshold ส่วน Calibration ตรวจว่า Probability มีความหมายตรงกับเหตุการณ์จริงหรือไม่

## ROC Curve

$$
\mathrm{TPR}=\frac{TP}{TP+FN}
$$

$$
\mathrm{FPR}=\frac{FP}{FP+TN}
$$

ROC curve วาด TPR เทียบกับ FPR ที่ Threshold ต่าง ๆ ส่วน ROC AUC สรุปความสามารถในการจัดอันดับ โดยค่าใกล้ 1 ดีกว่า

## Precision–Recall Curve

$$
\mathrm{Precision}=\frac{TP}{TP+FP},\qquad
\mathrm{Recall}=\frac{TP}{TP+FN}
$$

PR curve มักอ่านประโยชน์ได้ง่ายกว่า ROC เมื่อ Positive class พบได้น้อย เพราะเน้นผลของ Positive predictions โดยตรง

```python
from sklearn.metrics import (
    PrecisionRecallDisplay,
    RocCurveDisplay,
    average_precision_score,
    roc_auc_score,
)

probability = model.predict_proba(X_valid)[:, 1]

print("ROC AUC:", roc_auc_score(y_valid, probability))
print("Average precision:", average_precision_score(y_valid, probability))

RocCurveDisplay.from_predictions(y_valid, probability)
PrecisionRecallDisplay.from_predictions(y_valid, probability)
```

## Calibration

ถ้าโมเดลทำนายประมาณ `0.8` จำนวน 100 ครั้ง โมเดลที่ Calibrate ดีควรพบ Positive ใกล้ 80 ครั้ง

Brier score:

$$
\mathrm{Brier}=\frac{1}{n}\sum_{i=1}^{n}(p_i-y_i)^2
$$

```python
from sklearn.calibration import CalibrationDisplay
from sklearn.metrics import brier_score_loss

print("Brier score:", brier_score_loss(y_valid, probability))
CalibrationDisplay.from_predictions(y_valid, probability, n_bins=10)
```

Brier score ต่ำดีกว่า แต่รวมทั้ง Calibration และความสามารถในการแยกคลาส จึงควรดู Reliability diagram ร่วมด้วย

## เลือก Threshold

เลือกจากต้นทุนของ FP/FN และข้อจำกัดทางธุรกิจ ไม่ควรเลือกจาก Test:

```python
threshold = 0.35
y_pred = (probability >= threshold).astype(int)
```

## Checklist

- ใช้คะแนนหรือ Probability ไม่ใช่คลาส 0/1 ในการวาด Curve
- ดู PR curve เมื่อคลาสไม่สมดุล
- เลือก Threshold จาก Validation
- ประเมิน Threshold ที่เลือกบน Test ครั้งสุดท้าย
- ตรวจ Calibration หาก Probability ถูกใช้คำนวณความเสี่ยงหรือต้นทุน

## แหล่งอ้างอิง

- [scikit-learn: Model evaluation](https://scikit-learn.org/stable/modules/model_evaluation.html)
- [scikit-learn: Probability calibration](https://scikit-learn.org/stable/modules/calibration.html)

---

[← บทก่อนหน้า: วัดผลโมเดล Classification อย่างไร?](10-classification-metrics.md) · [สารบัญ](index.md) · [บทถัดไป: Underfitting และ Overfitting →](12-underfitting-overfitting.md)
