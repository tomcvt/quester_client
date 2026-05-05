import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quester_client/core/data/group_members_dao.dart';
import 'package:quester_client/core/data/quest_templates_dao.dart';

import 'package:quester_client/core/data/groups_dao.dart';
import 'package:quester_client/core/data/app_database.dart';
import 'package:quester_client/core/data/quests_dao.dart';
import 'package:quester_client/core/data/users_dao.dart';
import 'package:quester_client/core/services/app_initializer.dart';

/*
//WE OPEN THE DB IN THE APP INITIALIZER,WITH BUILD CONFIG, SO BY THE TIME ANY WIDGET OR PROVIDER RUNS, THE DB IS READY
final appDatabaseProvider = FutureProvider<AppDatabase>((ref) async {
  return AppDatabase.open(); // Drift opens the file here
});
*/
final groupsDaoProvider = Provider<GroupsDao>((ref) {
  return ref
      .watch(appDatabaseProvider)
      //.requireValue
      .groupsDao; // Access the DAO from the database
});

final groupMembersDaoProvider = Provider<GroupMembersDao>((ref) {
  return ref
      .watch(appDatabaseProvider)
      //.requireValue
      .groupMembersDao; // Access the DAO from the database
});

final questsDaoProvider = Provider<QuestsDao>((ref) {
  return ref
      .watch(appDatabaseProvider)
      //.requireValue
      .questsDao; // Access the DAO from the database
});

final usersDaoProvider = Provider<UsersDao>((ref) {
  return ref
      .watch(appDatabaseProvider)
      //.requireValue
      .usersDao; // Access the DAO from the database
});

final questTemplatesDaoProvider = Provider<QuestTemplatesDao>((ref) {
  return ref
      .watch(appDatabaseProvider)
      //.requireValue
      .questTemplatesDao;
});

/*
// This provider depends on the database — but returns sync GroupsDao
// because by the time this runs, the db is already open
final groupsDaoProvider = Provider<GroupsDao>((ref) {
  // .requireValue throws if database isn't ready yet
  // but it will be ready — you'll see why in a second
  final db = ref.watch(appDatabaseProvider).requireValue;
  return GroupsDao(db);
});

*/
