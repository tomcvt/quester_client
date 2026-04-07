// lib/core/providers/auth_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quester_client/core/models/auth.dart';
import 'package:quester_client/core/services/app_initializer.dart';
import 'core_providers.dart';

class AuthNotifier extends AsyncNotifier<SessionData> {
  @override
  Future<SessionData> build() async {
    // AppInitializer.init() already ran auth before runApp — just expose the result.
    // This avoids a second authenticate call on every app start.
    return AppInitializer.sessionData;
  }

  Future<void> login(String username, String password) async {
    state = const AsyncValue.loading();
    final session = await ref
        .read(authServiceProvider)
        .login(username, password);
    state = AsyncValue.data(session);
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    await ref.read(authServiceProvider).logout();
    state = const AsyncValue.data(SessionData.empty());
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, SessionData>(
  AuthNotifier.new,
);

/// Convenience provider — use this in UI instead of drilling into authProvider.
/// Returns null while auth is loading or when not logged in.
final currentUserPublicIdProvider = Provider<String?>((ref) {
  return ref
      .watch(authProvider)
      .maybeWhen(data: (session) => session.publicId, orElse: () => null);
});
