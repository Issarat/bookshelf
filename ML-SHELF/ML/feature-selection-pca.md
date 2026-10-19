# 24. Feature Selection และ PCA

Feature Selection เลือกคอลัมน์เดิมที่มีประโยชน์ ส่วน PCA สร้างแกนใหม่จากการผสม Features เดิมเพื่อลดจำนวนมิติ

## ทำไมต้องลด Features?

- ลด Noise และ Overfitting
- ลดเวลาและหน่วยความจำ
- ทำให้โมเดลอธิบายง่ายขึ้น
- ลดปัญหาของโมเดลที่ใช้ระยะทางในมิติสูง

## Feature Selection

| วิธี | ตัวอย่าง |
|---|---|
| Filter | Correlation, mutual information, chi-square |
| Wrapper | Recursive Feature Elimination |
| Embedded | L1 regularization, tree importance |

```python
from sklearn.feature_selection import SelectKBest, mutual_info_classif
from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression

model = make_pipeline(
    StandardScaler(),
    SelectKBest(score_func=mutual_info_classif, k=10),
    LogisticRegression(max_iter=1000),
)
model.fit(X_train, y_train)
```

Selector ต้องอยู่ใน Pipeline เพื่อให้เลือก Features จาก Train ของแต่ละ Fold เท่านั้น

## PCA

PCA หาแกนที่หนึ่งให้เก็บความแปรปรวนมากที่สุด แล้วหาแกนถัดไปที่ตั้งฉากกัน

Explained variance ratio ของ Component $j$:

$$
r_j=\frac{\lambda_j}{\sum_{k=1}^{p}\lambda_k}
$$

```python
from sklearn.decomposition import PCA
from sklearn.linear_model import LogisticRegression
from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler

model = make_pipeline(
    StandardScaler(),
    PCA(n_components=0.95),
    LogisticRegression(max_iter=1000),
)
model.fit(X_train, y_train)
```

`n_components=0.95` เลือกจำนวน Components ที่เก็บความแปรปรวนสะสมอย่างน้อย 95% PCA ทำการ Center แต่ไม่ได้ Scale Features จึงมักวาง `StandardScaler` ก่อน PCA

## ข้อจำกัด

- ความแปรปรวนสูงไม่ได้แปลว่ามีประโยชน์ต่อ Target เสมอไป
- Components เป็นส่วนผสมของหลาย Features จึงอธิบายยาก
- PCA เป็นการแปลงเชิงเส้น
- Feature importance ไม่ได้ยืนยันเหตุและผล

## Checklist

- ทำ Selection/PCA ภายใน Pipeline
- เลือกด้วย Cross-validation
- เปรียบเทียบกับโมเดลที่ไม่ลด Features
- ตรวจ Performance เวลา และความสามารถในการอธิบาย
- เก็บ Transformer ตัวเดิมไว้ใช้กับข้อมูลใหม่

## แหล่งอ้างอิง

- [scikit-learn: Feature selection](https://scikit-learn.org/stable/modules/feature_selection.html)
- [scikit-learn: PCA](https://scikit-learn.org/stable/modules/generated/sklearn.decomposition.PCA.html)

---

[← บทก่อนหน้า: Feature Engineering](feature-engineering.md) | [สารบัญ](index.md) | [บทถัดไป: Optimization: โมเดลหาค่าที่ดีขึ้นได้อย่างไร →](optimization.md)
