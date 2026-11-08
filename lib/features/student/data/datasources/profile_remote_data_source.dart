import 'package:dio/dio.dart';
import 'package:mr/core/constants/api_constants.dart';
import 'package:mr/core/network/api_response.dart';
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
    return ApiResponse.requireData(
      response.data,
      (json) => StudentProfileModel.fromJson(json),
      failureMessage: 'تعذر تحميل الملف الشخصي',
    );
  }
}
