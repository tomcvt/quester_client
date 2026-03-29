// lib/main.dart

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:quester_client/core/services/fcm_handler.dart';
import 'firebase_options.dart';
import 'package:quester_client/core/providers/core_providers.dart';
import 'package:quester_client/core/providers/data_providers.dart';
import 'package:quester_client/core/services/app_initializer.dart';
import 'package:quester_client/core/utils/logger_util.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseApp firebaseApp = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  logger.d('Firebase initialized: ${firebaseApp.name}');

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
    //TODO: memory for debug
    isDebug: kDebugMode,
    apiBaseUrl: apiBaseUrl,
  );

  await AppInitializer.init(buildConfig);
  logger.d('DB: ${AppInitializer.db}');
  await FirebaseMessaging.instance.requestPermission();

  FirebaseMessaging.onBackgroundMessage(
    firebaseMessagingBackgroundHandler,
  ); // killed / background (separate isolate)
  initFcmHandlers(); // wires up foreground + background handlers, must be called after FirebaseMessaging.onBackgroundMessage
  /*
    * Note: onMessageOpenedApp only triggers for notification messages, not data-only messages.
    * Since we're using data-only for everything, we need to handle background taps in the same way as foreground messages.
    * If we were to add a notification field to the FCM payload, then we could use onMessageOpenedApp for background taps instead.
    */
  /*
  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    _handleMessage(message);
  });     // user tapped notification, app was in background
  */
  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(AsyncValue.data(AppInitializer.db)),
        installationIdProvider.overrideWithValue(AppInitializer.installationId),
        apiClientProvider.overrideWithValue(AppInitializer.apiClient),
        //fcmTokenProvider.overrideWithValue(AppInitializer.fcmToken), TODO
      ],
      child: MyApp(),
    ),
  );
}
