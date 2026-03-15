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
