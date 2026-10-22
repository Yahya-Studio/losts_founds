enum ReportStatus {
  open,
  contacted,
  closed;

  String get displayName {
    switch (this) {
      case ReportStatus.open:
        return 'مفقود';
      case ReportStatus.contacted:
        return 'قيد التواصل';
      case ReportStatus.closed:
        return 'مغلق';
    }
  }

  static ReportStatus fromString(String status) {
    switch (status) {
      case 'open':
        return ReportStatus.open;
      case 'contacted':
        return ReportStatus.contacted;
      case 'closed':
        return ReportStatus.closed;
      default:
        return ReportStatus.open;
    }
  }
}

class Report {
  final String id;
  final String ownerId;
  final String itemName;
  final String description;
  final String location;
  final String? notes;
  final ReportStatus status;
  final String ownerPhone;
  final String ownerName;
  final DateTime createdAt;
  final DateTime updatedAt;

  Report({
    required this.id,
    required this.ownerId,
    required this.itemName,
    required this.description,
    required this.location,
    this.notes,
    required this.status,
    required this.ownerPhone,
    required this.ownerName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      itemName: json['item_name'] as String,
      description: json['description'] as String,
      location: json['location'] as String,
      notes: json['notes'] as String?,
      status: ReportStatus.fromString(json['status'] as String),
      ownerPhone: json['owner_phone'] as String,
      ownerName: json['owner_name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'item_name': itemName,
      'description': description,
      'location': location,
      'notes': notes,
      'status': status.name,
      'owner_phone': ownerPhone,
      'owner_name': ownerName,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Report copyWith({
    String? id,
    String? ownerId,
    String? itemName,
    String? description,
    String? location,
    String? notes,
    ReportStatus? status,
    String? ownerPhone,
    String? ownerName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Report(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      itemName: itemName ?? this.itemName,
      description: description ?? this.description,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      ownerPhone: ownerPhone ?? this.ownerPhone,
      ownerName: ownerName ?? this.ownerName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
