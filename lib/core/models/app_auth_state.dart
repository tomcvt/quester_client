// lib/core/models/app_auth_state.dart

import 'package:quester_client/core/models/auth.dart';

sealed class AppAuthState {
  const AppAuthState();
}

/// Server responded — full fresh session
class Authenticated extends AppAuthState {
  final SessionData session;
  const Authenticated(this.session);

  String? get username => session.username;
  String? get oauthProvider =>
      session.oauthProvider; // nullable — not linked yet
}

/// Has apiKey locally but server unreachable on startup
class AuthenticatedOffline extends AppAuthState {
  final String cachedUsername;
  final String cachedPublicId;
  const AuthenticatedOffline({
    required this.cachedUsername,
    required this.cachedPublicId,
  });
}

/// First ever launch AND no network — nothing we can do
class CannotAuthenticate extends AppAuthState {
  const CannotAuthenticate();
}
