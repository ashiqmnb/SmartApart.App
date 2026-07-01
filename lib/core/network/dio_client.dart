import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../storage/secure_storage.dart';

/// Shared Dio instance used for all API calls.
/// Use DioClient.instance wherever you need to make an HTTP request.
class DioClient {
  static Dio? _dio;

  static Dio get instance {
    _dio ??= _createDio();
    return _dio!;
  }

  static Dio _createDio() {
    final dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      contentType: 'application/json',
    ));

    dio.interceptors.add(_AuthInterceptor(dio));
    return dio;
  }
}

/// Attaches the access token to every outgoing request.
/// On a 401 response, tries to refresh the token once and retry
/// the original request before giving up.
class _AuthInterceptor extends Interceptor {
  final Dio dio;
  _AuthInterceptor(this.dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await SecureStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Only attempt refresh on 401 (unauthorized / expired token)
    if (err.response?.statusCode == 401) {
      final refreshed = await _tryRefreshToken();
      if (refreshed) {
        final token = await SecureStorage.getAccessToken();
        err.requestOptions.headers['Authorization'] = 'Bearer $token';
        try {
          // Retry the original request with the new token
          final response = await dio.fetch(err.requestOptions);
          return handler.resolve(response);
        } catch (_) {
          // Retry itself failed — fall through to normal error handling
        }
      } else {
        // Refresh failed — clear tokens so the app can redirect to login
        await SecureStorage.clearAll();
      }
    }
    handler.next(err);
  }

  Future<bool> _tryRefreshToken() async {
    final refreshToken = await SecureStorage.getRefreshToken();
    if (refreshToken == null) return false;

    try {
      // Uses a plain Dio (not the shared instance) to avoid interceptor loops
      final response = await Dio().post(
        '${ApiConstants.baseUrl}${ApiConstants.refreshTokenEndpoint}',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        await SecureStorage.saveTokens(data['accessToken'], data['refreshToken']);
        return true;
      }
    } catch (_) {
      // Refresh request itself failed (network error, invalid token, etc.)
    }
    return false;
  }
}