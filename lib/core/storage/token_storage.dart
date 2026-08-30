import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// مسؤول عن حفظ / قراءة / حذف التوكن محليًا على الجهاز
class TokenStorage {
  static const _tokenKey = 'AUTH_TOKEN';
  static const _roleKey = 'AUTH_ROLE';
  final FlutterSecureStorage _storage;

  TokenStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return _storage.read(key: _tokenKey);
  }

  Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _roleKey);
  }

  Future<void> saveRole(String? role) async {
    if (role == null || role.trim().isEmpty) {
      await _storage.delete(key: _roleKey);
      return;
    }
    await _storage.write(key: _roleKey, value: role.trim());
  }

  Future<String?> getRole() async {
    return _storage.read(key: _roleKey);
  }

  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
