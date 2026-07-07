import 'package:flutter/material.dart';
import '../../../../core/errors/app_exception.dart';
import '../../data/models/maintenance_models.dart';
import '../../data/repositories/maintenance_repository.dart';

/// State management for Maintenance Requests — same ChangeNotifier
/// pattern as VisitorProvider (loading/error/data shape, shared
/// helper for the action-then-refresh calls).
class MaintenanceProvider extends ChangeNotifier {
  final MaintenanceRepository _repo = MaintenanceRepository();

  // ── List state ───────────────────────────────────────────────
  List<MaintenanceListModel> _requests = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMore = true;
  String? _statusFilter;
  String? _categoryFilter;

  // ── Detail state ─────────────────────────────────────────────
  MaintenanceDetailModel? _selectedRequest;
  bool _isDetailLoading = false;

  // ── Create/action state ──────────────────────────────────────
  bool _isSubmitting = false;
  double _uploadProgress = 0.0;

  List<MaintenanceListModel> get requests => _requests;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;
  String? get statusFilter => _statusFilter;
  String? get categoryFilter => _categoryFilter;
  MaintenanceDetailModel? get selectedRequest => _selectedRequest;
  bool get isDetailLoading => _isDetailLoading;
  bool get isSubmitting => _isSubmitting;
  double get uploadProgress => _uploadProgress;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ── Fetch (first page / refresh) ─────────────────────────────

  Future<void> fetchRequests({String? status, String? category}) async {
    _statusFilter = status;
    _categoryFilter = category;
    _currentPage = 1;
    _hasMore = true;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repo.getRequests(MaintenanceFilter(
        status: _statusFilter,
        category: _categoryFilter,
        page: _currentPage,
      ));
      _requests = result.items;
      _hasMore = result.hasNext;
    } on AppException catch (e) {
      _errorMessage = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Fetch next page (infinite scroll) ────────────────────────

  Future<void> fetchMore() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final result = await _repo.getRequests(MaintenanceFilter(
        status: _statusFilter,
        category: _categoryFilter,
        page: nextPage,
      ));
      _requests.addAll(result.items);
      _currentPage = nextPage;
      _hasMore = result.hasNext;
    } on AppException catch (e) {
      _errorMessage = e.message;
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // ── Detail ────────────────────────────────────────────────────

  Future<void> fetchDetail(String requestId) async {
    _isDetailLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedRequest = await _repo.getById(requestId);
    } on AppException catch (e) {
      _errorMessage = e.message;
    } finally {
      _isDetailLoading = false;
      notifyListeners();
    }
  }

  void clearSelectedRequest() {
    _selectedRequest = null;
  }

  // ── Create (with optional image upload) ──────────────────────

  Future<bool> createRequest({
    required String category,
    required String priority,
    required String title,
    required String description,
    List<String> imagePaths = const [],
  }) async {
    _isSubmitting = true;
    _uploadProgress = 0.0;
    _errorMessage = null;
    notifyListeners();

    try {
      final created = await _repo.createRequest(CreateMaintenanceRequest(
        category: category,
        priority: priority,
        title: title,
        description: description,
      ));

      if (imagePaths.isNotEmpty) {
        await _repo.uploadImages(created.id, imagePaths);
      }

      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _isSubmitting = false;
      _uploadProgress = 0.0;
      notifyListeners();
    }
  }

  // ── Admin: Update Status ──────────────────────────────────────

  Future<bool> updateStatus(String requestId, String status, {String? resolutionNote}) async {
    return _actOnRequest(() => _repo.updateStatus(
      requestId,
      UpdateMaintenanceStatusRequest(status: status, resolutionNote: resolutionNote),
    ));
  }

  // ── Admin: Assign to Staff ────────────────────────────────────

  Future<bool> assignRequest(String requestId, String assignedTo) async {
    return _actOnRequest(() => _repo.assign(
      requestId,
      AssignMaintenanceRequest(assignedTo: assignedTo),
    ));
  }

  // ── Resident: Cancel Own Request ──────────────────────────────

  Future<bool> cancelRequest(String requestId) async {
    return _actOnRequest(() => _repo.cancelRequest(requestId));
  }

  /// Shared helper — runs an action, then refreshes the detail view
  /// (mirrors VisitorProvider's _actOnVisitor pattern).
  Future<bool> _actOnRequest(Future<void> Function() action) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await action();
      if (_selectedRequest != null) {
        await fetchDetail(_selectedRequest!.id);
      }
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}