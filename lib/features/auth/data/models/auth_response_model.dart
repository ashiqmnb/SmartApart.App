/// Mirrors the backend's AuthResponseDto — parsed from the `data`
/// field of a successful login/register/refresh response.
class AuthResponseModel {
  final String accessToken;
  final String refreshToken;
  final String fullName;
  final String email;
  final String role;

  AuthResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.fullName,
    required this.email,
    required this.role,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
    );
  }
}