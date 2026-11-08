import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mr/features/update/data/datasources/apk_inspector.dart';
import 'package:mr/features/update/data/services/apk_validation_service.dart';
import 'package:mr/features/update/domain/usecases/download_release_apk.dart';
import 'package:mr/features/update/domain/usecases/get_latest_release.dart';
import 'package:mr/features/update/presentation/cubit/update_cubit.dart';
import 'package:mr/features/update/presentation/cubit/update_state.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import 'helpers/update_fakes.dart';

class FakePathProviderPlatform extends PathProviderPlatform {
  final String supportPath;

  FakePathProviderPlatform(this.supportPath);

  @override
  Future<String?> getApplicationSupportPath() async => supportPath;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late Directory supportDir;
  late Directory updatesDir;
  late FakeUpdateRepository repository;
  late FakeApkInstaller installer;
  late FakeApkInspector inspector;
  late UpdateCubit cubit;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('mr_restart_test_');
    supportDir = Directory('${tempDir.path}${Platform.pathSeparator}support');
    updatesDir = Directory(
      '${supportDir.path}${Platform.pathSeparator}updates',
    );
    PathProviderPlatform.instance = FakePathProviderPlatform(supportDir.path);

    repository = FakeUpdateRepository();
    installer = FakeApkInstaller();
    inspector = FakeApkInspector();
    // After a successful install and restart, the device reports version 7.
    inspector.installed = const InstalledAppInfo(
      packageName: 'com.example.teacher',
      versionCode: 7,
      versionName: '4.0.7',
      signatureHashes: ['aa11'],
      deviceSdk: 33,
    );

    cubit = UpdateCubit(
      GetLatestRelease(repository),
      DownloadReleaseApk(repository),
      installer,
      inspector,
      ApkValidationService(inspector, minimumApkBytes: 4),
    );
  });

  tearDown(() async {
    await cubit.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  void writeApk(String name) {
    final file = File('${updatesDir.path}${Platform.pathSeparator}$name');
    file.parent.createSync(recursive: true);
    file.writeAsBytesSync(List<int>.filled(4, 0));
  }

  test('restart after install: installed(7) == backend(7) -> no update, '
      'nothing downloaded or installed, stale generic apk untouched', () async {
    // Even if a stale generic APK is left behind, it must never be used.
    writeApk('app-update.apk');
    repository.release = releaseWith(7);

    await cubit.checkForUpdate();
    await pumpEventQueue();
    expect(cubit.state, isA<UpdateNotRequired>());

    await cubit.startUpdate();
    await pumpEventQueue();

    expect(repository.downloadedUrls, isEmpty);
    expect(installer.installedPaths, isEmpty);
    expect(
      File(
        '${updatesDir.path}${Platform.pathSeparator}app-update.apk',
      ).existsSync(),
      isTrue,
    );
  });

  test(
    'after restart, a newer backend version still triggers an update',
    () async {
      repository.release = releaseWith(8, versionName: '4.0.8');
      inspector.inspection = const ApkInspection(
        parsed: true,
        packageName: 'com.example.teacher',
        versionCode: 8,
        versionName: '4.0.8',
        minSdk: 21,
        deviceSdk: 33,
        signatureHashes: ['aa11'],
      );

      await cubit.checkForUpdate();
      await pumpEventQueue();
      expect(cubit.state, isA<UpdateRequired>());

      await cubit.startUpdate();
      await pumpEventQueue();

      expect(installer.installedPaths.length, 1);
      expect(cubit.state, isA<UpdateInstallStarted>());
    },
  );
}
