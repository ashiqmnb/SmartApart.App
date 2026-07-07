import 'package:flutter/material.dart';
import '../../../../core/errors/app_exception.dart';
import '../../data/models/visitor_models.dart';
import '../../data/repositories/visitor_repository.dart';

/// Manages visitor log (paginated + filtered), pending approvals,
/// and single-visitor detail state. Shared across Security, Resident,
/// and Admin roles — screens read only the slice they need.
class VisitorProvider extends ChangeNotifier {
  final VisitorRepository _repository = VisitorRepository();

  // ── Visitor Log (list) ──────────────────────────────────────

  List<VisitorListModel> _visitors = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasNext = true;
  int _page = 1;
  static const _pageSize = 10;
  String? _statusFilter; // null = All
  String? _errorMessage;

  List<VisitorListModel> get visitors => _visitors;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasNext => _hasNext;
  String? get statusFilter => _statusFilter;
  String? get errorMessage => _errorMessage;

  // ── Pending Approvals (Resident) ────────────────────────────

  List<VisitorListModel> _pendingApprovals = [];
  bool _isPendingLoading = false;
  String? _pendingErrorMessage;

  List<VisitorListModel> get pendingApprovals => _pendingApprovals;
  bool get isPendingLoading => _isPendingLoading;
  String? get pendingErrorMessage => _pendingErrorMessage;

  // ── Detail (single visitor) ─────────────────────────────────

  VisitorDetailModel? _selectedVisitor;
  bool _isDetailLoading = false;
  String? _detailErrorMessage;
  bool _isActionInProgress = false;

  VisitorDetailModel? get selectedVisitor => _selectedVisitor;
  bool get isDetailLoading => _isDetailLoading;
  String? get detailErrorMessage => _detailErrorMessage;
  bool get isActionInProgress => _isActionInProgress;

  void clearError() {
    _errorMessage = null;
    _pendingErrorMessage = null;
    _detailErrorMessage = null;
    notifyListeners();
  }

  // ── Visitor Log: filter + load ──────────────────────────────

  void setStatusFilter(String? status) {
    _statusFilter = status;
    fetchVisitors();
  }

  Future<void> fetchVisitors() async {
    _page = 1;
    _hasNext = true;
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _repository.getVisitors(
        status: _statusFilter,
        page: _page,
        pageSize: _pageSize,
      );
      _visitors = result.items;
      _hasNext = result.hasNext;
      _errorMessage = null;
    } on AppException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Something went wrong. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchNextPage() async {
    if (_isLoadingMore || !_hasNext) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = _page + 1;
      final result = await _repository.getVisitors(
        status: _statusFilter,
        page: nextPage,
        pageSize: _pageSize,
      );
      _visitors = [..._visitors, ...result.items];
      _page = nextPage;
      _hasNext = result.hasNext;
    } on AppException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Something went wrong. Please try again.';
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // ── Pending Approvals ────────────────────────────────────────

  Future<void> fetchPendingApprovals() async {
    _isPendingLoading = true;
    notifyListeners();

    try {
      _pendingApprovals = await _repository.getPendingApprovals();
      _pendingErrorMessage = null;
    } on AppException catch (e) {
      _pendingErrorMessage = e.message;
    } catch (_) {
      _pendingErrorMessage = 'Something went wrong. Please try again.';
    } finally {
      _isPendingLoading = false;
      notifyListeners();
    }
  }

  // ── Detail ───────────────────────────────────────────────────

  Future<void> fetchVisitorDetail(String visitorId) async {
    _isDetailLoading = true;
    notifyListeners();

    try {
      _selectedVisitor = await _repository.getVisitorById(visitorId);
      _detailErrorMessage = null;
    } on AppException catch (e) {
      _detailErrorMessage = e.message;
    } catch (_) {
      _detailErrorMessage = 'Something went wrong. Please try again.';
    } finally {
      _isDetailLoading = false;
      notifyListeners();
    }
  }

  // ── Register (Security) ─────────────────────────────────────

  Future<bool> registerVisitor(RegisterVisitorRequest dto) async {
    _isActionInProgress = true;
    notifyListeners();

    try {
      await _repository.registerVisitor(dto);
      _detailErrorMessage = null;
      return true;
    } on AppException catch (e) {
      _detailErrorMessage = e.message;
      return false;
    } catch (_) {
      _detailErrorMessage = 'Something went wrong. Please try again.';
      return false;
    } finally {
      _isActionInProgress = false;
      notifyListeners();
    }
  }

  // ── Approve / Reject (Resident) ─────────────────────────────
  // Removes the acted-on visitor from the local pending list
  // immediately (optimistic-friendly), and updates detail/log
  // state if that visitor happens to also be loaded there.

  Future<bool> approveVisitor(String visitorId, {String? reason}) async {
    return _actOnVisitor(
      visitorId,
      action: () => _repository.approveVisitor(visitorId, reason: reason),
    );
  }

  Future<bool> rejectVisitor(String visitorId, {String? reason}) async {
    return _actOnVisitor(
      visitorId,
      action: () => _repository.rejectVisitor(visitorId, reason: reason),
    );
  }

  Future<bool> _actOnVisitor(
      String visitorId, {
        required Future<VisitorDetailModel> Function() action,
      }) async {
    _isActionInProgress = true;
    notifyListeners();

    try {
      final updated = await action();

      _pendingApprovals = _pendingApprovals.where((v) => v.id != visitorId).toList();

      if (_selectedVisitor?.id == visitorId) {
        _selectedVisitor = updated;
      }

      _detailErrorMessage = null;
      return true;
    } on AppException catch (e) {
      _detailErrorMessage = e.message;
      return false;
    } catch (_) {
      _detailErrorMessage = 'Something went wrong. Please try again.';
      return false;
    } finally {
      _isActionInProgress = false;
      notifyListeners();
    }
  }

  // ── Exit (Security) ─────────────────────────────────────────

  Future<bool> registerExit(String visitorId) async {
    _isActionInProgress = true;
    notifyListeners();

    try {
      final updated = await _repository.registerExit(visitorId);

      if (_selectedVisitor?.id == visitorId) {
        _selectedVisitor = updated;
      }

      _detailErrorMessage = null;
      return true;
    } on AppException catch (e) {
      _detailErrorMessage = e.message;
      return false;
    } catch (_) {
      _detailErrorMessage = 'Something went wrong. Please try again.';
      return false;
    } finally {
      _isActionInProgress = false;
      notifyListeners();
    }
  }
}