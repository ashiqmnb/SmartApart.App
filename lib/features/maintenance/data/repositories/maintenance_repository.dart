import 'package:dio/dio.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../shared/models/paged_result.dart';
import '../models/maintenance_models.dart';

/// Handles all HTTP calls for the Maintenance module.
/// ⚠️ Base path assumed as '/maintenance' per the Dev Plan — verify
/// against your actual MaintenanceController [Route] attribute
/// before testing (Visitor turned out to be singular+capitalized
/// despite the plan saying otherwise).
class MaintenanceRepository {
  final _dio = DioClient.instance;
  static const _basePath = '/maintenance';

  Future<PagedResult<MaintenanceListModel>> getRequests(MaintenanceFilter filter) async {
    try {
      final response = await _dio.get(_basePath, queryParameters: filter.toQueryParams());
      final apiResponse = ApiResponse<PagedResult<MaintenanceListModel>>.fromJson(
        response.data,
            (json) => PagedResult<MaintenanceListModel>.fromJson(
          json,
              (item) => MaintenanceListModel.fromJson(item),
        ),
      );
      return apiResponse.data!;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<MaintenanceDetailModel> getById(String id) async {
    try {
      final response = await _dio.get('$_basePath/$id');
      final apiResponse = ApiResponse<MaintenanceDetailModel>.fromJson(
        response.data,
            (json) => MaintenanceDetailModel.fromJson(json),
      );
      return apiResponse.data!;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<MaintenanceDetailModel> createRequest(CreateMaintenanceRequest dto) async {
    try {
      final response = await _dio.post(_basePath, data: dto.toJson());
      final apiResponse = ApiResponse<MaintenanceDetailModel>.fromJson(
        response.data,
            (json) => MaintenanceDetailModel.fromJson(json),
      );
      return apiResponse.data!;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Uploads one or more images for a request. Called after createRequest
  /// succeeds, once per selected image (or as a batch — wired properly
  /// in Step 4 once we build the picker UI).
  Future<void> uploadImages(String requestId, List<String> filePaths) async {
    try {
      final formData = FormData();
      for (final path in filePaths) {
        formData.files.add(MapEntry(
          'files',
          await MultipartFile.fromFile(path),
        ));
      }
      await _dio.post('$_basePath/$requestId/images', data: formData);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> updateStatus(String requestId, UpdateMaintenanceStatusRequest dto) async {
    try {
      await _dio.patch('$_basePath/$requestId/status', data: dto.toJson());
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> assign(String requestId, AssignMaintenanceRequest dto) async {
    try {
      await _dio.patch('$_basePath/$requestId/assign', data: dto.toJson());
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> cancelRequest(String requestId) async {
    try {
      await _dio.delete('$_basePath/$requestId');
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