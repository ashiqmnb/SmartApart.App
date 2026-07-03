/// Mirrors backend's FamilyMemberDto.
class FamilyMemberModel {
  final String id;
  final String residentId;
  final String fullName;
  final String relationship;
  final String? phoneNumber;
  final DateTime? dateOfBirth;
  final DateTime createdAt;

  FamilyMemberModel({
    required this.id,
    required this.residentId,
    required this.fullName,
    required this.relationship,
    this.phoneNumber,
    this.dateOfBirth,
    required this.createdAt,
  });

  factory FamilyMemberModel.fromJson(Map<String, dynamic> json) {
    return FamilyMemberModel(
      id: json['id'],
      residentId: json['residentId'],
      fullName: json['fullName'] ?? '',
      relationship: json['relationship'] ?? '',
      phoneNumber: json['phoneNumber'],
      dateOfBirth: json['dateOfBirth'] != null ? DateTime.parse(json['dateOfBirth']) : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

/// Shared shape for both Add and Update requests — backend DTOs
/// for AddFamilyMemberRequestDto / UpdateFamilyMemberRequestDto
/// have identical fields.
class FamilyMemberRequest {
  final String fullName;
  final String relationship;
  final String? phoneNumber;
  final DateTime? dateOfBirth;

  FamilyMemberRequest({
    required this.fullName,
    required this.relationship,
    this.phoneNumber,
    this.dateOfBirth,
  });

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'relationship': relationship,
    'phoneNumber': phoneNumber,
    'dateOfBirth': dateOfBirth?.toIso8601String().split('T').first,
  };
}