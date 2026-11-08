import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Stores the authenticated session securely on the device.
class TokenStorage {
  static const _tokenKey = 'AUTH_TOKEN';
  static const _roleKey = 'AUTH_ROLE';
  static const _userIdKey = 'AUTH_USER_ID';

  final FlutterSecureStorage _storage;

  TokenStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return _storage.read(key: _tokenKey);
  }

  Future<void> saveRole(String? role) async {
    final trimmed = role?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      await _storage.delete(key: _roleKey);
      return;
    }
    await _storage.write(key: _roleKey, value: trimmed);
  }

  Future<String?> getRole() async {
    return _storage.read(key: _roleKey);
  }

  Future<void> saveUserId(String? userId) async {
    final trimmed = userId?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      await _storage.delete(key: _userIdKey);
      return;
    }
    await _storage.write(key: _userIdKey, value: trimmed);
  }

  Future<String?> getUserId() async {
    return _storage.read(key: _userIdKey);
  }

  Future<void> saveSession({
    required String token,
    required String? role,
    required String? userId,
  }) async {
    await saveToken(token);
    await saveRole(role);
    await saveUserId(userId);
  }

  /// Clears every piece of authentication state (token, role and user id).
  Future<void> clearSession() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _roleKey);
    await _storage.delete(key: _userIdKey);
  }

  /// Kept for backwards compatibility; now clears the whole session.
  Future<void> clearToken() => clearSession();

  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
