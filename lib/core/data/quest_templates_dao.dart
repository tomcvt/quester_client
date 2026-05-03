import 'package:drift/drift.dart';
import 'package:quester_client/core/data/app_database.dart';
import 'package:quester_client/core/data/data_tables.dart';

part 'quest_templates_dao.g.dart';

@DriftAccessor(tables: [QuestTemplates])
class QuestTemplatesDao extends DatabaseAccessor<AppDatabase>
    with _$QuestTemplatesDaoMixin {
  QuestTemplatesDao(AppDatabase db) : super(db);

  /// Return up to [limit] most-recently-saved templates whose name begins with
  /// [query] (case-insensitive prefix match — uses the B-tree index on `name`).
  ///
  /// If [query] is empty, returns the most recent [limit] templates overall so
  /// the user sees useful suggestions on first tap even before typing.
  ///
  /// Special LIKE characters (`%`, `_`) are stripped from [query] to keep the
  /// SQL safe without needing an ESCAPE clause.
  Future<List<QuestTemplate>> searchByName(
    String query, {
    int limit = 20,
  }) async {
    final safeQuery = query.replaceAll('%', '').replaceAll('_', '');

    final dbQuery = select(questTemplates)
      ..orderBy([
        (t) => OrderingTerm(expression: t.savedAt, mode: OrderingMode.desc),
      ])
      ..limit(limit);

    if (safeQuery.isNotEmpty) {
      dbQuery.where((t) => t.name.like('$safeQuery%'));
    }

    final rows = await dbQuery.get();

    // Deduplicate: keep only the most-recently-saved row per distinct name.
    // Since rows are already ordered desc by savedAt, the first occurrence of
    // each name is the freshest.
    final seen = <String>{};
    return rows.where((r) => seen.add(r.name.toLowerCase())).take(8).toList();
  }

  /// Persist a quest configuration as a template.
  /// Always inserts a new row — deduplication is done client-side in
  /// [searchByName].
  Future<int> saveTemplate(QuestTemplatesCompanion entry) =>
      into(questTemplates).insert(entry);

  Future<int> deleteTemplate(int id) async {
    return (delete(questTemplates)..where((t) => t.id.equals(id))).go();
  }

  Future<void> clear() async {
    await delete(questTemplates).go();
  }
}
