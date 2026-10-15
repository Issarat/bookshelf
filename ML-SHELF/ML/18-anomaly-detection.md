# 18. Anomaly Detection

Anomaly Detection คือการค้นหาแถวที่แตกต่างจากรูปแบบส่วนใหญ่ เหมาะกับการตรวจธุรกรรมผิดปกติ เครื่องจักรเสีย หรือข้อมูลจาก Sensor ที่ผิดธรรมชาติ

## Outlier Detection กับ Novelty Detection

- **Outlier detection:** ข้อมูล Train อาจมีค่าผิดปกติปะปน
- **Novelty detection:** Train ควรเป็นข้อมูลปกติ แล้วตรวจข้อมูลใหม่ว่าแปลกหรือไม่

## วิธีที่พบบ่อย

| วิธี | แนวคิด |
|---|---|
| Isolation Forest | จุดผิดปกติถูกแยกออกด้วยการสุ่มได้ง่าย |
| Local Outlier Factor | เปรียบเทียบความหนาแน่นกับเพื่อนบ้าน |
| One-Class SVM | สร้างขอบเขตครอบข้อมูลปกติ |

## Isolation Forest

```python
from sklearn.ensemble import IsolationForest
from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler

model = make_pipeline(
    StandardScaler(),
    IsolationForest(
        contamination=0.02,
        random_state=42,
    ),
)

labels = model.fit_predict(X_train)
# 1 หมายถึง Inlier และ -1 หมายถึง Outlier
```

`contamination` คือสัดส่วน Outliers ที่คาดไว้ ใช้ความรู้ของงานหรือ Validation ช่วยเลือก ไม่ควรเดาเพื่อให้ได้จำนวนแจ้งเตือนที่ต้องการเพียงอย่างเดียว

## เมื่อมี Label

ถ้ามีคำตอบว่ารายการใดผิดปกติ ให้ประเมินเป็น Classification โดยเน้น Precision, Recall, PR curve และต้นทุนของ False alarms

ถ้าไม่มี Label ให้ตรวจ:

- ตัวอย่างที่โมเดลจัดว่าแปลก
- ความเสถียรเมื่อเปลี่ยนข้อมูลหรือ Parameters
- อัตราการแจ้งเตือนตามเวลา
- การยืนยันจากผู้เชี่ยวชาญของงาน

## ข้อควรระวัง

- Anomaly ไม่ได้แปลว่า Fraud หรือความผิดพลาดเสมอไป
- Scale สำคัญกับวิธีที่ใช้ระยะทาง
- Category และ Missing values ต้องจัดการก่อน
- Distribution เปลี่ยนตามเวลาอาจเพิ่ม False alarms
- อย่าให้ข้อมูลอนาคตรั่วเข้า Train

## Checklist

- นิยาม “ผิดปกติ” กับเจ้าของงาน
- สร้างกฎง่ายเป็น Baseline
- เลือกวิธีให้ตรงกับข้อมูลและขนาดข้อมูล
- ตรวจตัวอย่างจริง ไม่ดูคะแนนอย่างเดียว
- กำหนดขั้นตอนเมื่อระบบแจ้งเตือน
- ติดตามอัตราแจ้งเตือนและ Data drift

## แหล่งอ้างอิง

- [scikit-learn: Novelty and Outlier Detection](https://scikit-learn.org/stable/modules/outlier_detection.html)
- [scikit-learn: IsolationForest](https://scikit-learn.org/stable/modules/generated/sklearn.ensemble.IsolationForest.html)

---

[← บทก่อนหน้า: Outliers: ค่าที่ห่างจากข้อมูลส่วนใหญ่](17-outliers.md) · [สารบัญ](index.md) · [บทถัดไป: Feature Engineering →](19-feature-engineering.md)
