// lib/core/services/fcm_handler.dart

// Top-level — background/killed app, MUST be top-level function
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  await _handleMessage(message);
}

// Called once during app init — wires foreground + background handlers
void initFcmHandlers() {
  // Foreground — app is open
  FirebaseMessaging.onMessage.listen((message) {
    _handleMessage(message);
  });

  // Background tap — app resumes from notification tap (not relevant for data-only)
  // For data messages you don't need onMessageOpenedApp unless you add
  // a notification field to the FCM payload alongside data
}

Future<void> _handleMessage(RemoteMessage message) async {
  final data = message.data;
  final type = data['type'];
  final groupId = data['group_id'];
  final questId = data['quest_id'];

  if (type == null || groupId == null || questId == null) return;

  final db = await openDatabase();
  try {
    switch (type) {
      case 'QUEST_CREATED':
        await SyncService(db).syncQuests(groupId);
        final quest = await db.questsDao.getByPublicId(questId);
        if (quest != null) {
          await NotificationDisplayService.showQuestNotification(quest);
        }
      case 'QUEST_CANCELLED':
        await NotificationDisplayService.cancelQuestNotification(quest.id);
        await SyncService(db).syncQuests(groupId);
    }
  } finally {
    await db.close();
  }
}
