/// Mirrors backend's UserProfileDto — GET /api/profile response.
class UserProfileModel {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String role;
  final String? profilePhotoUrl;
  final bool isActive;
  final DateTime createdAt;

  UserProfileModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.role,
    this.profilePhotoUrl,
    required this.isActive,
    required this.createdAt,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'],
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      role: json['role'] ?? '',
      profilePhotoUrl: json['profilePhotoUrl'],
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

/// Request body for PUT /api/profile — mirrors UpdateProfileRequestDto.
class UpdateProfileRequest {
  final String fullName;
  final String phoneNumber;

  UpdateProfileRequest({required this.fullName, required this.phoneNumber});

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'phoneNumber': phoneNumber,
  };
}