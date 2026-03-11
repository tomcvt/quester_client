import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'auth_service.dart';
import 'installation_id_service.dart';

class AppInitializer {
  static late final String installationId;
  static late final String? token;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final installationIdService = InstallationIdService(prefs);
    installationId = await installationIdService.getOrCreateInstallationId();
    token = await AuthService(
      installationIdService,
      FlutterSecureStorage(),
    ).initialize(installationId: installationId);
  }
}
