import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quester_client/core/providers/core_providers.dart';
import 'package:quester_client/core/providers/data_providers.dart';
import 'package:quester_client/core/services/groups_service.dart';
import 'package:quester_client/core/services/quests_service.dart';

final groupsServiceProvider = FutureProvider<GroupsService>((ref) async {
  final groupsDao = ref.watch(groupsDaoProvider);
  final groupMembersDao = ref.watch(groupMembersDaoProvider);
  final usersDao = ref.watch(usersDaoProvider);
  final apiClient = await ref.watch(apiClientProvider.future);
  return GroupsService(groupsDao, groupMembersDao, usersDao, apiClient);
});

final questsServiceProvider = FutureProvider<QuestsService>((ref) async {
  final questsDao = ref.watch(questsDaoProvider);
  final groupsDao = ref.watch(groupsDaoProvider);
  final apiClient = await ref.watch(apiClientProvider.future);
  return QuestsService(questsDao, groupsDao, apiClient);
});
