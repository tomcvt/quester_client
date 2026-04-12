// lib/core/services/fcm_handler.dart

// Top-level — background/killed app, MUST be top-level function
import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:quester_client/core/data/app_database.dart';
import 'package:quester_client/core/data/data_tables.dart';
import 'package:quester_client/core/database/connection/connection.dart';
import 'package:quester_client/core/http/api_client.dart';
import 'package:quester_client/core/services/app_initializer.dart';
import 'package:quester_client/core/services/notification_display_service.dart';
import 'package:quester_client/core/services/sync_service.dart';
import 'package:quester_client/core/utils/logger_util.dart';
import 'package:quester_client/core/constants/const.dart';
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
  final sessionToken = await secureStorage.read(key: sessionTokenKey) ?? '';
  final myPublicId = await secureStorage.read(key: publicIdKey) ?? '';

  final data = message.data;
  final type = data['type'];
  final groupPublicId = data['group_public_id'];
  final questPublicId = data['quest_public_id'];
  final acceptedByPublicId = data['accepted_by_public_id'];
  final userPublicId = data['user_public_id']; // for user events
  final newRole = data['new_role']; // for USER_ROLE_CHANGED events
  logger.d(
    'Received FCM message: type=$type, \n groupPublicId=$groupPublicId, \n questPublicId=$questPublicId, \n acceptedByPublicId=$acceptedByPublicId',
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
      case questCreated:
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
      case questTaken:
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
        //TODO make sure server fires this to EVERYONE including source
        if (!kIsWeb) {
          await NotificationDisplayService.cancelQuestNotification(newQuest.id);
          if (newQuest.acceptedByPublicId == myPublicId) {
            await NotificationDisplayService.showYouDoQuestNotification(
              newQuest,
            );
          }
        }
        if (newQuest.acceptedByPublicId == null) {
          logger.w(
            'Received QUEST_TAKEN for quest ${newQuest.publicId} but acceptedByPublicId is null',
          );
        }
      case questDeleted:
        final deletedQuest = await syncService.deleteQuest(
          groupPublicId,
          questPublicId,
        );
        if (deletedQuest != null) {
          logger.i('Quest deleted: ${deletedQuest.name}');
        } else {
          logger.e(
            'Failed to sync deleted quest with public id $questPublicId',
          );
          break;
        }
        if (!kIsWeb) {
          if (acceptedByPublicId == myPublicId) {
            await NotificationDisplayService.questInProgressDeletedNotification(
              deletedQuest,
            );
          } else {
            await NotificationDisplayService.cancelQuestNotification(
              deletedQuest.id,
            );
          }
        }
      case yourQuestTaken:
        //inform the quest creator that their quest was taken by someone
        final newQuest = await syncService.syncNewQuests(
          groupPublicId,
          questPublicId,
        );
        if (newQuest != null) {
          logger.i('Your quest was taken: ${newQuest.name}');
        } else {
          logger.e(
            'Failed to sync updated quest with public id $questPublicId',
          );
          break;
        }
        final username = await db.usersDao
            .getByPublicId(newQuest.acceptedByPublicId ?? '')
            .then((u) => u?.username ?? 'Someone');
        if (!kIsWeb) {
          await NotificationDisplayService.showYourQuestTakenNotification(
            newQuest,
            username,
          );
          if (newQuest.acceptedByPublicId == myPublicId) {
            await NotificationDisplayService.showYouDoQuestNotification(
              newQuest,
            );
          }
        }
        //TODO later worry about inclusive quests (creator takes it too) and show different message in that case
        _incomingQuestController.add(
          QuestNudge(
            type: type,
            questId: newQuest.id.toString(),
            groupId: newQuest.groupId.toString(),
            takenByUsername: username,
          ),
        );
      case questCompleted:
        final newQuest = await syncService.syncNewQuests(
          groupPublicId,
          questPublicId,
        );
        if (newQuest != null) {
          logger.i('Quest completed: ${newQuest.name}');
        } else {
          logger.e(
            'Failed to sync completed quest with public id $questPublicId',
          );
          break;
        }
        final username = await db.usersDao
            .getByPublicId(newQuest.acceptedByPublicId ?? '')
            .then((u) => u?.username ?? 'Someone');
        if (!kIsWeb) {
          await NotificationDisplayService.cancelQuestNotification(newQuest.id);
          //takes care of both quests type and ongoing notification
        }
      case yourQuestCompleted:
        final newQuest = await syncService.syncNewQuests(
          groupPublicId,
          questPublicId,
        );
        if (newQuest != null) {
          logger.i('Your quest was completed: ${newQuest.name}');
        } else {
          logger.e(
            'Failed to sync updated quest with public id $questPublicId',
          );
          break;
        }
        final username = await db.usersDao
            .getByPublicId(newQuest.acceptedByPublicId ?? '')
            .then((u) => u?.username ?? 'Someone');
        if (!kIsWeb) {
          await NotificationDisplayService.showYourQuestCompletedOneTimeNotification(
            newQuest,
            username,
          );
        }
      case userRoleChanged:
        //TODO handle role change events (e.g. show notification if user is promoted to admin or something)
        //actually sync as this is most important
        MemberRole newRoleEnum;
        bool hasLeft = false;
        try {
          newRoleEnum = MemberRoleX.fromString(newRole);
        } catch (e) {
          hasLeft = true;
          logger.i(
            'Failed to parse role change, meaning user likely left the group. newRole=$newRole',
          );
        }
        if (hasLeft) {
          await syncService.syncUsersAndGroupMembersOnNotification(
            groupPublicId,
            removedUserPublicId: userPublicId,
          );
        } else {
          await syncService.syncUsersAndGroupMembersOnNotification(
            groupPublicId,
            addedUserPublicId: userPublicId,
          );
        }
      default:
        logger.w('Received FCM message with unknown type: $type');
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
