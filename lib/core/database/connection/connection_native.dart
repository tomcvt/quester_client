import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../services/app_initializer.dart';

Future<QueryExecutor> openConnection({BuildConfig? buildConfig}) async {
  //@Warning('Using native database connection, which is not supported on web. Ensure this is only used in non-web builds.')
  //TODO for debug purposes:
  //return NativeDatabase.memory();
  if (buildConfig?.persistenceMode == PersistenceMode.memory) {
    return NativeDatabase.memory();
  }
  final dbFolder = await getApplicationDocumentsDirectory();
  final file = File(path.join(dbFolder.path, 'app.db'));
  return NativeDatabase(file);
}
