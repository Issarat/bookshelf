# 24. Class Imbalance และการเลือก Threshold

Class Imbalance เกิดเมื่อจำนวนข้อมูลแต่ละคลาสต่างกันมาก เช่น ธุรกรรมปกติ 990 รายการและทุจริต 10 รายการ

## 1. ทำไม Accuracy อาจหลอกเรา?

ถ้าโมเดลตอบว่า “ปกติ” ทุกครั้ง:

$$
\operatorname{Accuracy}=\frac{990}{1000}=99\%
$$

แต่ Recall ของการทุจริตเท่ากับ 0 เพราะตรวจไม่พบรายการทุจริตเลย

> [!IMPORTANT]
> คะแนนสูงไม่ได้แปลว่าโมเดลมีประโยชน์ ต้องดูว่าโมเดลจับคลาสสำคัญได้หรือไม่

## 2. Metrics ที่ควรดู

| Metric | คำถามที่ตอบ |
|---|---|
| Precision | รายการที่แจ้งเตือน มีของจริงกี่ส่วน? |
| Recall | รายการทุจริตจริง ตรวจพบกี่ส่วน? |
| F1 | สมดุลระหว่าง Precision และ Recall เป็นอย่างไร? |
| PR-AUC | โมเดลรักษา Precision และ Recall ได้ดีเพียงใดเมื่อเปลี่ยน Threshold? |
| ROC-AUC | โมเดลจัดอันดับ Positive สูงกว่า Negative ได้ดีเพียงใด? |

เมื่อ Positive class พบได้น้อย PR curve มักช่วยให้เห็นผลของคลาสสำคัญโดยตรงมากขึ้น

## 3. `class_weight="balanced"`

เพิ่มน้ำหนักให้ความผิดพลาดของคลาสที่พบน้อย:

$$
w_k=\frac{n}{K n_k}
$$

โดย $n$ คือจำนวนข้อมูลทั้งหมด, $K$ คือจำนวนคลาส และ $n_k$ คือจำนวนข้อมูลคลาส $k$

```python
from sklearn.linear_model import LogisticRegression

model = LogisticRegression(
    class_weight="balanced",
    max_iter=1000,
    random_state=42,
)
```

น้ำหนักช่วยให้โมเดลสนใจคลาสส่วนน้อยมากขึ้น แต่ไม่ได้รับประกันว่าทุก Metric จะดีขึ้น ต้องตรวจด้วย Validation

## 4. Threshold เปลี่ยนผลอย่างไร?

```text
Threshold ต่ำ → ทำนาย Positive ง่ายขึ้น → Recall มักสูงขึ้น
Threshold สูง → ทำนาย Positive ยากขึ้น → Precision มักสูงขึ้น
```

```python
import numpy as np
from sklearn.metrics import precision_score, recall_score

probabilities = np.array([0.10, 0.35, 0.55, 0.70, 0.90])
y_true = np.array([0, 1, 0, 1, 1])

for threshold in [0.30, 0.50, 0.70]:
    y_pred = (probabilities >= threshold).astype(int)
    print(
        threshold,
        precision_score(y_true, y_pred, zero_division=0),
        recall_score(y_true, y_pred, zero_division=0),
    )
```

## 5. เลือก Threshold จาก Validation

ตัวอย่างเลือก Threshold ที่ทำให้ Recall อย่างน้อย 80% แล้วเลือก Precision ที่สูงที่สุด:

```python
import numpy as np
from sklearn.metrics import precision_recall_curve

precision, recall, thresholds = precision_recall_curve(
    y_valid,
    valid_probabilities,
)

# precision และ recall ยาวกว่า thresholds อยู่หนึ่งตำแหน่ง
candidates = []
for p, r, t in zip(precision[:-1], recall[:-1], thresholds):
    if r >= 0.80:
        candidates.append((p, r, t))

best_precision, best_recall, best_threshold = max(candidates)
print(best_threshold, best_precision, best_recall)
```

จากนั้นตรึง Threshold นี้แล้วใช้กับ Test เพียงครั้งเดียว

## 6. สิ่งที่ต้องระวัง

- แบ่งข้อมูลด้วย `stratify=y`
- ทำ Resampling ภายใน Train fold เท่านั้น
- ตรวจ Confusion Matrix เป็นจำนวนจริง ไม่ดูแต่เปอร์เซ็นต์
- กำหนดต้นทุน False Positive และ False Negative กับเจ้าของงาน
- ตรวจ Probability calibration หาก Threshold อิงความหมายของ Probability โดยตรง

## 7. แหล่งอ้างอิง

- [scikit-learn: Tuning the decision threshold](https://scikit-learn.org/stable/modules/classification_threshold.html)
- [scikit-learn: Classification metrics](https://scikit-learn.org/stable/modules/model_evaluation.html#classification-metrics)
- [scikit-learn: Computing class weights](https://scikit-learn.org/stable/modules/generated/sklearn.utils.class_weight.compute_class_weight.html)

---

[← บทก่อนหน้า: Search Space: เลือกช่วงค่าที่จะค้นหา](23-search-space.md) · [สารบัญ](index.md) · [บทถัดไป: เปรียบเทียบโมเดลอย่างยุติธรรม →](25-model-comparison.md)
