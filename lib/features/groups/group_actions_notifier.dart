import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quester_client/core/data/data_tables.dart';
import 'package:quester_client/core/providers/service_providers.dart';
import 'package:quester_client/core/services/sync_service.dart';

class GroupActionsNotifier extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async => null;

  /// Call after the UI has consumed the success message so the next
  /// identical message fires the listener again.
  void reset() => state = const AsyncData(null);

  Future<void> leaveGroup(String groupId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final groupsService = await ref.read(groupsServiceProvider.future);
      await groupsService.leaveGroup(groupId);
      return 'Left group';
    });
  }

  Future<void> syncGroupMembers(String groupId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final syncService = await ref.read(syncServiceProvider.future);
      await syncService.syncUsersAndGroupMembersForGroupById(
        int.parse(groupId),
      );
      return 'Members synced';
    });
  }

  Future<void> setMemberRole(
    String groupId,
    String userPublicId,
    MemberRole newRole,
  ) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final groupsService = await ref.read(groupsServiceProvider.future);
      await groupsService.setMemberRole(groupId, userPublicId, newRole);
      return 'Role updated';
    });
  }
}

final groupActionsProvider =
    AsyncNotifierProvider<GroupActionsNotifier, String?>(
      GroupActionsNotifier.new,
    );
