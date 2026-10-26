---
title: "CI/CD and Kubernetes"
tags: [docker, advanced, devops]
source: "https://devopsvn.tech/docker-advanced-08-cicd-and-kubernetes/"
---

# CI/CD and Kubernetes

สร้าง Release Artifact ครั้งเดียว แล้วนำ Digest เดิมที่ผ่านการตรวจไปใช้แต่ละ Environment แทนการ Build ใหม่

## ขั้นตอนส่งมอบ

1. ทดสอบโค้ดด้วยคำสั่งของแอป
2. CI ใช้ Buildx สร้างและ Push Image
3. สแกน Image ตาม Digest ที่ Push
4. อัปเดต Kubernetes Deployment ด้วย Digest ที่ผ่านเกณฑ์
5. ติดตาม Rollout และเตรียมย้อนกลับ

Workflow ต้นฉบับยังไม่มี Unit/Integration Tests ต้องเพิ่มเอง การ Build สำเร็จไม่ได้ทดแทน Tests

## การตรวจและสิทธิ์

ใช้ GitHub Actions และ Registry Credentials ที่มีสิทธิ์เท่าที่จำเป็น เก็บ Digest เป็น Output ของ Build เพื่อนำไปใช้ขั้นตอนถัดไป

ตัวอย่างสแกนหลัง Push ดังนั้น Image อาจอยู่ใน Registry แม้ Scan ไม่ผ่าน ต้องห้าม Promote Release ที่ไม่ผ่าน ส่วนการข้ามช่องโหว่ที่ยังไม่มีแพตช์เป็นนโยบาย ไม่ได้หมายความว่าปลอดภัย

## ตรวจ Rollout

เมื่อมี Cluster, สิทธิ์, Deployment และ Namespace ที่ถูกต้องแล้ว:

```powershell
kubectl rollout status deployment/task-api
kubectl rollout history deployment/task-api
```

คำสั่งนี้ไม่ได้สร้าง Cluster หรือ Deploy แอปให้ การย้อน Deployment ต้องพิจารณาความเข้ากันได้ของข้อมูลและ Schema ด้วย

Compose ยังเหมาะกับระบบ Host เดียว ไม่จำเป็นต้องย้ายทุกระบบไป Kubernetes

บทก่อนหน้า: [Debugging and Observability](DebuggingAndObservability.md)

ที่มา: [CI/CD and Kubernetes](https://devopsvn.tech/docker-advanced-08-cicd-and-kubernetes/)
