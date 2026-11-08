import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:mr/core/network/network_exceptions.dart';

import '../datasources/apk_inspector.dart';
import '../models/release_model.dart';

class ApkValidationResult {
  final bool isValid;
  final String message;
  final ApkInspection? inspection;
  final String? sha256;

  const ApkValidationResult._({
    required this.isValid,
    this.message = '',
    this.inspection,
    this.sha256,
  });

  factory ApkValidationResult.valid(ApkInspection inspection, String sha256) =>
      ApkValidationResult._(
        isValid: true,
        inspection: inspection,
        sha256: sha256,
      );

  factory ApkValidationResult.invalid(String message) =>
      ApkValidationResult._(isValid: false, message: message);
}

/// Validates a downloaded APK before it is ever handed to Android's installer.
///
/// Checks, in order: file presence/size, optional SHA-256, real Android package
/// metadata, package id, version code/name, signing certificate compatibility
/// and minimum SDK compatibility.
class ApkValidationService {
  final ApkInspector inspector;
  final int minimumApkBytes;

  const ApkValidationService(
    this.inspector, {
    this.minimumApkBytes = 1024 * 1024,
  });

  Future<ApkValidationResult> validate({
    required File file,
    required ReleaseModel release,
    required InstalledAppInfo installed,
  }) async {
    if (!await file.exists()) {
      return ApkValidationResult.invalid('ملف التحديث غير موجود.');
    }

    final length = await file.length();
    if (length == 0) {
      return ApkValidationResult.invalid('ملف التحديث فارغ.');
    }
    if (length < minimumApkBytes) {
      return ApkValidationResult.invalid(
        'ملف التحديث غير مكتمل أو تالف (الحجم أصغر من المتوقع).',
      );
    }

    final expectedSize = release.fileSize;
    if (expectedSize != null && expectedSize > 0 && length != expectedSize) {
      return ApkValidationResult.invalid(
        'حجم ملف التحديث لا يطابق البيانات المنشورة. '
        'أعد المحاولة أو تواصل مع الدعم.',
      );
    }

    final sha256 = await _sha256Of(file);

    final expectedHash = release.sha256?.trim().toLowerCase();
    if (expectedHash != null && expectedHash.isNotEmpty) {
      if (expectedHash != sha256) {
        return ApkValidationResult.invalid(
          'ملف التحديث تالف أو تم تعديله (checksum غير مطابق).',
        );
      }
    }

    final ApkInspection inspection;
    try {
      inspection = await inspector.inspect(file.path);
    } catch (_) {
      return ApkValidationResult.invalid('تعذر فحص ملف التحديث.');
    }

    if (!inspection.parsed) {
      return ApkValidationResult.invalid(
        inspection.error ??
            'ملف التحديث غير صالح أو لا يمكن لـ Android قراءته.',
      );
    }

    if (inspection.packageName.isEmpty) {
      return ApkValidationResult.invalid(
        'ملف التحديث لا يحتوي على هوية تطبيق صالحة.',
      );
    }

    final expectedVersionCode = release.versionCode;
    if (expectedVersionCode == null || expectedVersionCode <= 0) {
      return ApkValidationResult.invalid(
        'بيانات الإصدار المنشور لا تحتوي version_code صالح.',
      );
    }

    if (inspection.versionCode != expectedVersionCode) {
      return ApkValidationResult.invalid(
        'ملف التحديث لا يطابق رقم الإصدار المنشور '
        '(متوقع: $expectedVersionCode، موجود: ${inspection.versionCode}).',
      );
    }

    final expectedVersionName = release.versionName.trim();
    if (expectedVersionName.isNotEmpty &&
        inspection.versionName.trim().isNotEmpty &&
        inspection.versionName.trim() != expectedVersionName) {
      return ApkValidationResult.invalid(
        'اسم إصدار ملف التحديث لا يطابق البيانات المنشورة.',
      );
    }

    if (installed.packageName.isNotEmpty &&
        inspection.packageName != installed.packageName) {
      return ApkValidationResult.invalid(
        'حزمة التحديث لا تنتمي لهذا التطبيق '
        '(${inspection.packageName}).',
      );
    }

    if (inspection.signatureHashes.isEmpty) {
      return ApkValidationResult.invalid('ملف التحديث غير موقّع.');
    }

    if (installed.signatureHashes.isEmpty) {
      return ApkValidationResult.invalid(
        'تعذر التحقق من توقيع التطبيق المثبّت.',
      );
    }

    final installedSignatures = installed.signatureHashes
        .map((hash) => hash.toLowerCase())
        .toSet();
    final hasMatchingSignature = inspection.signatureHashes.any(
      installedSignatures.contains,
    );

    if (!hasMatchingSignature) {
      return ApkValidationResult.invalid(
        'توقيع ملف التحديث لا يطابق التطبيق المثبّت. '
        'لن يتمكن Android من تثبيت هذا التحديث فوق النسخة الحالية.',
      );
    }

    final deviceSdk = installed.deviceSdk > 0
        ? installed.deviceSdk
        : inspection.deviceSdk;
    if (inspection.minSdk > 0 &&
        deviceSdk > 0 &&
        inspection.minSdk > deviceSdk) {
      return ApkValidationResult.invalid(
        'هذا التحديث لا يدعم إصدار Android الموجود على جهازك.',
      );
    }

    if (release.fileName.trim().isNotEmpty &&
        !release.fileName.trim().toLowerCase().endsWith('.apk')) {
      return ApkValidationResult.invalid('الملف المنشور ليس ملف APK صالحًا.');
    }

    return ApkValidationResult.valid(inspection, sha256);
  }

  static Future<String> _sha256Of(File file) async {
    try {
      final digest = await sha256.bind(file.openRead()).first;
      return digest.toString();
    } on FileSystemException {
      throw const ApiException('تعذر قراءة ملف التحديث لحساب checksum.');
    }
  }
}
