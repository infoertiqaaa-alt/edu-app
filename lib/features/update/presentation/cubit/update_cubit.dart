import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mr/core/constants/api_constants.dart';
import 'package:mr/core/network/network_exceptions.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../data/datasources/apk_installer.dart';
import '../../data/models/release_model.dart';
import '../../domain/logic/update_comparator.dart';
import '../../domain/usecases/download_release_apk.dart';
import '../../domain/usecases/get_latest_release.dart';
import 'update_state.dart';

class UpdateCubit extends Cubit<UpdateState> {
  final GetLatestRelease _getLatestRelease;
  final DownloadReleaseApk _downloadReleaseApk;
  final ApkInstaller _apkInstaller;

  ReleaseModel? _currentRelease;

  UpdateCubit(
    this._getLatestRelease,
    this._downloadReleaseApk,
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

    final updateRequired = UpdateComparator.isUpdateRequired(
      installedVersionCode: installedVersionCode,
      backendVersionCode: release.versionCode,
    );
    _log(
      'installed=$installedVersionCode backend=${release.versionCode} '
      'updateRequired=$updateRequired',
    );

    if (updateRequired) {
      _currentRelease = release;
      emit(UpdateRequired(release));
    } else {
      emit(UpdateNotRequired());
    }
  }

  /// يبدأ التنزيل ثم يفتح المثبّت.
  ///
  /// القاعدة الأساسية: ممنوع نثبّت أي APK لمجرد إن ملف موجود على الجهاز.
  /// الكاش اللي بنستخدمه لازم يكون مرهون بنسخة الـ release المطلوبة نفسها
  /// (اسم الملف فيه version_code) وبالتالي ملف نسخة تانية أو الملف العام
  /// القديم `app-update.apk` مش هيتم اعتباره صالح أبدًا.
  Future<void> startUpdate() async {
    final release = _currentRelease;
    final versionCode = release?.versionCode;
    if (release == null || versionCode == null) return;

    // شيل أي ملفات APK قديمة (العام القديم أو نسخ لنسخ مختلفة) قبل ما نقرر.
    await _cleanupStaleApks(versionCode);

    final apkPath = await _resolveApkPath(release);
    final file = File(apkPath);

    // الملف بالاسم المرتبط بنفس version_code = صالح لإعادة الاستخدام.
    if (file.existsSync() && file.lengthSync() > 0) {
      _log('reusing cached release=$versionCode path=$apkPath');
      await _openInstaller(release, apkPath);
      return;
    }

    // ننزّل نفس النسخة اللي اتقارنت (file_url) مش "أحدث نسخة" عامة؛
    // ولما يكون file_url مش موجود بنوقع على endpoint الإصدار اللي اتقارن.
    final downloadUrl = release.fileUrl.isNotEmpty
        ? release.fileUrl
        : ApiConstants.latestReleaseDownload;

    _log('downloading release=$versionCode from $downloadUrl');
    emit(UpdateDownloading(release));

    final result = await _downloadReleaseApk(
      downloadUrl,
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
        // فشل التنزيل → ممنوع نثبّت أي ملف قديم موجود. نظهر الخطأ وبس.
        _log('download failed release=$versionCode');
        _deleteSafely(file);
        emit(UpdateDownloadFailed(release, failure.message));
      },
      (_) async {
        if (file.existsSync() && file.lengthSync() > 0) {
          _log('download completed release=$versionCode path=$apkPath');
          await _openInstaller(release, apkPath);
        } else {
          _log('downloaded file invalid release=$versionCode');
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
    _log('installing release=${release.versionCode} path=$apkPath');
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

  /// ملف APK مربوط بالنسخة المطلوبة: `updates/app-update-<versionCode>.apk`.
  Future<String> _resolveApkPath(ReleaseModel release) async {
    final supportDir = await getApplicationSupportDirectory();
    final updatesDir = p.join(supportDir.path, 'updates');
    await Directory(updatesDir).create(recursive: true);
    return p.join(updatesDir, _apkFileNameFor(release.versionCode!));
  }

  String _apkFileNameFor(int versionCode) => 'app-update-$versionCode.apk';

  /// بنحذف أي ملفات APK قديمة من مجلد التحديثات إلا الملف المرتبط
  /// بالنسخة المطلوبة:
  /// - `app-update.apk` العام من التنفيذ القديم بيتشال.
  /// - أي `app-update-<N>.apk` لنسخة تانية ما يصحش نثبّتها للنسخة الجديدة.
  Future<void> _cleanupStaleApks(int requestedVersionCode) async {
    try {
      final supportDir = await getApplicationSupportDirectory();
      final updatesDir = Directory(p.join(supportDir.path, 'updates'));
      if (!await updatesDir.exists()) return;

      final expectedName = _apkFileNameFor(requestedVersionCode);

      await for (final entity in updatesDir.list()) {
        if (entity is! File) continue;
        if (!entity.path.toLowerCase().endsWith('.apk')) continue;
        if (p.basename(entity.path) == expectedName) continue;

        _log('deleting stale apk ${entity.path}');
        try {
          if (await entity.exists()) await entity.delete();
        } catch (_) {
          // تجاهل: لو ماحصلش حذف دلوقتي هيتعامل معاه في التنزيل الجاي.
        }
      }
    } catch (_) {
      // تجاهل فشل القراءة/الحذف: التنظيف إجراء احتياطي مش خطوة حرجة.
    }
  }

  void _deleteSafely(File file) {
    try {
      if (file.existsSync()) file.deleteSync();
    } catch (_) {
      // تجاهل: لو ماحصلش حذف دلوقتي هيتعامل معاه في التنزيل الجاي.
    }
  }

  void _log(String message) {
    if (kDebugMode) {
      debugPrint('UpdateFlow: $message');
    }
  }
}