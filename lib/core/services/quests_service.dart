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
    required DateTime? date,
    required DateTime? deadlineStart,
    required DateTime? deadlineEnd,
    required String? address,
    required String? contactNumber,
    required String? contactInfo,
    required String? data,
    required QuestType type,
    required bool inclusive,
    required QuestStatus status,
    bool offline = false,
  }) async {
    if (offline) {
      return await createOfflineQuest(
        groupId: groupId,
        name: name,
        description: description,
        date: date,
        deadlineStart: deadlineStart,
        deadlineEnd: deadlineEnd,
        address: address,
        contactNumber: contactNumber,
        contactInfo: contactInfo,
        data: data,
        type: type,
        inclusive: inclusive,
        status: status,
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
      date: date,
      deadlineStart: deadlineStart,
      deadlineEnd: deadlineEnd,
      address: address,
      contactNumber: contactNumber,
      contactInfo: contactInfo,
      data: data,
      type: type,
      inclusive: inclusive,
      status: status,
      creatorPublicId: AppInitializer.installationId,
    );
    //TODO - fetch actual user public id from shared prefs or similar
    logger.d('Quest created on backend: ${questResponse.toString()}');
    final newQuest = QuestsCompanion(
      groupId: Value(groupId),
      publicId: Value(questResponse.publicId),
      name: Value(questResponse.name),
      description: Value(questResponse.description),
      date: Value(questResponse.date),
      deadlineStart: Value(questResponse.deadlineStart),
      deadlineEnd: Value(questResponse.deadlineEnd),
      address: Value(questResponse.address),
      contactNumber: Value(questResponse.contactNumber),
      contactInfo: Value(questResponse.contactInfo),
      data: Value(questResponse.data),
      type: Value(questResponse.type),
      inclusive: Value(questResponse.inclusive),
      status: Value(questResponse.status),
      creatorPublicId: Value(questResponse.creatorPublicId),
      createdAt: Value(questResponse.createdAt),
      updatedAt: Value(questResponse.updatedAt),
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
    required DateTime? date,
    required DateTime? deadlineStart,
    required DateTime? deadlineEnd,
    required String? address,
    required String? contactNumber,
    required String? contactInfo,
    required String? data,
    required QuestType type,
    required bool inclusive,
    required QuestStatus status,
  }) async {
    final newQuest = QuestsCompanion(
      groupId: Value(groupId),
      publicId: Value(Uuid().v4()),
      name: Value(name),
      description: Value(description),
      date: Value(date),
      deadlineStart: Value(deadlineStart),
      deadlineEnd: Value(deadlineEnd),
      address: Value(address),
      contactNumber: Value(contactNumber),
      contactInfo: Value(contactInfo),
      data: Value(data),
      type: Value(type),
      inclusive: Value(inclusive),
      status: Value(status),
      creatorPublicId: Value(AppInitializer.sessionData.publicId),
      createdAt: Value(DateTime.now()),
    );
    final id = await _questsDao.insertQuest(newQuest);
    final createdQuest = await _questsDao.getById(id);
    return createdQuest;
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
    await _apiClient.deleteQuest(quest.publicId);
    logger.d('Quest with id $questId deleted on backend');
    await _questsDao.deleteQuest(questId);
    logger.d('Quest with id $questId deleted from local DB');
  }
}
