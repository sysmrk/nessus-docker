# Nessus Docker

این پروژه Nessus Vulnerability Scanner را با Docker Compose اجرا می‌کند و آن را پشت Nginx قرار می‌دهد.

هدف پروژه این است که بدون درگیر شدن با نصب دستی Nessus، بتوانید از طریق مرورگر به پنل Nessus دسترسی داشته باشید.

## معماری ساده

```text
Browser
  |
  | http://localhost:9934
  v
Nginx
  |
  | internal Docker network
  v
Nessus
```

سرویس Nessus مستقیم روی سیستم شما منتشر نمی‌شود. فقط Nginx روی `localhost` در دسترس است.

## سرویس‌ها

- `nessus`: ایمیج رسمی Tenable با نسخه `tenable/nessus:10.12.0-ubuntu`
- `nginx`: reverse proxy جلوی Nessus

## پیش‌نیازها

روی سیستم باید این‌ها نصب باشند:

- Docker
- Docker Compose

برای تست:

```bash
docker --version
docker-compose --version
docker ps
```

اگر `docker ps` خطای permission داد، کاربر خود را به گروه Docker اضافه کنید:

```bash
sudo usermod -aG docker "$USER"
newgrp docker
```

بعد دوباره تست کنید:

```bash
docker ps
```

## اجرای پروژه

از داخل پوشه پروژه اجرا کنید:

```bash
docker-compose -f docker-compose.yaml up -d --build
```

بعد از چند دقیقه، Nessus از این آدرس در دسترس است:

```text
http://localhost:9934
```

بار اول ممکن است Nessus چند دقیقه برای آماده‌سازی، لود پلاگین‌ها و تنظیم اولیه زمان بخواهد.

## ورود و راه‌اندازی اولیه Nessus

1. مرورگر را باز کنید.
2. وارد `http://localhost:9934` شوید.
3. اگر صفحه Nessus باز شد، مراحل ساخت کاربر، وارد کردن activation code و initialization را انجام دهید.
4. اگر صفحه هنوز آماده نبود، چند دقیقه صبر کنید و دوباره refresh کنید.

برای دیدن لاگ‌ها:

```bash
docker-compose -f docker-compose.yaml logs -f
```

برای دیدن فقط لاگ Nessus:

```bash
docker-compose -f docker-compose.yaml logs -f nessus
```

برای دیدن فقط لاگ Nginx:

```bash
docker-compose -f docker-compose.yaml logs -f nginx
```

## SSL اجباری نیست

حالت پیش‌فرض پروژه بدون SSL است و از HTTP روی `localhost` استفاده می‌کند:

```text
http://localhost:9934
```

این انتخاب عمدی است، چون بعضی کاربران نمی‌خواهند یا نمی‌توانند SSL را همان ابتدا تنظیم کنند. پروژه بدون SSL هم بالا می‌آید و کار می‌کند.

## فعال کردن SSL اختیاری

اگر SSL محلی می‌خواهید، در [docker-compose.yaml](docker-compose.yaml) مقدار زیر را تغییر دهید:

```yaml
ENABLE_SSL: "true"
```

بعد سرویس را دوباره بسازید:

```bash
docker-compose -f docker-compose.yaml up -d --build
```

آدرس HTTPS:

```text
https://localhost:9943
```

Nginx خودش یک certificate محلی self-signed می‌سازد. مرورگر به این certificate اعتماد ندارد، پس هشدار امنیتی نشان می‌دهد. این برای استفاده محلی طبیعی است.

اگر SSL را نمی‌خواهید، مقدار را روی `"false"` بگذارید یا همان حالت پیش‌فرض را نگه دارید.

## بررسی سلامت سرویس‌ها

وضعیت کانتینرها:

```bash
docker-compose -f docker-compose.yaml ps
```

مشاهده healthcheckها:

```bash
docker inspect --format='{{json .State.Health}}' docker-nessus-mrk_nessus_1
docker inspect --format='{{json .State.Health}}' docker-nessus-mrk_nginx_1
```

نام کانتینر ممکن است روی سیستم شما کمی فرق کند. برای دیدن نام دقیق:

```bash
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
```

## Healthcheckها چه چیزی را چک می‌کنند؟

برای Nessus:

- باز بودن پورت داخلی `8834`
- زمان شروع طولانی‌تر، چون Nessus در اولین اجرا دیرتر آماده می‌شود
- تعداد retry بیشتر برای جلوگیری از fail شدن زودهنگام

برای Nginx:

- سالم بودن خود Nginx از مسیر `/nginx-health`
- دسترسی Nginx به سرویس Nessus روی شبکه داخلی Docker
- اگر SSL فعال باشد، سالم بودن endpoint HTTPS هم بررسی می‌شود

## دستورهای کاربردی

اجرای پروژه:

```bash
docker-compose -f docker-compose.yaml up -d --build
```

توقف پروژه:

```bash
docker-compose -f docker-compose.yaml down
```

دیدن وضعیت:

```bash
docker-compose -f docker-compose.yaml ps
```

دیدن لاگ‌ها:

```bash
docker-compose -f docker-compose.yaml logs -f
```

ری‌استارت:

```bash
docker-compose -f docker-compose.yaml restart
```

حذف کامل کانتینرها:

```bash
docker-compose -f docker-compose.yaml down --remove-orphans
```

## نکته مهم درباره اطلاعات Nessus

طبق مستندات Tenable، ایمیج‌های Docker رسمی Nessus برای persistent storage volume پشتیبانی رسمی ندارند.

یعنی قبل از حذف یا جایگزین کردن کانتینر Nessus، اگر تنظیمات یا اطلاعات مهم دارید، از داخل خود Nessus backup/export بگیرید.

## عیب‌یابی

اگر صفحه باز نمی‌شود:

```bash
docker-compose -f docker-compose.yaml ps
docker-compose -f docker-compose.yaml logs --tail=100 nginx
docker-compose -f docker-compose.yaml logs --tail=100 nessus
```

اگر پورت اشغال است:

```bash
sudo lsof -i :9934
```

اگر Docker Compose خطای `ContainerConfig` داد:

```bash
docker-compose -f docker-compose.yaml down --remove-orphans
docker-compose -f docker-compose.yaml up -d --build
```

اگر باز هم مشکل بود، کانتینر خراب قبلی را حذف کنید:

```bash
docker ps -a
docker rm -f <container-name-or-id>
docker-compose -f docker-compose.yaml up -d --build
```

اگر SSL فعال است و مرورگر هشدار می‌دهد، طبیعی است؛ certificate محلی self-signed است.

## چرا از ایمیج رسمی استفاده شده؟

نسخه‌های قبلی پروژه یک Ubuntu قدیمی و فایل `.deb` قدیمی Nessus را داخل repo نگه می‌داشتند. این روش نگهداری سخت‌تر و از نظر امنیتی ضعیف‌تر است.

در نسخه فعلی:

- Ubuntu 16.04 حذف شده است.
- فایل `.deb` قدیمی حذف شده است.
- از ایمیج رسمی Tenable استفاده می‌شود.
- Nginx جلوی Nessus قرار گرفته است.
- SSL اجباری نیست و پروژه با HTTP محلی هم کار می‌کند.
