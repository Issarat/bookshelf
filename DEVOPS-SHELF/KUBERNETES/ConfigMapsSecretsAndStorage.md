---
title: "ConfigMaps, Secrets and Storage"
tags: [kubernetes, basics, devops]
source: "https://devopsvn.tech/kubernetes-basics-07-configmaps-secrets-and-storage/"
---

# ConfigMaps, Secrets and Storage

แยก Configuration และข้อมูลจาก Image เพื่อให้มีวงจรการเปลี่ยนแปลงของตัวเอง

| Resource | ใช้กับ |
| --- | --- |
| ConfigMap | ค่าที่ไม่ลับ เช่น PORT |
| Secret | Credentials เช่น API_TOKEN |
| PVC | คำขอพื้นที่เก็บข้อมูลถาวร |
| StorageClass | วิธีจัดเตรียม Storage |

ConfigMap ที่ส่งผ่าน Environment ไม่เปลี่ยนค่าใน Process เดิม ต้องสร้าง Pods ใหม่ ส่วนไฟล์ที่ Mount อาจอัปเดตภายหลังและแอปต้อง Reload

Base64 ใน Secret ไม่ใช่ Encryption ต้องมีสิทธิ์เข้าถึงและการป้องกันเพิ่มเติม ไม่ Commit ค่าลับจริง

หลัง Apply PVC ต้นฉบับ:

```powershell
kubectl get pvc task-api-data -n tasks
kubectl describe pvc task-api-data -n tasks
kubectl get storageclass
```

PVC อาจ Pending หากไม่มี Storage ที่ตรงเงื่อนไข ReadWriteOnce โดยทั่วไปจำกัดหนึ่ง Node ไม่ใช่หนึ่ง Pod

Task API ใช้ไฟล์ JSON จึงไม่เหมาะกับหลาย Writers การมี PVC ไม่ได้ทำให้ข้อมูลรองรับ Concurrency หรือมี Backup อัตโนมัติ

ที่มา: [ConfigMaps, Secrets and Storage](https://devopsvn.tech/kubernetes-basics-07-configmaps-secrets-and-storage/)

[กลับสารบัญ](README.md)
