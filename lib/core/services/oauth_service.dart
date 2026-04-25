import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

class OAuthService {
  Future<void> initialize({required String serverClientId}) async {
    await GoogleSignIn.instance.initialize(serverClientId: serverClientId);
  }

  /// The raw event stream — AuthNotifier listens to this for the lifetime
  /// of the app. Catches both explicit sign-ins and future silent re-auth.
  /// Adding attemptLightweightAuthentication() later is one line —
  /// everything listening here will just work.
  Stream<GoogleSignInAuthenticationEvent> get authEvents =>
      GoogleSignIn.instance.authenticationEvents;

  Future<GoogleSignInAccount?> signIn() async {
    try {
      return await GoogleSignIn.instance.authenticate();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      rethrow;
    }
  }

  ///Actual code below useless
  /*
  Future<GoogleSignInAccount?> signInWithGoogleOneTap() async {
    final completer = Completer<GoogleSignInAccount?>();

    // Subscribe BEFORE authenticate() — the event can fire very quickly
    // and we cannot afford to miss it. Same reason you set up a Flow
    // collector before triggering the emission.
    late StreamSubscription<GoogleSignInAuthenticationEvent> sub;
    sub = GoogleSignIn.instance.authenticationEvents.listen(
      (event) async {
        // One event only — unsubscribe immediately so we don't catch
        // any future sign-out or unrelated events on this stream.
        await sub.cancel();
        switch (event) {
          case GoogleSignInAuthenticationEventSignIn():
            completer.complete(event.user);
          case GoogleSignInAuthenticationEventSignOut():
            // Shouldn't happen here but handle safely
            completer.complete(null);
        }
      },
      onError: (Object e) async {
        await sub.cancel();
        completer.completeError(e);
      },
    );

    try {
      await GoogleSignIn.instance.authenticate();
    } catch (e) {
      // authenticate() threw before stream fired — e.g. user cancelled
      // on some platforms this comes as an exception rather than an event
      await sub.cancel();
      if (!completer.isCompleted) completer.complete(null);
    }

    // Suspends here until completer.complete() is called from the listener.
    // From the caller's perspective this is a plain awaitable method.
    return completer.future;
  }
  */

  Future<void> signOut() => GoogleSignIn.instance.disconnect();

  // ONE LINE to enable silent re-auth later — AuthNotifier.build() listener
  // catches the result automatically, nothing else changes.
  // void attemptSilentSignIn() =>
  //     GoogleSignIn.instance.attemptLightweightAuthentication();
}
