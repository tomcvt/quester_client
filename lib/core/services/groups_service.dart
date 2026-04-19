import 'package:drift/drift.dart';
import 'package:quester_client/core/data/app_database.dart';
import 'package:quester_client/core/data/group_members_dao.dart';
import 'package:quester_client/core/data/groups_dao.dart';
import 'package:quester_client/core/data/data_tables.dart';
import 'package:quester_client/core/data/users_dao.dart';
import 'package:quester_client/core/dto/groups.dart';
import 'package:quester_client/core/http/api_client.dart';
import 'package:quester_client/core/services/app_initializer.dart';
import 'package:quester_client/core/utils/logger_util.dart';
import 'package:uuid/uuid.dart';

class GroupsService {
  final GroupsDao _groupsDao;
  final GroupMembersDao _groupMembersDao;
  final UsersDao _usersDao;
  final ApiClient _apiClient;

  GroupsService(
    this._groupsDao,
    this._groupMembersDao,
    this._usersDao,
    this._apiClient,
  );

  //TODO - add error handling and logging, visibility field
  Future<Group?> createGroup(
    String name,
    String password, {
    bool offline = false,
  }) async {
    if (offline) {
      return await createOfflineGroup(name, password);
    }
    final GroupResponse groupResponse = await _apiClient.createGroup(
      name,
      password,
    );
    logger.d('Group created on backend: ${groupResponse.toString()}');
    final newGroup = GroupsCompanion(
      name: Value(groupResponse.name),
      publicId: Value(groupResponse.publicId),
      type: Value(groupResponse.type.value),
      visibility: Value(groupResponse.visibility.value),
      createdAt: Value(groupResponse.createdAt),
    );

    /*
    final existingGroup = await _groupsDao.groupFromName(name);
    if (existingGroup != null) {
      throw Exception('Group with name "$name" already exists');
    }
    */

    final id = await _groupsDao.insertGroup(newGroup);
    final createdGroup = await _groupsDao.groupFromId(id);
    logger.d('Group inserted into local DB: ${createdGroup.toString()}');
    final fetchedMembers = await _apiClient.getGroupMembers(
      groupResponse.publicId,
    );
    logger.d('Fetched members from backend: ${fetchedMembers.toString()}');

    await _groupMembersDao.insertMembersFromSyncWithPublicId(
      groupResponse.publicId,
      fetchedMembers.members,
    );
    logger.d(
      'Members inserted into local DB for group ${groupResponse.publicId}',
    );
    return createdGroup;
  }

  Future<Group?> createOfflineGroup(String name, String password) async {
    final newGroup = GroupsCompanion(
      name: Value(name),
      publicId: Value(Uuid().v4()),
      type: Value(GroupType.work.value),
      visibility: Value(GroupVisibility.public.value),
      createdAt: Value(DateTime.now()),
    );
    final id = await _groupsDao.insertGroup(newGroup);
    final createdGroup = await _groupsDao.groupFromId(id);
    final userPublicId = AppInitializer.installationId;
    await _groupMembersDao.insertMember(
      id,
      userPublicId,
      "Offline User", //TODO - fetch actual username from shared prefs or similar
      MemberRole.owner,
    );
    return createdGroup;
  }

  Future<Group?> joinGroup(
    String name,
    String password, {
    bool offline = false,
  }) async {
    if (offline) {
      return await createOfflineGroup(name, password);
    }
    final GroupResponse groupResponse = await _apiClient.joinGroup(
      name,
      password,
    );
    //TODO - handle case where group already exists in local DB (e.g. from previous offline join) -
    //for now we assume it doesn't exist and just insert, but this could lead to duplicates if user tries to
    //join the same group multiple times while offline
    //fix - we just update local group and members data
    logger.d('Joined group on backend: ${groupResponse.toString()}');
    final existingGroup = await _groupsDao.groupFromPublicId(
      groupResponse.publicId,
    );
    if (existingGroup != null) {
      //TODO - update existing group data with latest from backend, including members
      //for now we skip and return
      logger.d(
        'Group with public ID ${groupResponse.publicId} already exists in local DB, skipping insert',
      );
      return existingGroup;
    }
    final newGroup = GroupsCompanion(
      name: Value(groupResponse.name),
      publicId: Value(groupResponse.publicId),
      type: Value(groupResponse.type.value),
      visibility: Value(groupResponse.visibility.value),
      createdAt: Value(groupResponse.createdAt),
    );

    final id = await _groupsDao.insertGroup(newGroup);
    final createdGroup = await _groupsDao.groupFromId(id);
    logger.d('Joined group inserted into local DB: ${createdGroup.toString()}');

    final fetchedMembersResponse = await _apiClient.getGroupMembers(
      groupResponse.publicId,
    );
    logger.d(
      'Fetched members from backend: ${fetchedMembersResponse.toString()}',
    );

    final usersPublicIds = fetchedMembersResponse.members
        .map((m) => m.userPublicId)
        .toSet();
    //TODO - optimize by only fetching users that are not already in local DB
    //actually better to just fetch and update the usernames etc.
    /*
    final Set<String> existingUsersPublicIds = await _usersDao
        .getExistingPublicIdsForUsers(usersPublicIds);

    final newUsersPublicIds = usersPublicIds.difference(existingUsersPublicIds);
    */
    final newUsersPublicIds = usersPublicIds.toList();

    final fetchedUsersResponse = await _apiClient.fetchUsersByPublicIds(
      newUsersPublicIds,
    );
    final fetchedUsers = fetchedUsersResponse.users;
    logger.d('Fetched users from backend: ${fetchedUsers.toString()}');

    await _usersDao.insertUsersFromSync(fetchedUsers);

    logger.d(
      'Users inserted/updated in local DB: ${fetchedUsers.map((u) => u.publicId).toList()}',
    );

    await _groupMembersDao.insertMembersFromSyncWithPublicId(
      groupResponse.publicId,
      fetchedMembersResponse.members,
    );
    logger.d(
      'Members inserted into local DB for joined group ${groupResponse.publicId}',
    );

    //TODO - run quests sync in background to fetch any quests for this group that aren't in local DB yet
    return createdGroup;
  }

  Future<void> leaveGroup(String groupId) async {
    final group = await _groupsDao.groupFromId(int.parse(groupId));
    if (group == null) return;
    final didLeave = await _apiClient.leaveGroup(group.publicId);
    if (!didLeave) {
      throw Exception('Failed to leave group on backend');
    }
    logger.d('Left group on backend: ${group.publicId}');
    await _groupMembersDao.deleteMembersForGroup(group.id);
    await _groupsDao.deleteGroupById(group.id);
  }

  Future<void> setMemberRole(
    String groupId,
    String userPublicId,
    MemberRole newRole,
  ) async {
    final group = await _groupsDao.groupFromId(int.parse(groupId));
    if (group == null) {
      throw Exception('Group not found in local DB for ID $groupId');
    }
    final updateDT = DateTime.now();
    await _apiClient.setMemberRole(group.publicId, userPublicId, newRole);
    logger.d('Set member role on backend: user $userPublicId to role $newRole');
    //TODO - update local DB with new role for this member
    await _groupMembersDao.updateMemberRole(
      group.id,
      userPublicId,
      newRole,
      updateDT,
    );
  }

  Future<Group?> createMockGroupWithUser(String groupName) async {
    final newGroup = GroupsCompanion(
      name: Value(groupName),
      publicId: Value("10000000-0000-0000-0000-000000000000"),
      type: Value(GroupType.work.value),
      visibility: Value(GroupVisibility.private.value),
      createdAt: Value(DateTime.now()),
    );

    final id = await _groupsDao.insertGroup(newGroup);
    final createdGroup = await _groupsDao.groupFromId(id);
    logger.d('Mock group inserted into local DB: ${createdGroup.toString()}');
    final userPublicId = AppInitializer.installationId;
    await _groupMembersDao.insertMember(
      id,
      userPublicId,
      "Mock User",
      MemberRole.owner,
    );
    return createdGroup;
  }
}
