import 'package:dio/dio.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../shared/models/paged_result.dart';
import '../models/visitor_models.dart';

/// Handles all HTTP calls for Visitor endpoints.
/// Base path assumed as /Visitor (singular, capitalized) — matching
/// ResidentController's actual routing. Confirm against Swagger.
class VisitorRepository {
  final _dio = DioClient.instance;
  static const _basePath = '/Visitor';

  // ── Register ─────────────────────────────────────────────────

  Future<VisitorDetailModel> registerVisitor(RegisterVisitorRequest dto) async {
    try {
      final response = await _dio.post(_basePath, data: dto.toJson());
      final apiResponse = ApiResponse<VisitorDetailModel>.fromJson(
        response.data,
            (json) => VisitorDetailModel.fromJson(json),
      );
      return apiResponse.data!;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ── List (paginated, filterable) ────────────────────────────

  Future<PagedResult<VisitorListModel>> getVisitors({
    String? status,
    DateTime? from,
    DateTime? to,
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final query = <String, dynamic>{
        'page': page,
        'pageSize': pageSize,
      };
      if (status != null && status.isNotEmpty) query['status'] = status;
      if (from != null) query['from'] = from.toIso8601String();
      if (to != null) query['to'] = to.toIso8601String();

      final response = await _dio.get(_basePath, queryParameters: query);
      final apiResponse = ApiResponse<PagedResult<VisitorListModel>>.fromJson(
        response.data,
            (json) => PagedResult<VisitorListModel>.fromJson(
          json,
              (item) => VisitorListModel.fromJson(item),
        ),
      );
      return apiResponse.data!;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ── Pending approvals (Resident) ────────────────────────────

  Future<List<VisitorListModel>> getPendingApprovals() async {
    try {
      final response = await _dio.get('$_basePath/pending');
      final apiResponse = ApiResponse<List<VisitorListModel>>.fromJson(
        response.data,
            (json) => (json as List)
            .map((e) => VisitorListModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
      return apiResponse.data ?? [];
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ── Detail ───────────────────────────────────────────────────

  Future<VisitorDetailModel> getVisitorById(String visitorId) async {
    try {
      final response = await _dio.get('$_basePath/$visitorId');
      final apiResponse = ApiResponse<VisitorDetailModel>.fromJson(
        response.data,
            (json) => VisitorDetailModel.fromJson(json),
      );
      return apiResponse.data!;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ── Approve / Reject (Resident) ─────────────────────────────

  Future<VisitorDetailModel> approveVisitor(String visitorId, {String? reason}) async {
    try {
      final response = await _dio.patch(
        '$_basePath/$visitorId/approve',
        data: ApproveRejectVisitorRequest(reason: reason).toJson(),
      );
      final apiResponse = ApiResponse<VisitorDetailModel>.fromJson(
        response.data,
            (json) => VisitorDetailModel.fromJson(json),
      );
      return apiResponse.data!;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<VisitorDetailModel> rejectVisitor(String visitorId, {String? reason}) async {
    try {
      final response = await _dio.patch(
        '$_basePath/$visitorId/reject',
        data: ApproveRejectVisitorRequest(reason: reason).toJson(),
      );
      final apiResponse = ApiResponse<VisitorDetailModel>.fromJson(
        response.data,
            (json) => VisitorDetailModel.fromJson(json),
      );
      return apiResponse.data!;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ── Exit (Security) ─────────────────────────────────────────

  Future<VisitorDetailModel> registerExit(String visitorId) async {
    try {
      final response = await _dio.patch('$_basePath/$visitorId/exit');
      final apiResponse = ApiResponse<VisitorDetailModel>.fromJson(
        response.data,
            (json) => VisitorDetailModel.fromJson(json),
      );
      return apiResponse.data!;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ── Error Handling ───────────────────────────────────────────

  AppException _handleError(dynamic e) {
    if (e is DioException) {
      return AppException.fromDioError(e);
    }
    return AppException('Unexpected error: ${e.toString()}');
  }
}