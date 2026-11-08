import 'package:flutter/services.dart';

/// Result of inspecting an APK archive with Android's PackageManager.
class ApkInspection {
  final bool parsed;
  final String packageName;
  final int versionCode;
  final String versionName;
  final int minSdk;
  final int deviceSdk;
  final List<String> signatureHashes;
  final String? error;

  const ApkInspection({
    required this.parsed,
    this.packageName = '',
    this.versionCode = 0,
    this.versionName = '',
    this.minSdk = 0,
    this.deviceSdk = 0,
    this.signatureHashes = const [],
    this.error,
  });

  factory ApkInspection.unavailable(String message) =>
      ApkInspection(parsed: false, error: message);

  factory ApkInspection.fromMap(Map<String, dynamic> map) {
    return ApkInspection(
      parsed: map['parsed'] == true,
      packageName: map['packageName']?.toString() ?? '',
      versionCode: _asInt(map['versionCode']),
      versionName: map['versionName']?.toString() ?? '',
      minSdk: _asInt(map['minSdk']),
      deviceSdk: _asInt(map['deviceSdk']),
      signatureHashes: (map['signatureHashes'] as List<dynamic>? ?? const [])
          .map((item) => item.toString().toLowerCase())
          .toList(growable: false),
      error: map['error']?.toString(),
    );
  }
}

/// Data of the currently installed application.
class InstalledAppInfo {
  final String packageName;
  final int versionCode;
  final String versionName;
  final List<String> signatureHashes;
  final int deviceSdk;

  const InstalledAppInfo({
    required this.packageName,
    required this.versionCode,
    required this.versionName,
    required this.signatureHashes,
    required this.deviceSdk,
  });

  factory InstalledAppInfo.fromMap(Map<String, dynamic> map) {
    return InstalledAppInfo(
      packageName: map['packageName']?.toString() ?? '',
      versionCode: _asInt(map['versionCode']),
      versionName: map['versionName']?.toString() ?? '',
      signatureHashes: (map['signatureHashes'] as List<dynamic>? ?? const [])
          .map((item) => item.toString().toLowerCase())
          .toList(growable: false),
      deviceSdk: _asInt(map['deviceSdk']),
    );
  }
}

/// Contract used by the update flow; fakeable in tests.
abstract class ApkInspector {
  Future<ApkInspection> inspect(String apkPath);

  Future<InstalledAppInfo?> getInstalledApp();

  /// Whether the app may open the Android package installer.
  Future<bool> canRequestPackageInstalls();

  Future<void> openInstallPermissionSettings();
}

/// Implementation backed by a small MethodChannel in `MainActivity.kt`.
class NativeApkInspector implements ApkInspector {
  static const MethodChannel _channel = MethodChannel('mr/update/apk');

  @override
  Future<ApkInspection> inspect(String apkPath) async {
    try {
      final map = await _channel.invokeMapMethod<String, dynamic>('inspect', {
        'path': apkPath,
      });
      if (map == null) {
        return ApkInspection.unavailable('تعذر قراءة ملف التحديث.');
      }
      return ApkInspection.fromMap(map);
    } on MissingPluginException {
      return ApkInspection.unavailable(
        'أداة التحقق من التحديث غير متاحة على هذا النظام.',
      );
    } on PlatformException catch (error) {
      return ApkInspection.unavailable(
        error.message ?? 'تعذر التحقق من ملف التحديث.',
      );
    }
  }

  @override
  Future<InstalledAppInfo?> getInstalledApp() async {
    try {
      final map = await _channel.invokeMapMethod<String, dynamic>('installed');
      if (map == null) return null;
      return InstalledAppInfo.fromMap(map);
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }

  @override
  Future<bool> canRequestPackageInstalls() async {
    try {
      return await _channel.invokeMethod<bool>('canInstallPackages') ?? true;
    } on MissingPluginException {
      return true;
    } on PlatformException {
      return true;
    }
  }

  @override
  Future<void> openInstallPermissionSettings() async {
    try {
      await _channel.invokeMethod<void>('openInstallSettings');
    } on MissingPluginException {
      // Nothing we can do on non-Android platforms.
    } on PlatformException {
      // The UI keeps the retry action available.
    }
  }
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
