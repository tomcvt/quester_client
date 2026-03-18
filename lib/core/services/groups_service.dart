import 'package:drift/drift.dart';
import 'package:quester_client/core/data/app_database.dart';
import 'package:quester_client/core/data/group_members_dao.dart';
import 'package:quester_client/core/data/groups_dao.dart';
import 'package:quester_client/core/data/data_tables.dart';
import 'package:quester_client/core/http/api_client.dart';
import 'package:quester_client/core/services/app_initializer.dart';
import 'package:quester_client/core/utils/logger_util.dart';

class GroupsService {
  final GroupsDao _groupsDao;
  final GroupMembersDao _groupMembersDao;
  final ApiClient _apiClient;

  GroupsService(this._groupsDao, this._groupMembersDao, this._apiClient);

  Future<Group?> createGroup(String name, String password) async {
    final groupResponse = await _apiClient.createGroup(name, password);
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
    final fetchedMembers = await _apiClient.syncGroupMembers(
      groupResponse.publicId,
    );
    logger.d('Fetched members from backend: ${fetchedMembers.toString()}');

    await _groupMembersDao.insertMembersFromSync(
      groupResponse.publicId,
      fetchedMembers.members,
    );
    logger.d(
      'Members inserted into local DB for group ${groupResponse.publicId}',
    );
    return createdGroup;
  }

  Future<Group?> createMockGroupWithUser(String name) async {
    final newGroup = GroupsCompanion(
      name: Value(name),
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
