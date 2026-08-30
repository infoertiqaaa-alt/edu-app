import 'package:dio/dio.dart';
import 'package:teacher/core/constants/api_constants.dart';
import 'package:teacher/core/network/api_response.dart';
import '../models/lesson_model.dart';
import '../models/lesson_detail_model.dart';

abstract class LessonsRemoteDataSource {
  Future<List<LessonModel>> getLessons();
  Future<LessonDetailModel> getLessonDetail(int id);
}

class LessonsRemoteDataSourceImpl implements LessonsRemoteDataSource {
  final Dio dio;

  LessonsRemoteDataSourceImpl(this.dio);

  @override
  Future<List<LessonModel>> getLessons() async {
    final response = await dio.get(ApiConstants.lessons);
    final apiResponse = ApiResponse<List<LessonModel>>.fromJson(
      response.data,
      (json) => (json as List).map((e) => LessonModel.fromJson(e)).toList(),
    );
    return apiResponse.data!;
  }

  @override
  Future<LessonDetailModel> getLessonDetail(int id) async {
    final response = await dio.get('${ApiConstants.lessons}/$id');
    final apiResponse = ApiResponse<LessonDetailModel>.fromJson(
      response.data,
      (json) => LessonDetailModel.fromJson(json),
    );
    return apiResponse.data!;
  }
}
