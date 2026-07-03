/// Full resident profile — own profile view uses this.
/// Mirrors backend's ResidentDetailDto.
class ResidentDetailModel {
  final String id;
  final String userId;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String? profilePhotoUrl;
  final String apartmentNumber;
  final String block;
  final int floor;
  final String ownershipType; // "Owner" or "Renter"
  final DateTime moveInDate;
  final DateTime? moveOutDate;
  final String? emergencyContactName;
  final String? emergencyContactPhone;

  ResidentDetailModel({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.profilePhotoUrl,
    required this.apartmentNumber,
    required this.block,
    required this.floor,
    required this.ownershipType,
    required this.moveInDate,
    this.moveOutDate,
    this.emergencyContactName,
    this.emergencyContactPhone,
  });

  factory ResidentDetailModel.fromJson(Map<String, dynamic> json) {
    return ResidentDetailModel(
      id: json['id'],
      userId: json['userId'],
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      profilePhotoUrl: json['profilePhotoUrl'],
      apartmentNumber: json['apartmentNumber'] ?? '',
      block: json['block'] ?? '',
      floor: json['floor'] ?? 0,
      ownershipType: json['ownershipType'] ?? '',
      moveInDate: DateTime.parse(json['moveInDate']),
      moveOutDate: json['moveOutDate'] != null ? DateTime.parse(json['moveOutDate']) : null,
      emergencyContactName: json['emergencyContactName'],
      emergencyContactPhone: json['emergencyContactPhone'],
    );
  }
}

/// Slim resident info — used in directory listings (Step 7).
/// Mirrors backend's ResidentPublicDto.
class ResidentPublicModel {
  final String id;
  final String fullName;
  final String block;
  final String apartmentNumber;
  final int floor;
  final String? profilePhotoUrl;

  ResidentPublicModel({
    required this.id,
    required this.fullName,
    required this.block,
    required this.apartmentNumber,
    required this.floor,
    this.profilePhotoUrl,
  });

  factory ResidentPublicModel.fromJson(Map<String, dynamic> json) {
    return ResidentPublicModel(
      id: json['id'],
      fullName: json['fullName'] ?? '',
      block: json['block'] ?? '',
      apartmentNumber: json['apartmentNumber'] ?? '',
      floor: json['floor'] ?? 0,
      profilePhotoUrl: json['profilePhotoUrl'],
    );
  }
}

/// Request body for PUT /api/residents/{id} — apartment + emergency
/// contact fields. Mirrors backend's UpdateResidentRequestDto.
class UpdateResidentRequest {
  final String apartmentNumber;
  final String block;
  final int floor;
  final String ownershipType;
  final DateTime moveInDate;
  final DateTime? moveOutDate;
  final String? emergencyContactName;
  final String? emergencyContactPhone;

  UpdateResidentRequest({
    required this.apartmentNumber,
    required this.block,
    required this.floor,
    required this.ownershipType,
    required this.moveInDate,
    this.moveOutDate,
    this.emergencyContactName,
    this.emergencyContactPhone,
  });

  Map<String, dynamic> toJson() => {
    'apartmentNumber': apartmentNumber,
    'block': block,
    'floor': floor,
    'ownershipType': ownershipType,
    // DateOnly on the backend — send date-only ISO string
    'moveInDate': moveInDate.toIso8601String().split('T').first,
    'moveOutDate': moveOutDate?.toIso8601String().split('T').first,
    'emergencyContactName': emergencyContactName,
    'emergencyContactPhone': emergencyContactPhone,
  };
}