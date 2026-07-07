import 'package:flutter/material.dart';
import '../../../../core/errors/app_exception.dart';
import '../../data/models/amenity_models.dart';
import '../../data/repositories/amenity_repository.dart';

/// State management for Amenities. No pagination on the list (small,
/// fixed set of community amenities per the repository design), so
/// this is simpler than Maintenance/Complaint/Announcement providers —
/// just a flat fetch-all.
class AmenityProvider extends ChangeNotifier {
  final AmenityRepository _repo = AmenityRepository();

  // ── List state ───────────────────────────────────────────────
  List<AmenityListModel> _amenities = [];
  bool _isLoading = false;
  String? _errorMessage;

  // ── Detail state ─────────────────────────────────────────────
  AmenityDetailModel? _selected;
  bool _isDetailLoading = false;

  // ── Action state ──────────────────────────────────────────────
  bool _isSubmitting = false;

  List<AmenityListModel> get amenities => _amenities;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AmenityDetailModel? get selected => _selected;
  bool get isDetailLoading => _isDetailLoading;
  bool get isSubmitting => _isSubmitting;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ── Fetch All ────────────────────────────────────────────────

  Future<void> fetchAmenities() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _amenities = await _repo.getAll();
    } on AppException catch (e) {
      _errorMessage = e.message;
    } finally {
      _isLoading = false;
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

  Future<String?> createAmenity({
    required String name,
    required String description,
    required String location,
    required String openingTime,
    required String closingTime,
    String? rules,
    List<String> imagePaths = const [],
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final created = await _repo.create(CreateAmenityRequest(
        name: name,
        description: description,
        location: location,
        openingTime: openingTime,
        closingTime: closingTime,
        rules: rules,
      ));

      if (imagePaths.isNotEmpty) {
        await _repo.uploadImages(created.id, imagePaths);
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

  // ── Update ────────────────────────────────────────────────────

  Future<bool> updateAmenity(
      String id, {
        required String name,
        required String description,
        required String location,
        required String openingTime,
        required String closingTime,
        String? rules,
        List<String> newImagePaths = const [],
      }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repo.update(id, CreateAmenityRequest(
        name: name,
        description: description,
        location: location,
        openingTime: openingTime,
        closingTime: closingTime,
        rules: rules,
      ));

      if (newImagePaths.isNotEmpty) {
        await _repo.uploadImages(id, newImagePaths);
      }

      if (_selected != null) {
        await fetchDetail(id);
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

  // ── Delete Image ──────────────────────────────────────────────

  Future<bool> deleteImage(String amenityId, String imageId) async {
    try {
      await _repo.deleteImage(amenityId, imageId);
      if (_selected != null) {
        await fetchDetail(amenityId);
      }
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }

  // ── Update Availability ───────────────────────────────────────

  Future<bool> updateAvailability(String amenityId, String availability) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repo.updateAvailability(amenityId, UpdateAvailabilityRequest(availability: availability));
      if (_selected != null) {
        await fetchDetail(amenityId);
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

  // ── Delete Amenity ────────────────────────────────────────────

  Future<bool> deleteAmenity(String id) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repo.deleteAmenity(id);
      _amenities.removeWhere((a) => a.id == id);
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