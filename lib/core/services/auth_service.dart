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

  AuthService(
    this._installationIdService,
    this._apiClient,
    this._secureStorage,
  );

  Future<String?> initialize({String? installationId}) async {
    final id =
        installationId ??
        await _installationIdService.getOrCreateInstallationId();
    logger.i('Installation ID: $id');
    String? key = await _secureStorage.read(key: _tokenKey);
    if (key != null) {
      logger.i('Existing auth token found');
      return key;
    }
    logger.i('No auth token found, authenticating...');
    try {
      final sessionData = await authenticate();
      logger.i('Authentication successful, token stored securely');
      return sessionData.sessionToken;
    } catch (e) {
      logger.e('Authentication failed: $e');
      return null;
    }
  }

  Future<SessionData> authenticate() async {
    final installationId = await _installationIdService
        .getOrCreateInstallationId();
    final authResponse = await _apiClient.authenticate(installationId);
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
