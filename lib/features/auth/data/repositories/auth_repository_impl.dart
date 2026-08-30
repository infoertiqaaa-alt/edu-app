import 'package:dartz/dartz.dart';
import '../../../../core/network/network_exceptions.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/login_request_model.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final TokenStorage tokenStorage;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.tokenStorage,
  });

  @override
  Future<String?> getSavedUserRole() async {
    final token = await tokenStorage.getToken();
    if (token == null || token.trim().isEmpty) return null;
    return tokenStorage.getRole();
  }

  @override
  Future<Either<Failure, UserModel>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await remoteDataSource.login(
        LoginRequestModel(username: username, password: password),
      );

      if (!response.success) {
        return Left(
          Failure(
            response.message.isNotEmpty
                ? response.message
                : 'Login failed. Please try again.',
          ),
        );
      }

      if (response.token.isEmpty) {
        return const Left(Failure('Login response does not contain a token.'));
      }

      await tokenStorage.saveToken(response.token);
      await tokenStorage.saveRole(response.user.role);
      return Right(response.user);
    } catch (e) {
      return Left(NetworkExceptions.handle(e));
    }
  }
}
