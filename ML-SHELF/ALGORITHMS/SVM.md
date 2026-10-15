# Support Vector Machine (SVM)

**Support Vector Machine** คือโมเดล Supervised Learning ที่พยายามสร้างเส้นหรือระนาบแบ่งคลาส โดยทำให้ระยะห่างระหว่างเส้นแบ่งกับข้อมูลที่อยู่ใกล้ที่สุดกว้างที่สุด ระยะนี้เรียกว่า **Margin**

## 1. แนวคิด

```mermaid
flowchart LR
    A[ข้อมูลสองคลาส] --> B[หาเส้นแบ่งหลายแบบ]
    B --> C[เลือกเส้นที่มี Margin กว้าง]
    C --> D[ใช้ทำนายข้อมูลใหม่]
```

ข้อมูลที่อยู่ใกล้ขอบเขตและมีผลต่อเส้นแบ่งเรียกว่า **Support Vectors** จุดที่อยู่ไกลออกไปมักมีผลต่อขอบเขตน้อยกว่า

## 2. สมการเส้นแบ่ง

คะแนนของ Linear SVM:

$$
f(x)=w^Tx+b
$$

ทำนายด้วยเครื่องหมายของคะแนน:

$$
\hat{y}=\operatorname{sign}(w^Tx+b)
$$

ระยะ Margin ระหว่างขอบทั้งสองคือ:

$$
\mathrm{Margin}=\frac{2}{\|w\|}
$$

โมเดลต้องการ Margin กว้าง แต่ยอมให้บางจุดอยู่ผิดฝั่งได้ด้วย Slack variable $\xi_i$:

$$
\underset{w,b,\xi}{\operatorname{minimize}}
\left[
\frac{1}{2}\|w\|^2+C\sum_{i=1}^{n}\xi_i
\right]
$$

- `C` สูง: ลงโทษการทาย Train ผิดมาก ขอบเขตซับซ้อนขึ้นและเสี่ยง Overfitting
- `C` ต่ำ: ยอมผิดบางจุดเพื่อให้ Margin กว้างขึ้น

## 3. Kernel Trick

ถ้าแบ่งด้วยเส้นตรงไม่ได้ Kernel ช่วยคำนวณความคล้ายกันในพื้นที่มิติสูงโดยไม่ต้องสร้าง Features ทั้งหมดโดยตรง

RBF kernel:

$$
K(x,z)=\exp\left(-\gamma\|x-z\|^2\right)
$$

- `gamma` สูง: แต่ละจุดมีอิทธิพลแคบ ขอบเขตซับซ้อนและเสี่ยง Overfitting
- `gamma` ต่ำ: อิทธิพลกว้าง ขอบเขตเรียบขึ้น

## 4. ตัวอย่าง Classification

```python
from sklearn.datasets import load_breast_cancer
from sklearn.model_selection import train_test_split
from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.svm import SVC

X, y = load_breast_cancer(return_X_y=True)
X_train, X_valid, y_train, y_valid = train_test_split(
    X,
    y,
    test_size=0.25,
    random_state=42,
    stratify=y,
)

model = make_pipeline(
    StandardScaler(),
    SVC(kernel="rbf", C=1.0, gamma="scale"),
)
model.fit(X_train, y_train)

print("Validation accuracy:", model.score(X_valid, y_valid))
```

SVM ไวต่อสเกลของ Features จึงควรใช้ `StandardScaler` ภายใน Pipeline

## 5. รุ่นที่พบบ่อย

| โมเดล | ใช้กับ |
|---|---|
| `SVC` | Classification และ Kernel |
| `LinearSVC` | Linear classification โดยเฉพาะข้อมูลจำนวนมากหรือมิติสูง |
| `SVR` | Regression |

## 6. จุดเด่นและข้อจำกัด

จุดเด่น:

- ทำงานได้ดีกับข้อมูลมิติสูง
- Kernel จับขอบเขตที่ไม่เป็นเส้นตรงได้
- ใช้เฉพาะ Support Vectors เป็นหลักในการกำหนดขอบเขต

ข้อจำกัด:

- ต้อง Scale Features
- `SVC` อาจช้าและใช้หน่วยความจำมากเมื่อข้อมูลมีหลายหมื่นแถวขึ้นไป
- ต้องปรับ `C`, `gamma` และ `kernel`
- Probability จาก `SVC(probability=True)` ต้องมีขั้นตอนปรับเพิ่มเติมและทำให้ฝึกช้าลง

## 7. Checklist

- Scale Features ภายใน Pipeline
- เริ่มจาก `kernel="linear"` หรือ `"rbf"`
- ปรับ `C` และ `gamma` ด้วย Cross-validation
- ใช้ Metric ที่เหมาะกับ Class imbalance
- ตรวจ Train/Validation gap
- พิจารณา `LinearSVC` เมื่อข้อมูลใหญ่หรือมี Features มาก

## แหล่งอ้างอิง

- [scikit-learn: Support Vector Machines](https://scikit-learn.org/stable/modules/svm.html)
- [scikit-learn: SVC](https://scikit-learn.org/stable/modules/generated/sklearn.svm.SVC.html)

---

[สารบัญ](../ML/index.md) · [รวมสูตร](../ML/formulas.md)
