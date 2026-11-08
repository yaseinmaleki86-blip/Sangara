# سنگارا | Sangara v1.1

سورس فروشگاه محصولات سنگ مصنوعی «سنگارا» (Next.js) به همراه پیش‌نمایش مستقل و آفلاین HTML مخصوص گوشی.

## نمایش در گوشی بدون نصب

فایل [`Sangara_Mobile_Preview.html`](Sangara_Mobile_Preview.html) را دانلود کنید و مستقیماً در مرورگر موبایل باز کنید. تصاویر درون فایل هستند و اینترنت لازم نیست.

برای GitHub Pages نسخهٔ نمایشی در [`docs/index.html`](docs/index.html) قرار دارد. پس از **عمومی کردن مخزن در صورت تمایل** و فعال‌سازی GitHub Pages با تنظیم `Deploy from a branch`، شاخه `main` و پوشه `/docs`، نسخهٔ نمایشی با لینک Pages نمایش داده می‌شود.

> توجه: رابط HTML یک نمونه نمایشی است، نه فروشگاه متصل به پرداخت/ثبت سفارش واقعی.

## اجرای سورس اصلی روی ویندوز

فایل `INSTALL_RUN.bat` را اجرا کنید. نصب اولیه به اینترنت نیاز دارد. راهنمای کامل: [`README_FA.md`](README_FA.md).

## ساخت نسخه HTML بعد از ویرایش محصولات

```bash
python scripts/build-mobile-preview.py
```

سپس فایل `Sangara_Mobile_Preview.html` را در صورت نیاز به `docs/index.html` نیز کپی کنید.

## ساختار

- `app/` — صفحات و استایل Next.js
- `data/products.json` — داده محصولات نمونه
- `public/images/` — عکس‌های بهینه محصولات
- `templates/` و `scripts/` — قالب و ساخت پیش‌نمایش
- `Sangara_Mobile_Preview.html` — پیش‌نمایش موبایل مستقل
- `docs/index.html` — نسخه آماده GitHub Pages

مجوز انتشار یا استفاده تجاری جداگانه مشخص نشده است.