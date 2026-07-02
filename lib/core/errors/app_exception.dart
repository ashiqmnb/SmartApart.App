import 'package:dio/dio.dart';

/// Custom exception for failed API calls. Mirrors the backend's
/// AppException — carries a user-facing message + HTTP status code,
/// similar to a custom class extending Error in JS with extra fields.
class AppException implements Exception {
  final String message;
  final int statusCode;

  AppException(this.message, {this.statusCode = 500});

  /// Converts a raw Dio error into an AppException, pulling the
  /// readable message out of the backend's ApiResponse wrapper
  /// ({ success, message, errors, statusCode }) when one exists.
  factory AppException.fromDioError(DioException error) {
    if (error.response != null && error.response?.data is Map) {
      final data = error.response!.data as Map;
      final message = data['message'] ?? 'Something went wrong. Please try again.';
      final statusCode = error.response?.statusCode ?? 500;
      return AppException(message.toString(), statusCode: statusCode);
    }

    // No response at all — a network/timeout issue, not a backend error.
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return AppException('Connection timed out. Check your network and try again.');
    }
    if (error.type == DioExceptionType.connectionError) {
      return AppException('Could not connect to the server. Check your network.');
    }

    return AppException('Something went wrong. Please try again.');
  }

  @override
  String toString() => message;
}