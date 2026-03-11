// lib/features/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/auth_provider.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: Center(
        child: authState.isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: () => ref
                    .read(authProvider.notifier)
                    .login("username", "password"),
                child: const Text('Mock Login'),
              ),
      ),
    );
  }
}
