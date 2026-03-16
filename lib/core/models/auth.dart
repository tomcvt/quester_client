class SessionData {
  final String sessionToken;
  final String username;
  final String? fcmToken;

  SessionData({
    required this.sessionToken,
    required this.username,
    this.fcmToken,
  });
}
