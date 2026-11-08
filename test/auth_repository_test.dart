import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mr/core/network/network_exceptions.dart';
import 'package:mr/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:mr/features/auth/data/models/login_request_model.dart';
import 'package:mr/features/auth/data/models/login_response_model.dart';
import 'package:mr/features/auth/data/repositories/auth_repository_impl.dart';

import 'helpers/in_memory_token_storage.dart';

class FakeAuthRemoteDataSource implements AuthRemoteDataSource {
  LoginResponseModel? response;
  Object? error;
  int calls = 0;

  @override
  Future<LoginResponseModel> login(LoginRequestModel request) async {
    calls++;
    if (error != null) throw error!;
    return response!;
  }
}

LoginResponseModel successResponse({
  String token = 'token-123',
  String id = '42',
  String? role = 'student',
}) {
  return LoginResponseModel.fromJson({
    'success': true,
    'message': 'ok',
    'data': {
      'token': token,
      'user': {
        'id': id,
        'name': 'Test Student',
        'username': 'student',
        'role': role,
        'email': 'student@example.com',
      },
    },
  });
}

DioException unauthorizedLogin() {
  final options = RequestOptions(path: '/auth/login');
  return DioException(
    requestOptions: options,
    response: Response(
      requestOptions: options,
      statusCode: 401,
      data: {'message': 'بيانات الدخول غير صحيحة'},
    ),
    type: DioExceptionType.badResponse,
  );
}

void main() {
  late FakeAuthRemoteDataSource remote;
  late InMemoryTokenStorage storage;
  late AuthRepositoryImpl repository;

  setUp(() {
    remote = FakeAuthRemoteDataSource();
    storage = InMemoryTokenStorage();
    repository = AuthRepositoryImpl(
      remoteDataSource: remote,
      tokenStorage: storage,
    );
  });

  group('login', () {
    test('persists the complete session on success', () async {
      remote.response = successResponse();

      final result = await repository.login(
        username: 'student',
        password: 'secret',
      );

      expect(result.isRight(), isTrue);
      expect(storage.token, 'token-123');
      expect(storage.role, 'student');
      expect(storage.userId, '42');
    });

    test('rejects a response without a token and saves nothing', () async {
      remote.response = successResponse(token: '');

      final result = await repository.login(
        username: 'student',
        password: 'secret',
      );

      result.fold(
        (failure) => expect(failure, isA<ParsingFailure>()),
        (_) => fail('expected failure'),
      );
      expect(storage.token, isNull);
      expect(storage.role, isNull);
      expect(storage.userId, isNull);
    });

    test('returns the server message when success is false', () async {
      remote.response = LoginResponseModel.fromJson({
        'success': false,
        'message': 'الحساب موقوف',
        'data': {
          'token': '',
          'user': {'id': 1, 'name': '', 'username': '', 'role': 'student'},
        },
      });

      final result = await repository.login(
        username: 'student',
        password: 'secret',
      );

      result.fold(
        (failure) => expect(failure.message, 'الحساب موقوف'),
        (_) => fail('expected failure'),
      );
    });

    test(
      '401 on login is InvalidCredentialsFailure, not session expiry',
      () async {
        remote.error = unauthorizedLogin();

        final result = await repository.login(
          username: 'student',
          password: 'secret',
        );

        result.fold(
          (failure) => expect(failure, isA<InvalidCredentialsFailure>()),
          (_) => fail('expected failure'),
        );
      },
    );

    test('a failed login never clears an existing session', () async {
      storage.token = 'existing';
      storage.role = 'student';
      storage.userId = '1';
      remote.error = unauthorizedLogin();

      await repository.login(username: 'student', password: 'wrong');

      expect(storage.token, 'existing');
      expect(storage.role, 'student');
      expect(storage.userId, '1');
    });
  });

  group('getSavedUserRole', () {
    test('returns the stored role for a complete session', () async {
      storage.token = 'token';
      storage.role = 'student';
      storage.userId = '1';

      expect(await repository.getSavedUserRole(), 'student');
    });

    test('clears a token-only session', () async {
      storage.token = 'token';
      storage.role = null;

      expect(await repository.getSavedUserRole(), isNull);
      expect(storage.token, isNull);
      expect(storage.role, isNull);
      expect(storage.userId, isNull);
    });

    test('clears a role-only session (no token)', () async {
      storage.token = null;
      storage.role = 'student';

      expect(await repository.getSavedUserRole(), isNull);
      expect(storage.role, isNull);
    });
  });

  group('NetworkExceptions', () {
    test('maps non-login 401 to UnauthorizedFailure', () {
      final options = RequestOptions(path: '/student/profile');
      final failure = NetworkExceptions.handle(
        DioException(
          requestOptions: options,
          response: Response(
            requestOptions: options,
            statusCode: 401,
            data: {'message': 'expired'},
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      expect(failure, isA<UnauthorizedFailure>());
      expect(failure.message, 'expired');
    });

    test('maps 422 to ValidationFailure and 500 to ServerFailure', () {
      Failure mapStatus(int code) => NetworkExceptions.handle(
        DioException(
          requestOptions: RequestOptions(path: '/x'),
          response: Response(
            requestOptions: RequestOptions(path: '/x'),
            statusCode: code,
            data: {'message': 'server message'},
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      expect(mapStatus(422), isA<ValidationFailure>());
      expect(mapStatus(500), isA<ServerFailure>());
    });

    test('maps malformed payloads to ParsingFailure', () {
      expect(
        NetworkExceptions.handle(const FormatException('bad json')),
        isA<ParsingFailure>(),
      );
    });
  });
}
