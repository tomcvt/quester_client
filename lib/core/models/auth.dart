import 'package:quester_client/core/data/data_tables.dart';
import 'package:quester_client/core/dto/auth.dart';

class SessionData {
  //final String sessionToken;
  final String accessToken;
  final String? username;
  final String? phoneNumber;
  final String publicId;
  final String? fcmToken;
  final UserRole role;
  final String? oauthProvider;

  const SessionData.empty()
    : //sessionToken = '',
      accessToken = '',
      username = null,
      phoneNumber = null,
      publicId = '',
      fcmToken = null,
      role = UserRole.user,
      oauthProvider = null;

  const SessionData({
    //required this.sessionToken,
    required this.accessToken,
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
      Object.hash(accessToken, username, phoneNumber, publicId, fcmToken, role, oauthProvider);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SessionData &&
        other.accessToken == accessToken &&
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
    return 'SessionData(accessToken: $accessToken, username: $username, phoneNumber: $phoneNumber, publicId: $publicId, fcmToken: $fcmToken, role: $role, oauthProvider: $oauthProvider)';
  }

  bool get isEmpty => accessToken.isEmpty || publicId.isEmpty;

  static SessionData fromAuthResponse(AuthenticationResponse authResponse) {
    return SessionData(
      //sessionToken: authResponse.sessionToken,
      accessToken: authResponse
          .sessionToken, // TODO [to delete if jwt works]: rename sessionToken to accessToken in authResponse and here
      username: authResponse.username,
      phoneNumber: authResponse.phoneNumber,
      publicId: authResponse.publicId,
      fcmToken: authResponse.fcmToken,
      role: authResponse.role,
      oauthProvider: authResponse.oauthProvider,
    );
  }

  static SessionData fromSessionResponse(SessionResponse sessionResponse) {
    return SessionData(
      //sessionToken: sessionResponse.accessToken,
      accessToken: sessionResponse.accessToken,
      username: sessionResponse.username,
      phoneNumber: sessionResponse.phoneNumber,
      publicId: sessionResponse.publicId,
      fcmToken: sessionResponse.fcmToken,
      role: sessionResponse.role,
      oauthProvider: sessionResponse.oauthProvider,
    );
  }

  SessionData copyWith({
    String? accessToken,
    String? username,
    String? phoneNumber,
    String? publicId,
    String? fcmToken,
    UserRole? role,
    String? oauthProvider,
  }) {
    return SessionData(
      accessToken: accessToken ?? this.accessToken,
      username: username ?? this.username,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      publicId: publicId ?? this.publicId,
      fcmToken: fcmToken ?? this.fcmToken,
      role: role ?? this.role,
      oauthProvider: oauthProvider ?? this.oauthProvider,
    );
  }
}
