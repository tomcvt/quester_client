import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quester_client/core/data/app_database.dart';
import 'package:quester_client/core/providers/service_providers.dart';
import 'package:quester_client/core/utils/logger_util.dart';

class AddGroupNotifier extends AsyncNotifier<Group?> {
  @override
  Future<Group?> build() async {
    logger.d('AddGroupNotifier build called');
    try {
      return null;
    } catch (e, st) {
      logger.e('AddGroupNotifier build failed', error: e, stackTrace: st);
      rethrow;
    }
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
      // Optional error filter: catch all errors
      (err) => false,
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
