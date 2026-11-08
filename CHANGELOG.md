# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and the version numbers here MUST match the `version:` field in `pubspec.yaml`.

The CI/CD pipeline automatically reads the `## <version>` section that matches the
current `pubspec.yaml` version name and sends it to the Backend as the release
changelog. If a matching section is missing, the release workflow will fail.

## 5.0.2

### Fixed

* إصلاح دورة التحديث: التحقق من ملف الـ APK (الحزمة/الإصدار/التوقيع/SHA-256)
  قبل فتح المثبّت، وعدم إعادة استخدام ملفات تنزيل قديمة أو جزئية.
* حفظ صلاحية الجلسة بشكل متكامل (token + role + user id) وتسجيل الخروج عند
  انتهاء الصلاحية بدلًا من الدخول في حلقات أخطاء.
* عزل ملاحظات الدروس لكل مستخدم مع ترحيل آمن للملاحظات القديمة.
* تحسين قراءة أرقام التقارير المالية والبيانات النصية غير المتسقة.
* رفض روابط فيديو YouTube غير الصالحة بدلًا من تشغيل فيديو ثابت غير تابع للدرس.
* تضمين خطوط Cairo وTajawal داخل التطبيق وإزالة الاعتماد على تنزيل الخطوط وقت التشغيل.
* شاشة التحديث الإجباري تبقى ظاهرة بعد فتح المثبّت حتى يكتمل التثبيت فعليًا،
  مع زر لإعادة فتح المثبّت (إلغاء المثبّت لم يعد يتخطى التحديث الإجباري).
* عرض رسالة الخادم الفعلية عند فشل تحميل الدروس أو الملف الشخصي أو التقارير
  أو بيانات الطالب الممسوح بدلًا من رسالة عامة.
* منع تسجيل الحضور مرتين بالضغط المتكرر وإظهار حالة التحميل على الزر.
* عدم تسجيل خروج المستخدم بسبب خطأ 401 من رابط تنزيل التحديث العام.

### CI/CD

* إضافة فحص تنسيق وتحليل واختبارات إلزامية قبل أي إصدار.
* تثبيت إصدار Flutter والأدوات، وتشديد التحقق من التوقيع وهوية الحزمة ورقم
  الإصدار وبصمة SHA-256، ورفع الملف بشكل ذري.
* اسم ملف فريد لكل إصدار (`app-v<version_name>-<version_code>.apk`) وعدم
  استبدال أي ملف إصدار موجود على الخادم.
* تقييد الإصدار على فرع `main` وبيئة `production`، وفرض `pubspec.lock`.

## 4.0.10

* Initial release
