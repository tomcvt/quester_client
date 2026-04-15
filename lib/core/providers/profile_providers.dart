import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quester_client/core/models/auth.dart';
import 'package:quester_client/core/providers/auth_provider.dart';
import 'package:quester_client/core/services/app_initializer.dart';
import 'package:quester_client/core/utils/logger_util.dart';

class UsernameNotifier extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async {
    final session = await ref.watch(authProvider.future).catchError((e) {
      // Log the error and return null to indicate no username
      logger.e('Failed to load session data: $e');
      return SessionData.empty(); // Return an empty session to avoid null issues
    });
    return session.username;
  }

  void set(String newUsername) {
    ref.read(authProvider.notifier).update((session) {
      if (session == SessionData.empty()) {
        logger.w('Attempted to set username, but session is empty');
        return session; // No session, can't update
      }
      final updatedSession = session.copyWith(username: newUsername);
      logger.d('Updated username in session: $newUsername');
      return updatedSession;
    });
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
