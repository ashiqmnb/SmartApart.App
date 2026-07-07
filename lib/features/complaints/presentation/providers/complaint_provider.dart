import 'package:flutter/material.dart';
import '../../../../core/errors/app_exception.dart';
import '../../data/models/complaint_models.dart';
import '../../data/repositories/complaint_repository.dart';

/// State management for Complaints — mirrors MaintenanceProvider's
/// shape. The Normal/Anonymous toggle is just a string field passed
/// straight through to createComplaint; no special client-side logic
/// needed since the backend handles the masking.
class ComplaintProvider extends ChangeNotifier {
  final ComplaintRepository _repo = ComplaintRepository();

  // ── List state ───────────────────────────────────────────────
  List<ComplaintListModel> _complaints = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMore = true;
  String? _statusFilter;

  // ── Detail state ─────────────────────────────────────────────
  ComplaintDetailModel? _selectedComplaint;
  bool _isDetailLoading = false;

  // ── Create/action state ──────────────────────────────────────
  bool _isSubmitting = false;

  List<ComplaintListModel> get complaints => _complaints;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;
  String? get statusFilter => _statusFilter;
  ComplaintDetailModel? get selectedComplaint => _selectedComplaint;
  bool get isDetailLoading => _isDetailLoading;
  bool get isSubmitting => _isSubmitting;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ── Fetch (first page / refresh) ─────────────────────────────

  Future<void> fetchComplaints({String? status}) async {
    _statusFilter = status;
    _currentPage = 1;
    _hasMore = true;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repo.getComplaints(ComplaintFilter(
        status: _statusFilter,
        page: _currentPage,
      ));
      _complaints = result.items;
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
      final result = await _repo.getComplaints(ComplaintFilter(
        status: _statusFilter,
        page: nextPage,
      ));
      _complaints.addAll(result.items);
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

  Future<void> fetchDetail(String complaintId) async {
    _isDetailLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedComplaint = await _repo.getById(complaintId);
    } on AppException catch (e) {
      _errorMessage = e.message;
    } finally {
      _isDetailLoading = false;
      notifyListeners();
    }
  }

  void clearSelectedComplaint() {
    _selectedComplaint = null;
  }

  // ── Create (with optional image upload) ──────────────────────

  Future<bool> createComplaint({
    required String category,
    required String complaintType, // "Normal" or "Anonymous"
    required String title,
    required String description,
    List<String> imagePaths = const [],
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final created = await _repo.createComplaint(CreateComplaintRequest(
        category: category,
        complaintType: complaintType,
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
      notifyListeners();
    }
  }

  // ── Admin: Update Status ──────────────────────────────────────

  Future<bool> updateStatus(String complaintId, String status, {String? resolutionNote}) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repo.updateStatus(
        complaintId,
        UpdateComplaintStatusRequest(status: status, resolutionNote: resolutionNote),
      );
      if (_selectedComplaint != null) {
        await fetchDetail(_selectedComplaint!.id);
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