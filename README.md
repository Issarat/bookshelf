---
title: "bookshelf"
description: "คลังบันทึก Database Design การจัดการข้อมูล และ Machine Learning พร้อมตัวอย่างและแบบฝึกหัด"
tags:
  - learning
  - python
  - machine-learning
  - database-design
  - postgresql
---

# bookshelf

คลังบันทึกการเรียนรู้และ cookbook สำหรับทบทวนแนวคิด ทดลองโค้ด
และฝึกทำแบบฝึกหัดด้วยตนเอง เนื้อหาอธิบายเป็นภาษาไทย
ครอบคลุมการออกแบบฐานข้อมูล การจัดการข้อมูล และ Machine Learning
พร้อมตัวอย่าง SQL, Python และแบบฝึกหัด

## ชั้นหนังสือ

| หมวด | เนื้อหาปัจจุบัน | เริ่มอ่าน |
| --- | --- | --- |
| DB-SHELF | Database Design และระบบข้อมูล 26 บท ครอบคลุม PostgreSQL, Governance, การดูแล/ขยายระบบ และ Data Warehouse, Data Lake, Big Data, Data Center | [เข้าใจ Database Design ทีละขั้น](DB-SHELF/README.md) |
| DB-SHELF / WORKSHOPS | 2 Workshop แบบฝึก 6 ขั้น พร้อมเกณฑ์ส่งมอบ: ระบบยืมหนังสือ และ Database Design/Migration จาก Kaggle โดยมีคู่มือ SQL แยก | [สารบัญ Workshop](DB-SHELF/WORKSHOPS/README.md) |
| ML-SHELF / PANDAS | การจัดการ สำรวจ ทำความสะอาด และแสดงผลข้อมูลด้วย pandas | [สารบัญ pandas](ML-SHELF/PANDAS/README.md) |
| ML-SHELF / ML | Machine Learning 33 บท ครอบคลุมสถิติ EDA, Data Cleansing, Parsing Dates, Fuzzy Matching, Encoding, Scaling และการนำโมเดลไปใช้งานจริง | [เข้าใจ Machine Learning ทีละขั้น](ML-SHELF/ML/index.md) |
| ML-SHELF / DATA-VISUALIZATIONS | การเลือกกราฟ Distribution, Category, Relationships, Time Series และ Model Evaluation | [Data Visualizations สำหรับ Machine Learning](ML-SHELF/DATA-VISUALIZATIONS/index.md) |
| ML-SHELF / ALGORITHMS | อธิบายอัลกอริทึม สูตร จุดเด่น ข้อจำกัด และตัวอย่าง Python | [Linear Regression](ML-SHELF/ALGORITHMS/LinearRegression.md) |
| ML-SHELF / NOTEBOOKS | Notebook สำหรับทดลองโค้ด | [Linear Regression Notebook](ML-SHELF/NOTEBOOKS/linearregression.ipynb) |

ปัจจุบันมีบทเรียน Database Design และระบบข้อมูล 26 บท พร้อม Workshop 2 เรื่อง บทเรียน pandas 18 บท และ Machine Learning 33 บท
ชุด Data Visualizations 8 บท เอกสารอัลกอริทึม 11 เรื่อง เอกสารรวมสูตร และ Notebook สำหรับทดลอง

## เส้นทางการเรียน

เลือกเริ่มตามเป้าหมายได้สองเส้นทาง:

- **ออกแบบฐานข้อมูล:** ใช้ [สารบัญตามลำดับเรียน](DB-SHELF/README.md) ซึ่งจัดตามความสำคัญ ความยาก และความรู้ที่ต้องใช้ก่อน เริ่มจากพื้นฐาน ต่อด้วยความถูกต้องและการดูแลระบบ แล้วทำ Workshop ส่วนการขยายระบบเลือกเรียนตามโจทย์
- **วิเคราะห์ข้อมูลและสร้างโมเดล:** เรียนตามลำดับด้านล่าง พร้อมเปิดเอกสารอ้างอิงเมื่อจำเป็น

1. [pandas](ML-SHELF/PANDAS/README.md) — อ่าน สำรวจ และเตรียมข้อมูล
2. [Data Visualizations](ML-SHELF/DATA-VISUALIZATIONS/index.md) — เลือกกราฟ อ่านรูปแบบ และสื่อสารข้อมูล
3. [Machine Learning](ML-SHELF/ML/index.md) — อ่านตามลำดับจากพื้นฐานไปยังการนำโมเดลไปใช้งานจริง
4. [Algorithms](#อัลกอริทึม-machine-learning) — เลือกอ่านรายละเอียดของโมเดลแต่ละชนิด
5. [รวมสูตร Machine Learning](ML-SHELF/ML/formulas.md) — ทบทวนสัญลักษณ์ สูตร และวิธีอ่าน
6. [Notebook](ML-SHELF/NOTEBOOKS/linearregression.ipynb) — รันโค้ดทีละ Cell และทดลองเปลี่ยนข้อมูล

## เนื้อหา Database Design

เลขบทต่อไปนี้ตรงกับสารบัญและลิงก์บทก่อนหน้า/ถัดไปใน DB-SHELF แต่ละหัวข้อมีระดับความยากและเงื่อนไขที่ควรเรียนกำกับไว้ในสารบัญ

| บท | ความสำคัญและเนื้อหา | ระดับโดยรวม |
|---|---|---|
| 1–5 | พื้นฐานจำเป็น: ความสัมพันธ์ ชนิดข้อมูล Keys, Constraints, Normalization และการออกแบบให้พอดี | พื้นฐาน–กลาง |
| 6–8 | ก่อนเลือกและใช้ข้อมูลร่วมกัน: วงจรชีวิต Data Governance และ SQL/NoSQL | พื้นฐาน–กลาง |
| 9–12 | ความถูกต้องและการค้นหา: Transaction, Isolation/MVCC, Index, เวลาและภาษา | กลาง–สูง |
| 13–16 | ตามโจทย์ระบบ: ประวัติ คำสั่งซื้อ/การชำระเงิน Audit, สิทธิ์ และ Migration | กลาง–สูง |
| 17–19 | ก่อนและระหว่างใช้งานจริง: การทดสอบ Backup/Restore และประสิทธิภาพ | กลาง–สูง |
| 20–22 | เมื่อมีข้อจำกัดรองรับ: Partitioning, Replication และ Sharding | สูง–สูงมาก |
| 23–24 | ระบบวิเคราะห์: Data Warehouse, Fact/Dimension, ETL/ELT และ Data Lake, Catalog, Parquet/Lakehouse | กลาง |
| 25–26 | ภาพรวมแพลตฟอร์ม: Big Data, Batch/Streaming และ Data Center, Cloud, Failure Domain | พื้นฐาน–สูง |

หลังพื้นฐานหรือ Workshop สามารถต่อ [Data Warehouse](DB-SHELF/data-warehouse.md) → [Data Lake](DB-SHELF/data-lake.md) → [Big Data](DB-SHELF/big-data.md) → [Data Center](DB-SHELF/data-center.md) เพื่อเข้าใจบทบาทที่ต่างกัน ไม่จำเป็นต้องสร้างทุกส่วนตั้งแต่เริ่ม

เลือกโจทย์จาก [สารบัญ Workshop](DB-SHELF/WORKSHOPS/README.md) ซึ่งแยกจากบทเรียนหลัก ทั้งสองเรื่องใช้รูปแบบ **เป้าหมาย → ขั้นฝึก 6 หัวข้อ → สิ่งที่ส่งมอบ** โดยฝึกกฎธุรกิจ Grain/Constraints, Workflow, Query/Index, การทดสอบ และ Migration/การกู้คืน

| Workshop | เนื้อหาที่ฝึก | พื้นฐานที่แนะนำ |
|---|---|---|
| [ออกแบบระบบยืมหนังสือให้ครบวงจร](DB-SHELF/WORKSHOPS/database-design-workshop.md) | ออกแบบตารางและขั้นตอนยืม–คืน รักษากฎเมื่อมีคำขอพร้อมกัน และตรวจ Query/การกู้คืน | บท 1–19 |
| [Database Design และ Migration จาก Kaggle](DB-SHELF/WORKSHOPS/kaggle-design-and-migration.md) | ออกแบบจาก Olist CSV ย้ายผ่าน Raw/Cleansed Staging, Mapping, Reconciliation และเปลี่ยน Schema | บท 1–4, 7, 9–12 และ 16–19 |

Workshop Kaggle มี [ชุด SQL และวิธีรัน](DB-SHELF/WORKSHOPS/kaggle-sql/README.md) พร้อม Data Cleansing ที่เก็บค่าดิบและประวัติการแปลง ข้อมูลจำลอง และชุดทดสอบแยกจากหน้าโจทย์ ใช้ทดลองหรือเทียบหลังออกแบบเอง แล้วตรวจผลงานตามเกณฑ์ในแต่ละ Workshop

ดูหัวข้อ เลขบท ระดับความยาก และแบบฝึกหัดที่ [สารบัญ Database Design](DB-SHELF/README.md)

## เนื้อหา Machine Learning

| ช่วง | เนื้อหา |
|---|---|
| บท 1–9 | พื้นฐานโมเดล การแบ่งข้อมูล Probability & Statistics, EDA, Data Cleansing, Parsing Dates, Fuzzy Matching และ Baseline |
| บท 10–15 | Regression/Classification metrics, ROC/PR, Calibration, Underfitting/Overfitting และ Cross-validation |
| บท 16–24 | Data Leakage, Pipeline, Preprocessing, Encoding/Decoding, Scaling/Normalization, Outliers, Anomaly Detection, Feature Engineering และ PCA |
| บท 25–29 | Optimization, Hyperparameter tuning, Search Space, Class Imbalance, Threshold และการเปรียบเทียบโมเดล |
| บท 30–33 | Deep Learning, Explainability, Time Series/Forecasting และ Production Monitoring |

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

สำหรับ DB-SHELF ใช้ PostgreSQL กับ psql หรือ pgAdmin และฐานข้อมูลทดลองแยกจากข้อมูลจริง
ตัวอย่าง SQL เป็นส่วนประกอบเฉพาะหัวข้อ ไม่ใช่สคริปต์ที่รันต่อกันได้ทั้งหมด
บท Concurrency ต้องเปิดอย่างน้อยสอง Connection ส่วนข้อกำหนดเวอร์ชันและสิทธิ์ให้ดูในแต่ละบท

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
