// lib/main.dart

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:quester_client/core/providers/auth_provider.dart';
import 'package:quester_client/core/services/fcm_handler.dart';
import 'package:quester_client/core/services/notification_display_service.dart';
import 'firebase_options.dart';
import 'package:quester_client/core/providers/core_providers.dart';
import 'package:quester_client/core/providers/data_providers.dart';
import 'package:quester_client/core/services/app_initializer.dart';
import 'package:quester_client/core/utils/logger_util.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final firebaseAppFuture = Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await firebaseAppFuture; // Ensure Firebase is initialized before proceeding
  //TODO for now, solve the async later

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
    //apiBaseUrl = 'https://questerapp.tomcvt.com/api/v1/';
    apiBaseUrl = 'http://localhost:8100/api/v1/';
  }

  BuildConfig buildConfig = BuildConfig(
    persistenceMode: kIsWeb ? PersistenceMode.memory : PersistenceMode.sqlite,
    //TODO: memory for debug
    isDebug: kDebugMode,
    apiBaseUrl: apiBaseUrl,
    vapidKey:
        "BF7AEejZwS5IMB4qOl2Ys1Z-wppuNBl7r7pFEvYXat8ZF-zOU4xwJxZZ7iVfIvy7Zf-dJZIjqDLyEYZMHWvUrr8",
  );

  await AppInitializer.initSlim(buildConfig);
  logger.d('DB: ${AppInitializer.db}');
  Future<NotificationSettings> requestNotificationFuture;
  try {
    requestNotificationFuture = FirebaseMessaging.instance.requestPermission();
  } catch (e) {
    logger.e('Error requesting notification permissions: $e');
  }
  //await requestNotificationFuture;
  await NotificationDisplayService.init();

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
        firebaseFutureProvider.overrideWithValue(firebaseAppFuture),
        //fcmTokenProvider.overrideWithValue(AppInitializer.fcmToken), TODO
      ],
      child: MyApp(),
    ),
  );
}
