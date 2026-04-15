import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:quester_client/core/data/app_database.dart";
import "package:quester_client/core/providers/data_providers.dart";
import "package:quester_client/core/providers/service_providers.dart";

// State is void — we only track whether an action is in-progress or errored.
// The quest itself is already reactively streamed by questDetailsProvider.
// After any action updates the DB, the stream provider reflects the change automatically.
class QuestActionsNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // Nothing to load — quest data lives in questDetailsProvider.
  }

  Future<void> acceptQuest(int questId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final questsService = await ref.read(questsServiceProvider.future);
      await questsService.acceptQuest(questId);
    });
  }

  Future<void> completeQuest(int questId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final questsService = await ref.read(questsServiceProvider.future);
      await questsService.completeQuest(questId);
    });
  }

  Future<void> deleteQuest(int questId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final questsService = await ref.read(questsServiceProvider.future);
      await questsService.deleteQuest(questId);
    });
  }
}

final questActionsNotifierProvider =
    AsyncNotifierProvider<QuestActionsNotifier, void>(QuestActionsNotifier.new);
