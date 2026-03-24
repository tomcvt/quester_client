import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:quester_client/core/http/api_client.dart';
import 'package:quester_client/core/models/auth.dart';
import 'installation_id_service.dart';
import '../utils/logger_util.dart';

class AuthService {
  final InstallationIdService _installationIdService;
  final ApiClient _apiClient;
  final FlutterSecureStorage _secureStorage;

  static const String _tokenKey = 'auth_token';
  static const String _apiKey = 'x-api-key';
  static const String _sessionToken = 'session_token';
  static const String _publicIdKey = 'public_id';
  static const String _usernameKey = 'username';

  AuthService(
    this._installationIdService,
    this._apiClient,
    this._secureStorage,
  );

  Future<String?> initialize(String installationId, {String? fcmToken}) async {
    try {
      final sessionData = await authenticate(installationId, fcmToken);
      logger.i('Authentication successful, token stored securely');
      return sessionData.sessionToken;
    } catch (e) {
      logger.e('Authentication failed: $e');
      return null;
    }
  }

  Future<SessionData> authenticate(String installationId, String? fcmToken) async {
    final installationId = await _installationIdService
        .getOrCreateInstallationId();
    final apiKey = await _secureStorage.read(key: _apiKey);
    if (apiKey == null || apiKey.isEmpty) {
      final registrationResponse = await _apiClient.register(
        installationId,
        '',
        '');
      await _secureStorage.write(key: _apiKey, value: registrationResponse.apiKey);
      await _secureStorage.write(key: _sessionToken, value: registrationResponse.sessionToken)''
      await _secureStorage.write(key: _publicIdKey, value: registrationResponse.publicId);
      final sharedPrefs = _installationIdService.prefs;
      await sharedPrefs.setString(_usernameKey, registrationResponse.username);
      logger.i('Registration successful, API key and session token stored securely');
    }
    //TODO continue with authentication flow, handle cases where registration is needed, etc.
    final authResponse = await _apiClient.authenticate(
      installationId,
      fcmToken,
    );
    if (authResponse.sessionToken.isEmpty) {
      throw Exception('Authentication failed: No session token received');
    }
    await _secureStorage.write(
      key: _tokenKey,
      value: authResponse.sessionToken,
    );
    return SessionData(
      sessionToken: authResponse.sessionToken,
      username: authResponse.username,
      fcmToken: authResponse.fcmToken,

    );
  }

  Future<void> login(String username, String password) async {
    await Future.delayed(const Duration(seconds: 2)); // mock network
    await _secureStorage.write(key: _tokenKey, value: 'mock_token_123');
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(seconds: 1));
    await _secureStorage.delete(key: _tokenKey);
  }
}
