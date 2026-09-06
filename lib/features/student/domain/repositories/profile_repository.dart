import 'package:dartz/dartz.dart';
import 'package:mr/core/network/network_exceptions.dart';
import '../../data/models/student_profile_model.dart';

abstract class ProfileRepository {
  Future<Either<Failure, StudentProfileModel>> getProfile();
}