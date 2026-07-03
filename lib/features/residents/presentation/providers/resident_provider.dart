import 'package:flutter/material.dart';
import '../../../../core/errors/app_exception.dart';
import '../../data/models/resident_models.dart';
import '../../data/repositories/resident_repository.dart';

/// Holds the logged-in resident's apartment/ownership record.
/// Distinct from ProfileProvider (name/phone/photo, role-agnostic) —
/// this is Resident-specific data (apartment, block, emergency contact).
class ResidentProvider extends ChangeNotifier {
  final ResidentRepository _repository = ResidentRepository();

  ResidentDetailModel? _resident;
  bool _isLoading = false;
  String? _errorMessage;

  ResidentDetailModel? get resident => _resident;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ── Fetch own resident profile ──────────────────────────────

  Future<void> fetchMyProfile() async {
    _setLoading(true);
    try {
      _resident = await _repository.getMyProfile();
      _errorMessage = null;
    } on AppException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Something went wrong. Please try again.';
    } finally {
      _setLoading(false);
    }
  }

  // ── Update apartment / emergency contact fields ─────────────

  Future<bool> updateResident(UpdateResidentRequest dto) async {
    if (_resident == null) {
      _errorMessage = 'Resident profile not loaded yet.';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    try {
      _resident = await _repository.updateResident(_resident!.id, dto);
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