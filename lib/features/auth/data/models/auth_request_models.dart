/// Request payloads for the /auth endpoints. Each class mirrors a
/// backend RequestDto — toJson() produces the exact body shape the
/// controller's [FromBody] binding expects.
library;

class RegisterRequest {
  final String fullName;
  final String email;
  final String phoneNumber;
  final String password;
  final String confirmPassword;
  final String role;

  RegisterRequest({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.password,
    required this.confirmPassword,
    required this.role,
  });

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'email': email,
    'phoneNumber': phoneNumber,
    'password': password,
    'confirmPassword': confirmPassword,
    'role': role,
  };
}

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class VerifyOtpRequest {
  final String phoneNumber;
  final String otpCode;
  final String purpose;

  VerifyOtpRequest({
    required this.phoneNumber,
    required this.otpCode,
    required this.purpose,
  });

  Map<String, dynamic> toJson() => {
    'phoneNumber': phoneNumber,
    'otpCode': otpCode,
    'purpose': purpose,
  };
}

class ResendOtpRequest {
  final String phoneNumber;
  final String purpose;

  ResendOtpRequest({required this.phoneNumber, required this.purpose});

  Map<String, dynamic> toJson() => {'phoneNumber': phoneNumber, 'purpose': purpose};
}

class ForgotPasswordRequest {
  final String phoneNumber;

  ForgotPasswordRequest({required this.phoneNumber});

  Map<String, dynamic> toJson() => {'phoneNumber': phoneNumber};
}

class ResetPasswordRequest {
  final String phoneNumber;
  final String otpCode;
  final String newPassword;
  final String confirmPassword;

  ResetPasswordRequest({
    required this.phoneNumber,
    required this.otpCode,
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() => {
    'phoneNumber': phoneNumber,
    'otpCode': otpCode,
    'newPassword': newPassword,
    'confirmPassword': confirmPassword,
  };
}

class ChangePasswordRequest {
  final String oldPassword;
  final String newPassword;
  final String confirmPassword;

  ChangePasswordRequest({
    required this.oldPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() => {
    'oldPassword': oldPassword,
    'newPassword': newPassword,
    'confirmPassword': confirmPassword,
  };
}

class RefreshTokenRequest {
  final String refreshToken;

  RefreshTokenRequest({required this.refreshToken});

  Map<String, dynamic> toJson() => {'refreshToken': refreshToken};
}