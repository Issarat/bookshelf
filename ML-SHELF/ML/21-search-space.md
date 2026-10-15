# 21. Search Space: เลือกช่วงค่าที่จะค้นหา


**Search space คือรายการค่าหรือช่วงค่าที่ให้ระบบค้นหา** เช่น:

```python
param_grid = {
    "max_depth": [3, 5, 10],
    "n_estimators": [50, 100],
}
```

ตัวอย่างนี้มีความลึก 3 ค่า และจำนวนต้นไม้ 2 ค่า จึงมีทั้งหมด:

$$
3\times2=6\text{ combinations}
$$

เริ่มจากช่วงกว้างที่มีเหตุผลตามโมเดล แล้วค่อยปรับตามผล เช่น ถ้าความลึก 10 ให้คะแนนดี อาจลอง 8, 10 และ 12 ในรอบถัดไป หากค่าที่ดีที่สุดอยู่ขอบช่วง ให้พิจารณาขยายช่วงก่อน

สำหรับค่าบางตัว เช่น `alpha` ของ Ridge อาจลองแบบเพิ่มทีละ 10 เท่า:

$$
0.01\rightarrow0.1\rightarrow1\rightarrow10\rightarrow100
$$

เรียกว่า **log scale** ช่วยสำรวจทั้งค่าที่เล็กและใหญ่ โดยไม่ต้องไล่เพิ่มทีละนิด

เลือก GridSearchCV เมื่อลองครบได้สะดวก เลือก RandomizedSearchCV เมื่อช่วงค้นหาใหญ่และต้องจำกัดจำนวนชุด ทั้งนี้แต่ละชุดอาจใช้เวลาฝึกต่างกัน จำนวน fits จึงไม่ได้บอกเวลาแน่นอน

## ตัวอย่าง Python: สร้างและนับ Search Space

```python
import numpy as np
from sklearn.model_selection import ParameterGrid

param_grid = {
    "max_depth": [3, 5, 10],
    "n_estimators": [50, 100],
}

combinations = list(ParameterGrid(param_grid))
print("จำนวนชุด:", len(combinations))  # 6
print("ชุดแรก:", combinations[0])

# สร้างค่า alpha 6 ค่า ตั้งแต่ 0.001 ถึง 100 แบบ Log scale
alpha_values = np.logspace(-3, 2, 6)
print("alpha:", alpha_values)
```

`ParameterGrid` มีประโยชน์สำหรับตรวจจำนวนชุดก่อนเริ่มฝึก ส่วน `np.logspace()` ช่วยสร้างค่าที่เพิ่มเป็นสัดส่วน แทนการเพิ่มทีละค่าคงที่

---

[← บทก่อนหน้า: Hyperparameter คือค่าที่เราเลือกให้โมเดล](20-hyperparameter-tuning.md) · [สารบัญ](index.md) · [บทถัดไป: Class Imbalance และการเลือก Threshold →](22-class-imbalance-threshold.md)
