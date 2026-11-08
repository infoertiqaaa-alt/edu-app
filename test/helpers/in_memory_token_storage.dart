import 'package:mr/core/storage/token_storage.dart';

/// Minimal in-memory replacement for secure storage.
class InMemoryTokenStorage extends TokenStorage {
  String? token;
  String? role;
  String? userId;

  @override
  Future<void> saveToken(String value) async => token = value;

  @override
  Future<String?> getToken() async => token;

  @override
  Future<void> saveRole(String? value) async => role = value;

  @override
  Future<String?> getRole() async => role;

  @override
  Future<void> saveUserId(String? value) async => userId = value;

  @override
  Future<String?> getUserId() async => userId;

  @override
  Future<void> clearSession() async {
    token = null;
    role = null;
    userId = null;
  }

  @override
  Future<bool> hasToken() async => token != null && token!.isNotEmpty;
}
