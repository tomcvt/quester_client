import 'package:drift/drift.dart';
import 'package:quester_client/core/data/app_database.dart';
import 'package:quester_client/core/data/data_objects.dart';
import 'package:quester_client/core/data/data_tables.dart';
import 'package:quester_client/core/dto/groups.dart';

part 'group_members_dao.g.dart';

@DriftAccessor(tables: [GroupMembers, Users, Groups])
class GroupMembersDao extends DatabaseAccessor<AppDatabase>
    with _$GroupMembersDaoMixin {
  GroupMembersDao(AppDatabase db) : super(db);

  Stream<List<GroupMember>> watchMembersForGroup(int groupId) {
    final query = select(groupMembers)..where((m) => m.groupId.equals(groupId));
    return query.watch();
  }

  // use inner join and first ensure users are updated before emitting members stream
  Stream<List<GroupMemberWithUser>> watchMembersWithUserForGroup(int groupId) {
    final query = select(groupMembers).join([
      innerJoin(users, users.publicId.equalsExp(groupMembers.userPublicId)),
    ])..where(groupMembers.groupId.equals(groupId));

    return query.watch().map((rows) {
      return rows.map((row) {
        final member = row.readTable(groupMembers);
        final user = row.readTable(users);
        return GroupMemberWithUser(groupMember: member, user: user);
      }).toList();
    });
  }

  Stream<List<GroupMemberWithUser>> watchMembersWithUserForGroupExcluding(
    int groupId,
    String excludeUserPublicId,
  ) {
    final query =
        select(groupMembers).join([
          innerJoin(users, users.publicId.equalsExp(groupMembers.userPublicId)),
          innerJoin(groups, groups.id.equalsExp(groupMembers.groupId)),
        ])..where(
          groups.id.equals(groupId) &
              groupMembers.userPublicId.isNotValue(excludeUserPublicId),
        );

    return query.watch().map((rows) {
      return rows.map((row) {
        final member = row.readTable(groupMembers);
        final user = row.readTable(users);
        return GroupMemberWithUser(groupMember: member, user: user);
      }).toList();
    });
  }

  Future<void> insertMembersFromSync(
    String groupPublicId,
    List<GroupMemberSyncDTO> members,
  ) async {
    final group = await (select(
      groups,
    )..where((g) => g.publicId.equals(groupPublicId))).getSingleOrNull();

    if (group == null) {
      throw Exception('Group with publicId "$groupPublicId" not found');
    }

    final groupId = group.id;

    await batch((batch) {
      batch.insertAllOnConflictUpdate(
        groupMembers,
        members.map((member) {
          return GroupMembersCompanion(
            groupId: Value(groupId),
            userPublicId: Value(member.userPublicId),
            role: Value(member.role),
            updatedAt: Value(member.updatedAt),
          );
        }).toList(),
      );
    });
  }

  Future<GroupMember> insertMember(
    int groupId,
    String userPublicId,
    String username,
    MemberRole role,
  ) async {
    final member = GroupMembersCompanion(
      groupId: Value(groupId),
      userPublicId: Value(userPublicId),
      role: Value(role),
      updatedAt: Value(DateTime.now()),
    );
    final id = await into(groupMembers).insert(member);
    return GroupMember(
      id: id,
      groupId: groupId,
      userPublicId: userPublicId,
      role: role,
      updatedAt: DateTime.now(),
    );
  }

  Future<int> deleteMembersForGroup(int groupId) =>
      (delete(groupMembers)..where((m) => m.groupId.equals(groupId))).go();
}
