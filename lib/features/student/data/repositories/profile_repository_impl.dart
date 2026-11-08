import 'package:dartz/dartz.dart';
import 'package:mr/core/network/network_exceptions.dart';
import 'package:mr/core/storage/token_storage.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';
import '../models/student_profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final TokenStorage tokenStorage;

  static const _cacheTtl = Duration(minutes: 5);

  StudentProfileModel? _cachedProfile;
  String? _cachedUserId;
  DateTime? _cachedAt;

  ProfileRepositoryImpl(this.remoteDataSource, {required this.tokenStorage});

  @override
  StudentProfileModel? get cachedProfile => _cachedProfile;

  @override
  void clearCache() {
    _cachedProfile = null;
    _cachedUserId = null;
    _cachedAt = null;
  }

  @override
  Future<Either<Failure, StudentProfileModel>> getProfile({
    bool forceRefresh = false,
  }) async {
    final userId = await tokenStorage.getUserId();

    // A different authenticated account must never see the previous cache.
    if (_cachedUserId != null && _cachedUserId != userId) {
      clearCache();
    }

    if (!forceRefresh && _isCacheFresh(userId)) {
      return Right(_cachedProfile!);
    }

    try {
      final profile = await remoteDataSource.getProfile();
      _cachedProfile = profile;
      _cachedUserId = userId;
      _cachedAt = DateTime.now();
      return Right(profile);
    } catch (error) {
      final failure = NetworkExceptions.handle(error);

      // Never serve stale account data when the session is expired.
      if (failure is UnauthorizedFailure) {
        clearCache();
        return Left(failure);
      }

      // Keep usable cached data on transient failures.
      if (_cachedProfile != null && _cachedUserId == userId) {
        return Right(_cachedProfile!);
      }

      return Left(failure);
    }
  }

  bool _isCacheFresh(String? userId) {
    if (_cachedProfile == null || _cachedAt == null) return false;
    if (_cachedUserId != userId) return false;
    return DateTime.now().difference(_cachedAt!) < _cacheTtl;
  }
}
