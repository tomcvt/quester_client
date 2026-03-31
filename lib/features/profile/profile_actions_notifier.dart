import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quester_client/core/providers/core_providers.dart';
import 'package:quester_client/core/providers/profile_providers.dart';

class ProfileActionsNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> changeUsername(String newUsername) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authServiceProvider).changeUsername(newUsername);
      ref.read(usernameProvider.notifier).set(newUsername);
    });
  }
}

final profileActionsProvider =
    AsyncNotifierProvider<ProfileActionsNotifier, void>(
      ProfileActionsNotifier.new,
    );
