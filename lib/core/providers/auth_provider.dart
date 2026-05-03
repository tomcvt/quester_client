// lib/core/providers/auth_provider.dart

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:quester_client/core/constants/const.dart';
import 'package:quester_client/core/models/app_auth_state.dart';
import 'package:quester_client/core/models/auth.dart';
import 'package:quester_client/core/services/app_initializer.dart';
import 'package:quester_client/core/services/auth_service.dart';
import 'package:quester_client/core/utils/logger_util.dart';
import 'core_providers.dart';

class AuthNotifier extends AsyncNotifier<AppAuthState> {
  @override
  Future<AppAuthState> build() async {
    // Wire Google auth stream for the lifetime of this notifier.
    // Riverpod cancels this automatically when the notifier is disposed —
    // same as collecting a Flow in viewModelScope, no manual cleanup needed.
    //
    // This listener catches ALL Google sign-in events:
    //   - Explicit sign-in from ProfileActionsNotifier button tap
    //   - Future silent re-auth (attemptLightweightAuthentication) — just
    //     uncomment that one line in OAuthService and this works instantly
    final oauthService = await ref.read(oauthServiceProvider.future);
    ref.listen(
      // StreamProvider wrapping the raw Google event stream
      googleAuthEventProvider,
      (_, next) {
        next.whenData((event) async {
          if (event is GoogleSignInAuthenticationEventSignIn) {
            final user = event.user;
            final displayName = user.displayName;
            final email = user.email;
            logger.i('Google sign-in event: $displayName <$email>');
            await _handleOAuthEvent(user);
          }
        });
      },
    );

    // ── Your existing init flow, unchanged ──────────────────────────────
    final secureStorage = ref.read(secureStorageProvider);
    final prefs = await ref.read(sharedPreferencesProvider.future);
    final apiKey = await secureStorage.read(key: apiKeyKey);

    try {
      final authService = await ref.read(authServiceProvider.future);
      final installationId = await ref.read(installationIdProvider.future);

      // Use the cached FCM token from prefs (instant) — don't block auth on
      // FirebaseMessaging.getToken() which can take up to minutes.
      // The fresh token is fetched in the background after auth succeeds.
      final cachedFcmToken = prefs.getString(fcmTokenKey);

      final session = await authService.initialize(
        installationId,
        fcmToken: cachedFcmToken,
      );

      if (session.sessionToken.isEmpty) {
        // initialize() swallowed an error and returned empty —
        // treat same as network failure
        return _offlineOrCannot(prefs);
      }

      // Cache what we need for offline fallback
      await prefs.setString(usernameKey, session.username ?? '');
      await prefs.setString(publicIdKey, session.publicId);

      // Background: fetch fresh FCM token; update server if it changed.
      // Fire-and-forget — does not block the splash-to-home transition.
      unawaited(_refreshFcmTokenAsync(cachedFcmToken, installationId));

      return Authenticated(session);
    } catch (e) {
      logger.e('Auth init failed: $e');
      return _offlineOrCannot(prefs);
    }
  }

  /// Fetches a fresh FCM token in the background (without blocking auth/startup).
  /// If the token changed, updates the server via updateFcmToken.
  Future<void> _refreshFcmTokenAsync(
    String? cachedFcmToken,
    String installationId,
  ) async {
    try {
      final freshToken = await ref.read(fcmTokenProvider.future);
      if (freshToken == null || freshToken.isEmpty) return;
      if (freshToken == cachedFcmToken) {
        logger.d('FCM token unchanged, skipping server update');
        return;
      }
      logger.i('FCM token changed, updating server in background');
      final apiClient = await ref.read(apiClientProvider.future);
      await apiClient.updateFcmToken(installationId, freshToken);
      logger.i('FCM token updated on server');
    } catch (e) {
      logger.w('Background FCM token refresh failed (non-fatal): $e');
    }
  }

  AppAuthState _offlineOrCannot(prefs) {
    final cachedUsername = prefs.getString(usernameKey);
    final cachedPublicId = prefs.getString(publicIdKey);
    if (cachedUsername != null && cachedPublicId != null) {
      return AuthenticatedOffline(
        cachedUsername: cachedUsername,
        cachedPublicId: cachedPublicId,
      );
    }
    return const CannotAuthenticate();
  }

  /// Called from the Google auth stream listener.
  /// Does NOT set AsyncLoading — the user is mid-flow in the profile screen
  /// and we don't want to blank the UI. Loading state lives in
  /// ProfileActionsNotifier which owns the button feedback.
  Future<void> _handleOAuthEvent(GoogleSignInAccount googleUser) async {
    // Only handle if we have a usable auth state — linking needs a server call
    final current = state.value;
    if (current == null || current is CannotAuthenticate) return;

    try {
      final oauthService = await ref.read(oauthServiceProvider.future);
      final idToken = googleUser.authentication.idToken;
      if (idToken == null) return;

      final authService = await ref.read(authServiceProvider.future);
      final updatedSession = await authService.authenticateWithOAuth(
        idToken,
        googleUser.email,
      );

      state = AsyncData(Authenticated(updatedSession));
      logger.i('OAuth linked successfully: ${updatedSession.oauthProvider}');
    } catch (e) {
      // Don't change sealed state — user stays authenticated as before.
      // Error surfaces in ProfileActionsNotifier via its own guard.
      logger.e('OAuth event handling failed: $e');
    }
  }

  /// Called by ProfileActionsNotifier after changeUsername succeeds
  Future<void> setUsername(String newUsername) async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setString(usernameKey, newUsername);
    state = state.whenData(
      (auth) => switch (auth) {
        Authenticated(session: final s) => Authenticated(
          s.copyWith(username: newUsername),
        ),
        AuthenticatedOffline() => AuthenticatedOffline(
          //this shouldnt happen, change username is guarded in change username actions notifier
          // so we just return the same cached username, we cant update it without a server call anyway
          cachedUsername: auth.cachedUsername,
          cachedPublicId: auth.cachedPublicId,
        ),
        CannotAuthenticate() => auth,
      },
    );
  }

  Future<void> updateSession(SessionData updatedSession) async {
    state = AsyncData(Authenticated(updatedSession));
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, AppAuthState>(
  AuthNotifier.new,
);

final googleAuthEventProvider = StreamProvider<GoogleSignInAuthenticationEvent>(
  (ref) async* {
    final oauthService = await ref.watch(oauthServiceProvider.future);
    yield* oauthService.authEvents;
  },
);

/// Convenience provider — use this in UI instead of drilling into authProvider.
/// Returns null while auth is loading or when not logged in.
///
/*
final currentUserPublicIdProvider = Provider<String?>((ref) {
  return ref
      .watch(authProvider)
      .maybeWhen(data: (session) => session.publicId, orElse: () => null);
});
*/

final currentUserPublicIdProvider = Provider<String?>((ref) {
  return ref.watch(
    authProvider.select((async) {
      return switch (async.value) {
        Authenticated(session: final s) => s.publicId,
        AuthenticatedOffline(cachedPublicId: final id) => id,
        _ => null,
      };
    }),
  );
});
/*
final meUserPublicId = ref.watch(
  authProvider.select((async) => async.valueOrNull?.publicId),
);
*/
