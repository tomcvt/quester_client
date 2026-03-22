// lib/main.dart

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quester_client/core/providers/core_providers.dart';
import 'package:quester_client/core/providers/data_providers.dart';
import 'package:quester_client/core/services/app_initializer.dart';
import 'package:quester_client/core/utils/logger_util.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String apiBaseUrl;
  if (kDebugMode) {
    if (kIsWeb) {
      apiBaseUrl = 'http://localhost:8100/api/v1/';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      apiBaseUrl = 'http://10.0.2.2:8100/api/v1/';
    } else {
      apiBaseUrl = 'http://localhost:8100/api/v1/';
      logger.w(
        'Running in debug mode on unsupported platform ${defaultTargetPlatform}, defaulting API base URL to localhost. This may not work if the backend is not accessible at this address.',
      );
    }
  } else {
    //apiBaseUrl = 'https://questerapp.tomcvt.com/api';
    apiBaseUrl = 'http://localhost:8100/api/v1/';
  }

  BuildConfig buildConfig = BuildConfig(
    persistenceMode: kIsWeb ? PersistenceMode.memory : PersistenceMode.sqlite,
    isDebug: kDebugMode,
    apiBaseUrl: apiBaseUrl,
  );

  await AppInitializer.init(buildConfig);
  logger.d('DB: ${AppInitializer.db}');
  await FirebaseMessaging.instance.requestPermission();

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(AsyncValue.data(AppInitializer.db)),
        installationIdProvider.overrideWithValue(AppInitializer.installationId),
        //fcmTokenProvider.overrideWithValue(AppInitializer.fcmToken), TODO
      ],
      child: MyApp(),
    ),
  );
}
