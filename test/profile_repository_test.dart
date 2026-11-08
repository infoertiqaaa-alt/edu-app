import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mr/core/network/network_exceptions.dart';
import 'package:mr/features/student/data/datasources/profile_remote_data_source.dart';
import 'package:mr/features/student/data/models/student_profile_model.dart';
import 'package:mr/features/student/data/repositories/profile_repository_impl.dart';

import 'helpers/in_memory_token_storage.dart';

class FakeProfileRemoteDataSource implements ProfileRemoteDataSource {
  int calls = 0;
  Object? error;
  String name = 'Student One';

  @override
  Future<StudentProfileModel> getProfile() async {
    calls++;
    if (error != null) throw error!;
    return StudentProfileModel.fromJson({
      'id': 1,
      'name': name,
      'username': 'student',
      'phone': '01000000000',
      'email': 'student@example.com',
      'qr_code_string': 'qr-1',
      'student_code': 'S-1',
      'grade': 'Grade 3',
      'profile_image': null,
      'dob': '2010-01-01',
      'guardian_name': 'Guardian',
      'guardian_phone': '01111111111',
    });
  }
}

DioException unauthorized() {
  final options = RequestOptions(path: '/student/profile');
  return DioException(
    requestOptions: options,
    response: Response(requestOptions: options, statusCode: 401),
    type: DioExceptionType.badResponse,
  );
}

DioException connectionError() => DioException(
  requestOptions: RequestOptions(path: '/student/profile'),
  type: DioExceptionType.connectionError,
);

void main() {
  late FakeProfileRemoteDataSource remote;
  late InMemoryTokenStorage storage;
  late ProfileRepositoryImpl repository;

  setUp(() {
    remote = FakeProfileRemoteDataSource();
    storage = InMemoryTokenStorage()
      ..token = 'token'
      ..role = 'student'
      ..userId = '1';
    repository = ProfileRepositoryImpl(remote, tokenStorage: storage);
  });

  test('caches the profile for subsequent calls', () async {
    final first = await repository.getProfile();
    final second = await repository.getProfile();

    expect(first.isRight(), isTrue);
    expect(second.isRight(), isTrue);
    expect(remote.calls, 1);
    expect(repository.cachedProfile?.name, 'Student One');
  });

  test('forceRefresh bypasses the cache', () async {
    await repository.getProfile();
    remote.name = 'Student Updated';

    final refreshed = await repository.getProfile(forceRefresh: true);

    expect(remote.calls, 2);
    refreshed.fold(
      (_) => fail('expected success'),
      (profile) => expect(profile.name, 'Student Updated'),
    );
  });

  test('switching users invalidates the previous user cache', () async {
    await repository.getProfile();

    storage.userId = '2';
    remote.name = 'Student Two';
    final result = await repository.getProfile();

    expect(remote.calls, 2);
    result.fold(
      (_) => fail('expected success'),
      (profile) => expect(profile.name, 'Student Two'),
    );
  });

  test('401 clears the cache and is returned as an error', () async {
    await repository.getProfile();
    remote.error = unauthorized();

    final result = await repository.getProfile(forceRefresh: true);

    expect(repository.cachedProfile, isNull);
    result.fold(
      (failure) => expect(failure, isA<UnauthorizedFailure>()),
      (_) => fail('expected failure'),
    );
  });

  test('transient failure serves cached data instead of an error', () async {
    await repository.getProfile();
    remote.error = connectionError();

    final result = await repository.getProfile(forceRefresh: true);

    result.fold(
      (_) => fail('expected cached success'),
      (profile) => expect(profile.name, 'Student One'),
    );
  });

  test('transient failure without cache is returned as an error', () async {
    remote.error = connectionError();

    final result = await repository.getProfile();

    result.fold(
      (failure) => expect(failure, isA<NetworkFailure>()),
      (_) => fail('expected failure'),
    );
  });

  test('clearCache removes the cached profile', () async {
    await repository.getProfile();
    repository.clearCache();

    expect(repository.cachedProfile, isNull);
  });
}
