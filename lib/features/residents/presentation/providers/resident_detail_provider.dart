import 'package:flutter/material.dart';
import '../../../../core/errors/app_exception.dart';
import '../../data/models/resident_models.dart';
import '../../data/repositories/resident_repository.dart';

/// Admin-only: holds a single resident's full detail for the detail screen.
class ResidentDetailProvider extends ChangeNotifier {
  final ResidentRepository _repository = ResidentRepository();

  ResidentDetailModel? _resident;
  bool _isLoading = false;
  String? _errorMessage;

  ResidentDetailModel? get resident => _resident;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchResident(String residentId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _resident = await _repository.getResidentById(residentId);
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
}