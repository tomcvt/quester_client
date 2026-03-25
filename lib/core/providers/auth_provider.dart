// lib/core/providers/auth_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quester_client/core/models/auth.dart';
import 'package:quester_client/core/services/app_initializer.dart';
import 'core_providers.dart';

class AuthNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    // orchestrates, delegates to service
    final SessionData sessionData = await ref
        .watch(authServiceProvider)
        .initialize(
          AppInitializer.installationId,
          fcmToken: AppInitializer.fcmToken,
        );
    return sessionData.sessionToken.isNotEmpty;
  }
  //TODO bool -> session data and observe that in UI, handle errors, etc.

  Future<void> login(String username, String password) async {
    state = const AsyncValue.loading();
    await ref.read(authServiceProvider).login(username, password);
    state = const AsyncValue.data(true);
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    await ref.read(authServiceProvider).logout();
    state = const AsyncValue.data(false);
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, bool>(
  AuthNotifier.new,
);
