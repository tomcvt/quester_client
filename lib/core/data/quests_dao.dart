import 'package:drift/drift.dart';
import 'package:quester_client/core/data/app_database.dart';
import 'package:quester_client/core/data/data_tables.dart';
import 'package:quester_client/core/dto/quests.dart';
import 'package:quester_client/features/groups/group_home_screen.dart';

part 'quests_dao.g.dart';

@DriftAccessor(tables: [Quests, Groups, Users, GroupMembers])
class QuestsDao extends DatabaseAccessor<AppDatabase> with _$QuestsDaoMixin {
  QuestsDao(AppDatabase db) : super(db);

  Future<int> insertQuest(QuestsCompanion quest) => into(quests).insert(quest);

  Future<Quest?> questFromId(int id) =>
      (select(quests)..where((q) => q.id.equals(id))).getSingleOrNull();
  Future<List<Quest>> questsForGroup(int groupId) =>
      (select(quests)..where((q) => q.groupId.equals(groupId))).get();
  Future<List<Quest>> questsByGroupAndStatus(int groupId, QuestStatus status) =>
      (select(quests)
            ..where(
              (q) => q.groupId.equals(groupId) & q.status.equals(status.value),
            )
            ..orderBy([
              (q) => OrderingTerm(
                expression: q.updatedAt,
                mode: OrderingMode.desc,
              ),
            ]))
          .get();

  Future<void> updateQuest(Quest quest) {
    return update(quests).replace(quest);
  }

  Future<void> insertQuestsFromSync(
    int groupId,
    List<QuestSyncDTO> questList,
  ) async {
    await batch((batch) {
      for (final quest in questList) {
        final companion = QuestsCompanion(
          groupId: Value(groupId),
          publicId: Value(quest.publicId),
          name: Value(quest.name),
          data: Value(quest.data),
          contactInfo: Value(quest.contactInfo),
          type: Value(quest.type),
          inclusive: Value(quest.inclusive),
          status: Value(quest.status),
          creatorId: Value(1),
          createdAt: Value(quest.createdAt),
          updatedAt: Value(quest.updatedAt),
        );
        batch.insert(
          // ignore: unnecessary_this
          this.quests,
          companion,
          onConflict: DoUpdate(
            (old) => companion,
            // ignore: unnecessary_this
            target: [this.quests.publicId],
          ),
        );
      }
    });
  }

  Stream<List<Quest>> watchAllQuests() => select(quests).watch();
  Stream<Quest?> watchQuestFromId(int id) =>
      (select(quests)..where((q) => q.id.equals(id))).watchSingleOrNull();
  Stream<List<Quest>> watchQuestsForGroup(int groupId) =>
      (select(quests)..where((q) => q.groupId.equals(groupId))).watch();
  Stream<List<Quest>> watchQuestsByGroupAndStatus(
    int groupId,
    QuestStatus status,
  ) =>
      (select(quests)
            ..where(
              (q) => q.groupId.equals(groupId) & q.status.equals(status.value),
            )
            ..orderBy([
              (q) => OrderingTerm(
                expression: q.updatedAt,
                mode: OrderingMode.desc,
              ),
            ]))
          .watch();
  Stream<Quest?> watchByGroupAndId(int groupId, int questId) =>
      (select(quests)..where(
            (q) =>
                q.groupId.equals(groupId) &
                q.id.equals(questId), //maybe just use id here
          ))
          .watchSingleOrNull();
  Stream<List<Quest>> watchByGroupAndFilter(int groupId, TaskFilter filter) {
    final query = select(quests)..where((q) => q.groupId.equals(groupId));
    switch (filter) {
      case TaskFilter.all:
        break; // no additional where clause
      case TaskFilter.active:
        query.where((q) => q.status.equals(QuestStatus.started.value));
        break;
      case TaskFilter.accepted:
        query.where((q) => q.status.equals(QuestStatus.accepted.value));
        break;
      case TaskFilter.completed:
        query.where((q) => q.status.equals(QuestStatus.completed.value));
        break;
      case TaskFilter.other:
        query.where(
          (q) => q.status.isNotIn([
            QuestStatus.started.value,
            QuestStatus.accepted.value,
            QuestStatus.completed.value,
          ]),
        );
        break;
    }
    return (query..orderBy([
          (q) => OrderingTerm(expression: q.updatedAt, mode: OrderingMode.desc),
        ]))
        .watch();
  }

  // Add your DAO methods here
}
