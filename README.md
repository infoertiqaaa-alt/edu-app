# MR

تطبيق Flutter لإدارة ومتابعة الدروس والتقارير للطلاب والمساعدين.

> **ملاحظة عن هوية التطبيق:** القيمة الحالية `applicationId` هي
> `com.example.teacher` (موروثة من قالب Flutter). تغييرها يغيّر هوية التطبيق
> بالكامل ويمنع التحديث فوق النسخ المثبتة، لذلك لا تتم إلا بقرار صريح من مالك
> المنتج وبعد تخطيط ترحيل. خط إصدارات CI يتحقق من ثباتها ولا يغيّرها تلقائيًا.

## المتطلبات

- Flutter **3.47.9** (Dart 3.13.x) — الإصدار مثبّت في CI.
- Java 17.
- Android SDK (للبناء والتوقيع).

## التشغيل المحلي

```bash
flutter pub get
flutter run
```

التطبيق يتصل افتراضيًا ببيئة الإنتاج. لتشغيله على بيئة تطوير:

```bash
flutter run \
  --dart-define=APP_ENV=development \
  --dart-define=API_BASE_URL=https://dev.example.com/api/v1 \
  --dart-define=STORAGE_BASE_URL=https://dev.example.com/storage
```

كل متغيرات البيئة موثّقة في [`docs/ENVIRONMENT.md`](docs/ENVIRONMENT.md).

## البنية

بنية Clean Architecture موزّعة على features:

```
lib/
  core/          # الإعدادات، الشبكة، الجلسة، التخزين، الثيم، الأدوات
  features/
    auth/        # تسجيل الدخول والجلسة
    onboarding/
    lessons/     # الدروس، الفيديو، الملاحظات المحلية
    student/     # الملف الشخصي والتقارير
    assistant/   # مسح QR وتسجيل الحضور
    update/      # فحص وتنزيل وتحقق وتثبيت تحديثات الـ APK
```

- إدارة الحالة: Cubit (`flutter_bloc`).
- حقن التبعيات: `get_it`.
- الشبكة: `dio` + `dartz/Either`.
- التخزين الآمن: `flutter_secure_storage`.
- الملاحظات: SQLite عبر `sqflite` مع عزل لكل مستخدم.

## الفحص والاختبارات

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

> على Windows، إن لم يعمل أمر `dart` بسبب غياب Git، استخدم:
> `C:\src\flutter\bin\cache\dart-sdk\bin\dart.exe format .`

## الإصدارات

مصدر الحقيقة الوحيد هو `pubspec.yaml`:

```yaml
version: 4.0.11+11
```

- `4.0.11` = `versionName`
- `11` = `versionCode` (يجب أن يزيد دائمًا ولا يُعاد استخدامه أو إنقاصه)

أي إصدار جديد يتطلب أيضًا قسمًا مطابقًا في `CHANGELOG.md` (`## 4.0.11`).

## تحديث التطبيق

- التطبيق يقرأ `GET /app/releases/latest`.
- يحمّل الملف من `file_url` فقط إذا كان HTTPS وعلى مضيف موثوق وينتهي بـ `.apk`،
  وإلا يستخدم `GET /app/releases/latest/download`.
- قبل فتح المثبّت يتحقق من: الحجم، SHA-256 (إن توفّر)، هوية الحزمة، رقم/اسم
  الإصدار، توقيع التطبيق، وحد أدنى Android SDK.
- التحديث الإجباري مفعّل افتراضيًا، ويمكن للخادم جعله اختياريًا عبر
  `is_mandatory: false` مع الالتزام بـ `min_supported_version`.

تفاصيل العقد الكامل في [`docs/UPDATE_FLOW.md`](docs/UPDATE_FLOW.md).

## CI/CD

- `.github/workflows/ci.yml`: فحص التنسيق والتحليل والاختبارات وبناء Debug APK
  على كل Pull Request.
- `.github/workflows/release.yml`: إصدار APK موقّع، مع فحص جودة، تحقق من
  الهوية/الإصدار/التوقيع/SHA-256، رفع ذري للسيرفر، ونشر والتحقق من نقطة
  التنزيل.

الإصدار يعمل من فرع `main` فقط وتحت بيئة GitHub باسم `production`؛ يجب تفعيل
المراجعين الإلزاميين وحماية الفرع من إعدادات GitHub (موضحة في قسم Governance).

التفاصيل والمتطلبات في [`docs/CI_CD_RELEASE.md`](docs/CI_CD_RELEASE.md)،
وإجراءات التراجع في [`docs/ROLLBACK.md`](docs/ROLLBACK.md).
