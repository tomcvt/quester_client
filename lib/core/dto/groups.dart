/*

class GroupResponse(BaseModel):
    public_id: uuid.UUID
    name: str
    type: GroupType
    visibility: GroupVisibility
    created_at: str

class CreateGroupRequest(BaseModel):
    name: str
    password: str | None = None
    type: GroupType = GroupType.WORK
    visibility: GroupVisibility = GroupVisibility.PRIVATE

*/

import 'package:quester_client/core/data/data_tables.dart';

class GroupResponse {
  final String publicId;
  final String name;
  final GroupType type;
  final GroupVisibility visibility;
  final DateTime createdAt;

  GroupResponse({
    required this.publicId,
    required this.name,
    required this.type,
    required this.visibility,
    required this.createdAt,
  });

  factory GroupResponse.fromJson(Map<String, dynamic> json) {
    return GroupResponse(
      publicId: json['public_id'] as String,
      name: json['name'] as String,
      type: GroupTypeX.fromString(json['type'] as String),
      visibility: GroupVisibilityX.fromString(json['visibility'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
  @override
  String toString() {
    return 'GroupResponse(publicId: $publicId, name: $name, type: $type, visibility: $visibility, createdAt: $createdAt)';
  }
}

class CreateGroupRequest {
  final String name;
  final String? password;
  final GroupType type;
  final GroupVisibility visibility;

  CreateGroupRequest({
    required this.name,
    this.password,
    this.type = GroupType.work,
    this.visibility = GroupVisibility.private,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (password != null) 'password': password,
      'type': type.apiValue,
      'visibility': visibility.apiValue,
    };
  }
}

class JoinGroupRequest {
  final String name;
  final String password;

  JoinGroupRequest({required this.name, required this.password});

  Map<String, dynamic> toJson() {
    return {'name': name, 'password': password};
  }
}

/*

FASTAPI SERVER FOR REFERENCE
class GroupMemberSyncDTO(BaseModel):
    #public_id: str
    group_public_id: uuid.UUID
    user_public_id: uuid.UUID
    role: MemberRole
    username: str
    updated_at: datetime

class GroupMemberSyncResponse(BaseModel):
    members: list[GroupMemberSyncDTO]
*/

class GroupMemberSyncDTO {
  final String groupPublicId;
  final String userPublicId;
  final MemberRole role;
  final String username;
  final DateTime updatedAt;

  GroupMemberSyncDTO({
    required this.groupPublicId,
    required this.userPublicId,
    required this.role,
    required this.username,
    required this.updatedAt,
  });

  factory GroupMemberSyncDTO.fromJson(Map<String, dynamic> json) {
    return GroupMemberSyncDTO(
      groupPublicId: json['group_public_id'] as String,
      userPublicId: json['user_public_id'] as String,
      role: MemberRoleX.fromString(json['role'] as String),
      username: json['username'] as String,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
  @override
  String toString() {
    return 'GroupMemberSyncDTO(groupPublicId: $groupPublicId, userPublicId: $userPublicId, role: $role, username: $username, updatedAt: $updatedAt)';
  }
}

class GroupMembersSyncResponse {
  final List<GroupMemberSyncDTO> members;

  GroupMembersSyncResponse({required this.members});

  factory GroupMembersSyncResponse.fromJson(Map<String, dynamic> json) {
    var membersJson = json['members'] as List;
    List<GroupMemberSyncDTO> membersList = membersJson
        .map(
          (memberJson) =>
              GroupMemberSyncDTO.fromJson(memberJson as Map<String, dynamic>),
        )
        .toList();
    return GroupMembersSyncResponse(members: membersList);
  }

  @override
  String toString() {
    return 'GroupMembersSyncResponse(members: $members)';
  }
}
