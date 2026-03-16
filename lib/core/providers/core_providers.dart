// lib/core/providers/core_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quester_client/core/http/api_client.dart';
import 'package:quester_client/core/services/app_initializer.dart';
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

/*

class InstallationIdNotifier extends AsyncNotifier<String> {
  @override
  Future<String> build() async {
    // ref.watch inside AsyncNotifier = safe, lifecycle managed by Riverpod
    // will wait for sharedPreferencesProvider to resolve before continuing
    final prefs = await ref.watch(
      sharedPreferencesProvider.future, // .future unwraps AsyncValue → Future
    );

    return InstallationIdService(prefs).getOrCreateInstallationId();
  }
}

*/

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
  ),
);

final installationIdProvider = Provider<String>((ref) {
  throw UnimplementedError(
    'installationIdProvider must be overridden in main()',
  );
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final installationId = ref.watch(installationIdProvider);
  return ApiClient(AppInitializer.buildConfig.apiBaseUrl, installationId);
});
