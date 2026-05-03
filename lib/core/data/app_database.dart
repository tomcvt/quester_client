import 'package:drift/drift.dart';
import 'package:quester_client/core/build_config.dart';
import 'package:quester_client/core/data/group_members_dao.dart';
import 'package:quester_client/core/data/quest_templates_dao.dart';
import 'package:quester_client/core/data/quests_dao.dart';
import 'package:quester_client/core/data/users_dao.dart';
import 'package:quester_client/core/services/app_initializer.dart';
import 'data_tables.dart';
import 'groups_dao.dart';
import '../database/connection/connection.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Groups, Users, GroupMembers, Quests, QuestTemplates],
  daos: [GroupsDao, GroupMembersDao, QuestsDao, UsersDao, QuestTemplatesDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;

  /*
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      // v1 → v2: add quest_templates table
      if (from < 2) {
        await m.createTable(questTemplates);
      }
      // v2 → v3: add automatic_reward to quests; add currency to group_members;
      //          add automatic_reward to quest_templates
      if (from < 3) {
        await m.addColumn(quests, quests.automaticReward);
        await m.addColumn(groupMembers, groupMembers.currency);
        await m.addColumn(questTemplates, questTemplates.automaticReward);
      }
    },
  );
  */

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
  late final questsDao = QuestsDao(this);
  late final usersDao = UsersDao(this);
  late final questTemplatesDao = QuestTemplatesDao(this);
}
