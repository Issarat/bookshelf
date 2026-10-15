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
| 1 | [โมเดลเรียนรู้อะไร?](01-model-learning.md) | Feature, Target, fit และ predict |
| 2 | [ทำไมต้องแยกข้อมูลไว้สอบ?](02-train-validation-test.md) | หน้าที่ของ Train, Validation และ Test |
| 3 | [Probability และ Statistics สำหรับ Machine Learning](03-probability-statistics.md) | ค่ากลาง การกระจาย Probability และ Sampling |
| 4 | [Exploratory Data Analysis (EDA)](04-eda.md) | สำรวจคุณภาพ Distribution, Missing values และความสัมพันธ์ |
| 5 | [Baseline: เกณฑ์ขั้นต่ำสำหรับเปรียบเทียบโมเดล](05-baseline.md) | เกณฑ์ขั้นต่ำสำหรับเปรียบเทียบโมเดล |
| 6 | [จะรู้ได้อย่างไรว่าทำนายราคาพลาดแค่ไหน?](06-mse-rmse.md) | คำนวณความผิดพลาดทีละขั้น |
| 7 | [Metrics สำหรับ Regression](07-regression-metrics.md) | MAE, MSE, RMSE, MAPE และ R² |
| 8 | [วัดผลโมเดล Classification อย่างไร?](08-classification-metrics.md) | Accuracy, Precision, Recall และ F1 |
| 9 | [ROC, Precision–Recall และ Probability Calibration](09-roc-pr-calibration.md) | ประเมินหลาย Threshold และความน่าเชื่อถือของ Probability |
| 10 | [Underfitting และ Overfitting](10-underfitting-overfitting.md) | วิเคราะห์ Generalization gap |
| 11 | [Cross-validation คือการลองสอบหลายรอบ](11-cross-validation.md) | สลับ Validation fold และเฉลี่ยคะแนน |
| 12 | [Data Leakage: ข้อมูลที่ไม่ควรเห็นหลุดเข้ามาช่วยโมเดล](12-data-leakage.md) | ป้องกันข้อมูลที่ไม่ควรเห็นหลุดเข้าโมเดล |
| 13 | [Pipeline ช่วยทำขั้นตอนให้ถูกลำดับ](13-pipeline.md) | จัด Preprocessing และโมเดลให้ถูกลำดับ |
| 14 | [เตรียมข้อมูลจริง: Missing Values และ Category](14-preprocessing-real-data.md) | จัดการ Missing values และ Category |
| 15 | [Outliers: ค่าที่ห่างจากข้อมูลส่วนใหญ่](15-outliers.md) | ตรวจด้วย IQR, Z-score และกราฟ |
| 16 | [Anomaly Detection](16-anomaly-detection.md) | ค้นหารายการผิดปกติด้วย Isolation Forest และวิธีอื่น |
| 17 | [Feature Engineering](17-feature-engineering.md) | สร้าง Features โดยไม่ทำให้ข้อมูลรั่ว |
| 18 | [Feature Selection และ PCA](18-feature-selection-pca.md) | เลือก Features และลดมิติด้วย PCA |
| 19 | [Optimization: โมเดลหาค่าที่ดีขึ้นได้อย่างไร](19-optimization.md) | Loss, Gradient descent และ Learning rate |
| 20 | [Hyperparameter คือค่าที่เราเลือกให้โมเดล](20-hyperparameter-tuning.md) | ค่าที่ผู้พัฒนาเลือกให้โมเดล |
| 21 | [Search Space: เลือกช่วงค่าที่จะค้นหา](21-search-space.md) | Grid Search และ Randomized Search |
| 22 | [Class Imbalance และการเลือก Threshold](22-class-imbalance-threshold.md) | รับมือคลาสไม่สมดุลและเลือก Threshold |
| 23 | [เปรียบเทียบโมเดลอย่างยุติธรรม](23-model-comparison.md) | ใช้ข้อมูล Folds และ Metric เดียวกัน |
| 24 | [Deep Learning](24-deep-learning.md) | Backpropagation และ Transfer Learning |
| 25 | [อธิบายผลโมเดล](25-model-explainability.md) | Permutation Importance และ Partial Dependence |
| 26 | [Time Series และ Forecasting](26-time-series.md) | Time split, Lag features และ Backtesting |
| 27 | [นำโมเดลไปใช้งานจริงและติดตามผล](27-production-monitoring.md) | ตรวจ Schema, Drift และ Performance |

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
| บท 1–5 | เข้าใจโมเดล การแบ่งข้อมูล สถิติ EDA และ Baseline |
| บท 6–11 | วัดผล Probability curves, Underfitting/Overfitting และ Cross-validation |
| บท 12–18 | ป้องกัน Leakage เตรียมข้อมูล ตรวจ Anomalies และจัดการ Features |
| บท 19–23 | เข้าใจ Optimization ปรับ Hyperparameters และเปรียบเทียบโมเดล |
| บท 24–27 | เรียน Deep Learning อธิบายโมเดล Time Series และ Production |
