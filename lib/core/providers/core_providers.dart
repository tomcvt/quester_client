// lib/core/providers/core_providers.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quester_client/core/http/api_client.dart';
import 'package:quester_client/core/providers/data_providers.dart';
import 'package:quester_client/core/services/app_initializer.dart';
import 'package:quester_client/core/services/sync_service.dart';
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

final installationIdServiceProvider = Provider<InstallationIdService>(
  (ref) => InstallationIdService(
    ref
        .watch(sharedPreferencesProvider)
        .maybeWhen(
          data: (prefs) => prefs,
          orElse: () => throw Exception('SharedPreferences not available'),
        ),
  ),
);

final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(
    ref.watch(
      installationIdServiceProvider,
    ), // pass the notifier to getOrCreateInstallationId()
    ref.watch(apiClientProvider),
    ref.watch(secureStorageProvider),
    ref
        .watch(sharedPreferencesProvider)
        .maybeWhen(
          data: (prefs) => prefs,
          orElse: () => throw Exception('SharedPreferences not available'),
        ),
  ),
);

final installationIdProvider = FutureProvider<String>((ref) {
  return ref
      .watch(installationIdServiceProvider)
      .getOrCreateInstallationId(); // directly call the method here
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final buildConfig = ref.watch(buildConfigProvider);
  final installationId = ref
      .watch(installationIdProvider)
      .maybeWhen(
        data: (id) => id,
        orElse: () => throw Exception('Installation ID not available'),
      );
  return ApiClient(buildConfig.apiBaseUrl, installationId);
});

final syncServiceProvider = Provider<SyncService>((ref) {
  final db = ref.watch(databaseProvider).requireValue;
  final apiClient = ref.watch(apiClientProvider);
  return SyncService(db, apiClient);
});

final buildConfigProvider = Provider<BuildConfig>((ref) {
  throw UnimplementedError('buildConfigProvider must be overridden in main()');
});

final firebaseFutureProvider = Provider<Future<FirebaseApp>>((ref) {
  return Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
});

final fcmTokenProvider = FutureProvider<String?>((ref) async {
  final fcmToken = await FirebaseMessaging.instance.getToken(
    vapidKey: ref.watch(buildConfigProvider).vapidKey,
  );
  final prefsAsync = await ref.watch(sharedPreferencesProvider.future);
  await prefsAsync.setString('fcm_token', fcmToken ?? '');
  return fcmToken;
});
