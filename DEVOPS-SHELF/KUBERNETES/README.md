---
title: "Kubernetes Basics"
tags: [kubernetes, devops]
---

# Kubernetes Basics

สรุปภาษาไทยจากซีรีส์ DevOps VN เรียนต่อจาก [Docker](../DOCKER/README.md) โดยเริ่มแนวคิด สร้าง Local Cluster และประกอบ Task API

## ลำดับเรียน

| บท | หัวข้อ | เนื้อหา |
| --- | --- | --- |
| 01 | [What Is Kubernetes?](WhatIsKubernetes.md) | Desired State และส่วนประกอบ Cluster |
| 02 | [Local Cluster with Kind](LocalClusterWithKind.md) | Docker, Kind, kubectl และ Context |
| 03 | [Publish Task API to GHCR](PublishTaskAPIToGHCR.md) | Build, ทดสอบ และเผยแพร่ Image |
| 04 | [Pods and Namespaces](PodsAndNamespaces.md) | หน่วยรัน ขอบเขตชื่อ และ Events |
| 05 | [Deployments and Rollouts](DeploymentsAndRollouts.md) | Replicas, Updates และ Rollback |
| 06 | [Services and Local Access](ServicesAndLocalAccess.md) | ClusterIP, Selectors และ Port Forward |
| 07 | [ConfigMaps, Secrets and Storage](ConfigMapsSecretsAndStorage.md) | Configuration, Credentials และ PVC |
| 08 | [Complete Task API on Kind](CompleteTaskAPIOnKind.md) | รวม Image, Probes, Service และ Storage |

## วิธีใช้

อ่านตามลำดับแล้วทดลองใน Local Cluster ตรวจ Context ก่อนใช้คำสั่งทุกครั้ง ตัวอย่างที่อ้าง Manifests ต้องใช้ไฟล์จากบทความต้นฉบับ โฟลเดอร์นี้เป็นบันทึก ไม่ใช่ชุดแอปพร้อม Deploy

ชุดนี้ใช้ Task API แบบไฟล์ JSON ซึ่งต่างจากตัวอย่าง Docker ที่มี PostgreSQL และ Redis อย่าเพิ่ม Replicas โดยไม่พิจารณา Concurrency ของข้อมูล
