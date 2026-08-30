import '../repositories/auth_repository.dart';

class CheckAuthStatus {
  final AuthRepository _authRepository;

  CheckAuthStatus(this._authRepository);

  Future<String?> call() => _authRepository.getSavedUserRole();
}
