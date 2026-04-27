import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quester_client/core/models/app_auth_state.dart';
import 'package:quester_client/core/models/auth.dart';
import 'package:quester_client/core/providers/auth_provider.dart';
import 'package:quester_client/core/services/app_initializer.dart';
import 'package:quester_client/core/utils/logger_util.dart';

class UsernameNotifier extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async {
    final appAuthState = await ref.watch(authProvider.future).catchError((e) {
      // Log the error and return null to indicate no username
      logger.e('Failed to load session data: $e');
      return SessionData.empty(); // Return an empty session to avoid null issues
    });
    switch (appAuthState) {
      case Authenticated(session: final session):
        return session.username;
      case AuthenticatedOffline(cachedUsername: final cachedUsername):
        return cachedUsername;
      case CannotAuthenticate():
        return null;
    }
  }
}

final usernameProvider = AsyncNotifierProvider<UsernameNotifier, String?>(
  UsernameNotifier.new,
);

class PhoneNumberNotifier extends Notifier<String?> {
  @override
  String? build() => AppInitializer.sessionData.phoneNumber;

  void set(String newPhoneNumber) {
    state = newPhoneNumber;
  }
}

final phoneNumberProvider = NotifierProvider<PhoneNumberNotifier, String?>(
  PhoneNumberNotifier.new,
);
