import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quester_client/core/data/app_database.dart';
import 'package:quester_client/core/dto/groups.dart';
import 'package:quester_client/core/http/api_client.dart';
import 'package:quester_client/core/providers/core_providers.dart';
import 'package:quester_client/core/services/app_initializer.dart';

import '../utils/logger_util.dart';

class SyncService {
  final AppDatabase _db;
  final ApiClient _apiClient;

  SyncService(this._db, this._apiClient);

  Future<Quest?> syncNewQuests(
    String groupPublicId,
    String questPublicId,
  ) async {
    final group = await _db.groupsDao.groupFromPublicId(groupPublicId);
    if (group == null) {
      logger.e('Group with public id $groupPublicId not found');
      return null;
    }
    final lastUpdateTime = await _db.questsDao.getLatestUpdateTimeForGroup(
      group.id,
    );
    logger.d(
      'Starting quest sync for group $groupPublicId (id: ${group.id}) with last update time $lastUpdateTime',
    );
    // Subtract 10 seconds from lastUpdateTime to ensure we get any quests that were updated at the exact last update time
    final adjustedLastUpdateTime = lastUpdateTime.subtract(
      const Duration(seconds: 10),
    );
    final questsResponse = await _apiClient.syncGroupQuestsSince(
      groupPublicId,
      adjustedLastUpdateTime,
    );
    logger.d(
      'Syncing quests for group $groupPublicId since $adjustedLastUpdateTime, received ${questsResponse.quests.length} quests',
    );
    logger.d(
      'Payload: ${questsResponse.quests.map((q) => '${q.toString()}\n').join()}',
    );
    await _db.questsDao.insertQuestsFromSync(group.id, questsResponse.quests);
    logger.d(
      'Finished syncing quests for group $groupPublicId. Total quests synced: ${questsResponse.quests.length}',
    );
    return await _db.questsDao.getByPublicId(questPublicId);
  }

  Future<void> syncAllQuests() async {
    final groups = await _db.groupsDao.getAllGroups();
    for (final group in groups) {
      await syncNewQuests(group.publicId, '');
    }
  }

  Future<Quest?> deleteQuest(String groupPublicId, String questPublicId) async {
    final group = await _db.groupsDao.groupFromPublicId(groupPublicId);
    if (group == null) {
      logger.e('Group with public id $groupPublicId not found');
      return null;
    }
    final quest = await _db.questsDao.getByPublicId(questPublicId);
    if (quest == null) {
      logger.e('Quest with public id $questPublicId not found');
      return null;
    }
    final deletedCount = await _db.questsDao.deleteQuest(quest.id);
    if (deletedCount == 0) {
      logger.e('Failed to delete quest with id ${quest.id} from database');
    } else {
      logger.d('Deleted quest with id ${quest.id} from database');
    }
    return quest;
  }

  Future<void> syncUsersAndGroupMembers(
    String groupPublicId, 
    {String? addedUserPublicId,
    String? removedUserPublicId}
    ) async {
    final group = await _db.groupsDao.groupFromPublicId(groupPublicId);
    if (group == null) {
      logger.e('Group with public id $groupPublicId not found');
      return;
    }
    final membersResponse = await _apiClient.syncGroupMembers(groupPublicId);

    if (addedUserPublicId != null) {
      logger.d('User with public id $addedUserPublicId added to db from sync');
      final newUserInList = await _apiClient.fetchUsersByPublicIds(List.of([addedUserPublicId]));
      final newUser = newUserInList.users.first;
      await _db.usersDao.insertUsersFromSync(List.of([newUser]));
    }
    await _db.groupMembersDao.insertMembersFromSync(
      group.id,
      membersResponse.members,
    );
    if (removedUserPublicId != null) {
      logger.d('User with public id $removedUserPublicId removed from db from sync');
      await _db.groupMembersDao.deleteMember(group.id, removedUserPublicId);
    }
  }
  //actully useless becase we get notif about one user so we just fetch that
  Future<List<String>> diffNewUsersPublicIds(List<GroupMemberSyncDTO> fetchedMembersResponseMembers) async {
    final usersPublicIds = fetchedMembersResponseMembers
        .map((m) => m.userPublicId)
        .toSet();
    final Set<String> existingUsersPublicIds = await _db.usersDao
        .getExistingPublicIdsForUsers(usersPublicIds);
    final newUsersPublicIds = usersPublicIds.difference(existingUsersPublicIds);
    return newUsersPublicIds.toList();
}

final syncServiceProvider = Provider<SyncService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final apiClient = ref.watch(apiClientProvider);
  return SyncService(db, apiClient);
});
