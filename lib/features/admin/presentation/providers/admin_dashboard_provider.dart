import 'package:flutter/foundation.dart';
import '../../../../core/errors/app_exception.dart';
import '../../data/models/admin_dashboard_models.dart';
import '../../data/repositories/admin_dashboard_repository.dart';

class AdminDashboardProvider extends ChangeNotifier {
  final _repository = AdminDashboardRepository();

  AdminDashboardSummary? _summary;
  bool _isLoading = false;
  String? _errorMessage;

  AdminDashboardSummary? get summary => _summary;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchSummary() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _summary = await _repository.fetchSummary();
    } on AppException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Something went wrong. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}