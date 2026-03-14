import 'package:drift/web.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import '../../services/app_initializer.dart';

Future<QueryExecutor> openConnection({BuildConfig? buildConfig}) async {
  return driftDatabase(
    name: 'app_db',
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.js'),
    ),
  );
}
