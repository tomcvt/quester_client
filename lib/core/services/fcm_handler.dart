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
import 'package:quester_client/core/services/app_initializer.dart';
import 'package:quester_client/core/services/notification_display_service.dart';
import 'package:quester_client/core/services/sync_service.dart';
import 'package:quester_client/core/utils/logger_util.dart';
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
  logger.d(
    'Received FCM message: type=$type, groupPublicId=$groupPublicId, questPublicId=$questPublicId',
  );

  if (type == null || groupPublicId == null || questPublicId == null) return;

  final bool ownDb = !AppInitializer.isInitialized;
  final AppDatabase db;
  if (AppInitializer.isInitialized) {
    db = AppInitializer.db;
  } else {
    final executor = await openConnection();
    db = AppDatabase(executor);
  }

  final apiClient = ApiClient(
    apiBaseUrl,
    installationId,
    sessionToken: sessionToken,
  );
  final syncService = SyncService(db, apiClient);

  try {
    switch (type) {
      case 'QUEST_CREATED':
        final newQuest = await syncService.syncNewQuests(
          groupPublicId,
          questPublicId,
        );
        if (newQuest != null) {
          logger.i('New quest synced: ${newQuest.name}');
        } else {
          logger.e('Failed to sync new quest with public id $questPublicId');
          break;
        }
        if (!kIsWeb) {
          await NotificationDisplayService.showQuestNotification(newQuest);
        }
        _incomingQuestController.add(
          QuestNudge(
            type: type,
            questId: newQuest.id.toString(),
            groupId: newQuest.groupId.toString(),
          ),
        );
      case 'QUEST_TAKEN':
        final newQuest = await syncService.syncNewQuests(
          groupPublicId,
          questPublicId,
        );
        if (newQuest != null) {
          logger.i('Quest updated (taken): ${newQuest.name}');
        } else {
          logger.e(
            'Failed to sync updated quest with public id $questPublicId',
          );
          break;
        }
        if (!kIsWeb) {
          await NotificationDisplayService.cancelQuestNotification(newQuest.id);
        }
        if (newQuest.acceptedByPublicId == null) {
          logger.w(
            'Received QUEST_TAKEN for quest ${newQuest.publicId} but acceptedByPublicId is null',
          );
        }
        final username = await db.usersDao
            .getUserByPublicId(newQuest.acceptedByPublicId ?? '')
            .then((u) => u?.username ?? 'Someone');
        _incomingQuestController.add(
          QuestNudge(
            type: type,
            questId: newQuest.id.toString(),
            groupId: newQuest.groupId.toString(),
            takenByUsername: username,
          ),
        );
    }
  } finally {
    if (ownDb) await db.close();
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
  String? takenByUsername;
  QuestNudge({
    required this.type,
    required this.questId,
    required this.groupId,
    this.takenByUsername,
  });
}
