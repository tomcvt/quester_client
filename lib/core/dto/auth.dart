/*

class TokenResponse(BaseModel):
    session_token: str

class AuthResponse(BaseModel):
    session_token: str
    username: str
    fcm_token: str
    

#TODO : add proper login
class AuthRequest(BaseModel):
    device_id: str | None = None
    installation_id: uuid.UUID
    username: str | None = None
    fcm_token: str | None = None

    */

class AuthenticationRequest {
  final String installationId;
  final String? fcmToken;

  AuthenticationRequest({required this.installationId, this.fcmToken});

  Map<String, dynamic> toJson() => {
    'installation_id': installationId,
    if (fcmToken != null) 'fcm_token': fcmToken,
  };
}

class AuthenticationResponse {
  final String sessionToken;
  final String username;
  final String fcmToken;

  AuthenticationResponse({
    required this.sessionToken,
    required this.username,
    required this.fcmToken,
  });

  factory AuthenticationResponse.fromJson(Map<String, dynamic> json) {
    return AuthenticationResponse(
      sessionToken: json['session_token'] as String,
      username: json['username'] as String,
      fcmToken: json['fcm_token'] as String,
    );
  }
}
