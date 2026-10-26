---
title: "Managing Containers"
tags: [docker, containers, devops]
source: "https://devopsvn.tech/docker-04-containers/"
---

# Managing Containers

สรุปจาก [Managing Containers — DevOps VN](https://devopsvn.tech/docker-04-containers/)

## วงจรการทำงาน

| คำสั่ง | หน้าที่ |
| --- | --- |
| docker create | สร้างโดยยังไม่เริ่ม |
| docker start | เริ่มตัวเดิม |
| docker pause / unpause | แช่แข็งและคืนการทำงาน |
| docker stop | ขอให้หยุด ก่อนบังคับเมื่อหมดเวลา |
| docker kill | ส่งสัญญาณบังคับหยุดโดยค่าเริ่มต้น |
| docker rm | ลบตัวที่หยุดแล้ว |

## ตรวจปัญหา

```powershell
docker logs --tail 100 -f my-app
docker exec -it my-app sh
docker inspect my-app
docker cp my-app:/app/config.json ./config.json
```

Logs แสดง stdout/stderr ไม่ได้อ่านไฟล์ Log โดยอัตโนมัติ ส่วน exec ต้องใช้กับ Container ที่กำลังรันและมีโปรแกรมที่เรียกอยู่ภายใน

## จำกัดทรัพยากรและเริ่มใหม่

```powershell
docker run -d --name demo-web --memory=512m --cpus=0.5 --restart=unless-stopped -p 8081:80 nginx:alpine
docker stats --no-stream
```

จำกัด RAM และ CPU พร้อมเริ่มใหม่ตาม Policy โดย unless-stopped เคารพการหยุดด้วยมือ ส่วน on-failure:3 ลองใหม่เมื่อจบด้วยข้อผิดพลาดไม่เกินสามครั้ง

## Health Check

ใช้ตรวจว่าแอปตอบสนอง ไม่ใช่เพียง Process ยังอยู่

## ตรวจพื้นที่และล้าง

```powershell
docker system df
docker container prune
```

prune ด้านบนลบ Container ที่หยุดแล้วทั้งหมด ควรตรวจสิ่งที่จะลบก่อน

## ข้อชี้แจงเพิ่มเติม

- Docker Engine ไม่ Restart เพียงเพราะสถานะ unhealthy; Restart Policy ใช้กับการจบของ Container
- Exit Code 137 สื่อถึง SIGKILL ไม่ได้ยืนยันว่า RAM หมดเสมอไป ตรวจ State.OOMKilled เพิ่ม
- sh หรือ bash อาจไม่มีใน Image ขนาดเล็ก

บทก่อนหน้า: [Writing Dockerfiles](Dockerfile.md)
