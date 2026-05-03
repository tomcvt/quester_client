import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:quester_client/core/build_config.dart';

Future<QueryExecutor> openConnection({BuildConfig? buildConfig}) async {
  if (buildConfig?.persistenceMode == PersistenceMode.memory) {
    // Ephemeral in-memory DB — cleared on every page reload.
    // probe() loads the WASM binary and registers VFS implementations;
    // we then force inMemory so nothing is written to IndexedDB or OPFS.
    final probed = await WasmDatabase.probe(
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.js'),
      databaseName: 'app_db',
    );
    final connection = await probed.open(
      WasmStorageImplementation.inMemory,
      'app_db',
    );
    return connection.executor;
  }
  return driftDatabase(
    name: 'app_db',
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.js'),
    ),
  );
}
