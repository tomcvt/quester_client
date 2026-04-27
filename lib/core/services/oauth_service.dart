import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class OAuthService {
  bool get supportsExplicitSignIn => !kIsWeb;
  bool _explicitSignInInProgress = false;

  Future<void> initialize({
    required String serverClientId,
    String? webClientId,
  }) async {
    await GoogleSignIn.instance.initialize(
      serverClientId: kIsWeb ? null : serverClientId,
      clientId: kIsWeb ? webClientId : null,
    );
  }

  /// The raw event stream — AuthNotifier listens to this for the lifetime
  /// of the app. Catches both explicit sign-ins and future silent re-auth.
  /// Adding attemptLightweightAuthentication() later is one line —
  /// everything listening here will just work.
  Stream<GoogleSignInAuthenticationEvent> get authEvents => GoogleSignIn
      .instance
      .authenticationEvents
      .where((event) => !_explicitSignInInProgress);

  Future<GoogleSignInAccount?> signIn() async {
    try {
      _explicitSignInInProgress = true;
      return await GoogleSignIn.instance.authenticate();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      rethrow;
    } finally {
      _explicitSignInInProgress = false;
    }
  }

  Future<void> signOut() => GoogleSignIn.instance.disconnect();

  // ONE LINE to enable silent re-auth later — AuthNotifier.build() listener
  // catches the result automatically, nothing else changes.
  // void attemptSilentSignIn() =>
  //     GoogleSignIn.instance.attemptLightweightAuthentication();
}
