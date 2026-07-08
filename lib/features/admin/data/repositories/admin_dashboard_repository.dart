import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../shared/models/paged_result.dart';
import '../models/admin_dashboard_models.dart';

class AdminDashboardRepository {
  final _dio = DioClient.instance;

  Future<AdminDashboardSummary> fetchSummary() async {
    try {
      // Run all calls concurrently rather than sequentially.
      final results = await Future.wait([
        _dio.get('/residents', queryParameters: {'page': 1, 'pageSize': 1}),
        _dio.get('/maintenance', queryParameters: {'status': 'Open', 'page': 1, 'pageSize': 5}),
        _dio.get('/complaints', queryParameters: {'status': 'Pending', 'page': 1, 'pageSize': 5}),
        _dio.get('/announcements/drafts'),
      ]);

      final residentsResponse = ApiResponse<PagedResult<dynamic>>.fromJson(
        results[0].data,
            (json) => PagedResult.fromJson(json, (item) => item),
      );

      final maintenanceResponse = ApiResponse<PagedResult<dynamic>>.fromJson(
        results[1].data,
            (json) => PagedResult.fromJson(json, (item) => item),
      );

      final complaintsResponse = ApiResponse<PagedResult<dynamic>>.fromJson(
        results[2].data,
            (json) => PagedResult.fromJson(json, (item) => item),
      );

      // Drafts endpoint returns a plain list, not a PagedResult.
      final draftsRaw = results[3].data['data'] as List? ?? [];

      return AdminDashboardSummary(
        totalResidents: residentsResponse.data?.totalCount ?? 0,
        openMaintenanceCount: maintenanceResponse.data?.totalCount ?? 0,
        pendingComplaintsCount: complaintsResponse.data?.totalCount ?? 0,
        upcomingAnnouncementsCount: draftsRaw.length,
        recentMaintenance: maintenanceResponse.data?.items ?? [],
        recentComplaints: complaintsResponse.data?.items ?? [],
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  AppException _handleError(dynamic e) {
    try {
      final data = e.response?.data;
      final message = data?['message'] ?? 'Failed to load dashboard.';
      return AppException(message);
    } catch (_) {
      return AppException('Network error. Please check your connection.');
    }
  }
}