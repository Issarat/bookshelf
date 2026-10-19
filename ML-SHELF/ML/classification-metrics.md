# 10. วัดผลโมเดล Classification อย่างไร?


บทก่อนหน้าทำนายตัวเลข แต่การยกเลิกบริการเป็นการเลือกคำตอบระหว่างสองกลุ่ม เรียกว่า **Classification**

สมมติมีลูกค้า 100 คน โมเดลบอกว่าจะยกเลิก 20 คน ใน 20 คนนี้ยกเลิกจริง 15 คน ขณะที่ทั้งหมดมีผู้ยกเลิกจริง 30 คน จัดเป็นตารางได้ดังนี้:

| | ยกเลิกจริง | ไม่ยกเลิกจริง |
|---|---:|---:|
| ทำนายว่าจะยกเลิก | 15 | 5 |
| ทำนายว่าจะไม่ยกเลิก | 15 | 65 |

## Accuracy: ทายถูกกี่คนจากทุกคน?

ทายถูกคือช่อง 15 คนกับ 65 คน:

$$
\mathrm{Accuracy}=\frac{15+65}{100}=80\%
$$

## Precision: คนที่เราเตือนว่าจะยกเลิก มีใครยกเลิกจริงบ้าง?

โมเดลเตือน 20 คน และเตือนถูก 15 คน:

$$
\mathrm{Precision}=\frac{15}{20}=75\%
$$

## Recall: คนที่ยกเลิกจริง เราตรวจเจอกี่คน?

มีคนยกเลิกจริง 30 คน แต่เราตรวจเจอ 15 คน:

$$
\mathrm{Recall}=\frac{15}{30}=50\%
$$

Precision กับ Recall ต่างกันที่ **เรากำลังมองคนกลุ่มไหนเป็นตัวหาร**

หากข้อมูลมีคนไม่ยกเลิก 95% โมเดลที่ตอบว่า “ไม่ยกเลิก” ทุกคนจะได้ Accuracy 95% แต่ตรวจไม่พบผู้ยกเลิกเลย จึงควรเลือกตัววัดตามสิ่งที่ต้องการทำให้สำเร็จ

## Logistic Regression เกี่ยวข้องอย่างไร?

เป็นโมเดลที่ให้ค่าความน่าจะเป็นสำหรับแต่ละคน เช่น โอกาสยกเลิก 70% แล้วเราเลือกเกณฑ์ตัดสิน หรือ **threshold** เช่น 50%:

**โอกาสตั้งแต่ 50% ขึ้นไป → ทำนายว่าจะยกเลิก**

หากลดเกณฑ์ลง มักตรวจพบผู้ยกเลิกได้มากขึ้น แต่ก็อาจเตือนคนที่ไม่ยกเลิกมากขึ้นด้วย ให้เลือกเกณฑ์จาก Validation ตามเป้าหมายของงาน

## ตัวอย่าง Python: คำนวณ Metrics และใช้ Threshold

```python
import numpy as np
from sklearn.metrics import (
    accuracy_score,
    confusion_matrix,
    f1_score,
    precision_score,
    recall_score,
)

# สร้างข้อมูลให้ตรงกับตารางตัวอย่าง:
# TP=15, FN=15, FP=5, TN=65
y_true = np.array([1] * 30 + [0] * 70)
y_pred = np.array([1] * 15 + [0] * 15 + [1] * 5 + [0] * 65)

print("Confusion matrix:\n", confusion_matrix(y_true, y_pred))
print("Accuracy:", accuracy_score(y_true, y_pred))    # 0.80
print("Precision:", precision_score(y_true, y_pred))  # 0.75
print("Recall:", recall_score(y_true, y_pred))        # 0.50
print("F1:", f1_score(y_true, y_pred))                # 0.60

# เปลี่ยนความน่าจะเป็นเป็นคลาสด้วย Threshold
probabilities = np.array([0.20, 0.70, 0.49, 0.90])
threshold = 0.50
predictions = (probabilities >= threshold).astype(int)
print("Predictions:", predictions)  # [0, 1, 0, 1]
```

ลองเปลี่ยน `threshold` เป็น `0.30` แล้วดูว่าจำนวนที่ทำนายเป็นคลาส 1 เพิ่มขึ้นอย่างไร

---

[← บทก่อนหน้า: Metrics สำหรับ Regression](regression-metrics.md) · [สารบัญ](index.md) · [บทถัดไป: ROC, Precision–Recall และ Probability Calibration →](roc-pr-calibration.md)
