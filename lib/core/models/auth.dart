class SessionData {
  final String sessionToken;
  final String? username;
  final String? phoneNumber;
  final String publicId;
  final String? fcmToken;

  const SessionData.empty()
    : sessionToken = '',
      username = null,
      phoneNumber = null,
      publicId = '',
      fcmToken = null;

  const SessionData({
    required this.sessionToken,
    this.username,
    this.phoneNumber,
    required this.publicId,
    this.fcmToken,
  });

  @override
  String toString() {
    return 'SessionData(sessionToken: $sessionToken, username: $username, phoneNumber: $phoneNumber, publicId: $publicId, fcmToken: $fcmToken)';
  }

  SessionData copyWith({
    String? sessionToken,
    String? username,
    String? phoneNumber,
    String? publicId,
    String? fcmToken,
  }) {
    return SessionData(
      sessionToken: sessionToken ?? this.sessionToken,
      username: username ?? this.username,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      publicId: publicId ?? this.publicId,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }
}
