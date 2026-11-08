import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mr/core/network/network_exceptions.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../data/datasources/apk_inspector.dart';
import '../../data/datasources/apk_installer.dart';
import '../../data/models/release_model.dart';
import '../../data/services/apk_validation_service.dart';
import '../../data/services/release_download_url.dart';
import '../../domain/logic/update_comparator.dart';
import '../../domain/usecases/download_release_apk.dart';
import '../../domain/usecases/get_latest_release.dart';
import 'update_state.dart';

class UpdateCubit extends Cubit<UpdateState> {
  final GetLatestRelease _getLatestRelease;
  final DownloadReleaseApk _downloadReleaseApk;
  final ApkInstaller _apkInstaller;
  final ApkInspector _apkInspector;
  final ApkValidationService _validationService;

  ReleaseModel? _currentRelease;
  InstalledAppInfo? _installedInfo;

  bool _isChecking = false;
  bool _isUpdating = false;

  /// Number of consecutive failed download/validation/install attempts for the
  /// current release. Used only to offer an escape hatch when a mandatory
  /// update is not actually installable (broken artifact, no network). Without
  /// it a corrupt release would lock every user out of the app permanently.
  int _failedAttempts = 0;

  static const int _attemptsBeforeEscapeHatch = 2;

  /// True when updating has failed repeatedly, so the gate may offer
  /// "continue without updating" while still encouraging a retry.
  bool get canContinueOffline => _failedAttempts >= _attemptsBeforeEscapeHatch;

  /// Leaves the update gate without installing. Used only through the bounded
  /// escape hatch above; the update is re-checked on the next app start.
  void continueWithoutUpdate() {
    if (!canContinueOffline) return;
    _failedAttempts = 0;
    _currentRelease = null;
    emit(const UpdateDeferred());
  }

  UpdateCubit(
    this._getLatestRelease,
    this._downloadReleaseApk,
    this._apkInstaller,
    this._apkInspector,
    this._validationService,
  ) : super(UpdateInitial());

  /// Runs on startup and compares installed vs published `version_code`.
  Future<void> checkForUpdate() async {
    if (_isChecking) return;
    _isChecking = true;

    try {
      emit(UpdateChecking());
      _failedAttempts = 0;
      final result = await _getLatestRelease();

      await result.fold(
        (failure) async => emit(UpdateCheckFailed(failure)),
        _handleLatestRelease,
      );
    } catch (error) {
      emit(UpdateCheckFailed(NetworkExceptions.handle(error)));
    } finally {
      _isChecking = false;
    }
  }

  Future<void> _handleLatestRelease(ReleaseModel release) async {
    final metadataError = release.metadataError;
    if (metadataError != null) {
      emit(UpdateCheckFailed(ValidationFailure(metadataError)));
      return;
    }

    final installed = await _readInstalledApp();
    if (installed == null || installed.versionCode <= 0) {
      // Never force a gate that we cannot verify; fail open and let the app run.
      emit(
        const UpdateCheckFailed(
          Failure('تعذر قراءة نسخة التطبيق المثبتة على الجهاز.'),
        ),
      );
      return;
    }

    final updateRequired = UpdateComparator.isUpdateRequired(
      installedVersionCode: installed.versionCode,
      backendVersionCode: release.versionCode,
    );

    _log(
      'installed=${installed.versionCode} backend=${release.versionCode} '
      'updateRequired=$updateRequired mandatory=${release.mandatory}',
    );

    if (!updateRequired) {
      _currentRelease = null;
      emit(UpdateNotRequired());
      return;
    }

    // Reject unusable download metadata before showing a blocking gate.
    if (ReleaseDownloadUrl.resolve(release) == null) {
      _currentRelease = null;
      emit(
        const UpdateCheckFailed(
          ValidationFailure(
            'رابط تنزيل التحديث غير صالح أو غير موثوق. '
            'تواصل مع الدعم إذا استمرت المشكلة.',
          ),
        ),
      );
      return;
    }

    final minSupported = release.minSupportedVersionCode;
    final isMandatory =
        release.mandatory ||
        (minSupported != null && installed.versionCode < minSupported);

    if (!isMandatory) {
      _currentRelease = null;
      emit(UpdateOptionalAvailable(release));
      return;
    }

    _currentRelease = release;
    emit(UpdateRequired(release));
  }

  /// Downloads (or reuses a fully validated cached file), validates it, then
  /// opens the Android package installer.
  Future<void> startUpdate() async {
    if (_isUpdating) return;

    final release = _currentRelease;
    final versionCode = release?.versionCode;
    if (release == null || versionCode == null) return;

    // Reaching here from UpdateInstallStarted means the installer was opened
    // but the app is still running the old version: the user cancelled, or
    // Android rejected the package without telling the app. Count it as an
    // incomplete attempt so a package Android keeps rejecting cannot trap the
    // user on the gate forever (the bounded escape hatch becomes available).
    if (state is UpdateInstallStarted) _failedAttempts++;

    _isUpdating = true;
    var temporaryFile = <String, File>{};

    try {
      await _cleanupStaleApks(versionCode);

      final apkPath = await _resolveApkPath(versionCode);
      final finalFile = File(apkPath);

      // A cached file is reused only after the exact same validation as a
      // fresh download. Its name alone is never considered proof of validity.
      if (await finalFile.exists()) {
        _log('validating cached release=$versionCode path=$apkPath');
        emit(UpdateValidating(release));
        final cachedResult = await _validateFile(finalFile, release);
        if (cachedResult.isValid) {
          await _openInstaller(release, apkPath);
          return;
        }

        _log('cached apk rejected: ${cachedResult.message}');
        await _deleteSafely(finalFile);
      }

      final downloadUri = ReleaseDownloadUrl.resolve(release);
      if (downloadUri == null) {
        _failedAttempts++;
        emit(
          UpdateDownloadFailed(
            release,
            'رابط تنزيل التحديث غير صالح أو غير موثوق.',
          ),
        );
        return;
      }

      final temporaryPath = '$apkPath.part';
      final tempFile = File(temporaryPath);
      temporaryFile[temporaryPath] = tempFile;
      await _deleteSafely(tempFile);

      _log('downloading release=$versionCode from $downloadUri');
      emit(UpdateDownloading(release));

      final downloadResult = await _downloadReleaseApk(
        downloadUri.toString(),
        temporaryPath,
        onProgress: (received, total) {
          if (!isClosed) {
            emit(
              UpdateDownloading(
                release,
                receivedBytes: received,
                totalBytes: total,
              ),
            );
          }
        },
      );

      final downloadFailure = downloadResult.fold<Failure?>(
        (failure) => failure,
        (_) => null,
      );
      if (downloadFailure != null) {
        _log('download failed release=$versionCode');
        await _deleteSafely(tempFile);
        _failedAttempts++;
        emit(UpdateDownloadFailed(release, downloadFailure.message));
        return;
      }

      emit(UpdateValidating(release));
      final validation = await _validateFile(tempFile, release);
      if (!validation.isValid) {
        _log('downloaded apk rejected: ${validation.message}');
        await _deleteSafely(tempFile);
        _failedAttempts++;
        emit(UpdateValidationFailed(release, validation.message));
        return;
      }

      // Only now does the file become the official update artifact.
      await _deleteSafely(finalFile);
      try {
        await tempFile.rename(apkPath);
      } on FileSystemException {
        await _deleteSafely(tempFile);
        _failedAttempts++;
        emit(
          UpdateDownloadFailed(
            release,
            'تعذر حفظ ملف التحديث على الجهاز. تأكد من توفر مساحة كافية.',
          ),
        );
        return;
      }

      _log('download validated release=$versionCode path=$apkPath');
      await _openInstaller(release, apkPath);
    } catch (error) {
      final failure = NetworkExceptions.handle(error);
      final current = _currentRelease;
      if (current != null) {
        _failedAttempts++;
        emit(UpdateDownloadFailed(current, failure.message));
      }
    } finally {
      for (final file in temporaryFile.values) {
        await _deleteSafely(file);
      }
      _isUpdating = false;
    }
  }

  Future<void> openInstallPermissionSettings() =>
      _apkInspector.openInstallPermissionSettings();

  Future<ApkValidationResult> _validateFile(
    File file,
    ReleaseModel release,
  ) async {
    final installed = await _readInstalledApp(refresh: true);
    if (installed == null || installed.versionCode <= 0) {
      return ApkValidationResult.invalid(
        'تعذر قراءة بيانات التطبيق المثبّت للتحقق من التحديث.',
      );
    }

    return _validationService.validate(
      file: file,
      release: release,
      installed: installed,
    );
  }

  Future<void> _openInstaller(ReleaseModel release, String apkPath) async {
    final permissionGranted = await _apkInspector.canRequestPackageInstalls();
    if (!permissionGranted) {
      emit(UpdateInstallPermissionRequired(release));
      return;
    }

    _log('installing release=${release.versionCode} path=$apkPath');
    // _failedAttempts is intentionally NOT reset here: opening the installer
    // is not proof that the installation will succeed.
    emit(UpdateInstallStarted(release, apkPath));

    try {
      await _apkInstaller.install(apkPath);
    } catch (error) {
      if (!isClosed) {
        _failedAttempts++;
        emit(
          UpdateInstallFailed(release, NetworkExceptions.handle(error).message),
        );
      }
    }
    // Remaining on UpdateInstallStarted is intentional: the installer has been
    // opened but Android has not confirmed that installation completed.
  }

  Future<InstalledAppInfo?> _readInstalledApp({bool refresh = false}) async {
    if (!refresh && _installedInfo != null) return _installedInfo;

    try {
      final info = await _apkInspector.getInstalledApp();
      if (info != null && info.packageName.isNotEmpty) {
        _installedInfo = info;
        return info;
      }
    } catch (_) {
      // Fall through to package_info_plus for the version code comparison.
    }

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final buildNumber = int.tryParse(packageInfo.buildNumber);
      if (buildNumber == null || buildNumber <= 0) return null;

      final info = InstalledAppInfo(
        packageName: packageInfo.packageName,
        versionCode: buildNumber,
        versionName: packageInfo.version,
        signatureHashes: const [],
        deviceSdk: 0,
      );
      _installedInfo = info;
      return info;
    } catch (_) {
      return null;
    }
  }

  Future<String> _resolveApkPath(int versionCode) async {
    final supportDir = await getApplicationSupportDirectory();
    final updatesDir = p.join(supportDir.path, 'updates');
    await Directory(updatesDir).create(recursive: true);
    return p.join(updatesDir, _apkFileNameFor(versionCode));
  }

  String _apkFileNameFor(int versionCode) => 'app-update-$versionCode.apk';

  /// Removes old generic/versioned APKs and partial downloads. Only the file
  /// for the requested version code survives.
  Future<void> _cleanupStaleApks(int requestedVersionCode) async {
    try {
      final supportDir = await getApplicationSupportDirectory();
      final updatesDir = Directory(p.join(supportDir.path, 'updates'));
      if (!await updatesDir.exists()) return;

      final expectedNames = {
        _apkFileNameFor(requestedVersionCode),
        '${_apkFileNameFor(requestedVersionCode)}.part',
      };

      await for (final entity in updatesDir.list()) {
        if (entity is! File) continue;
        final lower = entity.path.toLowerCase();
        if (!lower.endsWith('.apk') && !lower.endsWith('.part')) continue;
        if (expectedNames.contains(p.basename(entity.path))) continue;

        _log('deleting stale update file ${entity.path}');
        await _deleteSafely(entity);
      }
    } catch (_) {
      // Cleanup is best effort; it must never block a valid update.
    }
  }

  Future<void> _deleteSafely(File file) async {
    try {
      if (await file.exists()) await file.delete();
    } catch (_) {
      // Best effort; the next attempt overwrites the file.
    }
  }

  void _log(String message) {
    if (kDebugMode) {
      debugPrint('UpdateFlow: $message');
    }
  }
}
