import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mr/features/update/data/datasources/apk_installer.dart';
import 'package:mr/features/update/data/models/release_model.dart';
import 'package:mr/features/update/domain/repositories/update_repository.dart';
import 'package:mr/features/update/domain/usecases/download_release_apk.dart';
import 'package:mr/features/update/domain/usecases/get_latest_release.dart';
import 'package:mr/features/update/presentation/cubit/update_cubit.dart';
import 'package:mr/features/update/presentation/cubit/update_state.dart';
import 'package:mr/core/network/network_exceptions.dart';
import 'package:package_info_plus_platform_interface/package_info_data.dart';
import 'package:package_info_plus_platform_interface/package_info_platform_interface.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class FakePathProviderPlatform extends PathProviderPlatform {
  final String supportPath;

  FakePathProviderPlatform(this.supportPath);

  @override
  Future<String?> getApplicationSupportPath() async => supportPath;
}

/// بعد إعادة تشغيل التطبيق (تثبيت النسخة الجديدة أصلًا)، الـ PackageInfo
/// بيقرا من الجهاز مباشرة: المثبّت بقى 4.0.7 (build = 7) — نفس النسخة اللي
/// اتنزّلت قبل شوية من الـ backend.
class RestartPackageInfoPlatform extends PackageInfoPlatform {
  @override
  Future<PackageInfoData> getAll({String? baseUrl}) async {
    return PackageInfoData(
      appName: 'MR',
      packageName: 'com.ertiqaa.mr',
      version: '4.0.7',
      buildNumber: '7',
      buildSignature: '',
    );
  }
}

class FakeUpdateRepository implements UpdateRepository {
  ReleaseModel release =
      ReleaseModel.fromJson(<String, Object?>{'version_code': 7});
  bool failed = false;
  final List<String> downloadedUrls = [];

  @override
  Future<Either<Failure, ReleaseModel>> getLatestRelease() async => Right(release);

  @override
  Future<Either<Failure, void>> downloadReleaseApk(
    String url,
    String savePath, {
    void Function(int received, int total)? onProgress,
  }) async {
    downloadedUrls.add(url);
    if (failed) return const Left(Failure('خطأ في الشبكة'));
    File(savePath).parent.createSync(recursive: true);
    File(savePath).writeAsBytesSync([0x50, 0x4B, 0x03, 0x04]);
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late Directory supportDir;
  late Directory updatesDir;
  late FakeUpdateRepository repository;
  late FakeApkInstaller installer;
  late UpdateCubit cubit;

  setUpAll(() {
    PackageInfoPlatform.instance = RestartPackageInfoPlatform();
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('mr_restart_test_');
    supportDir = Directory('${tempDir.path}${Platform.pathSeparator}support');
    updatesDir = Directory(
      '${supportDir.path}${Platform.pathSeparator}updates',
    );
    PathProviderPlatform.instance = FakePathProviderPlatform(supportDir.path);

    repository = FakeUpdateRepository();
    installer = FakeApkInstaller();
    cubit = UpdateCubit(
      GetLatestRelease(repository),
      DownloadReleaseApk(repository),
      installer,
    );
  });

  tearDown(() async {
    await cubit.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  void writeApk(String name) {
    final file = File(
      '${updatesDir.path}${Platform.pathSeparator}$name',
    );
    file.parent.createSync(recursive: true);
    file.writeAsBytesSync(List<int>.filled(1, 0));
  }

  test('restart after install: installed(7) matches backend(7) -> no update, '
      'nothing downloaded, nothing installed, stale generic apk untouched', () async {
    // حتى لو جرّبنا نبدأ تحديث غصب (سيناريو الجسد القديم متخلف) —
    // ممنوع يحصل أي تنزيل أو تثبيت لأن النسخة المثبتة = نسخة الخادم.
    writeApk('app-update.apk');

    await cubit.checkForUpdate();
    await pumpEventQueue();

    expect(cubit.state, isA<UpdateNotRequired>());

    await cubit.startUpdate();
    await pumpEventQueue();

      expect(repository.downloadedUrls, isEmpty);
    expect(installer.installedPaths, isEmpty);
    expect(
      File('${updatesDir.path}${Platform.pathSeparator}app-update.apk')
          .existsSync(),
      isTrue,
    );
  });
}