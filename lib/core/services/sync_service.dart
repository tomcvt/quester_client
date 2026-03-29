import 'package:quester_client/core/data/app_database.dart';
import 'package:quester_client/core/http/api_client.dart';

import '../utils/logger_util.dart';

class SyncService {
  final AppDatabase _db;
  final ApiClient _apiClient;

  SyncService(this._db, this._apiClient);

  Future<void> syncNewQuests(String groupPublicId) async {
    final group = await _db.groupsDao.groupFromPublicId(groupPublicId);
    if (group == null) {
      logger.e('Group with public id $groupPublicId not found');
      return;
    }
    final lastUpdateTime = await _db.questsDao.getLatestUpdateTimeForGroup(
      group.id,
    );
    final questsResponse = await _apiClient.syncGroupQuestsSince(
      groupPublicId,
      lastUpdateTime,
    );
    await _db.questsDao.insertQuestsFromSync(group.id, questsResponse.quests);
  }
}
