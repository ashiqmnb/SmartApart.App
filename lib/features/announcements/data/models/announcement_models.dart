/// Mirrors backend's AnnouncementAttachmentDto.
class AnnouncementAttachmentModel {
  final String id;
  final String fileUrl;
  final String fileType; // "Image" | "Poster" | "Banner"
  final DateTime uploadedAt;

  AnnouncementAttachmentModel({
    required this.id,
    required this.fileUrl,
    required this.fileType,
    required this.uploadedAt,
  });

  factory AnnouncementAttachmentModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementAttachmentModel(
      id: json['id'],
      fileUrl: json['fileUrl'] ?? '',
      fileType: json['fileType'] ?? 'Image',
      uploadedAt: DateTime.parse(json['uploadedAt']),
    );
  }
}

/// Mirrors backend's AnnouncementDetailDto — full record with attachments.
class AnnouncementDetailModel {
  final String id;
  final String createdByName;
  final String title;
  final String body;
  final String noticeType; // "SocietyNotice" | "MaintenanceNotice" | "EmergencyAlert" | "EventAnnouncement"
  final bool isPublished;
  final DateTime? scheduledAt;
  final DateTime? publishedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<AnnouncementAttachmentModel> attachments;

  AnnouncementDetailModel({
    required this.id,
    required this.createdByName,
    required this.title,
    required this.body,
    required this.noticeType,
    required this.isPublished,
    this.scheduledAt,
    this.publishedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.attachments,
  });

  factory AnnouncementDetailModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementDetailModel(
      id: json['id'],
      createdByName: json['createdByName'] ?? json['creatorName'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      noticeType: json['noticeType'] ?? '',
      isPublished: json['isPublished'] ?? false,
      scheduledAt: json['scheduledAt'] != null ? DateTime.parse(json['scheduledAt']) : null,
      publishedAt: json['publishedAt'] != null ? DateTime.parse(json['publishedAt']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      attachments: (json['attachments'] as List? ?? [])
          .map((e) => AnnouncementAttachmentModel.fromJson(e))
          .toList(),
    );
  }
}

/// Slim version for feed/list screens.
class AnnouncementListModel {
  final String id;
  final String title;
  final String noticeType;
  final bool isPublished;
  final DateTime? scheduledAt;
  final DateTime? publishedAt;
  final DateTime createdAt;

  AnnouncementListModel({
    required this.id,
    required this.title,
    required this.noticeType,
    required this.isPublished,
    this.scheduledAt,
    this.publishedAt,
    required this.createdAt,
  });

  factory AnnouncementListModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementListModel(
      id: json['id'],
      title: json['title'] ?? '',
      noticeType: json['noticeType'] ?? '',
      isPublished: json['isPublished'] ?? false,
      scheduledAt: json['scheduledAt'] != null ? DateTime.parse(json['scheduledAt']) : null,
      publishedAt: json['publishedAt'] != null ? DateTime.parse(json['publishedAt']) : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

/// Request body for POST /announcements and PUT /announcements/{id}.
/// If scheduledAt is null, backend publishes immediately.
class CreateAnnouncementRequest {
  final String title;
  final String body;
  final String noticeType;
  final DateTime? scheduledAt;

  CreateAnnouncementRequest({
    required this.title,
    required this.body,
    required this.noticeType,
    this.scheduledAt,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'body': body,
    'noticeType': noticeType,
    'scheduledAt': scheduledAt?.toUtc().toIso8601String(),
  };
}

/// Filter params for GET /announcements.
class AnnouncementFilter {
  final String? noticeType;
  final int page;
  final int pageSize;

  AnnouncementFilter({this.noticeType, this.page = 1, this.pageSize = 10});

  Map<String, dynamic> toQueryParams() => {
    if (noticeType != null) 'noticeType': noticeType,
    'page': page,
    'pageSize': pageSize,
  };
}