import 'package:dio/dio.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../shared/models/paged_result.dart';
import '../models/announcement_models.dart';

/// Handles all HTTP calls for the Announcement module.
/// ⚠️ Base path assumed as '/announcements' — verify against your
/// actual AnnouncementController [Route] attribute before testing.
class AnnouncementRepository {
  final _dio = DioClient.instance;
  static const _basePath = '/announcements';

  Future<PagedResult<AnnouncementListModel>> getPublished(AnnouncementFilter filter) async {
    try {
      final response = await _dio.get(_basePath, queryParameters: filter.toQueryParams());
      final apiResponse = ApiResponse<PagedResult<AnnouncementListModel>>.fromJson(
        response.data,
            (json) => PagedResult<AnnouncementListModel>.fromJson(
          json,
              (item) => AnnouncementListModel.fromJson(item),
        ),
      );
      return apiResponse.data!;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Admin only — scheduled/unpublished announcements.
  Future<PagedResult<AnnouncementListModel>> getDrafts({int page = 1, int pageSize = 10}) async {
    try {
      final response = await _dio.get(
        '$_basePath/drafts',
        queryParameters: {'page': page, 'pageSize': pageSize},
      );
      final apiResponse = ApiResponse<PagedResult<AnnouncementListModel>>.fromJson(
        response.data,
            (json) => PagedResult<AnnouncementListModel>.fromJson(
          json,
              (item) => AnnouncementListModel.fromJson(item),
        ),
      );
      return apiResponse.data!;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<AnnouncementDetailModel> getById(String id) async {
    try {
      final response = await _dio.get('$_basePath/$id');
      final apiResponse = ApiResponse<AnnouncementDetailModel>.fromJson(
        response.data,
            (json) => AnnouncementDetailModel.fromJson(json),
      );
      return apiResponse.data!;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<AnnouncementDetailModel> create(CreateAnnouncementRequest dto) async {
    try {
      final response = await _dio.post(_basePath, data: dto.toJson());
      final apiResponse = ApiResponse<AnnouncementDetailModel>.fromJson(
        response.data,
            (json) => AnnouncementDetailModel.fromJson(json),
      );
      return apiResponse.data!;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<AnnouncementDetailModel> update(String id, CreateAnnouncementRequest dto) async {
    try {
      final response = await _dio.put('$_basePath/$id', data: dto.toJson());
      final apiResponse = ApiResponse<AnnouncementDetailModel>.fromJson(
        response.data,
            (json) => AnnouncementDetailModel.fromJson(json),
      );
      return apiResponse.data!;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> uploadAttachments(
      String announcementId,
      List<String> filePaths,
      String fileType,
      ) async {
    try {
      final formData = FormData();
      formData.fields.add(MapEntry('fileType', fileType));
      for (final path in filePaths) {
        formData.files.add(MapEntry('files', await MultipartFile.fromFile(path)));
      }
      await _dio.post('$_basePath/$announcementId/attachments', data: formData);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteAnnouncement(String id) async {
    try {
      await _dio.delete('$_basePath/$id');
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> publishDraft(String id) async {
    try {
      await _dio.post('$_basePath/$id/publish');
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