import 'package:dio/dio.dart';
import 'package:mr/core/constants/api_constants.dart';
import 'package:mr/core/network/api_response.dart';
import '../models/reports_model.dart';

abstract class ReportsRemoteDataSource {
  Future<ReportsModel> getReports();
}

class ReportsRemoteDataSourceImpl implements ReportsRemoteDataSource {
  final Dio dio;

  ReportsRemoteDataSourceImpl(this.dio);

  @override
  Future<ReportsModel> getReports() async {
    final response = await dio.get(ApiConstants.studentReports);
    return ApiResponse.requireData(
      response.data,
      (json) => ReportsModel.fromJson(json),
      failureMessage: 'تعذر تحميل التقارير',
    );
  }
}
