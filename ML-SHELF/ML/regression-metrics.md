# 11. Metrics สำหรับ Regression

Regression ทำนายตัวเลขต่อเนื่อง การเลือก Metric ต้องสัมพันธ์กับผลกระทบของความผิดพลาด

สมมติ:

```text
ค่าจริง     = [100, 200, 300]
ค่าทำนาย   = [110, 180, 360]
ความผิดพลาด = [10, -20, 60]
```

## 1. MAE

$$
\operatorname{MAE}=\frac{1}{n}\sum_{i=1}^{n}|y_i-\hat{y}_i|
$$

แทนค่า:

$$
\operatorname{MAE}=\frac{10+20+60}{3}=30
$$

MAE อ่านง่ายเพราะมีหน่วยเดียวกับ Target และให้ความสำคัญกับความผิดพลาดแต่ละแถวแบบเส้นตรง

## 2. MSE และ RMSE

$$
\operatorname{MSE}=\frac{1}{n}\sum_{i=1}^{n}(y_i-\hat{y}_i)^2
$$

$$
\operatorname{RMSE}=\sqrt{\operatorname{MSE}}
$$

การยกกำลังสองทำให้ความผิดพลาดขนาดใหญ่มีผลมากขึ้น RMSE กลับมาอยู่ในหน่วยเดียวกับ Target

## 3. MAPE

$$
\operatorname{MAPE}
=\frac{100}{n}\sum_{i=1}^{n}
\left|\frac{y_i-\hat{y}_i}{y_i}\right|
$$

MAPE แสดงเป็นเปอร์เซ็นต์จึงสื่อสารง่าย แต่มีปัญหาเมื่อค่าจริงเท่ากับหรือใกล้ศูนย์ เพราะตัวหารทำให้ค่ารุนแรงหรือไม่สามารถคำนวณตามสูตรตรง ๆ ได้

> [!CAUTION]
> ห้ามเลือก MAPE เพียงเพราะอ่านเป็นเปอร์เซ็นต์ ต้องตรวจช่วงค่าของ Target ก่อนเสมอ

## 4. $R^2$

$$
R^2
=1-
\frac{\sum_{i=1}^{n}(y_i-\hat{y}_i)^2}
{\sum_{i=1}^{n}(y_i-\bar{y})^2}
$$

| ค่า | ความหมายโดยย่อ |
|---:|---|
| 1 | ทำนายข้อมูลชุดนี้ได้สมบูรณ์ |
| 0 | ไม่ดีกว่าการทำนายด้วยค่าเฉลี่ย |
| น้อยกว่า 0 | แย่กว่าการทำนายด้วยค่าเฉลี่ย |

$R^2$ ไม่มีหน่วย แต่ไม่ได้บอกว่าพลาดกี่บาทหรือกี่หน่วย จึงควรดูร่วมกับ MAE หรือ RMSE

## 5. คำนวณด้วย Python

```python
import numpy as np
from sklearn.metrics import (
    mean_absolute_error,
    mean_absolute_percentage_error,
    mean_squared_error,
    r2_score,
)

y_true = np.array([100, 200, 300])
y_pred = np.array([110, 180, 360])

mae = mean_absolute_error(y_true, y_pred)
mse = mean_squared_error(y_true, y_pred)
rmse = np.sqrt(mse)
mape = mean_absolute_percentage_error(y_true, y_pred) * 100
r2 = r2_score(y_true, y_pred)

print("MAE:", mae)
print("MSE:", mse)
print("RMSE:", rmse)
print("MAPE (%):", mape)
print("R²:", r2)
```

## 6. เลือก Metric อย่างไร?

| เป้าหมาย                                            | Metric ที่ควรพิจารณา |
| --------------------------------------------------- | -------------------- |
| ต้องการความผิดพลาดเฉลี่ยที่อ่านง่าย                 | MAE                  |
| ความผิดพลาดขนาดใหญ่มีต้นทุนสูง                      | RMSE                 |
| ต้องการสื่อสารเป็นเปอร์เซ็นต์และค่าจริงไม่ใกล้ศูนย์ | MAPE                 |
| ต้องการเทียบกับ Baseline ค่าเฉลี่ย                  | $R^2$                |

Metric สำหรับเลือกโมเดลควรตรงกับสิ่งที่ธุรกิจต้องการลด และควรรายงานมากกว่าหนึ่งค่าเมื่อแต่ละ Metric แสดงความเสี่ยงคนละด้าน

## 7. แหล่งอ้างอิง

- [scikit-learn: Regression metrics](https://scikit-learn.org/stable/modules/model_evaluation.html#regression-metrics)
- [scikit-learn: mean_absolute_error](https://scikit-learn.org/stable/modules/generated/sklearn.metrics.mean_absolute_error.html)
- [scikit-learn: r2_score](https://scikit-learn.org/stable/modules/generated/sklearn.metrics.r2_score.html)

---

[← บทก่อนหน้า: จะรู้ได้อย่างไรว่าทำนายราคาพลาดแค่ไหน?](mse-rmse.md) | [สารบัญ](index.md) | [บทถัดไป: วัดผลโมเดล Classification อย่างไร? →](classification-metrics.md)
