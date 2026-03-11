import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'installation_id_service.dart';
import '../utils/logger_util.dart';

class AuthService {
  final InstallationIdService _installationIdService;
  final FlutterSecureStorage _secureStorage;

  static const String _tokenKey = 'auth_token';

  AuthService(this._installationIdService, this._secureStorage);

  Future<String?> initialize({String? installationId}) async {
    final id =
        installationId ??
        await _installationIdService.getOrCreateInstallationId();
    logger.i('Installation ID: $id');
    return await _secureStorage.read(key: _tokenKey);
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
