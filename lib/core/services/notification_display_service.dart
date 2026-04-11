// lib/core/services/notification_display_service.dart

import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:quester_client/core/data/app_database.dart';

class NotificationDisplayService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(
      settings: const InitializationSettings(android: android),
    );
    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    // Create the channel once — Android ignores duplicate creates
    const questsChannel = AndroidNotificationChannel(
      'quests', // id
      'Active Quests', // name shown in system settings
      enableLights: true,
      ledColor: Color(0xFFFF8B28),
      importance: Importance.high,
    );
    //androidAlarmSound = AndroidNotificationSound()
    const standardChannel = AndroidNotificationChannel(
      'standard-notifications',
      'Key Notifications',
      importance: Importance.high,
      enableLights: true,
      ledColor: Color.fromARGB(255, 40, 234, 255),
    );
    await androidImpl?.createNotificationChannel(questsChannel);
    await androidImpl?.createNotificationChannel(standardChannel);
  }

  static Future<void> showQuestNotification(Quest quest) async {
    await _plugin.show(
      id: quest
          .id, // your local Drift int id — deterministic, no mapping needed
      title: quest.name,
      body: quest.data ?? 'Tap to open',
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'quests',
          'Active Quests',
          importance: Importance.high,
          priority: Priority.high,
          ongoing: true, // non-dismissable by user
          autoCancel: false,
        ),
      ),
    );
  }

  static Future<void> cancelQuestNotification(int questLocalId) async {
    await _plugin.cancel(id: questLocalId);
  }

  static Future<void> showYourQuestTakenNotification(
    Quest quest,
    String takenByUsername,
  ) async {
    await _plugin.show(
      id: quest.id,
      title: 'Your quest was taken!',
      body: '${quest.name} has been accepted by $takenByUsername.',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'standard-notifications',
          'Key Notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  static Future<void> showYouDoQuestNotification(Quest quest) async {
    await _plugin.show(
      id: quest.id,
      title: 'You are completing a quest!',
      body:
          '${quest.name} : ${quest.deadlineStart != null ? 'Start at ${_dateTimeHourMinute(quest.deadlineStart!)}' : 'Tap to open'}',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'quests',
          'Active Quests',
          importance: Importance.high,
          priority: Priority.high,
          ongoing: true, // non-dismissable by user
          autoCancel: false,
        ),
      ),
    );
  }

  static Future<void> showYourQuestCompletedOneTimeNotification(
    Quest quest,
    String completedByUsername,
  ) async {
    await _plugin.show(
      id: quest.id,
      title: 'Your quest was completed!',
      body: '${quest.name} done by $completedByUsername!',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'standard-notifications',
          'Key Notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  static Future<void> questInProgressDeletedNotification(Quest quest) async {
    await _plugin.show(
      id: quest.id,
      title: 'CANCELED: ${quest.name}',
      body: 'A quest you are doing was deleted by the creator.',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'standard-notifications',
          'Key Notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  static String _dateTimeHourMinute(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    //TODO dive in on padLeft and character length, this.length etc.
    return '$hour:$minute';
  }
}
