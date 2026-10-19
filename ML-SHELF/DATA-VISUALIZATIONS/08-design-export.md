# 8. ออกแบบและส่งออกกราฟ

กราฟที่ถูกต้องทางคณิตศาสตร์อาจยังสื่อสารผิดได้ หากแกน สี หรือช่วงข้อมูลทำให้ผู้ชมตีความเกินหลักฐาน

## ชื่อกราฟและแกน

ชื่อกราฟควรบอกคำถามหรือข้อค้นพบ ชื่อแกนต้องมีหน่วย:

```python
import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns

data = pd.DataFrame({
    "income": [18000, 30000, 42000, 55000],
    "spending": [5000, 9000, 15000, 18000],
})

sns.scatterplot(data=data, x="income", y="spending")
plt.title("Monthly spending tends to rise with income")
plt.xlabel("Monthly income (THB)")
plt.ylabel("Monthly spending (THB)")
plt.tight_layout()
plt.show()
```

## การใช้สี

- ใช้สีเดียวเมื่อทุกจุดมีความหมายเดียวกัน
- ใช้สีแบบ Categorical กับกลุ่มที่ไม่มีลำดับ
- ใช้สีแบบ Sequential กับค่าจากน้อยไปมาก
- ใช้สีแบบ Diverging เมื่อมีจุดกึ่งกลาง เช่น Correlation ที่ศูนย์
- เลือก Palette ที่ผู้มีภาวะตาบอดสีแยกได้
- อย่าใช้สีรุ้งกับข้อมูลต่อเนื่อง เพราะความสว่างไม่เรียงสม่ำเสมอ

## กราฟที่ทำให้เข้าใจผิด

### ตัดแกน Bar chart

แท่งใช้ความยาวแทนขนาด การเริ่มแกนที่ 95 อาจทำให้ 98 กับ 100 ดูต่างกันมาก ควรเริ่มที่ศูนย์

### แกน Y สองชุด

Dual-axis chart ปรับ Scale ให้สองเส้นดูสัมพันธ์กันได้ง่าย ควรใช้กราฟย่อยหรือ Normalize พร้อมอธิบาย

### เลือกเฉพาะช่วงเวลา

การเลือกช่วงที่กราฟขึ้นหรือลงอาจสนับสนุนข้อสรุปที่กำหนดไว้ล่วงหน้า ต้องบอกเหตุผลของช่วงเวลาและแสดงบริบท

### ใช้พื้นที่หรือ 3 มิติ

มนุษย์เทียบความยาวได้แม่นกว่าพื้นที่และปริมาตร หากต้องเปรียบเทียบค่าทั่วไป Bar chart มักอ่านง่ายกว่า Bubble หรือกราฟ 3 มิติ

## Annotation

ใช้เส้นอ้างอิงหรือข้อความเมื่อช่วยตอบคำถาม:

```python
sns.scatterplot(data=data, x="income", y="spending")
plt.axvline(40000, linestyle="--", color="gray", label="Target income")
plt.legend()
plt.show()
```

Annotation มากเกินไปจะกลบข้อมูล ควรเน้นเฉพาะเหตุการณ์หรือจุดที่เกี่ยวข้องกับข้อสรุป

## บันทึกกราฟ

```python
plt.figure(figsize=(8, 5))
sns.scatterplot(data=data, x="income", y="spending")
plt.title("Income and spending")
plt.tight_layout()
plt.savefig(
    "income-spending.png",
    dpi=150,
    bbox_inches="tight",
)
plt.close()
```

- PNG เหมาะกับหน้าจอและภาพที่มีรายละเอียดแบบ Raster
- SVG/PDF เหมาะกับกราฟ Vector ที่ต้องขยายหรือพิมพ์
- `dpi=150` มักพอสำหรับหน้าจอ งานพิมพ์อาจใช้ 300
- ใช้ `bbox_inches="tight"` ลดปัญหาข้อความถูกตัด
- เรียก `plt.close()` เมื่อสร้างหลายรูปใน Script

## ทำให้สร้างซ้ำได้

ควรเก็บ:

- โค้ดและเวอร์ชันไลบรารี
- แหล่งข้อมูลและเวลาที่ดึงข้อมูล
- ขั้นตอนกรองและ Aggregate
- หน่วย Bins, Window และ Scale
- Palette, ขนาด Figure และรูปแบบไฟล์

## Checklist ก่อนเผยแพร่

- กราฟตอบคำถามที่ตั้งไว้
- ชื่อแกน หน่วย Legend และช่วงเวลาครบ
- จำนวนข้อมูลและกลุ่มย่อยเหมาะสม
- แกนและสีไม่ทำให้ความต่างเกินจริง
- ข้อสรุปไม่กล่าวถึงเหตุและผลจาก Correlation อย่างเดียว
- สร้างกราฟซ้ำจากโค้ดได้

## แหล่งอ้างอิง

- [Matplotlib: Tutorials](https://matplotlib.org/stable/tutorials/index.html)
- [Seaborn: User guide](https://seaborn.pydata.org/tutorial.html)
- [Pandas: Chart visualization](https://pandas.pydata.org/docs/user_guide/visualization.html)

---

[← บทก่อนหน้า](07-model-evaluation.md) | [สารบัญ](index.md) | [กลับไปหลักสูตร ML](../ML/data-visualization.md)
