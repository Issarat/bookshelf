# 23. Feature Engineering

Feature Engineering คือการเปลี่ยนข้อมูลดิบให้เป็นข้อมูลที่ช่วยให้โมเดลเห็นรูปแบบของปัญหาได้ชัดขึ้น

ตัวอย่าง:

```text
วันที่สมัคร 2025-01-10
        ↓
อายุสมาชิก ณ วันทำนาย = 9 เดือน
```

## 1. Features จากวันที่

```python
import pandas as pd

df = pd.DataFrame({
    "order_date": pd.to_datetime([
        "2026-01-05",
        "2026-02-14",
        "2026-03-20",
    ])
})

df["order_month"] = df["order_date"].dt.month
df["day_of_week"] = df["order_date"].dt.dayofweek
df["is_weekend"] = df["day_of_week"].isin([5, 6]).astype(int)
```

อย่าส่งวันที่เป็นข้อความดิบเข้าโมเดลโดยไม่กำหนดว่าต้องการให้โมเดลเรียนรู้อะไรจากวันที่นั้น

## 2. อัตราส่วน

อัตราส่วนอาจสื่อความหมายดีกว่าค่าดิบ:

$$
\text{utilization}
=\frac{\text{ยอดใช้เครดิต}}
{\text{วงเงินเครดิต}}
$$

```python
df["credit_utilization"] = (
    df["credit_used"] / df["credit_limit"]
)
```

ต้องจัดการกรณีตัวหารเป็นศูนย์ และตรวจว่า Numerator กับ Denominator มีอยู่แล้ว ณ เวลาทำนาย

## 3. Features ย้อนหลัง

ตัวอย่างทำนายวันที่ 1 ตุลาคม:

- `usage_last_7_days` ใช้ข้อมูล 24–30 กันยายน
- `usage_last_30_days` ใช้ข้อมูล 1–30 กันยายน
- ห้ามรวมข้อมูลหลังวันที่ 1 ตุลาคม

```python
df = df.sort_values(["customer_id", "event_date"])

df["amount_last_3_events"] = (
    df.groupby("customer_id")["amount"]
      .transform(lambda s: s.shift(1).rolling(3).sum())
)
```

`shift(1)` ทำให้แถวปัจจุบันไม่เข้าไปอยู่ในผลรวมย้อนหลัง จึงช่วยป้องกันการเห็นข้อมูลของเหตุการณ์ที่กำลังทำนาย

## 4. Interaction Features

บางครั้งผลของ Feature หนึ่งขึ้นอยู่กับอีก Feature:

$$
x_{\text{interaction}}=x_1x_2
$$

```python
df["area_x_location_score"] = (
    df["area"] * df["location_score"]
)
```

โมเดลต้นไม้มักเรียนรู้ Interaction ได้เองบางส่วน ส่วนโมเดลเชิงเส้นอาจได้ประโยชน์จากการสร้าง Interaction อย่างตั้งใจ

## 5. Fit Transformation จาก Train เท่านั้น

ขั้นตอนต่อไปนี้ต้องเรียนรู้จาก Train:

- ค่าเฉลี่ยและส่วนเบี่ยงเบนมาตรฐาน
- Median สำหรับเติม Missing values
- รายการ Category
- ช่วงสำหรับแบ่ง Bin
- Target encoding

จึงควรใส่ Transformer ที่เรียนรู้ค่าลงใน Pipeline

## 6. ประเมินว่า Feature ใหม่ช่วยจริงหรือไม่

ใช้การทดลองแบบเดิมทุกอย่าง แล้วเปลี่ยนเฉพาะชุด Features:

```text
Baseline features → CV score A
เพิ่ม feature ใหม่ → CV score B
```

ตรวจทั้งคะแนน ความสม่ำเสมอระหว่าง Folds และความเป็นไปได้ที่จะคำนวณ Feature ตอนใช้งานจริง

## 7. Checklist ป้องกัน Leakage

- Feature นี้มีอยู่จริงตอน Predict หรือไม่
- ใช้ข้อมูลหลังเวลาทำนายหรือไม่
- ใช้ Target สร้าง Feature หรือไม่
- Aggregate ข้าม Train/Validation หรือไม่
- ลูกค้าคนเดียวกันรั่วข้ามชุดหรือไม่
- คำนวณ Feature แบบเดียวกันตอน Train และ Production หรือไม่

## 8. แหล่งอ้างอิง

- [scikit-learn: Preprocessing data](https://scikit-learn.org/stable/modules/preprocessing.html)
- [scikit-learn: Pipelines](https://scikit-learn.org/stable/modules/compose.html#pipeline)
- [scikit-learn: Common pitfalls](https://scikit-learn.org/stable/common_pitfalls.html)

---

[← บทก่อนหน้า: Anomaly Detection](anomaly-detection.md) | [สารบัญ](index.md) | [บทถัดไป: Feature Selection และ PCA →](feature-selection-pca.md)
