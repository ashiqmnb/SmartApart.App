/// Mirrors the backend's ApiResponse<T> wrapper.
/// [fromJsonT] tells this class how to convert the raw `data` field
/// into your actual model (e.g. a User, a List<Visitor>, etc.)
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final List<String>? errors;
  final int statusCode;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
    required this.statusCode,
  });

  factory ApiResponse.fromJson(
      Map<String, dynamic> json,
      T Function(dynamic json) fromJsonT,
      ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      errors: json['errors'] != null ? List<String>.from(json['errors']) : null,
      statusCode: json['statusCode'] ?? 500,
    );
  }
}