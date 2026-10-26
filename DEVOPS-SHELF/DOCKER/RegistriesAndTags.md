---
title: "Registries, Tags and Digests"
tags: [docker, advanced, devops]
source: "https://devopsvn.tech/docker-advanced-05-registries-and-tags/"
---

# Registries, Tags and Digests

| คำ | ความหมาย |
| --- | --- |
| Registry | ระบบเก็บและแจกจ่าย Images |
| Repository | กลุ่ม Images ของ Service |
| Tag | ชื่ออ่านง่ายที่อาจเปลี่ยนปลายทางได้ |
| Digest | ตัวระบุเนื้อหา Manifest ที่แน่นอน |

## กระบวนการ Release

1. Build และ Push ด้วย Tag ของ Release
2. อ่าน Digest จาก Registry หลัง Push สำเร็จ
3. บันทึก Digest พร้อม Commit และ Platforms
4. Deploy ด้วย repository@sha256 ตามค่าจริง

```powershell
docker buildx imagetools inspect ghcr.io/your-account/task-api:1.4.0
```

ชื่อข้างต้นเป็นตัวอย่าง ต้องแทนด้วย Repository ที่เข้าถึงได้ แล้วคัดลอก Digest เต็มจากผลลัพธ์ ไม่ใช้ Local Image ID แทน

## สิทธิ์และ Rollback

CI ต้องมีสิทธิ์ Push ส่วนเครื่อง Deploy ควรมีเพียงสิทธิ์ Pull แอปไม่ต้องได้รับ Registry Token

เก็บ Release เก่าให้ครอบคลุมช่วง Rollback เพราะ Digest ไม่ป้องกัน Registry ลบ Manifest หรือ Layers การย้อนกลับจึงต้องอาศัย Retention Policy ด้วย

บทก่อนหน้า: [Multi-platform Images](MultiPlatformImages.md)

ที่มา: [Registries, Tags and Digests](https://devopsvn.tech/docker-advanced-05-registries-and-tags/)
