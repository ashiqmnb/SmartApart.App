import 'package:flutter/material.dart';
import '../../../../core/errors/app_exception.dart';
import '../../data/models/family_member_models.dart';
import '../../data/repositories/resident_repository.dart';

/// Manages the family member list for the logged-in resident.
/// Uses optimistic-friendly patterns: after add/update/delete succeeds,
/// the local list is updated directly instead of re-fetching everything
/// (React comparison: like updating local state after a mutation instead
/// of always refetching the whole list).
class FamilyMemberProvider extends ChangeNotifier {
  final ResidentRepository _repository = ResidentRepository();

  List<FamilyMemberModel> _members = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<FamilyMemberModel> get members => _members;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ── Fetch list ───────────────────────────────────────────────

  Future<void> fetchFamilyMembers(String residentId) async {
    _setLoading(true);
    try {
      _members = await _repository.getFamilyMembers(residentId);
      _errorMessage = null;
    } on AppException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Something went wrong. Please try again.';
    } finally {
      _setLoading(false);
    }
  }

  // ── Add ──────────────────────────────────────────────────────

  Future<bool> addFamilyMember(String residentId, FamilyMemberRequest dto) async {
    _setLoading(true);
    try {
      final newMember = await _repository.addFamilyMember(residentId, dto);
      _members = [..._members, newMember];
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

  // ── Update ───────────────────────────────────────────────────

  Future<bool> updateFamilyMember(
      String residentId,
      String memberId,
      FamilyMemberRequest dto,
      ) async {
    _setLoading(true);
    try {
      final updated = await _repository.updateFamilyMember(residentId, memberId, dto);
      _members = _members.map((m) => m.id == memberId ? updated : m).toList();
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

  // ── Delete ───────────────────────────────────────────────────

  Future<bool> deleteFamilyMember(String residentId, String memberId) async {
    _setLoading(true);
    try {
      await _repository.deleteFamilyMember(residentId, memberId);
      _members = _members.where((m) => m.id != memberId).toList();
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