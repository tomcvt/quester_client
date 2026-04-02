import 'package:drift/drift.dart';

/// Groups table schema
///
/// - publicId: UUID for group, globally unique
class Groups extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// UUID for group, globally unique
  TextColumn get publicId => text()();
  TextColumn get name => text()();
  TextColumn get type => text().withDefault(
    Constant(GroupType.work.value),
  )(); // you handle enum mapping manually
  TextColumn get visibility => text().withDefault(
    Constant(GroupVisibility.private.value),
  )(); // you handle enum mapping manually
  DateTimeColumn get createdAt => dateTime()();
}

enum GroupVisibility { public, private }

extension GroupVisibilityX on GroupVisibility {
  String get value => name; // enum.name = 'public', 'private'
  String get apiValue => name.toUpperCase(); // 'PUBLIC', 'PRIVATE' for API
  String get label {
    switch (this) {
      case GroupVisibility.public:
        return 'Public';
      case GroupVisibility.private:
        return 'Private';
      default:
        return name;
    }
  }

  static GroupVisibility fromString(String s) =>
      GroupVisibility.values.firstWhere((e) => e.name == s.toLowerCase());
}

enum GroupType { work, personal }

extension GroupTypeX on GroupType {
  String get value => name;
  String get apiValue => name.toUpperCase();
  String get label {
    switch (this) {
      case GroupType.work:
        return 'Work';
      case GroupType.personal:
        return 'Personal';
      default:
        return name;
    }
  }

  static GroupType fromString(String s) =>
      GroupType.values.firstWhere((e) => e.name == s.toLowerCase());
}

class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get publicId => text()();
  TextColumn get username => text()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {publicId},
  ];
}

//-- GroupMembers

enum MemberRole { owner, member }

extension MemberRoleX on MemberRole {
  String get value => name;
  String get apiValue => name.toUpperCase();
  static MemberRole fromString(String s) =>
      MemberRole.values.firstWhere((e) => e.name == s.toLowerCase());
  String get label {
    switch (this) {
      case MemberRole.owner:
        return 'Owner';
      case MemberRole.member:
        return 'Member';
      default:
        return name;
    }
  }
}

// GroupMembers stores denormalized user data (username) intentionally.
// At MVP, members are only ever displayed in group context — no User table needed.
// Extend to normalized Users table when:
//   - profile screen exists
//   - user appears in multiple independent contexts
//   - username changes need to propagate consistently
class GroupMembers extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get groupId => integer().references(Groups, #id)();
  TextColumn get userPublicId => text().references(Users, #publicId)();
  TextColumn get role =>
      textEnum<MemberRole>().withDefault(Constant(MemberRole.member.value))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {groupId, userPublicId}, // prevent duplicate memberships
  ];
}

/*
Server data model for reference
class Quest(Base):
    __tablename__ = "quests"
    
    @staticmethod
    def new(quest: NewQuest) -> 'Quest':
        return Quest(
            group_id=quest.group_id,
            name=quest.name,
            public_id=uuid.uuid4(),
            data=quest.data,
            contact_info=quest.contact_info,
            deadline=quest.deadline,
            address=quest.address,
            contact_number=quest.contact_number,
            type=quest.type,
            inclusive=quest.inclusive,
            status=quest.status,
            creator_id=quest.creator_id
        )

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    group_id: Mapped[int] = mapped_column(ForeignKey("groups.id"), nullable=False)
    public_id: Mapped[uuid.UUID] = mapped_column(Uuid(as_uuid=True, native_uuid=False), default=uuid.uuid4, unique=True, nullable=False)
    name: Mapped[str] = mapped_column(String, nullable=False)
    data: Mapped[str] = mapped_column(String, nullable=True)  # JSON string or any other relevant data
    deadline: Mapped[str] = mapped_column(String, nullable=True)
    address: Mapped[str] = mapped_column(String, nullable=True)
    contact_number: Mapped[str] = mapped_column(String, nullable=True)
    contact_info: Mapped[str] = mapped_column(String, nullable=True)  # Optional field for contact info
    type: Mapped[QuestType] = mapped_column(Enum(QuestType), nullable=False)
    inclusive: Mapped[bool] = mapped_column(Boolean, nullable=False)
    status: Mapped[QuestStatus] = mapped_column(Enum(QuestStatus), nullable=False)
    creator_id: Mapped[int] = mapped_column(ForeignKey("users.id"), nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(DateTime, server_default=func.now(), onupdate=func.now())

    //TODO refactor 
*/
@TableIndex(
  name: 'quests_group_status_updated_idx',
  columns: {#groupId, #status, #updatedAt},
)
class Quests extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get groupId => integer().references(Groups, #id)();
  TextColumn get publicId => text()();
  TextColumn get name => text()();
  TextColumn get data => text().nullable()();
  TextColumn get deadline => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get contactNumber => text().nullable()();
  TextColumn get contactInfo => text().nullable()();
  TextColumn get type =>
      textEnum<QuestType>().withDefault(Constant(QuestType.job.value))();
  BoolColumn get inclusive => boolean()();
  TextColumn get status => textEnum<QuestStatus>().withDefault(
    Constant(QuestStatus.started.value),
  )();
  IntColumn get creatorId => integer().references(Users, #id)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(
    currentDateAndTime,
  )(); // update on change logic in code
  TextColumn get acceptedById => text().nullable()();

  //indexes
  @override
  List<Set<Column>> get uniqueKeys => [
    {publicId}, // ensure publicId uniqueness
  ];
}

enum QuestType { job }

extension QuestTypeX on QuestType {
  String get value => name;
  String get apiValue => name.toUpperCase();
  String get label {
    switch (this) {
      case QuestType.job:
        return 'Job';
      default:
        return name;
    }
  }

  static QuestType fromString(String s) =>
      QuestType.values.firstWhere((e) => e.name == s.toLowerCase());
}

enum QuestStatus { started, accepted, completed, deleted, timedOut }

extension QuestStatusX on QuestStatus {
  String get value => name;
  String get apiValue => name.toUpperCase();
  String get label {
    switch (this) {
      case QuestStatus.started:
        return 'Started';
      case QuestStatus.accepted:
        return 'Accepted';
      case QuestStatus.completed:
        return 'Completed';
      case QuestStatus.deleted:
        return 'Deleted';
      case QuestStatus.timedOut:
        return 'Timed Out';
      default:
        return name;
    }
  }

  static QuestStatus fromString(String s) =>
      QuestStatus.values.firstWhere((e) => e.name == s.toLowerCase());
}
