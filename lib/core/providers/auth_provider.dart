// lib/core/providers/auth_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';


final authProvider = AsyncNotifierProvider<

/*
// Mock auth state — later this reads from flutter_secure_storage
// true = has token, false = no token
class AuthNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    // Simulate secure storage read
    await Future.delayed(const Duration(seconds: 1));
    return false; // mock: not logged in
  }

  // Called after successful login — sets token in secure storage later
  Future<void> login() async {
    // optimistically set loading while we "save token"
    state = const AsyncValue.loading();
    await Future.delayed(const Duration(milliseconds: 500)); // mock save
    state = const AsyncValue.data(true);
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    await Future.delayed(const Duration(milliseconds: 300)); // mock clear
    state = const AsyncValue.data(false);
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, bool>(
  AuthNotifier.new,
);

*/