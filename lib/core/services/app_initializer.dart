import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quester_client/core/data/app_database.dart';
import 'package:quester_client/core/http/api_client.dart';
import 'package:quester_client/core/models/auth.dart';
import 'package:quester_client/core/utils/logger_util.dart';
import 'package:quester_client/dev/dev_data_seeder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:quester_client/core/services/auth_service.dart';
import 'package:uuid/uuid.dart';
import 'auth_service.dart';
import 'installation_id_service.dart';
import 'package:quester_client/core/constants/const.dart';
import 'package:quester_client/core/utils/logger_util.dart';

class AppInitializer {
  static late final BuildConfig buildConfig;
  static late final String deviceId;
  static late final String installationId;
  static late final String? token;
  static late final AppDatabase db;
  static late final String fcmToken;
  static late final SharedPreferences prefs;
  static late final ApiClient apiClient;
  static bool isInitialized = false;
  static SessionData sessionData = const SessionData.empty();
  static final isOnline = ValueNotifier<bool>(
    true,
  ); // Start assuming we're online

  //TODO think about what is really static and final

  static String? getCurrentUserPublicId() {
    return sessionData.publicId;
  }

  static Future<void> init(BuildConfig? passedBuildConfig) async {
    final config =
        passedBuildConfig ??
        BuildConfig(
          persistenceMode: PersistenceMode.memory,
          isDebug: true,
          apiBaseUrl: 'http://localhost:8100/api/v1/',
        );
    buildConfig = config; // assign to static variable for global access
    prefs = await SharedPreferences.getInstance();
    final installationIdService = InstallationIdService(prefs);
    installationId = await installationIdService.getOrCreateInstallationId();
    fcmToken = await getFcmToken(prefs);
    prefs.setString(apiBaseUrlKey, config.apiBaseUrl);
    prefs.setString('installation_id', installationId);
    apiClient = ApiClient(config.apiBaseUrl, installationId);
    //TODO - handle token expiration, refresh, etc. @link AuthService.initialize() should return a result object with success/failure and token if successful
    final authService = AuthService(
      installationIdService,
      apiClient,
      FlutterSecureStorage(),
      prefs,
    );
    sessionData = await authService.initialize(
      installationId,
      fcmToken: fcmToken,
    );
    logger.i('Installation ID: $installationId');
    logger.i('Session data: ${sessionData.toString()}');
    db = await AppDatabase.open(buildConfig: buildConfig);
    deviceId = await _getDeviceId();

    if (config.isDebug) {
      await DevDataSeeder.seed(db, installationId);
      logger.d('Development data seeded');
    }
    isInitialized = true;
  }

  static Future<String> getFcmToken(SharedPreferences prefs) async {
    String? newFcmToken = prefs.getString('fcm_token');
    logger.i('Existing FCM token: $newFcmToken');
    if (newFcmToken == null || newFcmToken.isEmpty) {
      newFcmToken = await FirebaseMessaging.instance.getToken(
        vapidKey:
            "BF7AEejZwS5IMB4qOl2Ys1Z-wppuNBl7r7pFEvYXat8ZF-zOU4xwJxZZ7iVfIvy7Zf-dJZIjqDLyEYZMHWvUrr8",
      );
      if (newFcmToken == null) {
        logger.e('Failed to obtain FCM token');
        newFcmToken = '';
      }
      await prefs.setString('fcm_token', newFcmToken);
      logger.i('New FCM token generated: $newFcmToken');
    }
    return newFcmToken;
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

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  if (!AppInitializer.isInitialized) {
    throw Exception(
      'AppDatabase provider accessed before AppInitializer.init()',
    );
  }
  return AppInitializer.db;
});
