import 'package:drift/drift.dart';

class Groups extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get publicId => text()();
  TextColumn get name => text()();
  TextColumn get type => text().withDefault(
    Constant(GroupType.work.value),
  )(); // you handle enum mapping manually
  TextColumn get visibility => text().withDefault(
    Constant(GroupVisibility.private.value),
  )(); // you handle enum mapping manually
  DateTimeColumn get createdAt => dateTime()();
}

enum GroupVisibility { public, private }

extension GroupVisibilityX on GroupVisibility {
  String get value => name; // enum.name = 'public', 'private'
  String get apiValue => name.toUpperCase(); // 'PUBLIC', 'PRIVATE' for API
  static GroupVisibility fromString(String s) =>
      GroupVisibility.values.firstWhere((e) => e.name == s.toLowerCase());
}

enum GroupType { work, personal }

extension GroupTypeX on GroupType {
  String get value => name;
  String get apiValue => name.toUpperCase();
  static GroupType fromString(String s) =>
      GroupType.values.firstWhere((e) => e.name == s.toLowerCase());
}

class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get publicId => text()();
  TextColumn get name => text()();
}

//-- GroupMembers

enum MemberRole { owner, member }

extension MemberRoleX on MemberRole {
  String get value => name;
  String get apiValue => name.toUpperCase();
  static MemberRole fromString(String s) =>
      MemberRole.values.firstWhere((e) => e.name == s.toLowerCase());
}

// GroupMembers stores denormalized user data (username) intentionally.
// At MVP, members are only ever displayed in group context — no User table needed.
// Extend to normalized Users table when:
//   - profile screen exists
//   - user appears in multiple independent contexts
//   - username changes need to propagate consistently
class GroupMembers extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get groupId => integer().references(Groups, #id)();
  TextColumn get userPublicId => text()();
  TextColumn get username => text()();
  TextColumn get role =>
      textEnum<MemberRole>().withDefault(Constant(MemberRole.member.value))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {groupId, userPublicId}, // prevent duplicate memberships
  ];
}
