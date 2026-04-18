// lib/core/providers/auth_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quester_client/core/models/auth.dart';
import 'package:quester_client/core/services/app_initializer.dart';
import 'package:quester_client/core/services/auth_service.dart';
import 'package:quester_client/core/utils/logger_util.dart';
import 'core_providers.dart';

class AuthNotifier extends AsyncNotifier<SessionData> {
  @override
  Future<SessionData> build() async {
    final authService = await ref.read(authServiceProvider.future);
    final installationId = await ref.read(installationIdProvider.future);
    final firebaseApp = await ref.read(firebaseFutureProvider);
    final fcmToken = await ref.read(fcmTokenProvider.future);
    logger.d('Firebase app in AuthNotifier: ${firebaseApp.name}');
    final sessionData = await authService.initialize(
      installationId,
      fcmToken: fcmToken,
    );
    if (sessionData.sessionToken.isEmpty) {
      logger.w('No session token received during authentication');
      return const SessionData.empty();
    }
    return sessionData;
  }

  Future<void> setUsername(String newUsername) async {
    state = state.whenData(
      (session) => session.copyWith(username: newUsername),
    );
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, SessionData>(
  AuthNotifier.new,
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
    authProvider.select((async) => async.unwrapPrevious().value?.publicId),
  );
});
/*
final meUserPublicId = ref.watch(
  authProvider.select((async) => async.valueOrNull?.publicId),
);
*/
