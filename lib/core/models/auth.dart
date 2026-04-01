class SessionData {
  final String sessionToken;
  final String? username;
  final String publicId;
  final String? fcmToken;

  const SessionData.empty()
    : sessionToken = '',
      username = null,
      publicId = '',
      fcmToken = null;

  const SessionData({
    required this.sessionToken,
    this.username,
    required this.publicId,
    this.fcmToken,
  });

  @override
  String toString() {
    return 'SessionData(sessionToken: $sessionToken, username: $username, publicId: $publicId, fcmToken: $fcmToken)';
  }

  SessionData copyWith({
    String? sessionToken,
    String? username,
    String? publicId,
    String? fcmToken,
  }) {
    return SessionData(
      sessionToken: sessionToken ?? this.sessionToken,
      username: username ?? this.username,
      publicId: publicId ?? this.publicId,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }
}
