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
  // final DateTime? date; // DROPPED: removed from backend contract
  // final DateTime? deadlineStart; // DROPPED: replaced by deadline
  // final DateTime? deadlineEnd; // DROPPED: replaced by deadline
  final DateTime? deadline;
  final DateTime? startTime;
  final String? address;
  // final String? contactNumber; // DROPPED: removed from backend contract
  // final String? contactInfo; // DROPPED: removed from backend contract
  final String? data;
  // final QuestType type; // DROPPED: removed from backend contract
  final RewardType rewardType;
  final String? rewardValue;
  final bool inclusive;
  final QuestStatus status;
  final bool automaticReward;
  // final String creatorPublicId; // DROPPED: resolved server-side from auth token
  // final String? acceptedByPublicId; // DROPPED: not sent on create

  CreateQuestRequest({
    required this.groupPublicId,
    required this.name,
    this.description,
    this.deadline,
    this.startTime,
    this.address,
    this.data,
    this.rewardType = RewardType.none,
    this.rewardValue,
    // this.type = QuestType.job, // DROPPED
    this.inclusive = true,
    this.status = QuestStatus.open,
    // required this.creatorPublicId, // DROPPED
    // this.acceptedByPublicId, // DROPPED
    this.automaticReward = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'group_public_id': groupPublicId,
      'name': name,
      'description': description,
      // 'date': date?.toIso8601String(), // DROPPED
      // 'deadline_start': deadlineStart?.toIso8601String(), // DROPPED
      // 'deadline_end': deadlineEnd?.toIso8601String(), // DROPPED
      'deadline': deadline?.toIso8601String(),
      'start_time': startTime?.toIso8601String(),
      'address': address,
      // 'contact_number': contactNumber, // DROPPED
      // 'contact_info': contactInfo, // DROPPED
      'data': data,
      // 'type': type.apiValue, // DROPPED
      'reward_type': rewardType.apiValue,
      'reward_value': rewardValue,
      'inclusive': inclusive,
      'status': status.apiValue,
      // 'creator_public_id': creatorPublicId, // DROPPED: server resolves from auth
      // 'accepted_by_public_id': acceptedByPublicId, // DROPPED
      'automatic_reward': automaticReward,
    };
  }
}

class CreateQuestResponse {
  final String publicId;
  final String? groupPublicId;
  final String name;
  final String? description;
  // final DateTime? date; // DROPPED
  // final DateTime? deadlineStart; // DROPPED: replaced by deadline
  // final DateTime? deadlineEnd; // DROPPED: replaced by deadline
  final DateTime? deadline;
  final DateTime? startTime;
  // final String? contactNumber; // DROPPED
  // final String? contactInfo; // DROPPED
  final String? address;
  final String? data;
  // final QuestType type; // DROPPED
  final RewardType rewardType;
  final String? rewardValue;
  final bool inclusive;
  final QuestStatus status;
  final String creatorPublicId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? acceptedByPublicId;
  final bool automaticReward;

  CreateQuestResponse({
    required this.publicId,
    this.groupPublicId,
    required this.name,
    this.description,
    this.deadline,
    this.startTime,
    this.address,
    // this.contactNumber, // DROPPED
    // this.contactInfo, // DROPPED
    this.data,
    // required this.type, // DROPPED
    this.rewardType = RewardType.none,
    this.rewardValue,
    required this.inclusive,
    required this.status,
    required this.creatorPublicId,
    required this.createdAt,
    required this.updatedAt,
    this.acceptedByPublicId,
    this.automaticReward = true,
  });

  factory CreateQuestResponse.fromJson(Map<String, dynamic> json) {
    return CreateQuestResponse(
      publicId: json['public_id'],
      groupPublicId: json['group_public_id'],
      name: json['name'],
      description: json['description'],
      // date: json['date'] != null ? DateTime.parse(json['date']) : null, // DROPPED
      // deadlineStart: json['deadline_start'] != null ? DateTime.parse(json['deadline_start']) : null, // DROPPED
      // deadlineEnd: json['deadline_end'] != null ? DateTime.parse(json['deadline_end']) : null, // DROPPED
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'])
          : null,
      startTime: json['start_time'] != null
          ? DateTime.parse(json['start_time'])
          : null,
      address: json['address'],
      // contactNumber: json['contact_number'], // DROPPED
      // contactInfo: json['contact_info'], // DROPPED
      data: json['data'],
      // type: QuestTypeX.fromString(json['type']), // DROPPED
      rewardType: json['reward_type'] != null
          ? RewardTypeX.fromString(json['reward_type'])
          : RewardType.none,
      rewardValue: json['reward_value'],
      inclusive: json['inclusive'],
      status: QuestStatusX.fromString(json['status']),
      creatorPublicId: json['creator_public_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      acceptedByPublicId: json['accepted_by_public_id'],
      automaticReward: json['automatic_reward'] as bool? ?? true,
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
  // final DateTime? date; // DROPPED
  // final DateTime? deadlineStart; // DROPPED: replaced by deadline
  // final DateTime? deadlineEnd; // DROPPED: replaced by deadline
  final DateTime? deadline;
  final DateTime? startTime;
  // final String? contactNumber; // DROPPED
  // final String? contactInfo; // DROPPED
  final String? address;
  final String? data;
  // final QuestType type; // DROPPED
  final RewardType rewardType;
  final String? rewardValue;
  final bool inclusive;
  final QuestStatus status;
  final String creatorPublicId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? acceptedByPublicId;
  final bool automaticReward;

  QuestSyncDTO({
    required this.groupPublicId,
    required this.publicId,
    required this.name,
    this.description,
    this.deadline,
    this.startTime,
    // this.contactNumber, // DROPPED
    // this.contactInfo, // DROPPED
    this.address,
    this.data,
    // required this.type, // DROPPED
    this.rewardType = RewardType.none,
    this.rewardValue,
    required this.inclusive,
    required this.status,
    required this.creatorPublicId,
    required this.createdAt,
    required this.updatedAt,
    this.acceptedByPublicId,
    this.automaticReward = true,
  });

  factory QuestSyncDTO.fromJson(Map<String, dynamic> json) {
    return QuestSyncDTO(
      groupPublicId: json['group_public_id'],
      publicId: json['public_id'],
      name: json['name'],
      description: json['description'],
      // date: json['date'] != null ? DateTime.parse(json['date']) : null, // DROPPED
      // deadlineStart: json['deadline_start'] != null ? DateTime.parse(json['deadline_start']) : null, // DROPPED
      // deadlineEnd: json['deadline_end'] != null ? DateTime.parse(json['deadline_end']) : null, // DROPPED
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'])
          : null,
      startTime: json['start_time'] != null
          ? DateTime.parse(json['start_time'])
          : null,
      address: json['address'],
      // contactNumber: json['contact_number'], // DROPPED
      // contactInfo: json['contact_info'], // DROPPED
      data: json['data'],
      // type: QuestTypeX.fromString(json['type']), // DROPPED
      rewardType: json['reward_type'] != null
          ? RewardTypeX.fromString(json['reward_type'])
          : RewardType.none,
      rewardValue: json['reward_value'],
      inclusive: json['inclusive'],
      status: QuestStatusX.fromString(json['status']),
      creatorPublicId: json['creator_public_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      acceptedByPublicId: json['accepted_by_public_id'],
      automaticReward: json['automatic_reward'] as bool? ?? true,
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
