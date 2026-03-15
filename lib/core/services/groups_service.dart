import 'package:drift/drift.dart';
import 'package:quester_client/core/data/app_database.dart';
import 'package:quester_client/core/data/groups_dao.dart';
import 'package:quester_client/core/data/data_tables.dart';
import 'package:quester_client/core/http/api_client.dart';
import 'package:quester_client/core/utils/logger_util.dart';

class GroupsService {
  final GroupsDao _groupsDao;
  final ApiClient _apiClient;

  GroupsService(this._groupsDao, this._apiClient);

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
    return createdGroup;
  }
}
