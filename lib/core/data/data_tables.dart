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

// Junction table — Group <-> User many-to-many
class GroupMembers extends Table {
  IntColumn get groupId => integer().references(Groups, #id)();
  IntColumn get userId => integer().references(Users, #id)();

  // Composite primary key — no autoincrement here
  @override
  Set<Column> get primaryKey => {groupId, userId};
}
