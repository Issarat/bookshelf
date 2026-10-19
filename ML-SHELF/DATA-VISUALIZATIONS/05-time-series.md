# 5. Visualization สำหรับข้อมูลตามเวลา

Line chart เชื่อมค่าตามลำดับเวลา จึงเหมาะกับ Trend, Seasonality และเหตุการณ์ที่เกิดตามเวลา

## เตรียมข้อมูล

```python
import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns

sales = pd.DataFrame({
    "date": pd.date_range("2026-01-01", periods=10, freq="D"),
    "sales": [100, 120, 115, 140, 135, 160, 155, 170, 165, 180],
})

sales = sales.sort_values("date")

sns.lineplot(data=sales, x="date", y="sales", marker="o")
plt.xticks(rotation=45)
plt.tight_layout()
plt.show()
```

ต้อง Parse เป็น `datetime` และเรียงเวลาก่อนวาด เส้นเชื่อมตามลำดับแถว หากลำดับผิดกราฟจะวกกลับ

## ตรวจช่วงเวลาที่ขาด

```python
full_dates = pd.date_range(
    sales["date"].min(),
    sales["date"].max(),
    freq="D",
)

missing_dates = full_dates.difference(sales["date"])
print(missing_dates)
```

วันที่ไม่มีแถวอาจหมายถึงยอดเป็นศูนย์ ระบบไม่ทำงาน หรือยังไม่ได้รับข้อมูล ความหมายเหล่านี้ต่างกันและไม่ควรเติมศูนย์โดยอัตโนมัติ

## Aggregate และ Resample

```python
daily = sales.set_index("date")
weekly = daily["sales"].resample("W").sum()

weekly.plot(marker="o")
plt.ylabel("Weekly sales")
plt.show()
```

ต้องเลือก Sum, Mean, Last หรือวิธีอื่นตามความหมาย เช่นยอดขายใช้ Sum แต่อุณหภูมิอาจใช้ Mean

## Rolling average

```python
sales["rolling_mean_3"] = sales["sales"].rolling(3).mean()

sns.lineplot(data=sales, x="date", y="sales", label="Daily")
sns.lineplot(data=sales, x="date", y="rolling_mean_3", label="3-day mean")
plt.show()
```

Rolling ช่วยลด Noise แต่ทำให้การเปลี่ยนแปลงดูช้าลง ต้องระบุ Window และวิธีจัดตำแหน่งให้ชัด

สำหรับ Feature ที่ใช้ทำนาย ต้องเลื่อนอดีตก่อนเพื่อไม่ให้ค่าปัจจุบันรั่วเข้า Feature:

```python
sales["past_rolling_mean_3"] = (
    sales["sales"].shift(1).rolling(3).mean()
)
```

## เปรียบเทียบหลายเส้น

- ใช้สีสม่ำเสมอและไม่ควรมีเส้นจำนวนมาก
- หาก Scale ต่างกันมากให้ใช้ Facet แทนแกน Y สองชุด
- ระบุเหตุการณ์สำคัญด้วยเส้นหรือ Annotation
- อย่าสรุปจากช่วงเวลาสั้นที่เลือกมาเพียงบางส่วน

## Checklist

- Parse และเรียงเวลา
- ตรวจ Timezone และ Frequency
- ตรวจช่วงข้อมูลขาด
- ระบุหน่วยและวิธี Aggregate
- แสดงข้อมูลดิบร่วมกับเส้น Smooth เมื่อเหมาะสม
- ไม่ใช้ข้อมูลอนาคตสร้าง Features

---

[← บทก่อนหน้า](04-relationships.md) | [สารบัญ](index.md) | [บทถัดไป: คุณภาพข้อมูลและ Shift →](06-data-quality-shift.md)
