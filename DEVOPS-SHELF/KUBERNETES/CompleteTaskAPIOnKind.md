---
title: "Complete Task API on Kind"
tags: [kubernetes, basics, devops]
source: "https://devopsvn.tech/kubernetes-basics-08-complete-task-api-deployment-on-kind/"
---

# Complete Task API on Kind

ประกอบ Task API ด้วย Image, Namespace, ConfigMap, Secret, PVC, Deployment และ Service โดยชื่อ Labels, Ports และ Mount Paths ต้องสอดคล้องกัน

## เตรียมก่อน Apply

- ใช้ Image ของคุณแทน Placeholder
- Private GHCR ใช้ imagePullSecrets ใน Namespace เดียวกัน
- API Token และ Registry Token มีคนละหน้าที่
- สร้าง Configuration, Secret และ PVC ให้พร้อม

บทนี้กำหนดหนึ่ง Replica และ Recreate เพราะข้อมูลเป็นไฟล์ JSON ป้องกันสอง Pods เขียนพร้อมกันระหว่างอัปเดต แลกกับ Downtime ชั่วคราว

Readiness ควบคุมการรับ Traffic ส่วน Liveness ช่วยเริ่ม Container ใหม่เมื่อ Probe ล้มเหลวตามเงื่อนไข ทั้งคู่เรียก /healthz ซึ่งไม่ได้ยืนยันว่าเขียนข้อมูลได้

จากโฟลเดอร์ Manifests ที่เตรียมค่าครบแล้ว:

```powershell
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl rollout status deployment/task-api -n tasks
kubectl get deployment,pods,service,pvc -n tasks
kubectl port-forward -n tasks service/task-api 8080:80
```

ทดสอบอ่านและสร้าง Tasks พร้อม Token ของคุณ แล้วตรวจว่าข้อมูลยังอยู่หลังแทนที่ Pod การลบ Kind Cluster ไม่ใช่การรักษาข้อมูลถาวร

ที่มา: [Complete Task API on Kind](https://devopsvn.tech/kubernetes-basics-08-complete-task-api-deployment-on-kind/)

[กลับสารบัญ](README.md)
