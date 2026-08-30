import 'package:dio/dio.dart';
import 'package:teacher/core/constants/api_constants.dart';
import 'package:teacher/core/network/api_response.dart';
import '../models/student_profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<StudentProfileModel> getProfile();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio dio;

  ProfileRemoteDataSourceImpl(this.dio);

  @override
  Future<StudentProfileModel> getProfile() async {
    final response = await dio.get(ApiConstants.studentProfile);
    final apiResponse = ApiResponse<StudentProfileModel>.fromJson(
      response.data,
      (json) => StudentProfileModel.fromJson(json),
    );
    return apiResponse.data!;
  }
} 