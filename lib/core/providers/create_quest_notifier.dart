import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quester_client/core/data/app_database.dart';
import 'package:quester_client/core/data/data_tables.dart';
import 'package:quester_client/core/providers/service_providers.dart';
import 'package:quester_client/core/services/app_initializer.dart';
import 'package:quester_client/core/utils/logger_util.dart';

/*
NEW SCHEMA:
class CreateQuestRequest(BaseModel):
    group_public_id: uuid.UUID
    name: str
    description: str | None = None
    deadline: datetime | None = None
    start_time: datetime | None = None
    address: str | None = None
    data: str | None = None
    reward_type: RewardType
    reward_value: str | None = None
    inclusive: bool
    status: QuestStatus
    # creator_public_id: resolved server-side from auth token (DROPPED from request)
    */

class CreateQuestNotifier extends AsyncNotifier<Quest?> {
  @override
  Future<Quest?> build() async => null; // idle on start

  Future<Quest?> createQuest({
    required int groupId,
    required String name,
    required String? description,
    // required DateTime? date, // DROPPED
    // required DateTime? deadlineStart, // DROPPED: replaced by deadline
    // required DateTime? deadlineEnd, // DROPPED: replaced by deadline
    required DateTime? deadline,
    required DateTime? startTime,
    required String? address,
    // required String? contactNumber, // DROPPED
    // required String? contactInfo, // DROPPED
    required String? data,
    // required QuestType type, // DROPPED
    required RewardType rewardType,
    required String? rewardValue,
    required bool inclusive,
    required QuestStatus status,
    bool automaticReward = true,
  }) async {
    logger.d('createQuest called: $name');
    final questsService = await ref.read(questsServiceProvider.future);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () async {
        final quest = await questsService.createQuest(
          groupId: groupId,
          name: name,
          description: description,
          // date: date, // DROPPED
          // deadlineStart: deadlineStart, // DROPPED
          // deadlineEnd: deadlineEnd, // DROPPED
          deadline: deadline,
          startTime: startTime,
          address: address,
          // contactNumber: contactNumber, // DROPPED
          // contactInfo: contactInfo, // DROPPED
          data: data,
          // type: type, // DROPPED
          rewardType: rewardType,
          rewardValue: rewardValue,
          inclusive: inclusive,
          status: status,
          automaticReward: automaticReward,
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
