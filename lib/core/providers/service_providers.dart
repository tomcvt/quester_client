import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quester_client/core/providers/data_providers.dart';
import 'package:quester_client/core/services/groups_service.dart';

final groupsServiceProvider = Provider<GroupsService>((ref) {
  final groupsDao = ref.watch(groupsDaoProvider);
  return GroupsService(groupsDao);
});
