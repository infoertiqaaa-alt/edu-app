import 'package:dartz/dartz.dart';
import 'package:mr/core/network/network_exceptions.dart';
import '../../domain/repositories/reports_repository.dart';
import '../datasources/reports_remote_data_source.dart';
import '../models/reports_model.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  final ReportsRemoteDataSource remoteDataSource;

  ReportsRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, ReportsModel>> getReports() async {
    try {
      final reports = await remoteDataSource.getReports();
      return Right(reports);
    } catch (e) {
      return Left(NetworkExceptions.handle(e));
    }
  }
}
