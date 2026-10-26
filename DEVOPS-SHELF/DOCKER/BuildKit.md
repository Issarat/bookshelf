---
title: "Faster, Safer Docker Builds with BuildKit"
tags: [docker, buildkit, devops]
source: "https://devopsvn.tech/docker-advanced-01-buildkit/"
---

# BuildKit

สรุปจาก [Faster, Safer Docker Builds with BuildKit — DevOps VN](https://devopsvn.tech/docker-advanced-01-buildkit/)

BuildKit คือระบบสร้าง Image ส่วน Buildx เป็นเครื่องมือ CLI สำหรับเรียกใช้ จุดเน้นของบทนี้คือ Cache และ Secrets ระหว่าง Build

## Cache สองระดับ

| ประเภท | ประโยชน์ |
| --- | --- |
| Layer Cache | ข้ามขั้นตอนเดิมเมื่อเงื่อนไข Cache ยังตรง |
| Cache Mount | เก็บไฟล์ดาวน์โหลดให้ใช้ซ้ำเมื่อขั้นตอนติดตั้งต้องรันใหม่ |

Cache Mount ไม่เพิ่มไฟล์ Cache ลงใน Image Layer โดยอัตโนมัติ

## ตัวอย่าง RUN

```dockerfile
# syntax=docker/dockerfile:1.7
RUN --mount=type=cache,target=/root/.npm \
    --mount=type=secret,id=npmrc,target=/root/.npmrc \
    npm ci --omit=dev
```

นี่เป็นส่วนหนึ่งของ Dockerfile ต้องเตรียม Node Base Image, WORKDIR และไฟล์ package.json กับ package-lock.json ก่อน

## เรียก Build

```powershell
docker buildx version
docker buildx build --secret id=npmrc,src=.npmrc --load -t practice-api:local .
```

รันจากโฟลเดอร์ที่มี Dockerfile และ .npmrc ของคุณ ส่วน --load โหลดผลลัพธ์แบบ Single-platform เข้า Image Store ในเครื่อง

## Secrets และขอบเขต Image

Secret Mount เปิดไฟล์ให้เฉพาะ RUN ที่ต้องใช้ แทนการฝัง Token ผ่าน COPY, ARG หรือ ENV ใช้ .dockerignore ตัด .npmrc และ node_modules และใช้ Multi-stage คัดลอกเฉพาะไฟล์สำหรับรัน

## ข้อชี้แจงเพิ่มเติม

- Secret Mount ไม่ป้องกันโปรแกรมที่พิมพ์ Secret ลง Log หรือคัดลอกออกเอง
- Builder ใหม่บน CI ไม่ได้มี Cache เดิมโดยอัตโนมัติ ต้องวางแผนการเก็บและนำกลับมาใช้
- --no-cache ข้าม Layer Cache แต่ไม่ได้หมายถึงล้าง Cache Mount

พื้นฐานที่เกี่ยวข้อง: [Writing Dockerfiles](Dockerfile.md)
