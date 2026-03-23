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

  Future<Quest?> createQuest(
    int groupId,
    String name,
    String? data,
    String? contactInfo, {
    QuestType type = QuestType.job,
    bool inclusive = true,
    QuestStatus status = QuestStatus.started,
    bool offline = false,
  }) async {
    if (offline) {
      return await createOfflineQuest(
        groupId,
        name,
        data,
        contactInfo,
        type,
        inclusive,
        status,
      );
    }
    final group = await _groupsDao.groupFromId(groupId);
    final questResponse = await _apiClient.createQuest(
      group!.publicId,
      name,
      data,
      contactInfo,
      type,
      inclusive,
      status,
      AppInitializer
          .installationId, //TODO - fetch actual user public id from shared prefs or similar
    );
    logger.d('Quest created on backend: ${questResponse.toString()}');
    final newQuest = QuestsCompanion(
      groupId: Value(groupId),
      publicId: Value(questResponse.publicId),
      name: Value(questResponse.name),
      data: Value(questResponse.data),
      contactInfo: Value(questResponse.contactInfo),
      type: Value(questResponse.type),
      inclusive: Value(questResponse.inclusive),
      status: Value(questResponse.status),
      creatorId: Value(
        1,
      ), //TODO - fetch actual user id later/ or change to public id
      createdAt: Value(questResponse.createdAt),
      updatedAt: Value(questResponse.updatedAt),
    );

    final id = await _questsDao.insertQuest(newQuest);
    final createdQuest = await _questsDao.questFromId(id);
    logger.d('Quest inserted into local DB: ${createdQuest.toString()}');
    final fetchedQuests = await _apiClient.syncGroupQuests(group.publicId);
    logger.d('Fetched quests from backend: ${fetchedQuests.toString()}');
    await _questsDao.insertQuestsFromSync(groupId, fetchedQuests.quests);
    logger.d('Quests inserted into local DB for group $groupId');

    return createdQuest;
  }

  Future<Quest?> createOfflineQuest(
    int groupId,
    String name,
    String? data,
    String? contactInfo,
    QuestType type,
    bool inclusive,
    QuestStatus status,
  ) async {
    final newQuest = QuestsCompanion(
      groupId: Value(groupId),
      publicId: Value(Uuid().v4()),
      name: Value(name),
      data: Value(data),
      contactInfo: Value(contactInfo),
      type: Value(type),
      inclusive: Value(inclusive),
      status: Value(status),
      creatorId: Value(
        1,
      ), //TODO - fetch actual user id later/ or change to public id
      createdAt: Value(DateTime.now()),
    );
    final id = await _questsDao.insertQuest(newQuest);
    final createdQuest = await _questsDao.questFromId(id);
    return createdQuest;
  }
}
