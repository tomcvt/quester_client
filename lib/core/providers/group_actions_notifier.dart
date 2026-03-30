import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quester_client/core/providers/service_providers.dart';

class GroupActionsNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> leaveGroup(String groupPublicId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(groupsServiceProvider).leaveGroup(groupPublicId);
    });
  }
}

final groupActionsProvider = AsyncNotifierProvider<GroupActionsNotifier, void>(
  GroupActionsNotifier.new,
);
