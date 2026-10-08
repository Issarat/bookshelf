---
title: "bookshelf"
description: "คลังบันทึกการเรียนรู้ พร้อมตัวอย่างโค้ดและแบบฝึกหัดด้านข้อมูลและ Machine Learning"
tags:
  - learning
  - python
  - machine-learning
---

# bookshelf

คลังบันทึกการเรียนรู้และ cookbook สำหรับทบทวนแนวคิด ทดลองโค้ด
และฝึกทำแบบฝึกหัดด้วยตนเอง เนื้อหาอธิบายเป็นภาษาไทย
และใช้ชื่อคำสั่งตามเอกสารของไลบรารี

## ชั้นหนังสือ

| หมวด | เนื้อหาปัจจุบัน | เริ่มอ่าน |
| --- | --- | --- |
| ML-SHELF / PANDAS | การจัดการ สำรวจ ทำความสะอาด และแสดงผลข้อมูลด้วย pandas | [สารบัญ pandas](ML-SHELF/PANDAS/README.md) |

ปัจจุบันมีบทเรียน pandas 18 บท ครอบคลุมการเตรียมข้อมูลก่อนสร้างโมเดล
ส่วนบทฝึกและประเมินโมเดล Machine Learning ยังไม่ได้เพิ่ม

## เนื้อหา pandas

| กลุ่ม | บทเรียน |
| --- | --- |
| พื้นฐาน | [Introduction](ML-SHELF/PANDAS/Introduction.md), [Series](ML-SHELF/PANDAS/Series.md), [DataFrame](ML-SHELF/PANDAS/DataFrame.md) |
| อ่านและเลือกข้อมูล | [Reading Data](ML-SHELF/PANDAS/ReadingData.md), [Indexing](ML-SHELF/PANDAS/Indexing.md), [Query & Filter](ML-SHELF/PANDAS/QueryAndFilter.md) |
| สรุปและแปลงข้อมูล | [Summary Functions](ML-SHELF/PANDAS/SummaryFunctions.md), [Data Types](ML-SHELF/PANDAS/DataTypes.md), [Maps](ML-SHELF/PANDAS/Maps.md), [Grouping](ML-SHELF/PANDAS/Grouping.md) |
| ทำความสะอาดข้อมูล | [Missing Data](ML-SHELF/PANDAS/MissingData.md), [Replace & Renaming](ML-SHELF/PANDAS/ReplaceAndRenaming.md), [Duplicates & Sorting](ML-SHELF/PANDAS/DuplicatesAndSorting.md), [Cleaning Data](ML-SHELF/PANDAS/CleaningData.md) |
| รวมและปรับรูปตาราง | [Combining Data](ML-SHELF/PANDAS/CombiningData.md), [Reshaping](ML-SHELF/PANDAS/Reshaping.md) |
| เวลาและกราฟ | [DateTime](ML-SHELF/PANDAS/DateTime.md), [Plotting](ML-SHELF/PANDAS/Plotting.md) |

## วิธีใช้บันทึก

1. เริ่มจากสารบัญของหมวด แล้วอ่านตามลำดับที่แนะนำ
2. รันส่วนเตรียมข้อมูลก่อนทดลองตัวอย่างในแต่ละบท
3. เขียนคำตอบใน code block ใต้โจทย์ และตรวจผลด้วย print()
4. กลับมาทบทวนคำอธิบายและลิงก์อ้างอิงเมื่อผลลัพธ์ไม่ตรงที่คาด

ไฟล์ Markdown อ่านได้จากโปรแกรมแก้ไขข้อความหรือ Obsidian
ตัวอย่าง Python รันแยกในไฟล์ .py หรือ Jupyter Notebook

สำหรับบท pandas และกราฟ ให้ติดตั้งไลบรารีใน environment ที่ใช้งาน:

```bash
pip install pandas matplotlib
```

ตัวอย่าง Excel ต้องมี engine เพิ่มเติม เช่น openpyxl ตามที่ระบุในบท Reading Data

## มาตรฐานเอกสาร

- [กฎการเขียนและแก้ไขเอกสาร pandas](ML-SHELF/PANDAS/rules/AGENTS.md)
- [Frontmatter และแม่แบบบทเรียน pandas](ML-SHELF/PANDAS/rules/Frontmatter.md)

แต่ละบทมี metadata ชื่อเรื่อง คำอธิบาย และ tags
แบบฝึกหัดใช้เลขข้อพร้อมช่องโค้ดสำหรับคำตอบ โดยบางบทมีคำตอบที่ทำไว้แล้ว
