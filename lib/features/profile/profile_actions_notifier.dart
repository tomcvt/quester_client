import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quester_client/core/providers/auth_provider.dart';
import 'package:quester_client/core/providers/core_providers.dart';
import 'package:quester_client/core/providers/profile_providers.dart';
import 'package:quester_client/core/utils/logger_util.dart';

class ProfileActionsNotifier extends Notifier<AsyncValue<String?>> {
  @override
  AsyncValue<String?> build() => const AsyncData(null);

  void reset() => state = const AsyncData(null);

  Future<void> changeUsername(String newUsername) async {
    state = const AsyncLoading();
    logger.d('Attempting to change username to: $newUsername');
    state = await AsyncValue.guard(() async {
      final authService = await ref.read(authServiceProvider.future);
      await authService.changeUsername(newUsername);
      ref.read(authProvider.notifier).setUsername(newUsername);
      logger.d('Username provider updated with new username: $newUsername');
      return 'Username changed to: $newUsername';
    });
  }

  Future<void> changePhoneNumber(String newPhoneNumber) async {
    state = const AsyncLoading();
    logger.d('Attempting to change phone number to: $newPhoneNumber');
    state = await AsyncValue.guard(() async {
      final authService = await ref.read(authServiceProvider.future);
      await authService.changePhoneNumber(newPhoneNumber);
      ref.read(phoneNumberProvider.notifier).set(newPhoneNumber);
      return 'Phone number changed to: $newPhoneNumber';
    });
  }

  Future<void> changeUsernamePhone(
    String newUsername,
    String newPhoneNumber,
  ) async {
    state = const AsyncLoading();
    logger.d(
      'Attempting to change username and phone number. New username: $newUsername, New phone number: $newPhoneNumber',
    );
    state = await AsyncValue.guard(() async {
      final authService = await ref.read(authServiceProvider.future);
      await authService.changeUsernameAndPhoneNumber(
        newUsername,
        newPhoneNumber,
      );
      logger.d('Username changed to: $newUsername');
      ref.read(usernameProvider.notifier).set(newUsername);
      logger.d('Username provider updated with new username: $newUsername');
      logger.d('Phone number changed to: $newPhoneNumber');
      ref.read(phoneNumberProvider.notifier).set(newPhoneNumber);
      logger.d(
        'Phone number provider updated with new phone number: $newPhoneNumber',
      );
      return 'Username changed to: $newUsername, Phone number changed to: $newPhoneNumber';
    });
  }
}

final profileActionsProvider =
    NotifierProvider<ProfileActionsNotifier, AsyncValue<String?>>(
      ProfileActionsNotifier.new,
    );
