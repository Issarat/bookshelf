---
title: "Docker Compose"
tags: [docker, compose, devops]
source: "https://devopsvn.tech/docker-07-compose/"
---

# Docker Compose

สรุปจาก [Docker Compose — DevOps VN](https://devopsvn.tech/docker-07-compose/)

Compose กำหนดแอปหลาย Container ใน YAML แล้วจัดการ Services, Networks และ Volumes ร่วมกัน แทนการพิมพ์ docker run แยกหลายครั้ง

## ส่วนสำคัญ

| ตัวเลือก | หน้าที่ |
| --- | --- |
| services | กำหนดบริการ |
| image / build | ใช้ Image หรือสร้างจาก Dockerfile |
| ports | เปิดพอร์ต Host |
| environment / env_file | ส่งค่าตัวแปรเข้า Container |
| volumes | เก็บข้อมูลหรือ Mount ไฟล์ |
| depends_on | กำหนดลำดับเริ่ม |
| restart | กำหนดการเริ่มใหม่ |

Services บน Network เริ่มต้นเรียกกันด้วยชื่อ Service ได้

## ตัวอย่างสำหรับฝึก

บันทึกเป็น compose.yaml:

```yaml
services:
  web:
    image: nginx:alpine
    ports:
      - "127.0.0.1:8083:80"
  cache:
    image: redis:7-alpine
```

ตัวอย่างนี้ทดลองจัดการสอง Service ร่วมกัน โดย Nginx ยังไม่ได้เชื่อมใช้ Redis

## คำสั่งประจำวัน

```powershell
docker compose up -d
docker compose ps
docker compose logs -f
docker compose exec cache redis-cli ping
docker compose down
```

เปิด http://localhost:8083 เพื่อดูเว็บ ส่วน up --build ใช้สร้าง Image ของ Services ที่มี build ก่อนเริ่ม

## Readiness และข้อมูล

depends_on แบบสั้นรอเพียงการเริ่ม Container หากต้องรอความพร้อมให้กำหนด healthcheck และ condition: service_healthy

Named Volume เก็บข้อมูลแยกจาก Container ส่วน Bind Mount เหมาะกับการใช้ไฟล์โค้ดจากเครื่องในงานพัฒนา

## ข้อชี้แจงเพิ่มเติม

- down ลบ Container และ Network ที่ Compose จัดการตามขอบเขตคำสั่ง แต่ไม่ลบ Named Volume โดยค่าเริ่มต้น
- down -v ลบ Volume ที่เข้าเงื่อนไขด้วย จึงอาจทำให้ข้อมูลฐานข้อมูลหาย
- Restart ไม่ใช่การนำการแก้ YAML มาใช้ ให้ใช้ up -d เพื่อปรับตาม Configuration
- การ Mount โค้ดไม่ทำให้ Hot Reload เอง แอปต้องรองรับด้วย
- อย่า Commit ไฟล์ที่มี Secrets
