// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quests_dao.dart';

// ignore_for_file: type=lint
mixin _$QuestsDaoMixin on DatabaseAccessor<AppDatabase> {
  $GroupsTable get groups => attachedDatabase.groups;
  $UsersTable get users => attachedDatabase.users;
  $QuestsTable get quests => attachedDatabase.quests;
  $GroupMembersTable get groupMembers => attachedDatabase.groupMembers;
  QuestsDaoManager get managers => QuestsDaoManager(this);
}

class QuestsDaoManager {
  final _$QuestsDaoMixin _db;
  QuestsDaoManager(this._db);
  $$GroupsTableTableManager get groups =>
      $$GroupsTableTableManager(_db.attachedDatabase, _db.groups);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db.attachedDatabase, _db.users);
  $$QuestsTableTableManager get quests =>
      $$QuestsTableTableManager(_db.attachedDatabase, _db.quests);
  $$GroupMembersTableTableManager get groupMembers =>
      $$GroupMembersTableTableManager(_db.attachedDatabase, _db.groupMembers);
}
