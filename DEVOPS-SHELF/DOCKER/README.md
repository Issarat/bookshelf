---
title: "Docker"
description: "สารบัญบันทึกพื้นฐาน Docker ตามซีรีส์ DevOps VN"
tags: [docker, containers, devops]
---

# Docker

บันทึกสรุปภาษาไทยจากซีรีส์ Docker Basics ของ [DevOps VN](https://devopsvn.tech/docker-00-what-is-docker/) สำหรับเริ่มเรียนตั้งแต่ Container ไปจนถึงแอปหลาย Services

## สารบัญตามลำดับเรียน

| บท | หัวข้อ | สิ่งที่จะเรียน |
| --- | --- | --- |
| 00 | [Docker คืออะไร?](whatisdocker.md) | Container, Image และความต่างจาก VM |
| 01 | [Your First Container](FirstContainer.md) | รัน Container แรกและคำสั่งพื้นฐาน |
| 02 | [Docker Images](DockerImages.md) | Layers, Tags, Build และ Registry |
| 03 | [Writing Dockerfiles](Dockerfile.md) | คำสั่ง Dockerfile, Cache และ Multi-stage Build |
| 04 | [Managing Containers](ManagingContainers.md) | Logs, Lifecycle, Resource Limits และ Health Checks |
| 05 | [Docker Networking](DockerNetworking.md) | Custom Bridge, DNS และ Port Publishing |
| 06 | Volumes and Data Persistence — ยังไม่มีไฟล์สรุป | การเก็บข้อมูลให้คงอยู่และ Bind Mounts |
| 07 | [Docker Compose](DockerCompose.md) | กำหนดและจัดการหลาย Services ผ่าน YAML |
| 08 | [Building a Complete Application](CompleteApplication.md) | ประกอบ API, Worker, PostgreSQL และ Redis |

## วิธีใช้บันทึก

1. อ่านตามลำดับบท แล้วทดลองคำสั่งบนเครื่องตัวเอง
2. ตรวจชื่อ Container และพอร์ตให้ไม่ชนกับตัวอย่างที่รันไว้ก่อนหน้า
3. ตัวอย่าง Build และ Compose บางบทต้องใช้โค้ดแอปจากบทความต้นฉบับ ไฟล์ในโฟลเดอร์นี้เป็นบันทึกสรุป
4. ตรวจข้อมูลที่จะลบก่อนใช้ prune หรือ docker compose down -v โดยเฉพาะข้อมูลใน Volumes

บันทึกแต่ละบทมีลิงก์ต้นฉบับสำหรับอ่านรายละเอียดเพิ่มเติม

## Docker Advanced

| บท | หัวข้อ | สิ่งที่จะเรียน |
| --- | --- | --- |
| 01 | [BuildKit](BuildKit.md) | Cache Mount, Secret Mount และ Buildx |
| 02 | [Image Optimization](ImageOptimization.md) | Multi-stage Build และการตรวจ Runtime Image |
| 03 | [Container Security](ContainerSecurity.md) | Non-root, Read-only Filesystem และการจำกัดสิทธิ์ |
| 04 | [Multi-platform Images](MultiPlatformImages.md) | AMD64, ARM64 และ Manifest List |
| 05 | [Registries and Tags](RegistriesAndTags.md) | Digest, Release Identity และ Retention |
| 06 | [Production Compose](ProductionCompose.md) | Configuration Merge และ Runtime Policy |
| 07 | [Debugging and Observability](DebuggingAndObservability.md) | State, Logs, Metrics และ Traces |
| 08 | [CI/CD and Kubernetes](CICDAndKubernetes.md) | Build, Scan และ Promote Image ด้วย Digest |
