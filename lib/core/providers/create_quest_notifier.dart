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
    date: datetime | None = None
    deadline_start: datetime | None = None
    deadline_end: datetime | None = None
    address: str | None = None
    contact_number: str | None = None
    contact_info: str | None = None
    data: str | None = None
    type: QuestType
    inclusive: bool
    status: QuestStatus
    creator_public_id: uuid.UUID
    accepted_by_public_id: uuid.UUID | None = None'
    */

class CreateQuestNotifier extends AsyncNotifier<Quest?> {
  @override
  Future<Quest?> build() async => null; // idle on start

  Future<Quest?> createQuest({
    required int groupId,
    required String name,
    required String? description,
    required DateTime? date,
    required DateTime? deadlineStart,
    required DateTime? deadlineEnd,
    required String? address,
    required String? contactNumber,
    required String? contactInfo,
    required String? data,
    required QuestType type,
    required bool inclusive,
    required QuestStatus status,
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
          date: date,
          deadlineStart: deadlineStart,
          deadlineEnd: deadlineEnd,
          address: address,
          contactNumber: contactNumber,
          contactInfo: contactInfo,
          data: data,
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
