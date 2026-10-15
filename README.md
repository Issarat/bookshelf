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
| ML-SHELF / ML | หลักสูตร Machine Learning 29 บท ตั้งแต่พื้นฐาน สถิติ EDA ไปจนถึง Deep Learning, Time Series และ Production | [เข้าใจ Machine Learning ทีละขั้น](ML-SHELF/ML/index.md) |
| ML-SHELF / ALGORITHMS | อธิบายอัลกอริทึม สูตร จุดเด่น ข้อจำกัด และตัวอย่าง Python | [Linear Regression](ML-SHELF/ALGORITHMS/LinearRegression.md) |
| ML-SHELF / NOTEBOOKS | Notebook สำหรับทดลองโค้ด | [Linear Regression Notebook](ML-SHELF/NOTEBOOKS/linearregression.ipynb) |

ปัจจุบันมีบทเรียน pandas 18 บท หลักสูตร Machine Learning 29 บท
เอกสารอัลกอริทึม 11 เรื่อง เอกสารรวมสูตร และ Notebook สำหรับทดลอง

## เส้นทางการเรียน

1. [pandas](ML-SHELF/PANDAS/README.md) — อ่าน สำรวจ และเตรียมข้อมูล
2. [Machine Learning](ML-SHELF/ML/index.md) — อ่านตามลำดับจากพื้นฐานไปยังการนำโมเดลไปใช้งานจริง
3. [Algorithms](#อัลกอริทึม-machine-learning) — เลือกอ่านรายละเอียดของโมเดลแต่ละชนิด
4. [รวมสูตร Machine Learning](ML-SHELF/ML/formulas.md) — ทบทวนสัญลักษณ์ สูตร และวิธีอ่าน
5. [Notebook](ML-SHELF/NOTEBOOKS/linearregression.ipynb) — รันโค้ดทีละ Cell และทดลองเปลี่ยนข้อมูล

## เนื้อหา Machine Learning

| ช่วง | เนื้อหา |
|---|---|
| บท 1–5 | พื้นฐานโมเดล การแบ่งข้อมูล Probability & Statistics, EDA และ Baseline |
| บท 7–12 | Regression/Classification metrics, ROC/PR, Calibration, Underfitting/Overfitting และ Cross-validation |
| บท 13–19 | Data Leakage, Pipeline, Preprocessing, Outliers, Anomaly Detection, Feature Engineering และ PCA |
| บท 20–24 | Optimization, Hyperparameter tuning, Search space, Class imbalance และการเปรียบเทียบโมเดล |
| บท 25–28 | Deep Learning, Explainability, Time Series และ Production monitoring |

ดูหัวข้อและคำอธิบายของแต่ละบทได้ที่ [สารบัญ Machine Learning](ML-SHELF/ML/index.md)

## อัลกอริทึม Machine Learning

| กลุ่ม | เอกสาร |
|---|---|
| Linear models | [Linear Regression](ML-SHELF/ALGORITHMS/LinearRegression.md), [Logistic Regression](ML-SHELF/ALGORITHMS/LogisticRegression.md) |
| Tree และ Ensemble | [Decision Tree](ML-SHELF/ALGORITHMS/DecisionTree.md), [Random Forest](ML-SHELF/ALGORITHMS/RandomForest.md), [Gradient Boosting](ML-SHELF/ALGORITHMS/GradientBoosting.md) |
| Distance และ Margin | [KNN](ML-SHELF/ALGORITHMS/KNN.md), [SVM](ML-SHELF/ALGORITHMS/SVM.md) |
| Probability | [Naive Bayes](ML-SHELF/ALGORITHMS/NaiveBayes.md) |
| Clustering | [K-Means](ML-SHELF/ALGORITHMS/KMeans.md) |
| Deep Learning | [Neural Network](ML-SHELF/ALGORITHMS/NeuralNetwork.md), [Transformer](ML-SHELF/ALGORITHMS/Transformer.md) |

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
3. คัดลอกตัวอย่างไปทดลอง แล้วเปลี่ยนค่าทีละส่วนเพื่อสังเกตผล
4. กลับมาทบทวนคำอธิบายและลิงก์อ้างอิงเมื่อผลลัพธ์ไม่ตรงที่คาด

ไฟล์ Markdown อ่านได้จากโปรแกรมแก้ไขข้อความหรือ Obsidian
ตัวอย่าง Python รันแยกในไฟล์ .py หรือ Jupyter Notebook

สำหรับบท pandas กราฟ และ Machine Learning ให้ติดตั้งไลบรารีใน environment ที่ใช้งาน:

```bash
python -m pip install numpy pandas matplotlib seaborn scikit-learn
```

ตัวอย่าง Excel ต้องมี engine เพิ่มเติม เช่น openpyxl ตามที่ระบุในบท Reading Data
หากใช้ Jupyter Notebook ให้ติดตั้ง Jupyter เพิ่มใน environment เดียวกัน

## ไฟล์ที่เก็บใน Git

เก็บบทเรียน Markdown, Notebook และไฟล์ประกอบที่ใช้เรียนร่วมกัน
ส่วน [.gitignore](.gitignore) แยก virtual environment, Python cache,
Notebook checkpoints, ไฟล์ลับ และไฟล์สถานะส่วนตัวของโปรแกรมออก

ข้อมูลตัวอย่างและภาพประกอบยังเพิ่มเข้า Git ได้ตามปกติ
ผลลัพธ์ทดลองที่ไม่ต้องการเผยแพร่ให้เก็บในโฟลเดอร์ outputs หรือ artifacts
ไฟล์ที่ Git ติดตามอยู่แล้วจะไม่หยุดติดตามเพียงเพราะเพิ่มกฎ ignore

## มาตรฐานเอกสาร

- [กฎการเขียนและแก้ไขเอกสาร pandas](ML-SHELF/PANDAS/rules/AGENTS.md)
- [Frontmatter และแม่แบบบทเรียน pandas](ML-SHELF/PANDAS/rules/Frontmatter.md)

เอกสารใช้หัวข้อ ลิงก์ สูตร LaTeX, Mermaid และตัวอย่าง Python ในรูปแบบที่ GitHub แสดงผลได้
