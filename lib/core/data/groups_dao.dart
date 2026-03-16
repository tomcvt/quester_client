import 'package:drift/drift.dart';
import 'data_tables.dart';
import 'app_database.dart';

part 'groups_dao.g.dart';

@DriftAccessor(tables: [Groups, Users, GroupMembers])
class GroupsDao extends DatabaseAccessor<AppDatabase> with _$GroupsDaoMixin {
  GroupsDao(AppDatabase db) : super(db);

  // Simple insert
  Future<int> insertGroup(GroupsCompanion group) => into(groups).insert(group);

  // Stream — this is your Flow<List<Group>> equivalent
  // Drift automatically re-emits when the table changes
  Stream<List<Group>> watchAllGroups() => select(groups).watch();

  // Join query — groups with their members
  // This is where Drift gets more verbose than Room
  /*
  Stream<Map<Group, List<User>>> watchGroupsWithMembers() {
    final query = select(groups).join([
      leftOuterJoin(groupMembers, groupMembers.groupId.equalsExp(groups.id)),
      leftOuterJoin(users, users.id.equalsExp(groupMembers.userId)),
    ]);

    return query.watch().map((rows) {
      // fold rows into map — same pattern as you'd do in Kotlin
      // multiple rows per group because of the join
      final result = <Group, List<User>>{};
      for (final row in rows) {
        final group = row.readTable(groups);
        final user = row.readTableOrNull(users);
        result.putIfAbsent(group, () => []);
        if (user != null) result[group]!.add(user);
      }
      return result;
    });
  }
  */
  /*
  Future<void> insertGroupWithMembers(
    GroupsCompanion group,
    List<UsersCompanion> members,
  ) =>
      // transaction() = @Transaction in Room
      transaction(() async {
        final groupId = await into(groups).insert(group);
        for (final member in members) {
          final userId = await into(users).insert(member);
          await into(groupMembers).insert(
            GroupMembersCompanion(
              groupId: Value(groupId),
              userId: Value(userId),
            ),
          );
        }
      });
      */

  Future<Group?> groupFromId(int id) =>
      (select(groups)..where((g) => g.id.equals(id))).getSingleOrNull();
  Future<Group?> groupFromName(String name) =>
      (select(groups)..where((g) => g.name.equals(name))).getSingleOrNull();
}
