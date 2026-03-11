// lib/core/providers/auth_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core_providers.dart';

class AuthNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    // orchestrates, delegates to service
    final token = await ref.watch(authServiceProvider).initialize();
    return token != null;
  }

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
