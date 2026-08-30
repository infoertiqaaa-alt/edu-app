import 'package:dartz/dartz.dart';
import '../../../../core/network/network_exceptions.dart';
import '../../data/models/user_model.dart';

abstract class AuthRepository {
  Future<String?> getSavedUserRole();

  Future<Either<Failure, UserModel>> login({
    required String username,
    required String password,
  });
}
