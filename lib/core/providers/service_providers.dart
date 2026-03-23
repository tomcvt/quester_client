import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quester_client/core/providers/core_providers.dart';
import 'package:quester_client/core/providers/data_providers.dart';
import 'package:quester_client/core/services/groups_service.dart';
import 'package:quester_client/core/services/quests_service.dart';

final groupsServiceProvider = Provider<GroupsService>((ref) {
  final groupsDao = ref.watch(groupsDaoProvider);
  final groupMembersDao = ref.watch(groupMembersDaoProvider);
  final apiClient = ref.watch(apiClientProvider);
  return GroupsService(groupsDao, groupMembersDao, apiClient);
});

final questsServiceProvider = Provider<QuestsService>((ref) {
  final questsDao = ref.watch(questsDaoProvider);
  final groupsDao = ref.watch(groupsDaoProvider);
  final apiClient = ref.watch(apiClientProvider);
  return QuestsService(questsDao, groupsDao, apiClient);
});
