// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quest_templates_dao.dart';

// ignore_for_file: type=lint
mixin _$QuestTemplatesDaoMixin on DatabaseAccessor<AppDatabase> {
  $QuestTemplatesTable get questTemplates => attachedDatabase.questTemplates;
  QuestTemplatesDaoManager get managers => QuestTemplatesDaoManager(this);
}

class QuestTemplatesDaoManager {
  final _$QuestTemplatesDaoMixin _db;
  QuestTemplatesDaoManager(this._db);
  $$QuestTemplatesTableTableManager get questTemplates =>
      $$QuestTemplatesTableTableManager(
        _db.attachedDatabase,
        _db.questTemplates,
      );
}
