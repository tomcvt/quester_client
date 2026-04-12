import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quester_client/core/providers/service_providers.dart';
import 'package:quester_client/core/services/sync_service.dart';

class GroupActionsNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> leaveGroup(String groupId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(groupsServiceProvider).leaveGroup(groupId);
    });
  }

  Future<void> syncGroupMembers(String groupId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(syncServiceProvider)
          .syncUsersAndGroupMembersForGroupById(int.parse(groupId));
    });
  }
}

final groupActionsProvider = AsyncNotifierProvider<GroupActionsNotifier, void>(
  GroupActionsNotifier.new,
);
