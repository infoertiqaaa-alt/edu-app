import 'package:dartz/dartz.dart';
import '../../../../core/network/network_exceptions.dart';
import '../repositories/update_repository.dart';

class DownloadLatestApk {
  final UpdateRepository _repository;

  DownloadLatestApk(this._repository);

  Future<Either<Failure, void>> call(
    String savePath, {
    void Function(int received, int total)? onProgress,
  }) => _repository.downloadLatestApk(savePath, onProgress: onProgress);
}
