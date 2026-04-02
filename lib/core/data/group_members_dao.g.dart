// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_members_dao.dart';

// ignore_for_file: type=lint
mixin _$GroupMembersDaoMixin on DatabaseAccessor<AppDatabase> {
  $GroupsTable get groups => attachedDatabase.groups;
  $UsersTable get users => attachedDatabase.users;
  $GroupMembersTable get groupMembers => attachedDatabase.groupMembers;
  GroupMembersDaoManager get managers => GroupMembersDaoManager(this);
}

class GroupMembersDaoManager {
  final _$GroupMembersDaoMixin _db;
  GroupMembersDaoManager(this._db);
  $$GroupsTableTableManager get groups =>
      $$GroupsTableTableManager(_db.attachedDatabase, _db.groups);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db.attachedDatabase, _db.users);
  $$GroupMembersTableTableManager get groupMembers =>
      $$GroupMembersTableTableManager(_db.attachedDatabase, _db.groupMembers);
}
