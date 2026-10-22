# 🔍 تطبيق المفقودات | Lost & Found App

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.10%2B-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.0%2B-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Supabase](https://img.shields.io/badge/Backend-Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/Database-PostgreSQL-4169E1?style=for-the-badge&logo=postgresql&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

**منصة ذكية وآمنة لإدارة بلاغات المفقودات والعثور عليها، تعتمد على التواصل الهاتفي المباشر لتقليل الاحتيال، مع قاعدة بيانات سحابية محمية عبر Supabase.**

*A smart, secure Lost & Found reporting platform built with Flutter and Supabase, focusing on direct communication and fraud prevention with robust Row Level Security (RLS).*

[المميزات](#-المميزات-الأساسية--core-features) •
[التقنيات المستخدمة](#-التقنيات-المستخدمة--tech-stack) •
[طريقة التثبيت والتشغيل](#-طريقة-التثبيت-والتشغيل--getting-started) •
[إعداد قاعدة بيانات Supabase](#-إعداد-قاعدة-بيانات-supabase--supabase-setup) •
[هيكلية المشروع](#-هيكلية-المشروع--project-structure) •
[الأمان والخصوصية](#-الأمان-والخصوصية--security--privacy)

</div>

---

## 🎯 المميزات الأساسية | Core Features

- 🚫 **حماية ضد الاحتيال (Anti-Fraud by Design):** لا يعتمد التطبيق على رفع صور المفقودات لضمان عدم استغلالها من قِبل المحتالين، والتحقق يتم بالوصف الدقيق المباشر.
- 📞 **تواصل مباشر (Direct Contact):** إمكانية الاتصال فوراً برقم هاتف صاحب البلاغ أو المعثور عليه عبر زر اتصال مدمج (`url_launcher`).
- 🔒 **أمان متكامل عبر Supabase RLS:** حماية مستوى الصف (Row Level Security) تضمن ألا يعدل أو يحذف أي بلاغ إلا صاحبه الحقيقي.
- 🌐 **واجهة عربية كاملة (Full RTL Support):** تصميم انسيابي موجه بالكامل للغة العربية.
- 📊 **إدارة وتتبع حالة البلاغات:** تتبع مباشر للحالات الثلاث:
  * 🟡 **مفتوح (Open):** جارٍ البحث عنه.
  * 🔵 **قيد التواصل (Contacted):** تم التواصل بين الأطراف.
  * 🟢 **مغلق (Closed):** تمت استعادة الغرض بنجاح.
- 👤 **إدارة الحساب والملف الشخصي:** تسجيل وتعديل البيانات الأساسية، واستعراض قائمة "بلاغاتي" المخصصة لكل مستخدم.

---

## 🛠 التقنيات المستخدمة | Tech Stack

| المجال | التقنية | الوصف |
| :--- | :--- | :--- |
| **Framework** | [Flutter](https://flutter.dev/) | بناء التطبيق لأنظمة Android و iOS والويب |
| **Backend & Auth** | [Supabase](https://supabase.com/) | المصادقة وقاعدة البيانات وإدارة الجلسات في الوقت الفعلي |
| **Database** | [PostgreSQL](https://www.postgresql.org/) | قاعدة البيانات السحابية مع تفعيل سياسات الأمان RLS |
| **State & Navigation** | Flutter Reactive Streams | التفاعل الفوري مع تدفق حالات المصادقة (`onAuthStateChange`) |
| **Phone Integration** | [`url_launcher`](https://pub.dev/packages/url_launcher) | تشغيل تطبيق الهاتف للاتصال المباشر برقم المستخدم |
| **Formatting** | [`intl`](https://pub.dev/packages/intl) | تنسيق التواريخ والأوقات |

---

## 🚀 طريقة التثبيت والتشغيل | Getting Started

### 📋 المتطلبات المسبقة (Prerequisites)
* تثبيت **Flutter SDK** (الإصدار `3.10.4` أو أحدث).
* تثبيت **Git**.
* حساب مجاني على منصة [Supabase](https://supabase.com).

### 📥 خطوات التثبيت (Installation Steps)

1. **استنساخ المستودع (Clone):**
   ```bash
   git clone https://github.com/Yahya-Studio/losts_founds.git
   cd losts_founds
   ```

2. **تثبيت الحزم (Install Dependencies):**
   ```bash
   flutter pub get
   ```

3. **إعداد متغيرات البيئة (Configure Environment):**
   * انسخ ملف النموذج `.env.example` إلى `.env`:
     ```bash
     cp .env.example .env
     ```
   * ضع رابط مشروعك ومفتاح `anon` الخاص بـ Supabase (انظر القسم التالي).

4. **تشغيل التطبيق (Run):**
   يمكنك تمرير مفاتيح Supabase عبر `--dart-define` لتشغيل آمن دون وضع المفاتيح داخل الكود:
   ```bash
   flutter run --dart-define=SUPABASE_URL=https://your-project.supabase.co --dart-define=SUPABASE_ANON_KEY=your-anon-key
   ```

---

## 🗄 إعداد قاعدة بيانات Supabase | Supabase Setup

لإعداد الخادم وقاعدة البيانات في أقل من 5 دقائق:

### 1. إنشاء المشروع والحصول على المفاتيح
1. ادخل إلى [لوحة تحكم Supabase](https://supabase.com/dashboard) وأنشئ مشروعاً جديداً.
2. اذهب إلى **Project Settings** > **API**.
3. انسخ:
   * **Project URL**: رابط مشروعك.
   * **Project API Keys** (`anon` `public`): المفتاح العام.

### 2. تنفيذ المخطط الأمني (Database Schema)
1. في لوحة تحكم Supabase، افتح **SQL Editor** من القائمة الجانبية.
2. انسخ كامل محتوى الملف المرفق في المشروع: [`database_schema.sql`](file:///home/solan/Documents/antigravity/hopeful-chandrasekhar/losts_founds/database_schema.sql).
3. الصق الاستعلام في المحرر واضغط **Run**.

يقوم هذا السكريبت بإنشاء:
* جدول الملفات الشخصية `profiles` المتصل بنظام المصادقة.
* جدول البلاغات `reports`.
* جدول إشعارات المعثورات `found_notifications`.
* سياسات أمان مستوى الصف (Row Level Security - RLS) التي تمنع أي وصول غير مصرح به.

---

## 📁 هيكلية المشروع | Project Structure

```text
losts_founds/
├── lib/
│   ├── main.dart                 # نقطة البداية وإدارة حالة المصادقة (AuthWrapper)
│   ├── models/                   # نماذج البيانات
│   │   ├── user_model.dart       # نموذج المستخدم (Profile)
│   │   └── report_model.dart     # نموذج البلاغ (Report)
│   ├── repositories/             # طبقة التعامل مع Supabase
│   │   ├── auth_repository.dart  # عمليات تسجيل الدخول والتسجيل والخروج
│   │   ├── user_repository.dart  # جلب وتحديث بيانات الملف الشخصي
│   │   └── reports_repository.dart # إنشاء واسترجاع وتحديث حالة البلاغات
│   ├── screens/                  # شاشات التطبيق
│   │   ├── auth/                 # شاشات الدخول وإنشاء الحساب
│   │   ├── home/                 # الشاشة الرئيسية وعرض كافة البلاغات
│   │   ├── reports/              # إنشاء بلاغ جديد وقائمة بلاغاتي
│   │   └── profile/              # تعديل الملف الشخصي
│   ├── widgets/                  # المكونات المشتركة
│   │   ├── common/               # حقول الإدخال، الأزرار، وأيقونات التحميل
│   │   └── report_card.dart      # بطاقة عرض تفاصيل البلاغ مع زر الاتصال
│   └── utils/                    # الأدوات المساعدة
│       ├── constants.dart        # ثيمات الألوان وإعدادات Supabase من البيئة
│       └── validators.dart       # التحقق من صحة المدخلات (البريد، الهاتف)
├── database_schema.sql           # استعلام SQL لإنشاء جداول Supabase وسياسات RLS
├── .env.example                  # نموذج متغيرات البيئة
├── .gitignore                    # ملف التجاهل لحماية الأسرار
└── pubspec.yaml                  # تبعيات المشروع
```

---

## 🔐 الأمان والخصوصية | Security & Privacy

* **حماية الأسرار:** تم استخراج مفاتيح Supabase من الكود الثابت وجعلها تستقبل من متغيرات البيئة أو وسائط التشغيل (`--dart-define`).
* **أمان البيانات RLS:** تفرض قاعدة البيانات قواعد RLS بحيث لا يستطيع المستخدمون حذف أو تعديل سوى بلاغاتهم الخاصة.
* **حظر التتبع:** ملف `.gitignore` محصن لمنع رفع ملفات `.env` أو مفاتيح التطبيق وشهادات الأندرويد وiOS.

---

## 🤝 المساهمة | Contributing

نرحب بمساهمات المطورين لتحسين التطبيق!
1. قم بعمل **Fork** للمشروع.
2. أنشئ فرعاً جديداً لميزتك (`git checkout -b feature/NewFeature`).
3. سجّل التعديلات (`git commit -m 'Add NewFeature'`).
4. ارفع الفرع (`git push origin feature/NewFeature`).
5. افتح **Pull Request**.

---

## 📄 الترخيص | License

هذا المشروع متاح تحت رخصة **MIT**. راجع ملف `LICENSE` للمزيد من التفاصيل.

---

<div align="center">

صُنع بـ ❤️ بواسطة **[Yahya-Studio](https://github.com/Yahya-Studio)**

</div>
