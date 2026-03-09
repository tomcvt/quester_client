// lib/core/router/router.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/home/home_screen.dart';

// GoRouter needs a Listenable to know when to re-evaluate redirect
// This bridges Riverpod's AsyncNotifier to GoRouter's refresh system
// Think of it as an event bus between Riverpod and GoRouter
class _RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  _RouterNotifier(this._ref) {
    // listen() = fire and forget observation, no rebuild
    // we don't need to rebuild a widget, just notify GoRouter
    _ref.listen(authProvider, (_, __) => notifyListeners());
  }
}

// RouterProvider so we can access router anywhere if needed
final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);

  return GoRouter(
    initialLocation: '/splash',
    // refreshListenable = "re-run redirect whenever this fires"
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isSplash = state.matchedLocation == '/splash';

      // Still loading auth — stay on splash
      if (authState.isLoading) return isSplash ? null : '/splash';

      final isLoggedIn = authState.value ?? false;

      // On splash and auth resolved — redirect to correct screen
      if (isSplash) return isLoggedIn ? '/home' : '/login';

      // Not on splash — guard home route
      if (!isLoggedIn && state.matchedLocation == '/home') return '/login';

      // Already on login and logged in — go home
      if (isLoggedIn && state.matchedLocation == '/login') return '/home';

      return null; // proceed
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
    ],
  );
});
