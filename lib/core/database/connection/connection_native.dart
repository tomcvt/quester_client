import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../services/app_initializer.dart';

Future<QueryExecutor> openConnection({BuildConfig? buildConfig}) async {
  if (buildConfig?.persistenceMode == PersistenceMode.memory) {
    return NativeDatabase.memory();
  }
  final dbFolder = await getApplicationDocumentsDirectory();
  final file = File(path.join(dbFolder.path, 'app.db'));
  return NativeDatabase(file);
}
