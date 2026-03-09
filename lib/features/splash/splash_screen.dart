import 'package:flutter/material.dart';

// No longer needs to be ConsumerWidget — it's just a loading screen
// GoRouter redirect handles the navigation automatically
// when authProvider resolves, _RouterNotifier fires, redirect re-evaluates
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}



/*

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final installationIdState = ref.watch(installationIdProvider);

    // .when() on AsyncValue — your Kotlin when() on sealed class
    return Scaffold(
      body: Center(
        child: installationIdState.when(
          loading: () => const CircularProgressIndicator(),

          data: (installationId) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Installation ID',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                installationId,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          error: (error, stack) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text('Failed to initialize: $error', textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

*/