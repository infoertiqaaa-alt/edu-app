import 'package:dartz/dartz.dart';
import 'package:teacher/core/network/network_exceptions.dart';
import '../../data/models/student_profile_model.dart';

abstract class ProfileRepository {
  Future<Either<Failure, StudentProfileModel>> getProfile();
}