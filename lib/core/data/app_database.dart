import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'data_tables.dart';
import 'groups_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Groups, Users, GroupMembers], daos: [GroupsDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;

  // static factory — this is what main() calls
  static Future<AppDatabase> open() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(path.join(dbFolder.path, 'app.db'));
    return AppDatabase(NativeDatabase(file));
  }
}
