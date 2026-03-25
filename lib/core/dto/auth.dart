/*
class AuthResponse(BaseModel):
    session_token: str
    username: str
    public_id: uuid.UUID
    fcm_token: str

class AuthRequest(BaseModel):
    device_id: str | None = None
    installation_id: str
    api_key: str
    username: str | None = None
    fcm_token: str | None = None

class RegistrationRequest(BaseModel):
    device_id: str | None = None
    installation_id: str
    username: str
    password: str

class RegistrationResponse(BaseModel):
    session_token: str
    api_key: str
    username: str
    public_id: uuid.UUID | None = None
*/

class AuthenticationRequest {
  final String installationId;
  final String? fcmToken;
  final String apiKey;

  AuthenticationRequest({
    required this.installationId,
    this.fcmToken,
    required this.apiKey,
  });

  Map<String, dynamic> toJson() => {
    'installation_id': installationId,
    if (fcmToken != null) 'fcm_token': fcmToken,
    if (apiKey != null) 'api_key': apiKey,
  };
}

class AuthenticationResponse {
  final String sessionToken;
  final String username;
  final String publicId;
  final String fcmToken;

  AuthenticationResponse({
    required this.sessionToken,
    required this.username,
    required this.publicId,
    required this.fcmToken,
  });

  factory AuthenticationResponse.fromJson(Map<String, dynamic> json) {
    return AuthenticationResponse(
      sessionToken: json['session_token'] as String,
      username: json['username'] as String,
      publicId: json['public_id'] as String,
      fcmToken: json['fcm_token'] as String,
    );
  }
}

class RegistrationResponse {
  final String sessionToken;
  final String apiKey;
  final String username;
  final String publicId;

  RegistrationResponse({
    required this.sessionToken,
    required this.apiKey,
    required this.username,
    required this.publicId,
  });

  factory RegistrationResponse.fromJson(Map<String, dynamic> json) {
    return RegistrationResponse(
      sessionToken: json['session_token'] as String,
      apiKey: json['api_key'] as String,
      username: json['username'] as String,
      publicId: json['public_id'] as String,
    );
  }

  @override
  String toString() {
    return 'RegistrationResponse(sessionToken: $sessionToken, apiKey: $apiKey, username: $username, publicId: $publicId)';
  }
}

class RegistrationRequest {
  final String? deviceId;
  final String installationId;
  final String? username;
  final String? password;

  RegistrationRequest({
    required this.installationId,
    this.deviceId,
    this.username,
    this.password,
  });

  Map<String, dynamic> toJson() => {
    'installation_id': installationId,
    if (deviceId != null) 'device_id': deviceId,
    if (username != null) 'username': username,
    if (password != null) 'password': password,
  };
}

/*
class RegistrationRequest(BaseModel):
    device_id: str | None = None
    installation_id: str
    username: str
    password: str
    */
