---
title: "Your First Container"
description: "ติดตั้ง Docker และฝึกรัน Container แรก"
tags: [docker, containers, devops]
source: "https://devopsvn.tech/docker-01-first-container/"
---

# Your First Container

สรุปจาก [Your First Container — DevOps VN](https://devopsvn.tech/docker-01-first-container/)

## 1. เตรียม Docker

บทความใช้ Docker Desktop บน Windows ร่วมกับ WSL 2 เมื่อติดตั้งและเปิดโปรแกรมแล้ว ตรวจสอบด้วย:

```powershell
docker version
```

ควรเห็นข้อมูลทั้ง Client และ Server

## 2. รัน Container แรก

```powershell
docker run hello-world
```

Docker จะหา Image ในเครื่อง ดาวน์โหลดหากยังไม่มี แล้วสร้างและรัน Container เพื่อแสดงข้อความ จากนั้นโปรแกรมจบและ Container หยุดตามปกติ

## 3. รันเว็บ Nginx

```powershell
docker run -d --name my-nginx -p 8080:80 nginx
```

| ส่วนของคำสั่ง | ความหมาย |
| --- | --- |
| `-d` | รันเบื้องหลัง |
| `--name my-nginx` | ตั้งชื่อ Container |
| `-p 8080:80` | เชื่อมพอร์ต 8080 ของเครื่องกับพอร์ต 80 ใน Container |
| `nginx` | Image ที่ใช้ |

เปิด [localhost:8080](http://localhost:8080) เพื่อดูหน้าเว็บ

## 4. คำสั่งที่ใช้บ่อย

| คำสั่ง | หน้าที่ |
| --- | --- |
| `docker ps` | ดู Container ที่กำลังรัน |
| `docker ps -a` | ดูทั้งหมด รวมตัวที่หยุดแล้ว |
| `docker logs my-nginx` | ดู Log |
| `docker exec -it my-nginx bash` | เปิด Shell ภายใน Container ที่กำลังรัน |
| `docker stop my-nginx` | หยุด Container |
| `docker rm my-nginx` | ลบ Container ที่หยุดแล้ว |
| `docker images` | ดู Image ในเครื่อง |

**จำให้ได้:** stop ยังเก็บ Container ไว้ ส่วน rm ลบ Container และไม่ได้ลบ Image ตามไปด้วย

บทก่อนหน้า: [Docker คืออะไร?](whatisdocker.md)
