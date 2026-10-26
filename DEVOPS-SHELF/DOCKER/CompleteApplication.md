---
title: "Building a Complete Application"
tags: [docker, compose, devops]
source: "https://devopsvn.tech/docker-08-complete-app/"
---

# Building a Complete Application

สรุปจาก [Building a Complete Application — DevOps VN](https://devopsvn.tech/docker-08-complete-app/)

บทสุดท้ายนำ Dockerfile, Networking, Volumes และ Compose มาประกอบเป็น Task App

## ส่วนประกอบ

| Service | หน้าที่ |
| --- | --- |
| Node.js API | รับคำขอ บันทึก Task และส่งงานเข้าคิว |
| Python Worker | ประมวลผลงานเบื้องหลัง |
| PostgreSQL | เก็บ Task |
| Redis | คิวระหว่าง API และ Worker |

## แนวทางประกอบระบบ

แยก Dockerfile ของ API และ Worker ติดตั้ง Dependencies ก่อนคัดลอกโค้ดเพื่อใช้ Cache แล้วกำหนดการเชื่อมต่อใน Compose ผ่านชื่อ Service ใช้ Health Check ร่วมกับ depends_on และ Named Volumes เก็บข้อมูล

## ทดลองรัน

คำสั่งนี้ต้องรันจากโฟลเดอร์ตัวอย่าง Task App ที่มีโค้ดและ Compose ของบทความ ไม่ใช่จากโฟลเดอร์บันทึกนี้

```powershell
docker compose up -d --build
docker compose ps
Invoke-RestMethod http://localhost:3000/health
Invoke-RestMethod http://localhost:3000/tasks
docker compose logs -f worker
```

สร้าง Task บน PowerShell:

```powershell
$taskBody = @{ title = 'Practice containers'; description = 'Run the sample stack' } | ConvertTo-Json
Invoke-RestMethod -Method Post -Uri http://localhost:3000/tasks -ContentType 'application/json' -Body $taskBody
```

## ก่อนใช้งานจริง

ใช้ Non-root, ไม่ฝัง Secrets, จำกัดทรัพยากร อัปเดตและสแกน Images ส่วน Compose เหมาะกับ Development และระบบบน Server เดียว หากต้องจัดการหลายเครื่องหรือ Autoscaling ต้องพิจารณา Orchestrator

## หยุดระบบ

```powershell
docker compose down
```

## ข้อชี้แจงเพิ่มเติม

- down -v อาจลบข้อมูลใน Volumes ใช้เมื่อยอมรับการสูญเสียข้อมูลได้
- Multi-stage ไม่ได้ลบ Package Manager โดยอัตโนมัติ ขึ้นกับ Image สุดท้าย
- Python อาจได้ประโยชน์จาก Multi-stage เมื่อ Dependencies ต้อง Compile
- Named Volume ไม่ใช่ Backup และ Redis ยังต้องกำหนด Persistence ให้ตรงความต้องการ
- Health Check ของฐานข้อมูลไม่รับประกันว่าทั้งแอปพร้อมใช้งาน

บทก่อนหน้า: [Docker Compose](DockerCompose.md)
