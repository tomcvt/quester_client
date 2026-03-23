import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quester_client/core/data/app_database.dart';
import 'package:quester_client/core/data/data_tables.dart';
import 'package:quester_client/core/providers/service_providers.dart';
import 'package:quester_client/core/services/app_initializer.dart';
import 'package:quester_client/core/utils/logger_util.dart';

class CreateQuestNotifier extends AsyncNotifier<Quest?> {
  @override
  Future<Quest?> build() async => null; // idle on start

  Future<Quest?> createQuest(
    int groupId,
    String name,
    String? data,
    String? contactInfo, {
    QuestType type = QuestType.job,
    bool inclusive = true,
    QuestStatus status = QuestStatus.started,
  }) async {
    logger.d('createQuest called: $name');
    final questsService = ref.read(questsServiceProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () async {
        final quest = await questsService.createQuest(
          groupId,
          name,
          data,
          contactInfo,
          type: type,
          inclusive: inclusive,
          status: status,
          offline: !AppInitializer.isOnline.value,
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
