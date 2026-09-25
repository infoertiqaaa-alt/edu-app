import 'package:dio/dio.dart';
import 'package:mr/core/constants/api_constants.dart';
import 'package:mr/core/network/api_response.dart';
import 'package:mr/core/network/network_exceptions.dart';
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
    final apiResponse = ApiResponse<ReportsModel>.fromJson(
      response.data,
      (json) => ReportsModel.fromJson(json),
    );

    if (!apiResponse.success) {
      throw ApiException(
        apiResponse.message.isNotEmpty
            ? apiResponse.message
            : 'تعذر تحميل التقارير',
      );
    }

    return apiResponse.data!;
  }
}
