// lib/core/auth/auth_event_bus.dart

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quester_client/core/models/auth.dart';

/// Events emitted by [AuthEventBus] to coordinate auth state changes
/// between the HTTP layer ([AuthInterceptor]) and the state layer ([AuthNotifier]).
sealed class AuthEvent {
  const AuthEvent();
}

/// The refresh token was rejected or is missing — the user must log in again.
class SessionExpired extends AuthEvent {
  const SessionExpired();
}

/// A 401 was received, the access token was silently refreshed via the
/// refresh-session endpoint, and the original request was retried successfully.
///
/// [session] contains the full refreshed session data from the server response,
/// so [AuthNotifier] can update its state without an extra network round-trip.
class AccessTokenRefreshed extends AuthEvent {
  final SessionData session;
  const AccessTokenRefreshed(this.session);
}

class AuthEventBus {
  final _controller = StreamController<AuthEvent>.broadcast();

  Stream<AuthEvent> get events => _controller.stream;

  void emit(AuthEvent event) => _controller.add(event);

  void dispose() => _controller.close();
}

final authEventBusProvider = Provider<AuthEventBus>((ref) {
  final bus = AuthEventBus();
  ref.onDispose(bus.dispose);
  return bus;
});
