---
title: "Harden Docker Containers at Runtime"
tags: [docker, security, compose]
source: "https://devopsvn.tech/docker-advanced-03-container-security/"
---

# Container Security

สรุปจาก [Harden Docker Containers at Runtime — DevOps VN](https://devopsvn.tech/docker-advanced-03-container-security/)

Image เป็นจุดตั้งต้น แต่ Runtime Configuration กำหนดสิทธิ์จริงของ Container ควรให้แอปเฉพาะสิ่งที่ต้องใช้

## ข้อจำกัดหลัก

| การตั้งค่า | หน้าที่ |
| --- | --- |
| Non-root USER | ลดสิทธิ์ของ Process |
| read_only: true | ป้องกันการเขียน Root Filesystem |
| tmpfs | เปิดพื้นที่ชั่วคราวที่เขียนได้ |
| cap_drop: [ALL] | ตัด Linux Capabilities เริ่มต้น |
| no-new-privileges:true | ปิดช่องทางเพิ่มสิทธิ์บางประเภท |

## ตัวอย่าง Policy

```yaml
services:
  api:
    image: your-api:local
    read_only: true
    tmpfs:
      - /tmp
    cap_drop:
      - ALL
    security_opt:
      - no-new-privileges:true
```

แทนชื่อ Image ด้วยแอปของคุณที่กำหนด Non-root USER แล้ว ตัวอย่างนี้เป็น Policy ไม่ใช่แอปพร้อมรัน

## ตรวจสอบ

```powershell
docker compose config
docker image inspect your-api:local --format '{{.Config.User}}'
```

config ตรวจโครงสร้างและค่าของ Compose ไม่ได้ยืนยันการบังคับใช้จริง ต้องตรวจ UID และทดสอบแอปขณะรันด้วย

## ปรับให้เหมาะกับแอป

เมื่อพบ Read-only file system ให้หาพาธที่แอปต้องเขียน แล้วเปิดเฉพาะจุด ไม่ปิดข้อจำกัดทั้งหมด tmpfs หายเมื่อหยุด Container และควรจำกัดขนาด

Secrets ต้องแยกจาก Image, Git, Arguments และ Logs ส่วน Build Credentials ใช้ BuildKit Secret Mount

## ข้อชี้แจงเพิ่มเติม

- read_only ไม่ได้ทำให้ Mount อื่นเป็นแบบอ่านอย่างเดียวทั้งหมด
- Process ที่อ่าน Secret ได้ยังอาจนำ Secret ออกไปได้
- Non-root และ Runtime Policy ลดความเสี่ยง แต่ไม่ทดแทนการแก้ช่องโหว่

บทก่อนหน้า: [Image Optimization](ImageOptimization.md)
