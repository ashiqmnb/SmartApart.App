import 'package:flutter/material.dart';
import '../../../../core/errors/app_exception.dart';
import '../../data/models/announcement_models.dart';
import '../../data/repositories/announcement_repository.dart';

/// State management for Announcements — same ChangeNotifier pattern
/// as MaintenanceProvider/ComplaintProvider. Keeps published feed and
/// admin drafts as separate lists since they're fetched from different
/// endpoints and shown on different screens.
class AnnouncementProvider extends ChangeNotifier {
  final AnnouncementRepository _repo = AnnouncementRepository();

  // ── Published feed state ────────────────────────────────────
  List<AnnouncementListModel> _published = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  bool _hasMore = true;
  String? _noticeTypeFilter;

  // ── Admin drafts state ───────────────────────────────────────
  List<AnnouncementListModel> _drafts = [];
  bool _isDraftsLoading = false;

  // ── Detail state ─────────────────────────────────────────────
  AnnouncementDetailModel? _selected;
  bool _isDetailLoading = false;

  // ── Action state ──────────────────────────────────────────────
  bool _isSubmitting = false;
  String? _errorMessage;

  List<AnnouncementListModel> get published => _published;
  List<AnnouncementListModel> get drafts => _drafts;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get isDraftsLoading => _isDraftsLoading;
  bool get hasMore => _hasMore;
  String? get noticeTypeFilter => _noticeTypeFilter;
  AnnouncementDetailModel? get selected => _selected;
  bool get isDetailLoading => _isDetailLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ── Fetch Published (first page / refresh) ───────────────────

  Future<void> fetchPublished({String? noticeType}) async {
    _noticeTypeFilter = noticeType;
    _currentPage = 1;
    _hasMore = true;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repo.getPublished(AnnouncementFilter(
        noticeType: _noticeTypeFilter,
        page: _currentPage,
      ));
      _published = result.items;
      _hasMore = result.hasNext;
    } on AppException catch (e) {
      _errorMessage = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMore() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final result = await _repo.getPublished(AnnouncementFilter(
        noticeType: _noticeTypeFilter,
        page: nextPage,
      ));
      _published.addAll(result.items);
      _currentPage = nextPage;
      _hasMore = result.hasNext;
    } on AppException catch (e) {
      _errorMessage = e.message;
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // ── Fetch Drafts (Admin) ──────────────────────────────────────

  Future<void> fetchDrafts() async {
    _isDraftsLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repo.getDrafts();
      _drafts = result.items;
    } on AppException catch (e) {
      _errorMessage = e.message;
    } finally {
      _isDraftsLoading = false;
      notifyListeners();
    }
  }

  // ── Detail ────────────────────────────────────────────────────

  Future<void> fetchDetail(String id) async {
    _isDetailLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selected = await _repo.getById(id);
    } on AppException catch (e) {
      _errorMessage = e.message;
    } finally {
      _isDetailLoading = false;
      notifyListeners();
    }
  }

  void clearSelected() {
    _selected = null;
  }

  // ── Create ────────────────────────────────────────────────────

  Future<String?> createAnnouncement({
    required String title,
    required String body,
    required String noticeType,
    DateTime? scheduledAt,
    List<String> attachmentPaths = const [],
    String attachmentType = 'Image',
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final created = await _repo.create(CreateAnnouncementRequest(
        title: title,
        body: body,
        noticeType: noticeType,
        scheduledAt: scheduledAt,
      ));

      if (attachmentPaths.isNotEmpty) {
        await _repo.uploadAttachments(created.id, attachmentPaths, attachmentType);
      }

      return created.id;
    } on AppException catch (e) {
      _errorMessage = e.message;
      return null;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  // ── Update (Edit) ─────────────────────────────────────────────

  Future<bool> updateAnnouncement(
      String id, {
        required String title,
        required String body,
        required String noticeType,
        DateTime? scheduledAt,
        List<String> newAttachmentPaths = const [],
        String attachmentType = 'Image',
      }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repo.update(id, CreateAnnouncementRequest(
        title: title,
        body: body,
        noticeType: noticeType,
        scheduledAt: scheduledAt,
      ));

      if (newAttachmentPaths.isNotEmpty) {
        await _repo.uploadAttachments(id, newAttachmentPaths, attachmentType);
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

  // ── Delete ────────────────────────────────────────────────────

  Future<bool> deleteAnnouncement(String id) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repo.deleteAnnouncement(id);
      _drafts.removeWhere((a) => a.id == id);
      _published.removeWhere((a) => a.id == id);
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  // ── Publish Draft ─────────────────────────────────────────────

  Future<bool> publishDraft(String id) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repo.publishDraft(id);
      _drafts.removeWhere((a) => a.id == id);
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