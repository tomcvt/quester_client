import 'package:quester_client/core/data/app_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'auth_service.dart';
import 'installation_id_service.dart';

class AppInitializer {
  static late final BuildConfig buildConfig;
  static late final String installationId;
  static late final String? token;
  static late final AppDatabase db;

  static Future<void> init(BuildConfig? passedBuildConfig) async {
    final config =
        passedBuildConfig ??
        BuildConfig(
          persistenceMode: PersistenceMode.memory,
          isDebug: true,
          apiBaseUrl: 'http://localhost:8100/api',
        );
    buildConfig = config; // assign to static variable for global access
    final prefs = await SharedPreferences.getInstance();
    final installationIdService = InstallationIdService(prefs);
    installationId = await installationIdService.getOrCreateInstallationId();
    //TODO - handle token expiration, refresh, etc. @link AuthService.initialize() should return a result object with success/failure and token if successful
    token = await AuthService(
      installationIdService,
      FlutterSecureStorage(),
    ).initialize(installationId: installationId);
    db = await AppDatabase.open(buildConfig: buildConfig);
  }
}

class BuildConfig {
  //static const String apiBaseUrl = 'https://questerapp.tomcvt.com/api';
  String apiBaseUrl = 'http://localhost:8100/api';
  PersistenceMode persistenceMode = PersistenceMode.memory;
  bool isDebug = true;

  BuildConfig({
    required this.persistenceMode,
    required this.isDebug,
    required this.apiBaseUrl,
  });
}

enum PersistenceMode { memory, sqlite }
