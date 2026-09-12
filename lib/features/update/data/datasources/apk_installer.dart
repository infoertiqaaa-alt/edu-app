import 'package:mr/core/network/network_exceptions.dart';
import 'package:open_filex/open_filex.dart';

/// بيشغّل Android Package Installer عن طريق فتح ملف الـ APK.
///
/// مش بيقوم بالتثبيت الصامت؛ النظام هو اللي بيظهر شاشة التأكيد للمستخدم.
/// بيستخدم open_filex اللي بيعتمد على FileProvider وتوليد content:// URI.
class ApkInstaller {
  Future<void> install(String apkPath) async {
    final result = await OpenFilex.open(
      apkPath,
      type: 'application/vnd.android.package-archive',
    );

    switch (result.type) {
      case ResultType.done:
        return;
      case ResultType.fileNotFound:
        throw const ApiException('ملف التحديث غير موجود على الجهاز.');
      case ResultType.noAppToOpen:
        throw const ApiException(
          'لم يتم العثور على أداة تثبيت لحزم التطبيقات.',
        );
      case ResultType.permissionDenied:
        throw const ApiException(
          'ليست لديك صلاحية تثبيت التطبيقات من هذا المصدر.',
        );
      case ResultType.error:
        throw ApiException(
          result.message.isNotEmpty
              ? result.message
              : 'تعذر بدء تثبيت التحديث.',
        );
    }
  }
}
