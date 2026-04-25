import 'package:quester_client/core/data/data_tables.dart';
import 'package:quester_client/core/dto/auth.dart';

class SessionData {
  final String sessionToken;
  final String? username;
  final String? phoneNumber;
  final String publicId;
  final String? fcmToken;
  final UserRole role;
  final String? oauthProvider;

  const SessionData.empty()
    : sessionToken = '',
      username = null,
      phoneNumber = null,
      publicId = '',
      fcmToken = null,
      role = UserRole.user,
      oauthProvider = null;

  const SessionData({
    required this.sessionToken,
    this.username,
    this.phoneNumber,
    required this.publicId,
    this.fcmToken,
    this.role = UserRole.user,
    this.oauthProvider,
  });
  /*
  @override
  int get hashCode =>
      Object.hash(sessionToken, username, phoneNumber, publicId, fcmToken, role, oauthProvider);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SessionData &&
        other.sessionToken == sessionToken &&
        other.username == username &&
        other.phoneNumber == phoneNumber &&
        other.publicId == publicId &&
        other.fcmToken == fcmToken &&
        other.role == role &&
        other.oauthProvider == oauthProvider;
  }
*/
  @override
  String toString() {
    return 'SessionData(sessionToken: $sessionToken, username: $username, phoneNumber: $phoneNumber, publicId: $publicId, fcmToken: $fcmToken, role: $role, oauthProvider: $oauthProvider)';
  }

  static SessionData fromAuthResponse(AuthenticationResponse authResponse) {
    return SessionData(
      sessionToken: authResponse.sessionToken,
      username: authResponse.username,
      phoneNumber: authResponse.phoneNumber,
      publicId: authResponse.publicId,
      fcmToken: authResponse.fcmToken,
      role: authResponse.role,
      oauthProvider: authResponse.oauthProvider,
    );
  }

  SessionData copyWith({
    String? sessionToken,
    String? username,
    String? phoneNumber,
    String? publicId,
    String? fcmToken,
    UserRole? role,
    String? oauthProvider,
  }) {
    return SessionData(
      sessionToken: sessionToken ?? this.sessionToken,
      username: username ?? this.username,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      publicId: publicId ?? this.publicId,
      fcmToken: fcmToken ?? this.fcmToken,
      role: role ?? this.role,
      oauthProvider: oauthProvider ?? this.oauthProvider,
    );
  }
}
