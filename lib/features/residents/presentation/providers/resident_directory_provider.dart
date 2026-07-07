import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/errors/app_exception.dart';
import '../../data/models/resident_models.dart';
import '../../data/repositories/resident_repository.dart';

/// Admin-only: manages the resident directory list, pagination, and search.
class ResidentDirectoryProvider extends ChangeNotifier {
  final ResidentRepository _repository = ResidentRepository();

  List<ResidentDetailModel> _residents = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;

  int _page = 1;
  static const _pageSize = 10;
  bool _hasNext = true;

  String _searchQuery = '';
  Timer? _debounce;

  List<ResidentDetailModel> get residents => _residents;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasNext => _hasNext;
  String? get errorMessage => _errorMessage;
  bool get isSearching => _searchQuery.isNotEmpty;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ── Initial load / refresh ──────────────────────────────────────

  Future<void> loadFirstPage() async {
    _page = 1;
    _hasNext = true;
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _repository.getAllResidents(page: _page, pageSize: _pageSize);
      _residents = result.items;
      _hasNext = result.hasNext;
      _errorMessage = null;
    } on AppException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Something went wrong. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Load more (pagination) ──────────────────────────────────────

  Future<void> loadNextPage() async {
    if (_isLoadingMore || !_hasNext || isSearching) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = _page + 1;
      final result = await _repository.getAllResidents(page: nextPage, pageSize: _pageSize);
      _residents = [..._residents, ...result.items];
      _page = nextPage;
      _hasNext = result.hasNext;
    } on AppException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Something went wrong. Please try again.';
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // ── Search (debounced 300ms, per dev plan) ───────────────────────

  void onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _searchQuery = query.trim();
      if (_searchQuery.isEmpty) {
        loadFirstPage();
      } else {
        _runSearch(_searchQuery);
      }
    });
  }

  Future<void> _runSearch(String query) async {
    _isLoading = true;
    notifyListeners();

    try {
      _residents = await _repository.searchResidents(query);
      _errorMessage = null;
    } on AppException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Something went wrong. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}