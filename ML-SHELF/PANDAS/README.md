---
title: "pandas Learning Notes"
description: "สารบัญ ลำดับเรียน และแบบฝึกหัดรวมของบท pandas"
tags:
  - python
  - pandas
---

# pandas Learning Notes

บันทึกเรียน pandas พร้อมตัวอย่างที่รันได้และแบบฝึกหัดท้ายบท
แต่ละบทสร้างข้อมูลของตัวเอง ให้เริ่มรันจากส่วนเตรียมข้อมูลของบทนั้น

## ลำดับอ่านที่แนะนำ

| ลำดับ | บท | สิ่งที่จะได้ฝึก |
| --- | --- | --- |
| 1 | [Introduction](Introduction.md) | ภาพรวมและการ import |
| 2 | [Series](Series.md) | ข้อมูลหนึ่งมิติและ index |
| 3 | [DataFrame](DataFrame.md) | ตาราง แถว และคอลัมน์ |
| 4 | [ReadingData](ReadingData.md) | อ่านและบันทึก CSV, Excel, JSON |
| 5 | [Indexing](Indexing.md) | loc, iloc และ Boolean indexing |
| 6 | [QueryAndFilter](QueryAndFilter.md) | เลือกแถวด้วย query และเลือกชื่อด้วย filter |
| 7 | [SummaryFunctions](SummaryFunctions.md) | สถิติและความถี่ |
| 8 | [MissingData](MissingData.md) | ตรวจ ลบ และเติมค่าว่าง |
| 9 | [DataTypes](DataTypes.md) | แปลงตัวเลขและเลือก dtype |
| 10 | [Maps](Maps.md) | map และ apply |
| 11 | [ReplaceAndRenaming](ReplaceAndRenaming.md) | แทนค่า เปลี่ยนชื่อ และ normalize ข้อความ |
| 12 | [DuplicatesAndSorting](DuplicatesAndSorting.md) | ตรวจข้อมูลซ้ำ เรียงข้อมูล และจัด index |
| 13 | [Grouping](Grouping.md) | groupby และ agg |
| 14 | [CombiningData](CombiningData.md) | concat, merge และ join |
| 15 | [Reshaping](Reshaping.md) | pivot, pivot_table, melt และ crosstab |
| 16 | [DateTime](DateTime.md) | วันที่ ช่วงเวลา resample และ rolling |
| 17 | [Plotting](Plotting.md) | กราฟแท่ง เส้น histogram scatter และ box plot |
| 18 | [CleaningData](CleaningData.md) | ขั้นตอนทำความสะอาดข้อมูล พร้อมเหตุผลและการตรวจผล |

## แบบฝึกหัดรวม

ลองสร้างรายงานยอดขายจากสองตาราง: รายการขายและรายละเอียดสินค้า

1. อ่านไฟล์โดยเก็บรหัสสินค้าเป็นข้อความ

```python

```

2. ตรวจชนิดข้อมูล ค่าว่าง และรายการซ้ำ

```python

```

3. จัดชื่อคอลัมน์และหมวดสินค้าให้สม่ำเสมอ

```python

```

4. รวมรายละเอียดสินค้าด้วย merge และตรวจรายการที่จับคู่ไม่ได้

```python

```

5. คำนวณยอดขายจากจำนวนคูณราคาต่อหน่วย

```python

```

6. สรุปยอดตามหมวดและเดือน แล้วทำ pivot_table แยกตามร้าน

```python

```

7. บันทึกรายงานเป็น CSV โดยไม่รวม index

```python

```

8. วาดกราฟยอดขายตามหมวดและแนวโน้มรายเดือน พร้อมบันทึกภาพ

```python

```


เมื่อเรียนพื้นฐานครบแล้ว ค่อยต่อยอดหัวข้อเฉพาะงาน
เช่น MultiIndex หรือการประมวลผลไฟล์ใหญ่เป็น chunks

## เอกสารหลัก

- [กฎการเขียนและแก้ไขเอกสาร](rules/AGENTS.md)
- [มาตรฐาน frontmatter และรูปแบบบทเรียน](rules/Frontmatter.md)

- [pandas User Guide](https://pandas.pydata.org/docs/user_guide/index.html)
