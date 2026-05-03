// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $GroupsTable extends Groups with TableInfo<$GroupsTable, Group> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GroupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _publicIdMeta = const VerificationMeta(
    'publicId',
  );
  @override
  late final GeneratedColumn<String> publicId = GeneratedColumn<String>(
    'public_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: Constant(GroupType.work.value),
  );
  static const VerificationMeta _visibilityMeta = const VerificationMeta(
    'visibility',
  );
  @override
  late final GeneratedColumn<String> visibility = GeneratedColumn<String>(
    'visibility',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: Constant(GroupVisibility.private.value),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    publicId,
    name,
    type,
    visibility,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'groups';
  @override
  VerificationContext validateIntegrity(
    Insertable<Group> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('public_id')) {
      context.handle(
        _publicIdMeta,
        publicId.isAcceptableOrUnknown(data['public_id']!, _publicIdMeta),
      );
    } else if (isInserting) {
      context.missing(_publicIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('visibility')) {
      context.handle(
        _visibilityMeta,
        visibility.isAcceptableOrUnknown(data['visibility']!, _visibilityMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Group map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Group(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      publicId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}public_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      visibility: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}visibility'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $GroupsTable createAlias(String alias) {
    return $GroupsTable(attachedDatabase, alias);
  }
}

class Group extends DataClass implements Insertable<Group> {
  final int id;

  /// UUID for group, globally unique
  final String publicId;
  final String name;
  final String type;
  final String visibility;
  final DateTime createdAt;
  const Group({
    required this.id,
    required this.publicId,
    required this.name,
    required this.type,
    required this.visibility,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['public_id'] = Variable<String>(publicId);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['visibility'] = Variable<String>(visibility);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  GroupsCompanion toCompanion(bool nullToAbsent) {
    return GroupsCompanion(
      id: Value(id),
      publicId: Value(publicId),
      name: Value(name),
      type: Value(type),
      visibility: Value(visibility),
      createdAt: Value(createdAt),
    );
  }

  factory Group.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Group(
      id: serializer.fromJson<int>(json['id']),
      publicId: serializer.fromJson<String>(json['publicId']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      visibility: serializer.fromJson<String>(json['visibility']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'publicId': serializer.toJson<String>(publicId),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'visibility': serializer.toJson<String>(visibility),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Group copyWith({
    int? id,
    String? publicId,
    String? name,
    String? type,
    String? visibility,
    DateTime? createdAt,
  }) => Group(
    id: id ?? this.id,
    publicId: publicId ?? this.publicId,
    name: name ?? this.name,
    type: type ?? this.type,
    visibility: visibility ?? this.visibility,
    createdAt: createdAt ?? this.createdAt,
  );
  Group copyWithCompanion(GroupsCompanion data) {
    return Group(
      id: data.id.present ? data.id.value : this.id,
      publicId: data.publicId.present ? data.publicId.value : this.publicId,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      visibility: data.visibility.present
          ? data.visibility.value
          : this.visibility,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Group(')
          ..write('id: $id, ')
          ..write('publicId: $publicId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('visibility: $visibility, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, publicId, name, type, visibility, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Group &&
          other.id == this.id &&
          other.publicId == this.publicId &&
          other.name == this.name &&
          other.type == this.type &&
          other.visibility == this.visibility &&
          other.createdAt == this.createdAt);
}

class GroupsCompanion extends UpdateCompanion<Group> {
  final Value<int> id;
  final Value<String> publicId;
  final Value<String> name;
  final Value<String> type;
  final Value<String> visibility;
  final Value<DateTime> createdAt;
  const GroupsCompanion({
    this.id = const Value.absent(),
    this.publicId = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.visibility = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  GroupsCompanion.insert({
    this.id = const Value.absent(),
    required String publicId,
    required String name,
    this.type = const Value.absent(),
    this.visibility = const Value.absent(),
    required DateTime createdAt,
  }) : publicId = Value(publicId),
       name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<Group> custom({
    Expression<int>? id,
    Expression<String>? publicId,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? visibility,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (publicId != null) 'public_id': publicId,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (visibility != null) 'visibility': visibility,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  GroupsCompanion copyWith({
    Value<int>? id,
    Value<String>? publicId,
    Value<String>? name,
    Value<String>? type,
    Value<String>? visibility,
    Value<DateTime>? createdAt,
  }) {
    return GroupsCompanion(
      id: id ?? this.id,
      publicId: publicId ?? this.publicId,
      name: name ?? this.name,
      type: type ?? this.type,
      visibility: visibility ?? this.visibility,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (publicId.present) {
      map['public_id'] = Variable<String>(publicId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (visibility.present) {
      map['visibility'] = Variable<String>(visibility.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GroupsCompanion(')
          ..write('id: $id, ')
          ..write('publicId: $publicId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('visibility: $visibility, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _publicIdMeta = const VerificationMeta(
    'publicId',
  );
  @override
  late final GeneratedColumn<String> publicId = GeneratedColumn<String>(
    'public_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneNumberMeta = const VerificationMeta(
    'phoneNumber',
  );
  @override
  late final GeneratedColumn<String> phoneNumber = GeneratedColumn<String>(
    'phone_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<UserRole, String> role =
      GeneratedColumn<String>(
        'role',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(UserRole.user.name),
      ).withConverter<UserRole>($UsersTable.$converterrole);
  @override
  List<GeneratedColumn> get $columns => [publicId, username, phoneNumber, role];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(
    Insertable<User> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('public_id')) {
      context.handle(
        _publicIdMeta,
        publicId.isAcceptableOrUnknown(data['public_id']!, _publicIdMeta),
      );
    } else if (isInserting) {
      context.missing(_publicIdMeta);
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    }
    if (data.containsKey('phone_number')) {
      context.handle(
        _phoneNumberMeta,
        phoneNumber.isAcceptableOrUnknown(
          data['phone_number']!,
          _phoneNumberMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {publicId};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      publicId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}public_id'],
      )!,
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      ),
      phoneNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone_number'],
      ),
      role: $UsersTable.$converterrole.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}role'],
        )!,
      ),
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<UserRole, String, String> $converterrole =
      const EnumNameConverter<UserRole>(UserRole.values);
}

class User extends DataClass implements Insertable<User> {
  final String publicId;
  final String? username;
  final String? phoneNumber;
  final UserRole role;
  const User({
    required this.publicId,
    this.username,
    this.phoneNumber,
    required this.role,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['public_id'] = Variable<String>(publicId);
    if (!nullToAbsent || username != null) {
      map['username'] = Variable<String>(username);
    }
    if (!nullToAbsent || phoneNumber != null) {
      map['phone_number'] = Variable<String>(phoneNumber);
    }
    {
      map['role'] = Variable<String>($UsersTable.$converterrole.toSql(role));
    }
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      publicId: Value(publicId),
      username: username == null && nullToAbsent
          ? const Value.absent()
          : Value(username),
      phoneNumber: phoneNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(phoneNumber),
      role: Value(role),
    );
  }

  factory User.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      publicId: serializer.fromJson<String>(json['publicId']),
      username: serializer.fromJson<String?>(json['username']),
      phoneNumber: serializer.fromJson<String?>(json['phoneNumber']),
      role: $UsersTable.$converterrole.fromJson(
        serializer.fromJson<String>(json['role']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'publicId': serializer.toJson<String>(publicId),
      'username': serializer.toJson<String?>(username),
      'phoneNumber': serializer.toJson<String?>(phoneNumber),
      'role': serializer.toJson<String>(
        $UsersTable.$converterrole.toJson(role),
      ),
    };
  }

  User copyWith({
    String? publicId,
    Value<String?> username = const Value.absent(),
    Value<String?> phoneNumber = const Value.absent(),
    UserRole? role,
  }) => User(
    publicId: publicId ?? this.publicId,
    username: username.present ? username.value : this.username,
    phoneNumber: phoneNumber.present ? phoneNumber.value : this.phoneNumber,
    role: role ?? this.role,
  );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      publicId: data.publicId.present ? data.publicId.value : this.publicId,
      username: data.username.present ? data.username.value : this.username,
      phoneNumber: data.phoneNumber.present
          ? data.phoneNumber.value
          : this.phoneNumber,
      role: data.role.present ? data.role.value : this.role,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('publicId: $publicId, ')
          ..write('username: $username, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('role: $role')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(publicId, username, phoneNumber, role);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.publicId == this.publicId &&
          other.username == this.username &&
          other.phoneNumber == this.phoneNumber &&
          other.role == this.role);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<String> publicId;
  final Value<String?> username;
  final Value<String?> phoneNumber;
  final Value<UserRole> role;
  final Value<int> rowid;
  const UsersCompanion({
    this.publicId = const Value.absent(),
    this.username = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.role = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String publicId,
    this.username = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.role = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : publicId = Value(publicId);
  static Insertable<User> custom({
    Expression<String>? publicId,
    Expression<String>? username,
    Expression<String>? phoneNumber,
    Expression<String>? role,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (publicId != null) 'public_id': publicId,
      if (username != null) 'username': username,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (role != null) 'role': role,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith({
    Value<String>? publicId,
    Value<String?>? username,
    Value<String?>? phoneNumber,
    Value<UserRole>? role,
    Value<int>? rowid,
  }) {
    return UsersCompanion(
      publicId: publicId ?? this.publicId,
      username: username ?? this.username,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (publicId.present) {
      map['public_id'] = Variable<String>(publicId.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (phoneNumber.present) {
      map['phone_number'] = Variable<String>(phoneNumber.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(
        $UsersTable.$converterrole.toSql(role.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('publicId: $publicId, ')
          ..write('username: $username, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('role: $role, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GroupMembersTable extends GroupMembers
    with TableInfo<$GroupMembersTable, GroupMember> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GroupMembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<int> groupId = GeneratedColumn<int>(
    'group_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES "groups" (id)',
    ),
  );
  static const VerificationMeta _userPublicIdMeta = const VerificationMeta(
    'userPublicId',
  );
  @override
  late final GeneratedColumn<String> userPublicId = GeneratedColumn<String>(
    'user_public_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (public_id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<MemberRole, String> role =
      GeneratedColumn<String>(
        'role',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(MemberRole.member.value),
      ).withConverter<MemberRole>($GroupMembersTable.$converterrole);
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<int> currency = GeneratedColumn<int>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    groupId,
    userPublicId,
    role,
    updatedAt,
    currency,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'group_members';
  @override
  VerificationContext validateIntegrity(
    Insertable<GroupMember> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('user_public_id')) {
      context.handle(
        _userPublicIdMeta,
        userPublicId.isAcceptableOrUnknown(
          data['user_public_id']!,
          _userPublicIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_userPublicIdMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {groupId, userPublicId},
  ];
  @override
  GroupMember map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GroupMember(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}group_id'],
      )!,
      userPublicId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_public_id'],
      )!,
      role: $GroupMembersTable.$converterrole.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}role'],
        )!,
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}currency'],
      )!,
    );
  }

  @override
  $GroupMembersTable createAlias(String alias) {
    return $GroupMembersTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<MemberRole, String, String> $converterrole =
      const EnumNameConverter<MemberRole>(MemberRole.values);
}

class GroupMember extends DataClass implements Insertable<GroupMember> {
  final int id;
  final int groupId;
  final String userPublicId;
  final MemberRole role;
  final DateTime updatedAt;
  final int currency;
  const GroupMember({
    required this.id,
    required this.groupId,
    required this.userPublicId,
    required this.role,
    required this.updatedAt,
    required this.currency,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['group_id'] = Variable<int>(groupId);
    map['user_public_id'] = Variable<String>(userPublicId);
    {
      map['role'] = Variable<String>(
        $GroupMembersTable.$converterrole.toSql(role),
      );
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['currency'] = Variable<int>(currency);
    return map;
  }

  GroupMembersCompanion toCompanion(bool nullToAbsent) {
    return GroupMembersCompanion(
      id: Value(id),
      groupId: Value(groupId),
      userPublicId: Value(userPublicId),
      role: Value(role),
      updatedAt: Value(updatedAt),
      currency: Value(currency),
    );
  }

  factory GroupMember.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GroupMember(
      id: serializer.fromJson<int>(json['id']),
      groupId: serializer.fromJson<int>(json['groupId']),
      userPublicId: serializer.fromJson<String>(json['userPublicId']),
      role: $GroupMembersTable.$converterrole.fromJson(
        serializer.fromJson<String>(json['role']),
      ),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      currency: serializer.fromJson<int>(json['currency']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'groupId': serializer.toJson<int>(groupId),
      'userPublicId': serializer.toJson<String>(userPublicId),
      'role': serializer.toJson<String>(
        $GroupMembersTable.$converterrole.toJson(role),
      ),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'currency': serializer.toJson<int>(currency),
    };
  }

  GroupMember copyWith({
    int? id,
    int? groupId,
    String? userPublicId,
    MemberRole? role,
    DateTime? updatedAt,
    int? currency,
  }) => GroupMember(
    id: id ?? this.id,
    groupId: groupId ?? this.groupId,
    userPublicId: userPublicId ?? this.userPublicId,
    role: role ?? this.role,
    updatedAt: updatedAt ?? this.updatedAt,
    currency: currency ?? this.currency,
  );
  GroupMember copyWithCompanion(GroupMembersCompanion data) {
    return GroupMember(
      id: data.id.present ? data.id.value : this.id,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      userPublicId: data.userPublicId.present
          ? data.userPublicId.value
          : this.userPublicId,
      role: data.role.present ? data.role.value : this.role,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      currency: data.currency.present ? data.currency.value : this.currency,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GroupMember(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('userPublicId: $userPublicId, ')
          ..write('role: $role, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('currency: $currency')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, groupId, userPublicId, role, updatedAt, currency);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GroupMember &&
          other.id == this.id &&
          other.groupId == this.groupId &&
          other.userPublicId == this.userPublicId &&
          other.role == this.role &&
          other.updatedAt == this.updatedAt &&
          other.currency == this.currency);
}

class GroupMembersCompanion extends UpdateCompanion<GroupMember> {
  final Value<int> id;
  final Value<int> groupId;
  final Value<String> userPublicId;
  final Value<MemberRole> role;
  final Value<DateTime> updatedAt;
  final Value<int> currency;
  const GroupMembersCompanion({
    this.id = const Value.absent(),
    this.groupId = const Value.absent(),
    this.userPublicId = const Value.absent(),
    this.role = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.currency = const Value.absent(),
  });
  GroupMembersCompanion.insert({
    this.id = const Value.absent(),
    required int groupId,
    required String userPublicId,
    this.role = const Value.absent(),
    required DateTime updatedAt,
    this.currency = const Value.absent(),
  }) : groupId = Value(groupId),
       userPublicId = Value(userPublicId),
       updatedAt = Value(updatedAt);
  static Insertable<GroupMember> custom({
    Expression<int>? id,
    Expression<int>? groupId,
    Expression<String>? userPublicId,
    Expression<String>? role,
    Expression<DateTime>? updatedAt,
    Expression<int>? currency,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (groupId != null) 'group_id': groupId,
      if (userPublicId != null) 'user_public_id': userPublicId,
      if (role != null) 'role': role,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (currency != null) 'currency': currency,
    });
  }

  GroupMembersCompanion copyWith({
    Value<int>? id,
    Value<int>? groupId,
    Value<String>? userPublicId,
    Value<MemberRole>? role,
    Value<DateTime>? updatedAt,
    Value<int>? currency,
  }) {
    return GroupMembersCompanion(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      userPublicId: userPublicId ?? this.userPublicId,
      role: role ?? this.role,
      updatedAt: updatedAt ?? this.updatedAt,
      currency: currency ?? this.currency,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<int>(groupId.value);
    }
    if (userPublicId.present) {
      map['user_public_id'] = Variable<String>(userPublicId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(
        $GroupMembersTable.$converterrole.toSql(role.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (currency.present) {
      map['currency'] = Variable<int>(currency.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GroupMembersCompanion(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('userPublicId: $userPublicId, ')
          ..write('role: $role, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('currency: $currency')
          ..write(')'))
        .toString();
  }
}

class $QuestsTable extends Quests with TableInfo<$QuestsTable, Quest> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuestsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<int> groupId = GeneratedColumn<int>(
    'group_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES "groups" (id)',
    ),
  );
  static const VerificationMeta _publicIdMeta = const VerificationMeta(
    'publicId',
  );
  @override
  late final GeneratedColumn<String> publicId = GeneratedColumn<String>(
    'public_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deadlineMeta = const VerificationMeta(
    'deadline',
  );
  @override
  late final GeneratedColumn<DateTime> deadline = GeneratedColumn<DateTime>(
    'deadline',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  @override
  late final GeneratedColumn<DateTime> startTime = GeneratedColumn<DateTime>(
    'start_time',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
    'data',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<RewardType, String> rewardType =
      GeneratedColumn<String>(
        'reward_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(RewardType.none.value),
      ).withConverter<RewardType>($QuestsTable.$converterrewardType);
  static const VerificationMeta _rewardValueMeta = const VerificationMeta(
    'rewardValue',
  );
  @override
  late final GeneratedColumn<String> rewardValue = GeneratedColumn<String>(
    'reward_value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _inclusiveMeta = const VerificationMeta(
    'inclusive',
  );
  @override
  late final GeneratedColumn<bool> inclusive = GeneratedColumn<bool>(
    'inclusive',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("inclusive" IN (0, 1))',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<QuestStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(QuestStatus.open.value),
      ).withConverter<QuestStatus>($QuestsTable.$converterstatus);
  static const VerificationMeta _creatorPublicIdMeta = const VerificationMeta(
    'creatorPublicId',
  );
  @override
  late final GeneratedColumn<String> creatorPublicId = GeneratedColumn<String>(
    'creator_public_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (public_id)',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _acceptedByPublicIdMeta =
      const VerificationMeta('acceptedByPublicId');
  @override
  late final GeneratedColumn<String> acceptedByPublicId =
      GeneratedColumn<String>(
        'accepted_by_public_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES users (public_id)',
        ),
      );
  static const VerificationMeta _automaticRewardMeta = const VerificationMeta(
    'automaticReward',
  );
  @override
  late final GeneratedColumn<bool> automaticReward = GeneratedColumn<bool>(
    'automatic_reward',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("automatic_reward" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    groupId,
    publicId,
    name,
    description,
    deadline,
    startTime,
    data,
    address,
    rewardType,
    rewardValue,
    inclusive,
    status,
    creatorPublicId,
    createdAt,
    updatedAt,
    acceptedByPublicId,
    automaticReward,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quests';
  @override
  VerificationContext validateIntegrity(
    Insertable<Quest> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('public_id')) {
      context.handle(
        _publicIdMeta,
        publicId.isAcceptableOrUnknown(data['public_id']!, _publicIdMeta),
      );
    } else if (isInserting) {
      context.missing(_publicIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('deadline')) {
      context.handle(
        _deadlineMeta,
        deadline.isAcceptableOrUnknown(data['deadline']!, _deadlineMeta),
      );
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('reward_value')) {
      context.handle(
        _rewardValueMeta,
        rewardValue.isAcceptableOrUnknown(
          data['reward_value']!,
          _rewardValueMeta,
        ),
      );
    }
    if (data.containsKey('inclusive')) {
      context.handle(
        _inclusiveMeta,
        inclusive.isAcceptableOrUnknown(data['inclusive']!, _inclusiveMeta),
      );
    } else if (isInserting) {
      context.missing(_inclusiveMeta);
    }
    if (data.containsKey('creator_public_id')) {
      context.handle(
        _creatorPublicIdMeta,
        creatorPublicId.isAcceptableOrUnknown(
          data['creator_public_id']!,
          _creatorPublicIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_creatorPublicIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('accepted_by_public_id')) {
      context.handle(
        _acceptedByPublicIdMeta,
        acceptedByPublicId.isAcceptableOrUnknown(
          data['accepted_by_public_id']!,
          _acceptedByPublicIdMeta,
        ),
      );
    }
    if (data.containsKey('automatic_reward')) {
      context.handle(
        _automaticRewardMeta,
        automaticReward.isAcceptableOrUnknown(
          data['automatic_reward']!,
          _automaticRewardMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {publicId},
  ];
  @override
  Quest map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Quest(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}group_id'],
      )!,
      publicId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}public_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      deadline: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deadline'],
      ),
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_time'],
      ),
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      rewardType: $QuestsTable.$converterrewardType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}reward_type'],
        )!,
      ),
      rewardValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reward_value'],
      ),
      inclusive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}inclusive'],
      )!,
      status: $QuestsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      creatorPublicId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}creator_public_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      acceptedByPublicId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}accepted_by_public_id'],
      ),
      automaticReward: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}automatic_reward'],
      )!,
    );
  }

  @override
  $QuestsTable createAlias(String alias) {
    return $QuestsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<RewardType, String, String> $converterrewardType =
      const EnumNameConverter<RewardType>(RewardType.values);
  static JsonTypeConverter2<QuestStatus, String, String> $converterstatus =
      const EnumNameConverter<QuestStatus>(QuestStatus.values);
}

class Quest extends DataClass implements Insertable<Quest> {
  final int id;
  final int groupId;
  final String publicId;
  final String name;
  final String? description;
  final DateTime? deadline;
  final DateTime? startTime;
  final String? data;
  final String? address;
  final RewardType rewardType;
  final String? rewardValue;
  final bool inclusive;
  final QuestStatus status;
  final String creatorPublicId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? acceptedByPublicId;
  final bool automaticReward;
  const Quest({
    required this.id,
    required this.groupId,
    required this.publicId,
    required this.name,
    this.description,
    this.deadline,
    this.startTime,
    this.data,
    this.address,
    required this.rewardType,
    this.rewardValue,
    required this.inclusive,
    required this.status,
    required this.creatorPublicId,
    required this.createdAt,
    required this.updatedAt,
    this.acceptedByPublicId,
    required this.automaticReward,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['group_id'] = Variable<int>(groupId);
    map['public_id'] = Variable<String>(publicId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || deadline != null) {
      map['deadline'] = Variable<DateTime>(deadline);
    }
    if (!nullToAbsent || startTime != null) {
      map['start_time'] = Variable<DateTime>(startTime);
    }
    if (!nullToAbsent || data != null) {
      map['data'] = Variable<String>(data);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    {
      map['reward_type'] = Variable<String>(
        $QuestsTable.$converterrewardType.toSql(rewardType),
      );
    }
    if (!nullToAbsent || rewardValue != null) {
      map['reward_value'] = Variable<String>(rewardValue);
    }
    map['inclusive'] = Variable<bool>(inclusive);
    {
      map['status'] = Variable<String>(
        $QuestsTable.$converterstatus.toSql(status),
      );
    }
    map['creator_public_id'] = Variable<String>(creatorPublicId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || acceptedByPublicId != null) {
      map['accepted_by_public_id'] = Variable<String>(acceptedByPublicId);
    }
    map['automatic_reward'] = Variable<bool>(automaticReward);
    return map;
  }

  QuestsCompanion toCompanion(bool nullToAbsent) {
    return QuestsCompanion(
      id: Value(id),
      groupId: Value(groupId),
      publicId: Value(publicId),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      deadline: deadline == null && nullToAbsent
          ? const Value.absent()
          : Value(deadline),
      startTime: startTime == null && nullToAbsent
          ? const Value.absent()
          : Value(startTime),
      data: data == null && nullToAbsent ? const Value.absent() : Value(data),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      rewardType: Value(rewardType),
      rewardValue: rewardValue == null && nullToAbsent
          ? const Value.absent()
          : Value(rewardValue),
      inclusive: Value(inclusive),
      status: Value(status),
      creatorPublicId: Value(creatorPublicId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      acceptedByPublicId: acceptedByPublicId == null && nullToAbsent
          ? const Value.absent()
          : Value(acceptedByPublicId),
      automaticReward: Value(automaticReward),
    );
  }

  factory Quest.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Quest(
      id: serializer.fromJson<int>(json['id']),
      groupId: serializer.fromJson<int>(json['groupId']),
      publicId: serializer.fromJson<String>(json['publicId']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      deadline: serializer.fromJson<DateTime?>(json['deadline']),
      startTime: serializer.fromJson<DateTime?>(json['startTime']),
      data: serializer.fromJson<String?>(json['data']),
      address: serializer.fromJson<String?>(json['address']),
      rewardType: $QuestsTable.$converterrewardType.fromJson(
        serializer.fromJson<String>(json['rewardType']),
      ),
      rewardValue: serializer.fromJson<String?>(json['rewardValue']),
      inclusive: serializer.fromJson<bool>(json['inclusive']),
      status: $QuestsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      creatorPublicId: serializer.fromJson<String>(json['creatorPublicId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      acceptedByPublicId: serializer.fromJson<String?>(
        json['acceptedByPublicId'],
      ),
      automaticReward: serializer.fromJson<bool>(json['automaticReward']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'groupId': serializer.toJson<int>(groupId),
      'publicId': serializer.toJson<String>(publicId),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'deadline': serializer.toJson<DateTime?>(deadline),
      'startTime': serializer.toJson<DateTime?>(startTime),
      'data': serializer.toJson<String?>(data),
      'address': serializer.toJson<String?>(address),
      'rewardType': serializer.toJson<String>(
        $QuestsTable.$converterrewardType.toJson(rewardType),
      ),
      'rewardValue': serializer.toJson<String?>(rewardValue),
      'inclusive': serializer.toJson<bool>(inclusive),
      'status': serializer.toJson<String>(
        $QuestsTable.$converterstatus.toJson(status),
      ),
      'creatorPublicId': serializer.toJson<String>(creatorPublicId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'acceptedByPublicId': serializer.toJson<String?>(acceptedByPublicId),
      'automaticReward': serializer.toJson<bool>(automaticReward),
    };
  }

  Quest copyWith({
    int? id,
    int? groupId,
    String? publicId,
    String? name,
    Value<String?> description = const Value.absent(),
    Value<DateTime?> deadline = const Value.absent(),
    Value<DateTime?> startTime = const Value.absent(),
    Value<String?> data = const Value.absent(),
    Value<String?> address = const Value.absent(),
    RewardType? rewardType,
    Value<String?> rewardValue = const Value.absent(),
    bool? inclusive,
    QuestStatus? status,
    String? creatorPublicId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<String?> acceptedByPublicId = const Value.absent(),
    bool? automaticReward,
  }) => Quest(
    id: id ?? this.id,
    groupId: groupId ?? this.groupId,
    publicId: publicId ?? this.publicId,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    deadline: deadline.present ? deadline.value : this.deadline,
    startTime: startTime.present ? startTime.value : this.startTime,
    data: data.present ? data.value : this.data,
    address: address.present ? address.value : this.address,
    rewardType: rewardType ?? this.rewardType,
    rewardValue: rewardValue.present ? rewardValue.value : this.rewardValue,
    inclusive: inclusive ?? this.inclusive,
    status: status ?? this.status,
    creatorPublicId: creatorPublicId ?? this.creatorPublicId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    acceptedByPublicId: acceptedByPublicId.present
        ? acceptedByPublicId.value
        : this.acceptedByPublicId,
    automaticReward: automaticReward ?? this.automaticReward,
  );
  Quest copyWithCompanion(QuestsCompanion data) {
    return Quest(
      id: data.id.present ? data.id.value : this.id,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      publicId: data.publicId.present ? data.publicId.value : this.publicId,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      deadline: data.deadline.present ? data.deadline.value : this.deadline,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      data: data.data.present ? data.data.value : this.data,
      address: data.address.present ? data.address.value : this.address,
      rewardType: data.rewardType.present
          ? data.rewardType.value
          : this.rewardType,
      rewardValue: data.rewardValue.present
          ? data.rewardValue.value
          : this.rewardValue,
      inclusive: data.inclusive.present ? data.inclusive.value : this.inclusive,
      status: data.status.present ? data.status.value : this.status,
      creatorPublicId: data.creatorPublicId.present
          ? data.creatorPublicId.value
          : this.creatorPublicId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      acceptedByPublicId: data.acceptedByPublicId.present
          ? data.acceptedByPublicId.value
          : this.acceptedByPublicId,
      automaticReward: data.automaticReward.present
          ? data.automaticReward.value
          : this.automaticReward,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Quest(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('publicId: $publicId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('deadline: $deadline, ')
          ..write('startTime: $startTime, ')
          ..write('data: $data, ')
          ..write('address: $address, ')
          ..write('rewardType: $rewardType, ')
          ..write('rewardValue: $rewardValue, ')
          ..write('inclusive: $inclusive, ')
          ..write('status: $status, ')
          ..write('creatorPublicId: $creatorPublicId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('acceptedByPublicId: $acceptedByPublicId, ')
          ..write('automaticReward: $automaticReward')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    groupId,
    publicId,
    name,
    description,
    deadline,
    startTime,
    data,
    address,
    rewardType,
    rewardValue,
    inclusive,
    status,
    creatorPublicId,
    createdAt,
    updatedAt,
    acceptedByPublicId,
    automaticReward,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Quest &&
          other.id == this.id &&
          other.groupId == this.groupId &&
          other.publicId == this.publicId &&
          other.name == this.name &&
          other.description == this.description &&
          other.deadline == this.deadline &&
          other.startTime == this.startTime &&
          other.data == this.data &&
          other.address == this.address &&
          other.rewardType == this.rewardType &&
          other.rewardValue == this.rewardValue &&
          other.inclusive == this.inclusive &&
          other.status == this.status &&
          other.creatorPublicId == this.creatorPublicId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.acceptedByPublicId == this.acceptedByPublicId &&
          other.automaticReward == this.automaticReward);
}

class QuestsCompanion extends UpdateCompanion<Quest> {
  final Value<int> id;
  final Value<int> groupId;
  final Value<String> publicId;
  final Value<String> name;
  final Value<String?> description;
  final Value<DateTime?> deadline;
  final Value<DateTime?> startTime;
  final Value<String?> data;
  final Value<String?> address;
  final Value<RewardType> rewardType;
  final Value<String?> rewardValue;
  final Value<bool> inclusive;
  final Value<QuestStatus> status;
  final Value<String> creatorPublicId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String?> acceptedByPublicId;
  final Value<bool> automaticReward;
  const QuestsCompanion({
    this.id = const Value.absent(),
    this.groupId = const Value.absent(),
    this.publicId = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.deadline = const Value.absent(),
    this.startTime = const Value.absent(),
    this.data = const Value.absent(),
    this.address = const Value.absent(),
    this.rewardType = const Value.absent(),
    this.rewardValue = const Value.absent(),
    this.inclusive = const Value.absent(),
    this.status = const Value.absent(),
    this.creatorPublicId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.acceptedByPublicId = const Value.absent(),
    this.automaticReward = const Value.absent(),
  });
  QuestsCompanion.insert({
    this.id = const Value.absent(),
    required int groupId,
    required String publicId,
    required String name,
    this.description = const Value.absent(),
    this.deadline = const Value.absent(),
    this.startTime = const Value.absent(),
    this.data = const Value.absent(),
    this.address = const Value.absent(),
    this.rewardType = const Value.absent(),
    this.rewardValue = const Value.absent(),
    required bool inclusive,
    this.status = const Value.absent(),
    required String creatorPublicId,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.acceptedByPublicId = const Value.absent(),
    this.automaticReward = const Value.absent(),
  }) : groupId = Value(groupId),
       publicId = Value(publicId),
       name = Value(name),
       inclusive = Value(inclusive),
       creatorPublicId = Value(creatorPublicId);
  static Insertable<Quest> custom({
    Expression<int>? id,
    Expression<int>? groupId,
    Expression<String>? publicId,
    Expression<String>? name,
    Expression<String>? description,
    Expression<DateTime>? deadline,
    Expression<DateTime>? startTime,
    Expression<String>? data,
    Expression<String>? address,
    Expression<String>? rewardType,
    Expression<String>? rewardValue,
    Expression<bool>? inclusive,
    Expression<String>? status,
    Expression<String>? creatorPublicId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? acceptedByPublicId,
    Expression<bool>? automaticReward,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (groupId != null) 'group_id': groupId,
      if (publicId != null) 'public_id': publicId,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (deadline != null) 'deadline': deadline,
      if (startTime != null) 'start_time': startTime,
      if (data != null) 'data': data,
      if (address != null) 'address': address,
      if (rewardType != null) 'reward_type': rewardType,
      if (rewardValue != null) 'reward_value': rewardValue,
      if (inclusive != null) 'inclusive': inclusive,
      if (status != null) 'status': status,
      if (creatorPublicId != null) 'creator_public_id': creatorPublicId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (acceptedByPublicId != null)
        'accepted_by_public_id': acceptedByPublicId,
      if (automaticReward != null) 'automatic_reward': automaticReward,
    });
  }

  QuestsCompanion copyWith({
    Value<int>? id,
    Value<int>? groupId,
    Value<String>? publicId,
    Value<String>? name,
    Value<String?>? description,
    Value<DateTime?>? deadline,
    Value<DateTime?>? startTime,
    Value<String?>? data,
    Value<String?>? address,
    Value<RewardType>? rewardType,
    Value<String?>? rewardValue,
    Value<bool>? inclusive,
    Value<QuestStatus>? status,
    Value<String>? creatorPublicId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String?>? acceptedByPublicId,
    Value<bool>? automaticReward,
  }) {
    return QuestsCompanion(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      publicId: publicId ?? this.publicId,
      name: name ?? this.name,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      startTime: startTime ?? this.startTime,
      data: data ?? this.data,
      address: address ?? this.address,
      rewardType: rewardType ?? this.rewardType,
      rewardValue: rewardValue ?? this.rewardValue,
      inclusive: inclusive ?? this.inclusive,
      status: status ?? this.status,
      creatorPublicId: creatorPublicId ?? this.creatorPublicId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      acceptedByPublicId: acceptedByPublicId ?? this.acceptedByPublicId,
      automaticReward: automaticReward ?? this.automaticReward,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<int>(groupId.value);
    }
    if (publicId.present) {
      map['public_id'] = Variable<String>(publicId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (deadline.present) {
      map['deadline'] = Variable<DateTime>(deadline.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<DateTime>(startTime.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (rewardType.present) {
      map['reward_type'] = Variable<String>(
        $QuestsTable.$converterrewardType.toSql(rewardType.value),
      );
    }
    if (rewardValue.present) {
      map['reward_value'] = Variable<String>(rewardValue.value);
    }
    if (inclusive.present) {
      map['inclusive'] = Variable<bool>(inclusive.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $QuestsTable.$converterstatus.toSql(status.value),
      );
    }
    if (creatorPublicId.present) {
      map['creator_public_id'] = Variable<String>(creatorPublicId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (acceptedByPublicId.present) {
      map['accepted_by_public_id'] = Variable<String>(acceptedByPublicId.value);
    }
    if (automaticReward.present) {
      map['automatic_reward'] = Variable<bool>(automaticReward.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuestsCompanion(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('publicId: $publicId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('deadline: $deadline, ')
          ..write('startTime: $startTime, ')
          ..write('data: $data, ')
          ..write('address: $address, ')
          ..write('rewardType: $rewardType, ')
          ..write('rewardValue: $rewardValue, ')
          ..write('inclusive: $inclusive, ')
          ..write('status: $status, ')
          ..write('creatorPublicId: $creatorPublicId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('acceptedByPublicId: $acceptedByPublicId, ')
          ..write('automaticReward: $automaticReward')
          ..write(')'))
        .toString();
  }
}

class $QuestTemplatesTable extends QuestTemplates
    with TableInfo<$QuestTemplatesTable, QuestTemplate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuestTemplatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<RewardType, String> rewardType =
      GeneratedColumn<String>(
        'reward_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(RewardType.none.value),
      ).withConverter<RewardType>($QuestTemplatesTable.$converterrewardType);
  static const VerificationMeta _rewardValueMeta = const VerificationMeta(
    'rewardValue',
  );
  @override
  late final GeneratedColumn<String> rewardValue = GeneratedColumn<String>(
    'reward_value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _inclusiveMeta = const VerificationMeta(
    'inclusive',
  );
  @override
  late final GeneratedColumn<bool> inclusive = GeneratedColumn<bool>(
    'inclusive',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("inclusive" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDelayedStartMeta = const VerificationMeta(
    'isDelayedStart',
  );
  @override
  late final GeneratedColumn<bool> isDelayedStart = GeneratedColumn<bool>(
    'is_delayed_start',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_delayed_start" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _deadlineOffsetDaysMeta =
      const VerificationMeta('deadlineOffsetDays');
  @override
  late final GeneratedColumn<int> deadlineOffsetDays = GeneratedColumn<int>(
    'deadline_offset_days',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deadlineHourMeta = const VerificationMeta(
    'deadlineHour',
  );
  @override
  late final GeneratedColumn<int> deadlineHour = GeneratedColumn<int>(
    'deadline_hour',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deadlineMinuteMeta = const VerificationMeta(
    'deadlineMinute',
  );
  @override
  late final GeneratedColumn<int> deadlineMinute = GeneratedColumn<int>(
    'deadline_minute',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startTimeOffsetDaysMeta =
      const VerificationMeta('startTimeOffsetDays');
  @override
  late final GeneratedColumn<int> startTimeOffsetDays = GeneratedColumn<int>(
    'start_time_offset_days',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startTimeHourMeta = const VerificationMeta(
    'startTimeHour',
  );
  @override
  late final GeneratedColumn<int> startTimeHour = GeneratedColumn<int>(
    'start_time_hour',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startTimeMinuteMeta = const VerificationMeta(
    'startTimeMinute',
  );
  @override
  late final GeneratedColumn<int> startTimeMinute = GeneratedColumn<int>(
    'start_time_minute',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _automaticRewardMeta = const VerificationMeta(
    'automaticReward',
  );
  @override
  late final GeneratedColumn<bool> automaticReward = GeneratedColumn<bool>(
    'automatic_reward',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("automatic_reward" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _savedAtMeta = const VerificationMeta(
    'savedAt',
  );
  @override
  late final GeneratedColumn<DateTime> savedAt = GeneratedColumn<DateTime>(
    'saved_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    address,
    rewardType,
    rewardValue,
    inclusive,
    isDelayedStart,
    deadlineOffsetDays,
    deadlineHour,
    deadlineMinute,
    startTimeOffsetDays,
    startTimeHour,
    startTimeMinute,
    automaticReward,
    savedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quest_templates';
  @override
  VerificationContext validateIntegrity(
    Insertable<QuestTemplate> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('reward_value')) {
      context.handle(
        _rewardValueMeta,
        rewardValue.isAcceptableOrUnknown(
          data['reward_value']!,
          _rewardValueMeta,
        ),
      );
    }
    if (data.containsKey('inclusive')) {
      context.handle(
        _inclusiveMeta,
        inclusive.isAcceptableOrUnknown(data['inclusive']!, _inclusiveMeta),
      );
    }
    if (data.containsKey('is_delayed_start')) {
      context.handle(
        _isDelayedStartMeta,
        isDelayedStart.isAcceptableOrUnknown(
          data['is_delayed_start']!,
          _isDelayedStartMeta,
        ),
      );
    }
    if (data.containsKey('deadline_offset_days')) {
      context.handle(
        _deadlineOffsetDaysMeta,
        deadlineOffsetDays.isAcceptableOrUnknown(
          data['deadline_offset_days']!,
          _deadlineOffsetDaysMeta,
        ),
      );
    }
    if (data.containsKey('deadline_hour')) {
      context.handle(
        _deadlineHourMeta,
        deadlineHour.isAcceptableOrUnknown(
          data['deadline_hour']!,
          _deadlineHourMeta,
        ),
      );
    }
    if (data.containsKey('deadline_minute')) {
      context.handle(
        _deadlineMinuteMeta,
        deadlineMinute.isAcceptableOrUnknown(
          data['deadline_minute']!,
          _deadlineMinuteMeta,
        ),
      );
    }
    if (data.containsKey('start_time_offset_days')) {
      context.handle(
        _startTimeOffsetDaysMeta,
        startTimeOffsetDays.isAcceptableOrUnknown(
          data['start_time_offset_days']!,
          _startTimeOffsetDaysMeta,
        ),
      );
    }
    if (data.containsKey('start_time_hour')) {
      context.handle(
        _startTimeHourMeta,
        startTimeHour.isAcceptableOrUnknown(
          data['start_time_hour']!,
          _startTimeHourMeta,
        ),
      );
    }
    if (data.containsKey('start_time_minute')) {
      context.handle(
        _startTimeMinuteMeta,
        startTimeMinute.isAcceptableOrUnknown(
          data['start_time_minute']!,
          _startTimeMinuteMeta,
        ),
      );
    }
    if (data.containsKey('automatic_reward')) {
      context.handle(
        _automaticRewardMeta,
        automaticReward.isAcceptableOrUnknown(
          data['automatic_reward']!,
          _automaticRewardMeta,
        ),
      );
    }
    if (data.containsKey('saved_at')) {
      context.handle(
        _savedAtMeta,
        savedAt.isAcceptableOrUnknown(data['saved_at']!, _savedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QuestTemplate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuestTemplate(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      rewardType: $QuestTemplatesTable.$converterrewardType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}reward_type'],
        )!,
      ),
      rewardValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reward_value'],
      ),
      inclusive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}inclusive'],
      )!,
      isDelayedStart: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_delayed_start'],
      )!,
      deadlineOffsetDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deadline_offset_days'],
      ),
      deadlineHour: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deadline_hour'],
      ),
      deadlineMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deadline_minute'],
      ),
      startTimeOffsetDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_time_offset_days'],
      ),
      startTimeHour: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_time_hour'],
      ),
      startTimeMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_time_minute'],
      ),
      automaticReward: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}automatic_reward'],
      )!,
      savedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}saved_at'],
      )!,
    );
  }

  @override
  $QuestTemplatesTable createAlias(String alias) {
    return $QuestTemplatesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<RewardType, String, String> $converterrewardType =
      const EnumNameConverter<RewardType>(RewardType.values);
}

class QuestTemplate extends DataClass implements Insertable<QuestTemplate> {
  final int id;
  final String name;
  final String? description;
  final String? address;
  final RewardType rewardType;
  final String? rewardValue;
  final bool inclusive;
  final bool isDelayedStart;
  final int? deadlineOffsetDays;
  final int? deadlineHour;
  final int? deadlineMinute;
  final int? startTimeOffsetDays;
  final int? startTimeHour;
  final int? startTimeMinute;
  final bool automaticReward;
  final DateTime savedAt;
  const QuestTemplate({
    required this.id,
    required this.name,
    this.description,
    this.address,
    required this.rewardType,
    this.rewardValue,
    required this.inclusive,
    required this.isDelayedStart,
    this.deadlineOffsetDays,
    this.deadlineHour,
    this.deadlineMinute,
    this.startTimeOffsetDays,
    this.startTimeHour,
    this.startTimeMinute,
    required this.automaticReward,
    required this.savedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    {
      map['reward_type'] = Variable<String>(
        $QuestTemplatesTable.$converterrewardType.toSql(rewardType),
      );
    }
    if (!nullToAbsent || rewardValue != null) {
      map['reward_value'] = Variable<String>(rewardValue);
    }
    map['inclusive'] = Variable<bool>(inclusive);
    map['is_delayed_start'] = Variable<bool>(isDelayedStart);
    if (!nullToAbsent || deadlineOffsetDays != null) {
      map['deadline_offset_days'] = Variable<int>(deadlineOffsetDays);
    }
    if (!nullToAbsent || deadlineHour != null) {
      map['deadline_hour'] = Variable<int>(deadlineHour);
    }
    if (!nullToAbsent || deadlineMinute != null) {
      map['deadline_minute'] = Variable<int>(deadlineMinute);
    }
    if (!nullToAbsent || startTimeOffsetDays != null) {
      map['start_time_offset_days'] = Variable<int>(startTimeOffsetDays);
    }
    if (!nullToAbsent || startTimeHour != null) {
      map['start_time_hour'] = Variable<int>(startTimeHour);
    }
    if (!nullToAbsent || startTimeMinute != null) {
      map['start_time_minute'] = Variable<int>(startTimeMinute);
    }
    map['automatic_reward'] = Variable<bool>(automaticReward);
    map['saved_at'] = Variable<DateTime>(savedAt);
    return map;
  }

  QuestTemplatesCompanion toCompanion(bool nullToAbsent) {
    return QuestTemplatesCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      rewardType: Value(rewardType),
      rewardValue: rewardValue == null && nullToAbsent
          ? const Value.absent()
          : Value(rewardValue),
      inclusive: Value(inclusive),
      isDelayedStart: Value(isDelayedStart),
      deadlineOffsetDays: deadlineOffsetDays == null && nullToAbsent
          ? const Value.absent()
          : Value(deadlineOffsetDays),
      deadlineHour: deadlineHour == null && nullToAbsent
          ? const Value.absent()
          : Value(deadlineHour),
      deadlineMinute: deadlineMinute == null && nullToAbsent
          ? const Value.absent()
          : Value(deadlineMinute),
      startTimeOffsetDays: startTimeOffsetDays == null && nullToAbsent
          ? const Value.absent()
          : Value(startTimeOffsetDays),
      startTimeHour: startTimeHour == null && nullToAbsent
          ? const Value.absent()
          : Value(startTimeHour),
      startTimeMinute: startTimeMinute == null && nullToAbsent
          ? const Value.absent()
          : Value(startTimeMinute),
      automaticReward: Value(automaticReward),
      savedAt: Value(savedAt),
    );
  }

  factory QuestTemplate.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuestTemplate(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      address: serializer.fromJson<String?>(json['address']),
      rewardType: $QuestTemplatesTable.$converterrewardType.fromJson(
        serializer.fromJson<String>(json['rewardType']),
      ),
      rewardValue: serializer.fromJson<String?>(json['rewardValue']),
      inclusive: serializer.fromJson<bool>(json['inclusive']),
      isDelayedStart: serializer.fromJson<bool>(json['isDelayedStart']),
      deadlineOffsetDays: serializer.fromJson<int?>(json['deadlineOffsetDays']),
      deadlineHour: serializer.fromJson<int?>(json['deadlineHour']),
      deadlineMinute: serializer.fromJson<int?>(json['deadlineMinute']),
      startTimeOffsetDays: serializer.fromJson<int?>(
        json['startTimeOffsetDays'],
      ),
      startTimeHour: serializer.fromJson<int?>(json['startTimeHour']),
      startTimeMinute: serializer.fromJson<int?>(json['startTimeMinute']),
      automaticReward: serializer.fromJson<bool>(json['automaticReward']),
      savedAt: serializer.fromJson<DateTime>(json['savedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'address': serializer.toJson<String?>(address),
      'rewardType': serializer.toJson<String>(
        $QuestTemplatesTable.$converterrewardType.toJson(rewardType),
      ),
      'rewardValue': serializer.toJson<String?>(rewardValue),
      'inclusive': serializer.toJson<bool>(inclusive),
      'isDelayedStart': serializer.toJson<bool>(isDelayedStart),
      'deadlineOffsetDays': serializer.toJson<int?>(deadlineOffsetDays),
      'deadlineHour': serializer.toJson<int?>(deadlineHour),
      'deadlineMinute': serializer.toJson<int?>(deadlineMinute),
      'startTimeOffsetDays': serializer.toJson<int?>(startTimeOffsetDays),
      'startTimeHour': serializer.toJson<int?>(startTimeHour),
      'startTimeMinute': serializer.toJson<int?>(startTimeMinute),
      'automaticReward': serializer.toJson<bool>(automaticReward),
      'savedAt': serializer.toJson<DateTime>(savedAt),
    };
  }

  QuestTemplate copyWith({
    int? id,
    String? name,
    Value<String?> description = const Value.absent(),
    Value<String?> address = const Value.absent(),
    RewardType? rewardType,
    Value<String?> rewardValue = const Value.absent(),
    bool? inclusive,
    bool? isDelayedStart,
    Value<int?> deadlineOffsetDays = const Value.absent(),
    Value<int?> deadlineHour = const Value.absent(),
    Value<int?> deadlineMinute = const Value.absent(),
    Value<int?> startTimeOffsetDays = const Value.absent(),
    Value<int?> startTimeHour = const Value.absent(),
    Value<int?> startTimeMinute = const Value.absent(),
    bool? automaticReward,
    DateTime? savedAt,
  }) => QuestTemplate(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    address: address.present ? address.value : this.address,
    rewardType: rewardType ?? this.rewardType,
    rewardValue: rewardValue.present ? rewardValue.value : this.rewardValue,
    inclusive: inclusive ?? this.inclusive,
    isDelayedStart: isDelayedStart ?? this.isDelayedStart,
    deadlineOffsetDays: deadlineOffsetDays.present
        ? deadlineOffsetDays.value
        : this.deadlineOffsetDays,
    deadlineHour: deadlineHour.present ? deadlineHour.value : this.deadlineHour,
    deadlineMinute: deadlineMinute.present
        ? deadlineMinute.value
        : this.deadlineMinute,
    startTimeOffsetDays: startTimeOffsetDays.present
        ? startTimeOffsetDays.value
        : this.startTimeOffsetDays,
    startTimeHour: startTimeHour.present
        ? startTimeHour.value
        : this.startTimeHour,
    startTimeMinute: startTimeMinute.present
        ? startTimeMinute.value
        : this.startTimeMinute,
    automaticReward: automaticReward ?? this.automaticReward,
    savedAt: savedAt ?? this.savedAt,
  );
  QuestTemplate copyWithCompanion(QuestTemplatesCompanion data) {
    return QuestTemplate(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      address: data.address.present ? data.address.value : this.address,
      rewardType: data.rewardType.present
          ? data.rewardType.value
          : this.rewardType,
      rewardValue: data.rewardValue.present
          ? data.rewardValue.value
          : this.rewardValue,
      inclusive: data.inclusive.present ? data.inclusive.value : this.inclusive,
      isDelayedStart: data.isDelayedStart.present
          ? data.isDelayedStart.value
          : this.isDelayedStart,
      deadlineOffsetDays: data.deadlineOffsetDays.present
          ? data.deadlineOffsetDays.value
          : this.deadlineOffsetDays,
      deadlineHour: data.deadlineHour.present
          ? data.deadlineHour.value
          : this.deadlineHour,
      deadlineMinute: data.deadlineMinute.present
          ? data.deadlineMinute.value
          : this.deadlineMinute,
      startTimeOffsetDays: data.startTimeOffsetDays.present
          ? data.startTimeOffsetDays.value
          : this.startTimeOffsetDays,
      startTimeHour: data.startTimeHour.present
          ? data.startTimeHour.value
          : this.startTimeHour,
      startTimeMinute: data.startTimeMinute.present
          ? data.startTimeMinute.value
          : this.startTimeMinute,
      automaticReward: data.automaticReward.present
          ? data.automaticReward.value
          : this.automaticReward,
      savedAt: data.savedAt.present ? data.savedAt.value : this.savedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuestTemplate(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('address: $address, ')
          ..write('rewardType: $rewardType, ')
          ..write('rewardValue: $rewardValue, ')
          ..write('inclusive: $inclusive, ')
          ..write('isDelayedStart: $isDelayedStart, ')
          ..write('deadlineOffsetDays: $deadlineOffsetDays, ')
          ..write('deadlineHour: $deadlineHour, ')
          ..write('deadlineMinute: $deadlineMinute, ')
          ..write('startTimeOffsetDays: $startTimeOffsetDays, ')
          ..write('startTimeHour: $startTimeHour, ')
          ..write('startTimeMinute: $startTimeMinute, ')
          ..write('automaticReward: $automaticReward, ')
          ..write('savedAt: $savedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    description,
    address,
    rewardType,
    rewardValue,
    inclusive,
    isDelayedStart,
    deadlineOffsetDays,
    deadlineHour,
    deadlineMinute,
    startTimeOffsetDays,
    startTimeHour,
    startTimeMinute,
    automaticReward,
    savedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuestTemplate &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.address == this.address &&
          other.rewardType == this.rewardType &&
          other.rewardValue == this.rewardValue &&
          other.inclusive == this.inclusive &&
          other.isDelayedStart == this.isDelayedStart &&
          other.deadlineOffsetDays == this.deadlineOffsetDays &&
          other.deadlineHour == this.deadlineHour &&
          other.deadlineMinute == this.deadlineMinute &&
          other.startTimeOffsetDays == this.startTimeOffsetDays &&
          other.startTimeHour == this.startTimeHour &&
          other.startTimeMinute == this.startTimeMinute &&
          other.automaticReward == this.automaticReward &&
          other.savedAt == this.savedAt);
}

class QuestTemplatesCompanion extends UpdateCompanion<QuestTemplate> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<String?> address;
  final Value<RewardType> rewardType;
  final Value<String?> rewardValue;
  final Value<bool> inclusive;
  final Value<bool> isDelayedStart;
  final Value<int?> deadlineOffsetDays;
  final Value<int?> deadlineHour;
  final Value<int?> deadlineMinute;
  final Value<int?> startTimeOffsetDays;
  final Value<int?> startTimeHour;
  final Value<int?> startTimeMinute;
  final Value<bool> automaticReward;
  final Value<DateTime> savedAt;
  const QuestTemplatesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.address = const Value.absent(),
    this.rewardType = const Value.absent(),
    this.rewardValue = const Value.absent(),
    this.inclusive = const Value.absent(),
    this.isDelayedStart = const Value.absent(),
    this.deadlineOffsetDays = const Value.absent(),
    this.deadlineHour = const Value.absent(),
    this.deadlineMinute = const Value.absent(),
    this.startTimeOffsetDays = const Value.absent(),
    this.startTimeHour = const Value.absent(),
    this.startTimeMinute = const Value.absent(),
    this.automaticReward = const Value.absent(),
    this.savedAt = const Value.absent(),
  });
  QuestTemplatesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.description = const Value.absent(),
    this.address = const Value.absent(),
    this.rewardType = const Value.absent(),
    this.rewardValue = const Value.absent(),
    this.inclusive = const Value.absent(),
    this.isDelayedStart = const Value.absent(),
    this.deadlineOffsetDays = const Value.absent(),
    this.deadlineHour = const Value.absent(),
    this.deadlineMinute = const Value.absent(),
    this.startTimeOffsetDays = const Value.absent(),
    this.startTimeHour = const Value.absent(),
    this.startTimeMinute = const Value.absent(),
    this.automaticReward = const Value.absent(),
    this.savedAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<QuestTemplate> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? address,
    Expression<String>? rewardType,
    Expression<String>? rewardValue,
    Expression<bool>? inclusive,
    Expression<bool>? isDelayedStart,
    Expression<int>? deadlineOffsetDays,
    Expression<int>? deadlineHour,
    Expression<int>? deadlineMinute,
    Expression<int>? startTimeOffsetDays,
    Expression<int>? startTimeHour,
    Expression<int>? startTimeMinute,
    Expression<bool>? automaticReward,
    Expression<DateTime>? savedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (address != null) 'address': address,
      if (rewardType != null) 'reward_type': rewardType,
      if (rewardValue != null) 'reward_value': rewardValue,
      if (inclusive != null) 'inclusive': inclusive,
      if (isDelayedStart != null) 'is_delayed_start': isDelayedStart,
      if (deadlineOffsetDays != null)
        'deadline_offset_days': deadlineOffsetDays,
      if (deadlineHour != null) 'deadline_hour': deadlineHour,
      if (deadlineMinute != null) 'deadline_minute': deadlineMinute,
      if (startTimeOffsetDays != null)
        'start_time_offset_days': startTimeOffsetDays,
      if (startTimeHour != null) 'start_time_hour': startTimeHour,
      if (startTimeMinute != null) 'start_time_minute': startTimeMinute,
      if (automaticReward != null) 'automatic_reward': automaticReward,
      if (savedAt != null) 'saved_at': savedAt,
    });
  }

  QuestTemplatesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? description,
    Value<String?>? address,
    Value<RewardType>? rewardType,
    Value<String?>? rewardValue,
    Value<bool>? inclusive,
    Value<bool>? isDelayedStart,
    Value<int?>? deadlineOffsetDays,
    Value<int?>? deadlineHour,
    Value<int?>? deadlineMinute,
    Value<int?>? startTimeOffsetDays,
    Value<int?>? startTimeHour,
    Value<int?>? startTimeMinute,
    Value<bool>? automaticReward,
    Value<DateTime>? savedAt,
  }) {
    return QuestTemplatesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      rewardType: rewardType ?? this.rewardType,
      rewardValue: rewardValue ?? this.rewardValue,
      inclusive: inclusive ?? this.inclusive,
      isDelayedStart: isDelayedStart ?? this.isDelayedStart,
      deadlineOffsetDays: deadlineOffsetDays ?? this.deadlineOffsetDays,
      deadlineHour: deadlineHour ?? this.deadlineHour,
      deadlineMinute: deadlineMinute ?? this.deadlineMinute,
      startTimeOffsetDays: startTimeOffsetDays ?? this.startTimeOffsetDays,
      startTimeHour: startTimeHour ?? this.startTimeHour,
      startTimeMinute: startTimeMinute ?? this.startTimeMinute,
      automaticReward: automaticReward ?? this.automaticReward,
      savedAt: savedAt ?? this.savedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (rewardType.present) {
      map['reward_type'] = Variable<String>(
        $QuestTemplatesTable.$converterrewardType.toSql(rewardType.value),
      );
    }
    if (rewardValue.present) {
      map['reward_value'] = Variable<String>(rewardValue.value);
    }
    if (inclusive.present) {
      map['inclusive'] = Variable<bool>(inclusive.value);
    }
    if (isDelayedStart.present) {
      map['is_delayed_start'] = Variable<bool>(isDelayedStart.value);
    }
    if (deadlineOffsetDays.present) {
      map['deadline_offset_days'] = Variable<int>(deadlineOffsetDays.value);
    }
    if (deadlineHour.present) {
      map['deadline_hour'] = Variable<int>(deadlineHour.value);
    }
    if (deadlineMinute.present) {
      map['deadline_minute'] = Variable<int>(deadlineMinute.value);
    }
    if (startTimeOffsetDays.present) {
      map['start_time_offset_days'] = Variable<int>(startTimeOffsetDays.value);
    }
    if (startTimeHour.present) {
      map['start_time_hour'] = Variable<int>(startTimeHour.value);
    }
    if (startTimeMinute.present) {
      map['start_time_minute'] = Variable<int>(startTimeMinute.value);
    }
    if (automaticReward.present) {
      map['automatic_reward'] = Variable<bool>(automaticReward.value);
    }
    if (savedAt.present) {
      map['saved_at'] = Variable<DateTime>(savedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuestTemplatesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('address: $address, ')
          ..write('rewardType: $rewardType, ')
          ..write('rewardValue: $rewardValue, ')
          ..write('inclusive: $inclusive, ')
          ..write('isDelayedStart: $isDelayedStart, ')
          ..write('deadlineOffsetDays: $deadlineOffsetDays, ')
          ..write('deadlineHour: $deadlineHour, ')
          ..write('deadlineMinute: $deadlineMinute, ')
          ..write('startTimeOffsetDays: $startTimeOffsetDays, ')
          ..write('startTimeHour: $startTimeHour, ')
          ..write('startTimeMinute: $startTimeMinute, ')
          ..write('automaticReward: $automaticReward, ')
          ..write('savedAt: $savedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $GroupsTable groups = $GroupsTable(this);
  late final $UsersTable users = $UsersTable(this);
  late final $GroupMembersTable groupMembers = $GroupMembersTable(this);
  late final $QuestsTable quests = $QuestsTable(this);
  late final $QuestTemplatesTable questTemplates = $QuestTemplatesTable(this);
  late final Index groupMembersUserPublicIdIdx = Index(
    'group_members_user_public_id_idx',
    'CREATE INDEX group_members_user_public_id_idx ON group_members (user_public_id)',
  );
  late final Index groupMembersGroupIdPublicIdIdx = Index(
    'group_members_group_id_public_id_idx',
    'CREATE INDEX group_members_group_id_public_id_idx ON group_members (group_id, user_public_id)',
  );
  late final Index questsGroupStatusUpdatedIdx = Index(
    'quests_group_status_updated_idx',
    'CREATE INDEX quests_group_status_updated_idx ON quests (group_id, status, updated_at)',
  );
  late final Index questTemplatesNameIdx = Index(
    'quest_templates_name_idx',
    'CREATE INDEX quest_templates_name_idx ON quest_templates (name)',
  );
  late final GroupsDao groupsDao = GroupsDao(this as AppDatabase);
  late final GroupMembersDao groupMembersDao = GroupMembersDao(
    this as AppDatabase,
  );
  late final QuestsDao questsDao = QuestsDao(this as AppDatabase);
  late final UsersDao usersDao = UsersDao(this as AppDatabase);
  late final QuestTemplatesDao questTemplatesDao = QuestTemplatesDao(
    this as AppDatabase,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    groups,
    users,
    groupMembers,
    quests,
    questTemplates,
    groupMembersUserPublicIdIdx,
    groupMembersGroupIdPublicIdIdx,
    questsGroupStatusUpdatedIdx,
    questTemplatesNameIdx,
  ];
}

typedef $$GroupsTableCreateCompanionBuilder =
    GroupsCompanion Function({
      Value<int> id,
      required String publicId,
      required String name,
      Value<String> type,
      Value<String> visibility,
      required DateTime createdAt,
    });
typedef $$GroupsTableUpdateCompanionBuilder =
    GroupsCompanion Function({
      Value<int> id,
      Value<String> publicId,
      Value<String> name,
      Value<String> type,
      Value<String> visibility,
      Value<DateTime> createdAt,
    });

final class $$GroupsTableReferences
    extends BaseReferences<_$AppDatabase, $GroupsTable, Group> {
  $$GroupsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$GroupMembersTable, List<GroupMember>>
  _groupMembersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.groupMembers,
    aliasName: $_aliasNameGenerator(db.groups.id, db.groupMembers.groupId),
  );

  $$GroupMembersTableProcessedTableManager get groupMembersRefs {
    final manager = $$GroupMembersTableTableManager(
      $_db,
      $_db.groupMembers,
    ).filter((f) => f.groupId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_groupMembersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$QuestsTable, List<Quest>> _questsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.quests,
    aliasName: $_aliasNameGenerator(db.groups.id, db.quests.groupId),
  );

  $$QuestsTableProcessedTableManager get questsRefs {
    final manager = $$QuestsTableTableManager(
      $_db,
      $_db.quests,
    ).filter((f) => f.groupId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_questsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$GroupsTableFilterComposer
    extends Composer<_$AppDatabase, $GroupsTable> {
  $$GroupsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get publicId => $composableBuilder(
    column: $table.publicId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get visibility => $composableBuilder(
    column: $table.visibility,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> groupMembersRefs(
    Expression<bool> Function($$GroupMembersTableFilterComposer f) f,
  ) {
    final $$GroupMembersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.groupMembers,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupMembersTableFilterComposer(
            $db: $db,
            $table: $db.groupMembers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> questsRefs(
    Expression<bool> Function($$QuestsTableFilterComposer f) f,
  ) {
    final $$QuestsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.quests,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestsTableFilterComposer(
            $db: $db,
            $table: $db.quests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GroupsTableOrderingComposer
    extends Composer<_$AppDatabase, $GroupsTable> {
  $$GroupsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get publicId => $composableBuilder(
    column: $table.publicId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get visibility => $composableBuilder(
    column: $table.visibility,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GroupsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GroupsTable> {
  $$GroupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get publicId =>
      $composableBuilder(column: $table.publicId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get visibility => $composableBuilder(
    column: $table.visibility,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> groupMembersRefs<T extends Object>(
    Expression<T> Function($$GroupMembersTableAnnotationComposer a) f,
  ) {
    final $$GroupMembersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.groupMembers,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupMembersTableAnnotationComposer(
            $db: $db,
            $table: $db.groupMembers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> questsRefs<T extends Object>(
    Expression<T> Function($$QuestsTableAnnotationComposer a) f,
  ) {
    final $$QuestsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.quests,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestsTableAnnotationComposer(
            $db: $db,
            $table: $db.quests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GroupsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GroupsTable,
          Group,
          $$GroupsTableFilterComposer,
          $$GroupsTableOrderingComposer,
          $$GroupsTableAnnotationComposer,
          $$GroupsTableCreateCompanionBuilder,
          $$GroupsTableUpdateCompanionBuilder,
          (Group, $$GroupsTableReferences),
          Group,
          PrefetchHooks Function({bool groupMembersRefs, bool questsRefs})
        > {
  $$GroupsTableTableManager(_$AppDatabase db, $GroupsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GroupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GroupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> publicId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> visibility = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => GroupsCompanion(
                id: id,
                publicId: publicId,
                name: name,
                type: type,
                visibility: visibility,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String publicId,
                required String name,
                Value<String> type = const Value.absent(),
                Value<String> visibility = const Value.absent(),
                required DateTime createdAt,
              }) => GroupsCompanion.insert(
                id: id,
                publicId: publicId,
                name: name,
                type: type,
                visibility: visibility,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$GroupsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({groupMembersRefs = false, questsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (groupMembersRefs) db.groupMembers,
                    if (questsRefs) db.quests,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (groupMembersRefs)
                        await $_getPrefetchedData<
                          Group,
                          $GroupsTable,
                          GroupMember
                        >(
                          currentTable: table,
                          referencedTable: $$GroupsTableReferences
                              ._groupMembersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GroupsTableReferences(
                                db,
                                table,
                                p0,
                              ).groupMembersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.groupId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (questsRefs)
                        await $_getPrefetchedData<Group, $GroupsTable, Quest>(
                          currentTable: table,
                          referencedTable: $$GroupsTableReferences
                              ._questsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GroupsTableReferences(db, table, p0).questsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.groupId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$GroupsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GroupsTable,
      Group,
      $$GroupsTableFilterComposer,
      $$GroupsTableOrderingComposer,
      $$GroupsTableAnnotationComposer,
      $$GroupsTableCreateCompanionBuilder,
      $$GroupsTableUpdateCompanionBuilder,
      (Group, $$GroupsTableReferences),
      Group,
      PrefetchHooks Function({bool groupMembersRefs, bool questsRefs})
    >;
typedef $$UsersTableCreateCompanionBuilder =
    UsersCompanion Function({
      required String publicId,
      Value<String?> username,
      Value<String?> phoneNumber,
      Value<UserRole> role,
      Value<int> rowid,
    });
typedef $$UsersTableUpdateCompanionBuilder =
    UsersCompanion Function({
      Value<String> publicId,
      Value<String?> username,
      Value<String?> phoneNumber,
      Value<UserRole> role,
      Value<int> rowid,
    });

final class $$UsersTableReferences
    extends BaseReferences<_$AppDatabase, $UsersTable, User> {
  $$UsersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$GroupMembersTable, List<GroupMember>>
  _groupMembersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.groupMembers,
    aliasName: $_aliasNameGenerator(
      db.users.publicId,
      db.groupMembers.userPublicId,
    ),
  );

  $$GroupMembersTableProcessedTableManager get groupMembersRefs {
    final manager = $$GroupMembersTableTableManager($_db, $_db.groupMembers)
        .filter(
          (f) => f.userPublicId.publicId.sqlEquals(
            $_itemColumn<String>('public_id')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(_groupMembersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$QuestsTable, List<Quest>> _createdQuestsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.quests,
    aliasName: $_aliasNameGenerator(
      db.users.publicId,
      db.quests.creatorPublicId,
    ),
  );

  $$QuestsTableProcessedTableManager get createdQuests {
    final manager = $$QuestsTableTableManager($_db, $_db.quests).filter(
      (f) => f.creatorPublicId.publicId.sqlEquals(
        $_itemColumn<String>('public_id')!,
      ),
    );

    final cache = $_typedResult.readTableOrNull(_createdQuestsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$QuestsTable, List<Quest>> _acceptedQuestsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.quests,
    aliasName: $_aliasNameGenerator(
      db.users.publicId,
      db.quests.acceptedByPublicId,
    ),
  );

  $$QuestsTableProcessedTableManager get acceptedQuests {
    final manager = $$QuestsTableTableManager($_db, $_db.quests).filter(
      (f) => f.acceptedByPublicId.publicId.sqlEquals(
        $_itemColumn<String>('public_id')!,
      ),
    );

    final cache = $_typedResult.readTableOrNull(_acceptedQuestsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get publicId => $composableBuilder(
    column: $table.publicId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<UserRole, UserRole, String> get role =>
      $composableBuilder(
        column: $table.role,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  Expression<bool> groupMembersRefs(
    Expression<bool> Function($$GroupMembersTableFilterComposer f) f,
  ) {
    final $$GroupMembersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.publicId,
      referencedTable: $db.groupMembers,
      getReferencedColumn: (t) => t.userPublicId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupMembersTableFilterComposer(
            $db: $db,
            $table: $db.groupMembers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> createdQuests(
    Expression<bool> Function($$QuestsTableFilterComposer f) f,
  ) {
    final $$QuestsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.publicId,
      referencedTable: $db.quests,
      getReferencedColumn: (t) => t.creatorPublicId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestsTableFilterComposer(
            $db: $db,
            $table: $db.quests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> acceptedQuests(
    Expression<bool> Function($$QuestsTableFilterComposer f) f,
  ) {
    final $$QuestsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.publicId,
      referencedTable: $db.quests,
      getReferencedColumn: (t) => t.acceptedByPublicId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestsTableFilterComposer(
            $db: $db,
            $table: $db.quests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get publicId => $composableBuilder(
    column: $table.publicId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get publicId =>
      $composableBuilder(column: $table.publicId, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<UserRole, String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  Expression<T> groupMembersRefs<T extends Object>(
    Expression<T> Function($$GroupMembersTableAnnotationComposer a) f,
  ) {
    final $$GroupMembersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.publicId,
      referencedTable: $db.groupMembers,
      getReferencedColumn: (t) => t.userPublicId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupMembersTableAnnotationComposer(
            $db: $db,
            $table: $db.groupMembers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> createdQuests<T extends Object>(
    Expression<T> Function($$QuestsTableAnnotationComposer a) f,
  ) {
    final $$QuestsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.publicId,
      referencedTable: $db.quests,
      getReferencedColumn: (t) => t.creatorPublicId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestsTableAnnotationComposer(
            $db: $db,
            $table: $db.quests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> acceptedQuests<T extends Object>(
    Expression<T> Function($$QuestsTableAnnotationComposer a) f,
  ) {
    final $$QuestsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.publicId,
      referencedTable: $db.quests,
      getReferencedColumn: (t) => t.acceptedByPublicId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestsTableAnnotationComposer(
            $db: $db,
            $table: $db.quests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersTable,
          User,
          $$UsersTableFilterComposer,
          $$UsersTableOrderingComposer,
          $$UsersTableAnnotationComposer,
          $$UsersTableCreateCompanionBuilder,
          $$UsersTableUpdateCompanionBuilder,
          (User, $$UsersTableReferences),
          User,
          PrefetchHooks Function({
            bool groupMembersRefs,
            bool createdQuests,
            bool acceptedQuests,
          })
        > {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> publicId = const Value.absent(),
                Value<String?> username = const Value.absent(),
                Value<String?> phoneNumber = const Value.absent(),
                Value<UserRole> role = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion(
                publicId: publicId,
                username: username,
                phoneNumber: phoneNumber,
                role: role,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String publicId,
                Value<String?> username = const Value.absent(),
                Value<String?> phoneNumber = const Value.absent(),
                Value<UserRole> role = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion.insert(
                publicId: publicId,
                username: username,
                phoneNumber: phoneNumber,
                role: role,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$UsersTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                groupMembersRefs = false,
                createdQuests = false,
                acceptedQuests = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (groupMembersRefs) db.groupMembers,
                    if (createdQuests) db.quests,
                    if (acceptedQuests) db.quests,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (groupMembersRefs)
                        await $_getPrefetchedData<
                          User,
                          $UsersTable,
                          GroupMember
                        >(
                          currentTable: table,
                          referencedTable: $$UsersTableReferences
                              ._groupMembersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsersTableReferences(
                                db,
                                table,
                                p0,
                              ).groupMembersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userPublicId == item.publicId,
                              ),
                          typedResults: items,
                        ),
                      if (createdQuests)
                        await $_getPrefetchedData<User, $UsersTable, Quest>(
                          currentTable: table,
                          referencedTable: $$UsersTableReferences
                              ._createdQuestsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsersTableReferences(
                                db,
                                table,
                                p0,
                              ).createdQuests,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.creatorPublicId == item.publicId,
                              ),
                          typedResults: items,
                        ),
                      if (acceptedQuests)
                        await $_getPrefetchedData<User, $UsersTable, Quest>(
                          currentTable: table,
                          referencedTable: $$UsersTableReferences
                              ._acceptedQuestsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsersTableReferences(
                                db,
                                table,
                                p0,
                              ).acceptedQuests,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.acceptedByPublicId == item.publicId,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$UsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersTable,
      User,
      $$UsersTableFilterComposer,
      $$UsersTableOrderingComposer,
      $$UsersTableAnnotationComposer,
      $$UsersTableCreateCompanionBuilder,
      $$UsersTableUpdateCompanionBuilder,
      (User, $$UsersTableReferences),
      User,
      PrefetchHooks Function({
        bool groupMembersRefs,
        bool createdQuests,
        bool acceptedQuests,
      })
    >;
typedef $$GroupMembersTableCreateCompanionBuilder =
    GroupMembersCompanion Function({
      Value<int> id,
      required int groupId,
      required String userPublicId,
      Value<MemberRole> role,
      required DateTime updatedAt,
      Value<int> currency,
    });
typedef $$GroupMembersTableUpdateCompanionBuilder =
    GroupMembersCompanion Function({
      Value<int> id,
      Value<int> groupId,
      Value<String> userPublicId,
      Value<MemberRole> role,
      Value<DateTime> updatedAt,
      Value<int> currency,
    });

final class $$GroupMembersTableReferences
    extends BaseReferences<_$AppDatabase, $GroupMembersTable, GroupMember> {
  $$GroupMembersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GroupsTable _groupIdTable(_$AppDatabase db) => db.groups.createAlias(
    $_aliasNameGenerator(db.groupMembers.groupId, db.groups.id),
  );

  $$GroupsTableProcessedTableManager get groupId {
    final $_column = $_itemColumn<int>('group_id')!;

    final manager = $$GroupsTableTableManager(
      $_db,
      $_db.groups,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_groupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $UsersTable _userPublicIdTable(_$AppDatabase db) =>
      db.users.createAlias(
        $_aliasNameGenerator(db.groupMembers.userPublicId, db.users.publicId),
      );

  $$UsersTableProcessedTableManager get userPublicId {
    final $_column = $_itemColumn<String>('user_public_id')!;

    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.publicId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userPublicIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$GroupMembersTableFilterComposer
    extends Composer<_$AppDatabase, $GroupMembersTable> {
  $$GroupMembersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<MemberRole, MemberRole, String> get role =>
      $composableBuilder(
        column: $table.role,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  $$GroupsTableFilterComposer get groupId {
    final $$GroupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsTableFilterComposer(
            $db: $db,
            $table: $db.groups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsersTableFilterComposer get userPublicId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userPublicId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.publicId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableFilterComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GroupMembersTableOrderingComposer
    extends Composer<_$AppDatabase, $GroupMembersTable> {
  $$GroupMembersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  $$GroupsTableOrderingComposer get groupId {
    final $$GroupsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsTableOrderingComposer(
            $db: $db,
            $table: $db.groups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsersTableOrderingComposer get userPublicId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userPublicId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.publicId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableOrderingComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GroupMembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $GroupMembersTable> {
  $$GroupMembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MemberRole, String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  $$GroupsTableAnnotationComposer get groupId {
    final $$GroupsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsTableAnnotationComposer(
            $db: $db,
            $table: $db.groups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsersTableAnnotationComposer get userPublicId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userPublicId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.publicId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableAnnotationComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GroupMembersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GroupMembersTable,
          GroupMember,
          $$GroupMembersTableFilterComposer,
          $$GroupMembersTableOrderingComposer,
          $$GroupMembersTableAnnotationComposer,
          $$GroupMembersTableCreateCompanionBuilder,
          $$GroupMembersTableUpdateCompanionBuilder,
          (GroupMember, $$GroupMembersTableReferences),
          GroupMember,
          PrefetchHooks Function({bool groupId, bool userPublicId})
        > {
  $$GroupMembersTableTableManager(_$AppDatabase db, $GroupMembersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GroupMembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GroupMembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GroupMembersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> groupId = const Value.absent(),
                Value<String> userPublicId = const Value.absent(),
                Value<MemberRole> role = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> currency = const Value.absent(),
              }) => GroupMembersCompanion(
                id: id,
                groupId: groupId,
                userPublicId: userPublicId,
                role: role,
                updatedAt: updatedAt,
                currency: currency,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int groupId,
                required String userPublicId,
                Value<MemberRole> role = const Value.absent(),
                required DateTime updatedAt,
                Value<int> currency = const Value.absent(),
              }) => GroupMembersCompanion.insert(
                id: id,
                groupId: groupId,
                userPublicId: userPublicId,
                role: role,
                updatedAt: updatedAt,
                currency: currency,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$GroupMembersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({groupId = false, userPublicId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (groupId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.groupId,
                                referencedTable: $$GroupMembersTableReferences
                                    ._groupIdTable(db),
                                referencedColumn: $$GroupMembersTableReferences
                                    ._groupIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (userPublicId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.userPublicId,
                                referencedTable: $$GroupMembersTableReferences
                                    ._userPublicIdTable(db),
                                referencedColumn: $$GroupMembersTableReferences
                                    ._userPublicIdTable(db)
                                    .publicId,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$GroupMembersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GroupMembersTable,
      GroupMember,
      $$GroupMembersTableFilterComposer,
      $$GroupMembersTableOrderingComposer,
      $$GroupMembersTableAnnotationComposer,
      $$GroupMembersTableCreateCompanionBuilder,
      $$GroupMembersTableUpdateCompanionBuilder,
      (GroupMember, $$GroupMembersTableReferences),
      GroupMember,
      PrefetchHooks Function({bool groupId, bool userPublicId})
    >;
typedef $$QuestsTableCreateCompanionBuilder =
    QuestsCompanion Function({
      Value<int> id,
      required int groupId,
      required String publicId,
      required String name,
      Value<String?> description,
      Value<DateTime?> deadline,
      Value<DateTime?> startTime,
      Value<String?> data,
      Value<String?> address,
      Value<RewardType> rewardType,
      Value<String?> rewardValue,
      required bool inclusive,
      Value<QuestStatus> status,
      required String creatorPublicId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String?> acceptedByPublicId,
      Value<bool> automaticReward,
    });
typedef $$QuestsTableUpdateCompanionBuilder =
    QuestsCompanion Function({
      Value<int> id,
      Value<int> groupId,
      Value<String> publicId,
      Value<String> name,
      Value<String?> description,
      Value<DateTime?> deadline,
      Value<DateTime?> startTime,
      Value<String?> data,
      Value<String?> address,
      Value<RewardType> rewardType,
      Value<String?> rewardValue,
      Value<bool> inclusive,
      Value<QuestStatus> status,
      Value<String> creatorPublicId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String?> acceptedByPublicId,
      Value<bool> automaticReward,
    });

final class $$QuestsTableReferences
    extends BaseReferences<_$AppDatabase, $QuestsTable, Quest> {
  $$QuestsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GroupsTable _groupIdTable(_$AppDatabase db) => db.groups.createAlias(
    $_aliasNameGenerator(db.quests.groupId, db.groups.id),
  );

  $$GroupsTableProcessedTableManager get groupId {
    final $_column = $_itemColumn<int>('group_id')!;

    final manager = $$GroupsTableTableManager(
      $_db,
      $_db.groups,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_groupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $UsersTable _creatorPublicIdTable(_$AppDatabase db) =>
      db.users.createAlias(
        $_aliasNameGenerator(db.quests.creatorPublicId, db.users.publicId),
      );

  $$UsersTableProcessedTableManager get creatorPublicId {
    final $_column = $_itemColumn<String>('creator_public_id')!;

    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.publicId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_creatorPublicIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $UsersTable _acceptedByPublicIdTable(_$AppDatabase db) =>
      db.users.createAlias(
        $_aliasNameGenerator(db.quests.acceptedByPublicId, db.users.publicId),
      );

  $$UsersTableProcessedTableManager? get acceptedByPublicId {
    final $_column = $_itemColumn<String>('accepted_by_public_id');
    if ($_column == null) return null;
    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.publicId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_acceptedByPublicIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$QuestsTableFilterComposer
    extends Composer<_$AppDatabase, $QuestsTable> {
  $$QuestsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get publicId => $composableBuilder(
    column: $table.publicId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deadline => $composableBuilder(
    column: $table.deadline,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<RewardType, RewardType, String>
  get rewardType => $composableBuilder(
    column: $table.rewardType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get rewardValue => $composableBuilder(
    column: $table.rewardValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get inclusive => $composableBuilder(
    column: $table.inclusive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<QuestStatus, QuestStatus, String> get status =>
      $composableBuilder(
        column: $table.status,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get automaticReward => $composableBuilder(
    column: $table.automaticReward,
    builder: (column) => ColumnFilters(column),
  );

  $$GroupsTableFilterComposer get groupId {
    final $$GroupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsTableFilterComposer(
            $db: $db,
            $table: $db.groups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsersTableFilterComposer get creatorPublicId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.creatorPublicId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.publicId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableFilterComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsersTableFilterComposer get acceptedByPublicId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.acceptedByPublicId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.publicId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableFilterComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QuestsTableOrderingComposer
    extends Composer<_$AppDatabase, $QuestsTable> {
  $$QuestsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get publicId => $composableBuilder(
    column: $table.publicId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deadline => $composableBuilder(
    column: $table.deadline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rewardType => $composableBuilder(
    column: $table.rewardType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rewardValue => $composableBuilder(
    column: $table.rewardValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get inclusive => $composableBuilder(
    column: $table.inclusive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get automaticReward => $composableBuilder(
    column: $table.automaticReward,
    builder: (column) => ColumnOrderings(column),
  );

  $$GroupsTableOrderingComposer get groupId {
    final $$GroupsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsTableOrderingComposer(
            $db: $db,
            $table: $db.groups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsersTableOrderingComposer get creatorPublicId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.creatorPublicId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.publicId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableOrderingComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsersTableOrderingComposer get acceptedByPublicId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.acceptedByPublicId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.publicId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableOrderingComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QuestsTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuestsTable> {
  $$QuestsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get publicId =>
      $composableBuilder(column: $table.publicId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deadline =>
      $composableBuilder(column: $table.deadline, builder: (column) => column);

  GeneratedColumn<DateTime> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumnWithTypeConverter<RewardType, String> get rewardType =>
      $composableBuilder(
        column: $table.rewardType,
        builder: (column) => column,
      );

  GeneratedColumn<String> get rewardValue => $composableBuilder(
    column: $table.rewardValue,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get inclusive =>
      $composableBuilder(column: $table.inclusive, builder: (column) => column);

  GeneratedColumnWithTypeConverter<QuestStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get automaticReward => $composableBuilder(
    column: $table.automaticReward,
    builder: (column) => column,
  );

  $$GroupsTableAnnotationComposer get groupId {
    final $$GroupsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsTableAnnotationComposer(
            $db: $db,
            $table: $db.groups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsersTableAnnotationComposer get creatorPublicId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.creatorPublicId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.publicId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableAnnotationComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsersTableAnnotationComposer get acceptedByPublicId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.acceptedByPublicId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.publicId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableAnnotationComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QuestsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QuestsTable,
          Quest,
          $$QuestsTableFilterComposer,
          $$QuestsTableOrderingComposer,
          $$QuestsTableAnnotationComposer,
          $$QuestsTableCreateCompanionBuilder,
          $$QuestsTableUpdateCompanionBuilder,
          (Quest, $$QuestsTableReferences),
          Quest,
          PrefetchHooks Function({
            bool groupId,
            bool creatorPublicId,
            bool acceptedByPublicId,
          })
        > {
  $$QuestsTableTableManager(_$AppDatabase db, $QuestsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuestsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuestsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuestsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> groupId = const Value.absent(),
                Value<String> publicId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<DateTime?> deadline = const Value.absent(),
                Value<DateTime?> startTime = const Value.absent(),
                Value<String?> data = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<RewardType> rewardType = const Value.absent(),
                Value<String?> rewardValue = const Value.absent(),
                Value<bool> inclusive = const Value.absent(),
                Value<QuestStatus> status = const Value.absent(),
                Value<String> creatorPublicId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String?> acceptedByPublicId = const Value.absent(),
                Value<bool> automaticReward = const Value.absent(),
              }) => QuestsCompanion(
                id: id,
                groupId: groupId,
                publicId: publicId,
                name: name,
                description: description,
                deadline: deadline,
                startTime: startTime,
                data: data,
                address: address,
                rewardType: rewardType,
                rewardValue: rewardValue,
                inclusive: inclusive,
                status: status,
                creatorPublicId: creatorPublicId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                acceptedByPublicId: acceptedByPublicId,
                automaticReward: automaticReward,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int groupId,
                required String publicId,
                required String name,
                Value<String?> description = const Value.absent(),
                Value<DateTime?> deadline = const Value.absent(),
                Value<DateTime?> startTime = const Value.absent(),
                Value<String?> data = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<RewardType> rewardType = const Value.absent(),
                Value<String?> rewardValue = const Value.absent(),
                required bool inclusive,
                Value<QuestStatus> status = const Value.absent(),
                required String creatorPublicId,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String?> acceptedByPublicId = const Value.absent(),
                Value<bool> automaticReward = const Value.absent(),
              }) => QuestsCompanion.insert(
                id: id,
                groupId: groupId,
                publicId: publicId,
                name: name,
                description: description,
                deadline: deadline,
                startTime: startTime,
                data: data,
                address: address,
                rewardType: rewardType,
                rewardValue: rewardValue,
                inclusive: inclusive,
                status: status,
                creatorPublicId: creatorPublicId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                acceptedByPublicId: acceptedByPublicId,
                automaticReward: automaticReward,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$QuestsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                groupId = false,
                creatorPublicId = false,
                acceptedByPublicId = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (groupId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.groupId,
                                    referencedTable: $$QuestsTableReferences
                                        ._groupIdTable(db),
                                    referencedColumn: $$QuestsTableReferences
                                        ._groupIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (creatorPublicId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.creatorPublicId,
                                    referencedTable: $$QuestsTableReferences
                                        ._creatorPublicIdTable(db),
                                    referencedColumn: $$QuestsTableReferences
                                        ._creatorPublicIdTable(db)
                                        .publicId,
                                  )
                                  as T;
                        }
                        if (acceptedByPublicId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.acceptedByPublicId,
                                    referencedTable: $$QuestsTableReferences
                                        ._acceptedByPublicIdTable(db),
                                    referencedColumn: $$QuestsTableReferences
                                        ._acceptedByPublicIdTable(db)
                                        .publicId,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$QuestsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QuestsTable,
      Quest,
      $$QuestsTableFilterComposer,
      $$QuestsTableOrderingComposer,
      $$QuestsTableAnnotationComposer,
      $$QuestsTableCreateCompanionBuilder,
      $$QuestsTableUpdateCompanionBuilder,
      (Quest, $$QuestsTableReferences),
      Quest,
      PrefetchHooks Function({
        bool groupId,
        bool creatorPublicId,
        bool acceptedByPublicId,
      })
    >;
typedef $$QuestTemplatesTableCreateCompanionBuilder =
    QuestTemplatesCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> description,
      Value<String?> address,
      Value<RewardType> rewardType,
      Value<String?> rewardValue,
      Value<bool> inclusive,
      Value<bool> isDelayedStart,
      Value<int?> deadlineOffsetDays,
      Value<int?> deadlineHour,
      Value<int?> deadlineMinute,
      Value<int?> startTimeOffsetDays,
      Value<int?> startTimeHour,
      Value<int?> startTimeMinute,
      Value<bool> automaticReward,
      Value<DateTime> savedAt,
    });
typedef $$QuestTemplatesTableUpdateCompanionBuilder =
    QuestTemplatesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> description,
      Value<String?> address,
      Value<RewardType> rewardType,
      Value<String?> rewardValue,
      Value<bool> inclusive,
      Value<bool> isDelayedStart,
      Value<int?> deadlineOffsetDays,
      Value<int?> deadlineHour,
      Value<int?> deadlineMinute,
      Value<int?> startTimeOffsetDays,
      Value<int?> startTimeHour,
      Value<int?> startTimeMinute,
      Value<bool> automaticReward,
      Value<DateTime> savedAt,
    });

class $$QuestTemplatesTableFilterComposer
    extends Composer<_$AppDatabase, $QuestTemplatesTable> {
  $$QuestTemplatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<RewardType, RewardType, String>
  get rewardType => $composableBuilder(
    column: $table.rewardType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get rewardValue => $composableBuilder(
    column: $table.rewardValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get inclusive => $composableBuilder(
    column: $table.inclusive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDelayedStart => $composableBuilder(
    column: $table.isDelayedStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deadlineOffsetDays => $composableBuilder(
    column: $table.deadlineOffsetDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deadlineHour => $composableBuilder(
    column: $table.deadlineHour,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deadlineMinute => $composableBuilder(
    column: $table.deadlineMinute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startTimeOffsetDays => $composableBuilder(
    column: $table.startTimeOffsetDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startTimeHour => $composableBuilder(
    column: $table.startTimeHour,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startTimeMinute => $composableBuilder(
    column: $table.startTimeMinute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get automaticReward => $composableBuilder(
    column: $table.automaticReward,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$QuestTemplatesTableOrderingComposer
    extends Composer<_$AppDatabase, $QuestTemplatesTable> {
  $$QuestTemplatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rewardType => $composableBuilder(
    column: $table.rewardType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rewardValue => $composableBuilder(
    column: $table.rewardValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get inclusive => $composableBuilder(
    column: $table.inclusive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDelayedStart => $composableBuilder(
    column: $table.isDelayedStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deadlineOffsetDays => $composableBuilder(
    column: $table.deadlineOffsetDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deadlineHour => $composableBuilder(
    column: $table.deadlineHour,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deadlineMinute => $composableBuilder(
    column: $table.deadlineMinute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startTimeOffsetDays => $composableBuilder(
    column: $table.startTimeOffsetDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startTimeHour => $composableBuilder(
    column: $table.startTimeHour,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startTimeMinute => $composableBuilder(
    column: $table.startTimeMinute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get automaticReward => $composableBuilder(
    column: $table.automaticReward,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$QuestTemplatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuestTemplatesTable> {
  $$QuestTemplatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumnWithTypeConverter<RewardType, String> get rewardType =>
      $composableBuilder(
        column: $table.rewardType,
        builder: (column) => column,
      );

  GeneratedColumn<String> get rewardValue => $composableBuilder(
    column: $table.rewardValue,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get inclusive =>
      $composableBuilder(column: $table.inclusive, builder: (column) => column);

  GeneratedColumn<bool> get isDelayedStart => $composableBuilder(
    column: $table.isDelayedStart,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deadlineOffsetDays => $composableBuilder(
    column: $table.deadlineOffsetDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deadlineHour => $composableBuilder(
    column: $table.deadlineHour,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deadlineMinute => $composableBuilder(
    column: $table.deadlineMinute,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startTimeOffsetDays => $composableBuilder(
    column: $table.startTimeOffsetDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startTimeHour => $composableBuilder(
    column: $table.startTimeHour,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startTimeMinute => $composableBuilder(
    column: $table.startTimeMinute,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get automaticReward => $composableBuilder(
    column: $table.automaticReward,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get savedAt =>
      $composableBuilder(column: $table.savedAt, builder: (column) => column);
}

class $$QuestTemplatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QuestTemplatesTable,
          QuestTemplate,
          $$QuestTemplatesTableFilterComposer,
          $$QuestTemplatesTableOrderingComposer,
          $$QuestTemplatesTableAnnotationComposer,
          $$QuestTemplatesTableCreateCompanionBuilder,
          $$QuestTemplatesTableUpdateCompanionBuilder,
          (
            QuestTemplate,
            BaseReferences<_$AppDatabase, $QuestTemplatesTable, QuestTemplate>,
          ),
          QuestTemplate,
          PrefetchHooks Function()
        > {
  $$QuestTemplatesTableTableManager(
    _$AppDatabase db,
    $QuestTemplatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuestTemplatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuestTemplatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuestTemplatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<RewardType> rewardType = const Value.absent(),
                Value<String?> rewardValue = const Value.absent(),
                Value<bool> inclusive = const Value.absent(),
                Value<bool> isDelayedStart = const Value.absent(),
                Value<int?> deadlineOffsetDays = const Value.absent(),
                Value<int?> deadlineHour = const Value.absent(),
                Value<int?> deadlineMinute = const Value.absent(),
                Value<int?> startTimeOffsetDays = const Value.absent(),
                Value<int?> startTimeHour = const Value.absent(),
                Value<int?> startTimeMinute = const Value.absent(),
                Value<bool> automaticReward = const Value.absent(),
                Value<DateTime> savedAt = const Value.absent(),
              }) => QuestTemplatesCompanion(
                id: id,
                name: name,
                description: description,
                address: address,
                rewardType: rewardType,
                rewardValue: rewardValue,
                inclusive: inclusive,
                isDelayedStart: isDelayedStart,
                deadlineOffsetDays: deadlineOffsetDays,
                deadlineHour: deadlineHour,
                deadlineMinute: deadlineMinute,
                startTimeOffsetDays: startTimeOffsetDays,
                startTimeHour: startTimeHour,
                startTimeMinute: startTimeMinute,
                automaticReward: automaticReward,
                savedAt: savedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> description = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<RewardType> rewardType = const Value.absent(),
                Value<String?> rewardValue = const Value.absent(),
                Value<bool> inclusive = const Value.absent(),
                Value<bool> isDelayedStart = const Value.absent(),
                Value<int?> deadlineOffsetDays = const Value.absent(),
                Value<int?> deadlineHour = const Value.absent(),
                Value<int?> deadlineMinute = const Value.absent(),
                Value<int?> startTimeOffsetDays = const Value.absent(),
                Value<int?> startTimeHour = const Value.absent(),
                Value<int?> startTimeMinute = const Value.absent(),
                Value<bool> automaticReward = const Value.absent(),
                Value<DateTime> savedAt = const Value.absent(),
              }) => QuestTemplatesCompanion.insert(
                id: id,
                name: name,
                description: description,
                address: address,
                rewardType: rewardType,
                rewardValue: rewardValue,
                inclusive: inclusive,
                isDelayedStart: isDelayedStart,
                deadlineOffsetDays: deadlineOffsetDays,
                deadlineHour: deadlineHour,
                deadlineMinute: deadlineMinute,
                startTimeOffsetDays: startTimeOffsetDays,
                startTimeHour: startTimeHour,
                startTimeMinute: startTimeMinute,
                automaticReward: automaticReward,
                savedAt: savedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$QuestTemplatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QuestTemplatesTable,
      QuestTemplate,
      $$QuestTemplatesTableFilterComposer,
      $$QuestTemplatesTableOrderingComposer,
      $$QuestTemplatesTableAnnotationComposer,
      $$QuestTemplatesTableCreateCompanionBuilder,
      $$QuestTemplatesTableUpdateCompanionBuilder,
      (
        QuestTemplate,
        BaseReferences<_$AppDatabase, $QuestTemplatesTable, QuestTemplate>,
      ),
      QuestTemplate,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$GroupsTableTableManager get groups =>
      $$GroupsTableTableManager(_db, _db.groups);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$GroupMembersTableTableManager get groupMembers =>
      $$GroupMembersTableTableManager(_db, _db.groupMembers);
  $$QuestsTableTableManager get quests =>
      $$QuestsTableTableManager(_db, _db.quests);
  $$QuestTemplatesTableTableManager get questTemplates =>
      $$QuestTemplatesTableTableManager(_db, _db.questTemplates);
}
