import 'package:dio/dio.dart';
import 'package:mr/core/constants/api_constants.dart';
import 'package:mr/core/network/api_response.dart';
import 'package:mr/core/network/network_exceptions.dart';
import '../models/scanned_student_model.dart';

abstract class ScanQrRemoteDataSource {
  Future<ScannedStudentModel> scanStudent(String qrCodeString);
  Future<void> registerAttendance(int studentId);
}

class ScanQrRemoteDataSourceImpl implements ScanQrRemoteDataSource {
  final Dio dio;

  ScanQrRemoteDataSourceImpl(this.dio);

  @override
  Future<ScannedStudentModel> scanStudent(String qrCodeString) async {
    final response = await dio.get(ApiConstants.scanStudentByQr(qrCodeString));
    // Previously a generic Exception surfaced to the user as
    // "Exception: Unable to find..." (English, with the class-name prefix).
    return ApiResponse.requireData(
      response.data,
      (json) => ScannedStudentModel.fromJson(json),
      failureMessage: 'تعذر العثور على الطالب صاحب هذا الكود.',
    );
  }

  @override
  Future<void> registerAttendance(int studentId) async {
    final response = await dio.post(
      ApiConstants.registerAttendance,
      data: {'student_id': studentId},
    );

    if (response.data is! Map) {
      throw const ApiException('استجابة تسجيل الحضور غير صالحة.');
    }

    final data = Map<String, dynamic>.from(response.data as Map);
    if (data['success'] != true) {
      throw ApiException(data['message']?.toString() ?? 'تعذر تسجيل الحضور.');
    }
  }
}
