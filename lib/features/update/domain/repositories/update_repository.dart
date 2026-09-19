import 'package:dartz/dartz.dart';
import '../../../../core/network/network_exceptions.dart';
import '../../data/models/release_model.dart';

/// مسؤول عن جلب آخر إصدار وتنزيل APK النسخة المطلوبة.
abstract class UpdateRepository {
  Future<Either<Failure, ReleaseModel>> getLatestRelease();

  /// ينزّل النسخة المطلوبة تحديدًا (بعنوان [url]) ويحفظها في [savePath].
  Future<Either<Failure, void>> downloadReleaseApk(
    String url,
    String savePath, {
    void Function(int received, int total)? onProgress,
  });
}
