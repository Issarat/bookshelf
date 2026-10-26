---
title: "Local Cluster with Kind"
tags: [kubernetes, basics, devops]
source: "https://devopsvn.tech/kubernetes-basics-02-create-a-local-cluster-with-kind/"
---

# Local Cluster with Kind

Kind สร้าง Kubernetes Nodes เป็น Docker Containers เหมาะกับฝึกในเครื่อง แต่ไม่ได้จำลองบริการ Cloud ทั้งหมด

ต้องเตรียม Docker ที่กำลังรัน, Kind และ kubectl ก่อน บันทึกตัวอย่างเป็น kind-config.yaml:

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
  - role: worker
```

คำสั่งสำหรับทดลองด้วยตนเอง:

```powershell
docker version
kind version
kubectl version --client
kind create cluster --name kubernetes-basics --config kind-config.yaml
kubectl config current-context
kubectl get nodes -o wide
```

ตรวจว่า Context เป็น kind-kubernetes-basics และ Nodes เป็น Ready ก่อน Apply Workload อย่าลบ Node Containers ด้วย docker rm ให้ Kind จัดการ Cluster

การติดตั้ง kubectl อย่างเดียวไม่ได้สร้าง Cluster และข้อมูล Local Cluster ไม่ใช่ Backup ถาวร

ที่มา: [Local Cluster with Kind](https://devopsvn.tech/kubernetes-basics-02-create-a-local-cluster-with-kind/)

[กลับสารบัญ](README.md)
