/// Mirrors backend's MaintenanceImageDto.
class MaintenanceImageModel {
  final String id;
  final String imageUrl;
  final DateTime uploadedAt;

  MaintenanceImageModel({
    required this.id,
    required this.imageUrl,
    required this.uploadedAt,
  });

  factory MaintenanceImageModel.fromJson(Map<String, dynamic> json) {
    return MaintenanceImageModel(
      id: json['id'],
      imageUrl: json['imageUrl'] ?? '',
      uploadedAt: DateTime.parse(json['uploadedAt']),
    );
  }
}

/// Mirrors backend's MaintenanceDetailDto — full record with images.
class MaintenanceDetailModel {
  final String id;
  final String residentId;
  final String residentName;
  final String apartmentNumber;
  final String block;
  final String category;
  final String priority;
  final String title;
  final String description;
  final String status;
  final String? assignedToName;
  final DateTime? assignedAt;
  final DateTime? resolvedAt;
  final String? resolutionNote;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<MaintenanceImageModel> images;

  MaintenanceDetailModel({
    required this.id,
    required this.residentId,
    required this.residentName,
    required this.apartmentNumber,
    required this.block,
    required this.category,
    required this.priority,
    required this.title,
    required this.description,
    required this.status,
    this.assignedToName,
    this.assignedAt,
    this.resolvedAt,
    this.resolutionNote,
    required this.createdAt,
    required this.updatedAt,
    required this.images,
  });

  factory MaintenanceDetailModel.fromJson(Map<String, dynamic> json) {
    return MaintenanceDetailModel(
      id: json['id'],
      residentId: json['residentId'],
      residentName: json['residentName'] ?? '',
      apartmentNumber: json['apartmentNumber'] ?? '',
      block: json['block'] ?? '',
      category: json['category'] ?? '',
      priority: json['priority'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? '',
      assignedToName: json['assignedToName'],
      assignedAt: json['assignedAt'] != null ? DateTime.parse(json['assignedAt']) : null,
      resolvedAt: json['resolvedAt'] != null ? DateTime.parse(json['resolvedAt']) : null,
      resolutionNote: json['resolutionNote'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      images: (json['images'] as List? ?? [])
          .map((e) => MaintenanceImageModel.fromJson(e))
          .toList(),
    );
  }
}

/// Slim version for list screens — mirrors MaintenanceListDto.
class MaintenanceListModel {
  final String id;
  final String category;
  final String priority;
  final String title;
  final String status;
  final DateTime createdAt;

  MaintenanceListModel({
    required this.id,
    required this.category,
    required this.priority,
    required this.title,
    required this.status,
    required this.createdAt,
  });

  factory MaintenanceListModel.fromJson(Map<String, dynamic> json) {
    return MaintenanceListModel(
      id: json['id'],
      category: json['category'] ?? '',
      priority: json['priority'] ?? '',
      title: json['title'] ?? '',
      status: json['status'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

/// Request body for POST /maintenance.
class CreateMaintenanceRequest {
  final String category;
  final String priority;
  final String title;
  final String description;

  CreateMaintenanceRequest({
    required this.category,
    required this.priority,
    required this.title,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
    'category': category,
    'priority': priority,
    'title': title,
    'description': description,
  };
}

/// Request body for PATCH /maintenance/{id}/status.
class UpdateMaintenanceStatusRequest {
  final String status;
  final String? resolutionNote;

  UpdateMaintenanceStatusRequest({required this.status, this.resolutionNote});

  Map<String, dynamic> toJson() => {
    'status': status,
    'resolutionNote': resolutionNote,
  };
}

/// Request body for PATCH /maintenance/{id}/assign.
class AssignMaintenanceRequest {
  final String assignedTo;

  AssignMaintenanceRequest({required this.assignedTo});

  Map<String, dynamic> toJson() => {'assignedTo': assignedTo};
}

/// Filter params for GET /maintenance — mirrors query string options.
class MaintenanceFilter {
  final String? status;
  final String? category;
  final int page;
  final int pageSize;

  MaintenanceFilter({
    this.status,
    this.category,
    this.page = 1,
    this.pageSize = 10,
  });

  Map<String, dynamic> toQueryParams() => {
    if (status != null) 'status': status,
    if (category != null) 'category': category,
    'page': page,
    'pageSize': pageSize,
  };
}