# Linear Regression

Linear Regression คือโมเดล Machine Learning สำหรับ **ทำนายค่าที่เป็นตัวเลขต่อเนื่อง** เช่น ราคาบ้าน ยอดขาย อุณหภูมิ หรือระยะเวลาจัดส่ง

แนวคิดหลักคือหาเส้นตรงที่อธิบายความสัมพันธ์ระหว่าง Features กับ Target ได้ดีที่สุด

> [!IMPORTANT]
> โมเดลที่ไม่มีขั้นตอนสุ่ม เช่น `LinearRegression` แบบปกติ ไม่จำเป็นต้องมี `random_state`

## 1. สมการพื้นฐาน

กรณีมี Feature หนึ่งตัว:

$$
\hat{y}=wx+b
$$

| สัญลักษณ์ | ความหมาย |
|---|---|
| $x$ | Feature ที่ใช้ทำนาย |
| $w$ | Weight หรือผลของ Feature ต่อค่าทำนาย |
| $b$ | Bias หรือค่าตั้งต้นของสมการ |
| $\hat{y}$ | ค่าที่โมเดลทำนาย |

ตัวอย่างสมการราคาบ้าน หน่วยเป็นล้านบาท:

$$
\hat{y}=0.02x+1
$$

ถ้าบ้านมีพื้นที่ 80 ตารางเมตร:

$$
\hat{y}=0.02(80)+1=2.6
$$

โมเดลจึงทำนายราคา 2.6 ล้านบาท

## 2. โมเดลเรียนรู้ Weight และ Bias อย่างไร?

เรามีข้อมูลตัวอย่าง:

| พื้นที่ | ราคาจริง |
|---:|---:|
| 50 | 2 ล้านบาท |
| 100 | 3 ล้านบาท |
| 150 | 4 ล้านบาท |

Linear Regression จะค้นหาค่า $w$ และ $b$ ที่ทำให้ค่าทำนายใกล้ค่าจริง โดยพยายามลดผลรวมความผิดพลาดกำลังสอง:

$$
\text{Sum of squared errors}
=
\sum_{i=1}^{n}(y_i-\hat{y}_i)^2
$$

วิธีนี้เรียกว่า **Least Squares**

เหตุผลที่ยกกำลังสองคือ:

- ป้องกันความผิดพลาดค่าบวกกับค่าลบหักล้างกัน
- ให้ความผิดพลาดขนาดใหญ่มีผลมากขึ้น
- ทำให้หาค่า Weight และ Bias ที่เหมาะสมได้สะดวก

## 3. ตัวอย่าง Python: ฝึกและทำนาย

```python
import numpy as np
from sklearn.linear_model import LinearRegression

# X ต้องเป็นตาราง 2 มิติ
# แต่ละแถวคือบ้านหนึ่งหลัง แต่ละคอลัมน์คือ Feature หนึ่งตัว
X = np.array([
    [50],
    [100],
    [150],
])

# Target: ราคาจริง หน่วยเป็นล้านบาท
y = np.array([2, 3, 4])

model = LinearRegression()
model.fit(X, y)

new_house = np.array([[80]])
prediction = model.predict(new_house)

print("Weight:", model.coef_[0])
print("Bias:", model.intercept_)
print("ราคาที่ทำนาย:", prediction[0], "ล้านบาท")
```

ผลลัพธ์จะใกล้เคียง:

```text
Weight: 0.02
Bias: 1.0
ราคาที่ทำนาย: 2.6 ล้านบาท
```

คำสั่งสำคัญ:

| คำสั่ง | หน้าที่ |
|---|---|
| `model.fit(X, y)` | เรียนรู้ Weight และ Bias |
| `model.predict(X_new)` | ทำนายข้อมูลใหม่ |
| `model.coef_` | ดู Weight ที่เรียนรู้ได้ |
| `model.intercept_` | ดู Bias ที่เรียนรู้ได้ |

## 4. Linear Regression ที่มีหลาย Features

ถ้าใช้พื้นที่ อายุบ้าน และระยะทางจากสถานี สมการจะเป็น:

$$
\hat{y}=w_1x_1+w_2x_2+w_3x_3+b
$$

แต่ละ Feature มี Weight ของตัวเอง:

```python
import numpy as np
from sklearn.linear_model import LinearRegression

X = np.array([
    # พื้นที่, อายุบ้าน, ระยะทางจากสถานี
    [50, 10, 2.0],
    [70, 8, 1.8],
    [100, 5, 1.0],
    [120, 4, 0.8],
    [150, 2, 0.5],
])

y = np.array([2.0, 2.4, 3.1, 3.5, 4.2])

model = LinearRegression()
model.fit(X, y)

new_house = np.array([[80, 4, 1.5]])
prediction = model.predict(new_house)

print("Weights:", model.coef_)
print("Bias:", model.intercept_)
print("ราคาที่ทำนาย:", prediction[0])
```

Weight บวกหมายถึงเมื่อ Feature เพิ่ม ค่าทำนายมีแนวโน้มเพิ่ม หาก Features อื่นคงที่ ส่วน Weight ลบหมายถึงค่าทำนายมีแนวโน้มลด

การเปรียบเทียบขนาด Weight โดยตรงอาจทำให้เข้าใจผิดเมื่อ Features ใช้หน่วยต่างกัน เช่น ตารางเมตร ปีกับกิโลเมตร

## 5. รู้ได้อย่างไรว่าความสัมพันธ์ค่อนข้างเป็นเส้นตรง?

ไม่มีการตรวจเพียงอย่างเดียวที่ตอบได้สมบูรณ์ ควรดูหลักฐานหลายอย่างร่วมกัน

### 5.1 ดู Scatter Plot

```python
import matplotlib.pyplot as plt
import numpy as np
from sklearn.linear_model import LinearRegression

X = np.array([[50], [70], [90], [110], [130]])
y = np.array([2.0, 2.3, 2.8, 3.1, 3.6])

model = LinearRegression()
model.fit(X, y)
predictions = model.predict(X)

order = np.argsort(X[:, 0])

plt.scatter(X[:, 0], y, label="ข้อมูลจริง")
plt.plot(
    X[order, 0],
    predictions[order],
    label="Linear Regression",
)
plt.xlabel("พื้นที่บ้าน")
plt.ylabel("ราคา")
plt.legend()
plt.show()
```

หากจุดมีแนวโน้มไปในทิศทางเดียวกับเส้นตรง โมเดลอาจเป็นจุดเริ่มต้นที่เหมาะสม จุดไม่จำเป็นต้องอยู่บนเส้นทั้งหมด

### 5.2 ดู Residual Plot

Residual คือค่าที่โมเดลทำนายพลาด:

$$
\text{Residual}=y-\hat{y}
$$

```python
residuals = y - predictions

plt.scatter(predictions, residuals)
plt.axhline(0, color="red")
plt.xlabel("ค่าที่โมเดลทำนาย")
plt.ylabel("Residual")
plt.show()
```

สิ่งที่ควรสังเกต:

- กระจายรอบเส้นศูนย์โดยไม่มีรูปแบบชัดเจน: เส้นตรงอาจเหมาะสม
- เป็นรูปตัว U หรือเป็นคลื่น: อาจมีความสัมพันธ์แบบโค้ง
- กระจายกว้างขึ้นคล้ายกรวย: ขนาดความผิดพลาดอาจเปลี่ยนตามระดับค่าทำนาย
- มีจุดอยู่ไกลมาก: ควรตรวจ Outlier และคุณภาพข้อมูล

### 5.3 วัดผลด้วย Validation หรือ Cross-validation

อย่าตัดสินจากกราฟอย่างเดียว ให้ดูคะแนนบนข้อมูลที่โมเดลไม่เคยใช้ฝึกด้วย:

```python
import numpy as np
from sklearn.linear_model import LinearRegression
from sklearn.model_selection import KFold, cross_val_score

X = np.array([[50], [70], [90], [110], [130]])
y = np.array([2.0, 2.3, 2.8, 3.1, 3.6])

cv = KFold(
    n_splits=5,
    shuffle=True,
    random_state=42,
)

model = LinearRegression()

negative_mse = cross_val_score(
    model,
    X,
    y,
    cv=cv,
    scoring="neg_mean_squared_error",
)

rmse_each_fold = np.sqrt(-negative_mse)
print("RMSE แต่ละ Fold:", rmse_each_fold)
print("RMSE เฉลี่ย:", rmse_each_fold.mean())
```

หาก Linear Regression ให้คะแนนใกล้เคียงโมเดลที่ซับซ้อนกว่า มักควรเริ่มจาก Linear Regression เพราะอธิบายและตรวจสอบง่าย

## 6. Correlation อย่างเดียวเพียงพอหรือไม่?

ไม่เพียงพอ Correlation ช่วยวัดความสัมพันธ์เชิงเส้น แต่ไม่สามารถบอกความสัมพันธ์ทุกชนิดได้

```python
import pandas as pd

df = pd.DataFrame({
    "area": [50, 70, 90, 110, 130],
    "price": [2.0, 2.3, 2.8, 3.1, 3.6],
})

correlation = df["area"].corr(df["price"])
print(correlation)
```

- ค่าใกล้ `1`: มีแนวโน้มเพิ่มไปด้วยกันแบบเชิงเส้น
- ค่าใกล้ `-1`: ตัวหนึ่งเพิ่ม อีกตัวมีแนวโน้มลดแบบเชิงเส้น
- ค่าใกล้ `0`: ไม่มีความสัมพันธ์เชิงเส้นชัดเจน แต่ยังอาจมีความสัมพันธ์แบบโค้ง

ดังนั้นควรใช้ Scatter Plot, Residual Plot และคะแนน Validation ร่วมกัน

## 7. แบ่งข้อมูลและประเมินโมเดลแบบครบขั้นตอน

```python
import numpy as np
from sklearn.linear_model import LinearRegression
from sklearn.metrics import mean_squared_error
from sklearn.model_selection import train_test_split

X = np.array([
    [50], [60], [70], [80], [90],
    [100], [110], [120], [130], [140],
])
y = np.array([2.0, 2.1, 2.4, 2.5, 2.8, 3.0, 3.1, 3.4, 3.5, 3.8])

X_train, X_test, y_train, y_test = train_test_split(
    X,
    y,
    test_size=0.2,
    random_state=42,
)

model = LinearRegression()
model.fit(X_train, y_train)

predictions = model.predict(X_test)
rmse = np.sqrt(mean_squared_error(y_test, predictions))

print("ค่าจริง:", y_test)
print("ค่าทำนาย:", predictions)
print("Test RMSE:", rmse)
```

ลำดับที่ควรจำคือ:

1. แบ่งข้อมูล
2. `fit()` ด้วย Train
3. `predict()` ด้วย Test
4. เปรียบเทียบค่าทำนายกับคำตอบจริง

## 8. `random_state` อยู่ตรงไหน?

`LinearRegression` แบบปกติไม่มีขั้นตอนสุ่ม จึงไม่มี `random_state`:

```python
model = LinearRegression()
```

แต่การแบ่งข้อมูลมีการสุ่ม จึงกำหนด seed ที่ `train_test_split()`:

```python
X_train, X_test, y_train, y_test = train_test_split(
    X,
    y,
    test_size=0.2,
    random_state=42,
)
```

Seed ตรงนี้ควบคุมว่าแถวใดอยู่ Train หรือ Test ไม่ได้ควบคุมการฝึกของ `LinearRegression`

## 9. ข้อจำกัดและข้อผิดพลาดที่พบบ่อย

### ความสัมพันธ์เป็นเส้นโค้ง

เส้นตรงเส้นเดียวอาจจับรูปแบบที่โค้งมากไม่ได้ ให้ตรวจ Residual Plot และเปรียบเทียบกับโมเดลอื่น

### Outlier ดึงเส้นออกจากข้อมูลส่วนใหญ่

เพราะโมเดลยกกำลังสองความผิดพลาด จุดที่อยู่ไกลจึงมีผลมาก ควรตรวจว่าจุดนั้นเป็นข้อมูลจริงหรือความผิดพลาดในการบันทึก

### ทำนายนอกช่วงข้อมูล

ถ้าฝึกด้วยบ้านขนาด 50–150 ตารางเมตร แล้วนำไปทำนายบ้าน 1,000 ตารางเมตร โมเดลกำลังต่อเส้นออกไปไกลเกินช่วงที่เคยเห็น ผลอาจไม่น่าเชื่อถือ

### ส่ง `X` ผิดรูปทรง

scikit-learn ต้องการ `X` เป็นตารางสองมิติ แม้มี Feature เดียว:

```python
X = np.array([[50], [100], [150]])  # ถูก
```

ไม่ใช่:

```python
X = np.array([50, 100, 150])  # เป็นข้อมูลหนึ่งมิติ
```

### ใช้คะแนนจาก Train เป็นคำตอบสุดท้าย

คะแนน Train บอกว่าโมเดลอธิบายข้อมูลที่เคยเห็นได้ดีเพียงใด แต่ไม่ได้บอกว่าจะทำนายข้อมูลใหม่ได้ดีแค่ไหน ต้องประเมินด้วย Validation, Cross-validation หรือ Test

## 10. Checklist ก่อนใช้ Linear Regression

- Target เป็นตัวเลขต่อเนื่อง
- ดู Scatter Plot ของ Features สำคัญแล้ว
- Residual ไม่มีรูปแบบโค้งชัดเจน
- ตรวจ Outliers และค่าผิดปกติแล้ว
- แยก Train และ Test ก่อนฝึก
- วัดผลด้วย MSE หรือ RMSE บนข้อมูลที่ไม่ได้ใช้ฝึก
- เปรียบเทียบกับ Baseline หรือโมเดลอื่น
- ระวังการทำนายนอกช่วงข้อมูลที่เคยเห็น

---

[← บทที่ 1: โมเดลเรียนรู้อะไร?](model-learning.md) · [สารบัญ](../ML/index.md) · [บทที่ 3: MSE และ RMSE →](mse-rmse.md)

