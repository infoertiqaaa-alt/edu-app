import 'package:dartz/dartz.dart';
import 'package:mr/core/network/network_exceptions.dart';
import '../../domain/repositories/lessons_repository.dart';
import '../datasources/lessons_remote_data_source.dart';
import '../models/lesson_model.dart';
import '../models/lesson_detail_model.dart';

class LessonsRepositoryImpl implements LessonsRepository {
  final LessonsRemoteDataSource remoteDataSource;

  LessonsRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<LessonModel>>> getLessons() async {
    try {
      final lessons = await remoteDataSource.getLessons();
      return Right(lessons);
    } catch (e) {
      return Left(NetworkExceptions.handle(e));
    }
  }

  @override
  Future<Either<Failure, LessonDetailModel>> getLessonDetail(int id) async {
    try {
      final detail = await remoteDataSource.getLessonDetail(id);
      return Right(detail);
    } catch (e) {
      return Left(NetworkExceptions.handle(e));
    }
  }
}
