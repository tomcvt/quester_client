// lib/main.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quester_client/core/providers/data_providers.dart';
import 'package:quester_client/core/services/app_initializer.dart';
import 'package:quester_client/core/utils/logger_util.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  BuildConfig buildConfig = BuildConfig(
    persistenceMode: kIsWeb ? PersistenceMode.memory : PersistenceMode.sqlite,
    isDebug: kDebugMode,
  );

  await AppInitializer.init(buildConfig);
  logger.d('DB: ${AppInitializer.db}');

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(AsyncValue.data(AppInitializer.db)),
      ],
      child: MyApp(),
    ),
  );
}
