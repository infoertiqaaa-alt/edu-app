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
    tempDir = await Directory.systemTemp.createTemp('mr_update_test_');
    supportDir = Directory('${tempDir.path}${Platform.pathSeparator}support');
    updatesDir = Directory(
      '${supportDir.path}${Platform.pathSeparator}updates',
    );
    PathProviderPlatform.instance = FakePathProviderPlatform(supportDir.path);

    repository = FakeUpdateRepository();
    installer = FakeApkInstaller();
    inspector = FakeApkInspector();
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

  Future<UpdateState> requireUpdateAndStart({String? fileUrl}) async {
    repository.release = releaseWith(7, fileUrl: fileUrl ?? '');
    await cubit.checkForUpdate();
    await pumpEventQueue();
    expect(cubit.state, isA<UpdateRequired>());
    await cubit.startUpdate();
    await pumpEventQueue();
    return cubit.state;
  }

  void writeApk(String name, {int length = 4}) {
    final file = File('${updatesDir.path}${Platform.pathSeparator}$name');
    file.parent.createSync(recursive: true);
    file.writeAsBytesSync(List<int>.filled(length, 0));
  }

  String updatesPathFor(String name) =>
      '${updatesDir.path}${Platform.pathSeparator}$name';

  group('release-aware update flow (cubit)', () {
    test(
      'first update: no cache -> downloads release fileUrl and installs',
      () async {
        const fileUrl =
            'https://mr-edu.ertiqaa.site/storage/releases/app-v4.0.7.apk';

        final state = await requireUpdateAndStart(fileUrl: fileUrl);

        expect(repository.downloadedUrls, [fileUrl]);
        expect(installer.installedPaths, [updatesPathFor('app-update-7.apk')]);
        expect(state, isA<UpdateInstallStarted>());
        expect(File(updatesPathFor('app-update-7.apk')).existsSync(), isTrue);
      },
    );

    test('stale versioned apk is deleted before downloading', () async {
      writeApk('app-update-6.apk');

      final state = await requireUpdateAndStart();

      expect(installer.installedPaths, [updatesPathFor('app-update-7.apk')]);
      expect(File(updatesPathFor('app-update-6.apk')).existsSync(), isFalse);
      expect(File(updatesPathFor('app-update-7.apk')).existsSync(), isTrue);
      expect(state, isA<UpdateInstallStarted>());
    });

    test('legacy generic app-update.apk is deleted, never installed', () async {
      writeApk('app-update.apk');

      final state = await requireUpdateAndStart();

      expect(installer.installedPaths, [updatesPathFor('app-update-7.apk')]);
      expect(File(updatesPathFor('app-update.apk')).existsSync(), isFalse);
      expect(state, isA<UpdateInstallStarted>());
    });

    test('fully validated cached apk is reused without downloading', () async {
      writeApk('app-update-7.apk');

      final state = await requireUpdateAndStart();

      expect(repository.downloadedUrls, isEmpty);
      expect(inspector.inspectCalls, 1);
      expect(installer.installedPaths, [updatesPathFor('app-update-7.apk')]);
      expect(state, isA<UpdateInstallStarted>());
    });

    test('empty cached apk is not valid -> downloaded again', () async {
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

    test(
      'cached apk with mismatched version code is rejected and removed',
      () async {
        writeApk('app-update-7.apk');
        inspector.inspection = const ApkInspection(
          parsed: true,
          packageName: 'com.example.teacher',
          versionCode: 6,
          versionName: '4.0.6',
          minSdk: 21,
          deviceSdk: 33,
          signatureHashes: ['aa11'],
        );

        final state = await requireUpdateAndStart();

        // First validation fails, so the cached file is deleted and a fresh
        // download is validated with the (still wrong) fake inspector.
        expect(repository.downloadedUrls, isNotEmpty);
        expect(installer.installedPaths, isEmpty);
        expect(state, isA<UpdateValidationFailed>());
        expect(File(updatesPathFor('app-update-7.apk')).existsSync(), isFalse);
      },
    );

    test('download failure: no fallback to any old apk, error state', () async {
      writeApk('app-update-3.apk');
      repository.downloadFails = true;

      final state = await requireUpdateAndStart();

      expect(installer.installedPaths, isEmpty);
      expect(state, isA<UpdateDownloadFailed>());
      expect((state as UpdateDownloadFailed).message, 'انقطاع الشبكة');
      expect(File(updatesPathFor('app-update-7.apk')).existsSync(), isFalse);
      expect(File(updatesPathFor('app-update-3.apk')).existsSync(), isFalse);
    });

    test(
      'restart after install: installed == backend -> not required',
      () async {
        inspector.installed = const InstalledAppInfo(
          packageName: 'com.example.teacher',
          versionCode: 7,
          versionName: '4.0.7',
          signatureHashes: ['aa11'],
          deviceSdk: 33,
        );
        repository.release = releaseWith(7);

        await cubit.checkForUpdate();
        await pumpEventQueue();
        expect(cubit.state, isA<UpdateNotRequired>());

        await cubit.startUpdate();
        await pumpEventQueue();
        expect(repository.downloadedUrls, isEmpty);
        expect(installer.installedPaths, isEmpty);
      },
    );

    test(
      'uses absolute /latest/download when release has no file_url',
      () async {
        final state = await requireUpdateAndStart();

        expect(repository.downloadedUrls, [
          'https://mr-edu.ertiqaa.site/api/v1/app/releases/latest/download',
        ]);
        expect(state, isA<UpdateInstallStarted>());
      },
    );

    test(
      'optional release does not block and is never auto-installed',
      () async {
        repository.release = releaseWith(7, isMandatory: false);

        await cubit.checkForUpdate();
        await pumpEventQueue();

        expect(cubit.state, isA<UpdateOptionalAvailable>());

        await cubit.startUpdate();
        await pumpEventQueue();

        expect(repository.downloadedUrls, isEmpty);
        expect(installer.installedPaths, isEmpty);
      },
    );

    test('min_supported_version forces mandatory even when optional', () async {
      repository.release = releaseWith(
        7,
        isMandatory: false,
        minSupportedVersion: 7,
      );

      await cubit.checkForUpdate();
      await pumpEventQueue();

      expect(cubit.state, isA<UpdateRequired>());
    });

    test(
      'missing install permission surfaces a settings/retry state',
      () async {
        inspector.permissionGranted = false;

        final state = await requireUpdateAndStart();

        expect(state, isA<UpdateInstallPermissionRequired>());
        expect(installer.installedPaths, isEmpty);
        expect(File(updatesPathFor('app-update-7.apk')).existsSync(), isTrue);

        await cubit.openInstallPermissionSettings();
        expect(inspector.openedInstallSettings, isTrue);
      },
    );

    test('checksum mismatch rejects the download before install', () async {
      repository.release = releaseWith(7, sha256: 'deadbeef');

      await cubit.checkForUpdate();
      await pumpEventQueue();
      await cubit.startUpdate();
      await pumpEventQueue();

      expect(cubit.state, isA<UpdateValidationFailed>());
      expect(installer.installedPaths, isEmpty);
      expect(File(updatesPathFor('app-update-7.apk')).existsSync(), isFalse);
    });

    test('signature mismatch rejects the download before install', () async {
      inspector.inspection = const ApkInspection(
        parsed: true,
        packageName: 'com.example.teacher',
        versionCode: 7,
        versionName: '4.0.7',
        minSdk: 21,
        deviceSdk: 33,
        signatureHashes: ['different'],
      );

      final state = await requireUpdateAndStart();

      expect(state, isA<UpdateValidationFailed>());
      expect(installer.installedPaths, isEmpty);
    });

    test('package id mismatch rejects the download before install', () async {
      inspector.inspection = const ApkInspection(
        parsed: true,
        packageName: 'com.attacker.app',
        versionCode: 7,
        versionName: '4.0.7',
        minSdk: 21,
        deviceSdk: 33,
        signatureHashes: ['aa11'],
      );

      final state = await requireUpdateAndStart();

      expect(state, isA<UpdateValidationFailed>());
      expect(installer.installedPaths, isEmpty);
    });

    test('unsupported minSdk rejects the download before install', () async {
      inspector.inspection = const ApkInspection(
        parsed: true,
        packageName: 'com.example.teacher',
        versionCode: 7,
        versionName: '4.0.7',
        minSdk: 35,
        deviceSdk: 33,
        signatureHashes: ['aa11'],
      );

      final state = await requireUpdateAndStart();

      expect(state, isA<UpdateValidationFailed>());
      expect(installer.installedPaths, isEmpty);
    });

    test('retry after a download failure performs a fresh download', () async {
      repository.release = releaseWith(7);
      await cubit.checkForUpdate();
      await pumpEventQueue();

      repository.downloadFails = true;
      await cubit.startUpdate();
      await pumpEventQueue();
      expect(cubit.state, isA<UpdateDownloadFailed>());
      expect(repository.downloadCount, 1);
      expect(installer.installedPaths, isEmpty);

      repository.downloadFails = false;
      await cubit.startUpdate();
      await pumpEventQueue();

      expect(repository.downloadCount, 2);
      expect(cubit.state, isA<UpdateInstallStarted>());
      expect(installer.installedPaths, [updatesPathFor('app-update-7.apk')]);
    });

    test(
      'untrusted file_url falls back to the backend download endpoint',
      () async {
        final state = await requireUpdateAndStart(
          fileUrl: 'https://evil.example.com/app.apk',
        );

        expect(repository.downloadedUrls, [
          'https://mr-edu.ertiqaa.site/api/v1/app/releases/latest/download',
        ]);
        expect(state, isA<UpdateInstallStarted>());
      },
    );

    test('escape hatch appears only after two consecutive failures', () async {
      repository.downloadFails = true;

      final first = await requireUpdateAndStart();
      expect(first, isA<UpdateDownloadFailed>());
      expect(cubit.canContinueOffline, isFalse);

      // Calling it too early must not bypass the mandatory gate.
      cubit.continueWithoutUpdate();
      expect(cubit.state, isA<UpdateDownloadFailed>());

      await cubit.startUpdate();
      await pumpEventQueue();
      expect(cubit.state, isA<UpdateDownloadFailed>());
      expect(cubit.canContinueOffline, isTrue);

      cubit.continueWithoutUpdate();
      expect(cubit.state, isA<UpdateDeferred>());
      expect(installer.installedPaths, isEmpty);
    });

    test('opening the installer is not success: the gate stays and no escape '
        'hatch is offered right away', () async {
      final state = await requireUpdateAndStart();

      expect(state, isA<UpdateInstallStarted>());
      expect(cubit.canContinueOffline, isFalse);
      cubit.continueWithoutUpdate();
      expect(cubit.state, isA<UpdateInstallStarted>());
    });

    test('reopening the installer re-validates the cached apk without '
        're-downloading', () async {
      await requireUpdateAndStart();
      expect(repository.downloadCount, 1);
      final inspectionsAfterFirst = inspector.inspectCalls;

      await cubit.startUpdate();
      await pumpEventQueue();

      expect(cubit.state, isA<UpdateInstallStarted>());
      expect(repository.downloadCount, 1);
      expect(inspector.inspectCalls, greaterThan(inspectionsAfterFirst));
      expect(installer.installedPaths, hasLength(2));
    });

    test('a package Android keeps rejecting cannot trap the user: escape '
        'hatch after two reopen attempts', () async {
      await requireUpdateAndStart();

      // User cancelled / Android silently rejected the install, twice.
      await cubit.startUpdate();
      await pumpEventQueue();
      expect(cubit.canContinueOffline, isFalse);

      await cubit.startUpdate();
      await pumpEventQueue();
      expect(cubit.state, isA<UpdateInstallStarted>());
      expect(cubit.canContinueOffline, isTrue);

      cubit.continueWithoutUpdate();
      expect(cubit.state, isA<UpdateDeferred>());
    });

    test('a fresh update check resets the attempt counter', () async {
      await requireUpdateAndStart();
      await cubit.startUpdate();
      await pumpEventQueue();
      await cubit.startUpdate();
      await pumpEventQueue();
      expect(cubit.canContinueOffline, isTrue);

      await cubit.checkForUpdate();
      await pumpEventQueue();

      expect(cubit.state, isA<UpdateRequired>());
      expect(cubit.canContinueOffline, isFalse);
    });
  });
}
