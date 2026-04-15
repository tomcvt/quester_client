import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quester_client/core/providers/service_providers.dart';
import 'package:quester_client/core/services/sync_service.dart';

class GroupActionsNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> leaveGroup(String groupId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final groupsService = await ref.read(groupsServiceProvider.future);
      await groupsService.leaveGroup(groupId);
    });
  }

  Future<void> syncGroupMembers(String groupId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final syncService = await ref.read(syncServiceProvider.future);
      await syncService.syncUsersAndGroupMembersForGroupById(
        int.parse(groupId),
      );
    });
  }
}

final groupActionsProvider = AsyncNotifierProvider<GroupActionsNotifier, void>(
  GroupActionsNotifier.new,
);
