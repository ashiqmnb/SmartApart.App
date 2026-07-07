/// Mirrors backend's AmenityImageDto.
class AmenityImageModel {
  final String id;
  final String imageUrl;
  final DateTime uploadedAt;

  AmenityImageModel({
    required this.id,
    required this.imageUrl,
    required this.uploadedAt,
  });

  factory AmenityImageModel.fromJson(Map<String, dynamic> json) {
    return AmenityImageModel(
      id: json['id'],
      imageUrl: json['imageUrl'] ?? '',
      uploadedAt: DateTime.parse(json['uploadedAt']),
    );
  }
}

/// Mirrors backend's AmenityDetailDto.
/// openingTime/closingTime come from backend's TimeOnly as "HH:mm:ss"
/// strings — kept as raw strings here rather than DateTime since
/// there's no calendar date attached to them.
class AmenityDetailModel {
  final String id;
  final String name;
  final String description;
  final String location;
  final String openingTime;
  final String closingTime;
  final String? rules;
  final String availability; // "Available" | "UnderMaintenance" | "TemporarilyClosed"
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<AmenityImageModel> images;

  AmenityDetailModel({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.openingTime,
    required this.closingTime,
    this.rules,
    required this.availability,
    required this.createdAt,
    required this.updatedAt,
    required this.images,
  });

  factory AmenityDetailModel.fromJson(Map<String, dynamic> json) {
    return AmenityDetailModel(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      openingTime: json['openingTime'] ?? '',
      closingTime: json['closingTime'] ?? '',
      rules: json['rules'],
      availability: json['availability'] ?? 'Available',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      images: (json['images'] as List? ?? [])
          .map((e) => AmenityImageModel.fromJson(e))
          .toList(),
    );
  }
}

/// Slim version for grid/list screens.
class AmenityListModel {
  final String id;
  final String name;
  final String location;
  final String availability;
  final String? thumbnailUrl;

  AmenityListModel({
    required this.id,
    required this.name,
    required this.location,
    required this.availability,
    this.thumbnailUrl,
  });

  factory AmenityListModel.fromJson(Map<String, dynamic> json) {
    return AmenityListModel(
      id: json['id'],
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      availability: json['availability'] ?? 'Available',
      thumbnailUrl: json['thumbnailUrl'] ?? json['imageUrl'],
    );
  }
}

/// Request body for POST /amenities and PUT /amenities/{id}.
/// openingTime/closingTime sent as "HH:mm:ss" strings matching
/// backend's TimeOnly binding.
class CreateAmenityRequest {
  final String name;
  final String description;
  final String location;
  final String openingTime;
  final String closingTime;
  final String? rules;

  CreateAmenityRequest({
    required this.name,
    required this.description,
    required this.location,
    required this.openingTime,
    required this.closingTime,
    this.rules,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'location': location,
    'openingTime': openingTime,
    'closingTime': closingTime,
    'rules': rules,
  };
}

/// Request body for PATCH /amenities/{id}/availability.
class UpdateAvailabilityRequest {
  final String availability;

  UpdateAvailabilityRequest({required this.availability});

  Map<String, dynamic> toJson() => {'availability': availability};
}