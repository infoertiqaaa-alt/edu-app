import '../utils/json_parsers.dart';
import 'network_exceptions.dart';

class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;

  const ApiResponse({required this.success, required this.message, this.data});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json) fromJsonT,
  ) {
    final rawData = json['data'];
    return ApiResponse<T>(
      success: JsonParsers.asBoolOr(json['success'], fallback: false),
      message: JsonParsers.asString(json['message']),
      data: rawData != null ? fromJsonT(rawData) : null,
    );
  }

  /// Parses a raw Dio response body and returns its `data`, or throws.
  ///
  /// Every remote data source used to repeat `apiResponse.data!`, which turned
  /// a `success:false` reply into an anonymous null-check crash and hid the
  /// server's own message. This keeps one contract for all endpoints:
  /// - a non-object body (HTML error page, plain text) → [FormatException];
  /// - `success:false` → [ApiException] with the server message (or
  ///   [failureMessage] when the server sent none);
  /// - `success:true` without `data` → [FormatException].
  static T requireData<T>(
    dynamic body,
    T Function(dynamic json) fromJsonT, {
    required String failureMessage,
  }) {
    if (body is! Map) {
      throw const FormatException('Response body is not a JSON object.');
    }

    final response = ApiResponse<T>.fromJson(
      Map<String, dynamic>.from(body),
      fromJsonT,
    );

    if (!response.success) {
      throw ApiException(
        response.message.isNotEmpty ? response.message : failureMessage,
      );
    }

    final data = response.data;
    if (data == null) {
      throw const FormatException('Response does not contain data.');
    }
    return data;
  }
}
