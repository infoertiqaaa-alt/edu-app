import 'package:dartz/dartz.dart';
import '../../../../core/network/network_exceptions.dart';
import '../../data/models/release_model.dart';

/// مسؤول عن جلب آخر إصدار وتنزيل الـ APK.
abstract class UpdateRepository {
  Future<Either<Failure, ReleaseModel>> getLatestRelease();

  Future<Either<Failure, void>> downloadLatestApk(
    String savePath, {
    void Function(int received, int total)? onProgress,
  });
}
