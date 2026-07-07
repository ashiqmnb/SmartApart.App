/// Mirrors backend's ComplaintImageDto.
class ComplaintImageModel {
  final String id;
  final String imageUrl;
  final DateTime uploadedAt;

  ComplaintImageModel({
    required this.id,
    required this.imageUrl,
    required this.uploadedAt,
  });

  factory ComplaintImageModel.fromJson(Map<String, dynamic> json) {
    return ComplaintImageModel(
      id: json['id'],
      imageUrl: json['imageUrl'] ?? '',
      uploadedAt: DateTime.parse(json['uploadedAt']),
    );
  }
}

/// Mirrors backend's ComplaintDetailDto.
/// Note: when complaintType == "Anonymous", backend returns
/// reporterName as "Anonymous" and omits residentId — handle
/// nullable residentId here accordingly.
class ComplaintDetailModel {
  final String id;
  final String? residentId;
  final String reporterName;
  final String category;
  final String complaintType; // "Normal" or "Anonymous"
  final String title;
  final String description;
  final String status;
  final String? resolutionNote;
  final DateTime? resolvedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ComplaintImageModel> images;

  ComplaintDetailModel({
    required this.id,
    this.residentId,
    required this.reporterName,
    required this.category,
    required this.complaintType,
    required this.title,
    required this.description,
    required this.status,
    this.resolutionNote,
    this.resolvedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.images,
  });

  factory ComplaintDetailModel.fromJson(Map<String, dynamic> json) {
    return ComplaintDetailModel(
      id: json['id'],
      residentId: json['residentId'],
      reporterName: json['reporterName'] ?? json['residentName'] ?? 'Anonymous',
      category: json['category'] ?? '',
      complaintType: json['complaintType'] ?? 'Normal',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? '',
      resolutionNote: json['resolutionNote'],
      resolvedAt: json['resolvedAt'] != null ? DateTime.parse(json['resolvedAt']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      images: (json['images'] as List? ?? [])
          .map((e) => ComplaintImageModel.fromJson(e))
          .toList(),
    );
  }
}

/// Slim version for list screens.
class ComplaintListModel {
  final String id;
  final String category;
  final String complaintType;
  final String title;
  final String status;
  final DateTime createdAt;

  ComplaintListModel({
    required this.id,
    required this.category,
    required this.complaintType,
    required this.title,
    required this.status,
    required this.createdAt,
  });

  factory ComplaintListModel.fromJson(Map<String, dynamic> json) {
    return ComplaintListModel(
      id: json['id'],
      category: json['category'] ?? '',
      complaintType: json['complaintType'] ?? 'Normal',
      title: json['title'] ?? '',
      status: json['status'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

/// Request body for POST /complaints.
class CreateComplaintRequest {
  final String category;
  final String complaintType; // "Normal" or "Anonymous"
  final String title;
  final String description;

  CreateComplaintRequest({
    required this.category,
    required this.complaintType,
    required this.title,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
    'category': category,
    'complaintType': complaintType,
    'title': title,
    'description': description,
  };
}

/// Request body for PATCH /complaints/{id}/status.
class UpdateComplaintStatusRequest {
  final String status;
  final String? resolutionNote;

  UpdateComplaintStatusRequest({required this.status, this.resolutionNote});

  Map<String, dynamic> toJson() => {
    'status': status,
    'resolutionNote': resolutionNote,
  };
}

/// Filter params for GET /complaints.
class ComplaintFilter {
  final String? status;
  final int page;
  final int pageSize;

  ComplaintFilter({this.status, this.page = 1, this.pageSize = 10});

  Map<String, dynamic> toQueryParams() => {
    if (status != null) 'status': status,
    'page': page,
    'pageSize': pageSize,
  };
}