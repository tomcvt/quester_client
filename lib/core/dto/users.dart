class UserSyncDto {
  final String publicId;
  final String username;
  final String? avatarUrl;

  UserSyncDto({required this.publicId, required this.username, this.avatarUrl});

  factory UserSyncDto.fromJson(Map<String, dynamic> json) {
    return UserSyncDto(
      publicId: json['public_id'],
      username: json['username'],
      avatarUrl: json['avatar_url'],
    );
  }
}

class UsersSyncResponse {
  final List<UserSyncDto> users;

  UsersSyncResponse({required this.users});

  factory UsersSyncResponse.fromJson(Map<String, dynamic> json) {
    final usersJson = json['users'] as List<dynamic>? ?? [];
    final users = usersJson
        .map((userJson) => UserSyncDto.fromJson(userJson))
        .toList();
    return UsersSyncResponse(users: users);
  }
}
