class SessionData {
  final String sessionToken;
  final String username;
  final String publicId;
  final String? fcmToken;

  const SessionData.empty()
    : sessionToken = '',
      username = '',
      publicId = '',
      fcmToken = null;

  const SessionData({
    required this.sessionToken,
    required this.username,
    required this.publicId,
    this.fcmToken,
  });
}
