import 'package:flutter/foundation.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../data/models/auth_request_models.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

/// Holds all auth-related state for the app. Equivalent to an
/// AuthContext + useReducer combo in React — screens call methods
/// here (login, register, etc.) and rebuild automatically when
/// notifyListeners() fires, the same way context consumers re-render
/// on state change.
class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepo = AuthRepository();

  bool _isLoading = false;
  String? _errorMessage;
  UserModel? _currentUser;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Clears any previous error — call this when a screen first opens
  /// or before a new submit, so old errors don't linger on screen.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ── Register ─────────────────────────────────────────────────

  Future<bool> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    required String confirmPassword,
    required String role,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _authRepo.register(RegisterRequest(
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
        confirmPassword: confirmPassword,
        role: role,
      ));
      return true;
    } on AppException catch (e) {
      _setError(e.message);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Verify OTP ───────────────────────────────────────────────

  Future<bool> verifyOtp({
    required String phoneNumber,
    required String otpCode,
    required String purpose,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _authRepo.verifyOtp(VerifyOtpRequest(
        phoneNumber: phoneNumber,
        otpCode: otpCode,
        purpose: purpose,
      ));
      return true;
    } on AppException catch (e) {
      _setError(e.message);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Resend OTP ───────────────────────────────────────────────

  Future<bool> resendOtp({required String phoneNumber, required String purpose}) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _authRepo.resendOtp(ResendOtpRequest(phoneNumber: phoneNumber, purpose: purpose));
      return true;
    } on AppException catch (e) {
      _setError(e.message);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Login ────────────────────────────────────────────────────

  Future<bool> login({required String email, required String password}) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final response = await _authRepo.login(LoginRequest(email: email, password: password));

      await SecureStorage.saveTokens(response.accessToken, response.refreshToken);
      await SecureStorage.saveRole(response.role);

      _currentUser = UserModel.fromAuthResponse(response);
      return true;
    } on AppException catch (e) {
      _setError(e.message);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Logout ───────────────────────────────────────────────────

  Future<void> logout() async {
    _setLoading(true);
    try {
      final refreshToken = await SecureStorage.getRefreshToken();
      if (refreshToken != null) {
        await _authRepo.logout(refreshToken);
      }
    } on AppException catch (_) {
      // Even if the server call fails (e.g. token already expired),
      // we still clear local state so the user can log out locally.
    } finally {
      await SecureStorage.clearAll();
      _currentUser = null;
      _setLoading(false);
    }
  }

  // ── Forgot Password ──────────────────────────────────────────

  Future<bool> forgotPassword({required String phoneNumber}) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _authRepo.forgotPassword(ForgotPasswordRequest(phoneNumber: phoneNumber));
      return true;
    } on AppException catch (e) {
      _setError(e.message);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Reset Password ───────────────────────────────────────────

  Future<bool> resetPassword({
    required String phoneNumber,
    required String otpCode,
    required String newPassword,
    required String confirmPassword,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _authRepo.resetPassword(ResetPasswordRequest(
        phoneNumber: phoneNumber,
        otpCode: otpCode,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      ));
      return true;
    } on AppException catch (e) {
      _setError(e.message);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Change Password ──────────────────────────────────────────

  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _authRepo.changePassword(ChangePasswordRequest(
        oldPassword: oldPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      ));
      return true;
    } on AppException catch (e) {
      _setError(e.message);
      return false;
    } finally {
      _setLoading(false);
    }
  }
}