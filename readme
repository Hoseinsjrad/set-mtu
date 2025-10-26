<p align="center">
<h1 align="center">set-mtu-persistent</h1>
<h6 align="center">تنظیم MTU به‌صورت پایدار در سرورهای اوبونتو</h6>
</p>

<h2>نصب و استفاده</h2>

<p>برای اجرای اسکریپت کافیست یک دستور زیر را وارد کنید:</p>

<pre><code>bash <(curl -fsSL https://raw.githubusercontent.com/Hoseinsjrad/set-mtu-persistent/main/set-mtu-persistent.sh)</code></pre>

<p>اسکریپت به صورت تعاملی از شما <strong>اینترفیس شبکه</strong> و <strong>مقدار MTU</strong> را می‌پرسد و تغییرات را اعمال می‌کند. همچنین تغییرات بعد از ریبوت نیز حفظ می‌شوند.</p>

<h2>نکات مهم</h2>
<ul>
  <li>MTU معمولاً بین 68 تا 9000 است. مقدار استاندارد 1500 و برای Jumbo Frames مقدار 9000 پیشنهاد می‌شود.</li>
  <li>در سرورهایی که از <strong>cloud-init</strong> استفاده می‌کنند، ممکن است فایل‌های شبکه بازنویسی شوند.</li>
  <li>تمام فایل‌های پیکربندی اصلی قبل از تغییر <strong>به صورت خودکار بکاپ</strong> گرفته می‌شوند.</li>
</ul>

<h2>بررسی MTU</h2>
<p>پس از اجرای اسکریپت، می‌توانید مقدار MTU را با دستور زیر بررسی کنید:</p>
<pre><code>ip link show &lt;interface-name&gt;</code></pre>

<h2>تلگرام</h2>
<p>
<a href="https://t.me/Hoseinsjrad" target="_blank">[@Hoseinsjrad](https://t.me/Hoseinsjrad)</a>
</p>
