import 'package:dio/dio.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/dio_client.dart';
import '../models/amenity_models.dart';

/// Handles all HTTP calls for the Amenity module.
/// ⚠️ Base path assumed as '/amenities' — verify against your
/// actual AmenityController [Route] attribute before testing.
/// No pagination on the amenity list per the Dev Plan (small,
/// fixed set of community amenities) — GET returns a flat list.
class AmenityRepository {
  final _dio = DioClient.instance;
  static const _basePath = '/amenities';

  Future<List<AmenityListModel>> getAll() async {
    try {
      final response = await _dio.get(_basePath);
      final apiResponse = ApiResponse<List<AmenityListModel>>.fromJson(
        response.data,
            (json) => (json as List).map((e) => AmenityListModel.fromJson(e)).toList(),
      );
      return apiResponse.data ?? [];
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<AmenityDetailModel> getById(String id) async {
    try {
      final response = await _dio.get('$_basePath/$id');
      final apiResponse = ApiResponse<AmenityDetailModel>.fromJson(
        response.data,
            (json) => AmenityDetailModel.fromJson(json),
      );
      return apiResponse.data!;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<AmenityDetailModel> create(CreateAmenityRequest dto) async {
    try {
      final response = await _dio.post(_basePath, data: dto.toJson());
      final apiResponse = ApiResponse<AmenityDetailModel>.fromJson(
        response.data,
            (json) => AmenityDetailModel.fromJson(json),
      );
      return apiResponse.data!;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<AmenityDetailModel> update(String id, CreateAmenityRequest dto) async {
    try {
      final response = await _dio.put('$_basePath/$id', data: dto.toJson());
      final apiResponse = ApiResponse<AmenityDetailModel>.fromJson(
        response.data,
            (json) => AmenityDetailModel.fromJson(json),
      );
      return apiResponse.data!;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> uploadImages(String amenityId, List<String> filePaths) async {
    try {
      final formData = FormData();
      for (final path in filePaths) {
        formData.files.add(MapEntry('files', await MultipartFile.fromFile(path)));
      }
      await _dio.post('$_basePath/$amenityId/images', data: formData);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteImage(String amenityId, String imageId) async {
    try {
      await _dio.delete('$_basePath/$amenityId/images/$imageId');
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> updateAvailability(String amenityId, UpdateAvailabilityRequest dto) async {
    try {
      await _dio.patch('$_basePath/$amenityId/availability', data: dto.toJson());
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteAmenity(String id) async {
    try {
      await _dio.delete('$_basePath/$id');
    } catch (e) {
      throw _handleError(e);
    }
  }

  AppException _handleError(dynamic e) {
    if (e is DioException) {
      return AppException.fromDioError(e);
    }
    return AppException('Something went wrong. Please try again.');
  }
}