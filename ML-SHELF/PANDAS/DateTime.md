---
title: "DateTime & Time Series"
description: "การแปลงวันเวลา กรองช่วงเวลา และสรุปอนุกรมเวลา"
tags:
  - python
  - pandas
---

# DateTime & Time Series

แปลงข้อความวันที่เป็น datetime ก่อนกรองตามช่วงเวลา
หรือสรุปยอดขายตามวันและเดือน

## 1. แปลงวันที่ด้วย to_datetime

```python
import pandas as pd

sales = pd.DataFrame({
    "date": ["2026-01-01", "2026-01-03", "2026-02-01", "invalid"],
    "amount": [300, 200, 400, 100]
})

sales["sold_at"] = pd.to_datetime(sales["date"], format="%Y-%m-%d", errors="coerce")
print(sales)
```

invalid กลายเป็น NaT ซึ่งเป็นค่าว่างของวันเวลา
format ระบุรูปแบบให้ชัดเจน เช่น %Y คือปี, %m คือเดือน, %d คือวัน
สำหรับข้อมูลวัน/เดือน/ปี ใช้ format="%d/%m/%Y" แทนการเดารูปแบบ

## 2. ดึงส่วนของวันเวลา

```python
sales["year"] = sales["sold_at"].dt.year
sales["month"] = sales["sold_at"].dt.month
sales["weekday"] = sales["sold_at"].dt.dayofweek
print(sales)
```

dayofweek ให้วันจันทร์เป็น 0 และวันอาทิตย์เป็น 6
ต้องใช้ .dt กับข้อมูลวันเวลา ไม่ใช่ข้อความที่ยังไม่แปลง

## 3. กรองช่วงเวลา

```python
start = pd.Timestamp("2026-01-01")
end = pd.Timestamp("2026-02-01")
january = sales.loc[(sales["sold_at"] >= start) & (sales["sold_at"] < end)]
print(january)
```

ใช้ขอบบนแบบไม่รวมเพื่อเลือกทั้งเดือนมกราคม แม้ข้อมูลมีชั่วโมงและนาที

## 4. resample: สรุปตามช่วงเวลา

ตรวจรายการวันที่เสียก่อนแยกข้อมูลที่มีวันเวลามาใช้งาน:

```python
invalid_dates = sales.loc[sales["sold_at"].isna()]
print(invalid_dates)

dated_sales = sales.dropna(subset=["sold_at"]).set_index("sold_at").sort_index()
monthly = dated_sales["amount"].resample("MS").sum()
print(monthly)
# มกราคม: 500, กุมภาพันธ์: 400
```

MS หมายถึงแบ่งรายเดือนโดยป้ายกำกับเป็นวันแรกของเดือน
ข้อมูล amount 100 ที่วันที่เสียยังไม่ถูกรวมในยอดตามเดือน
ต้องแก้วันเวลาของรายการนั้นก่อนหากต้องการยอดที่ครบทั้งหมด

## 5. ระยะเวลาและ rolling

```python
sales["delivery_due"] = sales["sold_at"] + pd.Timedelta(days=3)

daily = dated_sales["amount"].resample("D").sum()
moving_average = daily.rolling(window=3, min_periods=3).mean()
print(moving_average.head())
```

ตัวอย่าง daily ถือว่าวันที่ไม่มีรายการขายมียอดเป็น 0
rolling(window=3) ใช้สามรายการติดกัน ซึ่งใน daily คือสามวัน
min_periods=3 ต้องมีครบสามค่าจึงคำนวณ และสองค่าแรกเป็นค่าว่าง
ถ้าวันที่ขาดหมายถึงยังไม่ได้รับข้อมูล ไม่ควรตีความเป็นยอดขาย 0

## แบบฝึกหัด

1. แปลง date เป็น datetime แล้วแสดงรายการที่แปลงไม่ได้

```python
import pandas as pd

sales = pd.DataFrame({
    "date": ["2026-01-01", "2026-01-03", "2026-02-01", "invalid"],
    "amount": [300, 200, 400, 100]
})

sales["sold_at"] = pd.to_datetime(sales["date"], format="%Y-%m-%d", errors="coerce")
print(sales)
```

2. กรองเฉพาะยอดขายเดือนมกราคม

```python
print(sales[sales["sold_at"].dt.month == 1])
```

3. รวม amount รายเดือนด้วย resample("MS")

```python

```

4. เพิ่มวันครบกำหนดส่งของหลังขาย 7 วัน

```python

```

5. ตรวจว่ายอดตามเดือนต่างจากยอดทั้งหมดเท่าไร และอธิบายสาเหตุ

```python

```


## แหล่งอ้างอิง

- [pandas: Time series / date functionality](https://pandas.pydata.org/docs/user_guide/timeseries.html)
