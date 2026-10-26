---
title: "Pods and Namespaces"
tags: [kubernetes, basics, devops]
source: "https://devopsvn.tech/kubernetes-basics-04-pods-and-namespaces/"
---

# Pods and Namespaces

Pod คือหน่วยที่ Kubernetes จัดวาง Containers ภายในใช้ IP และ Port Space ร่วมกัน ส่วน Namespace แบ่งขอบเขตชื่อ Resources ภายใน Cluster

Namespace ไม่ได้เปิด Network Isolation หรือกำหนดสิทธิ์ทีมโดยอัตโนมัติ ต้องใช้ NetworkPolicy และ RBAC ตามความต้องการ

บทนี้ใช้ Pod ชื่อ pod-inspector ใน Namespace tasks หลัง Apply Manifests ต้นฉบับ ตรวจด้วย:

```powershell
kubectl get pods -n tasks -o wide
kubectl describe pod pod-inspector -n tasks
kubectl logs pod-inspector -n tasks
```

| อาการ | สิ่งที่ตรวจ |
| --- | --- |
| Pending | Scheduling และ Dependencies |
| ImagePullBackOff | ชื่อ Image และสิทธิ์ Registry |
| CrashLoopBackOff | Logs, Command และ Configuration |

Container Restart ยังอยู่ใน Pod เดิม แต่ Pod ที่สร้างตรง ๆ ไม่มี Controller สร้างทดแทนเมื่อลบ ใช้ Deployment สำหรับบริการที่ต้องรักษาจำนวน Instances

ที่มา: [Pods and Namespaces](https://devopsvn.tech/kubernetes-basics-04-pods-and-namespaces/)

[กลับสารบัญ](README.md)
