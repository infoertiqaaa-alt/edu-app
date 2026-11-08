import 'package:dio/dio.dart';

/// Unified error model used with `Either<Failure, T>`.
///
/// Subclasses let the UI/repository distinguish an expired session from wrong
/// credentials, a network outage or malformed server data.
class Failure {
  final String message;
  final int? statusCode;

  const Failure(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class AuthenticationFailure extends Failure {
  const AuthenticationFailure(super.message, {super.statusCode});
}

class InvalidCredentialsFailure extends AuthenticationFailure {
  const InvalidCredentialsFailure(super.message, {super.statusCode = 401});
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure(super.message, {super.statusCode = 401});
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.statusCode});
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.statusCode});
}

class ParsingFailure extends Failure {
  const ParsingFailure(super.message, {super.statusCode});
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.statusCode});
}

/// Thrown when a local operation needs an authenticated user but none exists.
class SessionException implements Exception {
  final String message;

  const SessionException(this.message);

  @override
  String toString() => message;
}

class ApiException implements Exception {
  final String message;

  const ApiException(this.message);

  @override
  String toString() => message;
}

/// Converts any Dio/parsing error into an Arabic, user-facing [Failure].
class NetworkExceptions {
  NetworkExceptions._();

  static Failure handle(dynamic error, {bool isLoginRequest = false}) {
    if (error is Failure) return error;

    if (error is ApiException) {
      return Failure(error.message);
    }

    if (error is SessionException) {
      return UnauthorizedFailure(error.message);
    }

    if (error is FormatException || error is TypeError) {
      return const ParsingFailure('تعذر قراءة استجابة الخادم.');
    }

    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return const NetworkFailure('انتهت مهلة الاتصال، حاول تاني');
        case DioExceptionType.connectionError:
          return const NetworkFailure('تأكد من اتصالك بالإنترنت');
        case DioExceptionType.badCertificate:
          return const NetworkFailure('اتصال غير آمن بالخادم.');
        case DioExceptionType.badResponse:
          return _handleStatusCode(
            error.response?.statusCode,
            error.response?.data,
            isLoginRequest: isLoginRequest,
          );
        case DioExceptionType.cancel:
          return const Failure('تم إلغاء الطلب');
        default:
          return const Failure('حصل خطأ غير متوقع، حاول تاني');
      }
    }
    return Failure(error.toString());
  }

  static Failure _handleStatusCode(
    int? code,
    dynamic data, {
    required bool isLoginRequest,
  }) {
    String? serverMessage;
    if (data is Map && data['message'] != null) {
      final message = data['message'].toString().trim();
      if (message.isNotEmpty) serverMessage = message;
    }

    switch (code) {
      case 400:
        return ValidationFailure(
          serverMessage ?? 'بيانات غير صحيحة',
          statusCode: code,
        );
      case 401:
        if (isLoginRequest) {
          return InvalidCredentialsFailure(
            serverMessage ?? 'اسم المستخدم أو كلمة المرور غير صحيحة',
          );
        }
        return UnauthorizedFailure(
          serverMessage ?? 'انتهت صلاحية الجلسة، سجّل الدخول من جديد.',
        );
      case 403:
        return Failure(
          serverMessage ?? 'غير مسموح لك بالدخول',
          statusCode: code,
        );
      case 404:
        return Failure(
          serverMessage ?? 'الخدمة غير متاحة حاليًا',
          statusCode: code,
        );
      case 422:
        return ValidationFailure(
          serverMessage ?? 'البيانات المرسلة غير صالحة',
          statusCode: code,
        );
      case 429:
        return Failure(
          serverMessage ?? 'محاولات كثيرة، حاول بعد قليل',
          statusCode: code,
        );
      case 500:
      case 502:
      case 503:
      case 504:
        return ServerFailure(
          serverMessage ?? 'خطأ في السيرفر، حاول لاحقًا',
          statusCode: code,
        );
      default:
        return Failure(
          serverMessage ?? 'حصل خطأ غير متوقع (كود $code)',
          statusCode: code,
        );
    }
  }
}
