---
title: "Deployments and Rollouts"
tags: [kubernetes, basics, devops]
source: "https://devopsvn.tech/kubernetes-basics-05-deployments-and-rollouts/"
---

# Deployments and Rollouts

Deployment จัดการ ReplicaSets ซึ่งรักษาจำนวน Pods ตาม Desired State โดย Selector ต้องตรงกับ Labels ของ Pod Template

บทนี้ใช้ HTTP Server ตัวอย่างสอง Replicas ยังไม่ใช่ Task API จริง เมื่อมี Manifests และ Namespace tasks แล้ว:

```powershell
kubectl get deployment,replicaset,pods -n tasks
kubectl rollout status deployment/task-api -n tasks
kubectl rollout history deployment/task-api -n tasks
```

การเปลี่ยน Pod Template ทำให้เกิด Revision และ Rollout ใหม่ RollingUpdate ค่อย ๆ เปลี่ยน Pods ส่วน Recreate หยุดชุดเก่าก่อนเริ่มชุดใหม่

Readiness Probe ช่วยบอกว่า Pod พร้อมรับ Traffic ไม่ใช่เพียงเริ่ม Process ได้

Rollback เปลี่ยน Deployment Template กลับได้ แต่ไม่ย้อน Database Migration หรือผลข้างเคียงภายนอก Kubernetes ไม่ซ่อม Image ที่ผิดด้วยการสร้าง Pods ซ้ำ

หมายเหตุ: คำสั่งลบ Pod ด้วย Label Selector ในบทความอาจลบทุก Pod ที่ตรง ไม่ใช่เพียงตัวเดียว

ที่มา: [Deployments and Rollouts](https://devopsvn.tech/kubernetes-basics-05-deployments-and-rollouts/)

[กลับสารบัญ](README.md)
