import 'package:dio/dio.dart';
import 'package:mr/core/constants/api_constants.dart';
import 'package:mr/core/network/api_response.dart';
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
    return ApiResponse.requireData(
      response.data,
      (json) => (json as List).map((e) => LessonModel.fromJson(e)).toList(),
      failureMessage: 'تعذر تحميل الدروس',
    );
  }

  @override
  Future<LessonDetailModel> getLessonDetail(int id) async {
    final response = await dio.get('${ApiConstants.lessons}/$id');
    return ApiResponse.requireData(
      response.data,
      (json) => LessonDetailModel.fromJson(json),
      failureMessage: 'تعذر تحميل تفاصيل الدرس',
    );
  }
}
