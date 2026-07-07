import 'package:dio/dio.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../shared/models/paged_result.dart';
import '../models/complaint_models.dart';

/// Handles all HTTP calls for the Complaint module.
/// ⚠️ Base path assumed as '/complaints' — verify against your
/// actual ComplaintController [Route] attribute before testing.
class ComplaintRepository {
  final _dio = DioClient.instance;
  static const _basePath = '/complaint';

  Future<PagedResult<ComplaintListModel>> getComplaints(ComplaintFilter filter) async {
    try {
      final response = await _dio.get(_basePath, queryParameters: filter.toQueryParams());
      final apiResponse = ApiResponse<PagedResult<ComplaintListModel>>.fromJson(
        response.data,
            (json) => PagedResult<ComplaintListModel>.fromJson(
          json,
              (item) => ComplaintListModel.fromJson(item),
        ),
      );
      return apiResponse.data!;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<ComplaintDetailModel> getById(String id) async {
    try {
      final response = await _dio.get('$_basePath/$id');
      final apiResponse = ApiResponse<ComplaintDetailModel>.fromJson(
        response.data,
            (json) => ComplaintDetailModel.fromJson(json),
      );
      return apiResponse.data!;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<ComplaintDetailModel> createComplaint(CreateComplaintRequest dto) async {
    try {
      final response = await _dio.post(_basePath, data: dto.toJson());
      final apiResponse = ApiResponse<ComplaintDetailModel>.fromJson(
        response.data,
            (json) => ComplaintDetailModel.fromJson(json),
      );
      return apiResponse.data!;
    } catch (e) {
      if (e is DioException) {
        print('CREATE COMPLAINT RESPONSE DATA: ${e.response?.data}'); // temporary debug line
      }
      throw _handleError(e);
    }
  }

  Future<void> uploadImages(String complaintId, List<String> filePaths) async {
    try {
      final formData = FormData();
      for (final path in filePaths) {
        formData.files.add(MapEntry(
          'files',
          await MultipartFile.fromFile(path),
        ));
      }
      await _dio.post('$_basePath/$complaintId/images', data: formData);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> updateStatus(String complaintId, UpdateComplaintStatusRequest dto) async {
    try {
      await _dio.patch('$_basePath/$complaintId/status', data: dto.toJson());
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