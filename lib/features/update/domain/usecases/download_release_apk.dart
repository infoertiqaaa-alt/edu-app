import 'package:dartz/dartz.dart';
import '../../../../core/network/network_exceptions.dart';
import '../repositories/update_repository.dart';

/// ينزّل APK نسخة محددة (بعنوان [url]) ليس "أحدث نسخة" عامة.
class DownloadReleaseApk {
  final UpdateRepository _repository;

  DownloadReleaseApk(this._repository);

  Future<Either<Failure, void>> call(
    String url,
    String savePath, {
    void Function(int received, int total)? onProgress,
  }) => _repository.downloadReleaseApk(url, savePath, onProgress: onProgress);
}