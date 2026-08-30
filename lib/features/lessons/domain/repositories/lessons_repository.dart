import 'package:dartz/dartz.dart';
import 'package:teacher/core/network/network_exceptions.dart';
import '../../data/models/lesson_model.dart';
import '../../data/models/lesson_detail_model.dart';

abstract class LessonsRepository {
  Future<Either<Failure, List<LessonModel>>> getLessons();
  Future<Either<Failure, LessonDetailModel>> getLessonDetail(int id);
}
