---
title: "Smaller Docker Images with Multi-Stage Builds"
tags: [docker, multi-stage, image-optimization]
source: "https://devopsvn.tech/docker-advanced-02-image-optimization/"
---

# Image Optimization

สรุปจาก [Smaller Docker Images with Multi-Stage Builds — DevOps VN](https://devopsvn.tech/docker-advanced-02-image-optimization/)

เป้าหมายคือให้ Image สุดท้ายมีเฉพาะสิ่งที่จำเป็นสำหรับรัน พร้อมรักษาความเข้ากันได้ ไม่ใช่ลดขนาดให้เล็กที่สุดเสมอไป

## แยก Build กับ Runtime

| Stage | สิ่งที่ต้องมี |
| --- | --- |
| Build | Source, Dependencies และเครื่องมือสร้างผลลัพธ์ |
| Runtime | Runtime, Production Dependencies และผลลัพธ์ที่แอปใช้ |

ใช้ COPY --from เลือกนำผลลัพธ์ข้าม Stage โดยไม่คัดลอกทั้งโฟลเดอร์ Build

## Cache และ Build Context

คัดลอก package.json กับ Lockfile ก่อนติดตั้ง Dependencies แล้วค่อยคัดลอก Source ใช้ .dockerignore ตัด node_modules และ dist จากเครื่อง เพื่อไม่ให้ทับผลลัพธ์ที่สร้างภายใน Docker

## ทดลองตรวจ Image

รันจากโฟลเดอร์ตัวอย่างต้นฉบับที่มี Dockerfile และ Stage ชื่อ build:

```powershell
docker build -t practice-runtime:local .
docker build --target build -t practice-builder:local .
docker image ls
docker history practice-runtime:local
docker run --rm practice-runtime:local
```

เปรียบเทียบขนาดและไฟล์จริงระหว่างสอง Image ตัวอย่างเล็กอาจไม่ได้ลดขนาดมาก

## ปัญหาที่ต้องระวัง

หาก Build ผ่านแต่รันไม่ได้ ให้ตรวจไฟล์และ Dependencies ที่ Runtime ต้องใช้ แก้ด้วยการเพิ่มเฉพาะสิ่งที่ขาด ไม่คัดลอกทั้ง Build Stage กลับมา

Alpine อาจมีปัญหากับ Native Dependencies จึงต้องทดสอบ Image ที่จะ Deploy จริง

## ข้อชี้แจงเพิ่มเติม

- Multi-stage ไม่รับประกันว่า Base Image จะไม่มี Shell หรือ Package Manager
- Build อาจช้าขึ้นจากการติดตั้ง Dependencies แยกสองชุด ใช้ Cache ช่วยได้
- Image เล็กไม่ได้รับประกันความปลอดภัย ต้องอัปเดตและตรวจช่องโหว่ด้วย

บทก่อนหน้า: [BuildKit](BuildKit.md)
