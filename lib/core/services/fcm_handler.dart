// lib/core/services/fcm_handler.dart

// Top-level — background/killed app, MUST be top-level function
import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:quester_client/core/data/app_database.dart';
import 'package:quester_client/core/database/connection/connection.dart';
import 'package:quester_client/core/http/api_client.dart';
import 'package:quester_client/core/services/notification_display_service.dart';
import 'package:quester_client/core/services/sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

/*
data={
                'type': 'QUEST_CREATED',
                'group_public_id': questEvent.group_public_id,
                'quest_public_id': questEvent.public_id,
            },

data={
                'type': 'QUEST_TAKEN',
                'group_public_id': questEvent.group_public_id,
                'quest_public_id': questEvent.public_id,
                'accepted_by_public_id': questEvent.accepted_by_public_id if questEvent.accepted_by_public_id else '',
            },
*/

Future<void> _handleMessage(RemoteMessage message) async {
  final prefs = await SharedPreferences.getInstance();
  final secureStorage = FlutterSecureStorage();
  final apiBaseUrl =
      prefs.getString('api_base_url') ?? 'http://localhost:8100/api/v1/';
  final installationId = prefs.getString('installation_id') ?? '';
  final sessionToken = await secureStorage.read(key: 'session_token') ?? '';

  final data = message.data;
  final type = data['type'];
  final groupPublicId = data['group_public_id'];
  final questPublicId = data['quest_public_id'];

  if (type == null || groupPublicId == null || questPublicId == null) return;

  final executor = await openConnection();
  final db = AppDatabase(executor);

  final apiClient = ApiClient(
    apiBaseUrl,
    installationId,
    sessionToken: sessionToken,
  );
  final syncService = SyncService(db, apiClient);

  try {
    switch (type) {
      case 'QUEST_CREATED':
        await syncService.syncNewQuests(groupPublicId);
        final quest = await db.questsDao.getByPublicId(questPublicId);
        if (quest != null && !kIsWeb) {
          await NotificationDisplayService.showQuestNotification(quest);
        }
        _incomingQuestController.add(
          QuestNudge(
            type: type,
            questId: questPublicId,
            groupId: groupPublicId,
          ),
        );
      case 'QUEST_TAKEN':
        await syncService.syncNewQuests(groupPublicId);
        final quest = await db.questsDao.getByPublicId(questPublicId);
        if (quest != null && !kIsWeb) {
          await NotificationDisplayService.cancelQuestNotification(quest.id);
        }
    }
  } finally {
    await db.close();
  }
}

final _incomingQuestController = StreamController<QuestNudge>.broadcast();
Stream<QuestNudge> get incomingQuestStream => _incomingQuestController.stream;

final incomingQuestProvider = StreamProvider<QuestNudge>((ref) {
  return incomingQuestStream;
});

// Simple data class — just enough for the popup
class QuestNudge {
  final String type; // QUEST_CREATED / QUEST_CANCELLED
  final String questId;
  final String groupId;
  QuestNudge({
    required this.type,
    required this.questId,
    required this.groupId,
  });
}
