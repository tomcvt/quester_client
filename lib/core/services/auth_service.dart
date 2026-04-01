import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:quester_client/core/dto/auth.dart';
import 'package:quester_client/core/http/api_client.dart';
import 'package:quester_client/core/models/auth.dart';
import 'package:quester_client/core/services/app_initializer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'installation_id_service.dart';
import '../utils/logger_util.dart';

class AuthService {
  final InstallationIdService _installationIdService;
  final ApiClient _apiClient;
  final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage;

  static const String _apiKey = 'x-api-key';
  static const String _sessionToken = 'session_token';
  static const String _publicIdKey = 'public_id';
  static const String _usernameKey = 'username';

  AuthService(
    this._installationIdService,
    this._apiClient,
    this._secureStorage,
    this._prefs,
  );

  Future<SessionData> initialize(
    String installationId, {
    String? fcmToken,
  }) async {
    try {
      final sessionData = await authenticate(installationId, fcmToken);
      logger.i('Authentication successful, token stored securely');
      return sessionData;
    } catch (e) {
      logger.e('Authentication failed: $e');
      return const SessionData.empty();
    }
  }

  Future<SessionData> authenticate(
    String installationId,
    String? fcmToken,
  ) async {
    final installationId = await _installationIdService
        .getOrCreateInstallationId();
    var apiKey = await _secureStorage.read(key: _apiKey);
    if (apiKey == null || apiKey.isEmpty) {
      await registerAndSave(installationId, null, '');
    }
    apiKey = await _secureStorage.read(key: _apiKey);
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('API key is missing after registration');
    }
    //TODO continue with authentication flow, handle cases where registration is needed, etc.
    final authResponse = await _apiClient.authenticate(
      installationId,
      apiKey,
      fcmToken,
    );
    //TODO -handle case of server has key user doesnt. for now we assume
    /*
    if (authResponse.sessionToken.isEmpty) {
      await registerAndSave(installationId, username, password)
    }
    */
    _apiClient.setSessionToken(authResponse.sessionToken);
    logger.d(
      'Setting session token in API client: ${authResponse.sessionToken}',
    );
    await _secureStorage.write(
      key: _sessionToken,
      value: authResponse.sessionToken,
    );
    await _secureStorage.write(key: _publicIdKey, value: authResponse.publicId);
    await _prefs.setString(_usernameKey, authResponse.username);
    return SessionData(
      sessionToken: authResponse.sessionToken,
      username: authResponse.username,
      publicId: authResponse.publicId,
      fcmToken: authResponse.fcmToken,
    );
  }

  Future<RegistrationResponse> registerAndSave(
    String installationId,
    String? username,
    String password,
  ) async {
    final registrationResponse = await _apiClient.register(
      installationId,
      username,
      password,
    );
    await _secureStorage.write(
      key: _apiKey,
      value: registrationResponse.apiKey,
    );
    await _secureStorage.write(
      key: _sessionToken,
      value: registrationResponse.sessionToken,
    );
    await _secureStorage.write(
      key: _publicIdKey,
      value: registrationResponse.publicId,
    );
    //how to handle case where username is null? for now we just store empty string, but maybe we should generate a random username or something?
    await _prefs.setString(_usernameKey, registrationResponse.username ?? '');
    logger.d('Registered: ${registrationResponse.toString()}');
    return registrationResponse;
  }

  String? getUsername() => AppInitializer.sessionData.username;

  Future<String?> changeUsername(String newUsername) async {
    final publicId = await _secureStorage.read(key: _publicIdKey);
    if (publicId == null) {
      throw Exception('Public ID not found in secure storage');
    }
    if (!_allowedUsername(newUsername)) {
      throw Exception(
        'Username has to be 3-20 chars, letters, numbers or underscores only',
      );
    }
    bool didSucceed = await _apiClient.changeUsername(newUsername);
    if (!didSucceed) {
      throw Exception('Failed to change username');
    }
    await _prefs.setString(_usernameKey, newUsername);
    AppInitializer.sessionData = AppInitializer.sessionData.copyWith(
      username: newUsername,
    );
    logger.d('Username changed successfully to: $newUsername');
    return newUsername;
  }

  Future<void> login(String username, String password) async {
    await Future.delayed(const Duration(seconds: 2)); // mock network
    await _secureStorage.write(key: _sessionToken, value: 'mock_token_123');
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(seconds: 1));
    await _secureStorage.delete(key: _sessionToken);
  }

  bool _allowedUsername(String username) {
    // Add more complex validation as needed (e.g., regex for allowed characters)
    // so lets do regex for only letters, numbers, underscores, 3-20 chars
    return RegExp(r'^[a-zA-Z0-9_]{3,20}$').hasMatch(username);
  }
}
