import 'user_model.dart';

class LoginResponseModel {
  final bool success;
  final String message;
  final String token;
  final UserModel user;

  const LoginResponseModel({
    required this.success,
    required this.message,
    required this.token,
    required this.user,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    final responseData = json['data'];
    if (responseData is! Map) {
      throw const FormatException('Login response data is missing or invalid.');
    }

    final data = Map<String, dynamic>.from(responseData);
    final userData = data['user'];
    if (userData is! Map) {
      throw const FormatException('Login response user is missing or invalid.');
    }

    return LoginResponseModel(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      token: data['token']?.toString() ?? '',
      user: UserModel.fromJson(Map<String, dynamic>.from(userData)),
    );
  }
}
