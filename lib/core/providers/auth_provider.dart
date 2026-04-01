// lib/core/providers/auth_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quester_client/core/models/auth.dart';
import 'package:quester_client/core/services/app_initializer.dart';
import 'core_providers.dart';

class AuthNotifier extends AsyncNotifier<SessionData> {
  @override
  Future<SessionData> build() async {
    // orchestrates, delegates to service
    final SessionData sessionData = await ref
        .watch(authServiceProvider)
        .initialize(
          AppInitializer.installationId,
          fcmToken: AppInitializer.fcmToken,
        );
    return sessionData;
  }
  //TODO bool -> session data and observe that in UI, handle errors, etc.

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
    state = const AsyncValue.data(const SessionData.empty());
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, SessionData>(
  AuthNotifier.new,
);
