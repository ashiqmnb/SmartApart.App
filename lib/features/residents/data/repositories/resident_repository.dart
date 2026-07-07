import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../shared/models/paged_result.dart';
import '../models/family_member_models.dart';
import '../models/resident_models.dart';

/// Handles all HTTP calls for Resident + Family Member endpoints.
/// Mirrors AuthRepository's pattern — unwraps ApiResponse`<T>`, throws
/// AppException on failure so providers can catch a single error type.
class ResidentRepository {
  final _dio = DioClient.instance;

  // ── My Profile ───────────────────────────────────────────────

  Future<ResidentDetailModel> getMyProfile() async {
    try {
      final response = await _dio.get('/resident/my-profile');
      final apiResponse = ApiResponse<ResidentDetailModel>.fromJson(
        response.data,
            (json) => ResidentDetailModel.fromJson(json),
      );
      return apiResponse.data!;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<ResidentDetailModel> updateResident(String residentId, UpdateResidentRequest dto) async {
    try {
      final response = await _dio.put('/resident/$residentId', data: dto.toJson());
      final apiResponse = ApiResponse<ResidentDetailModel>.fromJson(
        response.data,
            (json) => ResidentDetailModel.fromJson(json),
      );
      return apiResponse.data!;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ── Family Members ───────────────────────────────────────────

  Future<List<FamilyMemberModel>> getFamilyMembers(String residentId) async {
    try {
      final response = await _dio.get('/resident/$residentId/family-members');
      final apiResponse = ApiResponse<List<FamilyMemberModel>>.fromJson(
        response.data,
            (json) => (json as List).map((e) => FamilyMemberModel.fromJson(e)).toList(),
      );
      return apiResponse.data ?? [];
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<FamilyMemberModel> addFamilyMember(String residentId, FamilyMemberRequest dto) async {
    try {
      final response = await _dio.post('/resident/$residentId/family-members', data: dto.toJson());
      final apiResponse = ApiResponse<FamilyMemberModel>.fromJson(
        response.data,
            (json) => FamilyMemberModel.fromJson(json),
      );
      return apiResponse.data!;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<FamilyMemberModel> updateFamilyMember(
      String residentId,
      String memberId,
      FamilyMemberRequest dto,
      ) async {
    try {
      final response = await _dio.put(
        '/resident/$residentId/family-members/$memberId',
        data: dto.toJson(),
      );
      final apiResponse = ApiResponse<FamilyMemberModel>.fromJson(
        response.data,
            (json) => FamilyMemberModel.fromJson(json),
      );
      return apiResponse.data!;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteFamilyMember(String residentId, String memberId) async {
    try {
      await _dio.delete('/resident/$residentId/family-members/$memberId');
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ── Admin: Directory & Search ───────────────────────────────────

  Future<PagedResult<ResidentDetailModel>> getAllResidents({
    required int page,
    required int pageSize,
  }) async {
    try {
      final response = await _dio.get(
        '/resident',
        queryParameters: {'page': page, 'pageSize': pageSize},
      );
      final apiResponse = ApiResponse<PagedResult<ResidentDetailModel>>.fromJson(
        response.data,
            (json) => PagedResult<ResidentDetailModel>.fromJson(
          json,
              (item) => ResidentDetailModel.fromJson(item),
        ),
      );
      return apiResponse.data!;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<ResidentDetailModel>> searchResidents(String query) async {
    try {
      final response = await _dio.get(
        '/resident/search',
        queryParameters: {'q': query},
      );
      final apiResponse = ApiResponse<List<ResidentDetailModel>>.fromJson(
        response.data,
            (json) => (json as List)
            .map((e) => ResidentDetailModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
      return apiResponse.data ?? [];
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<ResidentDetailModel> getResidentById(String residentId) async {
    try {
      final response = await _dio.get('/resident/$residentId');
      final apiResponse = ApiResponse<ResidentDetailModel>.fromJson(
        response.data,
            (json) => ResidentDetailModel.fromJson(json),
      );
      return apiResponse.data!;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Search for role-appropriate resident info — used by non-Admin
  /// callers (e.g. Security's resident picker on Register Visitor).
  /// Backend returns ResidentPublicDto (slim shape) for non-Admin roles.
  Future<List<ResidentPublicModel>> searchResidentsPublic(String query) async {
    try {
      final response = await _dio.get(
        '/resident/search',
        queryParameters: {'q': query},
      );
      final apiResponse = ApiResponse<List<ResidentPublicModel>>.fromJson(
        response.data,
            (json) => (json as List)
            .map((e) => ResidentPublicModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
      return apiResponse.data ?? [];
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ── Error Handling ───────────────────────────────────────────

  AppException _handleError(dynamic e) {
    try {
      final data = e.response?.data;
      final message = data?['message'] ?? 'Something went wrong. Please try again.';
      return AppException(message);
    } catch (_) {
      return AppException('Network error. Please check your connection.');
    }
  }
}