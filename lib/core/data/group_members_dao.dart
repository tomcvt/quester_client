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

  Stream<GroupMemberWithUser?> watchMemberWithUserByGroupAndUser(
    int groupId,
    String userPublicId,
  ) {
    final query =
        select(groupMembers).join([
          innerJoin(users, users.publicId.equalsExp(groupMembers.userPublicId)),
        ])..where(
          groupMembers.groupId.equals(groupId) &
              groupMembers.userPublicId.equals(userPublicId),
        );

    return query.watchSingleOrNull().map((row) {
      if (row == null) return null;
      final member = row.readTable(groupMembers);
      final user = row.readTable(users);
      return GroupMemberWithUser(groupMember: member, user: user);
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
    int groupId,
    List<GroupMemberSyncDTO> members,
  ) async {
    await batch((batch) {
      for (final member in members) {
        final companion = GroupMembersCompanion(
          groupId: Value(groupId),
          userPublicId: Value(member.userPublicId),
          role: Value(member.role),
          updatedAt: Value(member.updatedAt),
        );
        batch.insert(
          groupMembers,
          companion,
          onConflict: DoUpdate(
            (old) => companion,
            target: [groupMembers.groupId, groupMembers.userPublicId],
          ),
        );
      }
    });
  }

  Future<void> insertMembersFromSyncWithPublicId(
    String groupPublicId,
    List<GroupMemberSyncDTO> members,
  ) async {
    final group = await (select(
      groups,
    )..where((g) => g.publicId.equals(groupPublicId))).getSingleOrNull();
    if (group == null) {
      throw Exception('Group with publicId "$groupPublicId" not found');
    }
    await insertMembersFromSync(group.id, members);
  }

  //TODO check references for conflicts
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

  Future<void> deleteMember(int groupId, String userPublicId) async {
    await (delete(groupMembers)..where(
          (m) =>
              m.groupId.equals(groupId) & m.userPublicId.equals(userPublicId),
        ))
        .go();
  }

  Future<bool> isMemberOfAnyGroup(String userPublicId) async {
    final result =
        await (select(groupMembers)
              ..where((m) => m.userPublicId.equals(userPublicId))
              ..limit(1))
            .getSingleOrNull();
    return result != null;
  }

  Future<int> deleteMembersForGroup(int groupId) =>
      (delete(groupMembers)..where((m) => m.groupId.equals(groupId))).go();
}
