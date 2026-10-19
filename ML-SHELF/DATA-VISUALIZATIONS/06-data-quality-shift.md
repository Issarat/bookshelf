# 6. คุณภาพข้อมูลและ Dataset Shift

กราฟช่วยค้นหา Missing values และความแตกต่างระหว่าง Train กับ Validation แต่ต้องดูจำนวนข้อมูลและกระบวนการเก็บข้อมูลร่วมด้วย

## Missing percentage

```python
import matplotlib.pyplot as plt
import pandas as pd

data = pd.DataFrame({
    "age": [20, None, 35, 42],
    "income": [18000, 22000, None, 55000],
    "segment": ["A", "A", "B", None],
})

missing = (
    data.isna().mean().mul(100)
    .sort_values()
)
missing = missing[missing > 0]

missing.plot(kind="barh")
plt.xlabel("Missing values (%)")
plt.show()
```

เปอร์เซ็นต์ควรอ่านร่วมกับจำนวนแถว:

```python
missing_summary = pd.DataFrame({
    "count": data.isna().sum(),
    "percent": data.isna().mean().mul(100),
})
print(missing_summary)
```

## Missing pattern

Heatmap ช่วยดูว่าหลายคอลัมน์หายพร้อมกันหรือไม่:

```python
import seaborn as sns

sns.heatmap(data.isna(), cbar=False, yticklabels=False)
plt.xlabel("Column")
plt.ylabel("Row")
plt.show()
```

สำหรับข้อมูลใหญ่มากควร Sample หรือสรุป Pattern เพราะ Heatmap รายแถวจะช้าและอ่านยาก

## เปรียบเทียบ Train กับ Validation

```python
train = pd.DataFrame({"income": [18, 22, 30, 42, 55]})
valid = pd.DataFrame({"income": [25, 35, 48, 60, 80]})

train_plot = train.assign(dataset="train")
valid_plot = valid.assign(dataset="validation")
comparison = pd.concat([train_plot, valid_plot], ignore_index=True)

sns.histplot(
    data=comparison,
    x="income",
    hue="dataset",
    stat="density",
    common_norm=False,
    element="step",
)
plt.show()
```

ใช้ `common_norm=False` เพื่อ Normalize แต่ละ Dataset แยกกันเมื่อขนาด Sample ต่างกัน

## เปรียบเทียบ Category

```python
train_segment = pd.Series(["A", "A", "B", "C"])
valid_segment = pd.Series(["A", "B", "B", "D"])

category_share = pd.concat(
    {
        "train": train_segment.value_counts(normalize=True),
        "validation": valid_segment.value_counts(normalize=True),
    },
    axis=1,
).fillna(0)

category_share.plot(kind="bar")
plt.ylabel("Proportion")
plt.show()
```

Category `D` ที่พบเฉพาะ Validation อาจทำให้ Encoder หรือโมเดลมีปัญหา จึงต้องตรวจ Unknown category handling

## กราฟต่างกันแปลว่า Drift หรือไม่?

ยังสรุปไม่ได้ ความต่างอาจเกิดจาก:

- Sample เล็ก
- วิธีสุ่มหรือช่วงเวลาต่างกัน
- ระบบเก็บข้อมูลเปลี่ยน
- กลุ่มผู้ใช้เปลี่ยนจริง
- Data Leakage หรือการกรองไม่เหมือนกัน

ควรตรวจสถิติ กระบวนการเก็บข้อมูล และผลต่อ Metrics ร่วมกัน

---

[← บทก่อนหน้า](05-time-series.md) | [สารบัญ](index.md) | [บทถัดไป: กราฟประเมินโมเดล →](07-model-evaluation.md)
