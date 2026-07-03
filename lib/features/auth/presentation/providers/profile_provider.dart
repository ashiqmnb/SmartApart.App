import 'package:flutter/material.dart';
import '../../../../core/errors/app_exception.dart';
import '../../data/models/user_profile_models.dart';
import '../../data/repositories/profile_repository.dart';

/// Holds the logged-in user's own profile (name, phone, photo).
/// Separate from ResidentProvider — this is role-agnostic (Admin,
/// Resident, Security all have a UserProfileModel).
class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _repository = ProfileRepository();

  UserProfileModel? _profile;
  bool _isLoading = false;
  String? _errorMessage;

  UserProfileModel? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ── Fetch ────────────────────────────────────────────────────

  Future<void> fetchProfile() async {
    _setLoading(true);
    try {
      _profile = await _repository.getProfile();
      _errorMessage = null;
    } on AppException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Something went wrong. Please try again.';
    } finally {
      _setLoading(false);
    }
  }

  // ── Update name/phone ────────────────────────────────────────

  Future<bool> updateProfile({
    required String fullName,
    required String phoneNumber,
  }) async {
    _setLoading(true);
    try {
      _profile = await _repository.updateProfile(
        UpdateProfileRequest(fullName: fullName, phoneNumber: phoneNumber),
      );
      _errorMessage = null;
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage = 'Something went wrong. Please try again.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Update photo ─────────────────────────────────────────────

  Future<bool> updatePhoto(String filePath) async {
    _setLoading(true);
    try {
      _profile = await _repository.updateProfilePhoto(filePath);
      _errorMessage = null;
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage = 'Something went wrong. Please try again.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Private helper ───────────────────────────────────────────

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}