import 'package:drift/drift.dart';
import 'package:quester_client/core/data/app_database.dart';
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

  Future<void> insertMembers(
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
            username: Value(member.username),
            role: Value(member.role),
            updatedAt: Value(member.updatedAt),
          );
        }).toList(),
      );
    });
  }
}
