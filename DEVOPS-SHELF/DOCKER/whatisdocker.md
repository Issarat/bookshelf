---
title: "Docker คืออะไร?"
tags: [docker, containers, devops]
source: "https://devopsvn.tech/docker-00-what-is-docker/"
---

# Docker คืออะไร?

สรุปจาก [What Is Docker? — DevOps VN](https://devopsvn.tech/docker-00-what-is-docker/)

## ปัญหาที่ Docker ช่วยแก้

แอปอาจรันบนเครื่องเราได้ แต่รันบน Server ไม่ได้ เพราะเวอร์ชัน Runtime หรือ Libraries ต่างกัน Docker ช่วยแพ็กแอปพร้อมสิ่งที่จำเป็นต่อการรัน เพื่อลดความแตกต่างของสภาพแวดล้อมระหว่างเครื่อง

## Container คืออะไร?

Container คือสภาพแวดล้อมที่แยกการทำงานของแอป โดยใช้ Kernel ร่วมกับระบบที่รองรับการรัน Container จึงไม่ต้องบูตระบบปฏิบัติการเต็มชุดเหมือน VM

| ประเด็น | Virtual Machine (VM) | Container |
| --- | --- | --- |
| ระบบปฏิบัติการ | มี Guest OS และ Kernel ของตัวเอง | ใช้ Kernel ร่วมกัน |
| ทรัพยากร | โดยทั่วไปใช้มากกว่า | โดยทั่วไปใช้น้อยกว่า |
| การเริ่มทำงาน | โดยทั่วไปช้ากว่า | โดยทั่วไปเร็วกว่า |
| การแยกการทำงาน | ระดับเครื่องเสมือน | ระดับ Process |

## Image และ Container

- **Image:** แม่แบบแบบอ่านอย่างเดียว รวมแอป Runtime และ Dependencies
- **Container:** Instance ที่สร้างจาก Image เพื่อรันแอป โดยมีชั้นสำหรับเขียนข้อมูลเพิ่ม

Image เดียวสามารถสร้าง Container หลายตัวที่แยกจากกันได้

## Docker มีหน้าที่อะไร?

Docker มีเครื่องมือสร้าง Image, รัน Container และแชร์ Image ผ่าน Registry เช่น Docker Hub

## เหมาะกับงานแบบไหน?

- ทำให้สภาพแวดล้อม Development, CI และ Production สอดคล้องกัน
- แยก Dependencies ของแต่ละแอป เพื่อลดการชนกันของเวอร์ชัน
- Deploy แอปจาก Image ที่เตรียมไว้
- รันระบบที่มีหลาย Service แยกจากกัน

สำหรับสคริปต์สั้น ๆ ที่รันครั้งเดียว Docker อาจเพิ่มขั้นตอนโดยไม่จำเป็น

## สิ่งที่จะได้ฝึกในซีรีส์

สร้าง Task App ที่ประกอบด้วย Node.js API, Python Worker, PostgreSQL และ Redis แล้วใช้ Docker Compose จัดการ Service เหล่านี้ร่วมกัน

## จำให้ได้

**Docker คือเครื่องมือ, Image คือแม่แบบ และ Container คือตัวที่สร้างจากแม่แบบเพื่อรันแอป**
