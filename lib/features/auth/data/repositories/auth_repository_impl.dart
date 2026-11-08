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
    if (token == null || token.trim().isEmpty) {
      // A role without a token is an inconsistent session.
      if (await tokenStorage.getRole() != null ||
          await tokenStorage.getUserId() != null) {
        await tokenStorage.clearSession();
      }
      return null;
    }

    final role = (await tokenStorage.getRole())?.trim();
    if (role == null || role.isEmpty) {
      // Token exists but the session is incomplete/corrupt.
      await tokenStorage.clearSession();
      return null;
    }

    return role;
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
          AuthenticationFailure(
            response.message.isNotEmpty
                ? response.message
                : 'تعذر تسجيل الدخول، حاول مرة أخرى.',
          ),
        );
      }

      if (response.token.trim().isEmpty) {
        return const Left(
          ParsingFailure('استجابة تسجيل الدخول لا تحتوي على token.'),
        );
      }

      final userId = response.user.id.trim();
      await tokenStorage.saveSession(
        token: response.token,
        role: response.user.role,
        userId: userId.isEmpty ? null : userId,
      );
      return Right(response.user);
    } catch (error) {
      return Left(NetworkExceptions.handle(error, isLoginRequest: true));
    }
  }
}
