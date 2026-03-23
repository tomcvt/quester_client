import 'package:quester_client/core/data/data_tables.dart';
/*
Server data model for reference:
class CreateQuestRequest(BaseModel):
    group_public_id: uuid.UUID
    name: str
    data: str
    contact_info: str | None
    type: QuestType
    inclusive: bool
    status: QuestStatus
    creator_public_id: uuid.UUID

class CreateQuestResponse(BaseModel):
    public_id: uuid.UUID
    name: str
    data: str | None
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
  final String? data;
  final String? contactInfo;
  final QuestType type;
  final bool inclusive;
  final QuestStatus status;
  final String creatorPublicId;

  CreateQuestRequest({
    required this.groupPublicId,
    required this.name,
    this.data,
    this.contactInfo,
    this.type = QuestType.job,
    this.inclusive = true,
    this.status = QuestStatus.started,
    required this.creatorPublicId,
  });

  Map<String, dynamic> toJson() {
    return {
      'group_public_id': groupPublicId,
      'name': name,
      'data': data,
      'contact_info': contactInfo,
      'type': type.apiValue,
      'inclusive': inclusive,
      'status': status.apiValue,
      'creator_public_id': creatorPublicId,
    };
  }
}

class CreateQuestResponse {
  final String publicId;
  final String name;
  final String? data;
  final String? contactInfo;
  final QuestType type;
  final bool inclusive;
  final QuestStatus status;
  final String creatorPublicId;
  final DateTime createdAt;
  final DateTime updatedAt;

  CreateQuestResponse({
    required this.publicId,
    required this.name,
    this.data,
    this.contactInfo,
    required this.type,
    required this.inclusive,
    required this.status,
    required this.creatorPublicId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CreateQuestResponse.fromJson(Map<String, dynamic> json) {
    return CreateQuestResponse(
      publicId: json['public_id'],
      name: json['name'],
      data: json['data'],
      contactInfo: json['contact_info'],
      type: QuestTypeX.fromString(json['type']),
      inclusive: json['inclusive'],
      status: QuestStatusX.fromString(json['status']),
      creatorPublicId: json['creator_public_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
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
  final String? data;
  final String? contactInfo;
  final QuestType type;
  final bool inclusive;
  final QuestStatus status;
  final String creatorPublicId;
  final DateTime createdAt;
  final DateTime updatedAt;

  QuestSyncDTO({
    required this.groupPublicId,
    required this.publicId,
    required this.name,
    this.data,
    this.contactInfo,
    required this.type,
    required this.inclusive,
    required this.status,
    required this.creatorPublicId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory QuestSyncDTO.fromJson(Map<String, dynamic> json) {
    return QuestSyncDTO(
      groupPublicId: json['group_public_id'],
      publicId: json['public_id'],
      name: json['name'],
      data: json['data'],
      contactInfo: json['contact_info'],
      type: QuestTypeX.fromString(json['type']),
      inclusive: json['inclusive'],
      status: QuestStatusX.fromString(json['status']),
      creatorPublicId: json['creator_public_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
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
}
