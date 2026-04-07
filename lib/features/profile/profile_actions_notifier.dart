import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quester_client/core/providers/core_providers.dart';
import 'package:quester_client/core/providers/profile_providers.dart';

class ProfileActionsNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> changeUsername(String newUsername) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authServiceProvider).changeUsername(newUsername);
      ref.read(usernameProvider.notifier).set(newUsername);
    });
  }

  Future<void> changePhoneNumber(String newPhoneNumber) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authServiceProvider).changePhoneNumber(newPhoneNumber);
      ref.read(phoneNumberProvider.notifier).set(newPhoneNumber);
    });
  }
}

final profileActionsProvider =
    NotifierProvider<ProfileActionsNotifier, AsyncValue<void>>(
      ProfileActionsNotifier.new,
    );
