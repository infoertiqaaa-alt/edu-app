import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:mr/core/network/network_exceptions.dart';
import 'package:mr/features/update/data/datasources/apk_inspector.dart';
import 'package:mr/features/update/data/datasources/apk_installer.dart';
import 'package:mr/features/update/data/models/release_model.dart';
import 'package:mr/features/update/domain/repositories/update_repository.dart';

class FakeUpdateRepository implements UpdateRepository {
  ReleaseModel? release;
  bool downloadFails = false;
  final List<String> downloadedUrls = [];
  int downloadCount = 0;

  @override
  Future<Either<Failure, ReleaseModel>> getLatestRelease() async =>
      release != null
      ? Right(release!)
      : Left(const Failure('no release configured in fake'));

  @override
  Future<Either<Failure, void>> downloadReleaseApk(
    String url,
    String savePath, {
    void Function(int received, int total)? onProgress,
  }) async {
    downloadedUrls.add(url);
    downloadCount++;
    if (downloadFails) {
      return const Left(Failure('انقطاع الشبكة'));
    }
    final file = File(savePath);
    file.parent.createSync(recursive: true);
    // Minimal APK-like payload; validation is exercised through the fake
    // inspector, which is the abstraction the cubit actually depends on.
    file.writeAsBytesSync(const [0x50, 0x4B, 0x03, 0x04]);
    onProgress?.call(4, 4);
    return const Right(null);
  }
}

class FakeApkInstaller extends ApkInstaller {
  final List<String> installedPaths = [];

  @override
  Future<void> install(String apkPath) async {
    installedPaths.add(apkPath);
  }
}

class FakeApkInspector implements ApkInspector {
  ApkInspection inspection = const ApkInspection(
    parsed: true,
    packageName: 'com.example.teacher',
    versionCode: 7,
    versionName: '4.0.7',
    minSdk: 21,
    deviceSdk: 33,
    signatureHashes: ['aa11'],
  );

  InstalledAppInfo installed = const InstalledAppInfo(
    packageName: 'com.example.teacher',
    versionCode: 1,
    versionName: '4.0.1',
    signatureHashes: ['aa11'],
    deviceSdk: 33,
  );

  bool permissionGranted = true;
  bool openedInstallSettings = false;
  int inspectCalls = 0;

  @override
  Future<ApkInspection> inspect(String apkPath) async {
    inspectCalls++;
    return inspection;
  }

  @override
  Future<InstalledAppInfo?> getInstalledApp() async => installed;

  @override
  Future<bool> canRequestPackageInstalls() async => permissionGranted;

  @override
  Future<void> openInstallPermissionSettings() async {
    openedInstallSettings = true;
  }
}

ReleaseModel releaseWith(
  int versionCode, {
  String fileUrl = '',
  String? versionName,
  bool? isMandatory,
  String? sha256,
  int? minSupportedVersion,
}) {
  return ReleaseModel.fromJson({
    'id': versionCode,
    'version_code': versionCode,
    'version_name': versionName ?? '4.0.$versionCode',
    'changelog': '',
    'file_name': 'app-v4.0.$versionCode.apk',
    'file_url': fileUrl,
    'published_at': '2026-09-19T00:00:00+00:00',
    'is_mandatory': ?isMandatory,
    'sha256': ?sha256,
    'min_supported_version': ?minSupportedVersion,
  });
}
