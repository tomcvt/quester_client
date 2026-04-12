import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quester_client/core/providers/core_providers.dart';
import 'package:quester_client/core/providers/profile_providers.dart';
import 'package:quester_client/core/utils/logger_util.dart';

class ProfileActionsNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> changeUsername(String newUsername) async {
    state = const AsyncLoading();
    logger.d('Attempting to change username to: $newUsername');
    state = await AsyncValue.guard(() async {
      await ref.read(authServiceProvider).changeUsername(newUsername);
      logger.d('Username changed to: $newUsername');
      ref.read(usernameProvider.notifier).set(newUsername);
      logger.d('Username provider updated with new username: $newUsername');
    });
  }

  Future<void> changePhoneNumber(String newPhoneNumber) async {
    state = const AsyncLoading();
    logger.d('Attempting to change phone number to: $newPhoneNumber');
    state = await AsyncValue.guard(() async {
      await ref.read(authServiceProvider).changePhoneNumber(newPhoneNumber);
      ref.read(phoneNumberProvider.notifier).set(newPhoneNumber);
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
      await ref
          .read(authServiceProvider)
          .changeUsernameAndPhoneNumber(newUsername, newPhoneNumber);
      logger.d('Username changed to: $newUsername');
      ref.read(usernameProvider.notifier).set(newUsername);
      logger.d('Username provider updated with new username: $newUsername');
      logger.d('Phone number changed to: $newPhoneNumber');
      ref.read(phoneNumberProvider.notifier).set(newPhoneNumber);
      logger.d(
        'Phone number provider updated with new phone number: $newPhoneNumber',
      );
    });
  }
}

final profileActionsProvider =
    NotifierProvider<ProfileActionsNotifier, AsyncValue<void>>(
      ProfileActionsNotifier.new,
    );
