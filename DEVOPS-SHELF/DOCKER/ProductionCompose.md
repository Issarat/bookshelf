---
title: "Production Compose"
tags: [docker, advanced, devops]
source: "https://devopsvn.tech/docker-advanced-06-production-compose/"
---

# Production Compose

แยกตัวระบุ Release ออกจาก Runtime Policy แล้วตรวจผลรวมก่อน Deploy เหมาะกับระบบขนาดเล็กบน Docker Host เดียว

## Policy หลัก

| ค่า | จุดประสงค์ |
| --- | --- |
| image แบบ Digest | ระบุ Release แน่นอน |
| restart | ฟื้นตัวเมื่อ Process จบ |
| healthcheck | ตรวจการตอบสนอง |
| read_only และ tmpfs | จำกัดพื้นที่เขียน |
| Resource Limits | จำกัด RAM และ CPU |

## ตรวจผลรวม

จากโฟลเดอร์ที่มีไฟล์ของคุณ:

```powershell
docker compose -f compose.yaml -f compose.production.yaml config
```

ไฟล์ถัดมาสามารถทับค่าก่อนหน้าได้ โดยเฉพาะ image ตัวอย่าง Override ในบทความมี Tag ซึ่งทับ Digest จาก Base ให้ลบ image ใน Override หรือกำหนด Digest ในไฟล์สุดท้าย แล้วตรวจผลจริง

## ข้อจำกัด

- config ตรวจ Configuration ไม่ได้ Pull หรือทดสอบแอป
- Health Check ต้องใช้โปรแกรมที่มีใน Image และไม่ยืนยันว่าผู้ใช้ภายนอกเข้าถึงได้
- สถานะ unhealthy ไม่ทำให้ Docker Engine Restart เอง
- ต้องวางแผนข้อมูลถาวร Backup และการดูแล Host เพิ่ม

บทก่อนหน้า: [Registries and Tags](RegistriesAndTags.md)

ที่มา: [Production Compose](https://devopsvn.tech/docker-advanced-06-production-compose/)
