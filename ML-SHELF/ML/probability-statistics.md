# 3. Probability และ Statistics สำหรับ Machine Learning

Probability ช่วยอธิบายความไม่แน่นอน ส่วน Statistics ช่วยสรุปและอนุมานจากข้อมูล ทั้งสองเรื่องเป็นพื้นฐานของการวัดผล การสุ่มตัวอย่าง และโมเดลจำนวนมาก

## 1. Population และ Sample

- **Population:** ข้อมูลทั้งหมดที่สนใจ เช่น ลูกค้าทั้งหมด
- **Sample:** ข้อมูลบางส่วนที่นำมาศึกษา เช่น ลูกค้า 10,000 คนที่สุ่มมา

ค่าที่อธิบาย Population เรียกว่า **Parameter** ส่วนค่าที่คำนวณจาก Sample เรียกว่า **Statistic**

## 2. ค่ากลาง

ค่าเฉลี่ย:

$$
\bar{x}=\frac{1}{n}\sum_{i=1}^{n}x_i
$$

Median คือค่าตรงกลางหลังเรียงข้อมูล และทนต่อ Outliers มากกว่าค่าเฉลี่ย ส่วน Mode คือค่าที่เกิดบ่อยที่สุด

## 3. การกระจาย

Population variance และ standard deviation:

$$
\sigma^2=\frac{1}{N}\sum_{i=1}^{N}(x_i-\mu)^2
$$

$$
\sigma=\sqrt{\sigma^2}
$$

Sample variance ใช้ $n-1$ เพื่อลดความเอนเอียงในการประมาณ Population variance:

$$
s^2=\frac{1}{n-1}\sum_{i=1}^{n}(x_i-\bar{x})^2
$$

## 4. Probability พื้นฐาน

$$
P(A)=\frac{\text{จำนวนผลลัพธ์ที่เป็น }A}{\text{จำนวนผลลัพธ์ทั้งหมด}}
$$

ค่าความน่าจะเป็นอยู่ระหว่าง 0 ถึง 1 และเหตุการณ์ตรงข้ามมีค่า:

$$
P(A^c)=1-P(A)
$$

ถ้า $A$ และ $B$ เป็นอิสระต่อกัน:

$$
P(A\cap B)=P(A)P(B)
$$

## 5. Conditional Probability และ Bayes

$$
P(A\mid B)=\frac{P(A\cap B)}{P(B)}
$$

กฎของ Bayes:

$$
P(A\mid B)=\frac{P(B\mid A)P(A)}{P(B)}
$$

แนวคิดนี้เป็นพื้นฐานของ Naive Bayes และการปรับความเชื่อเมื่อได้รับข้อมูลใหม่

## 6. Correlation ไม่ใช่ Causation

Pearson correlation วัดความสัมพันธ์เชิงเส้น:

$$
r=\frac{\sum_{i=1}^{n}(x_i-\bar{x})(y_i-\bar{y})}
{\sqrt{\sum_{i=1}^{n}(x_i-\bar{x})^2}\sqrt{\sum_{i=1}^{n}(y_i-\bar{y})^2}}
$$

$r$ อยู่ระหว่าง -1 ถึง 1 แต่ Correlation สูงไม่ได้ยืนยันว่า $X$ เป็นสาเหตุของ $Y$ และค่าใกล้ 0 ไม่ได้แปลว่าไม่มีความสัมพันธ์แบบอื่น

## 7. Distribution ที่พบบ่อย

| Distribution | ใช้คิดเกี่ยวกับ |
|---|---|
| Bernoulli | ผลลัพธ์สองแบบ เช่น ผ่าน/ไม่ผ่าน |
| Binomial | จำนวนครั้งที่สำเร็จจากการทดลองหลายครั้ง |
| Normal | ค่าต่อเนื่องที่กระจายรอบค่าเฉลี่ย |
| Poisson | จำนวนเหตุการณ์ในช่วงเวลา/พื้นที่ |

Z-score บอกว่าค่าหนึ่งห่างจากค่าเฉลี่ยกี่ Standard deviations:

$$
z=\frac{x-\mu}{\sigma}
$$

## 8. Sampling และความไม่แน่นอน

Sample ที่ต่างกันให้ค่าเฉลี่ยต่างกัน Standard error ของค่าเฉลี่ยโดยประมาณคือ:

$$
SE_{\bar{x}}=\frac{s}{\sqrt{n}}
$$

เมื่อจำนวนข้อมูลมากขึ้น Standard error มักลดลง แต่ข้อมูลจำนวนมากที่เลือกมาแบบมี Bias ก็ยังให้ข้อสรุปผิดได้

## 9. ตัวอย่าง Python

```python
import numpy as np

values = np.array([10, 12, 12, 13, 53], dtype=float)

print("Mean:", values.mean())
print("Median:", np.median(values))
print("Population std:", values.std(ddof=0))
print("Sample std:", values.std(ddof=1))
print("25th, 50th, 75th percentiles:", np.percentile(values, [25, 50, 75]))
```

## 10. ใช้ใน Machine Learning อย่างไร?

- สรุปและตรวจคุณภาพข้อมูลก่อนฝึก
- แบ่งข้อมูลและทำ Cross-validation
- แปลง Features ด้วย StandardScaler
- ตีความ Probability จาก Classification
- วัดความผันผวนของคะแนน
- ตรวจ Outliers และ Data drift

> [!IMPORTANT]
> ค่าเฉลี่ย Probability หรือ Correlation เป็นเพียงข้อมูลสรุป ต้องดูการกระจาย ขนาด Sample วิธีเก็บข้อมูล และบริบทของงานร่วมกัน

## Checklist

- แยกให้ออกระหว่าง Population กับ Sample
- ดู Median และการกระจายร่วมกับ Mean
- ตรวจ Missing values และ Outliers
- อย่าสรุปเหตุและผลจาก Correlation เพียงอย่างเดียว
- รายงานจำนวนข้อมูลและความผันผวนของคะแนน

## แหล่งอ้างอิง

- [NIST/SEMATECH: Exploratory Data Analysis](https://www.itl.nist.gov/div898/handbook/eda/eda.htm)
- [scikit-learn: Probability calibration](https://scikit-learn.org/stable/modules/calibration.html)

---

[← บทก่อนหน้า: ทำไมต้องแยกข้อมูลไว้สอบ?](train-validation-test.md) · [สารบัญ](index.md) · [บทถัดไป: Exploratory Data Analysis (EDA) →](eda.md)
