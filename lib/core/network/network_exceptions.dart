import 'package:dio/dio.dart';

/// كلاس موحّد لأي خطأ راجع من السيرفر أو الشبكة، بيتبعت بدل ما نرمي Exception عادي
class Failure {
  final String message;
  final int? statusCode;

  const Failure(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiException implements Exception {
  final String message;

  const ApiException(this.message);

  @override
  String toString() => message;
}

/// بيحوّل أي error جاي من Dio لرسالة عربي مفهومة للمستخدم
class NetworkExceptions {
  NetworkExceptions._();

  static Failure handle(dynamic error) {
    if (error is ApiException) {
      return Failure(error.message);
    }

    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return const Failure('انتهت مهلة الاتصال، حاول تاني');
        case DioExceptionType.connectionError:
          return const Failure('تأكد من اتصالك بالإنترنت');
        case DioExceptionType.badResponse:
          return _handleStatusCode(
            error.response?.statusCode,
            error.response?.data,
          );
        case DioExceptionType.cancel:
          return const Failure('تم إلغاء الطلب');
        default:
          return const Failure('حصل خطأ غير متوقع، حاول تاني');
      }
    }
    return Failure(error.toString());
  }

  static Failure _handleStatusCode(int? code, dynamic data) {
    String? serverMessage;
    if (data is Map && data['message'] != null) {
      serverMessage = data['message'].toString();
    }

    switch (code) {
      case 400:
        return Failure(serverMessage ?? 'بيانات غير صحيحة');
      case 401:
        return Failure(serverMessage ?? 'اسم المستخدم أو كلمة المرور غير صحيحة');
      case 403:
        return Failure(serverMessage ?? 'غير مسموح لك بالدخول');
      case 404:
        return Failure(serverMessage ?? 'الخدمة غير متاحة حاليًا');
      case 500:
        return Failure(serverMessage ?? 'خطأ في السيرفر، حاول لاحقًا');
      default:
        return Failure(serverMessage ?? 'حصل خطأ غير متوقع (كود $code)');
    }
  }
}
