---
title: "Publish Task API to GHCR"
tags: [kubernetes, basics, devops]
source: "https://devopsvn.tech/kubernetes-basics-03-build-and-publish-a-task-api-to-ghcr/"
---

# Publish Task API to GHCR

Kubernetes Node ต้องเข้าถึง Image ได้ Image ที่มีเฉพาะบนเครื่องพัฒนาไม่ได้อยู่ในทุก Node โดยอัตโนมัติ บทนี้ใช้ GHCR แจกจ่าย Task API

Task API มี GET /healthz, GET / สำหรับอ่าน Tasks และ POST /tasks สำหรับสร้าง มีการตรวจ Bearer Token เมื่อกำหนด API_TOKEN

จากโฟลเดอร์โค้ด Task API ต้นฉบับที่มี Dockerfile:

```powershell
docker build -t task-api:0.1.0 .
docker run --rm -p 127.0.0.1:3000:3000 task-api:0.1.0
```

เปิดอีก Terminal:

```powershell
Invoke-RestMethod http://localhost:3000/healthz
```

หลังทดสอบจึงตั้งชื่อ ghcr.io/owner/task-api:0.1.0 แล้ว Login และ Push ด้วยบัญชีของคุณ ใช้ Credentials ที่จำกัดสิทธิ์และไม่บันทึก Token ในโค้ด

Tag อ่านง่ายแต่เปลี่ยนปลายทางได้ ส่วน Digest ระบุ Artifact แน่นอน สิทธิ์ Publish ต่างจากสิทธิ์ Pull ของ Cluster

ที่มา: [Publish Task API to GHCR](https://devopsvn.tech/kubernetes-basics-03-build-and-publish-a-task-api-to-ghcr/)

[กลับสารบัญ](README.md)
