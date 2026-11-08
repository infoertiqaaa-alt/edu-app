import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../session/session_manager.dart';
import '../storage/token_storage.dart';

/// Configured once and injected into every data source.
class DioClient {
  final Dio dio;
  final TokenStorage _tokenStorage;
  final SessionManager _sessionManager;

  DioClient(this._tokenStorage, this._sessionManager)
    : dio = Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: ApiConstants.connectTimeout,
          receiveTimeout: ApiConstants.receiveTimeout,
          headers: {'Content-Type': 'application/json'},
        ),
      ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Public auth requests must never carry a stale token, and file
          // downloads must not leak the bearer token to a CDN host.
          final skipAuth = options.extra['skipAuth'] == true;
          if (!skipAuth && !options.path.contains(ApiConstants.login)) {
            final token = await _tokenStorage.getToken();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          final status = error.response?.statusCode;
          final isLoginRequest = error.requestOptions.path.contains(
            ApiConstants.login,
          );
          // Requests sent without the token (public release download) say
          // nothing about the session; their 401 must never log the user out.
          final skippedAuth = error.requestOptions.extra['skipAuth'] == true;

          // 401 on an authenticated endpoint means the token is expired or was
          // revoked. Clear it centrally and let listeners redirect to login.
          // Login 401s are credential errors and must not clear anything.
          if (status == 401 && !isLoginRequest && !skippedAuth) {
            await _sessionManager.expireSession();
          }

          return handler.next(error);
        },
      ),
    );
  }
}
