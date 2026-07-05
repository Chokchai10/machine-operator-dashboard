# Machine Operator Dashboard

Responsive construction-site machine operator dashboard รองรับภาษาไทย อังกฤษ และจีน พร้อมรูปพนักงาน 19 คน

## เปิดใช้งาน

เปิด `open.html` โดยตรง หรือรัน `เปิดเว็บ.bat` บน Windows หน้า standalone ไม่ต้องติดตั้ง dependency

## Supabase

- Project: `machine-operator-dashboard`
- ตาราง: `public.machine_operators`
- Storage bucket: `operator-images`
- Migration: `supabase/migrations/001_machine_operators.sql`

หน้าเว็บใช้ Supabase REST API เป็นแหล่งข้อมูลกลาง และเก็บ LocalStorage เป็นข้อมูลสำรองเมื่อออฟไลน์
