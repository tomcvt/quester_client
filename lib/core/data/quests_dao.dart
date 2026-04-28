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

  Future<Quest?> getById(int id) =>
      (select(quests)..where((q) => q.id.equals(id))).getSingleOrNull();
  Future<Quest?> getByPublicId(String publicId) => (select(
    quests,
  )..where((q) => q.publicId.equals(publicId))).getSingleOrNull();
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

  Future<DateTime> getLatestUpdateTimeForGroup(int groupId) async {
    final result =
        await (select(quests)
              ..where((q) => q.groupId.equals(groupId))
              ..orderBy([
                (q) => OrderingTerm(
                  expression: q.updatedAt,
                  mode: OrderingMode.desc,
                ),
              ])
              ..limit(1))
            .getSingleOrNull();
    return result?.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
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
          description: Value(quest.description),
          // date: Value(quest.date), // DROPPED
          // deadlineStart: Value(quest.deadlineStart), // DROPPED
          // deadlineEnd: Value(quest.deadlineEnd), // DROPPED
          deadline: Value(quest.deadline),
          startTime: Value(quest.startTime),
          address: Value(quest.address),
          // contactNumber: Value(quest.contactNumber), // DROPPED
          // contactInfo: Value(quest.contactInfo), // DROPPED
          data: Value(quest.data),
          // type: Value(quest.type), // DROPPED
          rewardType: Value(quest.rewardType),
          rewardValue: Value(quest.rewardValue),
          inclusive: Value(quest.inclusive),
          status: Value(quest.status),
          creatorPublicId: Value(quest.creatorPublicId),
          acceptedByPublicId: Value(quest.acceptedByPublicId),
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
      //TODO [PENDING]: change taskfilter mapping
      case TaskFilter.all:
        break; // no additional where clause
      case TaskFilter.active:
        // active = CREATED | OPEN
        query.where(
          (q) => q.status.isIn([
            QuestStatus.created.value,
            QuestStatus.open.value,
          ]),
        );
        break;
      case TaskFilter.accepted:
        query.where((q) => q.status.equals(QuestStatus.accepted.value));
        break;
      case TaskFilter.completed:
        query.where((q) => q.status.equals(QuestStatus.completed.value));
        break;
      case TaskFilter.other:
        // other = CANCELLED | EXPIRED | CREATED (was: anything not started/accepted/completed)
        query.where(
          (q) => q.status.isIn([
            QuestStatus.cancelled.value,
            QuestStatus.expired.value,
          ]),
        );
        break;
    }
    if (filter == TaskFilter.active) {
      // For active tasks, we want to order by startTime desc
      query.orderBy([
        (q) => OrderingTerm(expression: q.startTime, mode: OrderingMode.desc),
      ]);
    } else {
      // For other filters, we can order by createdAt desc
      query.orderBy([
        (q) => OrderingTerm(expression: q.createdAt, mode: OrderingMode.desc),
      ]);
    }
    return query.watch();
    return (query..orderBy([
          (q) => OrderingTerm(expression: q.updatedAt, mode: OrderingMode.desc),
        ]))
        .watch();
  }

  Future<void> clear() async {
    await delete(quests).go();
  }

  Future<int> deleteQuest(int id) async {
    return await (delete(quests)..where((q) => q.id.equals(id))).go();
  }

  // Add your DAO methods here
}
