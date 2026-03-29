// lib/core/services/notification_display_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationDisplayService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(const InitializationSettings(android: android));

    // Create the channel once — Android ignores duplicate creates
    const channel = AndroidNotificationChannel(
      'quests',          // id
      'Active Quests',   // name shown in system settings
      importance: Importance.high,
    );
    await _plugin
        .resolvePlatformSpecificImplementation
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  static Future<void> showQuestNotification(Quest quest) async {
    await _plugin.show(
      quest.id,  // your local Drift int id — deterministic, no mapping needed
      quest.name,
      quest.data ?? 'Tap to open',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'quests',
          'Active Quests',
          importance: Importance.high,
          priority: Priority.high,
          ongoing: true,       // non-dismissable by user
          autoCancel: false,
        ),
      ),
    );
  }

  static Future<void> cancelQuestNotification(int questLocalId) async {
    await _plugin.cancel(questLocalId);
  }
}