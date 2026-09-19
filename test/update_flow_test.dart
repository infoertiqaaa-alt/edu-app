import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mr/core/network/network_exceptions.dart';
import 'package:mr/features/update/data/datasources/apk_installer.dart';
import 'package:mr/features/update/data/models/release_model.dart';
import 'package:mr/features/update/domain/repositories/update_repository.dart';
import 'package:mr/features/update/domain/usecases/download_release_apk.dart';
import 'package:mr/features/update/domain/usecases/get_latest_release.dart';
import 'package:mr/features/update/presentation/cubit/update_cubit.dart';
import 'package:mr/features/update/presentation/cubit/update_state.dart';
import 'package:package_info_plus_platform_interface/package_info_data.dart';
import 'package:package_info_plus_platform_interface/package_info_platform_interface.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class FakePathProviderPlatform extends PathProviderPlatform {
  final String supportPath;

  FakePathProviderPlatform(this.supportPath);

  @override
  Future<String?> getApplicationSupportPath() async => supportPath;
}

class FakePackageInfoPlatform extends PackageInfoPlatform {
  final int Function() buildNumberProvider;

  FakePackageInfoPlatform(this.buildNumberProvider);

  @override
  Future<PackageInfoData> getAll({String? baseUrl}) async {
    final buildNumber = buildNumberProvider();
    return PackageInfoData(
      appName: 'MR',
      packageName: 'com.ertiqaa.mr',
      version: '4.0.$buildNumber',
      buildNumber: '$buildNumber',
      buildSignature: '',
    );
  }
}

class FakeUpdateRepository implements UpdateRepository {
  ReleaseModel? release;
  bool downloadFails = false;
  final List<String> downloadedUrls = [];

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
    if (downloadFails) {
      return Left(const Failure('انقطاع الشبكة'));
    }
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

ReleaseModel releaseWith(int versionCode, {String fileUrl = ''}) {
  return ReleaseModel.fromJson({
    'id': versionCode,
    'version_code': versionCode,
    'version_name': '4.0.$versionCode',
    'changelog': '',
    'file_name': 'app-v4.0.$versionCode.apk',
    'file_size': 100,
    'file_url': fileUrl,
    'published_at': '2026-09-19T00:00:00+00:00',
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late int installedBuildNumber;
  late Directory tempDir;
  late Directory supportDir;
  late Directory updatesDir;
  late FakeUpdateRepository repository;
  late FakeApkInstaller installer;
  late UpdateCubit cubit;

  setUp(() async {
    installedBuildNumber = 1;
    PackageInfoPlatform.instance = FakePackageInfoPlatform(() => installedBuildNumber);
    tempDir = await Directory.systemTemp.createTemp('mr_update_test_');
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

  Future<UpdateState> requireUpdateAndStart({String? fileUrl}) async {
    repository.release = releaseWith(7, fileUrl: fileUrl ?? '');
    await cubit.checkForUpdate();
    await pumpEventQueue();
    expect(cubit.state, isA<UpdateRequired>());
    await cubit.startUpdate();
    await pumpEventQueue();
    return cubit.state;
  }

  void writeApk(String name, {int length = 1}) {
    final file = File(
      '${updatesDir.path}${Platform.pathSeparator}$name',
    );
    file.parent.createSync(recursive: true);
    file.writeAsBytesSync(List<int>.filled(length, 0));
  }

  String updatesPathFor(String name) =>
      '${updatesDir.path}${Platform.pathSeparator}$name';

  group('release-aware update flow (cubit)', () {
    test('first update: no cache -> downloads release fileUrl and installs',
        () async {
      const fileUrl = 'https://mr-edu.ertiqaa.site/storage/releases/app-v4.0.7.apk';

      final state = await requireUpdateAndStart(fileUrl: fileUrl);

      expect(repository.downloadedUrls, [fileUrl]);
      expect(installer.installedPaths, [updatesPathFor('app-update-7.apk')]);
      expect(state, isA<UpdateInstallStarted>());
      expect(File(updatesPathFor('app-update-7.apk')).existsSync(), isTrue);
    });

    test('second update: cached wrong-version apk is deleted, download new',
        () async {
      writeApk('app-update-6.apk');

      final state = await requireUpdateAndStart();

      expect(installer.installedPaths, [updatesPathFor('app-update-7.apk')]);
      expect(
        File(updatesPathFor('app-update-6.apk')).existsSync(),
        isFalse,
      );
      expect(File(updatesPathFor('app-update-7.apk')).existsSync(), isTrue);
      expect(state, isA<UpdateInstallStarted>());
    });

    test('legacy generic app-update.apk is deleted, never installed', () async {
      writeApk('app-update.apk');

      final state = await requireUpdateAndStart();

      expect(installer.installedPaths, [updatesPathFor('app-update-7.apk')]);
      expect(
        File(updatesPathFor('app-update.apk')).existsSync(),
        isFalse,
      );
      expect(state, isA<UpdateInstallStarted>());
    });

    test('correct cached versioned apk is reused without downloading',
        () async {
      writeApk('app-update-7.apk');

      final state = await requireUpdateAndStart();

      expect(repository.downloadedUrls, isEmpty);
      expect(installer.installedPaths, [updatesPathFor('app-update-7.apk')]);
      expect(state, isA<UpdateInstallStarted>());
    });

    test('empty cached apk is not considered valid -> downloads and installs',
        () async {
      writeApk('app-update-7.apk', length: 0);

      final state = await requireUpdateAndStart();

      expect(repository.downloadedUrls, isNotEmpty);
      expect(installer.installedPaths, [updatesPathFor('app-update-7.apk')]);
      expect(
        File(updatesPathFor('app-update-7.apk')).lengthSync(),
        greaterThan(0),
      );
      expect(state, isA<UpdateInstallStarted>());
    });

    test('download failure: no fallback to any old apk, error state', () async {
      writeApk('app-update-3.apk');
      repository.downloadFails = true;

      final state = await requireUpdateAndStart();

      expect(installer.installedPaths, isEmpty);
      expect(state, isA<UpdateDownloadFailed>());
      expect(
        (state as UpdateDownloadFailed).message,
        'انقطاع الشبكة',
      );
      expect(
        File(updatesPathFor('app-update-7.apk')).existsSync(),
        isFalse,
      );
      expect(File(updatesPathFor('app-update-3.apk')).existsSync(), isFalse);
    });

    test('restart after install: installed == backend -> not required, '
        'nothing is downloaded/installed', () async {
      repository.release = releaseWith(installedBuildNumber);

      await cubit.checkForUpdate();
      await pumpEventQueue();

      expect(cubit.state, isA<UpdateNotRequired>());

      await cubit.startUpdate();
      await pumpEventQueue();

      expect(repository.downloadedUrls, isEmpty);
      expect(installer.installedPaths, isEmpty);
    });

    test('fallbacks to /latest/download when release has no file_url',
        () async {
      final state = await requireUpdateAndStart();

      expect(
        repository.downloadedUrls,
        ['/app/releases/latest/download'],
      );
      expect(state, isA<UpdateInstallStarted>());
    });
  });
}