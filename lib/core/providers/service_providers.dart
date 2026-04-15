import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quester_client/core/providers/core_providers.dart';
import 'package:quester_client/core/providers/data_providers.dart';
import 'package:quester_client/core/services/groups_service.dart';
import 'package:quester_client/core/services/quests_service.dart';

final groupsServiceProvider = FutureProvider<GroupsService>((ref) async {
  final groupsDao = ref.read(groupsDaoProvider);
  final groupMembersDao = ref.read(groupMembersDaoProvider);
  final usersDao = ref.read(usersDaoProvider);
  final apiClient = await ref.read(apiClientProvider.future);
  return GroupsService(groupsDao, groupMembersDao, usersDao, apiClient);
});

final questsServiceProvider = FutureProvider<QuestsService>((ref) async {
  final questsDao = ref.read(questsDaoProvider);
  final groupsDao = ref.read(groupsDaoProvider);
  final apiClient = await ref.read(apiClientProvider.future);
  return QuestsService(questsDao, groupsDao, apiClient);
});
