import 'package:dartz/dartz.dart';
import 'package:mr/core/network/network_exceptions.dart';
import '../../domain/repositories/update_repository.dart';
import '../datasources/release_remote_data_source.dart';
import '../models/release_model.dart';

class UpdateRepositoryImpl implements UpdateRepository {
  final ReleaseRemoteDataSource remoteDataSource;

  UpdateRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, ReleaseModel>> getLatestRelease() async {
    try {
      final release = await remoteDataSource.getLatestRelease();
      return Right(release);
    } catch (e) {
      return Left(NetworkExceptions.handle(e));
    }
  }

  @override
  Future<Either<Failure, void>> downloadLatestApk(
    String savePath, {
    void Function(int received, int total)? onProgress,
  }) async {
    try {
      await remoteDataSource.downloadLatestApk(
        savePath,
        onReceiveProgress: onProgress,
      );
      return const Right(null);
    } catch (e) {
      return Left(NetworkExceptions.handle(e));
    }
  }
}
