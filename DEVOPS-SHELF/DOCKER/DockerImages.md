---
title: "Working with Docker Images"
description: "สรุป Layers, Tags, Build และ Registry"
tags: [docker, images, devops]
source: "https://devopsvn.tech/docker-02-images/"
---

# Working with Docker Images

สรุปจาก [Working with Docker Images — DevOps VN](https://devopsvn.tech/docker-02-images/)

## Image และ Layers

Image ประกอบด้วยชั้นข้อมูลแบบอ่านอย่างเดียว Layers ที่เหมือนกันใช้ร่วมกันได้ ช่วยลดพื้นที่และการดาวน์โหลด ส่วน Container เพิ่มชั้นสำหรับเขียนข้อมูลขณะรัน

## Tags และ Registry

Docker Hub เป็น Registry เริ่มต้น ใช้ค้นหา ดาวน์โหลด และเผยแพร่ Image

Tag เป็นชื่ออ้างอิง เช่น เวอร์ชันหรือรูปแบบ Alpine โดย latest ไม่รับประกันว่าเป็นรุ่นใหม่ที่สุด ควรระบุเวอร์ชันที่ต้องการ แต่ Tag ยังเปลี่ยนปลายทางได้ ส่วน Digest อ้างอิงเนื้อหาที่แน่นอนและไม่ใช่ Tag

## สร้าง Image ของเรา

เตรียม index.html ในโฟลเดอร์เดียวกับ Dockerfile:

```html
<h1>My Docker page</h1>
```

```dockerfile
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/
EXPOSE 80
```

FROM เลือก Image ตั้งต้น, COPY เพิ่มไฟล์ และ EXPOSE ระบุพอร์ตที่แอปใช้ โดยยังไม่เผยแพร่พอร์ตออกมาที่เครื่อง

```powershell
docker build -t my-web:v1 .
docker run -d -p 8080:80 --name my-web my-web:v1
```

จุดท้ายคำสั่ง Build คือ Build Context หรือโฟลเดอร์ต้นทางของไฟล์ เปิด [localhost:8080](http://localhost:8080) เพื่อดูผล หากบทก่อนยังใช้พอร์ตนี้ ให้หยุด Container เดิมก่อน

## ลดไฟล์ที่ใช้ Build

ใช้ .dockerignore ตัดไฟล์ที่ไม่ต้องใช้ เช่น:

```text
node_modules
.git
.env
```

## ตรวจสอบและแชร์

| คำสั่ง | หน้าที่ |
| --- | --- |
| `docker pull nginx:alpine` | ดาวน์โหลด Image |
| `docker image inspect nginx:alpine` | ดู Metadata |
| `docker history nginx:alpine` | ดูประวัติการสร้าง |
| `docker tag my-web:v1 yourusername/my-web:v1` | เพิ่มชื่อสำหรับ Registry |
| `docker login` | เข้าสู่ระบบ |
| `docker push yourusername/my-web:v1` | อัปโหลด Image |

แทน yourusername ด้วยบัญชีของคุณ ตัวอย่าง nginx:alpine ใช้ตามบทความเพื่อฝึก ไม่ได้ตรึงเนื้อหา Image

บทก่อนหน้า: [Your First Container](FirstContainer.md)
