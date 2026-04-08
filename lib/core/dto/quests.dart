import 'package:quester_client/core/data/data_tables.dart';
/*
Server data model for reference:
class CreateQuestRequest(BaseModel):
    group_public_id: uuid.UUID
    name: str
    data: str
    deadline: str | None
    address: str | None
    contact_number: str | None
    contact_info: str | None
    type: QuestType
    inclusive: bool
    status: QuestStatus
    creator_public_id: uuid.UUID

class CreateQuestResponse(BaseModel):
    public_id: uuid.UUID
    name: str
    data: str | None
    deadline: str | None
    address: str | None
    contact_number: str | None
    contact_info: str | None
    type: QuestType
    inclusive: bool
    status: QuestStatus
    creator_public_id: uuid.UUID
    created_at: datetime
    updated_at: datetime
  */

class CreateQuestRequest {
  final String groupPublicId;
  final String name;
  final String? description;
  final DateTime? date;
  final DateTime? deadlineStart;
  final DateTime? deadlineEnd;
  final String? address;
  final String? contactNumber;
  final String? contactInfo;
  final String? data;
  final QuestType type;
  final bool inclusive;
  final QuestStatus status;
  final String creatorPublicId;
  final String? acceptedByPublicId;

  CreateQuestRequest({
    required this.groupPublicId,
    required this.name,
    this.description,
    this.date,
    this.deadlineStart,
    this.deadlineEnd,
    this.address,
    this.contactNumber,
    this.contactInfo,
    this.data,
    this.type = QuestType.job,
    this.inclusive = true,
    this.status = QuestStatus.started,
    required this.creatorPublicId,
    this.acceptedByPublicId,
  });

  Map<String, dynamic> toJson() {
    return {
      'group_public_id': groupPublicId,
      'name': name,
      'description': description,
      'date': date?.toIso8601String(),
      'deadline_start': deadlineStart?.toIso8601String(),
      'deadline_end': deadlineEnd?.toIso8601String(),
      'address': address,
      'contact_number': contactNumber,
      'contact_info': contactInfo,
      'data': data,
      'type': type.apiValue,
      'inclusive': inclusive,
      'status': status.apiValue,
      'creator_public_id': creatorPublicId,
      'accepted_by_public_id': acceptedByPublicId,
    };
  }
}

class CreateQuestResponse {
  final String publicId;
  final String name;
  final String? description;
  final DateTime? date;
  final DateTime? deadlineStart;
  final DateTime? deadlineEnd;
  final String? address;
  final String? contactNumber;
  final String? contactInfo;
  final String? data;
  final QuestType type;
  final bool inclusive;
  final QuestStatus status;
  final String creatorPublicId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? acceptedByPublicId;

  CreateQuestResponse({
    required this.publicId,
    required this.name,
    this.description,
    this.date,
    this.deadlineStart,
    this.deadlineEnd,
    this.address,
    this.contactNumber,
    this.contactInfo,
    this.data,
    required this.type,
    required this.inclusive,
    required this.status,
    required this.creatorPublicId,
    required this.createdAt,
    required this.updatedAt,
    this.acceptedByPublicId,
  });

  factory CreateQuestResponse.fromJson(Map<String, dynamic> json) {
    return CreateQuestResponse(
      publicId: json['public_id'],
      name: json['name'],
      description: json['description'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      deadlineStart: json['deadline_start'] != null
          ? DateTime.parse(json['deadline_start'])
          : null,
      deadlineEnd: json['deadline_end'] != null
          ? DateTime.parse(json['deadline_end'])
          : null,
      address: json['address'],
      contactNumber: json['contact_number'],
      contactInfo: json['contact_info'],
      data: json['data'],
      type: QuestTypeX.fromString(json['type']),
      inclusive: json['inclusive'],
      status: QuestStatusX.fromString(json['status']),
      creatorPublicId: json['creator_public_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      acceptedByPublicId: json['accepted_by_public_id'],
    );
  }
}

/*
Server data model for reference:
class QuestSyncDTO(BaseModel):
    group_public_id: uuid.UUID
    public_id: uuid.UUID
    name: str
    data: str | None
    deadline: str | None
    address: str | None
    contact_number: str | None
    contact_info: str | None
    type: QuestType
    inclusive: bool
    status: QuestStatus
    creator_public_id: uuid.UUID
    created_at: datetime
    updated_at: datetime

class QuestSyncResponse(BaseModel):
    quests: list[QuestSyncDTO]
    */

class QuestSyncDTO {
  final String groupPublicId;
  final String publicId;
  final String name;
  final String? description;
  final DateTime? date;
  final DateTime? deadlineStart;
  final DateTime? deadlineEnd;
  final String? address;
  final String? contactNumber;
  final String? contactInfo;
  final String? data;
  final QuestType type;
  final bool inclusive;
  final QuestStatus status;
  final String creatorPublicId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? acceptedByPublicId;

  QuestSyncDTO({
    required this.groupPublicId,
    required this.publicId,
    required this.name,
    this.description,
    this.date,
    this.deadlineStart,
    this.deadlineEnd,
    this.address,
    this.contactNumber,
    this.contactInfo,
    this.data,
    required this.type,
    required this.inclusive,
    required this.status,
    required this.creatorPublicId,
    required this.createdAt,
    required this.updatedAt,
    this.acceptedByPublicId,
  });

  factory QuestSyncDTO.fromJson(Map<String, dynamic> json) {
    return QuestSyncDTO(
      groupPublicId: json['group_public_id'],
      publicId: json['public_id'],
      name: json['name'],
      description: json['description'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      deadlineStart: json['deadline_start'] != null
          ? DateTime.parse(json['deadline_start'])
          : null,
      deadlineEnd: json['deadline_end'] != null
          ? DateTime.parse(json['deadline_end'])
          : null,
      address: json['address'],
      contactNumber: json['contact_number'],
      contactInfo: json['contact_info'],
      data: json['data'],
      type: QuestTypeX.fromString(json['type']),
      inclusive: json['inclusive'],
      status: QuestStatusX.fromString(json['status']),
      creatorPublicId: json['creator_public_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      acceptedByPublicId: json['accepted_by_public_id'],
    );
  }
  @override
  String toString() {
    return 'QuestSyncDTO(publicId: $publicId, name: $name, status: $status, acceptedBy: $acceptedByPublicId)';
  }
}

class QuestsSyncResponse {
  final List<QuestSyncDTO> quests;

  QuestsSyncResponse({required this.quests});

  factory QuestsSyncResponse.fromJson(Map<String, dynamic> json) {
    return QuestsSyncResponse(
      quests: (json['quests'] as List)
          .map((quest) => QuestSyncDTO.fromJson(quest))
          .toList(),
    );
  }

  @override
  String toString() {
    return 'QuestsSyncResponse(quests: $quests)';
  }
}
