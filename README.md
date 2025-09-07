
# Supersports Cart Automation

ชุดทดสอบอัตโนมัติด้วย Robot Framework และ Browser library สำหรับเพิ่มสินค้าในตะกร้า, จัดเรียงสินค้า, และตรวจสอบเนื้อหาในตะกร้าของเว็บไซต์ Supersports

ความต้องการ (Requirements)

- Python 3.10 ขึ้นไป

- Robot Framework 6.x ขึ้นไป

- Robot Framework Browser library

- Node.js (จำเป็นสำหรับ Browser library)

- Chromium หรือเบราว์เซอร์อื่นที่ Browser library รองรับ

การติดตั้ง (Installation)

โคลนโปรเจค:
```bash
  git clone https://github.com/NolaniA/supersport-add-product-to-cart.git
```

```bash
  cd "repo-directory"
```


สร้าง environment ของ Python (แนะนำเพื่อไม่ให้กระทบระบบ):
```bash
  python -m venv venv
  source venv/bin/activate    # Linux / macOS
  venv\Scripts\activate       # Windows
```


ติดตั้งแพ็กเกจที่จำเป็น:
```bash
  pip install --upgrade pip
  pip install robotframework
  pip install robotframework-browser
```


ติดตั้งเบราว์เซอร์ที่ Browser library ใช้:
```bash
  rfbrowser init
```


โดยปกติจะติดตั้ง Chromium หากต้องการ Firefox หรือ WebKit เพิ่ม ให้รัน:
```bash
  rfbrowser init --browsers firefox,webkit
```
  

การตั้งค่า (Configuration)

แก้ไขไฟล์ var_supersport.py:

  - LIMIT_TOP_BRAND = 3

  - LIMIT_ADD_ITEM_PER_BRAND = 2  # 0 : get all top brand 



## โครงสร้างของ Test Suite
*ตรวจสอบว่า SELECTOR ในโค้ดตรงกับโครงสร้าง DOM ของเว็บปัจจุบัน

## Settings (improt and setup)

import --> Libraries,  Variables :

  - Libraries: Browser, Collections, String

  - Variables: var_supersport.py

setup:

Suite Setup: Inital Browser  (suite : ทำงานครั้งเดียว ขอบเขตทั้งโปรเจค)

Test Setup/Teardown: ล้างตะกร้าก่อนและหลังรัน (test : ทำงานทุกครั้ง ขอบเขตเทสเคส)

## Variables (กำหนดค่าหรือตัวแปร global)

${BROWSER}    chromium

${HEADLESS}   ${False}


## Test Cases

Add Products To Cart

  step1: ดู Top Brands ทั้งหมด

  step2: เลือก Top Brands แบบสุ่ม

  step3: จัดเรียงสินค้าและเลือกสินค้า

  step4: เพิ่มสินค้าลงตะกร้า

  step5: ตรวจสอบข้อมูลสินค้าในตะกร้า

## Keywords (ฟังก์ชัน)

 - Inital Browser — เปิดเบราว์เซอร์และเข้า Base URL

 - Select Product From Category — เลือกหมวดหมู่สินค้าแบบสุ่ม

 - Get Sorting Menu — เก็บค่าตัวเลือกการจัดเรียง

 - Random Selected Sorting — คลิกตัวเลือกการจัดเรียงแบบสุ่ม

 - Get Product Url — เก็บ URL ของสินค้าเพื่อนำไปใส่ตะกร้า

 - Remove All Items From Cart — ล้างสินค้าทั้งหมดในตะกร้า

 - View All Top Brands From Home Page — เข้าไปหน้า Top Brands

 - Select Brands From Top Brands — เลือก Top Brands แบบสุ่ม

 - Sorting And Select Products — จัดเรียงสินค้าและเก็บ URL ของสินค้า

 - Add Product To Cart — เพิ่มสินค้าในตะกร้าและบันทึกรายละเอียด

 - Validate Products In Cart — ตรวจสอบข้อมูลสินค้าในตะกร้า เช่น รูป, แบรนด์, ลิงก์, ราคา, จำนวน, และยอดรวมทั้งหมด

การรัน (How to Run)

รันทั้งหมด:
```bash
  robot supersport_add_cart.robot
```


รันเฉพาะ Test Case:
```bash
  robot -t "Add Products To Cart" supersport_add_cart.robot
```

หรือ
```bash
  robot -t "Add Products To Cart" *.robot
```

  ****** ผลลัพธ์และ logs จะถูกเก็บในโฟลเดอร์ results ******

## เปิด headless mode สำหรับ CI/CD: 

${HEADLESS}   ${True}   (เปลี่ยนจาก ${False} >>> ${True})


## หมายเหตุ (Notes)

 - ตรวจสอบให้ selectors (SELECTOR) ตรงกับ DOM ปัจจุบันของเว็บไซต์

 - ความเร็วของเครือข่ายอาจกระทบ Wait For Response หรือ Wait Until Keyword Succeeds

 - ปรับค่า LIMIT_TOP_BRAND และ LIMIT_ADD_ITEM_PER_BRAND เพื่อกำหนดจำนวนสินค้าที่ต้องการทดสอบ
