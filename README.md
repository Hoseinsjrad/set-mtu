<h1>🔥 set-mtu-persistent</h1>

<p>سلام! 👋 این اسکریپت برای <strong>تنظیم MTU سرورهای اوبونتو</strong> طراحی شده تا هم <strong>فوری اعمال</strong> شود و هم بعد از <strong>ریبوت</strong> حفظ شود. اگر دنبال یک روش ساده و سریع برای بهینه‌سازی شبکه سرورت هستی، این اسکریپت مخصوص توست!</p>

<h2>⚡ ویژگی‌های کلیدی</h2>
<ul>
  <li>پشتیبانی از <strong>Netplan</strong>، <strong>NetworkManager</strong> و <strong>Fallback systemd</strong></li>
  <li>اعمال MTU به صورت <strong>فوری و پایدار</strong></li>
  <li>ایجاد <strong>بکاپ خودکار</strong> از فایل‌های شبکه قبل از تغییر</li>
  <li>استفاده آسان با <strong>یک دستور کوتاه</strong>، بدون نیاز به cd یا chmod</li>
</ul>

<h2>🚀 نحوه استفاده آسان</h2>
<p>کافیه فقط یک دستور تو ترمینال بزنی و همه چیز خودکار انجام میشه:</p>

<pre><code>sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/Hoseinsjrad/set-mtu-persistent/main/set-mtu-persistent.sh)"</code></pre>

<p>اسکریپت به صورت تعاملی ازت می‌پرسه:</p>
<ul>
  <li>کدوم اینترفیس شبکه رو میخوای تغییر بدی</li>
  <li>مقدار MTU دلخواهت چقدره</li>
</ul>
<p>و بعد خودش همه تغییرات رو اعمال میکنه و حتی بعد از ریبوت هم باقی می‌مونه. 😎</p>

<h3>💡 نکات مهم</h3>
<ul>
  <li>محدوده MTU: بین 68 تا 9000. معمولاً 1500 استاندارده و 9000 برای Jumbo Frames مناسب.</li>
  <li>در سرورهایی که از <strong>cloud-init</strong> استفاده می‌کنن، ممکنه فایل شبکه بازنویسی بشه.</li>
  <li>تمام فایل‌های اصلی قبل از تغییر <strong>به صورت خودکار بکاپ</strong> گرفته میشه.</li>
</ul>

<div class="note">
  ⚠️ این روش نیاز به اینترنت داره چون اسکریپت مستقیم از GitHub دانلود میشه.
</div>

<h2>🔍 بررسی MTU</h2>
<p>بعد از اعمال تغییرات، برای اطمینان از مقدار MTU از دستور زیر استفاده کن:</p>

<pre><code>ip link show &lt;interface-name&gt;</code></pre>
