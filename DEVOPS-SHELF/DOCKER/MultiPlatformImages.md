---
title: "Multi-platform Images"
tags: [docker, advanced, devops]
source: "https://devopsvn.tech/docker-advanced-04-multi-platform-images/"
---

# Multi-platform Images

Image ต้องตรงทั้งระบบปฏิบัติการและ CPU เช่น linux/amd64 หรือ linux/arm64 โดย Manifest List หรือ OCI Image Index รวมหลาย Platform ไว้ใต้ Tag เดียวให้ Docker เลือกตัวที่เหมาะสม

## ขั้นตอน

ตรวจ Builder และสร้างตัวที่รองรับ Platform เป้าหมาย:

```powershell
docker buildx ls
docker buildx create --name study-multi --driver docker-container --use
docker buildx inspect --bootstrap
```

จากโฟลเดอร์ที่มี Dockerfile และโค้ด หลังแทนบัญชี Registry และ Login แล้ว:

```powershell
docker buildx build --platform linux/amd64,linux/arm64 -t ghcr.io/your-account/task-api:1.0.0 --push .
docker buildx imagetools inspect ghcr.io/your-account/task-api:1.0.0
```

คำสั่ง --push เผยแพร่ Image จริง ต้องมีสิทธิ์และ Repository ของคุณ ตรวจ Manifest ว่ามีทั้งสอง Platform

## ข้อควรเข้าใจ

- Emulation ช่วย Build ข้าม CPU แต่อาจช้ากว่า Native Builder
- Build ผ่านไม่ได้รับประกันว่าทั้งสอง Platform รันได้ ต้องทดสอบ
- ตัวอย่างสคริปต์ต้นฉบับไม่ได้มี Dockerfile ครบ ต้องเตรียม Build Context
- การโหลดหลาย Platform ในเครื่องขึ้นกับ Image Store; Classic Store มีข้อจำกัด จึงใช้ Registry ในตัวอย่าง

บทก่อนหน้า: [Container Security](ContainerSecurity.md)

ที่มา: [Multi-platform Images](https://devopsvn.tech/docker-advanced-04-multi-platform-images/)
