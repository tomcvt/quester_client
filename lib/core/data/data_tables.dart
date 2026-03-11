import 'package:drift/drift.dart';

class Groups extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get publicId => text()();
  TextColumn get name => text()();
  TextColumn get type => text()(); // you handle enum mapping manually
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
