import 'package:drift/drift.dart';
import 'package:quester_client/core/data/group_members_dao.dart';
import 'package:quester_client/core/data/quests_dao.dart';
import 'package:quester_client/core/data/users_dao.dart';
import 'package:quester_client/core/services/app_initializer.dart';
import 'data_tables.dart';
import 'groups_dao.dart';
import '../database/connection/connection.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Groups, Users, GroupMembers, Quests],
  daos: [GroupsDao, GroupMembersDao, QuestsDao, UsersDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;

  // static factory — this is what main() calls
  static Future<AppDatabase> open({BuildConfig? buildConfig}) async {
    /*
    if (buildConfig?.persistenceMode == PersistenceMode.memory) {
      return AppDatabase(NativeDatabase.memory());
    }
    */
    final executor = await openConnection(buildConfig: buildConfig);
    return AppDatabase(executor);
  }

  late final groupsDao = GroupsDao(this);
  late final groupMembersDao = GroupMembersDao(this);
}
