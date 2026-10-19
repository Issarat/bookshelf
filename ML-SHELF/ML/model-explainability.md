# 27. อธิบายผลโมเดล

การอธิบายโมเดลช่วยตอบสองคำถาม:

1. โมเดลใช้ Features ใดมาก?
2. เมื่อ Feature เปลี่ยน คำทำนายมีแนวโน้มเปลี่ยนอย่างไร?

คำอธิบายเหล่านี้แสดงพฤติกรรมของโมเดล ไม่ได้พิสูจน์ว่า Feature เป็นสาเหตุของ Target

## 1. Feature Importance จากโมเดล

โมเดลต้นไม้มี `feature_importances_`:

```python
import pandas as pd

importance = pd.Series(
    model.feature_importances_,
    index=X_valid.columns,
).sort_values(ascending=False)

print(importance)
```

วิธีนี้คำนวณเร็ว แต่ Importance แบบ Impurity อาจให้ความสำคัญกับ Feature ที่มีค่าหลากหลายมาก

## 2. Permutation Importance

แนวคิดคือสลับค่าของ Feature หนึ่งให้ความสัมพันธ์กับ Target หายไป แล้วดูว่าคะแนนโมเดลลดลงเท่าไร:

$$
I_j=s-\frac{1}{K}\sum_{k=1}^{K}s_{k,j}
$$

- $s$ คือคะแนนก่อนสลับ
- $s_{k,j}$ คือคะแนนรอบที่ $k$ หลังสลับ Feature $j$
- คะแนนลดลงมากหมายถึงโมเดลพึ่ง Feature นั้นมาก

```python
import pandas as pd
from sklearn.inspection import permutation_importance

result = permutation_importance(
    model,
    X_valid,
    y_valid,
    scoring="f1",
    n_repeats=20,
    random_state=42,
)

importance = pd.Series(
    result.importances_mean,
    index=X_valid.columns,
).sort_values(ascending=False)

print(importance)
```

> [!IMPORTANT]
> ควรตรวจว่าโมเดลมีคะแนน Validation ที่มีประโยชน์ก่อนตีความ Importance โมเดลที่ทำนายไม่ดีไม่มีพฤติกรรมที่ควรเชื่อถือมากนัก

## 3. Features ที่สัมพันธ์กัน

ถ้า Features สองตัวให้ข้อมูลคล้ายกัน เมื่อสลับตัวหนึ่ง โมเดลอาจยังใช้อีกตัวแทนได้ ทำให้ Importance ของทั้งคู่ดูต่ำกว่าความสำคัญรวม

ตัวอย่าง:

```text
อายุเป็นวัน ↔ อายุเป็นเดือน
พื้นที่ตารางเมตร ↔ พื้นที่ตารางวา
```

ต้องตรวจ Correlation และความหมายของ Features ร่วมด้วย

## 4. Partial Dependence

Partial Dependence แสดงค่าทำนายเฉลี่ยเมื่อกำหนด Feature หนึ่งให้เปลี่ยนไปตามช่วงค่า:

```python
from sklearn.inspection import PartialDependenceDisplay

PartialDependenceDisplay.from_estimator(
    model,
    X_valid,
    features=["age", "usage_count"],
)
```

กราฟช่วยดูแนวโน้ม เช่น อายุสมาชิกเพิ่มแล้วความเสี่ยงยกเลิกที่โมเดลทำนายลดลงหรือไม่

> [!CAUTION]
> Partial Dependence อาจสร้างชุดค่าที่แทบไม่เกิดจริงเมื่อ Features สัมพันธ์กันสูง จึงต้องอ่านร่วมกับการกระจายของข้อมูล

## 5. SHAP ควรเรียนเมื่อไร?

SHAP ใช้อธิบายผลของ Features ต่อคำทำนายแต่ละแถวได้ละเอียด แต่ควรเรียนหลังเข้าใจ:

- Baseline prediction
- Feature Importance
- ความสัมพันธ์ระหว่าง Features
- ความต่างระหว่าง Association และ Causation

SHAP ไม่ได้เปลี่ยนความสัมพันธ์ที่โมเดลเรียนรู้ให้กลายเป็นเหตุและผล

## 6. Checklist

- ประเมินโมเดลก่อนอธิบาย
- ใช้ข้อมูล Validation หรือ Test ที่เหมาะสม
- ระบุ Metric ของ Permutation Importance
- ตรวจ Features ที่สัมพันธ์กัน
- เปรียบเทียบคำอธิบายกับความรู้ของงาน
- ห้ามตีความ Importance เป็น Causation

## 7. แหล่งอ้างอิง

- [scikit-learn: Permutation feature importance](https://scikit-learn.org/stable/modules/permutation_importance.html)
- [scikit-learn: Partial Dependence and ICE](https://scikit-learn.org/stable/modules/partial_dependence.html)

---

[← บทก่อนหน้า: Deep Learning](deep-learning.md) · [สารบัญ](index.md) · [บทถัดไป: Time Series และ Forecasting →](time-series.md)
