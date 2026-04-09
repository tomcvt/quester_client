class UserSyncDto {
  final String publicId;
  final String username;
  final String? phoneNumber;
  final String? avatarUrl;

  UserSyncDto({
    required this.publicId,
    required this.username,
    this.phoneNumber,
    this.avatarUrl,
  });

  factory UserSyncDto.fromJson(Map<String, dynamic> json) {
    return UserSyncDto(
      publicId: json['public_id'],
      username: json['username'],
      phoneNumber: json['phone_number'],
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
