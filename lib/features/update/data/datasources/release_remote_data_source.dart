import 'dart:io';

import 'package:dio/dio.dart';
import 'package:mr/core/config/app_config.dart';
import 'package:mr/core/constants/api_constants.dart';
import 'package:mr/core/network/api_response.dart';
import 'package:mr/core/network/network_exceptions.dart';
import '../models/release_model.dart';

abstract class ReleaseRemoteDataSource {
  Future<ReleaseModel> getLatestRelease();

  /// Downloads the APK identified by [url] into [savePath].
  ///
  /// The caller is responsible for passing a temporary path and moving the file
  /// to its final location only after full validation. On any failure the
  /// partial file is deleted.
  Future<void> downloadReleaseApk(
    String url,
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
  Future<void> downloadReleaseApk(
    String url,
    String savePath, {
    void Function(int received, int total)? onReceiveProgress,
  }) async {
    final uri = Uri.tryParse(url);
    if (uri == null ||
        uri.scheme != 'https' ||
        !AppConfig.isAllowedDownloadHost(uri.host)) {
      throw const ApiException('رابط تنزيل التحديث غير صالح.');
    }

    final file = File(savePath);
    await file.parent.create(recursive: true);
    await _deleteSafely(file);

    try {
      final response = await dio.download(
        url,
        savePath,
        options: Options(
          // APKs are large; keep a dedicated, explicit timeout.
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(minutes: 5),
          headers: const {'Accept': 'application/vnd.android.package-archive'},
          // Release files are public artifacts; never send the session token
          // to a storage/CDN host.
          extra: const {'skipAuth': true},
          validateStatus: (status) =>
              status != null && status >= 200 && status < 300,
        ),
        onReceiveProgress: onReceiveProgress,
      );

      // Redirects must not silently move the download to an untrusted host.
      final finalUri = response.realUri;
      if (finalUri.scheme != 'https' ||
          !AppConfig.isAllowedDownloadHost(finalUri.host)) {
        throw const ApiException('تم تحويل تنزيل التحديث إلى مصدر غير موثوق.');
      }

      final contentType = response.headers
          .value(Headers.contentTypeHeader)
          ?.toLowerCase();
      if (contentType != null &&
          (contentType.contains('text/html') ||
              contentType.contains('application/json'))) {
        throw const ApiException(
          'الخادم أعاد صفحة أو بيانات بدلًا من ملف التحديث.',
        );
      }

      if (!await file.exists() || await file.length() == 0) {
        throw const ApiException('فشل تنزيل ملف التحديث (الملف فارغ).');
      }

      if (!await _isApk(file)) {
        throw const ApiException('فشل تنزيل ملف التحديث (الملف تالف).');
      }
    } catch (_) {
      await _deleteSafely(file);
      rethrow;
    }
  }

  /// APK is a ZIP archive, so it starts with `PK\x03\x04` (or an empty archive).
  Future<bool> _isApk(File file) async {
    try {
      final bytes = await file
          .openRead(0, 4)
          .fold<List<int>>(
            [],
            (accumulator, chunk) => accumulator..addAll(chunk),
          );
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
      if (await file.exists()) await file.delete();
    } catch (_) {
      // Best effort; the next attempt overwrites the temporary file.
    }
  }
}
