import 'package:drift/drift.dart';
import 'package:quester_client/core/data/app_database.dart';
import 'package:quester_client/core/data/groups_dao.dart';

class GroupsService {
  final GroupsDao _groupsDao;

  GroupsService(this._groupsDao);

  Future<Group?> createGroup(String name, String password) async {
    final existingGroup = await _groupsDao.groupFromName(name);
    if (existingGroup != null) {
      throw Exception('Group with name "$name" already exists');
    }
    final newGroup = GroupsCompanion(
      name: Value(name),
      //TODO password: Value(password),
    );
    //TODO actual network call to create group on backend
    await Future.delayed(const Duration(seconds: 2)); // mock network
    final id = await _groupsDao.insertGroup(newGroup);
    return await _groupsDao.groupFromId(id);
  }
}
