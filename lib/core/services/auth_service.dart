import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:quester_client/core/dto/auth.dart';
import 'package:quester_client/core/http/api_client.dart';
import 'package:quester_client/core/models/auth.dart';
import 'package:quester_client/core/services/app_initializer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quester_client/core/constants/const.dart';
import 'installation_id_service.dart';
import '../utils/logger_util.dart';

class AuthService {
  final InstallationIdService _installationIdService;
  final ApiClient _apiClient;
  final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage;
  /*
  static const String _apiKey = 'x-api-key';
  static const String _sessionTokenKey = 'session_token';
  static const String _publicIdKey = 'public_id';
  static const String _usernameKey = 'username';
  static const String _phoneNumberKey = 'phone_number';
*/
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
      if (sessionData.sessionToken.isEmpty) {
        logger.w('No session token received during authentication');
        return const SessionData.empty();
      }
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
    final id = await _installationIdService.getOrCreateInstallationId();

    final regResponse = await registerAndSave(id, null, '');
    if (regResponse.apiKey == null || regResponse.apiKey!.isEmpty) {
      throw Exception('API key is missing after registration');
    }
    logger.d('Registration complete, API key: ${regResponse.apiKey}');

    final authResponse = await _apiClient.authenticate(
      id,
      regResponse.apiKey!,
      fcmToken,
    );
    if (authResponse.sessionToken.isEmpty) {
      throw Exception('Session token is missing after authentication');
    }
    logger.d(
      'Authentication complete, session token: ${authResponse.sessionToken}',
    );

    _apiClient.setSessionToken(authResponse.sessionToken);
    await _secureStorage.write(
      key: sessionTokenKey,
      value: authResponse.sessionToken,
    );
    await _secureStorage.write(key: publicIdKey, value: authResponse.publicId);
    await _prefs.setString(usernameKey, authResponse.username ?? '');
    await _prefs.setString(phoneNumberKey, authResponse.phoneNumber ?? '');

    return SessionData(
      sessionToken: authResponse.sessionToken,
      username: authResponse.username,
      phoneNumber: authResponse.phoneNumber,
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
      key: apiKeyKey,
      value: registrationResponse.apiKey,
    );
    await _secureStorage.write(
      key: sessionTokenKey,
      value: registrationResponse.sessionToken,
    );
    await _secureStorage.write(
      key: publicIdKey,
      value: registrationResponse.publicId,
    );
    //how to handle case where username is null? for now we just store empty string, but maybe we should generate a random username or something?
    await _prefs.setString(usernameKey, registrationResponse.username ?? '');
    await _prefs.setString(
      phoneNumberKey,
      registrationResponse.phoneNumber ?? '',
    );
    logger.d('Registered: ${registrationResponse.toString()}');
    return registrationResponse;
  }

  String? getUsername() => AppInitializer.sessionData.username;

  String? getPhoneNumber() => AppInitializer.sessionData.phoneNumber;

  Future<String?> changeUsername(String newUsername) async {
    final publicId = await _secureStorage.read(key: publicIdKey);
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
    await _prefs.setString(usernameKey, newUsername);
    logger.d('Username changed successfully to: $newUsername');
    return newUsername;
  }

  //TODO refactor to current architecture
  Future<String?> changePhoneNumber(String newPhoneNumber) async {
    final publicId = await _secureStorage.read(key: publicIdKey);
    if (publicId == null) {
      throw Exception('Public ID not found in secure storage');
    }
    //TODO add phone number validation
    bool didSucceed = await _apiClient.changePhoneNumber(newPhoneNumber);
    if (!didSucceed) {
      throw Exception('Failed to change phone number');
    }
    await _prefs.setString(phoneNumberKey, newPhoneNumber);
    AppInitializer.sessionData = AppInitializer.sessionData.copyWith(
      phoneNumber: newPhoneNumber,
    );
    logger.d('Phone number changed successfully to: $newPhoneNumber');
    return newPhoneNumber;
  }

  //TODO refactor to current architecture
  Future<bool> changeUsernameAndPhoneNumber(
    String newUsername,
    String newPhoneNumber,
  ) async {
    final publicId = await _secureStorage.read(key: publicIdKey);
    if (publicId == null) {
      throw Exception('Public ID not found in secure storage');
    }
    if (!_allowedUsername(newUsername)) {
      throw Exception(
        'Username has to be 3-20 chars, letters, numbers or underscores only',
      );
    }
    //TODO add phone number validation
    bool didSucceed = await _apiClient.changeUsernameAndPhoneNumber(
      newUsername,
      newPhoneNumber,
    );
    if (!didSucceed) {
      throw Exception('Failed to change username and phone number');
    }
    await _prefs.setString(usernameKey, newUsername);
    await _prefs.setString(phoneNumberKey, newPhoneNumber);
    AppInitializer.sessionData = AppInitializer.sessionData.copyWith(
      username: newUsername,
      phoneNumber: newPhoneNumber,
    );
    logger.d(
      'Username and phone number changed successfully. New username: $newUsername, New phone number: $newPhoneNumber',
    );
    return true;
  }

  bool _allowedUsername(String username) {
    // Add more complex validation as needed (e.g., regex for allowed characters)
    // so lets do regex for only letters, numbers, underscores, 3-20 chars
    return RegExp(r'^[a-zA-Z0-9_]{3,20}$').hasMatch(username);
  }
}
