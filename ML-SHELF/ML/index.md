# เข้าใจ Machine Learning ทีละขั้น

เรียบเรียงจากบทสนทนา [เข้าใจ Machine Learning](https://chatgpt.com/share/6ad03c98-22b8-83ec-84ae-492dd6e28537) พร้อมตัวอย่างสำหรับมือใหม่

**วิธีอ่าน:** เริ่มจากบทที่ 1 แล้วอ่านตามลำดับ ทุกบทเริ่มจากตัวอย่างก่อนสูตร หากพบสัญลักษณ์ที่ไม่คุ้นเคย ให้เปิด [รวมสูตร Machine Learning](formulas.md) เป็นเอกสารอ้างอิง

## เตรียมเครื่องมือสำหรับรันโค้ด

ตัวอย่างใช้ Python 3 และไลบรารีหลัก 3 ตัว ติดตั้งครั้งเดียวด้วยคำสั่ง:

```bash
python -m pip install numpy pandas matplotlib scikit-learn
```

แต่ละตัวอย่างออกแบบให้คัดลอกไปรันแยกได้ อ่านคอมเมนต์ตามหมายเลข แล้วลองเปลี่ยนค่าทีละจุดเพื่อดูว่าผลลัพธ์เปลี่ยนอย่างไร

## สารบัญ

| บท | หัวข้อ | สิ่งที่จะได้เรียนรู้ |
|---:|---|---|
| 1 | [โมเดลเรียนรู้อะไร?](model-learning.md) | Feature, Target, fit และ predict |
| 2 | [ทำไมต้องแยกข้อมูลไว้สอบ?](train-validation-test.md) | Train, Validation และ Test |
| 3 | [Probability และ Statistics สำหรับ Machine Learning](probability-statistics.md) | Probability และ Sampling |
| 4 | [Exploratory Data Analysis (EDA)](eda.md) | สำรวจข้อมูลก่อนสร้างโมเดล |
| 5 | [Data Visualization](data-visualization.md) | เลือกกราฟและสื่อสารข้อมูลอย่างถูกต้อง |
| 6 | [Data Cleansing และ Missing Data](data-cleansing-missing-data.md) | Cleaning, Missing และ Duplicate |
| 7 | [Baseline: เกณฑ์ขั้นต่ำสำหรับเปรียบเทียบโมเดล](baseline.md) | Baseline |
| 8 | [จะรู้ได้อย่างไรว่าทำนายราคาพลาดแค่ไหน?](mse-rmse.md) | MSE และ RMSE |
| 9 | [Metrics สำหรับ Regression](regression-metrics.md) | Regression metrics |
| 10 | [วัดผลโมเดล Classification อย่างไร?](classification-metrics.md) | Classification metrics |
| 11 | [ROC, Precision–Recall และ Probability Calibration](roc-pr-calibration.md) | ROC/PR และ Calibration |
| 12 | [Underfitting และ Overfitting](underfitting-overfitting.md) | Generalization gap |
| 13 | [Cross-validation คือการลองสอบหลายรอบ](cross-validation.md) | Cross-validation |
| 14 | [Data Leakage: ข้อมูลที่ไม่ควรเห็นหลุดเข้ามาช่วยโมเดล](data-leakage.md) | Data Leakage |
| 15 | [Pipeline ช่วยทำขั้นตอนให้ถูกลำดับ](pipeline.md) | Pipeline |
| 16 | [เตรียมข้อมูลจริง: Missing Values และ Category](preprocessing-real-data.md) | Missing values และ Category |
| 17 | [Outliers: ค่าที่ห่างจากข้อมูลส่วนใหญ่](outliers.md) | Outliers |
| 18 | [Anomaly Detection](anomaly-detection.md) | Anomaly Detection |
| 19 | [Feature Engineering](feature-engineering.md) | Feature Engineering |
| 20 | [Feature Selection และ PCA](feature-selection-pca.md) | Feature Selection และ PCA |
| 21 | [Optimization: โมเดลหาค่าที่ดีขึ้นได้อย่างไร](optimization.md) | Optimization |
| 22 | [Hyperparameter คือค่าที่เราเลือกให้โมเดล](hyperparameter-tuning.md) | Hyperparameters |
| 23 | [Search Space: เลือกช่วงค่าที่จะค้นหา](search-space.md) | Search Space |
| 24 | [Class Imbalance และการเลือก Threshold](class-imbalance-threshold.md) | Class imbalance |
| 25 | [เปรียบเทียบโมเดลอย่างยุติธรรม](model-comparison.md) | Model comparison |
| 26 | [Deep Learning](deep-learning.md) | Deep Learning |
| 27 | [อธิบายผลโมเดล](model-explainability.md) | Explainability |
| 28 | [Time Series และ Forecasting](time-series.md) | Time Series |
| 29 | [นำโมเดลไปใช้งานจริงและติดตามผล](production-monitoring.md) | Production monitoring |

## บทเสริม

| ประเภท | เอกสาร | เนื้อหา |
|---|---|---|
| อ้างอิง | [รวมสูตร Machine Learning](formulas.md) | สัญลักษณ์ สูตร วิธีอ่าน และข้อควรระวัง |
| Regression | [Linear Regression](../ALGORITHMS/LinearRegression.md) | สมการ การฝึกโมเดล และการตรวจความสัมพันธ์เชิงเส้น |
| Classification | [Logistic Regression](../ALGORITHMS/LogisticRegression.md) | Sigmoid, Probability, Log Loss และ Regularization |
| Tree | [Decision Tree](../ALGORITHMS/DecisionTree.md) | กฎแบบ if/else, Gini, Entropy, MSE และ Overfitting |
| Ensemble | [Random Forest](../ALGORITHMS/RandomForest.md) | Classification, Regression, Parameters และ Tuning |
| Ensemble | [Gradient Boosting](../ALGORITHMS/GradientBoosting.md) | ต้นไม้ที่แก้ข้อผิดพลาดต่อกันและ Learning rate |
| Clustering | [K-Means](../ALGORITHMS/KMeans.md) | แบ่งข้อมูลแบบไม่มี Target, เลือก K และ Silhouette Score |
| Classification | [Support Vector Machine](../ALGORITHMS/SVM.md) | Margin, Kernel และเส้นแบ่งที่ไม่เป็นเส้นตรง |
| Neighbors | [K-Nearest Neighbors](../ALGORITHMS/KNN.md) | ทำนายจากข้อมูล Train ที่อยู่ใกล้ที่สุด K จุด |
| Probability | [Naive Bayes](../ALGORITHMS/NaiveBayes.md) | จำแนกข้อมูลด้วยกฎของ Bayes โดยเฉพาะงานข้อความ |
| Deep Learning | [Neural Network](../ALGORITHMS/NeuralNetwork.md) | Neurons, Layers และ Backpropagation |
| Deep Learning | [Transformer](../ALGORITHMS/Transformer.md) | Self-attention, Multi-head attention และโมเดลภาษา |

## เส้นทางการเรียน

| ช่วง | เป้าหมาย |
|---|---|
| บท 1–7 | เข้าใจโมเดล สถิติ EDA, Visualization, Data Cleansing และ Baseline |
| บท 8–13 | วัดผล ROC/PR, Underfitting/Overfitting และ Cross-validation |
| บท 14–20 | ป้องกัน Leakage เตรียมข้อมูล ตรวจ Anomalies และจัดการ Features |
| บท 21–25 | เข้าใจ Optimization ปรับ Hyperparameters และเปรียบเทียบโมเดล |
| บท 26–29 | เรียน Deep Learning อธิบายโมเดล Time Series และ Production |
