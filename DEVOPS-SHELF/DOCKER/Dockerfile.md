---
title: "Writing Dockerfiles"
tags: [docker, dockerfile, devops]
source: "https://devopsvn.tech/docker-03-dockerfile/"
---

# Writing Dockerfiles

สรุปจาก [Writing Dockerfiles — DevOps VN](https://devopsvn.tech/docker-03-dockerfile/)

Dockerfile คือสูตรสร้าง Image โดยลำดับคำสั่งมีผลต่อ Cache และความเร็วในการ Build

## คำสั่งหลัก

| คำสั่ง | หน้าที่ |
| --- | --- |
| FROM | เลือก Base Image |
| WORKDIR | กำหนดโฟลเดอร์ทำงาน |
| COPY | คัดลอกไฟล์เข้า Image |
| ADD | เพิ่มไฟล์ พร้อมความสามารถพิเศษ เช่น แตก tar |
| RUN | รันคำสั่งตอน Build |
| ENV | กำหนดตัวแปรสภาพแวดล้อม |
| EXPOSE | ระบุพอร์ต โดยยังไม่เผยแพร่พอร์ต |
| CMD | คำสั่งเริ่มต้นตอนรัน Container |
| ENTRYPOINT | โปรแกรมหลัก โดยใช้ CMD เป็น Arguments เริ่มต้นได้ |
| USER | กำหนดผู้ใช้สำหรับคำสั่งถัดไปและตอนรัน |

## ตัวอย่าง Python

ต้องมี app.py และ requirements.txt ใน Build Context:

```dockerfile
FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
CMD ["python", "app.py"]
```

ติดตั้ง Dependencies ก่อนคัดลอกโค้ดทั้งหมด เมื่อเปลี่ยนเฉพาะโค้ดจึงมีโอกาสใช้ Cache การติดตั้งเดิมได้ เลือก CMD แบบ JSON Array เพื่อรันโปรแกรมโดยตรง

## RUN ต่างจาก CMD

RUN ทำงานระหว่างสร้าง Image ส่วน CMD กำหนดสิ่งที่จะทำเมื่อเริ่ม Container

## Multi-stage Build

แยก Stage สำหรับ Build ออกจาก Stage สำหรับรัน แล้วใช้ COPY --from นำเฉพาะผลลัพธ์ที่จำเป็นมาใช้ ช่วยลดเครื่องมือ Build ใน Image สุดท้าย

## แนวทางสำคัญ

- เลือก Base Image ให้เหมาะกับ Dependencies
- รวมคำสั่งติดตั้งและล้างไฟล์ชั่วคราวใน RUN เดียวกัน
- ใช้ .dockerignore ลดไฟล์ที่ไม่จำเป็น
- ใช้ผู้ใช้ที่ไม่ใช่ root และไม่ฝัง Secrets ใน Image
- ระบุเวอร์ชันและสแกนช่องโหว่

หมายเหตุเพิ่มเติม: Tag ยังเปลี่ยนปลายทางได้ หากต้องตรึงเนื้อหา Image ให้ใช้ Digest

บทก่อนหน้า: [Docker Images](DockerImages.md)
