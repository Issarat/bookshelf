---
title: "Services and Local Access"
tags: [kubernetes, basics, devops]
source: "https://devopsvn.tech/kubernetes-basics-06-services-and-local-access/"
---

# Services and Local Access

Pod IP เปลี่ยนได้เมื่อสร้างใหม่ Service จึงให้ชื่อ DNS และ Virtual IP ที่คงที่ โดยเลือก Pods จาก Labels และใช้ Endpoints ที่พร้อมให้บริการ

| ค่า | ความหมาย |
| --- | --- |
| selector | Labels ของ Pods ที่ต้องการ |
| port | พอร์ตที่ Client เรียก Service |
| targetPort | พอร์ตของแอปภายใน Pod |
| ClusterIP | Service สำหรับเข้าถึงภายใน Cluster |

ตัวอย่างบทนี้ใช้ Service task-api พอร์ต 80 ส่งไป Pod พอร์ต 3000 หลัง Apply Service และ Deployment:

```powershell
kubectl get endpointslices -n tasks -l kubernetes.io/service-name=task-api
kubectl port-forward -n tasks service/task-api 8080:80
```

เปิดอีก Terminal แล้วเรียก http://localhost:8080/ โดยคง Port Forward ไว้

DNS ภายใน Namespace ใช้ task-api ส่วนข้าม Namespace ใช้ task-api.tasks

Port Forward เป็นช่องทางชั่วคราวสำหรับตรวจในเครื่อง ไม่ใช่ Load Balancer สำหรับ Production หากไม่มี Endpoints ให้ตรวจ Labels และ Readiness

ที่มา: [Services and Local Access](https://devopsvn.tech/kubernetes-basics-06-services-and-local-access/)

[กลับสารบัญ](README.md)
