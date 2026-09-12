import 'dart:io';

import 'package:dio/dio.dart';
import 'package:mr/core/constants/api_constants.dart';
import 'package:mr/core/network/api_response.dart';
import 'package:mr/core/network/network_exceptions.dart';
import '../models/release_model.dart';

abstract class ReleaseRemoteDataSource {
  Future<ReleaseModel> getLatestRelease();

  /// ينزّل أحدث APK من `GET /app/releases/latest/download` ويحفظه في [savePath].
  ///
  /// بيتبع redirects تلقائيًا وبيتحقق إن الملف الناتج APK سليم (PK magic bytes).
  Future<void> downloadLatestApk(
    String savePath, {
    void Function(int received, int total)? onReceiveProgress,
  });
}

class ReleaseRemoteDataSourceImpl implements ReleaseRemoteDataSource {
  final Dio dio;

  ReleaseRemoteDataSourceImpl(this.dio);

  @override
  Future<ReleaseModel> getLatestRelease() async {
    final response = await dio.get(ApiConstants.latestRelease);

    if (response.data is! Map) {
      throw const ApiException('استجابة الإصدار غير صالحة.');
    }

    final apiResponse = ApiResponse<ReleaseModel>.fromJson(
      Map<String, dynamic>.from(response.data as Map),
      (json) => ReleaseModel.fromJson(json),
    );

    if (!apiResponse.success) {
      throw ApiException(
        apiResponse.message.isNotEmpty
            ? apiResponse.message
            : 'تعذر جلب آخر إصدار.',
      );
    }

    if (apiResponse.data == null) {
      throw const ApiException('لا يوجد إصدار منشور حاليًا.');
    }

    return apiResponse.data!;
  }

  @override
  Future<void> downloadLatestApk(
    String savePath, {
    void Function(int received, int total)? onReceiveProgress,
  }) async {
    final dir = File(savePath).parent;
    await dir.create(recursive: true);

    await dio.download(
      ApiConstants.latestReleaseDownload,
      savePath,
      options: Options(
        // التحميل ملف كبير (APK) فبنسيب هامش أمان أكبر من timeout الافتراضي.
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(minutes: 3),
      ),
      onReceiveProgress: onReceiveProgress,
    );

    final file = File(savePath);
    if (!file.existsSync() || file.lengthSync() == 0) {
      await _deleteSafely(file);
      throw const ApiException('فشل تنزيل ملف التحديث (الملف فارغ).');
    }

    if (!await _isApk(file)) {
      await _deleteSafely(file);
      throw const ApiException('فشل تنزيل ملف التحديث (الملف تالف).');
    }
  }

  /// APK هو ZIP فبيبدأ بـ `PK\x03\x04`.
  Future<bool> _isApk(File file) async {
    try {
      final bytes = await file
          .openRead(0, 4)
          .fold<List<int>>([], (a, b) => a..addAll(b));
      if (bytes.length != 4) return false;
      return bytes[0] == 0x50 &&
          bytes[1] == 0x4B &&
          (bytes[2] == 0x03 || bytes[2] == 0x05 || bytes[2] == 0x07);
    } catch (_) {
      return false;
    }
  }

  Future<void> _deleteSafely(File file) async {
    try {
      if (file.existsSync()) await file.delete();
    } catch (_) {
      // تجاهل: لو منفعش نحذف دلوقتي هيتم التعامل معه في المحاولة الجاية.
    }
  }
}
