import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../models/auth_request_models.dart';
import '../models/auth_response_model.dart';

/// All HTTP calls to /auth endpoints. Equivalent to an api/auth.js
/// file in a React project — no app state lives here, just requests
/// in and parsed models (or thrown errors) out. AuthProvider (Step 2)
/// is what actually holds state and calls these methods.
class AuthRepository {
  final Dio _dio = DioClient.instance;

  Future<AuthResponseModel> register(RegisterRequest request) async {
    try {
      final response = await _dio.post(ApiConstants.register, data: request.toJson());
      return AuthResponseModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw AppException.fromDioError(e);
    }
  }

  Future<void> verifyOtp(VerifyOtpRequest request) async {
    try {
      await _dio.post(ApiConstants.verifyOtp, data: request.toJson());
    } on DioException catch (e) {
      throw AppException.fromDioError(e);
    }
  }

  Future<AuthResponseModel> login(LoginRequest request) async {
    try {
      final response = await _dio.post(ApiConstants.login, data: request.toJson());
      return AuthResponseModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw AppException.fromDioError(e);
    }
  }

  Future<void> logout(String refreshToken) async {
    try {
      await _dio.post(
        ApiConstants.logout,
        data: RefreshTokenRequest(refreshToken: refreshToken).toJson(),
      );
    } on DioException catch (e) {
      throw AppException.fromDioError(e);
    }
  }

  Future<void> forgotPassword(ForgotPasswordRequest request) async {
    try {
      await _dio.post(ApiConstants.forgotPassword, data: request.toJson());
    } on DioException catch (e) {
      throw AppException.fromDioError(e);
    }
  }

  Future<void> resetPassword(ResetPasswordRequest request) async {
    try {
      await _dio.post(ApiConstants.resetPassword, data: request.toJson());
    } on DioException catch (e) {
      throw AppException.fromDioError(e);
    }
  }

  Future<void> changePassword(ChangePasswordRequest request) async {
    try {
      await _dio.post(ApiConstants.changePassword, data: request.toJson());
    } on DioException catch (e) {
      throw AppException.fromDioError(e);
    }
  }

  Future<void> resendOtp(ResendOtpRequest request) async {
    try {
      await _dio.post(ApiConstants.resendOtp, data: request.toJson());
    } on DioException catch (e) {
      throw AppException.fromDioError(e);
    }
  }
}