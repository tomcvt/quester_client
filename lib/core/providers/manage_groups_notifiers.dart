import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quester_client/core/data/app_database.dart';
import 'package:quester_client/core/providers/service_providers.dart';
import 'package:quester_client/core/utils/logger_util.dart';

class AddGroupNotifier extends AsyncNotifier<Group?> {
  @override
  Future<Group?> build() async {
    return null; // idle on start
  }

  Future<Group?> createGroup(String name, String password) async {
    logger.d('createGroup called: $name');
    final groupsService = ref.read(groupsServiceProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () async {
        final group = await groupsService.createGroup(name, password);
        logger.d('Group: $group');
        logger.d('Group creation state: $state');
        logger.d('Group creation completed: ${state.value}');
        return group;
      },
      (err) => true, // catch all errors to prevent unhandled exceptions
    );
    if (state.hasError) {
      logger.e('Group creation failed', error: state.error);
    }
    return state.value;
  }
}

final addGroupProvider = AsyncNotifierProvider<AddGroupNotifier, Group?>(
  AddGroupNotifier.new,
);

class JoinGroupNotifier extends AsyncNotifier<Group?> {
  @override
  Future<Group?> build() async {
    return null; // idle on start
  }

  Future<Group?> joinGroup(String name, String password) async {
    logger.d('joinGroup called: $name');
    final groupsService = ref.read(groupsServiceProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () async {
        final group = await groupsService.joinGroup(name, password);
        logger.d('Group: $group');
        logger.d('Group joining state: $state');
        logger.d('Group joining completed: ${state.value}');
        return group;
      },
      (err) => true, // catch all errors to prevent unhandled exceptions
    );
    if (state.hasError) {
      logger.e('Group joining failed', error: state.error);
    }
    return state.value;
  }
}

final joinGroupProvider = AsyncNotifierProvider<JoinGroupNotifier, Group?>(
  JoinGroupNotifier.new,
);
