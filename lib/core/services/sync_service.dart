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

  @Deprecated("Wrong approach")
  Future<void> syncUsersAndGroupMembersOnNotification(
    String groupPublicId, {
    String? addedUserPublicId,
    String? removedUserPublicId,
  }) async {
    final group = await _db.groupsDao.groupFromPublicId(groupPublicId);
    if (group == null) {
      logger.e('Group with public id $groupPublicId not found');
      return;
    }
    final membersResponse = await _apiClient.getGroupMembers(groupPublicId);

    //we get addedpublicId if we dont find group member with that public id in local db,
    //we fetch and insert user if user is not present, RETHINK
    final userPresent = await _db.usersDao.getByPublicId(
      addedUserPublicId ?? '',
    );

    if (addedUserPublicId != null && userPresent == null) {
      logger.d('User with public id $addedUserPublicId added to db from sync');
      final newUserInList = await _apiClient.fetchUsersByPublicIds(
        List.of([addedUserPublicId]),
      );
      final newUser = newUserInList.users.first;
      await _db.usersDao.insertUsersFromSync(List.of([newUser]));
    }
    await _db.groupMembersDao.insertMembersFromSync(
      group.id,
      membersResponse.members,
    );
    if (removedUserPublicId != null) {
      logger.d(
        'User with public id $removedUserPublicId removed from db from sync',
      );
      await _db.groupMembersDao.deleteMember(group.id, removedUserPublicId);
      //TODO - consider deleting user from users table if they are not a member of any groups anymore, but need to check references first
      //long lookup if not indexed, so, just add index we dont microoptimize client side, waste of compute
      final isMember = await _db.groupMembersDao.isMemberOfAnyGroup(
        removedUserPublicId,
      );

      if (!isMember) {
        logger.d(
          'User with public id $removedUserPublicId is not a member of any groups, deleting from users table',
        );
        await _db.usersDao.deleteUserByPublicId(removedUserPublicId);
      }
    }
  }

  Future<void> syncUsersAndGroupMembersForGroupByPublicId(
    String groupPublicId,
  ) async {
    final group = await _db.groupsDao.groupFromPublicId(groupPublicId);
    if (group == null) {
      logger.e('Group with public id $groupPublicId not found');
      return;
    }
    await syncUsersAndGroupMembersForGroup(group);
  }

  Future<void> syncUsersAndGroupMembersForGroupById(int groupId) async {
    final group = await _db.groupsDao.groupFromId(groupId);
    if (group == null) {
      logger.e('Group with id $groupId not found');
      return;
    }
    await syncUsersAndGroupMembersForGroup(group);
  }

  Future<void> syncUsersAndGroupMembersForGroup(Group group) async {
    final groupPublicId = group.publicId;
    final membersResponse = await _apiClient.getGroupMembers(groupPublicId);

    final localMembers = await _db.groupMembersDao.getMembersForGroup(group.id);
    final localMembersPublicIds = localMembers
        .map((m) => m.userPublicId)
        .toSet();
    final usersPublicIds = membersResponse.members
        .map((m) => m.userPublicId)
        .toSet();
    final toDeletePublicIds = localMembersPublicIds.difference(usersPublicIds);

    if (usersPublicIds.isNotEmpty) {
      logger.d(
        'New users with public ids $usersPublicIds added to db from sync',
      );
      final newUsersInList = await _apiClient.fetchUsersByPublicIds(
        usersPublicIds.toList(),
      );
      await _db.usersDao.insertUsersFromSync(newUsersInList.users);
    }
    if (toDeletePublicIds.isNotEmpty) {
      logger.d(
        'Users with public ids $toDeletePublicIds removed from db from sync',
      );
      for (final publicId in toDeletePublicIds) {
        await _db.groupMembersDao.deleteMember(group.id, publicId);
        final isMember = await _db.groupMembersDao.isMemberOfAnyGroup(publicId);
        if (!isMember) {
          logger.d(
            'User with public id $publicId is not a member of any groups, deleting from users table',
          );
          await _db.usersDao.deleteUserByPublicId(publicId);
        }
      }
    }

    await _db.groupMembersDao.insertMembersFromSync(
      group.id,
      membersResponse.members,
    );
  }

  //actully useless becase we get notif about one user so we just fetch that
  Future<List<String>> diffNewUsersPublicIds(
    List<GroupMemberSyncDTO> fetchedMembersResponseMembers,
  ) async {
    final usersPublicIds = fetchedMembersResponseMembers
        .map((m) => m.userPublicId)
        .toSet();
    final Set<String> existingUsersPublicIds = await _db.usersDao
        .getExistingPublicIdsForUsers(usersPublicIds);
    final newUsersPublicIds = usersPublicIds.difference(existingUsersPublicIds);
    return newUsersPublicIds.toList();
  }
}

final syncServiceProvider = FutureProvider<SyncService>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  final apiClient = await ref.watch(apiClientProvider.future);
  return SyncService(db, apiClient);
});
