---
title: "Debugging and Observability"
tags: [docker, advanced, devops]
source: "https://devopsvn.tech/docker-advanced-07-debugging-and-observability/"
---

# Debugging and Observability

เก็บหลักฐานก่อน Restart หรือเปลี่ยน Configuration เพื่อไม่ให้สูญเสียบริบทของปัญหา

## ลำดับตรวจ

1. ระบุ Container รวมตัวที่หยุดแล้ว
2. อ่าน Logs พร้อมเวลา
3. ตรวจ State, Restart Count และ Configuration จริง
4. ดูทรัพยากร แล้วเจาะปัญหา Network หรือ Dependencies

```powershell
docker ps -a --no-trunc
docker logs --tail 200 --timestamps task-api
docker inspect task-api --format '{{.State.ExitCode}} {{.State.OOMKilled}}'
docker stats --no-stream task-api
```

แทน task-api ด้วยชื่อจริง คำสั่งเหล่านี้ใช้เก็บข้อมูล ไม่ได้รันแอปตัวอย่างให้

## ตีความอย่างระวัง

- Running ไม่ได้แปลว่าให้บริการได้
- Exit Code 137 ไม่ยืนยัน OOM ต้องตรวจ OOMKilled และข้อมูล Host
- Snapshot ทรัพยากรไม่ใช่ประวัติย้อนหลัง
- Local Image ID ไม่ใช่ Registry Digest

## เก็บข้อมูลนอก Container

Logs อธิบายเหตุการณ์ Metrics ช่วยดูแนวโน้ม และ Traces ช่วยตามคำขอข้าม Services เก็บ Telemetry ภายนอกเพื่อสืบค้นหลัง Restart หรือลบ Container

ข้อมูล inspect และ Logs อาจมี Credentials ควรตัดค่าลับก่อนแชร์

บทก่อนหน้า: [Production Compose](ProductionCompose.md)

ที่มา: [Debugging and Observability](https://devopsvn.tech/docker-advanced-07-debugging-and-observability/)
