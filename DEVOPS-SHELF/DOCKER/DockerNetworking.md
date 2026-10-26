---
title: "Docker Networking"
tags: [docker, networking, devops]
source: "https://devopsvn.tech/docker-05-networking/"
---

# Docker Networking

สรุปจาก [Docker Networking — DevOps VN](https://devopsvn.tech/docker-05-networking/)

## ประเภท Network

| ประเภท | การใช้งาน |
| --- | --- |
| bridge | เชื่อม Container บน Docker Host เดียวกัน |
| host | ใช้ Network ของ Host โดยตรง เมื่อระบบรองรับ |
| none | ปิดการเชื่อมต่อ Network ภายนอก |
| overlay | เชื่อมหลาย Host เช่น Docker Swarm |

## ใช้ Custom Bridge

Default bridge ไม่มีการค้นหาด้วยชื่อ Container อัตโนมัติเหมือน Custom Bridge ควรสร้าง Network เองและใช้ชื่อแทนการผูกกับ IP

```powershell
docker network create study-net
docker run -d --name study-web --network study-net -p 127.0.0.1:8082:80 nginx:alpine
docker run --rm --network study-net busybox wget -qO- http://study-web:80
```

คำสั่งสุดท้ายทดสอบเรียกเว็บผ่านชื่อ Container ส่วน Browser บนเครื่องเปิด http://localhost:8082

## Port Publishing

รูปแบบ -p HOST_PORT:CONTAINER_PORT เปิดทางจาก Host เข้า Service ส่วน Container ที่อยู่ Network เดียวกันติดต่อพอร์ตภายในได้โดยไม่ต้อง Publish

## จัดการ Network

```powershell
docker network ls
docker network inspect study-net
docker network connect study-net existing-container
docker network disconnect study-net existing-container
```

Network Alias เพิ่มชื่อเรียกให้ Container ได้

## ตัวอย่างระบบหลาย Service

ให้ API, PostgreSQL และ Redis อยู่ Custom Network เดียวกัน API ติดต่อฐานข้อมูลด้วยชื่อ db และ Redis ด้วยชื่อ redis โดยเปิดพอร์ต Host เฉพาะ API ตามความจำเป็น

## ข้อชี้แจงเพิ่มเติม

- localhost ภายใน Container หมายถึง Container นั้นเอง ไม่ใช่ Container ฐานข้อมูล
- ตัวอย่างผูกพอร์ตกับ 127.0.0.1 เพื่อทดลองจากเครื่องตัวเอง
- ไม่ Publish พอร์ตไม่ได้หมายความว่าเป็นขอบเขตความปลอดภัยสมบูรณ์
- existing-container เป็นชื่อสมมติ ต้องแทนด้วย Container ที่มีจริง

บทก่อนหน้า: [Managing Containers](ManagingContainers.md)
