# Naive Bayes

**Naive Bayes** เป็นโมเดล Classification ที่ใช้กฎของ Bayes และสมมติว่า Features เป็นอิสระต่อกันเมื่อทราบคลาส สมมตินี้มักไม่จริงทั้งหมด จึงเรียกว่า “Naive” แต่โมเดลยังทำงานได้ดีในหลายงาน โดยเฉพาะการจำแนกข้อความ

## 1. กฎของ Bayes

$$
P(C\mid X)=\frac{P(X\mid C)P(C)}{P(X)}
$$

- $P(C\mid X)$: Probability ของคลาส $C$ หลังเห็น Features
- $P(X\mid C)$: โอกาสพบ Features เมื่อเป็นคลาส $C$
- $P(C)$: โอกาสของคลาสก่อนเห็น Features หรือ Prior
- $P(X)$: โอกาสพบ Features ชุดนั้น

เมื่อเปรียบเทียบคลาส $P(X)$ เหมือนกันทุกคลาส จึงเลือกคลาสได้จาก:

$$
\hat{C}=\underset{c}{\operatorname{argmax}}
\;P(C=c)P(X\mid C=c)
$$

## 2. สมมติฐานแบบ Naive

ถ้ามี Features $x_1,\ldots,x_p$ โมเดลประมาณว่า:

$$
P(X\mid C)=\prod_{j=1}^{p}P(x_j\mid C)
$$

ดังนั้น:

$$
\hat{C}=\underset{c}{\operatorname{argmax}}
\;P(C=c)\prod_{j=1}^{p}P(x_j\mid C=c)
$$

ในโปรแกรมมักบวก Log probability แทนการคูณจำนวนเล็กมาก:

$$
\log P(C=c)+\sum_{j=1}^{p}\log P(x_j\mid C=c)
$$

## 3. ตัวอย่าง Spam

สมมติคำว่า “ฟรี” พบใน:

- Spam 80 จาก 100 ข้อความ
- ไม่ใช่ Spam 5 จาก 100 ข้อความ

คำว่า “ฟรี” จึงเพิ่มหลักฐานไปทาง Spam แต่โมเดลจะรวมหลักฐานจากคำอื่นและ Prior ของแต่ละคลาสด้วย

## 4. รุ่นที่พบบ่อย

| โมเดล | ลักษณะข้อมูล |
|---|---|
| `GaussianNB` | Features ต่อเนื่องและประมาณด้วย Normal distribution |
| `MultinomialNB` | จำนวนครั้งหรือความถี่ เช่น Count/TF-IDF ของคำที่ไม่ติดลบ |
| `BernoulliNB` | Features แบบ 0/1 เช่น มีหรือไม่มีคำ |
| `CategoricalNB` | Features เป็น Category ที่เข้ารหัสเป็นจำนวนเต็ม |

Gaussian Naive Bayes ใช้:

$$
P(x_j\mid C=c)=
\frac{1}{\sqrt{2\pi\sigma_{c,j}^2}}
\exp\left(-\frac{(x_j-\mu_{c,j})^2}{2\sigma_{c,j}^2}\right)
$$

## 5. ตัวอย่างจำแนกข้อความ

```python
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.metrics import classification_report
from sklearn.model_selection import train_test_split
from sklearn.naive_bayes import MultinomialNB
from sklearn.pipeline import make_pipeline

texts = [
    "รับเงินฟรี คลิกลิงก์ทันที",
    "โปรโมชั่นฟรีวันนี้",
    "ประชุมทีมพรุ่งนี้สิบโมง",
    "ส่งรายงานให้ตรวจแล้ว",
    "รับรางวัลฟรีตอนนี้",
    "นัดลูกค้าวันศุกร์",
    "เครดิตฟรี สมัครด่วน",
    "เอกสารประชุมอยู่ในอีเมล",
]
y = [1, 1, 0, 0, 1, 0, 1, 0]

X_train, X_valid, y_train, y_valid = train_test_split(
    texts,
    y,
    test_size=0.25,
    random_state=42,
    stratify=y,
)

model = make_pipeline(
    CountVectorizer(),
    MultinomialNB(alpha=1.0),
)
model.fit(X_train, y_train)
y_pred = model.predict(X_valid)

print(classification_report(y_valid, y_pred, zero_division=0))
```

## 6. Laplace smoothing

ถ้าคำหนึ่งไม่เคยปรากฏในคลาสใด Probability จะเป็นศูนย์และทำให้ผลคูณทั้งหมดเป็นศูนย์ จึงเพิ่มค่า smoothing $\alpha$:

$$
P(w\mid c)=\frac{N_{w,c}+\alpha}{N_c+\alpha V}
$$

- $N_{w,c}$ คือจำนวนคำ $w$ ในคลาส $c$
- $N_c$ คือจำนวนคำทั้งหมดในคลาส $c$
- $V$ คือจำนวนคำใน Vocabulary
- `alpha=1` คือ Laplace smoothing

## 7. จุดเด่นและข้อจำกัด

จุดเด่น:

- ฝึกและทำนายเร็ว
- ใช้ได้ดีกับข้อมูลข้อความที่มี Features จำนวนมาก
- ทำงานได้แม้ข้อมูลฝึกไม่ใหญ่มาก
- มี Probability สำหรับแต่ละคลาส

ข้อจำกัด:

- สมมติว่า Features เป็นอิสระต่อกันเมื่อทราบคลาส
- Probability อาจไม่ Calibrate ดีพอสำหรับการตัดสินใจที่ต้องใช้ค่าความน่าจะเป็นแม่นยำ
- ต้องเลือกรุ่นให้ตรงกับชนิดข้อมูล
- `MultinomialNB` ต้องการ Features ที่ไม่ติดลบ

## 8. Checklist

- เลือก Gaussian, Multinomial, Bernoulli หรือ Categorical ให้ตรงข้อมูล
- ทำ preprocessing ภายใน Pipeline
- ปรับ `alpha` ด้วย Cross-validation
- ตรวจ Precision, Recall และ F1 เมื่อคลาสไม่สมดุล
- เปรียบเทียบกับ Logistic Regression และ Baseline
- ตรวจ Calibration หากใช้ Probability ตัดสินใจโดยตรง

## แหล่งอ้างอิง

- [scikit-learn: Naive Bayes](https://scikit-learn.org/stable/modules/naive_bayes.html)
- [scikit-learn: MultinomialNB](https://scikit-learn.org/stable/modules/generated/sklearn.naive_bayes.MultinomialNB.html)

---

[สารบัญ](../ML/index.md) · [รวมสูตร](../ML/formulas.md)
