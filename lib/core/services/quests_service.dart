import 'package:drift/drift.dart';
import 'package:quester_client/core/data/app_database.dart';
import 'package:quester_client/core/data/data_tables.dart';
import 'package:quester_client/core/data/groups_dao.dart';
import 'package:quester_client/core/data/quests_dao.dart';
import 'package:quester_client/core/http/api_client.dart';
import 'package:quester_client/core/services/app_initializer.dart';
import 'package:uuid/uuid.dart';

import '../utils/logger_util.dart';

/*
Server data model for reference:
class CreateQuestRequest(BaseModel):
    group_public_id: uuid.UUID
    name: str
    data: str
    contact_info: str | None
    type: QuestType
    inclusive: bool
    status: QuestStatus
    creator_public_id: uuid.UUID

class CreateQuestResponse(BaseModel):
    public_id: uuid.UUID
    name: str
    data: str | None
    contact_info: str | None
    type: QuestType
    inclusive: bool
    status: QuestStatus
    creator_public_id: uuid.UUID
    created_at: datetime
    updated_at: datetime
  */

class QuestsService {
  final QuestsDao _questsDao;
  final GroupsDao _groupsDao;
  final ApiClient _apiClient;

  QuestsService(this._questsDao, this._groupsDao, this._apiClient);

  /*
  int groupId,
    String name,
    String? data,
    String? contactInfo, {
    QuestType type = QuestType.job,
    bool inclusive = true,
    QuestStatus status = QuestStatus.started,
    bool offline = false,
    */
  //this but with required named

  Future<Quest?> createQuest({
    required int groupId,
    required String name,
    required String? description,
    // required DateTime? date, // DROPPED
    // required DateTime? deadlineStart, // DROPPED: replaced by deadline
    // required DateTime? deadlineEnd, // DROPPED: replaced by deadline
    required DateTime? deadline,
    required DateTime? startTime,
    required String? address,
    // required String? contactNumber, // DROPPED
    // required String? contactInfo, // DROPPED
    required String? data,
    // required QuestType type, // DROPPED
    required RewardType rewardType,
    required String? rewardValue,
    required bool inclusive,
    required QuestStatus status,
    bool offline = false,
    bool automaticReward = true,
  }) async {
    if (offline) {
      return await createOfflineQuest(
        groupId: groupId,
        name: name,
        description: description,
        deadline: deadline,
        startTime: startTime,
        address: address,
        data: data,
        rewardType: rewardType,
        rewardValue: rewardValue,
        inclusive: inclusive,
        status: status,
        automaticReward: automaticReward,
      );
    }
    final group = await _groupsDao.groupFromId(groupId);
    if (group == null) {
      logger.e('Group with id $groupId not found');
      return null;
    }
    /*
    group.publicId,
      name,
      data,
      deadline,
      address,
      contactNumber,
      contactInfo,
      type,
      inclusive,
      status,
      AppInitializer
          .installationId,
          */
    final questResponse = await _apiClient.createQuest(
      groupPublicId: group.publicId,
      name: name,
      description: description,
      // date: date, // DROPPED
      // deadlineStart: deadlineStart, // DROPPED
      // deadlineEnd: deadlineEnd, // DROPPED
      deadline: deadline,
      startTime: startTime,
      address: address,
      // contactNumber: contactNumber, // DROPPED
      // contactInfo: contactInfo, // DROPPED
      data: data,
      // type: type, // DROPPED
      rewardType: rewardType,
      rewardValue: rewardValue,
      inclusive: inclusive,
      status: status,
      // creatorPublicId: AppInitializer.installationId, // DROPPED: resolved server-side
      automaticReward: automaticReward,
    );
    //TODO - fetch actual user public id from shared prefs or similar
    logger.d('Quest created on backend: ${questResponse.toString()}');
    final newQuest = QuestsCompanion(
      groupId: Value(groupId),
      publicId: Value(questResponse.publicId),
      name: Value(questResponse.name),
      description: Value(questResponse.description),
      // date: Value(questResponse.date), // DROPPED
      // deadlineStart: Value(questResponse.deadlineStart), // DROPPED
      // deadlineEnd: Value(questResponse.deadlineEnd), // DROPPED
      deadline: Value(questResponse.deadline),
      startTime: Value(questResponse.startTime),
      address: Value(questResponse.address),
      // contactNumber: Value(questResponse.contactNumber), // DROPPED
      // contactInfo: Value(questResponse.contactInfo), // DROPPED
      data: Value(questResponse.data),
      // type: Value(questResponse.type), // DROPPED
      rewardType: Value(questResponse.rewardType),
      rewardValue: Value(questResponse.rewardValue),
      inclusive: Value(questResponse.inclusive),
      status: Value(questResponse.status),
      creatorPublicId: Value(questResponse.creatorPublicId),
      createdAt: Value(questResponse.createdAt),
      updatedAt: Value(questResponse.updatedAt),
      automaticReward: Value(questResponse.automaticReward),
    );

    final id = await _questsDao.insertQuest(newQuest);
    final createdQuest = await _questsDao.getById(id);
    logger.d('Quest inserted into local DB: ${createdQuest.toString()}');
    final fetchedQuests = await _apiClient.syncGroupQuests(group.publicId);
    logger.d('Fetched quests from backend: ${fetchedQuests.toString()}');
    await _questsDao.insertQuestsFromSync(groupId, fetchedQuests.quests);
    logger.d('Quests inserted into local DB for group $groupId');

    return createdQuest;
  }

  Future<Quest?> createOfflineQuest({
    required int groupId,
    required String name,
    required String? description,
    // required DateTime? date, // DROPPED
    // required DateTime? deadlineStart, // DROPPED
    // required DateTime? deadlineEnd, // DROPPED
    required DateTime? deadline,
    required DateTime? startTime,
    required String? address,
    // required String? contactNumber, // DROPPED
    // required String? contactInfo, // DROPPED
    required String? data,
    // required QuestType type, // DROPPED
    required RewardType rewardType,
    required String? rewardValue,
    required bool inclusive,
    required QuestStatus status,
    bool automaticReward = true,
  }) async {
    final newQuest = QuestsCompanion(
      groupId: Value(groupId),
      publicId: Value(Uuid().v4()),
      name: Value(name),
      description: Value(description),
      // date: Value(date), // DROPPED
      // deadlineStart: Value(deadlineStart), // DROPPED
      // deadlineEnd: Value(deadlineEnd), // DROPPED
      deadline: Value(deadline),
      startTime: Value(startTime),
      address: Value(address),
      // contactNumber: Value(contactNumber), // DROPPED
      // contactInfo: Value(contactInfo), // DROPPED
      data: Value(data),
      // type: Value(type), // DROPPED
      rewardType: Value(rewardType),
      rewardValue: Value(rewardValue),
      inclusive: Value(inclusive),
      status: Value(status),
      creatorPublicId: Value(AppInitializer.sessionData.publicId),
      createdAt: Value(DateTime.now()),
      automaticReward: Value(automaticReward),
    );
    final id = await _questsDao.insertQuest(newQuest);
    final createdQuest = await _questsDao.getById(id);
    return createdQuest;
  }

  Future<Quest?> openQuest(int questId, {bool offline = false}) async {
    final quest = await _questsDao.getById(questId);
    if (quest == null) {
      logger.e('Quest with id $questId not found');
      return null;
    }
    if (!offline) {
      await _apiClient.openQuest(quest.publicId);
      logger.d('Quest with id $questId opened on backend');
    } else {
      logger.d('Offline quest open, skipping API call');
    }
    final updatedQuest = quest.copyWith(status: QuestStatus.open);
    await _questsDao.updateQuest(updatedQuest);
    logger.d('Quest with id $questId status set to open in local DB');
    return updatedQuest;
  }

  Future<Quest?> acceptQuest(int questId, {bool offline = false}) async {
    final quest = await _questsDao.getById(questId);
    if (quest == null) {
      logger.e('Quest with id $questId not found');
      return null;
    }
    final updatedQuestResponse = offline
        ? null
        : await _apiClient.acceptQuest(quest.publicId);
    if (updatedQuestResponse != null) {
      logger.d('Quest accepted on backend: ${updatedQuestResponse.toString()}');
    } else {
      logger.d('Offline quest acceptance, skipping API call');
    }
    logger.d(
      "publicId = ${quest.publicId}, sessionPublicId = ${AppInitializer.sessionData.publicId}",
    );
    Quest updatedQuest = quest;
    //TODO update from quest response instead of just changing status and acceptedByPublicId, in case there are other changes
    if (!offline) {
      final acceptedByPublicId = updatedQuestResponse?.acceptedByPublicId;
      if (acceptedByPublicId == null) {
        logger.e('API response missing acceptedByPublicId');
        return null;
      }
      updatedQuest = quest.copyWith(
        status: QuestStatus.accepted,
        acceptedByPublicId: Value(acceptedByPublicId),
      );
    } else {
      updatedQuest = quest.copyWith(
        status: QuestStatus.accepted,
        acceptedByPublicId: Value(AppInitializer.sessionData.publicId),
      );
    }
    await _questsDao.updateQuest(updatedQuest);
    logger.d('Quest with id $questId accepted');
    return updatedQuest;
  }

  Future<Quest?> completeQuest(int questId, {bool offline = false}) async {
    final quest = await _questsDao.getById(questId);
    if (quest == null) {
      logger.e('Quest with id $questId not found');
      return null;
    }
    final updateResponse = offline
        ? null
        : await _apiClient.completeQuest(quest.publicId);
    if (updateResponse != null) {
      logger.d('Quest completed on backend: ${updateResponse.toString()}');
    } else {
      logger.d('Offline quest completion, skipping API call');
    }
    final updatedQuest = quest.copyWith(status: QuestStatus.completed);
    await _questsDao.updateQuest(updatedQuest);
    logger.d('Quest with id $questId completed');
    return updatedQuest;
  }

  Future<void> deleteQuest(int questId) async {
    final quest = await _questsDao.getById(questId);
    if (quest == null) {
      logger.e('Quest with id $questId not found');
      return;
    }
    // TODO [PENDING]: backend now soft-deletes (CANCELLED status) instead of hard-deleting.
    // Once backend sends a dedicated cancellation FCM event, switch to sync instead of delete.
    // For now: call delete endpoint (server soft-cancels) then hard-delete locally.
    // The FCM questDeleted handler in fcm_handler.dart will sync the CANCELLED status reactively.
    await _apiClient.deleteQuest(quest.publicId);
    logger.d('Quest with id $questId cancelled on backend (soft delete)');
    await _questsDao.deleteQuest(questId);
    logger.d('Quest with id $questId deleted from local DB');
  }

  /// Triggers the reward for a completed quest.
  /// Only the creator can call this; should only be available when
  /// quest.automaticReward == false && quest.status == QuestStatus.completed.
  /// TODO [PENDING]: server must implement POST /quests/{publicId}/reward
  /// and transition status to REWARDED + distribute currency.
  Future<Quest?> rewardQuest(int questId) async {
    final quest = await _questsDao.getById(questId);
    if (quest == null) {
      logger.e('Quest with id $questId not found');
      return null;
    }
    await _apiClient.rewardQuest(quest.publicId);
    logger.d('Reward triggered for quest $questId on backend');
    final updatedQuest = quest.copyWith(status: QuestStatus.rewarded);
    await _questsDao.updateQuest(updatedQuest);
    logger.d('Quest $questId status set to rewarded in local DB');
    return updatedQuest;
  }
}
