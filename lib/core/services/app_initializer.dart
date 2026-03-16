import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:quester_client/core/data/app_database.dart';
import 'package:quester_client/core/http/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';
import 'auth_service.dart';
import 'installation_id_service.dart';

class AppInitializer {
  static late final BuildConfig buildConfig;
  static late final String deviceId;
  static late final String installationId;
  static late final String? token;
  static late final AppDatabase db;

  static Future<void> init(BuildConfig? passedBuildConfig) async {
    final config =
        passedBuildConfig ??
        BuildConfig(
          persistenceMode: PersistenceMode.memory,
          isDebug: true,
          apiBaseUrl: 'http://localhost:8100/api/v1/',
        );
    buildConfig = config; // assign to static variable for global access
    final prefs = await SharedPreferences.getInstance();
    final installationIdService = InstallationIdService(prefs);
    installationId = await installationIdService.getOrCreateInstallationId();
    final apiClient = ApiClient(config.apiBaseUrl, installationId);
    //TODO - handle token expiration, refresh, etc. @link AuthService.initialize() should return a result object with success/failure and token if successful
    token = await AuthService(
      installationIdService,
      apiClient,
      FlutterSecureStorage(),
    ).initialize(installationId: installationId);
    db = await AppDatabase.open(buildConfig: buildConfig);
    deviceId = await _getDeviceId();
  }

  static Future<String> _getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();

    if (kIsWeb) {
      // web has no real device id — generate and persist one yourself
      // same as installationId, use shared_preferences
      return _getOrCreateWebId();
    }

    if (Platform.isAndroid) {
      final info = await deviceInfo.androidInfo;
      return info.id; // Android hardware id
    }

    if (Platform.isIOS) {
      final info = await deviceInfo.iosInfo;
      return info.identifierForVendor ?? _generateFallback();
    }

    throw UnsupportedError('Platform not supported');
  }

  static Future<String> _getOrCreateWebId() async {
    final prefs = await SharedPreferences.getInstance();
    const key = 'web_device_id';
    String? id = prefs.getString(key);
    if (id == null) {
      id = _generateFallback();
      await prefs.setString(key, id);
    }
    return id;
  }

  static String _generateFallback() {
    // Generate a fallback ID, e.g., using UUID
    return const Uuid().v4();
  }
}

class BuildConfig {
  //static const String apiBaseUrl = 'https://questerapp.tomcvt.com/api';
  String apiBaseUrl = 'http://localhost:8100/api/v1/';
  PersistenceMode persistenceMode = PersistenceMode.memory;
  bool isDebug = true;

  BuildConfig({
    required this.persistenceMode,
    required this.isDebug,
    required this.apiBaseUrl,
  });
}

enum PersistenceMode { memory, sqlite }
