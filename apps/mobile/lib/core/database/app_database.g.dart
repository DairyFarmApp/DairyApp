// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LocalSessionMetadataTable extends LocalSessionMetadata
    with TableInfo<$LocalSessionMetadataTable, LocalSessionMetadataData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalSessionMetadataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activeOrganizationIdMeta =
      const VerificationMeta('activeOrganizationId');
  @override
  late final GeneratedColumn<String> activeOrganizationId =
      GeneratedColumn<String>(
        'active_organization_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _activeFarmIdMeta = const VerificationMeta(
    'activeFarmId',
  );
  @override
  late final GeneratedColumn<String> activeFarmId = GeneratedColumn<String>(
    'active_farm_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accessExpiresAtMeta = const VerificationMeta(
    'accessExpiresAt',
  );
  @override
  late final GeneratedColumn<DateTime> accessExpiresAt =
      GeneratedColumn<DateTime>(
        'access_expires_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    activeOrganizationId,
    activeFarmId,
    accessExpiresAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_session_metadata';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalSessionMetadataData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('active_organization_id')) {
      context.handle(
        _activeOrganizationIdMeta,
        activeOrganizationId.isAcceptableOrUnknown(
          data['active_organization_id']!,
          _activeOrganizationIdMeta,
        ),
      );
    }
    if (data.containsKey('active_farm_id')) {
      context.handle(
        _activeFarmIdMeta,
        activeFarmId.isAcceptableOrUnknown(
          data['active_farm_id']!,
          _activeFarmIdMeta,
        ),
      );
    }
    if (data.containsKey('access_expires_at')) {
      context.handle(
        _accessExpiresAtMeta,
        accessExpiresAt.isAcceptableOrUnknown(
          data['access_expires_at']!,
          _accessExpiresAtMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalSessionMetadataData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalSessionMetadataData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      activeOrganizationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}active_organization_id'],
      ),
      activeFarmId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}active_farm_id'],
      ),
      accessExpiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}access_expires_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LocalSessionMetadataTable createAlias(String alias) {
    return $LocalSessionMetadataTable(attachedDatabase, alias);
  }
}

class LocalSessionMetadataData extends DataClass
    implements Insertable<LocalSessionMetadataData> {
  final String id;
  final String userId;
  final String? activeOrganizationId;
  final String? activeFarmId;
  final DateTime? accessExpiresAt;
  final DateTime updatedAt;
  const LocalSessionMetadataData({
    required this.id,
    required this.userId,
    this.activeOrganizationId,
    this.activeFarmId,
    this.accessExpiresAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || activeOrganizationId != null) {
      map['active_organization_id'] = Variable<String>(activeOrganizationId);
    }
    if (!nullToAbsent || activeFarmId != null) {
      map['active_farm_id'] = Variable<String>(activeFarmId);
    }
    if (!nullToAbsent || accessExpiresAt != null) {
      map['access_expires_at'] = Variable<DateTime>(accessExpiresAt);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalSessionMetadataCompanion toCompanion(bool nullToAbsent) {
    return LocalSessionMetadataCompanion(
      id: Value(id),
      userId: Value(userId),
      activeOrganizationId: activeOrganizationId == null && nullToAbsent
          ? const Value.absent()
          : Value(activeOrganizationId),
      activeFarmId: activeFarmId == null && nullToAbsent
          ? const Value.absent()
          : Value(activeFarmId),
      accessExpiresAt: accessExpiresAt == null && nullToAbsent
          ? const Value.absent()
          : Value(accessExpiresAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalSessionMetadataData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalSessionMetadataData(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      activeOrganizationId: serializer.fromJson<String?>(
        json['activeOrganizationId'],
      ),
      activeFarmId: serializer.fromJson<String?>(json['activeFarmId']),
      accessExpiresAt: serializer.fromJson<DateTime?>(json['accessExpiresAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'activeOrganizationId': serializer.toJson<String?>(activeOrganizationId),
      'activeFarmId': serializer.toJson<String?>(activeFarmId),
      'accessExpiresAt': serializer.toJson<DateTime?>(accessExpiresAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalSessionMetadataData copyWith({
    String? id,
    String? userId,
    Value<String?> activeOrganizationId = const Value.absent(),
    Value<String?> activeFarmId = const Value.absent(),
    Value<DateTime?> accessExpiresAt = const Value.absent(),
    DateTime? updatedAt,
  }) => LocalSessionMetadataData(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    activeOrganizationId: activeOrganizationId.present
        ? activeOrganizationId.value
        : this.activeOrganizationId,
    activeFarmId: activeFarmId.present ? activeFarmId.value : this.activeFarmId,
    accessExpiresAt: accessExpiresAt.present
        ? accessExpiresAt.value
        : this.accessExpiresAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalSessionMetadataData copyWithCompanion(
    LocalSessionMetadataCompanion data,
  ) {
    return LocalSessionMetadataData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      activeOrganizationId: data.activeOrganizationId.present
          ? data.activeOrganizationId.value
          : this.activeOrganizationId,
      activeFarmId: data.activeFarmId.present
          ? data.activeFarmId.value
          : this.activeFarmId,
      accessExpiresAt: data.accessExpiresAt.present
          ? data.accessExpiresAt.value
          : this.accessExpiresAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalSessionMetadataData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('activeOrganizationId: $activeOrganizationId, ')
          ..write('activeFarmId: $activeFarmId, ')
          ..write('accessExpiresAt: $accessExpiresAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    activeOrganizationId,
    activeFarmId,
    accessExpiresAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalSessionMetadataData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.activeOrganizationId == this.activeOrganizationId &&
          other.activeFarmId == this.activeFarmId &&
          other.accessExpiresAt == this.accessExpiresAt &&
          other.updatedAt == this.updatedAt);
}

class LocalSessionMetadataCompanion
    extends UpdateCompanion<LocalSessionMetadataData> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String?> activeOrganizationId;
  final Value<String?> activeFarmId;
  final Value<DateTime?> accessExpiresAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalSessionMetadataCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.activeOrganizationId = const Value.absent(),
    this.activeFarmId = const Value.absent(),
    this.accessExpiresAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalSessionMetadataCompanion.insert({
    required String id,
    required String userId,
    this.activeOrganizationId = const Value.absent(),
    this.activeFarmId = const Value.absent(),
    this.accessExpiresAt = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       updatedAt = Value(updatedAt);
  static Insertable<LocalSessionMetadataData> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? activeOrganizationId,
    Expression<String>? activeFarmId,
    Expression<DateTime>? accessExpiresAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (activeOrganizationId != null)
        'active_organization_id': activeOrganizationId,
      if (activeFarmId != null) 'active_farm_id': activeFarmId,
      if (accessExpiresAt != null) 'access_expires_at': accessExpiresAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalSessionMetadataCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String?>? activeOrganizationId,
    Value<String?>? activeFarmId,
    Value<DateTime?>? accessExpiresAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalSessionMetadataCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      activeOrganizationId: activeOrganizationId ?? this.activeOrganizationId,
      activeFarmId: activeFarmId ?? this.activeFarmId,
      accessExpiresAt: accessExpiresAt ?? this.accessExpiresAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (activeOrganizationId.present) {
      map['active_organization_id'] = Variable<String>(
        activeOrganizationId.value,
      );
    }
    if (activeFarmId.present) {
      map['active_farm_id'] = Variable<String>(activeFarmId.value);
    }
    if (accessExpiresAt.present) {
      map['access_expires_at'] = Variable<DateTime>(accessExpiresAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalSessionMetadataCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('activeOrganizationId: $activeOrganizationId, ')
          ..write('activeFarmId: $activeFarmId, ')
          ..write('accessExpiresAt: $accessExpiresAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalOrganizationsTable extends LocalOrganizations
    with TableInfo<$LocalOrganizationsTable, LocalOrganization> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalOrganizationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _serverUpdatedAtMeta = const VerificationMeta(
    'serverUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> serverUpdatedAt =
      GeneratedColumn<DateTime>(
        'server_updated_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    version,
    serverUpdatedAt,
    isDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_organizations';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalOrganization> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
        _serverUpdatedAtMeta,
        serverUpdatedAt.isAcceptableOrUnknown(
          data['server_updated_at']!,
          _serverUpdatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_serverUpdatedAtMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalOrganization map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalOrganization(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}server_updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $LocalOrganizationsTable createAlias(String alias) {
    return $LocalOrganizationsTable(attachedDatabase, alias);
  }
}

class LocalOrganization extends DataClass
    implements Insertable<LocalOrganization> {
  final String id;
  final String name;
  final int version;
  final DateTime serverUpdatedAt;
  final bool isDeleted;
  const LocalOrganization({
    required this.id,
    required this.name,
    required this.version,
    required this.serverUpdatedAt,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['version'] = Variable<int>(version);
    map['server_updated_at'] = Variable<DateTime>(serverUpdatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  LocalOrganizationsCompanion toCompanion(bool nullToAbsent) {
    return LocalOrganizationsCompanion(
      id: Value(id),
      name: Value(name),
      version: Value(version),
      serverUpdatedAt: Value(serverUpdatedAt),
      isDeleted: Value(isDeleted),
    );
  }

  factory LocalOrganization.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalOrganization(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      version: serializer.fromJson<int>(json['version']),
      serverUpdatedAt: serializer.fromJson<DateTime>(json['serverUpdatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'version': serializer.toJson<int>(version),
      'serverUpdatedAt': serializer.toJson<DateTime>(serverUpdatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  LocalOrganization copyWith({
    String? id,
    String? name,
    int? version,
    DateTime? serverUpdatedAt,
    bool? isDeleted,
  }) => LocalOrganization(
    id: id ?? this.id,
    name: name ?? this.name,
    version: version ?? this.version,
    serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  LocalOrganization copyWithCompanion(LocalOrganizationsCompanion data) {
    return LocalOrganization(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      version: data.version.present ? data.version.value : this.version,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalOrganization(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('version: $version, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, version, serverUpdatedAt, isDeleted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalOrganization &&
          other.id == this.id &&
          other.name == this.name &&
          other.version == this.version &&
          other.serverUpdatedAt == this.serverUpdatedAt &&
          other.isDeleted == this.isDeleted);
}

class LocalOrganizationsCompanion extends UpdateCompanion<LocalOrganization> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> version;
  final Value<DateTime> serverUpdatedAt;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const LocalOrganizationsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.version = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalOrganizationsCompanion.insert({
    required String id,
    required String name,
    this.version = const Value.absent(),
    required DateTime serverUpdatedAt,
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       serverUpdatedAt = Value(serverUpdatedAt);
  static Insertable<LocalOrganization> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? version,
    Expression<DateTime>? serverUpdatedAt,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (version != null) 'version': version,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalOrganizationsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? version,
    Value<DateTime>? serverUpdatedAt,
    Value<bool>? isDeleted,
    Value<int>? rowid,
  }) {
    return LocalOrganizationsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      version: version ?? this.version,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<DateTime>(serverUpdatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalOrganizationsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('version: $version, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalFarmsTable extends LocalFarms
    with TableInfo<$LocalFarmsTable, LocalFarm> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalFarmsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _organizationIdMeta = const VerificationMeta(
    'organizationId',
  );
  @override
  late final GeneratedColumn<String> organizationId = GeneratedColumn<String>(
    'organization_id',
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
  static const VerificationMeta _timezoneMeta = const VerificationMeta(
    'timezone',
  );
  @override
  late final GeneratedColumn<String> timezone = GeneratedColumn<String>(
    'timezone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('UTC'),
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _serverUpdatedAtMeta = const VerificationMeta(
    'serverUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> serverUpdatedAt =
      GeneratedColumn<DateTime>(
        'server_updated_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    organizationId,
    name,
    timezone,
    version,
    serverUpdatedAt,
    isDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_farms';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalFarm> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('organization_id')) {
      context.handle(
        _organizationIdMeta,
        organizationId.isAcceptableOrUnknown(
          data['organization_id']!,
          _organizationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_organizationIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('timezone')) {
      context.handle(
        _timezoneMeta,
        timezone.isAcceptableOrUnknown(data['timezone']!, _timezoneMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
        _serverUpdatedAtMeta,
        serverUpdatedAt.isAcceptableOrUnknown(
          data['server_updated_at']!,
          _serverUpdatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_serverUpdatedAtMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalFarm map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalFarm(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      organizationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}organization_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      timezone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}timezone'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}server_updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $LocalFarmsTable createAlias(String alias) {
    return $LocalFarmsTable(attachedDatabase, alias);
  }
}

class LocalFarm extends DataClass implements Insertable<LocalFarm> {
  final String id;
  final String organizationId;
  final String name;
  final String timezone;
  final int version;
  final DateTime serverUpdatedAt;
  final bool isDeleted;
  const LocalFarm({
    required this.id,
    required this.organizationId,
    required this.name,
    required this.timezone,
    required this.version,
    required this.serverUpdatedAt,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['organization_id'] = Variable<String>(organizationId);
    map['name'] = Variable<String>(name);
    map['timezone'] = Variable<String>(timezone);
    map['version'] = Variable<int>(version);
    map['server_updated_at'] = Variable<DateTime>(serverUpdatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  LocalFarmsCompanion toCompanion(bool nullToAbsent) {
    return LocalFarmsCompanion(
      id: Value(id),
      organizationId: Value(organizationId),
      name: Value(name),
      timezone: Value(timezone),
      version: Value(version),
      serverUpdatedAt: Value(serverUpdatedAt),
      isDeleted: Value(isDeleted),
    );
  }

  factory LocalFarm.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalFarm(
      id: serializer.fromJson<String>(json['id']),
      organizationId: serializer.fromJson<String>(json['organizationId']),
      name: serializer.fromJson<String>(json['name']),
      timezone: serializer.fromJson<String>(json['timezone']),
      version: serializer.fromJson<int>(json['version']),
      serverUpdatedAt: serializer.fromJson<DateTime>(json['serverUpdatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'organizationId': serializer.toJson<String>(organizationId),
      'name': serializer.toJson<String>(name),
      'timezone': serializer.toJson<String>(timezone),
      'version': serializer.toJson<int>(version),
      'serverUpdatedAt': serializer.toJson<DateTime>(serverUpdatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  LocalFarm copyWith({
    String? id,
    String? organizationId,
    String? name,
    String? timezone,
    int? version,
    DateTime? serverUpdatedAt,
    bool? isDeleted,
  }) => LocalFarm(
    id: id ?? this.id,
    organizationId: organizationId ?? this.organizationId,
    name: name ?? this.name,
    timezone: timezone ?? this.timezone,
    version: version ?? this.version,
    serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  LocalFarm copyWithCompanion(LocalFarmsCompanion data) {
    return LocalFarm(
      id: data.id.present ? data.id.value : this.id,
      organizationId: data.organizationId.present
          ? data.organizationId.value
          : this.organizationId,
      name: data.name.present ? data.name.value : this.name,
      timezone: data.timezone.present ? data.timezone.value : this.timezone,
      version: data.version.present ? data.version.value : this.version,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalFarm(')
          ..write('id: $id, ')
          ..write('organizationId: $organizationId, ')
          ..write('name: $name, ')
          ..write('timezone: $timezone, ')
          ..write('version: $version, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    organizationId,
    name,
    timezone,
    version,
    serverUpdatedAt,
    isDeleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalFarm &&
          other.id == this.id &&
          other.organizationId == this.organizationId &&
          other.name == this.name &&
          other.timezone == this.timezone &&
          other.version == this.version &&
          other.serverUpdatedAt == this.serverUpdatedAt &&
          other.isDeleted == this.isDeleted);
}

class LocalFarmsCompanion extends UpdateCompanion<LocalFarm> {
  final Value<String> id;
  final Value<String> organizationId;
  final Value<String> name;
  final Value<String> timezone;
  final Value<int> version;
  final Value<DateTime> serverUpdatedAt;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const LocalFarmsCompanion({
    this.id = const Value.absent(),
    this.organizationId = const Value.absent(),
    this.name = const Value.absent(),
    this.timezone = const Value.absent(),
    this.version = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalFarmsCompanion.insert({
    required String id,
    required String organizationId,
    required String name,
    this.timezone = const Value.absent(),
    this.version = const Value.absent(),
    required DateTime serverUpdatedAt,
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       organizationId = Value(organizationId),
       name = Value(name),
       serverUpdatedAt = Value(serverUpdatedAt);
  static Insertable<LocalFarm> custom({
    Expression<String>? id,
    Expression<String>? organizationId,
    Expression<String>? name,
    Expression<String>? timezone,
    Expression<int>? version,
    Expression<DateTime>? serverUpdatedAt,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (organizationId != null) 'organization_id': organizationId,
      if (name != null) 'name': name,
      if (timezone != null) 'timezone': timezone,
      if (version != null) 'version': version,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalFarmsCompanion copyWith({
    Value<String>? id,
    Value<String>? organizationId,
    Value<String>? name,
    Value<String>? timezone,
    Value<int>? version,
    Value<DateTime>? serverUpdatedAt,
    Value<bool>? isDeleted,
    Value<int>? rowid,
  }) {
    return LocalFarmsCompanion(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      name: name ?? this.name,
      timezone: timezone ?? this.timezone,
      version: version ?? this.version,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (organizationId.present) {
      map['organization_id'] = Variable<String>(organizationId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (timezone.present) {
      map['timezone'] = Variable<String>(timezone.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<DateTime>(serverUpdatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalFarmsCompanion(')
          ..write('id: $id, ')
          ..write('organizationId: $organizationId, ')
          ..write('name: $name, ')
          ..write('timezone: $timezone, ')
          ..write('version: $version, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalShedsTable extends LocalSheds
    with TableInfo<$LocalShedsTable, LocalShed> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalShedsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _organizationIdMeta = const VerificationMeta(
    'organizationId',
  );
  @override
  late final GeneratedColumn<String> organizationId = GeneratedColumn<String>(
    'organization_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
    'farm_id',
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
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _serverUpdatedAtMeta = const VerificationMeta(
    'serverUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> serverUpdatedAt =
      GeneratedColumn<DateTime>(
        'server_updated_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    organizationId,
    farmId,
    name,
    version,
    serverUpdatedAt,
    isDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_sheds';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalShed> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('organization_id')) {
      context.handle(
        _organizationIdMeta,
        organizationId.isAcceptableOrUnknown(
          data['organization_id']!,
          _organizationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_organizationIdMeta);
    }
    if (data.containsKey('farm_id')) {
      context.handle(
        _farmIdMeta,
        farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_farmIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
        _serverUpdatedAtMeta,
        serverUpdatedAt.isAcceptableOrUnknown(
          data['server_updated_at']!,
          _serverUpdatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_serverUpdatedAtMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalShed map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalShed(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      organizationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}organization_id'],
      )!,
      farmId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}farm_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}server_updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $LocalShedsTable createAlias(String alias) {
    return $LocalShedsTable(attachedDatabase, alias);
  }
}

class LocalShed extends DataClass implements Insertable<LocalShed> {
  final String id;
  final String organizationId;
  final String farmId;
  final String name;
  final int version;
  final DateTime serverUpdatedAt;
  final bool isDeleted;
  const LocalShed({
    required this.id,
    required this.organizationId,
    required this.farmId,
    required this.name,
    required this.version,
    required this.serverUpdatedAt,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['organization_id'] = Variable<String>(organizationId);
    map['farm_id'] = Variable<String>(farmId);
    map['name'] = Variable<String>(name);
    map['version'] = Variable<int>(version);
    map['server_updated_at'] = Variable<DateTime>(serverUpdatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  LocalShedsCompanion toCompanion(bool nullToAbsent) {
    return LocalShedsCompanion(
      id: Value(id),
      organizationId: Value(organizationId),
      farmId: Value(farmId),
      name: Value(name),
      version: Value(version),
      serverUpdatedAt: Value(serverUpdatedAt),
      isDeleted: Value(isDeleted),
    );
  }

  factory LocalShed.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalShed(
      id: serializer.fromJson<String>(json['id']),
      organizationId: serializer.fromJson<String>(json['organizationId']),
      farmId: serializer.fromJson<String>(json['farmId']),
      name: serializer.fromJson<String>(json['name']),
      version: serializer.fromJson<int>(json['version']),
      serverUpdatedAt: serializer.fromJson<DateTime>(json['serverUpdatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'organizationId': serializer.toJson<String>(organizationId),
      'farmId': serializer.toJson<String>(farmId),
      'name': serializer.toJson<String>(name),
      'version': serializer.toJson<int>(version),
      'serverUpdatedAt': serializer.toJson<DateTime>(serverUpdatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  LocalShed copyWith({
    String? id,
    String? organizationId,
    String? farmId,
    String? name,
    int? version,
    DateTime? serverUpdatedAt,
    bool? isDeleted,
  }) => LocalShed(
    id: id ?? this.id,
    organizationId: organizationId ?? this.organizationId,
    farmId: farmId ?? this.farmId,
    name: name ?? this.name,
    version: version ?? this.version,
    serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  LocalShed copyWithCompanion(LocalShedsCompanion data) {
    return LocalShed(
      id: data.id.present ? data.id.value : this.id,
      organizationId: data.organizationId.present
          ? data.organizationId.value
          : this.organizationId,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      name: data.name.present ? data.name.value : this.name,
      version: data.version.present ? data.version.value : this.version,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalShed(')
          ..write('id: $id, ')
          ..write('organizationId: $organizationId, ')
          ..write('farmId: $farmId, ')
          ..write('name: $name, ')
          ..write('version: $version, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    organizationId,
    farmId,
    name,
    version,
    serverUpdatedAt,
    isDeleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalShed &&
          other.id == this.id &&
          other.organizationId == this.organizationId &&
          other.farmId == this.farmId &&
          other.name == this.name &&
          other.version == this.version &&
          other.serverUpdatedAt == this.serverUpdatedAt &&
          other.isDeleted == this.isDeleted);
}

class LocalShedsCompanion extends UpdateCompanion<LocalShed> {
  final Value<String> id;
  final Value<String> organizationId;
  final Value<String> farmId;
  final Value<String> name;
  final Value<int> version;
  final Value<DateTime> serverUpdatedAt;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const LocalShedsCompanion({
    this.id = const Value.absent(),
    this.organizationId = const Value.absent(),
    this.farmId = const Value.absent(),
    this.name = const Value.absent(),
    this.version = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalShedsCompanion.insert({
    required String id,
    required String organizationId,
    required String farmId,
    required String name,
    this.version = const Value.absent(),
    required DateTime serverUpdatedAt,
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       organizationId = Value(organizationId),
       farmId = Value(farmId),
       name = Value(name),
       serverUpdatedAt = Value(serverUpdatedAt);
  static Insertable<LocalShed> custom({
    Expression<String>? id,
    Expression<String>? organizationId,
    Expression<String>? farmId,
    Expression<String>? name,
    Expression<int>? version,
    Expression<DateTime>? serverUpdatedAt,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (organizationId != null) 'organization_id': organizationId,
      if (farmId != null) 'farm_id': farmId,
      if (name != null) 'name': name,
      if (version != null) 'version': version,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalShedsCompanion copyWith({
    Value<String>? id,
    Value<String>? organizationId,
    Value<String>? farmId,
    Value<String>? name,
    Value<int>? version,
    Value<DateTime>? serverUpdatedAt,
    Value<bool>? isDeleted,
    Value<int>? rowid,
  }) {
    return LocalShedsCompanion(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      farmId: farmId ?? this.farmId,
      name: name ?? this.name,
      version: version ?? this.version,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (organizationId.present) {
      map['organization_id'] = Variable<String>(organizationId.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<DateTime>(serverUpdatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalShedsCompanion(')
          ..write('id: $id, ')
          ..write('organizationId: $organizationId, ')
          ..write('farmId: $farmId, ')
          ..write('name: $name, ')
          ..write('version: $version, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncDevicesTable extends SyncDevices
    with TableInfo<$SyncDevicesTable, SyncDevice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncDevicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _registeredAtMeta = const VerificationMeta(
    'registeredAt',
  );
  @override
  late final GeneratedColumn<DateTime> registeredAt = GeneratedColumn<DateTime>(
    'registered_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSeenAtMeta = const VerificationMeta(
    'lastSeenAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSeenAt = GeneratedColumn<DateTime>(
    'last_seen_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, registeredAt, lastSeenAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_devices';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncDevice> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('registered_at')) {
      context.handle(
        _registeredAtMeta,
        registeredAt.isAcceptableOrUnknown(
          data['registered_at']!,
          _registeredAtMeta,
        ),
      );
    }
    if (data.containsKey('last_seen_at')) {
      context.handle(
        _lastSeenAtMeta,
        lastSeenAt.isAcceptableOrUnknown(
          data['last_seen_at']!,
          _lastSeenAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncDevice map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncDevice(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      registeredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}registered_at'],
      ),
      lastSeenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_seen_at'],
      ),
    );
  }

  @override
  $SyncDevicesTable createAlias(String alias) {
    return $SyncDevicesTable(attachedDatabase, alias);
  }
}

class SyncDevice extends DataClass implements Insertable<SyncDevice> {
  final String id;
  final String name;
  final DateTime? registeredAt;
  final DateTime? lastSeenAt;
  const SyncDevice({
    required this.id,
    required this.name,
    this.registeredAt,
    this.lastSeenAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || registeredAt != null) {
      map['registered_at'] = Variable<DateTime>(registeredAt);
    }
    if (!nullToAbsent || lastSeenAt != null) {
      map['last_seen_at'] = Variable<DateTime>(lastSeenAt);
    }
    return map;
  }

  SyncDevicesCompanion toCompanion(bool nullToAbsent) {
    return SyncDevicesCompanion(
      id: Value(id),
      name: Value(name),
      registeredAt: registeredAt == null && nullToAbsent
          ? const Value.absent()
          : Value(registeredAt),
      lastSeenAt: lastSeenAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSeenAt),
    );
  }

  factory SyncDevice.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncDevice(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      registeredAt: serializer.fromJson<DateTime?>(json['registeredAt']),
      lastSeenAt: serializer.fromJson<DateTime?>(json['lastSeenAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'registeredAt': serializer.toJson<DateTime?>(registeredAt),
      'lastSeenAt': serializer.toJson<DateTime?>(lastSeenAt),
    };
  }

  SyncDevice copyWith({
    String? id,
    String? name,
    Value<DateTime?> registeredAt = const Value.absent(),
    Value<DateTime?> lastSeenAt = const Value.absent(),
  }) => SyncDevice(
    id: id ?? this.id,
    name: name ?? this.name,
    registeredAt: registeredAt.present ? registeredAt.value : this.registeredAt,
    lastSeenAt: lastSeenAt.present ? lastSeenAt.value : this.lastSeenAt,
  );
  SyncDevice copyWithCompanion(SyncDevicesCompanion data) {
    return SyncDevice(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      registeredAt: data.registeredAt.present
          ? data.registeredAt.value
          : this.registeredAt,
      lastSeenAt: data.lastSeenAt.present
          ? data.lastSeenAt.value
          : this.lastSeenAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncDevice(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('registeredAt: $registeredAt, ')
          ..write('lastSeenAt: $lastSeenAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, registeredAt, lastSeenAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncDevice &&
          other.id == this.id &&
          other.name == this.name &&
          other.registeredAt == this.registeredAt &&
          other.lastSeenAt == this.lastSeenAt);
}

class SyncDevicesCompanion extends UpdateCompanion<SyncDevice> {
  final Value<String> id;
  final Value<String> name;
  final Value<DateTime?> registeredAt;
  final Value<DateTime?> lastSeenAt;
  final Value<int> rowid;
  const SyncDevicesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.registeredAt = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncDevicesCompanion.insert({
    required String id,
    required String name,
    this.registeredAt = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<SyncDevice> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<DateTime>? registeredAt,
    Expression<DateTime>? lastSeenAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (registeredAt != null) 'registered_at': registeredAt,
      if (lastSeenAt != null) 'last_seen_at': lastSeenAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncDevicesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<DateTime?>? registeredAt,
    Value<DateTime?>? lastSeenAt,
    Value<int>? rowid,
  }) {
    return SyncDevicesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      registeredAt: registeredAt ?? this.registeredAt,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (registeredAt.present) {
      map['registered_at'] = Variable<DateTime>(registeredAt.value);
    }
    if (lastSeenAt.present) {
      map['last_seen_at'] = Variable<DateTime>(lastSeenAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncDevicesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('registeredAt: $registeredAt, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncCursorsTable extends SyncCursors
    with TableInfo<$SyncCursorsTable, SyncCursor> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncCursorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _organizationIdMeta = const VerificationMeta(
    'organizationId',
  );
  @override
  late final GeneratedColumn<String> organizationId = GeneratedColumn<String>(
    'organization_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _collectionMeta = const VerificationMeta(
    'collection',
  );
  @override
  late final GeneratedColumn<String> collection = GeneratedColumn<String>(
    'collection',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cursorMeta = const VerificationMeta('cursor');
  @override
  late final GeneratedColumn<String> cursor = GeneratedColumn<String>(
    'cursor',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSuccessfulSyncAtMeta =
      const VerificationMeta('lastSuccessfulSyncAt');
  @override
  late final GeneratedColumn<DateTime> lastSuccessfulSyncAt =
      GeneratedColumn<DateTime>(
        'last_successful_sync_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    organizationId,
    collection,
    cursor,
    lastSuccessfulSyncAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_cursors';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncCursor> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('organization_id')) {
      context.handle(
        _organizationIdMeta,
        organizationId.isAcceptableOrUnknown(
          data['organization_id']!,
          _organizationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_organizationIdMeta);
    }
    if (data.containsKey('collection')) {
      context.handle(
        _collectionMeta,
        collection.isAcceptableOrUnknown(data['collection']!, _collectionMeta),
      );
    } else if (isInserting) {
      context.missing(_collectionMeta);
    }
    if (data.containsKey('cursor')) {
      context.handle(
        _cursorMeta,
        cursor.isAcceptableOrUnknown(data['cursor']!, _cursorMeta),
      );
    }
    if (data.containsKey('last_successful_sync_at')) {
      context.handle(
        _lastSuccessfulSyncAtMeta,
        lastSuccessfulSyncAt.isAcceptableOrUnknown(
          data['last_successful_sync_at']!,
          _lastSuccessfulSyncAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {organizationId, collection};
  @override
  SyncCursor map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncCursor(
      organizationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}organization_id'],
      )!,
      collection: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collection'],
      )!,
      cursor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cursor'],
      ),
      lastSuccessfulSyncAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_successful_sync_at'],
      ),
    );
  }

  @override
  $SyncCursorsTable createAlias(String alias) {
    return $SyncCursorsTable(attachedDatabase, alias);
  }
}

class SyncCursor extends DataClass implements Insertable<SyncCursor> {
  final String organizationId;
  final String collection;
  final String? cursor;
  final DateTime? lastSuccessfulSyncAt;
  const SyncCursor({
    required this.organizationId,
    required this.collection,
    this.cursor,
    this.lastSuccessfulSyncAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['organization_id'] = Variable<String>(organizationId);
    map['collection'] = Variable<String>(collection);
    if (!nullToAbsent || cursor != null) {
      map['cursor'] = Variable<String>(cursor);
    }
    if (!nullToAbsent || lastSuccessfulSyncAt != null) {
      map['last_successful_sync_at'] = Variable<DateTime>(lastSuccessfulSyncAt);
    }
    return map;
  }

  SyncCursorsCompanion toCompanion(bool nullToAbsent) {
    return SyncCursorsCompanion(
      organizationId: Value(organizationId),
      collection: Value(collection),
      cursor: cursor == null && nullToAbsent
          ? const Value.absent()
          : Value(cursor),
      lastSuccessfulSyncAt: lastSuccessfulSyncAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSuccessfulSyncAt),
    );
  }

  factory SyncCursor.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncCursor(
      organizationId: serializer.fromJson<String>(json['organizationId']),
      collection: serializer.fromJson<String>(json['collection']),
      cursor: serializer.fromJson<String?>(json['cursor']),
      lastSuccessfulSyncAt: serializer.fromJson<DateTime?>(
        json['lastSuccessfulSyncAt'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'organizationId': serializer.toJson<String>(organizationId),
      'collection': serializer.toJson<String>(collection),
      'cursor': serializer.toJson<String?>(cursor),
      'lastSuccessfulSyncAt': serializer.toJson<DateTime?>(
        lastSuccessfulSyncAt,
      ),
    };
  }

  SyncCursor copyWith({
    String? organizationId,
    String? collection,
    Value<String?> cursor = const Value.absent(),
    Value<DateTime?> lastSuccessfulSyncAt = const Value.absent(),
  }) => SyncCursor(
    organizationId: organizationId ?? this.organizationId,
    collection: collection ?? this.collection,
    cursor: cursor.present ? cursor.value : this.cursor,
    lastSuccessfulSyncAt: lastSuccessfulSyncAt.present
        ? lastSuccessfulSyncAt.value
        : this.lastSuccessfulSyncAt,
  );
  SyncCursor copyWithCompanion(SyncCursorsCompanion data) {
    return SyncCursor(
      organizationId: data.organizationId.present
          ? data.organizationId.value
          : this.organizationId,
      collection: data.collection.present
          ? data.collection.value
          : this.collection,
      cursor: data.cursor.present ? data.cursor.value : this.cursor,
      lastSuccessfulSyncAt: data.lastSuccessfulSyncAt.present
          ? data.lastSuccessfulSyncAt.value
          : this.lastSuccessfulSyncAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncCursor(')
          ..write('organizationId: $organizationId, ')
          ..write('collection: $collection, ')
          ..write('cursor: $cursor, ')
          ..write('lastSuccessfulSyncAt: $lastSuccessfulSyncAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(organizationId, collection, cursor, lastSuccessfulSyncAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncCursor &&
          other.organizationId == this.organizationId &&
          other.collection == this.collection &&
          other.cursor == this.cursor &&
          other.lastSuccessfulSyncAt == this.lastSuccessfulSyncAt);
}

class SyncCursorsCompanion extends UpdateCompanion<SyncCursor> {
  final Value<String> organizationId;
  final Value<String> collection;
  final Value<String?> cursor;
  final Value<DateTime?> lastSuccessfulSyncAt;
  final Value<int> rowid;
  const SyncCursorsCompanion({
    this.organizationId = const Value.absent(),
    this.collection = const Value.absent(),
    this.cursor = const Value.absent(),
    this.lastSuccessfulSyncAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncCursorsCompanion.insert({
    required String organizationId,
    required String collection,
    this.cursor = const Value.absent(),
    this.lastSuccessfulSyncAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : organizationId = Value(organizationId),
       collection = Value(collection);
  static Insertable<SyncCursor> custom({
    Expression<String>? organizationId,
    Expression<String>? collection,
    Expression<String>? cursor,
    Expression<DateTime>? lastSuccessfulSyncAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (organizationId != null) 'organization_id': organizationId,
      if (collection != null) 'collection': collection,
      if (cursor != null) 'cursor': cursor,
      if (lastSuccessfulSyncAt != null)
        'last_successful_sync_at': lastSuccessfulSyncAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncCursorsCompanion copyWith({
    Value<String>? organizationId,
    Value<String>? collection,
    Value<String?>? cursor,
    Value<DateTime?>? lastSuccessfulSyncAt,
    Value<int>? rowid,
  }) {
    return SyncCursorsCompanion(
      organizationId: organizationId ?? this.organizationId,
      collection: collection ?? this.collection,
      cursor: cursor ?? this.cursor,
      lastSuccessfulSyncAt: lastSuccessfulSyncAt ?? this.lastSuccessfulSyncAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (organizationId.present) {
      map['organization_id'] = Variable<String>(organizationId.value);
    }
    if (collection.present) {
      map['collection'] = Variable<String>(collection.value);
    }
    if (cursor.present) {
      map['cursor'] = Variable<String>(cursor.value);
    }
    if (lastSuccessfulSyncAt.present) {
      map['last_successful_sync_at'] = Variable<DateTime>(
        lastSuccessfulSyncAt.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncCursorsCompanion(')
          ..write('organizationId: $organizationId, ')
          ..write('collection: $collection, ')
          ..write('cursor: $cursor, ')
          ..write('lastSuccessfulSyncAt: $lastSuccessfulSyncAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncOutboxTable extends SyncOutbox
    with TableInfo<$SyncOutboxTable, SyncOutboxData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncOutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _organizationIdMeta = const VerificationMeta(
    'organizationId',
  );
  @override
  late final GeneratedColumn<String> organizationId = GeneratedColumn<String>(
    'organization_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
    'farm_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idempotencyKeyMeta = const VerificationMeta(
    'idempotencyKey',
  );
  @override
  late final GeneratedColumn<String> idempotencyKey = GeneratedColumn<String>(
    'idempotency_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _aggregateTypeMeta = const VerificationMeta(
    'aggregateType',
  );
  @override
  late final GeneratedColumn<String> aggregateType = GeneratedColumn<String>(
    'aggregate_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _aggregateIdMeta = const VerificationMeta(
    'aggregateId',
  );
  @override
  late final GeneratedColumn<String> aggregateId = GeneratedColumn<String>(
    'aggregate_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _methodMeta = const VerificationMeta('method');
  @override
  late final GeneratedColumn<String> method = GeneratedColumn<String>(
    'method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dependencyIdsJsonMeta = const VerificationMeta(
    'dependencyIdsJson',
  );
  @override
  late final GeneratedColumn<String> dependencyIdsJson =
      GeneratedColumn<String>(
        'dependency_ids_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _nextAttemptAtMeta = const VerificationMeta(
    'nextAttemptAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextAttemptAt =
      GeneratedColumn<DateTime>(
        'next_attempt_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    organizationId,
    farmId,
    deviceId,
    idempotencyKey,
    aggregateType,
    aggregateId,
    method,
    path,
    payloadJson,
    dependencyIdsJson,
    state,
    retryCount,
    nextAttemptAt,
    lastError,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_outbox';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncOutboxData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('organization_id')) {
      context.handle(
        _organizationIdMeta,
        organizationId.isAcceptableOrUnknown(
          data['organization_id']!,
          _organizationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_organizationIdMeta);
    }
    if (data.containsKey('farm_id')) {
      context.handle(
        _farmIdMeta,
        farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('idempotency_key')) {
      context.handle(
        _idempotencyKeyMeta,
        idempotencyKey.isAcceptableOrUnknown(
          data['idempotency_key']!,
          _idempotencyKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_idempotencyKeyMeta);
    }
    if (data.containsKey('aggregate_type')) {
      context.handle(
        _aggregateTypeMeta,
        aggregateType.isAcceptableOrUnknown(
          data['aggregate_type']!,
          _aggregateTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_aggregateTypeMeta);
    }
    if (data.containsKey('aggregate_id')) {
      context.handle(
        _aggregateIdMeta,
        aggregateId.isAcceptableOrUnknown(
          data['aggregate_id']!,
          _aggregateIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_aggregateIdMeta);
    }
    if (data.containsKey('method')) {
      context.handle(
        _methodMeta,
        method.isAcceptableOrUnknown(data['method']!, _methodMeta),
      );
    } else if (isInserting) {
      context.missing(_methodMeta);
    }
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('dependency_ids_json')) {
      context.handle(
        _dependencyIdsJsonMeta,
        dependencyIdsJson.isAcceptableOrUnknown(
          data['dependency_ids_json']!,
          _dependencyIdsJsonMeta,
        ),
      );
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    if (data.containsKey('next_attempt_at')) {
      context.handle(
        _nextAttemptAtMeta,
        nextAttemptAt.isAcceptableOrUnknown(
          data['next_attempt_at']!,
          _nextAttemptAtMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
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
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {organizationId, deviceId, idempotencyKey},
  ];
  @override
  SyncOutboxData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncOutboxData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      organizationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}organization_id'],
      )!,
      farmId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}farm_id'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      idempotencyKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}idempotency_key'],
      )!,
      aggregateType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}aggregate_type'],
      )!,
      aggregateId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}aggregate_id'],
      )!,
      method: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}method'],
      )!,
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      dependencyIdsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dependency_ids_json'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
      nextAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_attempt_at'],
      ),
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SyncOutboxTable createAlias(String alias) {
    return $SyncOutboxTable(attachedDatabase, alias);
  }
}

class SyncOutboxData extends DataClass implements Insertable<SyncOutboxData> {
  final String id;
  final String organizationId;
  final String? farmId;
  final String deviceId;
  final String idempotencyKey;
  final String aggregateType;
  final String aggregateId;
  final String method;
  final String path;
  final String payloadJson;
  final String dependencyIdsJson;
  final String state;
  final int retryCount;
  final DateTime? nextAttemptAt;
  final String? lastError;
  final DateTime createdAt;
  final DateTime updatedAt;
  const SyncOutboxData({
    required this.id,
    required this.organizationId,
    this.farmId,
    required this.deviceId,
    required this.idempotencyKey,
    required this.aggregateType,
    required this.aggregateId,
    required this.method,
    required this.path,
    required this.payloadJson,
    required this.dependencyIdsJson,
    required this.state,
    required this.retryCount,
    this.nextAttemptAt,
    this.lastError,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['organization_id'] = Variable<String>(organizationId);
    if (!nullToAbsent || farmId != null) {
      map['farm_id'] = Variable<String>(farmId);
    }
    map['device_id'] = Variable<String>(deviceId);
    map['idempotency_key'] = Variable<String>(idempotencyKey);
    map['aggregate_type'] = Variable<String>(aggregateType);
    map['aggregate_id'] = Variable<String>(aggregateId);
    map['method'] = Variable<String>(method);
    map['path'] = Variable<String>(path);
    map['payload_json'] = Variable<String>(payloadJson);
    map['dependency_ids_json'] = Variable<String>(dependencyIdsJson);
    map['state'] = Variable<String>(state);
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || nextAttemptAt != null) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SyncOutboxCompanion toCompanion(bool nullToAbsent) {
    return SyncOutboxCompanion(
      id: Value(id),
      organizationId: Value(organizationId),
      farmId: farmId == null && nullToAbsent
          ? const Value.absent()
          : Value(farmId),
      deviceId: Value(deviceId),
      idempotencyKey: Value(idempotencyKey),
      aggregateType: Value(aggregateType),
      aggregateId: Value(aggregateId),
      method: Value(method),
      path: Value(path),
      payloadJson: Value(payloadJson),
      dependencyIdsJson: Value(dependencyIdsJson),
      state: Value(state),
      retryCount: Value(retryCount),
      nextAttemptAt: nextAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextAttemptAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SyncOutboxData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncOutboxData(
      id: serializer.fromJson<String>(json['id']),
      organizationId: serializer.fromJson<String>(json['organizationId']),
      farmId: serializer.fromJson<String?>(json['farmId']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      idempotencyKey: serializer.fromJson<String>(json['idempotencyKey']),
      aggregateType: serializer.fromJson<String>(json['aggregateType']),
      aggregateId: serializer.fromJson<String>(json['aggregateId']),
      method: serializer.fromJson<String>(json['method']),
      path: serializer.fromJson<String>(json['path']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      dependencyIdsJson: serializer.fromJson<String>(json['dependencyIdsJson']),
      state: serializer.fromJson<String>(json['state']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      nextAttemptAt: serializer.fromJson<DateTime?>(json['nextAttemptAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'organizationId': serializer.toJson<String>(organizationId),
      'farmId': serializer.toJson<String?>(farmId),
      'deviceId': serializer.toJson<String>(deviceId),
      'idempotencyKey': serializer.toJson<String>(idempotencyKey),
      'aggregateType': serializer.toJson<String>(aggregateType),
      'aggregateId': serializer.toJson<String>(aggregateId),
      'method': serializer.toJson<String>(method),
      'path': serializer.toJson<String>(path),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'dependencyIdsJson': serializer.toJson<String>(dependencyIdsJson),
      'state': serializer.toJson<String>(state),
      'retryCount': serializer.toJson<int>(retryCount),
      'nextAttemptAt': serializer.toJson<DateTime?>(nextAttemptAt),
      'lastError': serializer.toJson<String?>(lastError),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SyncOutboxData copyWith({
    String? id,
    String? organizationId,
    Value<String?> farmId = const Value.absent(),
    String? deviceId,
    String? idempotencyKey,
    String? aggregateType,
    String? aggregateId,
    String? method,
    String? path,
    String? payloadJson,
    String? dependencyIdsJson,
    String? state,
    int? retryCount,
    Value<DateTime?> nextAttemptAt = const Value.absent(),
    Value<String?> lastError = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => SyncOutboxData(
    id: id ?? this.id,
    organizationId: organizationId ?? this.organizationId,
    farmId: farmId.present ? farmId.value : this.farmId,
    deviceId: deviceId ?? this.deviceId,
    idempotencyKey: idempotencyKey ?? this.idempotencyKey,
    aggregateType: aggregateType ?? this.aggregateType,
    aggregateId: aggregateId ?? this.aggregateId,
    method: method ?? this.method,
    path: path ?? this.path,
    payloadJson: payloadJson ?? this.payloadJson,
    dependencyIdsJson: dependencyIdsJson ?? this.dependencyIdsJson,
    state: state ?? this.state,
    retryCount: retryCount ?? this.retryCount,
    nextAttemptAt: nextAttemptAt.present
        ? nextAttemptAt.value
        : this.nextAttemptAt,
    lastError: lastError.present ? lastError.value : this.lastError,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SyncOutboxData copyWithCompanion(SyncOutboxCompanion data) {
    return SyncOutboxData(
      id: data.id.present ? data.id.value : this.id,
      organizationId: data.organizationId.present
          ? data.organizationId.value
          : this.organizationId,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      idempotencyKey: data.idempotencyKey.present
          ? data.idempotencyKey.value
          : this.idempotencyKey,
      aggregateType: data.aggregateType.present
          ? data.aggregateType.value
          : this.aggregateType,
      aggregateId: data.aggregateId.present
          ? data.aggregateId.value
          : this.aggregateId,
      method: data.method.present ? data.method.value : this.method,
      path: data.path.present ? data.path.value : this.path,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      dependencyIdsJson: data.dependencyIdsJson.present
          ? data.dependencyIdsJson.value
          : this.dependencyIdsJson,
      state: data.state.present ? data.state.value : this.state,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
      nextAttemptAt: data.nextAttemptAt.present
          ? data.nextAttemptAt.value
          : this.nextAttemptAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxData(')
          ..write('id: $id, ')
          ..write('organizationId: $organizationId, ')
          ..write('farmId: $farmId, ')
          ..write('deviceId: $deviceId, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('aggregateType: $aggregateType, ')
          ..write('aggregateId: $aggregateId, ')
          ..write('method: $method, ')
          ..write('path: $path, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('dependencyIdsJson: $dependencyIdsJson, ')
          ..write('state: $state, ')
          ..write('retryCount: $retryCount, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    organizationId,
    farmId,
    deviceId,
    idempotencyKey,
    aggregateType,
    aggregateId,
    method,
    path,
    payloadJson,
    dependencyIdsJson,
    state,
    retryCount,
    nextAttemptAt,
    lastError,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncOutboxData &&
          other.id == this.id &&
          other.organizationId == this.organizationId &&
          other.farmId == this.farmId &&
          other.deviceId == this.deviceId &&
          other.idempotencyKey == this.idempotencyKey &&
          other.aggregateType == this.aggregateType &&
          other.aggregateId == this.aggregateId &&
          other.method == this.method &&
          other.path == this.path &&
          other.payloadJson == this.payloadJson &&
          other.dependencyIdsJson == this.dependencyIdsJson &&
          other.state == this.state &&
          other.retryCount == this.retryCount &&
          other.nextAttemptAt == this.nextAttemptAt &&
          other.lastError == this.lastError &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SyncOutboxCompanion extends UpdateCompanion<SyncOutboxData> {
  final Value<String> id;
  final Value<String> organizationId;
  final Value<String?> farmId;
  final Value<String> deviceId;
  final Value<String> idempotencyKey;
  final Value<String> aggregateType;
  final Value<String> aggregateId;
  final Value<String> method;
  final Value<String> path;
  final Value<String> payloadJson;
  final Value<String> dependencyIdsJson;
  final Value<String> state;
  final Value<int> retryCount;
  final Value<DateTime?> nextAttemptAt;
  final Value<String?> lastError;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SyncOutboxCompanion({
    this.id = const Value.absent(),
    this.organizationId = const Value.absent(),
    this.farmId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
    this.aggregateType = const Value.absent(),
    this.aggregateId = const Value.absent(),
    this.method = const Value.absent(),
    this.path = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.dependencyIdsJson = const Value.absent(),
    this.state = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncOutboxCompanion.insert({
    required String id,
    required String organizationId,
    this.farmId = const Value.absent(),
    required String deviceId,
    required String idempotencyKey,
    required String aggregateType,
    required String aggregateId,
    required String method,
    required String path,
    required String payloadJson,
    this.dependencyIdsJson = const Value.absent(),
    this.state = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.lastError = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       organizationId = Value(organizationId),
       deviceId = Value(deviceId),
       idempotencyKey = Value(idempotencyKey),
       aggregateType = Value(aggregateType),
       aggregateId = Value(aggregateId),
       method = Value(method),
       path = Value(path),
       payloadJson = Value(payloadJson),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<SyncOutboxData> custom({
    Expression<String>? id,
    Expression<String>? organizationId,
    Expression<String>? farmId,
    Expression<String>? deviceId,
    Expression<String>? idempotencyKey,
    Expression<String>? aggregateType,
    Expression<String>? aggregateId,
    Expression<String>? method,
    Expression<String>? path,
    Expression<String>? payloadJson,
    Expression<String>? dependencyIdsJson,
    Expression<String>? state,
    Expression<int>? retryCount,
    Expression<DateTime>? nextAttemptAt,
    Expression<String>? lastError,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (organizationId != null) 'organization_id': organizationId,
      if (farmId != null) 'farm_id': farmId,
      if (deviceId != null) 'device_id': deviceId,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      if (aggregateType != null) 'aggregate_type': aggregateType,
      if (aggregateId != null) 'aggregate_id': aggregateId,
      if (method != null) 'method': method,
      if (path != null) 'path': path,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (dependencyIdsJson != null) 'dependency_ids_json': dependencyIdsJson,
      if (state != null) 'state': state,
      if (retryCount != null) 'retry_count': retryCount,
      if (nextAttemptAt != null) 'next_attempt_at': nextAttemptAt,
      if (lastError != null) 'last_error': lastError,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncOutboxCompanion copyWith({
    Value<String>? id,
    Value<String>? organizationId,
    Value<String?>? farmId,
    Value<String>? deviceId,
    Value<String>? idempotencyKey,
    Value<String>? aggregateType,
    Value<String>? aggregateId,
    Value<String>? method,
    Value<String>? path,
    Value<String>? payloadJson,
    Value<String>? dependencyIdsJson,
    Value<String>? state,
    Value<int>? retryCount,
    Value<DateTime?>? nextAttemptAt,
    Value<String?>? lastError,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SyncOutboxCompanion(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      farmId: farmId ?? this.farmId,
      deviceId: deviceId ?? this.deviceId,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      aggregateType: aggregateType ?? this.aggregateType,
      aggregateId: aggregateId ?? this.aggregateId,
      method: method ?? this.method,
      path: path ?? this.path,
      payloadJson: payloadJson ?? this.payloadJson,
      dependencyIdsJson: dependencyIdsJson ?? this.dependencyIdsJson,
      state: state ?? this.state,
      retryCount: retryCount ?? this.retryCount,
      nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
      lastError: lastError ?? this.lastError,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (organizationId.present) {
      map['organization_id'] = Variable<String>(organizationId.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (idempotencyKey.present) {
      map['idempotency_key'] = Variable<String>(idempotencyKey.value);
    }
    if (aggregateType.present) {
      map['aggregate_type'] = Variable<String>(aggregateType.value);
    }
    if (aggregateId.present) {
      map['aggregate_id'] = Variable<String>(aggregateId.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(method.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (dependencyIdsJson.present) {
      map['dependency_ids_json'] = Variable<String>(dependencyIdsJson.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (nextAttemptAt.present) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxCompanion(')
          ..write('id: $id, ')
          ..write('organizationId: $organizationId, ')
          ..write('farmId: $farmId, ')
          ..write('deviceId: $deviceId, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('aggregateType: $aggregateType, ')
          ..write('aggregateId: $aggregateId, ')
          ..write('method: $method, ')
          ..write('path: $path, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('dependencyIdsJson: $dependencyIdsJson, ')
          ..write('state: $state, ')
          ..write('retryCount: $retryCount, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncConflictsTable extends SyncConflicts
    with TableInfo<$SyncConflictsTable, SyncConflict> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncConflictsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationIdMeta = const VerificationMeta(
    'operationId',
  );
  @override
  late final GeneratedColumn<String> operationId = GeneratedColumn<String>(
    'operation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _aggregateTypeMeta = const VerificationMeta(
    'aggregateType',
  );
  @override
  late final GeneratedColumn<String> aggregateType = GeneratedColumn<String>(
    'aggregate_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _aggregateIdMeta = const VerificationMeta(
    'aggregateId',
  );
  @override
  late final GeneratedColumn<String> aggregateId = GeneratedColumn<String>(
    'aggregate_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localPayloadJsonMeta = const VerificationMeta(
    'localPayloadJson',
  );
  @override
  late final GeneratedColumn<String> localPayloadJson = GeneratedColumn<String>(
    'local_payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverPayloadJsonMeta = const VerificationMeta(
    'serverPayloadJson',
  );
  @override
  late final GeneratedColumn<String> serverPayloadJson =
      GeneratedColumn<String>(
        'server_payload_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resolutionStateMeta = const VerificationMeta(
    'resolutionState',
  );
  @override
  late final GeneratedColumn<String> resolutionState = GeneratedColumn<String>(
    'resolution_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('unresolved'),
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
  static const VerificationMeta _resolvedAtMeta = const VerificationMeta(
    'resolvedAt',
  );
  @override
  late final GeneratedColumn<DateTime> resolvedAt = GeneratedColumn<DateTime>(
    'resolved_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    operationId,
    aggregateType,
    aggregateId,
    localPayloadJson,
    serverPayloadJson,
    reason,
    resolutionState,
    createdAt,
    resolvedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_conflicts';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncConflict> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('operation_id')) {
      context.handle(
        _operationIdMeta,
        operationId.isAcceptableOrUnknown(
          data['operation_id']!,
          _operationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_operationIdMeta);
    }
    if (data.containsKey('aggregate_type')) {
      context.handle(
        _aggregateTypeMeta,
        aggregateType.isAcceptableOrUnknown(
          data['aggregate_type']!,
          _aggregateTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_aggregateTypeMeta);
    }
    if (data.containsKey('aggregate_id')) {
      context.handle(
        _aggregateIdMeta,
        aggregateId.isAcceptableOrUnknown(
          data['aggregate_id']!,
          _aggregateIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_aggregateIdMeta);
    }
    if (data.containsKey('local_payload_json')) {
      context.handle(
        _localPayloadJsonMeta,
        localPayloadJson.isAcceptableOrUnknown(
          data['local_payload_json']!,
          _localPayloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localPayloadJsonMeta);
    }
    if (data.containsKey('server_payload_json')) {
      context.handle(
        _serverPayloadJsonMeta,
        serverPayloadJson.isAcceptableOrUnknown(
          data['server_payload_json']!,
          _serverPayloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_serverPayloadJsonMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('resolution_state')) {
      context.handle(
        _resolutionStateMeta,
        resolutionState.isAcceptableOrUnknown(
          data['resolution_state']!,
          _resolutionStateMeta,
        ),
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
    if (data.containsKey('resolved_at')) {
      context.handle(
        _resolvedAtMeta,
        resolvedAt.isAcceptableOrUnknown(data['resolved_at']!, _resolvedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncConflict map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncConflict(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      operationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation_id'],
      )!,
      aggregateType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}aggregate_type'],
      )!,
      aggregateId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}aggregate_id'],
      )!,
      localPayloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_payload_json'],
      )!,
      serverPayloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_payload_json'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
      resolutionState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resolution_state'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      resolvedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}resolved_at'],
      ),
    );
  }

  @override
  $SyncConflictsTable createAlias(String alias) {
    return $SyncConflictsTable(attachedDatabase, alias);
  }
}

class SyncConflict extends DataClass implements Insertable<SyncConflict> {
  final String id;
  final String operationId;
  final String aggregateType;
  final String aggregateId;
  final String localPayloadJson;
  final String serverPayloadJson;
  final String reason;
  final String resolutionState;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  const SyncConflict({
    required this.id,
    required this.operationId,
    required this.aggregateType,
    required this.aggregateId,
    required this.localPayloadJson,
    required this.serverPayloadJson,
    required this.reason,
    required this.resolutionState,
    required this.createdAt,
    this.resolvedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['operation_id'] = Variable<String>(operationId);
    map['aggregate_type'] = Variable<String>(aggregateType);
    map['aggregate_id'] = Variable<String>(aggregateId);
    map['local_payload_json'] = Variable<String>(localPayloadJson);
    map['server_payload_json'] = Variable<String>(serverPayloadJson);
    map['reason'] = Variable<String>(reason);
    map['resolution_state'] = Variable<String>(resolutionState);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || resolvedAt != null) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt);
    }
    return map;
  }

  SyncConflictsCompanion toCompanion(bool nullToAbsent) {
    return SyncConflictsCompanion(
      id: Value(id),
      operationId: Value(operationId),
      aggregateType: Value(aggregateType),
      aggregateId: Value(aggregateId),
      localPayloadJson: Value(localPayloadJson),
      serverPayloadJson: Value(serverPayloadJson),
      reason: Value(reason),
      resolutionState: Value(resolutionState),
      createdAt: Value(createdAt),
      resolvedAt: resolvedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(resolvedAt),
    );
  }

  factory SyncConflict.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncConflict(
      id: serializer.fromJson<String>(json['id']),
      operationId: serializer.fromJson<String>(json['operationId']),
      aggregateType: serializer.fromJson<String>(json['aggregateType']),
      aggregateId: serializer.fromJson<String>(json['aggregateId']),
      localPayloadJson: serializer.fromJson<String>(json['localPayloadJson']),
      serverPayloadJson: serializer.fromJson<String>(json['serverPayloadJson']),
      reason: serializer.fromJson<String>(json['reason']),
      resolutionState: serializer.fromJson<String>(json['resolutionState']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      resolvedAt: serializer.fromJson<DateTime?>(json['resolvedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'operationId': serializer.toJson<String>(operationId),
      'aggregateType': serializer.toJson<String>(aggregateType),
      'aggregateId': serializer.toJson<String>(aggregateId),
      'localPayloadJson': serializer.toJson<String>(localPayloadJson),
      'serverPayloadJson': serializer.toJson<String>(serverPayloadJson),
      'reason': serializer.toJson<String>(reason),
      'resolutionState': serializer.toJson<String>(resolutionState),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'resolvedAt': serializer.toJson<DateTime?>(resolvedAt),
    };
  }

  SyncConflict copyWith({
    String? id,
    String? operationId,
    String? aggregateType,
    String? aggregateId,
    String? localPayloadJson,
    String? serverPayloadJson,
    String? reason,
    String? resolutionState,
    DateTime? createdAt,
    Value<DateTime?> resolvedAt = const Value.absent(),
  }) => SyncConflict(
    id: id ?? this.id,
    operationId: operationId ?? this.operationId,
    aggregateType: aggregateType ?? this.aggregateType,
    aggregateId: aggregateId ?? this.aggregateId,
    localPayloadJson: localPayloadJson ?? this.localPayloadJson,
    serverPayloadJson: serverPayloadJson ?? this.serverPayloadJson,
    reason: reason ?? this.reason,
    resolutionState: resolutionState ?? this.resolutionState,
    createdAt: createdAt ?? this.createdAt,
    resolvedAt: resolvedAt.present ? resolvedAt.value : this.resolvedAt,
  );
  SyncConflict copyWithCompanion(SyncConflictsCompanion data) {
    return SyncConflict(
      id: data.id.present ? data.id.value : this.id,
      operationId: data.operationId.present
          ? data.operationId.value
          : this.operationId,
      aggregateType: data.aggregateType.present
          ? data.aggregateType.value
          : this.aggregateType,
      aggregateId: data.aggregateId.present
          ? data.aggregateId.value
          : this.aggregateId,
      localPayloadJson: data.localPayloadJson.present
          ? data.localPayloadJson.value
          : this.localPayloadJson,
      serverPayloadJson: data.serverPayloadJson.present
          ? data.serverPayloadJson.value
          : this.serverPayloadJson,
      reason: data.reason.present ? data.reason.value : this.reason,
      resolutionState: data.resolutionState.present
          ? data.resolutionState.value
          : this.resolutionState,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      resolvedAt: data.resolvedAt.present
          ? data.resolvedAt.value
          : this.resolvedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncConflict(')
          ..write('id: $id, ')
          ..write('operationId: $operationId, ')
          ..write('aggregateType: $aggregateType, ')
          ..write('aggregateId: $aggregateId, ')
          ..write('localPayloadJson: $localPayloadJson, ')
          ..write('serverPayloadJson: $serverPayloadJson, ')
          ..write('reason: $reason, ')
          ..write('resolutionState: $resolutionState, ')
          ..write('createdAt: $createdAt, ')
          ..write('resolvedAt: $resolvedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    operationId,
    aggregateType,
    aggregateId,
    localPayloadJson,
    serverPayloadJson,
    reason,
    resolutionState,
    createdAt,
    resolvedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncConflict &&
          other.id == this.id &&
          other.operationId == this.operationId &&
          other.aggregateType == this.aggregateType &&
          other.aggregateId == this.aggregateId &&
          other.localPayloadJson == this.localPayloadJson &&
          other.serverPayloadJson == this.serverPayloadJson &&
          other.reason == this.reason &&
          other.resolutionState == this.resolutionState &&
          other.createdAt == this.createdAt &&
          other.resolvedAt == this.resolvedAt);
}

class SyncConflictsCompanion extends UpdateCompanion<SyncConflict> {
  final Value<String> id;
  final Value<String> operationId;
  final Value<String> aggregateType;
  final Value<String> aggregateId;
  final Value<String> localPayloadJson;
  final Value<String> serverPayloadJson;
  final Value<String> reason;
  final Value<String> resolutionState;
  final Value<DateTime> createdAt;
  final Value<DateTime?> resolvedAt;
  final Value<int> rowid;
  const SyncConflictsCompanion({
    this.id = const Value.absent(),
    this.operationId = const Value.absent(),
    this.aggregateType = const Value.absent(),
    this.aggregateId = const Value.absent(),
    this.localPayloadJson = const Value.absent(),
    this.serverPayloadJson = const Value.absent(),
    this.reason = const Value.absent(),
    this.resolutionState = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.resolvedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncConflictsCompanion.insert({
    required String id,
    required String operationId,
    required String aggregateType,
    required String aggregateId,
    required String localPayloadJson,
    required String serverPayloadJson,
    required String reason,
    this.resolutionState = const Value.absent(),
    required DateTime createdAt,
    this.resolvedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       operationId = Value(operationId),
       aggregateType = Value(aggregateType),
       aggregateId = Value(aggregateId),
       localPayloadJson = Value(localPayloadJson),
       serverPayloadJson = Value(serverPayloadJson),
       reason = Value(reason),
       createdAt = Value(createdAt);
  static Insertable<SyncConflict> custom({
    Expression<String>? id,
    Expression<String>? operationId,
    Expression<String>? aggregateType,
    Expression<String>? aggregateId,
    Expression<String>? localPayloadJson,
    Expression<String>? serverPayloadJson,
    Expression<String>? reason,
    Expression<String>? resolutionState,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? resolvedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (operationId != null) 'operation_id': operationId,
      if (aggregateType != null) 'aggregate_type': aggregateType,
      if (aggregateId != null) 'aggregate_id': aggregateId,
      if (localPayloadJson != null) 'local_payload_json': localPayloadJson,
      if (serverPayloadJson != null) 'server_payload_json': serverPayloadJson,
      if (reason != null) 'reason': reason,
      if (resolutionState != null) 'resolution_state': resolutionState,
      if (createdAt != null) 'created_at': createdAt,
      if (resolvedAt != null) 'resolved_at': resolvedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncConflictsCompanion copyWith({
    Value<String>? id,
    Value<String>? operationId,
    Value<String>? aggregateType,
    Value<String>? aggregateId,
    Value<String>? localPayloadJson,
    Value<String>? serverPayloadJson,
    Value<String>? reason,
    Value<String>? resolutionState,
    Value<DateTime>? createdAt,
    Value<DateTime?>? resolvedAt,
    Value<int>? rowid,
  }) {
    return SyncConflictsCompanion(
      id: id ?? this.id,
      operationId: operationId ?? this.operationId,
      aggregateType: aggregateType ?? this.aggregateType,
      aggregateId: aggregateId ?? this.aggregateId,
      localPayloadJson: localPayloadJson ?? this.localPayloadJson,
      serverPayloadJson: serverPayloadJson ?? this.serverPayloadJson,
      reason: reason ?? this.reason,
      resolutionState: resolutionState ?? this.resolutionState,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (operationId.present) {
      map['operation_id'] = Variable<String>(operationId.value);
    }
    if (aggregateType.present) {
      map['aggregate_type'] = Variable<String>(aggregateType.value);
    }
    if (aggregateId.present) {
      map['aggregate_id'] = Variable<String>(aggregateId.value);
    }
    if (localPayloadJson.present) {
      map['local_payload_json'] = Variable<String>(localPayloadJson.value);
    }
    if (serverPayloadJson.present) {
      map['server_payload_json'] = Variable<String>(serverPayloadJson.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (resolutionState.present) {
      map['resolution_state'] = Variable<String>(resolutionState.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (resolvedAt.present) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncConflictsCompanion(')
          ..write('id: $id, ')
          ..write('operationId: $operationId, ')
          ..write('aggregateType: $aggregateType, ')
          ..write('aggregateId: $aggregateId, ')
          ..write('localPayloadJson: $localPayloadJson, ')
          ..write('serverPayloadJson: $serverPayloadJson, ')
          ..write('reason: $reason, ')
          ..write('resolutionState: $resolutionState, ')
          ..write('createdAt: $createdAt, ')
          ..write('resolvedAt: $resolvedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalApplicationSettingsTable extends LocalApplicationSettings
    with TableInfo<$LocalApplicationSettingsTable, LocalApplicationSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalApplicationSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_application_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalApplicationSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  LocalApplicationSetting map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalApplicationSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LocalApplicationSettingsTable createAlias(String alias) {
    return $LocalApplicationSettingsTable(attachedDatabase, alias);
  }
}

class LocalApplicationSetting extends DataClass
    implements Insertable<LocalApplicationSetting> {
  final String key;
  final String value;
  final DateTime updatedAt;
  const LocalApplicationSetting({
    required this.key,
    required this.value,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalApplicationSettingsCompanion toCompanion(bool nullToAbsent) {
    return LocalApplicationSettingsCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalApplicationSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalApplicationSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalApplicationSetting copyWith({
    String? key,
    String? value,
    DateTime? updatedAt,
  }) => LocalApplicationSetting(
    key: key ?? this.key,
    value: value ?? this.value,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalApplicationSetting copyWithCompanion(
    LocalApplicationSettingsCompanion data,
  ) {
    return LocalApplicationSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalApplicationSetting(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalApplicationSetting &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class LocalApplicationSettingsCompanion
    extends UpdateCompanion<LocalApplicationSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalApplicationSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalApplicationSettingsCompanion.insert({
    required String key,
    required String value,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value),
       updatedAt = Value(updatedAt);
  static Insertable<LocalApplicationSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalApplicationSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalApplicationSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalApplicationSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalSessionMetadataTable localSessionMetadata =
      $LocalSessionMetadataTable(this);
  late final $LocalOrganizationsTable localOrganizations =
      $LocalOrganizationsTable(this);
  late final $LocalFarmsTable localFarms = $LocalFarmsTable(this);
  late final $LocalShedsTable localSheds = $LocalShedsTable(this);
  late final $SyncDevicesTable syncDevices = $SyncDevicesTable(this);
  late final $SyncCursorsTable syncCursors = $SyncCursorsTable(this);
  late final $SyncOutboxTable syncOutbox = $SyncOutboxTable(this);
  late final $SyncConflictsTable syncConflicts = $SyncConflictsTable(this);
  late final $LocalApplicationSettingsTable localApplicationSettings =
      $LocalApplicationSettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    localSessionMetadata,
    localOrganizations,
    localFarms,
    localSheds,
    syncDevices,
    syncCursors,
    syncOutbox,
    syncConflicts,
    localApplicationSettings,
  ];
}

typedef $$LocalSessionMetadataTableCreateCompanionBuilder =
    LocalSessionMetadataCompanion Function({
      required String id,
      required String userId,
      Value<String?> activeOrganizationId,
      Value<String?> activeFarmId,
      Value<DateTime?> accessExpiresAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$LocalSessionMetadataTableUpdateCompanionBuilder =
    LocalSessionMetadataCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String?> activeOrganizationId,
      Value<String?> activeFarmId,
      Value<DateTime?> accessExpiresAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$LocalSessionMetadataTableFilterComposer
    extends Composer<_$AppDatabase, $LocalSessionMetadataTable> {
  $$LocalSessionMetadataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activeOrganizationId => $composableBuilder(
    column: $table.activeOrganizationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activeFarmId => $composableBuilder(
    column: $table.activeFarmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get accessExpiresAt => $composableBuilder(
    column: $table.accessExpiresAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalSessionMetadataTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalSessionMetadataTable> {
  $$LocalSessionMetadataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activeOrganizationId => $composableBuilder(
    column: $table.activeOrganizationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activeFarmId => $composableBuilder(
    column: $table.activeFarmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get accessExpiresAt => $composableBuilder(
    column: $table.accessExpiresAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalSessionMetadataTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalSessionMetadataTable> {
  $$LocalSessionMetadataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get activeOrganizationId => $composableBuilder(
    column: $table.activeOrganizationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get activeFarmId => $composableBuilder(
    column: $table.activeFarmId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get accessExpiresAt => $composableBuilder(
    column: $table.accessExpiresAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalSessionMetadataTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalSessionMetadataTable,
          LocalSessionMetadataData,
          $$LocalSessionMetadataTableFilterComposer,
          $$LocalSessionMetadataTableOrderingComposer,
          $$LocalSessionMetadataTableAnnotationComposer,
          $$LocalSessionMetadataTableCreateCompanionBuilder,
          $$LocalSessionMetadataTableUpdateCompanionBuilder,
          (
            LocalSessionMetadataData,
            BaseReferences<
              _$AppDatabase,
              $LocalSessionMetadataTable,
              LocalSessionMetadataData
            >,
          ),
          LocalSessionMetadataData,
          PrefetchHooks Function()
        > {
  $$LocalSessionMetadataTableTableManager(
    _$AppDatabase db,
    $LocalSessionMetadataTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalSessionMetadataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalSessionMetadataTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalSessionMetadataTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String?> activeOrganizationId = const Value.absent(),
                Value<String?> activeFarmId = const Value.absent(),
                Value<DateTime?> accessExpiresAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalSessionMetadataCompanion(
                id: id,
                userId: userId,
                activeOrganizationId: activeOrganizationId,
                activeFarmId: activeFarmId,
                accessExpiresAt: accessExpiresAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                Value<String?> activeOrganizationId = const Value.absent(),
                Value<String?> activeFarmId = const Value.absent(),
                Value<DateTime?> accessExpiresAt = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalSessionMetadataCompanion.insert(
                id: id,
                userId: userId,
                activeOrganizationId: activeOrganizationId,
                activeFarmId: activeFarmId,
                accessExpiresAt: accessExpiresAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalSessionMetadataTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalSessionMetadataTable,
      LocalSessionMetadataData,
      $$LocalSessionMetadataTableFilterComposer,
      $$LocalSessionMetadataTableOrderingComposer,
      $$LocalSessionMetadataTableAnnotationComposer,
      $$LocalSessionMetadataTableCreateCompanionBuilder,
      $$LocalSessionMetadataTableUpdateCompanionBuilder,
      (
        LocalSessionMetadataData,
        BaseReferences<
          _$AppDatabase,
          $LocalSessionMetadataTable,
          LocalSessionMetadataData
        >,
      ),
      LocalSessionMetadataData,
      PrefetchHooks Function()
    >;
typedef $$LocalOrganizationsTableCreateCompanionBuilder =
    LocalOrganizationsCompanion Function({
      required String id,
      required String name,
      Value<int> version,
      required DateTime serverUpdatedAt,
      Value<bool> isDeleted,
      Value<int> rowid,
    });
typedef $$LocalOrganizationsTableUpdateCompanionBuilder =
    LocalOrganizationsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> version,
      Value<DateTime> serverUpdatedAt,
      Value<bool> isDeleted,
      Value<int> rowid,
    });

class $$LocalOrganizationsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalOrganizationsTable> {
  $$LocalOrganizationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalOrganizationsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalOrganizationsTable> {
  $$LocalOrganizationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalOrganizationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalOrganizationsTable> {
  $$LocalOrganizationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<DateTime> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
}

class $$LocalOrganizationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalOrganizationsTable,
          LocalOrganization,
          $$LocalOrganizationsTableFilterComposer,
          $$LocalOrganizationsTableOrderingComposer,
          $$LocalOrganizationsTableAnnotationComposer,
          $$LocalOrganizationsTableCreateCompanionBuilder,
          $$LocalOrganizationsTableUpdateCompanionBuilder,
          (
            LocalOrganization,
            BaseReferences<
              _$AppDatabase,
              $LocalOrganizationsTable,
              LocalOrganization
            >,
          ),
          LocalOrganization,
          PrefetchHooks Function()
        > {
  $$LocalOrganizationsTableTableManager(
    _$AppDatabase db,
    $LocalOrganizationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalOrganizationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalOrganizationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalOrganizationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<DateTime> serverUpdatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalOrganizationsCompanion(
                id: id,
                name: name,
                version: version,
                serverUpdatedAt: serverUpdatedAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<int> version = const Value.absent(),
                required DateTime serverUpdatedAt,
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalOrganizationsCompanion.insert(
                id: id,
                name: name,
                version: version,
                serverUpdatedAt: serverUpdatedAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalOrganizationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalOrganizationsTable,
      LocalOrganization,
      $$LocalOrganizationsTableFilterComposer,
      $$LocalOrganizationsTableOrderingComposer,
      $$LocalOrganizationsTableAnnotationComposer,
      $$LocalOrganizationsTableCreateCompanionBuilder,
      $$LocalOrganizationsTableUpdateCompanionBuilder,
      (
        LocalOrganization,
        BaseReferences<
          _$AppDatabase,
          $LocalOrganizationsTable,
          LocalOrganization
        >,
      ),
      LocalOrganization,
      PrefetchHooks Function()
    >;
typedef $$LocalFarmsTableCreateCompanionBuilder =
    LocalFarmsCompanion Function({
      required String id,
      required String organizationId,
      required String name,
      Value<String> timezone,
      Value<int> version,
      required DateTime serverUpdatedAt,
      Value<bool> isDeleted,
      Value<int> rowid,
    });
typedef $$LocalFarmsTableUpdateCompanionBuilder =
    LocalFarmsCompanion Function({
      Value<String> id,
      Value<String> organizationId,
      Value<String> name,
      Value<String> timezone,
      Value<int> version,
      Value<DateTime> serverUpdatedAt,
      Value<bool> isDeleted,
      Value<int> rowid,
    });

class $$LocalFarmsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalFarmsTable> {
  $$LocalFarmsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get organizationId => $composableBuilder(
    column: $table.organizationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalFarmsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalFarmsTable> {
  $$LocalFarmsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get organizationId => $composableBuilder(
    column: $table.organizationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalFarmsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalFarmsTable> {
  $$LocalFarmsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get organizationId => $composableBuilder(
    column: $table.organizationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get timezone =>
      $composableBuilder(column: $table.timezone, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<DateTime> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
}

class $$LocalFarmsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalFarmsTable,
          LocalFarm,
          $$LocalFarmsTableFilterComposer,
          $$LocalFarmsTableOrderingComposer,
          $$LocalFarmsTableAnnotationComposer,
          $$LocalFarmsTableCreateCompanionBuilder,
          $$LocalFarmsTableUpdateCompanionBuilder,
          (
            LocalFarm,
            BaseReferences<_$AppDatabase, $LocalFarmsTable, LocalFarm>,
          ),
          LocalFarm,
          PrefetchHooks Function()
        > {
  $$LocalFarmsTableTableManager(_$AppDatabase db, $LocalFarmsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalFarmsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalFarmsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalFarmsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> organizationId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> timezone = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<DateTime> serverUpdatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalFarmsCompanion(
                id: id,
                organizationId: organizationId,
                name: name,
                timezone: timezone,
                version: version,
                serverUpdatedAt: serverUpdatedAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String organizationId,
                required String name,
                Value<String> timezone = const Value.absent(),
                Value<int> version = const Value.absent(),
                required DateTime serverUpdatedAt,
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalFarmsCompanion.insert(
                id: id,
                organizationId: organizationId,
                name: name,
                timezone: timezone,
                version: version,
                serverUpdatedAt: serverUpdatedAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalFarmsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalFarmsTable,
      LocalFarm,
      $$LocalFarmsTableFilterComposer,
      $$LocalFarmsTableOrderingComposer,
      $$LocalFarmsTableAnnotationComposer,
      $$LocalFarmsTableCreateCompanionBuilder,
      $$LocalFarmsTableUpdateCompanionBuilder,
      (LocalFarm, BaseReferences<_$AppDatabase, $LocalFarmsTable, LocalFarm>),
      LocalFarm,
      PrefetchHooks Function()
    >;
typedef $$LocalShedsTableCreateCompanionBuilder =
    LocalShedsCompanion Function({
      required String id,
      required String organizationId,
      required String farmId,
      required String name,
      Value<int> version,
      required DateTime serverUpdatedAt,
      Value<bool> isDeleted,
      Value<int> rowid,
    });
typedef $$LocalShedsTableUpdateCompanionBuilder =
    LocalShedsCompanion Function({
      Value<String> id,
      Value<String> organizationId,
      Value<String> farmId,
      Value<String> name,
      Value<int> version,
      Value<DateTime> serverUpdatedAt,
      Value<bool> isDeleted,
      Value<int> rowid,
    });

class $$LocalShedsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalShedsTable> {
  $$LocalShedsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get organizationId => $composableBuilder(
    column: $table.organizationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalShedsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalShedsTable> {
  $$LocalShedsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get organizationId => $composableBuilder(
    column: $table.organizationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalShedsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalShedsTable> {
  $$LocalShedsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get organizationId => $composableBuilder(
    column: $table.organizationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<DateTime> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
}

class $$LocalShedsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalShedsTable,
          LocalShed,
          $$LocalShedsTableFilterComposer,
          $$LocalShedsTableOrderingComposer,
          $$LocalShedsTableAnnotationComposer,
          $$LocalShedsTableCreateCompanionBuilder,
          $$LocalShedsTableUpdateCompanionBuilder,
          (
            LocalShed,
            BaseReferences<_$AppDatabase, $LocalShedsTable, LocalShed>,
          ),
          LocalShed,
          PrefetchHooks Function()
        > {
  $$LocalShedsTableTableManager(_$AppDatabase db, $LocalShedsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalShedsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalShedsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalShedsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> organizationId = const Value.absent(),
                Value<String> farmId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<DateTime> serverUpdatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalShedsCompanion(
                id: id,
                organizationId: organizationId,
                farmId: farmId,
                name: name,
                version: version,
                serverUpdatedAt: serverUpdatedAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String organizationId,
                required String farmId,
                required String name,
                Value<int> version = const Value.absent(),
                required DateTime serverUpdatedAt,
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalShedsCompanion.insert(
                id: id,
                organizationId: organizationId,
                farmId: farmId,
                name: name,
                version: version,
                serverUpdatedAt: serverUpdatedAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalShedsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalShedsTable,
      LocalShed,
      $$LocalShedsTableFilterComposer,
      $$LocalShedsTableOrderingComposer,
      $$LocalShedsTableAnnotationComposer,
      $$LocalShedsTableCreateCompanionBuilder,
      $$LocalShedsTableUpdateCompanionBuilder,
      (LocalShed, BaseReferences<_$AppDatabase, $LocalShedsTable, LocalShed>),
      LocalShed,
      PrefetchHooks Function()
    >;
typedef $$SyncDevicesTableCreateCompanionBuilder =
    SyncDevicesCompanion Function({
      required String id,
      required String name,
      Value<DateTime?> registeredAt,
      Value<DateTime?> lastSeenAt,
      Value<int> rowid,
    });
typedef $$SyncDevicesTableUpdateCompanionBuilder =
    SyncDevicesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<DateTime?> registeredAt,
      Value<DateTime?> lastSeenAt,
      Value<int> rowid,
    });

class $$SyncDevicesTableFilterComposer
    extends Composer<_$AppDatabase, $SyncDevicesTable> {
  $$SyncDevicesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get registeredAt => $composableBuilder(
    column: $table.registeredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncDevicesTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncDevicesTable> {
  $$SyncDevicesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get registeredAt => $composableBuilder(
    column: $table.registeredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncDevicesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncDevicesTable> {
  $$SyncDevicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get registeredAt => $composableBuilder(
    column: $table.registeredAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => column,
  );
}

class $$SyncDevicesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncDevicesTable,
          SyncDevice,
          $$SyncDevicesTableFilterComposer,
          $$SyncDevicesTableOrderingComposer,
          $$SyncDevicesTableAnnotationComposer,
          $$SyncDevicesTableCreateCompanionBuilder,
          $$SyncDevicesTableUpdateCompanionBuilder,
          (
            SyncDevice,
            BaseReferences<_$AppDatabase, $SyncDevicesTable, SyncDevice>,
          ),
          SyncDevice,
          PrefetchHooks Function()
        > {
  $$SyncDevicesTableTableManager(_$AppDatabase db, $SyncDevicesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncDevicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncDevicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncDevicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime?> registeredAt = const Value.absent(),
                Value<DateTime?> lastSeenAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncDevicesCompanion(
                id: id,
                name: name,
                registeredAt: registeredAt,
                lastSeenAt: lastSeenAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<DateTime?> registeredAt = const Value.absent(),
                Value<DateTime?> lastSeenAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncDevicesCompanion.insert(
                id: id,
                name: name,
                registeredAt: registeredAt,
                lastSeenAt: lastSeenAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncDevicesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncDevicesTable,
      SyncDevice,
      $$SyncDevicesTableFilterComposer,
      $$SyncDevicesTableOrderingComposer,
      $$SyncDevicesTableAnnotationComposer,
      $$SyncDevicesTableCreateCompanionBuilder,
      $$SyncDevicesTableUpdateCompanionBuilder,
      (
        SyncDevice,
        BaseReferences<_$AppDatabase, $SyncDevicesTable, SyncDevice>,
      ),
      SyncDevice,
      PrefetchHooks Function()
    >;
typedef $$SyncCursorsTableCreateCompanionBuilder =
    SyncCursorsCompanion Function({
      required String organizationId,
      required String collection,
      Value<String?> cursor,
      Value<DateTime?> lastSuccessfulSyncAt,
      Value<int> rowid,
    });
typedef $$SyncCursorsTableUpdateCompanionBuilder =
    SyncCursorsCompanion Function({
      Value<String> organizationId,
      Value<String> collection,
      Value<String?> cursor,
      Value<DateTime?> lastSuccessfulSyncAt,
      Value<int> rowid,
    });

class $$SyncCursorsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get organizationId => $composableBuilder(
    column: $table.organizationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get collection => $composableBuilder(
    column: $table.collection,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cursor => $composableBuilder(
    column: $table.cursor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSuccessfulSyncAt => $composableBuilder(
    column: $table.lastSuccessfulSyncAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncCursorsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get organizationId => $composableBuilder(
    column: $table.organizationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get collection => $composableBuilder(
    column: $table.collection,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cursor => $composableBuilder(
    column: $table.cursor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSuccessfulSyncAt => $composableBuilder(
    column: $table.lastSuccessfulSyncAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncCursorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get organizationId => $composableBuilder(
    column: $table.organizationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get collection => $composableBuilder(
    column: $table.collection,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cursor =>
      $composableBuilder(column: $table.cursor, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSuccessfulSyncAt => $composableBuilder(
    column: $table.lastSuccessfulSyncAt,
    builder: (column) => column,
  );
}

class $$SyncCursorsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncCursorsTable,
          SyncCursor,
          $$SyncCursorsTableFilterComposer,
          $$SyncCursorsTableOrderingComposer,
          $$SyncCursorsTableAnnotationComposer,
          $$SyncCursorsTableCreateCompanionBuilder,
          $$SyncCursorsTableUpdateCompanionBuilder,
          (
            SyncCursor,
            BaseReferences<_$AppDatabase, $SyncCursorsTable, SyncCursor>,
          ),
          SyncCursor,
          PrefetchHooks Function()
        > {
  $$SyncCursorsTableTableManager(_$AppDatabase db, $SyncCursorsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncCursorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncCursorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncCursorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> organizationId = const Value.absent(),
                Value<String> collection = const Value.absent(),
                Value<String?> cursor = const Value.absent(),
                Value<DateTime?> lastSuccessfulSyncAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncCursorsCompanion(
                organizationId: organizationId,
                collection: collection,
                cursor: cursor,
                lastSuccessfulSyncAt: lastSuccessfulSyncAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String organizationId,
                required String collection,
                Value<String?> cursor = const Value.absent(),
                Value<DateTime?> lastSuccessfulSyncAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncCursorsCompanion.insert(
                organizationId: organizationId,
                collection: collection,
                cursor: cursor,
                lastSuccessfulSyncAt: lastSuccessfulSyncAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncCursorsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncCursorsTable,
      SyncCursor,
      $$SyncCursorsTableFilterComposer,
      $$SyncCursorsTableOrderingComposer,
      $$SyncCursorsTableAnnotationComposer,
      $$SyncCursorsTableCreateCompanionBuilder,
      $$SyncCursorsTableUpdateCompanionBuilder,
      (
        SyncCursor,
        BaseReferences<_$AppDatabase, $SyncCursorsTable, SyncCursor>,
      ),
      SyncCursor,
      PrefetchHooks Function()
    >;
typedef $$SyncOutboxTableCreateCompanionBuilder =
    SyncOutboxCompanion Function({
      required String id,
      required String organizationId,
      Value<String?> farmId,
      required String deviceId,
      required String idempotencyKey,
      required String aggregateType,
      required String aggregateId,
      required String method,
      required String path,
      required String payloadJson,
      Value<String> dependencyIdsJson,
      Value<String> state,
      Value<int> retryCount,
      Value<DateTime?> nextAttemptAt,
      Value<String?> lastError,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$SyncOutboxTableUpdateCompanionBuilder =
    SyncOutboxCompanion Function({
      Value<String> id,
      Value<String> organizationId,
      Value<String?> farmId,
      Value<String> deviceId,
      Value<String> idempotencyKey,
      Value<String> aggregateType,
      Value<String> aggregateId,
      Value<String> method,
      Value<String> path,
      Value<String> payloadJson,
      Value<String> dependencyIdsJson,
      Value<String> state,
      Value<int> retryCount,
      Value<DateTime?> nextAttemptAt,
      Value<String?> lastError,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$SyncOutboxTableFilterComposer
    extends Composer<_$AppDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get organizationId => $composableBuilder(
    column: $table.organizationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get aggregateType => $composableBuilder(
    column: $table.aggregateType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get aggregateId => $composableBuilder(
    column: $table.aggregateId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dependencyIdsJson => $composableBuilder(
    column: $table.dependencyIdsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncOutboxTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get organizationId => $composableBuilder(
    column: $table.organizationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aggregateType => $composableBuilder(
    column: $table.aggregateType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aggregateId => $composableBuilder(
    column: $table.aggregateId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dependencyIdsJson => $composableBuilder(
    column: $table.dependencyIdsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
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
}

class $$SyncOutboxTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get organizationId => $composableBuilder(
    column: $table.organizationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get aggregateType => $composableBuilder(
    column: $table.aggregateType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get aggregateId => $composableBuilder(
    column: $table.aggregateId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dependencyIdsJson => $composableBuilder(
    column: $table.dependencyIdsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SyncOutboxTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncOutboxTable,
          SyncOutboxData,
          $$SyncOutboxTableFilterComposer,
          $$SyncOutboxTableOrderingComposer,
          $$SyncOutboxTableAnnotationComposer,
          $$SyncOutboxTableCreateCompanionBuilder,
          $$SyncOutboxTableUpdateCompanionBuilder,
          (
            SyncOutboxData,
            BaseReferences<_$AppDatabase, $SyncOutboxTable, SyncOutboxData>,
          ),
          SyncOutboxData,
          PrefetchHooks Function()
        > {
  $$SyncOutboxTableTableManager(_$AppDatabase db, $SyncOutboxTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncOutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncOutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncOutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> organizationId = const Value.absent(),
                Value<String?> farmId = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String> idempotencyKey = const Value.absent(),
                Value<String> aggregateType = const Value.absent(),
                Value<String> aggregateId = const Value.absent(),
                Value<String> method = const Value.absent(),
                Value<String> path = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<String> dependencyIdsJson = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<DateTime?> nextAttemptAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncOutboxCompanion(
                id: id,
                organizationId: organizationId,
                farmId: farmId,
                deviceId: deviceId,
                idempotencyKey: idempotencyKey,
                aggregateType: aggregateType,
                aggregateId: aggregateId,
                method: method,
                path: path,
                payloadJson: payloadJson,
                dependencyIdsJson: dependencyIdsJson,
                state: state,
                retryCount: retryCount,
                nextAttemptAt: nextAttemptAt,
                lastError: lastError,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String organizationId,
                Value<String?> farmId = const Value.absent(),
                required String deviceId,
                required String idempotencyKey,
                required String aggregateType,
                required String aggregateId,
                required String method,
                required String path,
                required String payloadJson,
                Value<String> dependencyIdsJson = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<DateTime?> nextAttemptAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SyncOutboxCompanion.insert(
                id: id,
                organizationId: organizationId,
                farmId: farmId,
                deviceId: deviceId,
                idempotencyKey: idempotencyKey,
                aggregateType: aggregateType,
                aggregateId: aggregateId,
                method: method,
                path: path,
                payloadJson: payloadJson,
                dependencyIdsJson: dependencyIdsJson,
                state: state,
                retryCount: retryCount,
                nextAttemptAt: nextAttemptAt,
                lastError: lastError,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncOutboxTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncOutboxTable,
      SyncOutboxData,
      $$SyncOutboxTableFilterComposer,
      $$SyncOutboxTableOrderingComposer,
      $$SyncOutboxTableAnnotationComposer,
      $$SyncOutboxTableCreateCompanionBuilder,
      $$SyncOutboxTableUpdateCompanionBuilder,
      (
        SyncOutboxData,
        BaseReferences<_$AppDatabase, $SyncOutboxTable, SyncOutboxData>,
      ),
      SyncOutboxData,
      PrefetchHooks Function()
    >;
typedef $$SyncConflictsTableCreateCompanionBuilder =
    SyncConflictsCompanion Function({
      required String id,
      required String operationId,
      required String aggregateType,
      required String aggregateId,
      required String localPayloadJson,
      required String serverPayloadJson,
      required String reason,
      Value<String> resolutionState,
      required DateTime createdAt,
      Value<DateTime?> resolvedAt,
      Value<int> rowid,
    });
typedef $$SyncConflictsTableUpdateCompanionBuilder =
    SyncConflictsCompanion Function({
      Value<String> id,
      Value<String> operationId,
      Value<String> aggregateType,
      Value<String> aggregateId,
      Value<String> localPayloadJson,
      Value<String> serverPayloadJson,
      Value<String> reason,
      Value<String> resolutionState,
      Value<DateTime> createdAt,
      Value<DateTime?> resolvedAt,
      Value<int> rowid,
    });

class $$SyncConflictsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncConflictsTable> {
  $$SyncConflictsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get aggregateType => $composableBuilder(
    column: $table.aggregateType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get aggregateId => $composableBuilder(
    column: $table.aggregateId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPayloadJson => $composableBuilder(
    column: $table.localPayloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverPayloadJson => $composableBuilder(
    column: $table.serverPayloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resolutionState => $composableBuilder(
    column: $table.resolutionState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncConflictsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncConflictsTable> {
  $$SyncConflictsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aggregateType => $composableBuilder(
    column: $table.aggregateType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aggregateId => $composableBuilder(
    column: $table.aggregateId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPayloadJson => $composableBuilder(
    column: $table.localPayloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverPayloadJson => $composableBuilder(
    column: $table.serverPayloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resolutionState => $composableBuilder(
    column: $table.resolutionState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncConflictsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncConflictsTable> {
  $$SyncConflictsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get aggregateType => $composableBuilder(
    column: $table.aggregateType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get aggregateId => $composableBuilder(
    column: $table.aggregateId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localPayloadJson => $composableBuilder(
    column: $table.localPayloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get serverPayloadJson => $composableBuilder(
    column: $table.serverPayloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get resolutionState => $composableBuilder(
    column: $table.resolutionState,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => column,
  );
}

class $$SyncConflictsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncConflictsTable,
          SyncConflict,
          $$SyncConflictsTableFilterComposer,
          $$SyncConflictsTableOrderingComposer,
          $$SyncConflictsTableAnnotationComposer,
          $$SyncConflictsTableCreateCompanionBuilder,
          $$SyncConflictsTableUpdateCompanionBuilder,
          (
            SyncConflict,
            BaseReferences<_$AppDatabase, $SyncConflictsTable, SyncConflict>,
          ),
          SyncConflict,
          PrefetchHooks Function()
        > {
  $$SyncConflictsTableTableManager(_$AppDatabase db, $SyncConflictsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncConflictsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncConflictsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncConflictsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> operationId = const Value.absent(),
                Value<String> aggregateType = const Value.absent(),
                Value<String> aggregateId = const Value.absent(),
                Value<String> localPayloadJson = const Value.absent(),
                Value<String> serverPayloadJson = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<String> resolutionState = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> resolvedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncConflictsCompanion(
                id: id,
                operationId: operationId,
                aggregateType: aggregateType,
                aggregateId: aggregateId,
                localPayloadJson: localPayloadJson,
                serverPayloadJson: serverPayloadJson,
                reason: reason,
                resolutionState: resolutionState,
                createdAt: createdAt,
                resolvedAt: resolvedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String operationId,
                required String aggregateType,
                required String aggregateId,
                required String localPayloadJson,
                required String serverPayloadJson,
                required String reason,
                Value<String> resolutionState = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> resolvedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncConflictsCompanion.insert(
                id: id,
                operationId: operationId,
                aggregateType: aggregateType,
                aggregateId: aggregateId,
                localPayloadJson: localPayloadJson,
                serverPayloadJson: serverPayloadJson,
                reason: reason,
                resolutionState: resolutionState,
                createdAt: createdAt,
                resolvedAt: resolvedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncConflictsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncConflictsTable,
      SyncConflict,
      $$SyncConflictsTableFilterComposer,
      $$SyncConflictsTableOrderingComposer,
      $$SyncConflictsTableAnnotationComposer,
      $$SyncConflictsTableCreateCompanionBuilder,
      $$SyncConflictsTableUpdateCompanionBuilder,
      (
        SyncConflict,
        BaseReferences<_$AppDatabase, $SyncConflictsTable, SyncConflict>,
      ),
      SyncConflict,
      PrefetchHooks Function()
    >;
typedef $$LocalApplicationSettingsTableCreateCompanionBuilder =
    LocalApplicationSettingsCompanion Function({
      required String key,
      required String value,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$LocalApplicationSettingsTableUpdateCompanionBuilder =
    LocalApplicationSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$LocalApplicationSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalApplicationSettingsTable> {
  $$LocalApplicationSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalApplicationSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalApplicationSettingsTable> {
  $$LocalApplicationSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalApplicationSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalApplicationSettingsTable> {
  $$LocalApplicationSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalApplicationSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalApplicationSettingsTable,
          LocalApplicationSetting,
          $$LocalApplicationSettingsTableFilterComposer,
          $$LocalApplicationSettingsTableOrderingComposer,
          $$LocalApplicationSettingsTableAnnotationComposer,
          $$LocalApplicationSettingsTableCreateCompanionBuilder,
          $$LocalApplicationSettingsTableUpdateCompanionBuilder,
          (
            LocalApplicationSetting,
            BaseReferences<
              _$AppDatabase,
              $LocalApplicationSettingsTable,
              LocalApplicationSetting
            >,
          ),
          LocalApplicationSetting,
          PrefetchHooks Function()
        > {
  $$LocalApplicationSettingsTableTableManager(
    _$AppDatabase db,
    $LocalApplicationSettingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalApplicationSettingsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LocalApplicationSettingsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalApplicationSettingsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalApplicationSettingsCompanion(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalApplicationSettingsCompanion.insert(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalApplicationSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalApplicationSettingsTable,
      LocalApplicationSetting,
      $$LocalApplicationSettingsTableFilterComposer,
      $$LocalApplicationSettingsTableOrderingComposer,
      $$LocalApplicationSettingsTableAnnotationComposer,
      $$LocalApplicationSettingsTableCreateCompanionBuilder,
      $$LocalApplicationSettingsTableUpdateCompanionBuilder,
      (
        LocalApplicationSetting,
        BaseReferences<
          _$AppDatabase,
          $LocalApplicationSettingsTable,
          LocalApplicationSetting
        >,
      ),
      LocalApplicationSetting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalSessionMetadataTableTableManager get localSessionMetadata =>
      $$LocalSessionMetadataTableTableManager(_db, _db.localSessionMetadata);
  $$LocalOrganizationsTableTableManager get localOrganizations =>
      $$LocalOrganizationsTableTableManager(_db, _db.localOrganizations);
  $$LocalFarmsTableTableManager get localFarms =>
      $$LocalFarmsTableTableManager(_db, _db.localFarms);
  $$LocalShedsTableTableManager get localSheds =>
      $$LocalShedsTableTableManager(_db, _db.localSheds);
  $$SyncDevicesTableTableManager get syncDevices =>
      $$SyncDevicesTableTableManager(_db, _db.syncDevices);
  $$SyncCursorsTableTableManager get syncCursors =>
      $$SyncCursorsTableTableManager(_db, _db.syncCursors);
  $$SyncOutboxTableTableManager get syncOutbox =>
      $$SyncOutboxTableTableManager(_db, _db.syncOutbox);
  $$SyncConflictsTableTableManager get syncConflicts =>
      $$SyncConflictsTableTableManager(_db, _db.syncConflicts);
  $$LocalApplicationSettingsTableTableManager get localApplicationSettings =>
      $$LocalApplicationSettingsTableTableManager(
        _db,
        _db.localApplicationSettings,
      );
}
