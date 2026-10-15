# 6. จะรู้ได้อย่างไรว่าทำนายราคาพลาดแค่ไหน?


ลองดูบ้าน 2 หลัง โดยใช้หน่วยราคาเป็นล้านบาท:

| บ้าน | ราคาจริง | ราคาทำนาย | ผลต่าง: จริง − ทำนาย | ผลต่างยกกำลังสอง |
|---|---:|---:|---:|---:|
| A | 3 | 2 | 1 | 1 |
| B | 5 | 7 | −2 | 4 |

ถ้าเอาผลต่างมาบวกกันตรง ๆ ค่าบวกกับค่าลบอาจหักล้างกัน เราจึงยกกำลังสองก่อน แล้วค่อยหาค่าเฉลี่ย

## MSE: ค่าเฉลี่ยของความผิดพลาดกำลังสอง

วิธีคิดมี 3 ขั้น:

1. ลบราคาจริงกับราคาทำนายของแต่ละหลัง
2. ยกกำลังสองผลต่างแต่ละค่า
3. รวมผลแล้วหารด้วยจำนวนบ้าน

$$
\mathrm{MSE}=\frac{1^2+(-2)^2}{2}=\frac{5}{2}=2.5
$$

> [!IMPORTANT]
> MSE ยิ่งต่ำยิ่งดี และการยกกำลังสองทำให้ความผิดพลาดขนาดใหญ่มีผลมากขึ้น

## RMSE: ถอดรากเพื่อกลับมาเป็นหน่วยราคา

$$
\mathrm{RMSE}=\sqrt{\mathrm{MSE}}=\sqrt{2.5}\approx1.58
$$

RMSE ของตัวอย่างนี้ประมาณ **1.58 ล้านบาท** เป็นตัววัดขนาดความผิดพลาดที่มีหน่วยเดียวกับราคา แต่ไม่ใช่ค่าเฉลี่ยของผลต่างแบบค่าสัมบูรณ์

> [!NOTE]
> MSE และ RMSE ใช้วัดความผิดพลาดในการทำนายตัวเลข ค่าน้อยกว่าดีกว่า

## ตัวอย่าง Python: คำนวณเองและตรวจด้วย scikit-learn

```python
import numpy as np
from sklearn.metrics import mean_squared_error

y_true = np.array([3, 5])
y_pred = np.array([2, 7])

# คำนวณตามสูตรทีละขั้น
errors = y_true - y_pred
squared_errors = errors ** 2
mse_manual = squared_errors.mean()
rmse_manual = np.sqrt(mse_manual)

# ใช้ฟังก์ชันจาก scikit-learn ตรวจคำตอบ
mse_sklearn = mean_squared_error(y_true, y_pred)
rmse_sklearn = np.sqrt(mse_sklearn)

print("Errors:", errors)                 # [1, -2]
print("Squared errors:", squared_errors) # [1, 4]
print("MSE:", mse_manual)                # 2.5
print("RMSE:", rmse_manual)              # ประมาณ 1.58
print("ตรงกับ sklearn:", mse_manual == mse_sklearn)
```

---

[← บทก่อนหน้า: Baseline: เกณฑ์ขั้นต่ำสำหรับเปรียบเทียบโมเดล](05-baseline.md) · [สารบัญ](index.md) · [บทถัดไป: Metrics สำหรับ Regression →](07-regression-metrics.md)
