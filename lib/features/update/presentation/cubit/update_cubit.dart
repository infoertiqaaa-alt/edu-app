import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mr/core/network/network_exceptions.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../data/datasources/apk_installer.dart';
import '../../data/models/release_model.dart';
import '../../domain/logic/update_comparator.dart';
import '../../domain/usecases/download_latest_apk.dart';
import '../../domain/usecases/get_latest_release.dart';
import 'update_state.dart';

class UpdateCubit extends Cubit<UpdateState> {
  final GetLatestRelease _getLatestRelease;
  final DownloadLatestApk _downloadLatestApk;
  final ApkInstaller _apkInstaller;

  ReleaseModel? _currentRelease;

  UpdateCubit(
    this._getLatestRelease,
    this._downloadLatestApk,
    this._apkInstaller,
  ) : super(UpdateInitial());

  /// فحص التحديث عند الإقلاع: يقرأ النسخة المثبتة فعليًا من الجهاز
  /// ويقارنها بـ `data.version_code` من الخادم.
  Future<void> checkForUpdate() async {
    emit(UpdateChecking());

    final result = await _getLatestRelease();

    result.fold(
      (failure) => emit(UpdateCheckFailed(failure)),
      _handleLatestRelease,
    );
  }

  Future<void> _handleLatestRelease(ReleaseModel release) async {
    // لو الـ version_code ناقص أو مش صالح نتعامل بأمان: نكمل طبيعي.
    if (release.versionCode == null) {
      emit(
        UpdateCheckFailed(
          const Failure('استجابة الخادم لا تحتوي version_code صالح.'),
        ),
      );
      return;
    }

    final installedVersionCode = await _readInstalledVersionCode();

    // قراءة النسخة المثبتة فشلت → مش هنجبر على تحديث ولا نمنع التطبيق.
    if (installedVersionCode == null) {
      emit(UpdateNotRequired());
      return;
    }

    if (UpdateComparator.isUpdateRequired(
      installedVersionCode: installedVersionCode,
      backendVersionCode: release.versionCode,
    )) {
      _currentRelease = release;
      emit(UpdateRequired(release));
    } else {
      emit(UpdateNotRequired());
    }
  }

  /// يبدأ التنزيل ثم يفتح المثبّت.
  ///
  /// لو الملف نزل من قبل وموجود سليم (مثلًا بعد فشل فتح المثبّت) هيفتحه
  /// مباشرة بدل ما يعيد تنزيل 90+ ميجا.
  Future<void> startUpdate() async {
    final release = _currentRelease;
    if (release == null) return;

    final apkPath = await _resolveApkPath();
    final file = File(apkPath);

    if (file.existsSync() && file.lengthSync() > 0) {
      await _openInstaller(release, apkPath);
      return;
    }

    emit(UpdateDownloading(release));

    final result = await _downloadLatestApk(
      apkPath,
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

    result.fold(
      (failure) {
        _deleteSafely(file);
        emit(UpdateDownloadFailed(release, failure.message));
      },
      (_) async {
        if (file.existsSync() && file.lengthSync() > 0) {
          await _openInstaller(release, apkPath);
        } else {
          _deleteSafely(file);
          emit(
            UpdateDownloadFailed(
              release,
              'فشل تنزيل ملف التحديث، حاول مرة أخرى.',
            ),
          );
        }
      },
    );
  }

  Future<void> _openInstaller(ReleaseModel release, String apkPath) async {
    emit(UpdateInstallStarted(release, apkPath));
    try {
      await _apkInstaller.install(apkPath);
    } catch (e) {
      // ممكن يكون المستخدم اختار الاستمرار بعد فتح المثبّت فنكمّل من غير
      // حاجز؛ وبعدين الإقلاع الجاي هيرجع يفحص تاني.
      if (!isClosed) {
        emit(UpdateInstallFailed(release, NetworkExceptions.handle(e).message));
      }
    }
    // لو المثبّت اتبدأ بنجاح بنفضل على UpdateInstallStarted:
    // التحديث مش مكتمل إلا بعد تثبيت النسخة الجديدة فعليًا.
  }

  /// قراءة النسخة المثبتة من PackageInfo (buildNumber = versionCode الحقيقي للجهاز).
  Future<int?> _readInstalledVersionCode() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return int.tryParse(packageInfo.buildNumber);
    } catch (_) {
      return null;
    }
  }

  Future<String> _resolveApkPath() async {
    final supportDir = await getApplicationSupportDirectory();
    final updatesDir = p.join(supportDir.path, 'updates');
    await Directory(updatesDir).create(recursive: true);
    return p.join(updatesDir, 'app-update.apk');
  }

  void _deleteSafely(File file) {
    try {
      if (file.existsSync()) file.deleteSync();
    } catch (_) {
      // تجاهل: لو ماحصلش حذف دلوقتي هيتعامل معاه في التنزيل الجاي.
    }
  }
}
