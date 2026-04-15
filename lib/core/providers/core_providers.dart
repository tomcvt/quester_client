// lib/core/providers/core_providers.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quester_client/core/http/api_client.dart';
import 'package:quester_client/core/providers/data_providers.dart';
import 'package:quester_client/core/services/app_initializer.dart';
import 'package:quester_client/core/services/sync_service.dart';
import 'package:quester_client/core/utils/logger_util.dart';
import 'package:quester_client/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/auth_service.dart';
import '../services/installation_id_service.dart';

// ── SharedPreferences ────────────────────────────────────────────────────────
// FutureProvider because getInstance() is async
// Riverpod caches this — only ever one instance, created once
final sharedPreferencesProvider = FutureProvider<SharedPreferences>(
  (ref) async => SharedPreferences.getInstance(),
);

final secureStorageProvider = Provider<FlutterSecureStorage>(
  (ref) => const FlutterSecureStorage(),
);

final installationIdServiceProvider = FutureProvider<InstallationIdService>(
  (ref) async =>
      InstallationIdService(await ref.read(sharedPreferencesProvider.future)),
);

final authServiceProvider = FutureProvider<AuthService>(
  (ref) async => AuthService(
    await ref.read(installationIdServiceProvider.future),
    await ref.read(apiClientProvider.future),
    ref.read(secureStorageProvider),
    await ref.read(sharedPreferencesProvider.future),
  ),
);

final installationIdProvider = FutureProvider<String>((ref) async {
  final installationIdService = await ref.read(
    installationIdServiceProvider.future,
  );
  return installationIdService
      .getOrCreateInstallationId(); // directly call the method here
});

final apiClientProvider = FutureProvider<ApiClient>((ref) async {
  final buildConfig = ref.read(buildConfigProvider);
  final installationId = await ref
      .read(installationIdProvider.future)
      .catchError((e) {
        throw Exception('Failed to get installation ID: $e');
      });
  return ApiClient(buildConfig.apiBaseUrl, installationId);
});

final syncServiceProvider = FutureProvider<SyncService>((ref) async {
  final db = ref.watch(databaseProvider).requireValue;
  final apiClient = await ref.watch(apiClientProvider.future);
  return SyncService(db, apiClient);
});

final buildConfigProvider = Provider<BuildConfig>((ref) {
  throw UnimplementedError('buildConfigProvider must be overridden in main()');
});

final firebaseFutureProvider = Provider<Future<FirebaseApp>>((ref) {
  throw UnimplementedError(
    'firebaseFutureProvider must be overridden in main()',
  );
});

final fcmTokenProvider = FutureProvider<String?>((ref) async {
  final firebaseApp = await ref.watch(firebaseFutureProvider);
  logger.d('Firebase app in fcmTokenProvider: ${firebaseApp.name}');
  final fcmToken = await FirebaseMessaging.instance.getToken(
    vapidKey: ref.watch(buildConfigProvider).vapidKey,
  );
  final prefsAsync = await ref.watch(sharedPreferencesProvider.future);
  await prefsAsync.setString('fcm_token', fcmToken ?? '');
  return fcmToken;
});
