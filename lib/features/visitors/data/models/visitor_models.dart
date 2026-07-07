/// Full visitor record — used for the detail screen.
/// Mirrors backend's VisitorDetailDto.
class VisitorDetailModel {
  final String id;
  final String residentId;
  final String residentName;
  final String apartmentNumber;
  final String block;
  final String securityId;
  final String securityName;
  final String visitorName;
  final String visitorPhone;
  final String purpose;
  final String? vehicleNumber;
  final DateTime entryTime;
  final DateTime? exitTime;
  final String approvalStatus; // "Pending" | "Approved" | "Rejected"
  final String? approvedBy;
  final DateTime? approvedAt;
  final DateTime createdAt;

  VisitorDetailModel({
    required this.id,
    required this.residentId,
    required this.residentName,
    required this.apartmentNumber,
    required this.block,
    required this.securityId,
    required this.securityName,
    required this.visitorName,
    required this.visitorPhone,
    required this.purpose,
    this.vehicleNumber,
    required this.entryTime,
    this.exitTime,
    required this.approvalStatus,
    this.approvedBy,
    this.approvedAt,
    required this.createdAt,
  });

  factory VisitorDetailModel.fromJson(Map<String, dynamic> json) {
    return VisitorDetailModel(
      id: json['id'],
      residentId: json['residentId'],
      residentName: json['residentName'] ?? '',
      apartmentNumber: json['apartmentNumber'] ?? '',
      block: json['block'] ?? '',
      securityId: json['securityId'] ?? '',
      securityName: json['securityName'] ?? '',
      visitorName: json['visitorName'] ?? '',
      visitorPhone: json['visitorPhone'] ?? '',
      purpose: json['purpose'] ?? '',
      vehicleNumber: json['vehicleNumber'],
      entryTime: DateTime.parse(json['entryTime']),
      exitTime: json['exitTime'] != null ? DateTime.parse(json['exitTime']) : null,
      approvalStatus: json['approvalStatus'] ?? 'Pending',
      approvedBy: json['approvedBy'],
      approvedAt: json['approvedAt'] != null ? DateTime.parse(json['approvedAt']) : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

/// Slim visitor info — used in the log/list screens.
/// Mirrors backend's VisitorListDto.
class VisitorListModel {
  final String id;
  final String visitorName;
  final String visitorPhone;
  final String purpose;
  final String residentName;
  final String apartmentNumber;
  final String block;
  final DateTime entryTime;
  final DateTime? exitTime;
  final String approvalStatus;
  final DateTime createdAt;

  VisitorListModel({
    required this.id,
    required this.visitorName,
    required this.visitorPhone,
    required this.purpose,
    required this.residentName,
    required this.apartmentNumber,
    required this.block,
    required this.entryTime,
    this.exitTime,
    required this.approvalStatus,
    required this.createdAt,
  });

  factory VisitorListModel.fromJson(Map<String, dynamic> json) {
    return VisitorListModel(
      id: json['id'],
      visitorName: json['visitorName'] ?? '',
      visitorPhone: json['visitorPhone'] ?? '',
      purpose: json['purpose'] ?? '',
      residentName: json['residentName'] ?? '',
      apartmentNumber: json['apartmentNumber'] ?? '',
      block: json['block'] ?? '',
      entryTime: DateTime.parse(json['entryTime']),
      exitTime: json['exitTime'] != null ? DateTime.parse(json['exitTime']) : null,
      approvalStatus: json['approvalStatus'] ?? 'Pending',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

/// Request body for POST /api/Visitor — Security registers a new visitor.
/// Mirrors backend's RegisterVisitorRequestDto.
class RegisterVisitorRequest {
  final String residentId;
  final String visitorName;
  final String visitorPhone;
  final String purpose;
  final String? vehicleNumber;

  RegisterVisitorRequest({
    required this.residentId,
    required this.visitorName,
    required this.visitorPhone,
    required this.purpose,
    this.vehicleNumber,
  });

  Map<String, dynamic> toJson() => {
    'residentId': residentId,
    'visitorName': visitorName,
    'visitorPhone': visitorPhone,
    'purpose': purpose,
    'vehicleNumber': vehicleNumber,
  };
}

/// Request body for PATCH .../approve and .../reject.
/// Mirrors backend's ApproveRejectVisitorRequestDto.
class ApproveRejectVisitorRequest {
  final String? reason;
  ApproveRejectVisitorRequest({this.reason});

  Map<String, dynamic> toJson() => {'reason': reason};
}