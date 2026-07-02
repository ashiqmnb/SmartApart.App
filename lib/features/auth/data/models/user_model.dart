import 'auth_response_model.dart';

/// Represents the currently logged-in user. Built from AuthResponseModel
/// after login/register — screens read this via AuthProvider.currentUser
/// instead of touching tokens directly.
class UserModel {
  final String fullName;
  final String email;
  final String role;

  UserModel({required this.fullName, required this.email, required this.role});

  factory UserModel.fromAuthResponse(AuthResponseModel response) {
    return UserModel(
      fullName: response.fullName,
      email: response.email,
      role: response.role,
    );
  }
}