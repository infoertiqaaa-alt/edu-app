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
    final response = await dio.get(
      ApiConstants.scanStudentByQr(qrCodeString),
    );
    final apiResponse = ApiResponse<ScannedStudentModel>.fromJson(
      response.data,
      (json) => ScannedStudentModel.fromJson(json),
    );

    if (!apiResponse.success) {
      throw Exception(
        apiResponse.message.isNotEmpty
            ? apiResponse.message
            : 'Unable to find the scanned student.',
      );
    }

    final student = apiResponse.data;
    if (student == null) {
      throw const FormatException('Scan response does not contain student data.');
    }

    return student;
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
      throw ApiException(
        data['message']?.toString() ?? 'تعذر تسجيل الحضور.',
      );
    }
  }
}
