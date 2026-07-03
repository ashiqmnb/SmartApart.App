import 'package:dio/dio.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/dio_client.dart';
import '../models/user_profile_models.dart';

/// Handles /api/profile HTTP calls — name/phone/photo, available to
/// any authenticated user regardless of role.
class ProfileRepository {
  final _dio = DioClient.instance;

  Future<UserProfileModel> getProfile() async {
    try {
      final response = await _dio.get('/profile');
      final apiResponse = ApiResponse<UserProfileModel>.fromJson(
        response.data,
            (json) => UserProfileModel.fromJson(json),
      );
      return apiResponse.data!;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<UserProfileModel> updateProfile(UpdateProfileRequest dto) async {
    try {
      final response = await _dio.put('/profile', data: dto.toJson());
      final apiResponse = ApiResponse<UserProfileModel>.fromJson(
        response.data,
            (json) => UserProfileModel.fromJson(json),
      );
      return apiResponse.data!;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<UserProfileModel> updateProfilePhoto(String filePath) async {
    try {
      // multipart/form-data upload — matches backend's
      // ProfileController.UpdatePhoto ([Consumes("multipart/form-data")],
      // IFormFile photo — field name below MUST be "photo" to match).
      final formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(filePath),
      });

      final response = await _dio.patch('/profile/photo', data: formData);
      final apiResponse = ApiResponse<UserProfileModel>.fromJson(
        response.data,
            (json) => UserProfileModel.fromJson(json),
      );
      return apiResponse.data!;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // AppException _handleError(dynamic e) {
  //   try {
  //     final data = e.response?.data;
  //     final message = data?['message'] ?? 'Something went wrong. Please try again.';
  //     return AppException(message);
  //   } catch (_) {
  //     return AppException('Network error. Please check your connection.');
  //   }
  // }

  AppException _handleError(dynamic e) {
    if (e is DioException) {
      return AppException.fromDioError(e);
    }
    return AppException('Unexpected error: ${e.toString()}');
  }
}