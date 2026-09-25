import 'package:dartz/dartz.dart';
import 'package:mr/core/network/network_exceptions.dart';
import '../../data/models/reports_model.dart';

abstract class ReportsRepository {
  Future<Either<Failure, ReportsModel>> getReports();
}
