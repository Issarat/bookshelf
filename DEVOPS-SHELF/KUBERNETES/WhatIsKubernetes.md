---
title: "What Is Kubernetes?"
tags: [kubernetes, basics, devops]
source: "https://devopsvn.tech/kubernetes-basics-01-what-is-kubernetes/"
---

# What Is Kubernetes?

Kubernetes จัดการ Workloads แบบ Container บนกลุ่มเครื่อง โดยรับ Desired State แล้วพยายามปรับระบบจริงให้ตรง เช่น ต้องการ API สองชุด

| ส่วน | หน้าที่ |
| --- | --- |
| Control Plane | รับ API และควบคุมสถานะ Cluster |
| Node | เครื่องที่รัน Workloads |
| Pod | หน่วยที่ Kubernetes จัดวาง มีหนึ่งหรือหลาย Containers |
| Deployment | จัดการ ReplicaSets และ Rollouts |
| ReplicaSet | รักษาจำนวน Pods |
| kubectl | CLI ติดต่อ Kubernetes API |

Deployment ไม่ได้เปิดพอร์ตภายนอกเอง ต้องมีการเชื่อมต่อที่เหมาะสม เช่น Service

Docker ช่วยสร้างและรัน Container ส่วน Kubernetes เพิ่มการจัดวางและฟื้นตัวหลายเครื่อง แต่ไม่แก้โค้ดที่ผิดหรือกู้ข้อมูลที่ไม่มี Backup ให้เอง

เรียนแนวคิดบทนี้ก่อน แล้วสร้าง Cluster ในบทถัดไป

ที่มา: [What Is Kubernetes?](https://devopsvn.tech/kubernetes-basics-01-what-is-kubernetes/)

[กลับสารบัญ](README.md)
