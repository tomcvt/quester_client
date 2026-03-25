import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quester_client/core/data/app_database.dart';
import 'package:quester_client/core/data/data_tables.dart';
import 'package:quester_client/core/providers/service_providers.dart';
import 'package:quester_client/core/services/app_initializer.dart';
import 'package:quester_client/core/utils/logger_util.dart';

class CreateQuestNotifier extends AsyncNotifier<Quest?> {
  @override
  Future<Quest?> build() async => null; // idle on start

  Future<Quest?> createQuest({
    required int groupId,
    required String name,
    required String? data,
    required String? deadline,
    required String? address,
    required String? contactNumber,
    required String? contactInfo,
    required QuestType type,
    required bool inclusive,
    required QuestStatus status,
  }) async {
    logger.d('createQuest called: $name');
    final questsService = ref.read(questsServiceProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () async {
        final quest = await questsService.createQuest(
          groupId: groupId,
          name: name,
          data: data,
          deadline: deadline,
          address: address,
          contactNumber: contactNumber,
          contactInfo: contactInfo,
          type: type,
          inclusive: inclusive,
          status: status,
        );
        logger.d('Quest creation completed: ${quest.toString()}');
        return quest;
      },
      (err) => true, // catch all errors to prevent unhandled exceptions
    );
    if (state.hasError) {
      logger.e('Quest creation failed', error: state.error);
    }
    return state.value;
  }
}

final createQuestProvider = AsyncNotifierProvider<CreateQuestNotifier, Quest?>(
  CreateQuestNotifier.new,
);
