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

class $LocalAnimalSpeciesTable extends LocalAnimalSpecies
    with TableInfo<$LocalAnimalSpeciesTable, LocalAnimalSpecy> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalAnimalSpeciesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
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
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
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
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    code,
    name,
    isActive,
    version,
    serverUpdatedAt,
    cachedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_animal_species';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalAnimalSpecy> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
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
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalAnimalSpecy map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalAnimalSpecy(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}server_updated_at'],
      )!,
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
    );
  }

  @override
  $LocalAnimalSpeciesTable createAlias(String alias) {
    return $LocalAnimalSpeciesTable(attachedDatabase, alias);
  }
}

class LocalAnimalSpecy extends DataClass
    implements Insertable<LocalAnimalSpecy> {
  final String id;
  final String code;
  final String name;
  final bool isActive;
  final int version;
  final DateTime serverUpdatedAt;
  final DateTime cachedAt;
  const LocalAnimalSpecy({
    required this.id,
    required this.code,
    required this.name,
    required this.isActive,
    required this.version,
    required this.serverUpdatedAt,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['code'] = Variable<String>(code);
    map['name'] = Variable<String>(name);
    map['is_active'] = Variable<bool>(isActive);
    map['version'] = Variable<int>(version);
    map['server_updated_at'] = Variable<DateTime>(serverUpdatedAt);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  LocalAnimalSpeciesCompanion toCompanion(bool nullToAbsent) {
    return LocalAnimalSpeciesCompanion(
      id: Value(id),
      code: Value(code),
      name: Value(name),
      isActive: Value(isActive),
      version: Value(version),
      serverUpdatedAt: Value(serverUpdatedAt),
      cachedAt: Value(cachedAt),
    );
  }

  factory LocalAnimalSpecy.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalAnimalSpecy(
      id: serializer.fromJson<String>(json['id']),
      code: serializer.fromJson<String>(json['code']),
      name: serializer.fromJson<String>(json['name']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      version: serializer.fromJson<int>(json['version']),
      serverUpdatedAt: serializer.fromJson<DateTime>(json['serverUpdatedAt']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'code': serializer.toJson<String>(code),
      'name': serializer.toJson<String>(name),
      'isActive': serializer.toJson<bool>(isActive),
      'version': serializer.toJson<int>(version),
      'serverUpdatedAt': serializer.toJson<DateTime>(serverUpdatedAt),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  LocalAnimalSpecy copyWith({
    String? id,
    String? code,
    String? name,
    bool? isActive,
    int? version,
    DateTime? serverUpdatedAt,
    DateTime? cachedAt,
  }) => LocalAnimalSpecy(
    id: id ?? this.id,
    code: code ?? this.code,
    name: name ?? this.name,
    isActive: isActive ?? this.isActive,
    version: version ?? this.version,
    serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
    cachedAt: cachedAt ?? this.cachedAt,
  );
  LocalAnimalSpecy copyWithCompanion(LocalAnimalSpeciesCompanion data) {
    return LocalAnimalSpecy(
      id: data.id.present ? data.id.value : this.id,
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      version: data.version.present ? data.version.value : this.version,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalAnimalSpecy(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('isActive: $isActive, ')
          ..write('version: $version, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, code, name, isActive, version, serverUpdatedAt, cachedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalAnimalSpecy &&
          other.id == this.id &&
          other.code == this.code &&
          other.name == this.name &&
          other.isActive == this.isActive &&
          other.version == this.version &&
          other.serverUpdatedAt == this.serverUpdatedAt &&
          other.cachedAt == this.cachedAt);
}

class LocalAnimalSpeciesCompanion extends UpdateCompanion<LocalAnimalSpecy> {
  final Value<String> id;
  final Value<String> code;
  final Value<String> name;
  final Value<bool> isActive;
  final Value<int> version;
  final Value<DateTime> serverUpdatedAt;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const LocalAnimalSpeciesCompanion({
    this.id = const Value.absent(),
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.isActive = const Value.absent(),
    this.version = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalAnimalSpeciesCompanion.insert({
    required String id,
    required String code,
    required String name,
    this.isActive = const Value.absent(),
    this.version = const Value.absent(),
    required DateTime serverUpdatedAt,
    required DateTime cachedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       code = Value(code),
       name = Value(name),
       serverUpdatedAt = Value(serverUpdatedAt),
       cachedAt = Value(cachedAt);
  static Insertable<LocalAnimalSpecy> custom({
    Expression<String>? id,
    Expression<String>? code,
    Expression<String>? name,
    Expression<bool>? isActive,
    Expression<int>? version,
    Expression<DateTime>? serverUpdatedAt,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (isActive != null) 'is_active': isActive,
      if (version != null) 'version': version,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalAnimalSpeciesCompanion copyWith({
    Value<String>? id,
    Value<String>? code,
    Value<String>? name,
    Value<bool>? isActive,
    Value<int>? version,
    Value<DateTime>? serverUpdatedAt,
    Value<DateTime>? cachedAt,
    Value<int>? rowid,
  }) {
    return LocalAnimalSpeciesCompanion(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
      version: version ?? this.version,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<DateTime>(serverUpdatedAt.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalAnimalSpeciesCompanion(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('isActive: $isActive, ')
          ..write('version: $version, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalAnimalBreedsTable extends LocalAnimalBreeds
    with TableInfo<$LocalAnimalBreedsTable, LocalAnimalBreed> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalAnimalBreedsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _speciesIdMeta = const VerificationMeta(
    'speciesId',
  );
  @override
  late final GeneratedColumn<String> speciesId = GeneratedColumn<String>(
    'species_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
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
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
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
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    organizationId,
    speciesId,
    code,
    name,
    description,
    isActive,
    version,
    serverUpdatedAt,
    cachedAt,
    isArchived,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_animal_breeds';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalAnimalBreed> instance, {
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
    if (data.containsKey('species_id')) {
      context.handle(
        _speciesIdMeta,
        speciesId.isAcceptableOrUnknown(data['species_id']!, _speciesIdMeta),
      );
    } else if (isInserting) {
      context.missing(_speciesIdMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
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
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
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
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalAnimalBreed map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalAnimalBreed(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      organizationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}organization_id'],
      )!,
      speciesId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}species_id'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}server_updated_at'],
      )!,
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
    );
  }

  @override
  $LocalAnimalBreedsTable createAlias(String alias) {
    return $LocalAnimalBreedsTable(attachedDatabase, alias);
  }
}

class LocalAnimalBreed extends DataClass
    implements Insertable<LocalAnimalBreed> {
  final String id;
  final String organizationId;
  final String speciesId;
  final String code;
  final String name;
  final String? description;
  final bool isActive;
  final int version;
  final DateTime serverUpdatedAt;
  final DateTime cachedAt;
  final bool isArchived;
  const LocalAnimalBreed({
    required this.id,
    required this.organizationId,
    required this.speciesId,
    required this.code,
    required this.name,
    this.description,
    required this.isActive,
    required this.version,
    required this.serverUpdatedAt,
    required this.cachedAt,
    required this.isArchived,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['organization_id'] = Variable<String>(organizationId);
    map['species_id'] = Variable<String>(speciesId);
    map['code'] = Variable<String>(code);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['version'] = Variable<int>(version);
    map['server_updated_at'] = Variable<DateTime>(serverUpdatedAt);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    map['is_archived'] = Variable<bool>(isArchived);
    return map;
  }

  LocalAnimalBreedsCompanion toCompanion(bool nullToAbsent) {
    return LocalAnimalBreedsCompanion(
      id: Value(id),
      organizationId: Value(organizationId),
      speciesId: Value(speciesId),
      code: Value(code),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      isActive: Value(isActive),
      version: Value(version),
      serverUpdatedAt: Value(serverUpdatedAt),
      cachedAt: Value(cachedAt),
      isArchived: Value(isArchived),
    );
  }

  factory LocalAnimalBreed.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalAnimalBreed(
      id: serializer.fromJson<String>(json['id']),
      organizationId: serializer.fromJson<String>(json['organizationId']),
      speciesId: serializer.fromJson<String>(json['speciesId']),
      code: serializer.fromJson<String>(json['code']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      version: serializer.fromJson<int>(json['version']),
      serverUpdatedAt: serializer.fromJson<DateTime>(json['serverUpdatedAt']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'organizationId': serializer.toJson<String>(organizationId),
      'speciesId': serializer.toJson<String>(speciesId),
      'code': serializer.toJson<String>(code),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'isActive': serializer.toJson<bool>(isActive),
      'version': serializer.toJson<int>(version),
      'serverUpdatedAt': serializer.toJson<DateTime>(serverUpdatedAt),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
      'isArchived': serializer.toJson<bool>(isArchived),
    };
  }

  LocalAnimalBreed copyWith({
    String? id,
    String? organizationId,
    String? speciesId,
    String? code,
    String? name,
    Value<String?> description = const Value.absent(),
    bool? isActive,
    int? version,
    DateTime? serverUpdatedAt,
    DateTime? cachedAt,
    bool? isArchived,
  }) => LocalAnimalBreed(
    id: id ?? this.id,
    organizationId: organizationId ?? this.organizationId,
    speciesId: speciesId ?? this.speciesId,
    code: code ?? this.code,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    isActive: isActive ?? this.isActive,
    version: version ?? this.version,
    serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
    cachedAt: cachedAt ?? this.cachedAt,
    isArchived: isArchived ?? this.isArchived,
  );
  LocalAnimalBreed copyWithCompanion(LocalAnimalBreedsCompanion data) {
    return LocalAnimalBreed(
      id: data.id.present ? data.id.value : this.id,
      organizationId: data.organizationId.present
          ? data.organizationId.value
          : this.organizationId,
      speciesId: data.speciesId.present ? data.speciesId.value : this.speciesId,
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      version: data.version.present ? data.version.value : this.version,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalAnimalBreed(')
          ..write('id: $id, ')
          ..write('organizationId: $organizationId, ')
          ..write('speciesId: $speciesId, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('isActive: $isActive, ')
          ..write('version: $version, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('isArchived: $isArchived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    organizationId,
    speciesId,
    code,
    name,
    description,
    isActive,
    version,
    serverUpdatedAt,
    cachedAt,
    isArchived,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalAnimalBreed &&
          other.id == this.id &&
          other.organizationId == this.organizationId &&
          other.speciesId == this.speciesId &&
          other.code == this.code &&
          other.name == this.name &&
          other.description == this.description &&
          other.isActive == this.isActive &&
          other.version == this.version &&
          other.serverUpdatedAt == this.serverUpdatedAt &&
          other.cachedAt == this.cachedAt &&
          other.isArchived == this.isArchived);
}

class LocalAnimalBreedsCompanion extends UpdateCompanion<LocalAnimalBreed> {
  final Value<String> id;
  final Value<String> organizationId;
  final Value<String> speciesId;
  final Value<String> code;
  final Value<String> name;
  final Value<String?> description;
  final Value<bool> isActive;
  final Value<int> version;
  final Value<DateTime> serverUpdatedAt;
  final Value<DateTime> cachedAt;
  final Value<bool> isArchived;
  final Value<int> rowid;
  const LocalAnimalBreedsCompanion({
    this.id = const Value.absent(),
    this.organizationId = const Value.absent(),
    this.speciesId = const Value.absent(),
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.isActive = const Value.absent(),
    this.version = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalAnimalBreedsCompanion.insert({
    required String id,
    required String organizationId,
    required String speciesId,
    required String code,
    required String name,
    this.description = const Value.absent(),
    this.isActive = const Value.absent(),
    this.version = const Value.absent(),
    required DateTime serverUpdatedAt,
    required DateTime cachedAt,
    this.isArchived = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       organizationId = Value(organizationId),
       speciesId = Value(speciesId),
       code = Value(code),
       name = Value(name),
       serverUpdatedAt = Value(serverUpdatedAt),
       cachedAt = Value(cachedAt);
  static Insertable<LocalAnimalBreed> custom({
    Expression<String>? id,
    Expression<String>? organizationId,
    Expression<String>? speciesId,
    Expression<String>? code,
    Expression<String>? name,
    Expression<String>? description,
    Expression<bool>? isActive,
    Expression<int>? version,
    Expression<DateTime>? serverUpdatedAt,
    Expression<DateTime>? cachedAt,
    Expression<bool>? isArchived,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (organizationId != null) 'organization_id': organizationId,
      if (speciesId != null) 'species_id': speciesId,
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (isActive != null) 'is_active': isActive,
      if (version != null) 'version': version,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (isArchived != null) 'is_archived': isArchived,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalAnimalBreedsCompanion copyWith({
    Value<String>? id,
    Value<String>? organizationId,
    Value<String>? speciesId,
    Value<String>? code,
    Value<String>? name,
    Value<String?>? description,
    Value<bool>? isActive,
    Value<int>? version,
    Value<DateTime>? serverUpdatedAt,
    Value<DateTime>? cachedAt,
    Value<bool>? isArchived,
    Value<int>? rowid,
  }) {
    return LocalAnimalBreedsCompanion(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      speciesId: speciesId ?? this.speciesId,
      code: code ?? this.code,
      name: name ?? this.name,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      version: version ?? this.version,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      cachedAt: cachedAt ?? this.cachedAt,
      isArchived: isArchived ?? this.isArchived,
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
    if (speciesId.present) {
      map['species_id'] = Variable<String>(speciesId.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<DateTime>(serverUpdatedAt.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalAnimalBreedsCompanion(')
          ..write('id: $id, ')
          ..write('organizationId: $organizationId, ')
          ..write('speciesId: $speciesId, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('isActive: $isActive, ')
          ..write('version: $version, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('isArchived: $isArchived, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalAnimalGroupsTable extends LocalAnimalGroups
    with TableInfo<$LocalAnimalGroupsTable, LocalAnimalGroup> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalAnimalGroupsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _defaultShedIdMeta = const VerificationMeta(
    'defaultShedId',
  );
  @override
  late final GeneratedColumn<String> defaultShedId = GeneratedColumn<String>(
    'default_shed_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
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
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
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
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isAccessibleMeta = const VerificationMeta(
    'isAccessible',
  );
  @override
  late final GeneratedColumn<bool> isAccessible = GeneratedColumn<bool>(
    'is_accessible',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_accessible" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    organizationId,
    farmId,
    defaultShedId,
    code,
    name,
    description,
    isActive,
    version,
    serverUpdatedAt,
    cachedAt,
    isArchived,
    isAccessible,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_animal_groups';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalAnimalGroup> instance, {
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
    if (data.containsKey('default_shed_id')) {
      context.handle(
        _defaultShedIdMeta,
        defaultShedId.isAcceptableOrUnknown(
          data['default_shed_id']!,
          _defaultShedIdMeta,
        ),
      );
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
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
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
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
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    if (data.containsKey('is_accessible')) {
      context.handle(
        _isAccessibleMeta,
        isAccessible.isAcceptableOrUnknown(
          data['is_accessible']!,
          _isAccessibleMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalAnimalGroup map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalAnimalGroup(
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
      defaultShedId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_shed_id'],
      ),
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}server_updated_at'],
      )!,
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
      isAccessible: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_accessible'],
      )!,
    );
  }

  @override
  $LocalAnimalGroupsTable createAlias(String alias) {
    return $LocalAnimalGroupsTable(attachedDatabase, alias);
  }
}

class LocalAnimalGroup extends DataClass
    implements Insertable<LocalAnimalGroup> {
  final String id;
  final String organizationId;
  final String farmId;
  final String? defaultShedId;
  final String code;
  final String name;
  final String? description;
  final bool isActive;
  final int version;
  final DateTime serverUpdatedAt;
  final DateTime cachedAt;
  final bool isArchived;
  final bool isAccessible;
  const LocalAnimalGroup({
    required this.id,
    required this.organizationId,
    required this.farmId,
    this.defaultShedId,
    required this.code,
    required this.name,
    this.description,
    required this.isActive,
    required this.version,
    required this.serverUpdatedAt,
    required this.cachedAt,
    required this.isArchived,
    required this.isAccessible,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['organization_id'] = Variable<String>(organizationId);
    map['farm_id'] = Variable<String>(farmId);
    if (!nullToAbsent || defaultShedId != null) {
      map['default_shed_id'] = Variable<String>(defaultShedId);
    }
    map['code'] = Variable<String>(code);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['version'] = Variable<int>(version);
    map['server_updated_at'] = Variable<DateTime>(serverUpdatedAt);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    map['is_archived'] = Variable<bool>(isArchived);
    map['is_accessible'] = Variable<bool>(isAccessible);
    return map;
  }

  LocalAnimalGroupsCompanion toCompanion(bool nullToAbsent) {
    return LocalAnimalGroupsCompanion(
      id: Value(id),
      organizationId: Value(organizationId),
      farmId: Value(farmId),
      defaultShedId: defaultShedId == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultShedId),
      code: Value(code),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      isActive: Value(isActive),
      version: Value(version),
      serverUpdatedAt: Value(serverUpdatedAt),
      cachedAt: Value(cachedAt),
      isArchived: Value(isArchived),
      isAccessible: Value(isAccessible),
    );
  }

  factory LocalAnimalGroup.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalAnimalGroup(
      id: serializer.fromJson<String>(json['id']),
      organizationId: serializer.fromJson<String>(json['organizationId']),
      farmId: serializer.fromJson<String>(json['farmId']),
      defaultShedId: serializer.fromJson<String?>(json['defaultShedId']),
      code: serializer.fromJson<String>(json['code']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      version: serializer.fromJson<int>(json['version']),
      serverUpdatedAt: serializer.fromJson<DateTime>(json['serverUpdatedAt']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      isAccessible: serializer.fromJson<bool>(json['isAccessible']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'organizationId': serializer.toJson<String>(organizationId),
      'farmId': serializer.toJson<String>(farmId),
      'defaultShedId': serializer.toJson<String?>(defaultShedId),
      'code': serializer.toJson<String>(code),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'isActive': serializer.toJson<bool>(isActive),
      'version': serializer.toJson<int>(version),
      'serverUpdatedAt': serializer.toJson<DateTime>(serverUpdatedAt),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
      'isArchived': serializer.toJson<bool>(isArchived),
      'isAccessible': serializer.toJson<bool>(isAccessible),
    };
  }

  LocalAnimalGroup copyWith({
    String? id,
    String? organizationId,
    String? farmId,
    Value<String?> defaultShedId = const Value.absent(),
    String? code,
    String? name,
    Value<String?> description = const Value.absent(),
    bool? isActive,
    int? version,
    DateTime? serverUpdatedAt,
    DateTime? cachedAt,
    bool? isArchived,
    bool? isAccessible,
  }) => LocalAnimalGroup(
    id: id ?? this.id,
    organizationId: organizationId ?? this.organizationId,
    farmId: farmId ?? this.farmId,
    defaultShedId: defaultShedId.present
        ? defaultShedId.value
        : this.defaultShedId,
    code: code ?? this.code,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    isActive: isActive ?? this.isActive,
    version: version ?? this.version,
    serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
    cachedAt: cachedAt ?? this.cachedAt,
    isArchived: isArchived ?? this.isArchived,
    isAccessible: isAccessible ?? this.isAccessible,
  );
  LocalAnimalGroup copyWithCompanion(LocalAnimalGroupsCompanion data) {
    return LocalAnimalGroup(
      id: data.id.present ? data.id.value : this.id,
      organizationId: data.organizationId.present
          ? data.organizationId.value
          : this.organizationId,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      defaultShedId: data.defaultShedId.present
          ? data.defaultShedId.value
          : this.defaultShedId,
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      version: data.version.present ? data.version.value : this.version,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
      isAccessible: data.isAccessible.present
          ? data.isAccessible.value
          : this.isAccessible,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalAnimalGroup(')
          ..write('id: $id, ')
          ..write('organizationId: $organizationId, ')
          ..write('farmId: $farmId, ')
          ..write('defaultShedId: $defaultShedId, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('isActive: $isActive, ')
          ..write('version: $version, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('isArchived: $isArchived, ')
          ..write('isAccessible: $isAccessible')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    organizationId,
    farmId,
    defaultShedId,
    code,
    name,
    description,
    isActive,
    version,
    serverUpdatedAt,
    cachedAt,
    isArchived,
    isAccessible,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalAnimalGroup &&
          other.id == this.id &&
          other.organizationId == this.organizationId &&
          other.farmId == this.farmId &&
          other.defaultShedId == this.defaultShedId &&
          other.code == this.code &&
          other.name == this.name &&
          other.description == this.description &&
          other.isActive == this.isActive &&
          other.version == this.version &&
          other.serverUpdatedAt == this.serverUpdatedAt &&
          other.cachedAt == this.cachedAt &&
          other.isArchived == this.isArchived &&
          other.isAccessible == this.isAccessible);
}

class LocalAnimalGroupsCompanion extends UpdateCompanion<LocalAnimalGroup> {
  final Value<String> id;
  final Value<String> organizationId;
  final Value<String> farmId;
  final Value<String?> defaultShedId;
  final Value<String> code;
  final Value<String> name;
  final Value<String?> description;
  final Value<bool> isActive;
  final Value<int> version;
  final Value<DateTime> serverUpdatedAt;
  final Value<DateTime> cachedAt;
  final Value<bool> isArchived;
  final Value<bool> isAccessible;
  final Value<int> rowid;
  const LocalAnimalGroupsCompanion({
    this.id = const Value.absent(),
    this.organizationId = const Value.absent(),
    this.farmId = const Value.absent(),
    this.defaultShedId = const Value.absent(),
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.isActive = const Value.absent(),
    this.version = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.isAccessible = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalAnimalGroupsCompanion.insert({
    required String id,
    required String organizationId,
    required String farmId,
    this.defaultShedId = const Value.absent(),
    required String code,
    required String name,
    this.description = const Value.absent(),
    this.isActive = const Value.absent(),
    this.version = const Value.absent(),
    required DateTime serverUpdatedAt,
    required DateTime cachedAt,
    this.isArchived = const Value.absent(),
    this.isAccessible = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       organizationId = Value(organizationId),
       farmId = Value(farmId),
       code = Value(code),
       name = Value(name),
       serverUpdatedAt = Value(serverUpdatedAt),
       cachedAt = Value(cachedAt);
  static Insertable<LocalAnimalGroup> custom({
    Expression<String>? id,
    Expression<String>? organizationId,
    Expression<String>? farmId,
    Expression<String>? defaultShedId,
    Expression<String>? code,
    Expression<String>? name,
    Expression<String>? description,
    Expression<bool>? isActive,
    Expression<int>? version,
    Expression<DateTime>? serverUpdatedAt,
    Expression<DateTime>? cachedAt,
    Expression<bool>? isArchived,
    Expression<bool>? isAccessible,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (organizationId != null) 'organization_id': organizationId,
      if (farmId != null) 'farm_id': farmId,
      if (defaultShedId != null) 'default_shed_id': defaultShedId,
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (isActive != null) 'is_active': isActive,
      if (version != null) 'version': version,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (isArchived != null) 'is_archived': isArchived,
      if (isAccessible != null) 'is_accessible': isAccessible,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalAnimalGroupsCompanion copyWith({
    Value<String>? id,
    Value<String>? organizationId,
    Value<String>? farmId,
    Value<String?>? defaultShedId,
    Value<String>? code,
    Value<String>? name,
    Value<String?>? description,
    Value<bool>? isActive,
    Value<int>? version,
    Value<DateTime>? serverUpdatedAt,
    Value<DateTime>? cachedAt,
    Value<bool>? isArchived,
    Value<bool>? isAccessible,
    Value<int>? rowid,
  }) {
    return LocalAnimalGroupsCompanion(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      farmId: farmId ?? this.farmId,
      defaultShedId: defaultShedId ?? this.defaultShedId,
      code: code ?? this.code,
      name: name ?? this.name,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      version: version ?? this.version,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      cachedAt: cachedAt ?? this.cachedAt,
      isArchived: isArchived ?? this.isArchived,
      isAccessible: isAccessible ?? this.isAccessible,
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
    if (defaultShedId.present) {
      map['default_shed_id'] = Variable<String>(defaultShedId.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<DateTime>(serverUpdatedAt.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (isAccessible.present) {
      map['is_accessible'] = Variable<bool>(isAccessible.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalAnimalGroupsCompanion(')
          ..write('id: $id, ')
          ..write('organizationId: $organizationId, ')
          ..write('farmId: $farmId, ')
          ..write('defaultShedId: $defaultShedId, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('isActive: $isActive, ')
          ..write('version: $version, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('isArchived: $isArchived, ')
          ..write('isAccessible: $isAccessible, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalAnimalsTable extends LocalAnimals
    with TableInfo<$LocalAnimalsTable, LocalAnimal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalAnimalsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _animalNumberMeta = const VerificationMeta(
    'animalNumber',
  );
  @override
  late final GeneratedColumn<String> animalNumber = GeneratedColumn<String>(
    'animal_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _earTagNumberMeta = const VerificationMeta(
    'earTagNumber',
  );
  @override
  late final GeneratedColumn<String> earTagNumber = GeneratedColumn<String>(
    'ear_tag_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rfidNumberMeta = const VerificationMeta(
    'rfidNumber',
  );
  @override
  late final GeneratedColumn<String> rfidNumber = GeneratedColumn<String>(
    'rfid_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _registrationNumberMeta =
      const VerificationMeta('registrationNumber');
  @override
  late final GeneratedColumn<String> registrationNumber =
      GeneratedColumn<String>(
        'registration_number',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _speciesIdMeta = const VerificationMeta(
    'speciesId',
  );
  @override
  late final GeneratedColumn<String> speciesId = GeneratedColumn<String>(
    'species_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _speciesNameMeta = const VerificationMeta(
    'speciesName',
  );
  @override
  late final GeneratedColumn<String> speciesName = GeneratedColumn<String>(
    'species_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _breedIdMeta = const VerificationMeta(
    'breedId',
  );
  @override
  late final GeneratedColumn<String> breedId = GeneratedColumn<String>(
    'breed_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _breedNameMeta = const VerificationMeta(
    'breedName',
  );
  @override
  late final GeneratedColumn<String> breedName = GeneratedColumn<String>(
    'breed_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sexMeta = const VerificationMeta('sex');
  @override
  late final GeneratedColumn<String> sex = GeneratedColumn<String>(
    'sex',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lifeStageMeta = const VerificationMeta(
    'lifeStage',
  );
  @override
  late final GeneratedColumn<String> lifeStage = GeneratedColumn<String>(
    'life_stage',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateOfBirthMeta = const VerificationMeta(
    'dateOfBirth',
  );
  @override
  late final GeneratedColumn<DateTime> dateOfBirth = GeneratedColumn<DateTime>(
    'date_of_birth',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDateOfBirthEstimatedMeta =
      const VerificationMeta('isDateOfBirthEstimated');
  @override
  late final GeneratedColumn<bool> isDateOfBirthEstimated =
      GeneratedColumn<bool>(
        'is_date_of_birth_estimated',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_date_of_birth_estimated" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _colourMeta = const VerificationMeta('colour');
  @override
  late final GeneratedColumn<String> colour = GeneratedColumn<String>(
    'colour',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _identifyingMarksMeta = const VerificationMeta(
    'identifyingMarks',
  );
  @override
  late final GeneratedColumn<String> identifyingMarks = GeneratedColumn<String>(
    'identifying_marks',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currentFarmIdMeta = const VerificationMeta(
    'currentFarmId',
  );
  @override
  late final GeneratedColumn<String> currentFarmId = GeneratedColumn<String>(
    'current_farm_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentFarmNameMeta = const VerificationMeta(
    'currentFarmName',
  );
  @override
  late final GeneratedColumn<String> currentFarmName = GeneratedColumn<String>(
    'current_farm_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentShedIdMeta = const VerificationMeta(
    'currentShedId',
  );
  @override
  late final GeneratedColumn<String> currentShedId = GeneratedColumn<String>(
    'current_shed_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentShedNameMeta = const VerificationMeta(
    'currentShedName',
  );
  @override
  late final GeneratedColumn<String> currentShedName = GeneratedColumn<String>(
    'current_shed_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentAnimalGroupIdMeta =
      const VerificationMeta('currentAnimalGroupId');
  @override
  late final GeneratedColumn<String> currentAnimalGroupId =
      GeneratedColumn<String>(
        'current_animal_group_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _currentAnimalGroupNameMeta =
      const VerificationMeta('currentAnimalGroupName');
  @override
  late final GeneratedColumn<String> currentAnimalGroupName =
      GeneratedColumn<String>(
        'current_animal_group_name',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _motherAnimalIdMeta = const VerificationMeta(
    'motherAnimalId',
  );
  @override
  late final GeneratedColumn<String> motherAnimalId = GeneratedColumn<String>(
    'mother_animal_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _motherAnimalNumberMeta =
      const VerificationMeta('motherAnimalNumber');
  @override
  late final GeneratedColumn<String> motherAnimalNumber =
      GeneratedColumn<String>(
        'mother_animal_number',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _fatherAnimalIdMeta = const VerificationMeta(
    'fatherAnimalId',
  );
  @override
  late final GeneratedColumn<String> fatherAnimalId = GeneratedColumn<String>(
    'father_animal_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fatherAnimalNumberMeta =
      const VerificationMeta('fatherAnimalNumber');
  @override
  late final GeneratedColumn<String> fatherAnimalNumber =
      GeneratedColumn<String>(
        'father_animal_number',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _externalSireReferenceMeta =
      const VerificationMeta('externalSireReference');
  @override
  late final GeneratedColumn<String> externalSireReference =
      GeneratedColumn<String>(
        'external_sire_reference',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _originMeta = const VerificationMeta('origin');
  @override
  late final GeneratedColumn<String> origin = GeneratedColumn<String>(
    'origin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _acquisitionDateMeta = const VerificationMeta(
    'acquisitionDate',
  );
  @override
  late final GeneratedColumn<DateTime> acquisitionDate =
      GeneratedColumn<DateTime>(
        'acquisition_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _sourceDescriptionMeta = const VerificationMeta(
    'sourceDescription',
  );
  @override
  late final GeneratedColumn<String> sourceDescription =
      GeneratedColumn<String>(
        'source_description',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _operationalStatusMeta = const VerificationMeta(
    'operationalStatus',
  );
  @override
  late final GeneratedColumn<String> operationalStatus =
      GeneratedColumn<String>(
        'operational_status',
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
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isAccessibleMeta = const VerificationMeta(
    'isAccessible',
  );
  @override
  late final GeneratedColumn<bool> isAccessible = GeneratedColumn<bool>(
    'is_accessible',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_accessible" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    organizationId,
    animalNumber,
    earTagNumber,
    rfidNumber,
    name,
    registrationNumber,
    speciesId,
    speciesName,
    breedId,
    breedName,
    sex,
    lifeStage,
    dateOfBirth,
    isDateOfBirthEstimated,
    colour,
    identifyingMarks,
    currentFarmId,
    currentFarmName,
    currentShedId,
    currentShedName,
    currentAnimalGroupId,
    currentAnimalGroupName,
    motherAnimalId,
    motherAnimalNumber,
    fatherAnimalId,
    fatherAnimalNumber,
    externalSireReference,
    origin,
    acquisitionDate,
    sourceDescription,
    notes,
    operationalStatus,
    version,
    serverUpdatedAt,
    cachedAt,
    isArchived,
    isAccessible,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_animals';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalAnimal> instance, {
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
    if (data.containsKey('animal_number')) {
      context.handle(
        _animalNumberMeta,
        animalNumber.isAcceptableOrUnknown(
          data['animal_number']!,
          _animalNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_animalNumberMeta);
    }
    if (data.containsKey('ear_tag_number')) {
      context.handle(
        _earTagNumberMeta,
        earTagNumber.isAcceptableOrUnknown(
          data['ear_tag_number']!,
          _earTagNumberMeta,
        ),
      );
    }
    if (data.containsKey('rfid_number')) {
      context.handle(
        _rfidNumberMeta,
        rfidNumber.isAcceptableOrUnknown(data['rfid_number']!, _rfidNumberMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('registration_number')) {
      context.handle(
        _registrationNumberMeta,
        registrationNumber.isAcceptableOrUnknown(
          data['registration_number']!,
          _registrationNumberMeta,
        ),
      );
    }
    if (data.containsKey('species_id')) {
      context.handle(
        _speciesIdMeta,
        speciesId.isAcceptableOrUnknown(data['species_id']!, _speciesIdMeta),
      );
    } else if (isInserting) {
      context.missing(_speciesIdMeta);
    }
    if (data.containsKey('species_name')) {
      context.handle(
        _speciesNameMeta,
        speciesName.isAcceptableOrUnknown(
          data['species_name']!,
          _speciesNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_speciesNameMeta);
    }
    if (data.containsKey('breed_id')) {
      context.handle(
        _breedIdMeta,
        breedId.isAcceptableOrUnknown(data['breed_id']!, _breedIdMeta),
      );
    } else if (isInserting) {
      context.missing(_breedIdMeta);
    }
    if (data.containsKey('breed_name')) {
      context.handle(
        _breedNameMeta,
        breedName.isAcceptableOrUnknown(data['breed_name']!, _breedNameMeta),
      );
    } else if (isInserting) {
      context.missing(_breedNameMeta);
    }
    if (data.containsKey('sex')) {
      context.handle(
        _sexMeta,
        sex.isAcceptableOrUnknown(data['sex']!, _sexMeta),
      );
    } else if (isInserting) {
      context.missing(_sexMeta);
    }
    if (data.containsKey('life_stage')) {
      context.handle(
        _lifeStageMeta,
        lifeStage.isAcceptableOrUnknown(data['life_stage']!, _lifeStageMeta),
      );
    } else if (isInserting) {
      context.missing(_lifeStageMeta);
    }
    if (data.containsKey('date_of_birth')) {
      context.handle(
        _dateOfBirthMeta,
        dateOfBirth.isAcceptableOrUnknown(
          data['date_of_birth']!,
          _dateOfBirthMeta,
        ),
      );
    }
    if (data.containsKey('is_date_of_birth_estimated')) {
      context.handle(
        _isDateOfBirthEstimatedMeta,
        isDateOfBirthEstimated.isAcceptableOrUnknown(
          data['is_date_of_birth_estimated']!,
          _isDateOfBirthEstimatedMeta,
        ),
      );
    }
    if (data.containsKey('colour')) {
      context.handle(
        _colourMeta,
        colour.isAcceptableOrUnknown(data['colour']!, _colourMeta),
      );
    }
    if (data.containsKey('identifying_marks')) {
      context.handle(
        _identifyingMarksMeta,
        identifyingMarks.isAcceptableOrUnknown(
          data['identifying_marks']!,
          _identifyingMarksMeta,
        ),
      );
    }
    if (data.containsKey('current_farm_id')) {
      context.handle(
        _currentFarmIdMeta,
        currentFarmId.isAcceptableOrUnknown(
          data['current_farm_id']!,
          _currentFarmIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currentFarmIdMeta);
    }
    if (data.containsKey('current_farm_name')) {
      context.handle(
        _currentFarmNameMeta,
        currentFarmName.isAcceptableOrUnknown(
          data['current_farm_name']!,
          _currentFarmNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currentFarmNameMeta);
    }
    if (data.containsKey('current_shed_id')) {
      context.handle(
        _currentShedIdMeta,
        currentShedId.isAcceptableOrUnknown(
          data['current_shed_id']!,
          _currentShedIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currentShedIdMeta);
    }
    if (data.containsKey('current_shed_name')) {
      context.handle(
        _currentShedNameMeta,
        currentShedName.isAcceptableOrUnknown(
          data['current_shed_name']!,
          _currentShedNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currentShedNameMeta);
    }
    if (data.containsKey('current_animal_group_id')) {
      context.handle(
        _currentAnimalGroupIdMeta,
        currentAnimalGroupId.isAcceptableOrUnknown(
          data['current_animal_group_id']!,
          _currentAnimalGroupIdMeta,
        ),
      );
    }
    if (data.containsKey('current_animal_group_name')) {
      context.handle(
        _currentAnimalGroupNameMeta,
        currentAnimalGroupName.isAcceptableOrUnknown(
          data['current_animal_group_name']!,
          _currentAnimalGroupNameMeta,
        ),
      );
    }
    if (data.containsKey('mother_animal_id')) {
      context.handle(
        _motherAnimalIdMeta,
        motherAnimalId.isAcceptableOrUnknown(
          data['mother_animal_id']!,
          _motherAnimalIdMeta,
        ),
      );
    }
    if (data.containsKey('mother_animal_number')) {
      context.handle(
        _motherAnimalNumberMeta,
        motherAnimalNumber.isAcceptableOrUnknown(
          data['mother_animal_number']!,
          _motherAnimalNumberMeta,
        ),
      );
    }
    if (data.containsKey('father_animal_id')) {
      context.handle(
        _fatherAnimalIdMeta,
        fatherAnimalId.isAcceptableOrUnknown(
          data['father_animal_id']!,
          _fatherAnimalIdMeta,
        ),
      );
    }
    if (data.containsKey('father_animal_number')) {
      context.handle(
        _fatherAnimalNumberMeta,
        fatherAnimalNumber.isAcceptableOrUnknown(
          data['father_animal_number']!,
          _fatherAnimalNumberMeta,
        ),
      );
    }
    if (data.containsKey('external_sire_reference')) {
      context.handle(
        _externalSireReferenceMeta,
        externalSireReference.isAcceptableOrUnknown(
          data['external_sire_reference']!,
          _externalSireReferenceMeta,
        ),
      );
    }
    if (data.containsKey('origin')) {
      context.handle(
        _originMeta,
        origin.isAcceptableOrUnknown(data['origin']!, _originMeta),
      );
    } else if (isInserting) {
      context.missing(_originMeta);
    }
    if (data.containsKey('acquisition_date')) {
      context.handle(
        _acquisitionDateMeta,
        acquisitionDate.isAcceptableOrUnknown(
          data['acquisition_date']!,
          _acquisitionDateMeta,
        ),
      );
    }
    if (data.containsKey('source_description')) {
      context.handle(
        _sourceDescriptionMeta,
        sourceDescription.isAcceptableOrUnknown(
          data['source_description']!,
          _sourceDescriptionMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('operational_status')) {
      context.handle(
        _operationalStatusMeta,
        operationalStatus.isAcceptableOrUnknown(
          data['operational_status']!,
          _operationalStatusMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_operationalStatusMeta);
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
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    if (data.containsKey('is_accessible')) {
      context.handle(
        _isAccessibleMeta,
        isAccessible.isAcceptableOrUnknown(
          data['is_accessible']!,
          _isAccessibleMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalAnimal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalAnimal(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      organizationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}organization_id'],
      )!,
      animalNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}animal_number'],
      )!,
      earTagNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ear_tag_number'],
      ),
      rfidNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rfid_number'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      registrationNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}registration_number'],
      ),
      speciesId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}species_id'],
      )!,
      speciesName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}species_name'],
      )!,
      breedId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}breed_id'],
      )!,
      breedName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}breed_name'],
      )!,
      sex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sex'],
      )!,
      lifeStage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}life_stage'],
      )!,
      dateOfBirth: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_of_birth'],
      ),
      isDateOfBirthEstimated: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_date_of_birth_estimated'],
      )!,
      colour: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}colour'],
      ),
      identifyingMarks: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}identifying_marks'],
      ),
      currentFarmId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}current_farm_id'],
      )!,
      currentFarmName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}current_farm_name'],
      )!,
      currentShedId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}current_shed_id'],
      )!,
      currentShedName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}current_shed_name'],
      )!,
      currentAnimalGroupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}current_animal_group_id'],
      ),
      currentAnimalGroupName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}current_animal_group_name'],
      ),
      motherAnimalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mother_animal_id'],
      ),
      motherAnimalNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mother_animal_number'],
      ),
      fatherAnimalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}father_animal_id'],
      ),
      fatherAnimalNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}father_animal_number'],
      ),
      externalSireReference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}external_sire_reference'],
      ),
      origin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin'],
      )!,
      acquisitionDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}acquisition_date'],
      ),
      sourceDescription: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_description'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      operationalStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operational_status'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}server_updated_at'],
      )!,
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
      isAccessible: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_accessible'],
      )!,
    );
  }

  @override
  $LocalAnimalsTable createAlias(String alias) {
    return $LocalAnimalsTable(attachedDatabase, alias);
  }
}

class LocalAnimal extends DataClass implements Insertable<LocalAnimal> {
  final String id;
  final String organizationId;
  final String animalNumber;
  final String? earTagNumber;
  final String? rfidNumber;
  final String? name;
  final String? registrationNumber;
  final String speciesId;
  final String speciesName;
  final String breedId;
  final String breedName;
  final String sex;
  final String lifeStage;
  final DateTime? dateOfBirth;
  final bool isDateOfBirthEstimated;
  final String? colour;
  final String? identifyingMarks;
  final String currentFarmId;
  final String currentFarmName;
  final String currentShedId;
  final String currentShedName;
  final String? currentAnimalGroupId;
  final String? currentAnimalGroupName;
  final String? motherAnimalId;
  final String? motherAnimalNumber;
  final String? fatherAnimalId;
  final String? fatherAnimalNumber;
  final String? externalSireReference;
  final String origin;
  final DateTime? acquisitionDate;
  final String? sourceDescription;
  final String? notes;
  final String operationalStatus;
  final int version;
  final DateTime serverUpdatedAt;
  final DateTime cachedAt;
  final bool isArchived;
  final bool isAccessible;
  const LocalAnimal({
    required this.id,
    required this.organizationId,
    required this.animalNumber,
    this.earTagNumber,
    this.rfidNumber,
    this.name,
    this.registrationNumber,
    required this.speciesId,
    required this.speciesName,
    required this.breedId,
    required this.breedName,
    required this.sex,
    required this.lifeStage,
    this.dateOfBirth,
    required this.isDateOfBirthEstimated,
    this.colour,
    this.identifyingMarks,
    required this.currentFarmId,
    required this.currentFarmName,
    required this.currentShedId,
    required this.currentShedName,
    this.currentAnimalGroupId,
    this.currentAnimalGroupName,
    this.motherAnimalId,
    this.motherAnimalNumber,
    this.fatherAnimalId,
    this.fatherAnimalNumber,
    this.externalSireReference,
    required this.origin,
    this.acquisitionDate,
    this.sourceDescription,
    this.notes,
    required this.operationalStatus,
    required this.version,
    required this.serverUpdatedAt,
    required this.cachedAt,
    required this.isArchived,
    required this.isAccessible,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['organization_id'] = Variable<String>(organizationId);
    map['animal_number'] = Variable<String>(animalNumber);
    if (!nullToAbsent || earTagNumber != null) {
      map['ear_tag_number'] = Variable<String>(earTagNumber);
    }
    if (!nullToAbsent || rfidNumber != null) {
      map['rfid_number'] = Variable<String>(rfidNumber);
    }
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || registrationNumber != null) {
      map['registration_number'] = Variable<String>(registrationNumber);
    }
    map['species_id'] = Variable<String>(speciesId);
    map['species_name'] = Variable<String>(speciesName);
    map['breed_id'] = Variable<String>(breedId);
    map['breed_name'] = Variable<String>(breedName);
    map['sex'] = Variable<String>(sex);
    map['life_stage'] = Variable<String>(lifeStage);
    if (!nullToAbsent || dateOfBirth != null) {
      map['date_of_birth'] = Variable<DateTime>(dateOfBirth);
    }
    map['is_date_of_birth_estimated'] = Variable<bool>(isDateOfBirthEstimated);
    if (!nullToAbsent || colour != null) {
      map['colour'] = Variable<String>(colour);
    }
    if (!nullToAbsent || identifyingMarks != null) {
      map['identifying_marks'] = Variable<String>(identifyingMarks);
    }
    map['current_farm_id'] = Variable<String>(currentFarmId);
    map['current_farm_name'] = Variable<String>(currentFarmName);
    map['current_shed_id'] = Variable<String>(currentShedId);
    map['current_shed_name'] = Variable<String>(currentShedName);
    if (!nullToAbsent || currentAnimalGroupId != null) {
      map['current_animal_group_id'] = Variable<String>(currentAnimalGroupId);
    }
    if (!nullToAbsent || currentAnimalGroupName != null) {
      map['current_animal_group_name'] = Variable<String>(
        currentAnimalGroupName,
      );
    }
    if (!nullToAbsent || motherAnimalId != null) {
      map['mother_animal_id'] = Variable<String>(motherAnimalId);
    }
    if (!nullToAbsent || motherAnimalNumber != null) {
      map['mother_animal_number'] = Variable<String>(motherAnimalNumber);
    }
    if (!nullToAbsent || fatherAnimalId != null) {
      map['father_animal_id'] = Variable<String>(fatherAnimalId);
    }
    if (!nullToAbsent || fatherAnimalNumber != null) {
      map['father_animal_number'] = Variable<String>(fatherAnimalNumber);
    }
    if (!nullToAbsent || externalSireReference != null) {
      map['external_sire_reference'] = Variable<String>(externalSireReference);
    }
    map['origin'] = Variable<String>(origin);
    if (!nullToAbsent || acquisitionDate != null) {
      map['acquisition_date'] = Variable<DateTime>(acquisitionDate);
    }
    if (!nullToAbsent || sourceDescription != null) {
      map['source_description'] = Variable<String>(sourceDescription);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['operational_status'] = Variable<String>(operationalStatus);
    map['version'] = Variable<int>(version);
    map['server_updated_at'] = Variable<DateTime>(serverUpdatedAt);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    map['is_archived'] = Variable<bool>(isArchived);
    map['is_accessible'] = Variable<bool>(isAccessible);
    return map;
  }

  LocalAnimalsCompanion toCompanion(bool nullToAbsent) {
    return LocalAnimalsCompanion(
      id: Value(id),
      organizationId: Value(organizationId),
      animalNumber: Value(animalNumber),
      earTagNumber: earTagNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(earTagNumber),
      rfidNumber: rfidNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(rfidNumber),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      registrationNumber: registrationNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(registrationNumber),
      speciesId: Value(speciesId),
      speciesName: Value(speciesName),
      breedId: Value(breedId),
      breedName: Value(breedName),
      sex: Value(sex),
      lifeStage: Value(lifeStage),
      dateOfBirth: dateOfBirth == null && nullToAbsent
          ? const Value.absent()
          : Value(dateOfBirth),
      isDateOfBirthEstimated: Value(isDateOfBirthEstimated),
      colour: colour == null && nullToAbsent
          ? const Value.absent()
          : Value(colour),
      identifyingMarks: identifyingMarks == null && nullToAbsent
          ? const Value.absent()
          : Value(identifyingMarks),
      currentFarmId: Value(currentFarmId),
      currentFarmName: Value(currentFarmName),
      currentShedId: Value(currentShedId),
      currentShedName: Value(currentShedName),
      currentAnimalGroupId: currentAnimalGroupId == null && nullToAbsent
          ? const Value.absent()
          : Value(currentAnimalGroupId),
      currentAnimalGroupName: currentAnimalGroupName == null && nullToAbsent
          ? const Value.absent()
          : Value(currentAnimalGroupName),
      motherAnimalId: motherAnimalId == null && nullToAbsent
          ? const Value.absent()
          : Value(motherAnimalId),
      motherAnimalNumber: motherAnimalNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(motherAnimalNumber),
      fatherAnimalId: fatherAnimalId == null && nullToAbsent
          ? const Value.absent()
          : Value(fatherAnimalId),
      fatherAnimalNumber: fatherAnimalNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(fatherAnimalNumber),
      externalSireReference: externalSireReference == null && nullToAbsent
          ? const Value.absent()
          : Value(externalSireReference),
      origin: Value(origin),
      acquisitionDate: acquisitionDate == null && nullToAbsent
          ? const Value.absent()
          : Value(acquisitionDate),
      sourceDescription: sourceDescription == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceDescription),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      operationalStatus: Value(operationalStatus),
      version: Value(version),
      serverUpdatedAt: Value(serverUpdatedAt),
      cachedAt: Value(cachedAt),
      isArchived: Value(isArchived),
      isAccessible: Value(isAccessible),
    );
  }

  factory LocalAnimal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalAnimal(
      id: serializer.fromJson<String>(json['id']),
      organizationId: serializer.fromJson<String>(json['organizationId']),
      animalNumber: serializer.fromJson<String>(json['animalNumber']),
      earTagNumber: serializer.fromJson<String?>(json['earTagNumber']),
      rfidNumber: serializer.fromJson<String?>(json['rfidNumber']),
      name: serializer.fromJson<String?>(json['name']),
      registrationNumber: serializer.fromJson<String?>(
        json['registrationNumber'],
      ),
      speciesId: serializer.fromJson<String>(json['speciesId']),
      speciesName: serializer.fromJson<String>(json['speciesName']),
      breedId: serializer.fromJson<String>(json['breedId']),
      breedName: serializer.fromJson<String>(json['breedName']),
      sex: serializer.fromJson<String>(json['sex']),
      lifeStage: serializer.fromJson<String>(json['lifeStage']),
      dateOfBirth: serializer.fromJson<DateTime?>(json['dateOfBirth']),
      isDateOfBirthEstimated: serializer.fromJson<bool>(
        json['isDateOfBirthEstimated'],
      ),
      colour: serializer.fromJson<String?>(json['colour']),
      identifyingMarks: serializer.fromJson<String?>(json['identifyingMarks']),
      currentFarmId: serializer.fromJson<String>(json['currentFarmId']),
      currentFarmName: serializer.fromJson<String>(json['currentFarmName']),
      currentShedId: serializer.fromJson<String>(json['currentShedId']),
      currentShedName: serializer.fromJson<String>(json['currentShedName']),
      currentAnimalGroupId: serializer.fromJson<String?>(
        json['currentAnimalGroupId'],
      ),
      currentAnimalGroupName: serializer.fromJson<String?>(
        json['currentAnimalGroupName'],
      ),
      motherAnimalId: serializer.fromJson<String?>(json['motherAnimalId']),
      motherAnimalNumber: serializer.fromJson<String?>(
        json['motherAnimalNumber'],
      ),
      fatherAnimalId: serializer.fromJson<String?>(json['fatherAnimalId']),
      fatherAnimalNumber: serializer.fromJson<String?>(
        json['fatherAnimalNumber'],
      ),
      externalSireReference: serializer.fromJson<String?>(
        json['externalSireReference'],
      ),
      origin: serializer.fromJson<String>(json['origin']),
      acquisitionDate: serializer.fromJson<DateTime?>(json['acquisitionDate']),
      sourceDescription: serializer.fromJson<String?>(
        json['sourceDescription'],
      ),
      notes: serializer.fromJson<String?>(json['notes']),
      operationalStatus: serializer.fromJson<String>(json['operationalStatus']),
      version: serializer.fromJson<int>(json['version']),
      serverUpdatedAt: serializer.fromJson<DateTime>(json['serverUpdatedAt']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      isAccessible: serializer.fromJson<bool>(json['isAccessible']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'organizationId': serializer.toJson<String>(organizationId),
      'animalNumber': serializer.toJson<String>(animalNumber),
      'earTagNumber': serializer.toJson<String?>(earTagNumber),
      'rfidNumber': serializer.toJson<String?>(rfidNumber),
      'name': serializer.toJson<String?>(name),
      'registrationNumber': serializer.toJson<String?>(registrationNumber),
      'speciesId': serializer.toJson<String>(speciesId),
      'speciesName': serializer.toJson<String>(speciesName),
      'breedId': serializer.toJson<String>(breedId),
      'breedName': serializer.toJson<String>(breedName),
      'sex': serializer.toJson<String>(sex),
      'lifeStage': serializer.toJson<String>(lifeStage),
      'dateOfBirth': serializer.toJson<DateTime?>(dateOfBirth),
      'isDateOfBirthEstimated': serializer.toJson<bool>(isDateOfBirthEstimated),
      'colour': serializer.toJson<String?>(colour),
      'identifyingMarks': serializer.toJson<String?>(identifyingMarks),
      'currentFarmId': serializer.toJson<String>(currentFarmId),
      'currentFarmName': serializer.toJson<String>(currentFarmName),
      'currentShedId': serializer.toJson<String>(currentShedId),
      'currentShedName': serializer.toJson<String>(currentShedName),
      'currentAnimalGroupId': serializer.toJson<String?>(currentAnimalGroupId),
      'currentAnimalGroupName': serializer.toJson<String?>(
        currentAnimalGroupName,
      ),
      'motherAnimalId': serializer.toJson<String?>(motherAnimalId),
      'motherAnimalNumber': serializer.toJson<String?>(motherAnimalNumber),
      'fatherAnimalId': serializer.toJson<String?>(fatherAnimalId),
      'fatherAnimalNumber': serializer.toJson<String?>(fatherAnimalNumber),
      'externalSireReference': serializer.toJson<String?>(
        externalSireReference,
      ),
      'origin': serializer.toJson<String>(origin),
      'acquisitionDate': serializer.toJson<DateTime?>(acquisitionDate),
      'sourceDescription': serializer.toJson<String?>(sourceDescription),
      'notes': serializer.toJson<String?>(notes),
      'operationalStatus': serializer.toJson<String>(operationalStatus),
      'version': serializer.toJson<int>(version),
      'serverUpdatedAt': serializer.toJson<DateTime>(serverUpdatedAt),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
      'isArchived': serializer.toJson<bool>(isArchived),
      'isAccessible': serializer.toJson<bool>(isAccessible),
    };
  }

  LocalAnimal copyWith({
    String? id,
    String? organizationId,
    String? animalNumber,
    Value<String?> earTagNumber = const Value.absent(),
    Value<String?> rfidNumber = const Value.absent(),
    Value<String?> name = const Value.absent(),
    Value<String?> registrationNumber = const Value.absent(),
    String? speciesId,
    String? speciesName,
    String? breedId,
    String? breedName,
    String? sex,
    String? lifeStage,
    Value<DateTime?> dateOfBirth = const Value.absent(),
    bool? isDateOfBirthEstimated,
    Value<String?> colour = const Value.absent(),
    Value<String?> identifyingMarks = const Value.absent(),
    String? currentFarmId,
    String? currentFarmName,
    String? currentShedId,
    String? currentShedName,
    Value<String?> currentAnimalGroupId = const Value.absent(),
    Value<String?> currentAnimalGroupName = const Value.absent(),
    Value<String?> motherAnimalId = const Value.absent(),
    Value<String?> motherAnimalNumber = const Value.absent(),
    Value<String?> fatherAnimalId = const Value.absent(),
    Value<String?> fatherAnimalNumber = const Value.absent(),
    Value<String?> externalSireReference = const Value.absent(),
    String? origin,
    Value<DateTime?> acquisitionDate = const Value.absent(),
    Value<String?> sourceDescription = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    String? operationalStatus,
    int? version,
    DateTime? serverUpdatedAt,
    DateTime? cachedAt,
    bool? isArchived,
    bool? isAccessible,
  }) => LocalAnimal(
    id: id ?? this.id,
    organizationId: organizationId ?? this.organizationId,
    animalNumber: animalNumber ?? this.animalNumber,
    earTagNumber: earTagNumber.present ? earTagNumber.value : this.earTagNumber,
    rfidNumber: rfidNumber.present ? rfidNumber.value : this.rfidNumber,
    name: name.present ? name.value : this.name,
    registrationNumber: registrationNumber.present
        ? registrationNumber.value
        : this.registrationNumber,
    speciesId: speciesId ?? this.speciesId,
    speciesName: speciesName ?? this.speciesName,
    breedId: breedId ?? this.breedId,
    breedName: breedName ?? this.breedName,
    sex: sex ?? this.sex,
    lifeStage: lifeStage ?? this.lifeStage,
    dateOfBirth: dateOfBirth.present ? dateOfBirth.value : this.dateOfBirth,
    isDateOfBirthEstimated:
        isDateOfBirthEstimated ?? this.isDateOfBirthEstimated,
    colour: colour.present ? colour.value : this.colour,
    identifyingMarks: identifyingMarks.present
        ? identifyingMarks.value
        : this.identifyingMarks,
    currentFarmId: currentFarmId ?? this.currentFarmId,
    currentFarmName: currentFarmName ?? this.currentFarmName,
    currentShedId: currentShedId ?? this.currentShedId,
    currentShedName: currentShedName ?? this.currentShedName,
    currentAnimalGroupId: currentAnimalGroupId.present
        ? currentAnimalGroupId.value
        : this.currentAnimalGroupId,
    currentAnimalGroupName: currentAnimalGroupName.present
        ? currentAnimalGroupName.value
        : this.currentAnimalGroupName,
    motherAnimalId: motherAnimalId.present
        ? motherAnimalId.value
        : this.motherAnimalId,
    motherAnimalNumber: motherAnimalNumber.present
        ? motherAnimalNumber.value
        : this.motherAnimalNumber,
    fatherAnimalId: fatherAnimalId.present
        ? fatherAnimalId.value
        : this.fatherAnimalId,
    fatherAnimalNumber: fatherAnimalNumber.present
        ? fatherAnimalNumber.value
        : this.fatherAnimalNumber,
    externalSireReference: externalSireReference.present
        ? externalSireReference.value
        : this.externalSireReference,
    origin: origin ?? this.origin,
    acquisitionDate: acquisitionDate.present
        ? acquisitionDate.value
        : this.acquisitionDate,
    sourceDescription: sourceDescription.present
        ? sourceDescription.value
        : this.sourceDescription,
    notes: notes.present ? notes.value : this.notes,
    operationalStatus: operationalStatus ?? this.operationalStatus,
    version: version ?? this.version,
    serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
    cachedAt: cachedAt ?? this.cachedAt,
    isArchived: isArchived ?? this.isArchived,
    isAccessible: isAccessible ?? this.isAccessible,
  );
  LocalAnimal copyWithCompanion(LocalAnimalsCompanion data) {
    return LocalAnimal(
      id: data.id.present ? data.id.value : this.id,
      organizationId: data.organizationId.present
          ? data.organizationId.value
          : this.organizationId,
      animalNumber: data.animalNumber.present
          ? data.animalNumber.value
          : this.animalNumber,
      earTagNumber: data.earTagNumber.present
          ? data.earTagNumber.value
          : this.earTagNumber,
      rfidNumber: data.rfidNumber.present
          ? data.rfidNumber.value
          : this.rfidNumber,
      name: data.name.present ? data.name.value : this.name,
      registrationNumber: data.registrationNumber.present
          ? data.registrationNumber.value
          : this.registrationNumber,
      speciesId: data.speciesId.present ? data.speciesId.value : this.speciesId,
      speciesName: data.speciesName.present
          ? data.speciesName.value
          : this.speciesName,
      breedId: data.breedId.present ? data.breedId.value : this.breedId,
      breedName: data.breedName.present ? data.breedName.value : this.breedName,
      sex: data.sex.present ? data.sex.value : this.sex,
      lifeStage: data.lifeStage.present ? data.lifeStage.value : this.lifeStage,
      dateOfBirth: data.dateOfBirth.present
          ? data.dateOfBirth.value
          : this.dateOfBirth,
      isDateOfBirthEstimated: data.isDateOfBirthEstimated.present
          ? data.isDateOfBirthEstimated.value
          : this.isDateOfBirthEstimated,
      colour: data.colour.present ? data.colour.value : this.colour,
      identifyingMarks: data.identifyingMarks.present
          ? data.identifyingMarks.value
          : this.identifyingMarks,
      currentFarmId: data.currentFarmId.present
          ? data.currentFarmId.value
          : this.currentFarmId,
      currentFarmName: data.currentFarmName.present
          ? data.currentFarmName.value
          : this.currentFarmName,
      currentShedId: data.currentShedId.present
          ? data.currentShedId.value
          : this.currentShedId,
      currentShedName: data.currentShedName.present
          ? data.currentShedName.value
          : this.currentShedName,
      currentAnimalGroupId: data.currentAnimalGroupId.present
          ? data.currentAnimalGroupId.value
          : this.currentAnimalGroupId,
      currentAnimalGroupName: data.currentAnimalGroupName.present
          ? data.currentAnimalGroupName.value
          : this.currentAnimalGroupName,
      motherAnimalId: data.motherAnimalId.present
          ? data.motherAnimalId.value
          : this.motherAnimalId,
      motherAnimalNumber: data.motherAnimalNumber.present
          ? data.motherAnimalNumber.value
          : this.motherAnimalNumber,
      fatherAnimalId: data.fatherAnimalId.present
          ? data.fatherAnimalId.value
          : this.fatherAnimalId,
      fatherAnimalNumber: data.fatherAnimalNumber.present
          ? data.fatherAnimalNumber.value
          : this.fatherAnimalNumber,
      externalSireReference: data.externalSireReference.present
          ? data.externalSireReference.value
          : this.externalSireReference,
      origin: data.origin.present ? data.origin.value : this.origin,
      acquisitionDate: data.acquisitionDate.present
          ? data.acquisitionDate.value
          : this.acquisitionDate,
      sourceDescription: data.sourceDescription.present
          ? data.sourceDescription.value
          : this.sourceDescription,
      notes: data.notes.present ? data.notes.value : this.notes,
      operationalStatus: data.operationalStatus.present
          ? data.operationalStatus.value
          : this.operationalStatus,
      version: data.version.present ? data.version.value : this.version,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
      isAccessible: data.isAccessible.present
          ? data.isAccessible.value
          : this.isAccessible,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalAnimal(')
          ..write('id: $id, ')
          ..write('organizationId: $organizationId, ')
          ..write('animalNumber: $animalNumber, ')
          ..write('earTagNumber: $earTagNumber, ')
          ..write('rfidNumber: $rfidNumber, ')
          ..write('name: $name, ')
          ..write('registrationNumber: $registrationNumber, ')
          ..write('speciesId: $speciesId, ')
          ..write('speciesName: $speciesName, ')
          ..write('breedId: $breedId, ')
          ..write('breedName: $breedName, ')
          ..write('sex: $sex, ')
          ..write('lifeStage: $lifeStage, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('isDateOfBirthEstimated: $isDateOfBirthEstimated, ')
          ..write('colour: $colour, ')
          ..write('identifyingMarks: $identifyingMarks, ')
          ..write('currentFarmId: $currentFarmId, ')
          ..write('currentFarmName: $currentFarmName, ')
          ..write('currentShedId: $currentShedId, ')
          ..write('currentShedName: $currentShedName, ')
          ..write('currentAnimalGroupId: $currentAnimalGroupId, ')
          ..write('currentAnimalGroupName: $currentAnimalGroupName, ')
          ..write('motherAnimalId: $motherAnimalId, ')
          ..write('motherAnimalNumber: $motherAnimalNumber, ')
          ..write('fatherAnimalId: $fatherAnimalId, ')
          ..write('fatherAnimalNumber: $fatherAnimalNumber, ')
          ..write('externalSireReference: $externalSireReference, ')
          ..write('origin: $origin, ')
          ..write('acquisitionDate: $acquisitionDate, ')
          ..write('sourceDescription: $sourceDescription, ')
          ..write('notes: $notes, ')
          ..write('operationalStatus: $operationalStatus, ')
          ..write('version: $version, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('isArchived: $isArchived, ')
          ..write('isAccessible: $isAccessible')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    organizationId,
    animalNumber,
    earTagNumber,
    rfidNumber,
    name,
    registrationNumber,
    speciesId,
    speciesName,
    breedId,
    breedName,
    sex,
    lifeStage,
    dateOfBirth,
    isDateOfBirthEstimated,
    colour,
    identifyingMarks,
    currentFarmId,
    currentFarmName,
    currentShedId,
    currentShedName,
    currentAnimalGroupId,
    currentAnimalGroupName,
    motherAnimalId,
    motherAnimalNumber,
    fatherAnimalId,
    fatherAnimalNumber,
    externalSireReference,
    origin,
    acquisitionDate,
    sourceDescription,
    notes,
    operationalStatus,
    version,
    serverUpdatedAt,
    cachedAt,
    isArchived,
    isAccessible,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalAnimal &&
          other.id == this.id &&
          other.organizationId == this.organizationId &&
          other.animalNumber == this.animalNumber &&
          other.earTagNumber == this.earTagNumber &&
          other.rfidNumber == this.rfidNumber &&
          other.name == this.name &&
          other.registrationNumber == this.registrationNumber &&
          other.speciesId == this.speciesId &&
          other.speciesName == this.speciesName &&
          other.breedId == this.breedId &&
          other.breedName == this.breedName &&
          other.sex == this.sex &&
          other.lifeStage == this.lifeStage &&
          other.dateOfBirth == this.dateOfBirth &&
          other.isDateOfBirthEstimated == this.isDateOfBirthEstimated &&
          other.colour == this.colour &&
          other.identifyingMarks == this.identifyingMarks &&
          other.currentFarmId == this.currentFarmId &&
          other.currentFarmName == this.currentFarmName &&
          other.currentShedId == this.currentShedId &&
          other.currentShedName == this.currentShedName &&
          other.currentAnimalGroupId == this.currentAnimalGroupId &&
          other.currentAnimalGroupName == this.currentAnimalGroupName &&
          other.motherAnimalId == this.motherAnimalId &&
          other.motherAnimalNumber == this.motherAnimalNumber &&
          other.fatherAnimalId == this.fatherAnimalId &&
          other.fatherAnimalNumber == this.fatherAnimalNumber &&
          other.externalSireReference == this.externalSireReference &&
          other.origin == this.origin &&
          other.acquisitionDate == this.acquisitionDate &&
          other.sourceDescription == this.sourceDescription &&
          other.notes == this.notes &&
          other.operationalStatus == this.operationalStatus &&
          other.version == this.version &&
          other.serverUpdatedAt == this.serverUpdatedAt &&
          other.cachedAt == this.cachedAt &&
          other.isArchived == this.isArchived &&
          other.isAccessible == this.isAccessible);
}

class LocalAnimalsCompanion extends UpdateCompanion<LocalAnimal> {
  final Value<String> id;
  final Value<String> organizationId;
  final Value<String> animalNumber;
  final Value<String?> earTagNumber;
  final Value<String?> rfidNumber;
  final Value<String?> name;
  final Value<String?> registrationNumber;
  final Value<String> speciesId;
  final Value<String> speciesName;
  final Value<String> breedId;
  final Value<String> breedName;
  final Value<String> sex;
  final Value<String> lifeStage;
  final Value<DateTime?> dateOfBirth;
  final Value<bool> isDateOfBirthEstimated;
  final Value<String?> colour;
  final Value<String?> identifyingMarks;
  final Value<String> currentFarmId;
  final Value<String> currentFarmName;
  final Value<String> currentShedId;
  final Value<String> currentShedName;
  final Value<String?> currentAnimalGroupId;
  final Value<String?> currentAnimalGroupName;
  final Value<String?> motherAnimalId;
  final Value<String?> motherAnimalNumber;
  final Value<String?> fatherAnimalId;
  final Value<String?> fatherAnimalNumber;
  final Value<String?> externalSireReference;
  final Value<String> origin;
  final Value<DateTime?> acquisitionDate;
  final Value<String?> sourceDescription;
  final Value<String?> notes;
  final Value<String> operationalStatus;
  final Value<int> version;
  final Value<DateTime> serverUpdatedAt;
  final Value<DateTime> cachedAt;
  final Value<bool> isArchived;
  final Value<bool> isAccessible;
  final Value<int> rowid;
  const LocalAnimalsCompanion({
    this.id = const Value.absent(),
    this.organizationId = const Value.absent(),
    this.animalNumber = const Value.absent(),
    this.earTagNumber = const Value.absent(),
    this.rfidNumber = const Value.absent(),
    this.name = const Value.absent(),
    this.registrationNumber = const Value.absent(),
    this.speciesId = const Value.absent(),
    this.speciesName = const Value.absent(),
    this.breedId = const Value.absent(),
    this.breedName = const Value.absent(),
    this.sex = const Value.absent(),
    this.lifeStage = const Value.absent(),
    this.dateOfBirth = const Value.absent(),
    this.isDateOfBirthEstimated = const Value.absent(),
    this.colour = const Value.absent(),
    this.identifyingMarks = const Value.absent(),
    this.currentFarmId = const Value.absent(),
    this.currentFarmName = const Value.absent(),
    this.currentShedId = const Value.absent(),
    this.currentShedName = const Value.absent(),
    this.currentAnimalGroupId = const Value.absent(),
    this.currentAnimalGroupName = const Value.absent(),
    this.motherAnimalId = const Value.absent(),
    this.motherAnimalNumber = const Value.absent(),
    this.fatherAnimalId = const Value.absent(),
    this.fatherAnimalNumber = const Value.absent(),
    this.externalSireReference = const Value.absent(),
    this.origin = const Value.absent(),
    this.acquisitionDate = const Value.absent(),
    this.sourceDescription = const Value.absent(),
    this.notes = const Value.absent(),
    this.operationalStatus = const Value.absent(),
    this.version = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.isAccessible = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalAnimalsCompanion.insert({
    required String id,
    required String organizationId,
    required String animalNumber,
    this.earTagNumber = const Value.absent(),
    this.rfidNumber = const Value.absent(),
    this.name = const Value.absent(),
    this.registrationNumber = const Value.absent(),
    required String speciesId,
    required String speciesName,
    required String breedId,
    required String breedName,
    required String sex,
    required String lifeStage,
    this.dateOfBirth = const Value.absent(),
    this.isDateOfBirthEstimated = const Value.absent(),
    this.colour = const Value.absent(),
    this.identifyingMarks = const Value.absent(),
    required String currentFarmId,
    required String currentFarmName,
    required String currentShedId,
    required String currentShedName,
    this.currentAnimalGroupId = const Value.absent(),
    this.currentAnimalGroupName = const Value.absent(),
    this.motherAnimalId = const Value.absent(),
    this.motherAnimalNumber = const Value.absent(),
    this.fatherAnimalId = const Value.absent(),
    this.fatherAnimalNumber = const Value.absent(),
    this.externalSireReference = const Value.absent(),
    required String origin,
    this.acquisitionDate = const Value.absent(),
    this.sourceDescription = const Value.absent(),
    this.notes = const Value.absent(),
    required String operationalStatus,
    this.version = const Value.absent(),
    required DateTime serverUpdatedAt,
    required DateTime cachedAt,
    this.isArchived = const Value.absent(),
    this.isAccessible = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       organizationId = Value(organizationId),
       animalNumber = Value(animalNumber),
       speciesId = Value(speciesId),
       speciesName = Value(speciesName),
       breedId = Value(breedId),
       breedName = Value(breedName),
       sex = Value(sex),
       lifeStage = Value(lifeStage),
       currentFarmId = Value(currentFarmId),
       currentFarmName = Value(currentFarmName),
       currentShedId = Value(currentShedId),
       currentShedName = Value(currentShedName),
       origin = Value(origin),
       operationalStatus = Value(operationalStatus),
       serverUpdatedAt = Value(serverUpdatedAt),
       cachedAt = Value(cachedAt);
  static Insertable<LocalAnimal> custom({
    Expression<String>? id,
    Expression<String>? organizationId,
    Expression<String>? animalNumber,
    Expression<String>? earTagNumber,
    Expression<String>? rfidNumber,
    Expression<String>? name,
    Expression<String>? registrationNumber,
    Expression<String>? speciesId,
    Expression<String>? speciesName,
    Expression<String>? breedId,
    Expression<String>? breedName,
    Expression<String>? sex,
    Expression<String>? lifeStage,
    Expression<DateTime>? dateOfBirth,
    Expression<bool>? isDateOfBirthEstimated,
    Expression<String>? colour,
    Expression<String>? identifyingMarks,
    Expression<String>? currentFarmId,
    Expression<String>? currentFarmName,
    Expression<String>? currentShedId,
    Expression<String>? currentShedName,
    Expression<String>? currentAnimalGroupId,
    Expression<String>? currentAnimalGroupName,
    Expression<String>? motherAnimalId,
    Expression<String>? motherAnimalNumber,
    Expression<String>? fatherAnimalId,
    Expression<String>? fatherAnimalNumber,
    Expression<String>? externalSireReference,
    Expression<String>? origin,
    Expression<DateTime>? acquisitionDate,
    Expression<String>? sourceDescription,
    Expression<String>? notes,
    Expression<String>? operationalStatus,
    Expression<int>? version,
    Expression<DateTime>? serverUpdatedAt,
    Expression<DateTime>? cachedAt,
    Expression<bool>? isArchived,
    Expression<bool>? isAccessible,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (organizationId != null) 'organization_id': organizationId,
      if (animalNumber != null) 'animal_number': animalNumber,
      if (earTagNumber != null) 'ear_tag_number': earTagNumber,
      if (rfidNumber != null) 'rfid_number': rfidNumber,
      if (name != null) 'name': name,
      if (registrationNumber != null) 'registration_number': registrationNumber,
      if (speciesId != null) 'species_id': speciesId,
      if (speciesName != null) 'species_name': speciesName,
      if (breedId != null) 'breed_id': breedId,
      if (breedName != null) 'breed_name': breedName,
      if (sex != null) 'sex': sex,
      if (lifeStage != null) 'life_stage': lifeStage,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
      if (isDateOfBirthEstimated != null)
        'is_date_of_birth_estimated': isDateOfBirthEstimated,
      if (colour != null) 'colour': colour,
      if (identifyingMarks != null) 'identifying_marks': identifyingMarks,
      if (currentFarmId != null) 'current_farm_id': currentFarmId,
      if (currentFarmName != null) 'current_farm_name': currentFarmName,
      if (currentShedId != null) 'current_shed_id': currentShedId,
      if (currentShedName != null) 'current_shed_name': currentShedName,
      if (currentAnimalGroupId != null)
        'current_animal_group_id': currentAnimalGroupId,
      if (currentAnimalGroupName != null)
        'current_animal_group_name': currentAnimalGroupName,
      if (motherAnimalId != null) 'mother_animal_id': motherAnimalId,
      if (motherAnimalNumber != null)
        'mother_animal_number': motherAnimalNumber,
      if (fatherAnimalId != null) 'father_animal_id': fatherAnimalId,
      if (fatherAnimalNumber != null)
        'father_animal_number': fatherAnimalNumber,
      if (externalSireReference != null)
        'external_sire_reference': externalSireReference,
      if (origin != null) 'origin': origin,
      if (acquisitionDate != null) 'acquisition_date': acquisitionDate,
      if (sourceDescription != null) 'source_description': sourceDescription,
      if (notes != null) 'notes': notes,
      if (operationalStatus != null) 'operational_status': operationalStatus,
      if (version != null) 'version': version,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (isArchived != null) 'is_archived': isArchived,
      if (isAccessible != null) 'is_accessible': isAccessible,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalAnimalsCompanion copyWith({
    Value<String>? id,
    Value<String>? organizationId,
    Value<String>? animalNumber,
    Value<String?>? earTagNumber,
    Value<String?>? rfidNumber,
    Value<String?>? name,
    Value<String?>? registrationNumber,
    Value<String>? speciesId,
    Value<String>? speciesName,
    Value<String>? breedId,
    Value<String>? breedName,
    Value<String>? sex,
    Value<String>? lifeStage,
    Value<DateTime?>? dateOfBirth,
    Value<bool>? isDateOfBirthEstimated,
    Value<String?>? colour,
    Value<String?>? identifyingMarks,
    Value<String>? currentFarmId,
    Value<String>? currentFarmName,
    Value<String>? currentShedId,
    Value<String>? currentShedName,
    Value<String?>? currentAnimalGroupId,
    Value<String?>? currentAnimalGroupName,
    Value<String?>? motherAnimalId,
    Value<String?>? motherAnimalNumber,
    Value<String?>? fatherAnimalId,
    Value<String?>? fatherAnimalNumber,
    Value<String?>? externalSireReference,
    Value<String>? origin,
    Value<DateTime?>? acquisitionDate,
    Value<String?>? sourceDescription,
    Value<String?>? notes,
    Value<String>? operationalStatus,
    Value<int>? version,
    Value<DateTime>? serverUpdatedAt,
    Value<DateTime>? cachedAt,
    Value<bool>? isArchived,
    Value<bool>? isAccessible,
    Value<int>? rowid,
  }) {
    return LocalAnimalsCompanion(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      animalNumber: animalNumber ?? this.animalNumber,
      earTagNumber: earTagNumber ?? this.earTagNumber,
      rfidNumber: rfidNumber ?? this.rfidNumber,
      name: name ?? this.name,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      speciesId: speciesId ?? this.speciesId,
      speciesName: speciesName ?? this.speciesName,
      breedId: breedId ?? this.breedId,
      breedName: breedName ?? this.breedName,
      sex: sex ?? this.sex,
      lifeStage: lifeStage ?? this.lifeStage,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      isDateOfBirthEstimated:
          isDateOfBirthEstimated ?? this.isDateOfBirthEstimated,
      colour: colour ?? this.colour,
      identifyingMarks: identifyingMarks ?? this.identifyingMarks,
      currentFarmId: currentFarmId ?? this.currentFarmId,
      currentFarmName: currentFarmName ?? this.currentFarmName,
      currentShedId: currentShedId ?? this.currentShedId,
      currentShedName: currentShedName ?? this.currentShedName,
      currentAnimalGroupId: currentAnimalGroupId ?? this.currentAnimalGroupId,
      currentAnimalGroupName:
          currentAnimalGroupName ?? this.currentAnimalGroupName,
      motherAnimalId: motherAnimalId ?? this.motherAnimalId,
      motherAnimalNumber: motherAnimalNumber ?? this.motherAnimalNumber,
      fatherAnimalId: fatherAnimalId ?? this.fatherAnimalId,
      fatherAnimalNumber: fatherAnimalNumber ?? this.fatherAnimalNumber,
      externalSireReference:
          externalSireReference ?? this.externalSireReference,
      origin: origin ?? this.origin,
      acquisitionDate: acquisitionDate ?? this.acquisitionDate,
      sourceDescription: sourceDescription ?? this.sourceDescription,
      notes: notes ?? this.notes,
      operationalStatus: operationalStatus ?? this.operationalStatus,
      version: version ?? this.version,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      cachedAt: cachedAt ?? this.cachedAt,
      isArchived: isArchived ?? this.isArchived,
      isAccessible: isAccessible ?? this.isAccessible,
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
    if (animalNumber.present) {
      map['animal_number'] = Variable<String>(animalNumber.value);
    }
    if (earTagNumber.present) {
      map['ear_tag_number'] = Variable<String>(earTagNumber.value);
    }
    if (rfidNumber.present) {
      map['rfid_number'] = Variable<String>(rfidNumber.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (registrationNumber.present) {
      map['registration_number'] = Variable<String>(registrationNumber.value);
    }
    if (speciesId.present) {
      map['species_id'] = Variable<String>(speciesId.value);
    }
    if (speciesName.present) {
      map['species_name'] = Variable<String>(speciesName.value);
    }
    if (breedId.present) {
      map['breed_id'] = Variable<String>(breedId.value);
    }
    if (breedName.present) {
      map['breed_name'] = Variable<String>(breedName.value);
    }
    if (sex.present) {
      map['sex'] = Variable<String>(sex.value);
    }
    if (lifeStage.present) {
      map['life_stage'] = Variable<String>(lifeStage.value);
    }
    if (dateOfBirth.present) {
      map['date_of_birth'] = Variable<DateTime>(dateOfBirth.value);
    }
    if (isDateOfBirthEstimated.present) {
      map['is_date_of_birth_estimated'] = Variable<bool>(
        isDateOfBirthEstimated.value,
      );
    }
    if (colour.present) {
      map['colour'] = Variable<String>(colour.value);
    }
    if (identifyingMarks.present) {
      map['identifying_marks'] = Variable<String>(identifyingMarks.value);
    }
    if (currentFarmId.present) {
      map['current_farm_id'] = Variable<String>(currentFarmId.value);
    }
    if (currentFarmName.present) {
      map['current_farm_name'] = Variable<String>(currentFarmName.value);
    }
    if (currentShedId.present) {
      map['current_shed_id'] = Variable<String>(currentShedId.value);
    }
    if (currentShedName.present) {
      map['current_shed_name'] = Variable<String>(currentShedName.value);
    }
    if (currentAnimalGroupId.present) {
      map['current_animal_group_id'] = Variable<String>(
        currentAnimalGroupId.value,
      );
    }
    if (currentAnimalGroupName.present) {
      map['current_animal_group_name'] = Variable<String>(
        currentAnimalGroupName.value,
      );
    }
    if (motherAnimalId.present) {
      map['mother_animal_id'] = Variable<String>(motherAnimalId.value);
    }
    if (motherAnimalNumber.present) {
      map['mother_animal_number'] = Variable<String>(motherAnimalNumber.value);
    }
    if (fatherAnimalId.present) {
      map['father_animal_id'] = Variable<String>(fatherAnimalId.value);
    }
    if (fatherAnimalNumber.present) {
      map['father_animal_number'] = Variable<String>(fatherAnimalNumber.value);
    }
    if (externalSireReference.present) {
      map['external_sire_reference'] = Variable<String>(
        externalSireReference.value,
      );
    }
    if (origin.present) {
      map['origin'] = Variable<String>(origin.value);
    }
    if (acquisitionDate.present) {
      map['acquisition_date'] = Variable<DateTime>(acquisitionDate.value);
    }
    if (sourceDescription.present) {
      map['source_description'] = Variable<String>(sourceDescription.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (operationalStatus.present) {
      map['operational_status'] = Variable<String>(operationalStatus.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<DateTime>(serverUpdatedAt.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (isAccessible.present) {
      map['is_accessible'] = Variable<bool>(isAccessible.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalAnimalsCompanion(')
          ..write('id: $id, ')
          ..write('organizationId: $organizationId, ')
          ..write('animalNumber: $animalNumber, ')
          ..write('earTagNumber: $earTagNumber, ')
          ..write('rfidNumber: $rfidNumber, ')
          ..write('name: $name, ')
          ..write('registrationNumber: $registrationNumber, ')
          ..write('speciesId: $speciesId, ')
          ..write('speciesName: $speciesName, ')
          ..write('breedId: $breedId, ')
          ..write('breedName: $breedName, ')
          ..write('sex: $sex, ')
          ..write('lifeStage: $lifeStage, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('isDateOfBirthEstimated: $isDateOfBirthEstimated, ')
          ..write('colour: $colour, ')
          ..write('identifyingMarks: $identifyingMarks, ')
          ..write('currentFarmId: $currentFarmId, ')
          ..write('currentFarmName: $currentFarmName, ')
          ..write('currentShedId: $currentShedId, ')
          ..write('currentShedName: $currentShedName, ')
          ..write('currentAnimalGroupId: $currentAnimalGroupId, ')
          ..write('currentAnimalGroupName: $currentAnimalGroupName, ')
          ..write('motherAnimalId: $motherAnimalId, ')
          ..write('motherAnimalNumber: $motherAnimalNumber, ')
          ..write('fatherAnimalId: $fatherAnimalId, ')
          ..write('fatherAnimalNumber: $fatherAnimalNumber, ')
          ..write('externalSireReference: $externalSireReference, ')
          ..write('origin: $origin, ')
          ..write('acquisitionDate: $acquisitionDate, ')
          ..write('sourceDescription: $sourceDescription, ')
          ..write('notes: $notes, ')
          ..write('operationalStatus: $operationalStatus, ')
          ..write('version: $version, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('isArchived: $isArchived, ')
          ..write('isAccessible: $isAccessible, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalAnimalMovementsTable extends LocalAnimalMovements
    with TableInfo<$LocalAnimalMovementsTable, LocalAnimalMovement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalAnimalMovementsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _animalIdMeta = const VerificationMeta(
    'animalId',
  );
  @override
  late final GeneratedColumn<String> animalId = GeneratedColumn<String>(
    'animal_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _animalNumberMeta = const VerificationMeta(
    'animalNumber',
  );
  @override
  late final GeneratedColumn<String> animalNumber = GeneratedColumn<String>(
    'animal_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceFarmIdMeta = const VerificationMeta(
    'sourceFarmId',
  );
  @override
  late final GeneratedColumn<String> sourceFarmId = GeneratedColumn<String>(
    'source_farm_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceFarmNameMeta = const VerificationMeta(
    'sourceFarmName',
  );
  @override
  late final GeneratedColumn<String> sourceFarmName = GeneratedColumn<String>(
    'source_farm_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceShedIdMeta = const VerificationMeta(
    'sourceShedId',
  );
  @override
  late final GeneratedColumn<String> sourceShedId = GeneratedColumn<String>(
    'source_shed_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceShedNameMeta = const VerificationMeta(
    'sourceShedName',
  );
  @override
  late final GeneratedColumn<String> sourceShedName = GeneratedColumn<String>(
    'source_shed_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceAnimalGroupIdMeta =
      const VerificationMeta('sourceAnimalGroupId');
  @override
  late final GeneratedColumn<String> sourceAnimalGroupId =
      GeneratedColumn<String>(
        'source_animal_group_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _sourceAnimalGroupNameMeta =
      const VerificationMeta('sourceAnimalGroupName');
  @override
  late final GeneratedColumn<String> sourceAnimalGroupName =
      GeneratedColumn<String>(
        'source_animal_group_name',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _destinationFarmIdMeta = const VerificationMeta(
    'destinationFarmId',
  );
  @override
  late final GeneratedColumn<String> destinationFarmId =
      GeneratedColumn<String>(
        'destination_farm_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _destinationFarmNameMeta =
      const VerificationMeta('destinationFarmName');
  @override
  late final GeneratedColumn<String> destinationFarmName =
      GeneratedColumn<String>(
        'destination_farm_name',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _destinationShedIdMeta = const VerificationMeta(
    'destinationShedId',
  );
  @override
  late final GeneratedColumn<String> destinationShedId =
      GeneratedColumn<String>(
        'destination_shed_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _destinationShedNameMeta =
      const VerificationMeta('destinationShedName');
  @override
  late final GeneratedColumn<String> destinationShedName =
      GeneratedColumn<String>(
        'destination_shed_name',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _destinationAnimalGroupIdMeta =
      const VerificationMeta('destinationAnimalGroupId');
  @override
  late final GeneratedColumn<String> destinationAnimalGroupId =
      GeneratedColumn<String>(
        'destination_animal_group_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _destinationAnimalGroupNameMeta =
      const VerificationMeta('destinationAnimalGroupName');
  @override
  late final GeneratedColumn<String> destinationAnimalGroupName =
      GeneratedColumn<String>(
        'destination_animal_group_name',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _requestedEffectiveAtMeta =
      const VerificationMeta('requestedEffectiveAt');
  @override
  late final GeneratedColumn<DateTime> requestedEffectiveAt =
      GeneratedColumn<DateTime>(
        'requested_effective_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _actualEffectiveAtMeta = const VerificationMeta(
    'actualEffectiveAt',
  );
  @override
  late final GeneratedColumn<DateTime> actualEffectiveAt =
      GeneratedColumn<DateTime>(
        'actual_effective_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
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
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _approvalRequiredMeta = const VerificationMeta(
    'approvalRequired',
  );
  @override
  late final GeneratedColumn<bool> approvalRequired = GeneratedColumn<bool>(
    'approval_required',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("approval_required" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _requestedByMeta = const VerificationMeta(
    'requestedBy',
  );
  @override
  late final GeneratedColumn<String> requestedBy = GeneratedColumn<String>(
    'requested_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _requestedByNameMeta = const VerificationMeta(
    'requestedByName',
  );
  @override
  late final GeneratedColumn<String> requestedByName = GeneratedColumn<String>(
    'requested_by_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _decidedByMeta = const VerificationMeta(
    'decidedBy',
  );
  @override
  late final GeneratedColumn<String> decidedBy = GeneratedColumn<String>(
    'decided_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _decidedByNameMeta = const VerificationMeta(
    'decidedByName',
  );
  @override
  late final GeneratedColumn<String> decidedByName = GeneratedColumn<String>(
    'decided_by_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _decisionAtMeta = const VerificationMeta(
    'decisionAt',
  );
  @override
  late final GeneratedColumn<DateTime> decisionAt = GeneratedColumn<DateTime>(
    'decision_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rejectionReasonMeta = const VerificationMeta(
    'rejectionReason',
  );
  @override
  late final GeneratedColumn<String> rejectionReason = GeneratedColumn<String>(
    'rejection_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cancellationReasonMeta =
      const VerificationMeta('cancellationReason');
  @override
  late final GeneratedColumn<String> cancellationReason =
      GeneratedColumn<String>(
        'cancellation_reason',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
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
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isAccessibleMeta = const VerificationMeta(
    'isAccessible',
  );
  @override
  late final GeneratedColumn<bool> isAccessible = GeneratedColumn<bool>(
    'is_accessible',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_accessible" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    organizationId,
    animalId,
    animalNumber,
    sourceFarmId,
    sourceFarmName,
    sourceShedId,
    sourceShedName,
    sourceAnimalGroupId,
    sourceAnimalGroupName,
    destinationFarmId,
    destinationFarmName,
    destinationShedId,
    destinationShedName,
    destinationAnimalGroupId,
    destinationAnimalGroupName,
    requestedEffectiveAt,
    actualEffectiveAt,
    reason,
    notes,
    status,
    approvalRequired,
    requestedBy,
    requestedByName,
    decidedBy,
    decidedByName,
    decisionAt,
    rejectionReason,
    cancellationReason,
    version,
    serverUpdatedAt,
    cachedAt,
    isAccessible,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_animal_movements';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalAnimalMovement> instance, {
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
    if (data.containsKey('animal_id')) {
      context.handle(
        _animalIdMeta,
        animalId.isAcceptableOrUnknown(data['animal_id']!, _animalIdMeta),
      );
    } else if (isInserting) {
      context.missing(_animalIdMeta);
    }
    if (data.containsKey('animal_number')) {
      context.handle(
        _animalNumberMeta,
        animalNumber.isAcceptableOrUnknown(
          data['animal_number']!,
          _animalNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_animalNumberMeta);
    }
    if (data.containsKey('source_farm_id')) {
      context.handle(
        _sourceFarmIdMeta,
        sourceFarmId.isAcceptableOrUnknown(
          data['source_farm_id']!,
          _sourceFarmIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceFarmIdMeta);
    }
    if (data.containsKey('source_farm_name')) {
      context.handle(
        _sourceFarmNameMeta,
        sourceFarmName.isAcceptableOrUnknown(
          data['source_farm_name']!,
          _sourceFarmNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceFarmNameMeta);
    }
    if (data.containsKey('source_shed_id')) {
      context.handle(
        _sourceShedIdMeta,
        sourceShedId.isAcceptableOrUnknown(
          data['source_shed_id']!,
          _sourceShedIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceShedIdMeta);
    }
    if (data.containsKey('source_shed_name')) {
      context.handle(
        _sourceShedNameMeta,
        sourceShedName.isAcceptableOrUnknown(
          data['source_shed_name']!,
          _sourceShedNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceShedNameMeta);
    }
    if (data.containsKey('source_animal_group_id')) {
      context.handle(
        _sourceAnimalGroupIdMeta,
        sourceAnimalGroupId.isAcceptableOrUnknown(
          data['source_animal_group_id']!,
          _sourceAnimalGroupIdMeta,
        ),
      );
    }
    if (data.containsKey('source_animal_group_name')) {
      context.handle(
        _sourceAnimalGroupNameMeta,
        sourceAnimalGroupName.isAcceptableOrUnknown(
          data['source_animal_group_name']!,
          _sourceAnimalGroupNameMeta,
        ),
      );
    }
    if (data.containsKey('destination_farm_id')) {
      context.handle(
        _destinationFarmIdMeta,
        destinationFarmId.isAcceptableOrUnknown(
          data['destination_farm_id']!,
          _destinationFarmIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_destinationFarmIdMeta);
    }
    if (data.containsKey('destination_farm_name')) {
      context.handle(
        _destinationFarmNameMeta,
        destinationFarmName.isAcceptableOrUnknown(
          data['destination_farm_name']!,
          _destinationFarmNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_destinationFarmNameMeta);
    }
    if (data.containsKey('destination_shed_id')) {
      context.handle(
        _destinationShedIdMeta,
        destinationShedId.isAcceptableOrUnknown(
          data['destination_shed_id']!,
          _destinationShedIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_destinationShedIdMeta);
    }
    if (data.containsKey('destination_shed_name')) {
      context.handle(
        _destinationShedNameMeta,
        destinationShedName.isAcceptableOrUnknown(
          data['destination_shed_name']!,
          _destinationShedNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_destinationShedNameMeta);
    }
    if (data.containsKey('destination_animal_group_id')) {
      context.handle(
        _destinationAnimalGroupIdMeta,
        destinationAnimalGroupId.isAcceptableOrUnknown(
          data['destination_animal_group_id']!,
          _destinationAnimalGroupIdMeta,
        ),
      );
    }
    if (data.containsKey('destination_animal_group_name')) {
      context.handle(
        _destinationAnimalGroupNameMeta,
        destinationAnimalGroupName.isAcceptableOrUnknown(
          data['destination_animal_group_name']!,
          _destinationAnimalGroupNameMeta,
        ),
      );
    }
    if (data.containsKey('requested_effective_at')) {
      context.handle(
        _requestedEffectiveAtMeta,
        requestedEffectiveAt.isAcceptableOrUnknown(
          data['requested_effective_at']!,
          _requestedEffectiveAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_requestedEffectiveAtMeta);
    }
    if (data.containsKey('actual_effective_at')) {
      context.handle(
        _actualEffectiveAtMeta,
        actualEffectiveAt.isAcceptableOrUnknown(
          data['actual_effective_at']!,
          _actualEffectiveAtMeta,
        ),
      );
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('approval_required')) {
      context.handle(
        _approvalRequiredMeta,
        approvalRequired.isAcceptableOrUnknown(
          data['approval_required']!,
          _approvalRequiredMeta,
        ),
      );
    }
    if (data.containsKey('requested_by')) {
      context.handle(
        _requestedByMeta,
        requestedBy.isAcceptableOrUnknown(
          data['requested_by']!,
          _requestedByMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_requestedByMeta);
    }
    if (data.containsKey('requested_by_name')) {
      context.handle(
        _requestedByNameMeta,
        requestedByName.isAcceptableOrUnknown(
          data['requested_by_name']!,
          _requestedByNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_requestedByNameMeta);
    }
    if (data.containsKey('decided_by')) {
      context.handle(
        _decidedByMeta,
        decidedBy.isAcceptableOrUnknown(data['decided_by']!, _decidedByMeta),
      );
    }
    if (data.containsKey('decided_by_name')) {
      context.handle(
        _decidedByNameMeta,
        decidedByName.isAcceptableOrUnknown(
          data['decided_by_name']!,
          _decidedByNameMeta,
        ),
      );
    }
    if (data.containsKey('decision_at')) {
      context.handle(
        _decisionAtMeta,
        decisionAt.isAcceptableOrUnknown(data['decision_at']!, _decisionAtMeta),
      );
    }
    if (data.containsKey('rejection_reason')) {
      context.handle(
        _rejectionReasonMeta,
        rejectionReason.isAcceptableOrUnknown(
          data['rejection_reason']!,
          _rejectionReasonMeta,
        ),
      );
    }
    if (data.containsKey('cancellation_reason')) {
      context.handle(
        _cancellationReasonMeta,
        cancellationReason.isAcceptableOrUnknown(
          data['cancellation_reason']!,
          _cancellationReasonMeta,
        ),
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
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    if (data.containsKey('is_accessible')) {
      context.handle(
        _isAccessibleMeta,
        isAccessible.isAcceptableOrUnknown(
          data['is_accessible']!,
          _isAccessibleMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalAnimalMovement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalAnimalMovement(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      organizationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}organization_id'],
      )!,
      animalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}animal_id'],
      )!,
      animalNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}animal_number'],
      )!,
      sourceFarmId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_farm_id'],
      )!,
      sourceFarmName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_farm_name'],
      )!,
      sourceShedId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_shed_id'],
      )!,
      sourceShedName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_shed_name'],
      )!,
      sourceAnimalGroupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_animal_group_id'],
      ),
      sourceAnimalGroupName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_animal_group_name'],
      ),
      destinationFarmId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}destination_farm_id'],
      )!,
      destinationFarmName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}destination_farm_name'],
      )!,
      destinationShedId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}destination_shed_id'],
      )!,
      destinationShedName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}destination_shed_name'],
      )!,
      destinationAnimalGroupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}destination_animal_group_id'],
      ),
      destinationAnimalGroupName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}destination_animal_group_name'],
      ),
      requestedEffectiveAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}requested_effective_at'],
      )!,
      actualEffectiveAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}actual_effective_at'],
      ),
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      approvalRequired: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}approval_required'],
      )!,
      requestedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}requested_by'],
      )!,
      requestedByName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}requested_by_name'],
      )!,
      decidedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}decided_by'],
      ),
      decidedByName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}decided_by_name'],
      ),
      decisionAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}decision_at'],
      ),
      rejectionReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rejection_reason'],
      ),
      cancellationReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cancellation_reason'],
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}server_updated_at'],
      )!,
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
      isAccessible: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_accessible'],
      )!,
    );
  }

  @override
  $LocalAnimalMovementsTable createAlias(String alias) {
    return $LocalAnimalMovementsTable(attachedDatabase, alias);
  }
}

class LocalAnimalMovement extends DataClass
    implements Insertable<LocalAnimalMovement> {
  final String id;
  final String organizationId;
  final String animalId;
  final String animalNumber;
  final String sourceFarmId;
  final String sourceFarmName;
  final String sourceShedId;
  final String sourceShedName;
  final String? sourceAnimalGroupId;
  final String? sourceAnimalGroupName;
  final String destinationFarmId;
  final String destinationFarmName;
  final String destinationShedId;
  final String destinationShedName;
  final String? destinationAnimalGroupId;
  final String? destinationAnimalGroupName;
  final DateTime requestedEffectiveAt;
  final DateTime? actualEffectiveAt;
  final String reason;
  final String? notes;
  final String status;
  final bool approvalRequired;
  final String requestedBy;
  final String requestedByName;
  final String? decidedBy;
  final String? decidedByName;
  final DateTime? decisionAt;
  final String? rejectionReason;
  final String? cancellationReason;
  final int version;
  final DateTime serverUpdatedAt;
  final DateTime cachedAt;
  final bool isAccessible;
  const LocalAnimalMovement({
    required this.id,
    required this.organizationId,
    required this.animalId,
    required this.animalNumber,
    required this.sourceFarmId,
    required this.sourceFarmName,
    required this.sourceShedId,
    required this.sourceShedName,
    this.sourceAnimalGroupId,
    this.sourceAnimalGroupName,
    required this.destinationFarmId,
    required this.destinationFarmName,
    required this.destinationShedId,
    required this.destinationShedName,
    this.destinationAnimalGroupId,
    this.destinationAnimalGroupName,
    required this.requestedEffectiveAt,
    this.actualEffectiveAt,
    required this.reason,
    this.notes,
    required this.status,
    required this.approvalRequired,
    required this.requestedBy,
    required this.requestedByName,
    this.decidedBy,
    this.decidedByName,
    this.decisionAt,
    this.rejectionReason,
    this.cancellationReason,
    required this.version,
    required this.serverUpdatedAt,
    required this.cachedAt,
    required this.isAccessible,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['organization_id'] = Variable<String>(organizationId);
    map['animal_id'] = Variable<String>(animalId);
    map['animal_number'] = Variable<String>(animalNumber);
    map['source_farm_id'] = Variable<String>(sourceFarmId);
    map['source_farm_name'] = Variable<String>(sourceFarmName);
    map['source_shed_id'] = Variable<String>(sourceShedId);
    map['source_shed_name'] = Variable<String>(sourceShedName);
    if (!nullToAbsent || sourceAnimalGroupId != null) {
      map['source_animal_group_id'] = Variable<String>(sourceAnimalGroupId);
    }
    if (!nullToAbsent || sourceAnimalGroupName != null) {
      map['source_animal_group_name'] = Variable<String>(sourceAnimalGroupName);
    }
    map['destination_farm_id'] = Variable<String>(destinationFarmId);
    map['destination_farm_name'] = Variable<String>(destinationFarmName);
    map['destination_shed_id'] = Variable<String>(destinationShedId);
    map['destination_shed_name'] = Variable<String>(destinationShedName);
    if (!nullToAbsent || destinationAnimalGroupId != null) {
      map['destination_animal_group_id'] = Variable<String>(
        destinationAnimalGroupId,
      );
    }
    if (!nullToAbsent || destinationAnimalGroupName != null) {
      map['destination_animal_group_name'] = Variable<String>(
        destinationAnimalGroupName,
      );
    }
    map['requested_effective_at'] = Variable<DateTime>(requestedEffectiveAt);
    if (!nullToAbsent || actualEffectiveAt != null) {
      map['actual_effective_at'] = Variable<DateTime>(actualEffectiveAt);
    }
    map['reason'] = Variable<String>(reason);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['status'] = Variable<String>(status);
    map['approval_required'] = Variable<bool>(approvalRequired);
    map['requested_by'] = Variable<String>(requestedBy);
    map['requested_by_name'] = Variable<String>(requestedByName);
    if (!nullToAbsent || decidedBy != null) {
      map['decided_by'] = Variable<String>(decidedBy);
    }
    if (!nullToAbsent || decidedByName != null) {
      map['decided_by_name'] = Variable<String>(decidedByName);
    }
    if (!nullToAbsent || decisionAt != null) {
      map['decision_at'] = Variable<DateTime>(decisionAt);
    }
    if (!nullToAbsent || rejectionReason != null) {
      map['rejection_reason'] = Variable<String>(rejectionReason);
    }
    if (!nullToAbsent || cancellationReason != null) {
      map['cancellation_reason'] = Variable<String>(cancellationReason);
    }
    map['version'] = Variable<int>(version);
    map['server_updated_at'] = Variable<DateTime>(serverUpdatedAt);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    map['is_accessible'] = Variable<bool>(isAccessible);
    return map;
  }

  LocalAnimalMovementsCompanion toCompanion(bool nullToAbsent) {
    return LocalAnimalMovementsCompanion(
      id: Value(id),
      organizationId: Value(organizationId),
      animalId: Value(animalId),
      animalNumber: Value(animalNumber),
      sourceFarmId: Value(sourceFarmId),
      sourceFarmName: Value(sourceFarmName),
      sourceShedId: Value(sourceShedId),
      sourceShedName: Value(sourceShedName),
      sourceAnimalGroupId: sourceAnimalGroupId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceAnimalGroupId),
      sourceAnimalGroupName: sourceAnimalGroupName == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceAnimalGroupName),
      destinationFarmId: Value(destinationFarmId),
      destinationFarmName: Value(destinationFarmName),
      destinationShedId: Value(destinationShedId),
      destinationShedName: Value(destinationShedName),
      destinationAnimalGroupId: destinationAnimalGroupId == null && nullToAbsent
          ? const Value.absent()
          : Value(destinationAnimalGroupId),
      destinationAnimalGroupName:
          destinationAnimalGroupName == null && nullToAbsent
          ? const Value.absent()
          : Value(destinationAnimalGroupName),
      requestedEffectiveAt: Value(requestedEffectiveAt),
      actualEffectiveAt: actualEffectiveAt == null && nullToAbsent
          ? const Value.absent()
          : Value(actualEffectiveAt),
      reason: Value(reason),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      status: Value(status),
      approvalRequired: Value(approvalRequired),
      requestedBy: Value(requestedBy),
      requestedByName: Value(requestedByName),
      decidedBy: decidedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(decidedBy),
      decidedByName: decidedByName == null && nullToAbsent
          ? const Value.absent()
          : Value(decidedByName),
      decisionAt: decisionAt == null && nullToAbsent
          ? const Value.absent()
          : Value(decisionAt),
      rejectionReason: rejectionReason == null && nullToAbsent
          ? const Value.absent()
          : Value(rejectionReason),
      cancellationReason: cancellationReason == null && nullToAbsent
          ? const Value.absent()
          : Value(cancellationReason),
      version: Value(version),
      serverUpdatedAt: Value(serverUpdatedAt),
      cachedAt: Value(cachedAt),
      isAccessible: Value(isAccessible),
    );
  }

  factory LocalAnimalMovement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalAnimalMovement(
      id: serializer.fromJson<String>(json['id']),
      organizationId: serializer.fromJson<String>(json['organizationId']),
      animalId: serializer.fromJson<String>(json['animalId']),
      animalNumber: serializer.fromJson<String>(json['animalNumber']),
      sourceFarmId: serializer.fromJson<String>(json['sourceFarmId']),
      sourceFarmName: serializer.fromJson<String>(json['sourceFarmName']),
      sourceShedId: serializer.fromJson<String>(json['sourceShedId']),
      sourceShedName: serializer.fromJson<String>(json['sourceShedName']),
      sourceAnimalGroupId: serializer.fromJson<String?>(
        json['sourceAnimalGroupId'],
      ),
      sourceAnimalGroupName: serializer.fromJson<String?>(
        json['sourceAnimalGroupName'],
      ),
      destinationFarmId: serializer.fromJson<String>(json['destinationFarmId']),
      destinationFarmName: serializer.fromJson<String>(
        json['destinationFarmName'],
      ),
      destinationShedId: serializer.fromJson<String>(json['destinationShedId']),
      destinationShedName: serializer.fromJson<String>(
        json['destinationShedName'],
      ),
      destinationAnimalGroupId: serializer.fromJson<String?>(
        json['destinationAnimalGroupId'],
      ),
      destinationAnimalGroupName: serializer.fromJson<String?>(
        json['destinationAnimalGroupName'],
      ),
      requestedEffectiveAt: serializer.fromJson<DateTime>(
        json['requestedEffectiveAt'],
      ),
      actualEffectiveAt: serializer.fromJson<DateTime?>(
        json['actualEffectiveAt'],
      ),
      reason: serializer.fromJson<String>(json['reason']),
      notes: serializer.fromJson<String?>(json['notes']),
      status: serializer.fromJson<String>(json['status']),
      approvalRequired: serializer.fromJson<bool>(json['approvalRequired']),
      requestedBy: serializer.fromJson<String>(json['requestedBy']),
      requestedByName: serializer.fromJson<String>(json['requestedByName']),
      decidedBy: serializer.fromJson<String?>(json['decidedBy']),
      decidedByName: serializer.fromJson<String?>(json['decidedByName']),
      decisionAt: serializer.fromJson<DateTime?>(json['decisionAt']),
      rejectionReason: serializer.fromJson<String?>(json['rejectionReason']),
      cancellationReason: serializer.fromJson<String?>(
        json['cancellationReason'],
      ),
      version: serializer.fromJson<int>(json['version']),
      serverUpdatedAt: serializer.fromJson<DateTime>(json['serverUpdatedAt']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
      isAccessible: serializer.fromJson<bool>(json['isAccessible']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'organizationId': serializer.toJson<String>(organizationId),
      'animalId': serializer.toJson<String>(animalId),
      'animalNumber': serializer.toJson<String>(animalNumber),
      'sourceFarmId': serializer.toJson<String>(sourceFarmId),
      'sourceFarmName': serializer.toJson<String>(sourceFarmName),
      'sourceShedId': serializer.toJson<String>(sourceShedId),
      'sourceShedName': serializer.toJson<String>(sourceShedName),
      'sourceAnimalGroupId': serializer.toJson<String?>(sourceAnimalGroupId),
      'sourceAnimalGroupName': serializer.toJson<String?>(
        sourceAnimalGroupName,
      ),
      'destinationFarmId': serializer.toJson<String>(destinationFarmId),
      'destinationFarmName': serializer.toJson<String>(destinationFarmName),
      'destinationShedId': serializer.toJson<String>(destinationShedId),
      'destinationShedName': serializer.toJson<String>(destinationShedName),
      'destinationAnimalGroupId': serializer.toJson<String?>(
        destinationAnimalGroupId,
      ),
      'destinationAnimalGroupName': serializer.toJson<String?>(
        destinationAnimalGroupName,
      ),
      'requestedEffectiveAt': serializer.toJson<DateTime>(requestedEffectiveAt),
      'actualEffectiveAt': serializer.toJson<DateTime?>(actualEffectiveAt),
      'reason': serializer.toJson<String>(reason),
      'notes': serializer.toJson<String?>(notes),
      'status': serializer.toJson<String>(status),
      'approvalRequired': serializer.toJson<bool>(approvalRequired),
      'requestedBy': serializer.toJson<String>(requestedBy),
      'requestedByName': serializer.toJson<String>(requestedByName),
      'decidedBy': serializer.toJson<String?>(decidedBy),
      'decidedByName': serializer.toJson<String?>(decidedByName),
      'decisionAt': serializer.toJson<DateTime?>(decisionAt),
      'rejectionReason': serializer.toJson<String?>(rejectionReason),
      'cancellationReason': serializer.toJson<String?>(cancellationReason),
      'version': serializer.toJson<int>(version),
      'serverUpdatedAt': serializer.toJson<DateTime>(serverUpdatedAt),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
      'isAccessible': serializer.toJson<bool>(isAccessible),
    };
  }

  LocalAnimalMovement copyWith({
    String? id,
    String? organizationId,
    String? animalId,
    String? animalNumber,
    String? sourceFarmId,
    String? sourceFarmName,
    String? sourceShedId,
    String? sourceShedName,
    Value<String?> sourceAnimalGroupId = const Value.absent(),
    Value<String?> sourceAnimalGroupName = const Value.absent(),
    String? destinationFarmId,
    String? destinationFarmName,
    String? destinationShedId,
    String? destinationShedName,
    Value<String?> destinationAnimalGroupId = const Value.absent(),
    Value<String?> destinationAnimalGroupName = const Value.absent(),
    DateTime? requestedEffectiveAt,
    Value<DateTime?> actualEffectiveAt = const Value.absent(),
    String? reason,
    Value<String?> notes = const Value.absent(),
    String? status,
    bool? approvalRequired,
    String? requestedBy,
    String? requestedByName,
    Value<String?> decidedBy = const Value.absent(),
    Value<String?> decidedByName = const Value.absent(),
    Value<DateTime?> decisionAt = const Value.absent(),
    Value<String?> rejectionReason = const Value.absent(),
    Value<String?> cancellationReason = const Value.absent(),
    int? version,
    DateTime? serverUpdatedAt,
    DateTime? cachedAt,
    bool? isAccessible,
  }) => LocalAnimalMovement(
    id: id ?? this.id,
    organizationId: organizationId ?? this.organizationId,
    animalId: animalId ?? this.animalId,
    animalNumber: animalNumber ?? this.animalNumber,
    sourceFarmId: sourceFarmId ?? this.sourceFarmId,
    sourceFarmName: sourceFarmName ?? this.sourceFarmName,
    sourceShedId: sourceShedId ?? this.sourceShedId,
    sourceShedName: sourceShedName ?? this.sourceShedName,
    sourceAnimalGroupId: sourceAnimalGroupId.present
        ? sourceAnimalGroupId.value
        : this.sourceAnimalGroupId,
    sourceAnimalGroupName: sourceAnimalGroupName.present
        ? sourceAnimalGroupName.value
        : this.sourceAnimalGroupName,
    destinationFarmId: destinationFarmId ?? this.destinationFarmId,
    destinationFarmName: destinationFarmName ?? this.destinationFarmName,
    destinationShedId: destinationShedId ?? this.destinationShedId,
    destinationShedName: destinationShedName ?? this.destinationShedName,
    destinationAnimalGroupId: destinationAnimalGroupId.present
        ? destinationAnimalGroupId.value
        : this.destinationAnimalGroupId,
    destinationAnimalGroupName: destinationAnimalGroupName.present
        ? destinationAnimalGroupName.value
        : this.destinationAnimalGroupName,
    requestedEffectiveAt: requestedEffectiveAt ?? this.requestedEffectiveAt,
    actualEffectiveAt: actualEffectiveAt.present
        ? actualEffectiveAt.value
        : this.actualEffectiveAt,
    reason: reason ?? this.reason,
    notes: notes.present ? notes.value : this.notes,
    status: status ?? this.status,
    approvalRequired: approvalRequired ?? this.approvalRequired,
    requestedBy: requestedBy ?? this.requestedBy,
    requestedByName: requestedByName ?? this.requestedByName,
    decidedBy: decidedBy.present ? decidedBy.value : this.decidedBy,
    decidedByName: decidedByName.present
        ? decidedByName.value
        : this.decidedByName,
    decisionAt: decisionAt.present ? decisionAt.value : this.decisionAt,
    rejectionReason: rejectionReason.present
        ? rejectionReason.value
        : this.rejectionReason,
    cancellationReason: cancellationReason.present
        ? cancellationReason.value
        : this.cancellationReason,
    version: version ?? this.version,
    serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
    cachedAt: cachedAt ?? this.cachedAt,
    isAccessible: isAccessible ?? this.isAccessible,
  );
  LocalAnimalMovement copyWithCompanion(LocalAnimalMovementsCompanion data) {
    return LocalAnimalMovement(
      id: data.id.present ? data.id.value : this.id,
      organizationId: data.organizationId.present
          ? data.organizationId.value
          : this.organizationId,
      animalId: data.animalId.present ? data.animalId.value : this.animalId,
      animalNumber: data.animalNumber.present
          ? data.animalNumber.value
          : this.animalNumber,
      sourceFarmId: data.sourceFarmId.present
          ? data.sourceFarmId.value
          : this.sourceFarmId,
      sourceFarmName: data.sourceFarmName.present
          ? data.sourceFarmName.value
          : this.sourceFarmName,
      sourceShedId: data.sourceShedId.present
          ? data.sourceShedId.value
          : this.sourceShedId,
      sourceShedName: data.sourceShedName.present
          ? data.sourceShedName.value
          : this.sourceShedName,
      sourceAnimalGroupId: data.sourceAnimalGroupId.present
          ? data.sourceAnimalGroupId.value
          : this.sourceAnimalGroupId,
      sourceAnimalGroupName: data.sourceAnimalGroupName.present
          ? data.sourceAnimalGroupName.value
          : this.sourceAnimalGroupName,
      destinationFarmId: data.destinationFarmId.present
          ? data.destinationFarmId.value
          : this.destinationFarmId,
      destinationFarmName: data.destinationFarmName.present
          ? data.destinationFarmName.value
          : this.destinationFarmName,
      destinationShedId: data.destinationShedId.present
          ? data.destinationShedId.value
          : this.destinationShedId,
      destinationShedName: data.destinationShedName.present
          ? data.destinationShedName.value
          : this.destinationShedName,
      destinationAnimalGroupId: data.destinationAnimalGroupId.present
          ? data.destinationAnimalGroupId.value
          : this.destinationAnimalGroupId,
      destinationAnimalGroupName: data.destinationAnimalGroupName.present
          ? data.destinationAnimalGroupName.value
          : this.destinationAnimalGroupName,
      requestedEffectiveAt: data.requestedEffectiveAt.present
          ? data.requestedEffectiveAt.value
          : this.requestedEffectiveAt,
      actualEffectiveAt: data.actualEffectiveAt.present
          ? data.actualEffectiveAt.value
          : this.actualEffectiveAt,
      reason: data.reason.present ? data.reason.value : this.reason,
      notes: data.notes.present ? data.notes.value : this.notes,
      status: data.status.present ? data.status.value : this.status,
      approvalRequired: data.approvalRequired.present
          ? data.approvalRequired.value
          : this.approvalRequired,
      requestedBy: data.requestedBy.present
          ? data.requestedBy.value
          : this.requestedBy,
      requestedByName: data.requestedByName.present
          ? data.requestedByName.value
          : this.requestedByName,
      decidedBy: data.decidedBy.present ? data.decidedBy.value : this.decidedBy,
      decidedByName: data.decidedByName.present
          ? data.decidedByName.value
          : this.decidedByName,
      decisionAt: data.decisionAt.present
          ? data.decisionAt.value
          : this.decisionAt,
      rejectionReason: data.rejectionReason.present
          ? data.rejectionReason.value
          : this.rejectionReason,
      cancellationReason: data.cancellationReason.present
          ? data.cancellationReason.value
          : this.cancellationReason,
      version: data.version.present ? data.version.value : this.version,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
      isAccessible: data.isAccessible.present
          ? data.isAccessible.value
          : this.isAccessible,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalAnimalMovement(')
          ..write('id: $id, ')
          ..write('organizationId: $organizationId, ')
          ..write('animalId: $animalId, ')
          ..write('animalNumber: $animalNumber, ')
          ..write('sourceFarmId: $sourceFarmId, ')
          ..write('sourceFarmName: $sourceFarmName, ')
          ..write('sourceShedId: $sourceShedId, ')
          ..write('sourceShedName: $sourceShedName, ')
          ..write('sourceAnimalGroupId: $sourceAnimalGroupId, ')
          ..write('sourceAnimalGroupName: $sourceAnimalGroupName, ')
          ..write('destinationFarmId: $destinationFarmId, ')
          ..write('destinationFarmName: $destinationFarmName, ')
          ..write('destinationShedId: $destinationShedId, ')
          ..write('destinationShedName: $destinationShedName, ')
          ..write('destinationAnimalGroupId: $destinationAnimalGroupId, ')
          ..write('destinationAnimalGroupName: $destinationAnimalGroupName, ')
          ..write('requestedEffectiveAt: $requestedEffectiveAt, ')
          ..write('actualEffectiveAt: $actualEffectiveAt, ')
          ..write('reason: $reason, ')
          ..write('notes: $notes, ')
          ..write('status: $status, ')
          ..write('approvalRequired: $approvalRequired, ')
          ..write('requestedBy: $requestedBy, ')
          ..write('requestedByName: $requestedByName, ')
          ..write('decidedBy: $decidedBy, ')
          ..write('decidedByName: $decidedByName, ')
          ..write('decisionAt: $decisionAt, ')
          ..write('rejectionReason: $rejectionReason, ')
          ..write('cancellationReason: $cancellationReason, ')
          ..write('version: $version, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('isAccessible: $isAccessible')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    organizationId,
    animalId,
    animalNumber,
    sourceFarmId,
    sourceFarmName,
    sourceShedId,
    sourceShedName,
    sourceAnimalGroupId,
    sourceAnimalGroupName,
    destinationFarmId,
    destinationFarmName,
    destinationShedId,
    destinationShedName,
    destinationAnimalGroupId,
    destinationAnimalGroupName,
    requestedEffectiveAt,
    actualEffectiveAt,
    reason,
    notes,
    status,
    approvalRequired,
    requestedBy,
    requestedByName,
    decidedBy,
    decidedByName,
    decisionAt,
    rejectionReason,
    cancellationReason,
    version,
    serverUpdatedAt,
    cachedAt,
    isAccessible,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalAnimalMovement &&
          other.id == this.id &&
          other.organizationId == this.organizationId &&
          other.animalId == this.animalId &&
          other.animalNumber == this.animalNumber &&
          other.sourceFarmId == this.sourceFarmId &&
          other.sourceFarmName == this.sourceFarmName &&
          other.sourceShedId == this.sourceShedId &&
          other.sourceShedName == this.sourceShedName &&
          other.sourceAnimalGroupId == this.sourceAnimalGroupId &&
          other.sourceAnimalGroupName == this.sourceAnimalGroupName &&
          other.destinationFarmId == this.destinationFarmId &&
          other.destinationFarmName == this.destinationFarmName &&
          other.destinationShedId == this.destinationShedId &&
          other.destinationShedName == this.destinationShedName &&
          other.destinationAnimalGroupId == this.destinationAnimalGroupId &&
          other.destinationAnimalGroupName == this.destinationAnimalGroupName &&
          other.requestedEffectiveAt == this.requestedEffectiveAt &&
          other.actualEffectiveAt == this.actualEffectiveAt &&
          other.reason == this.reason &&
          other.notes == this.notes &&
          other.status == this.status &&
          other.approvalRequired == this.approvalRequired &&
          other.requestedBy == this.requestedBy &&
          other.requestedByName == this.requestedByName &&
          other.decidedBy == this.decidedBy &&
          other.decidedByName == this.decidedByName &&
          other.decisionAt == this.decisionAt &&
          other.rejectionReason == this.rejectionReason &&
          other.cancellationReason == this.cancellationReason &&
          other.version == this.version &&
          other.serverUpdatedAt == this.serverUpdatedAt &&
          other.cachedAt == this.cachedAt &&
          other.isAccessible == this.isAccessible);
}

class LocalAnimalMovementsCompanion
    extends UpdateCompanion<LocalAnimalMovement> {
  final Value<String> id;
  final Value<String> organizationId;
  final Value<String> animalId;
  final Value<String> animalNumber;
  final Value<String> sourceFarmId;
  final Value<String> sourceFarmName;
  final Value<String> sourceShedId;
  final Value<String> sourceShedName;
  final Value<String?> sourceAnimalGroupId;
  final Value<String?> sourceAnimalGroupName;
  final Value<String> destinationFarmId;
  final Value<String> destinationFarmName;
  final Value<String> destinationShedId;
  final Value<String> destinationShedName;
  final Value<String?> destinationAnimalGroupId;
  final Value<String?> destinationAnimalGroupName;
  final Value<DateTime> requestedEffectiveAt;
  final Value<DateTime?> actualEffectiveAt;
  final Value<String> reason;
  final Value<String?> notes;
  final Value<String> status;
  final Value<bool> approvalRequired;
  final Value<String> requestedBy;
  final Value<String> requestedByName;
  final Value<String?> decidedBy;
  final Value<String?> decidedByName;
  final Value<DateTime?> decisionAt;
  final Value<String?> rejectionReason;
  final Value<String?> cancellationReason;
  final Value<int> version;
  final Value<DateTime> serverUpdatedAt;
  final Value<DateTime> cachedAt;
  final Value<bool> isAccessible;
  final Value<int> rowid;
  const LocalAnimalMovementsCompanion({
    this.id = const Value.absent(),
    this.organizationId = const Value.absent(),
    this.animalId = const Value.absent(),
    this.animalNumber = const Value.absent(),
    this.sourceFarmId = const Value.absent(),
    this.sourceFarmName = const Value.absent(),
    this.sourceShedId = const Value.absent(),
    this.sourceShedName = const Value.absent(),
    this.sourceAnimalGroupId = const Value.absent(),
    this.sourceAnimalGroupName = const Value.absent(),
    this.destinationFarmId = const Value.absent(),
    this.destinationFarmName = const Value.absent(),
    this.destinationShedId = const Value.absent(),
    this.destinationShedName = const Value.absent(),
    this.destinationAnimalGroupId = const Value.absent(),
    this.destinationAnimalGroupName = const Value.absent(),
    this.requestedEffectiveAt = const Value.absent(),
    this.actualEffectiveAt = const Value.absent(),
    this.reason = const Value.absent(),
    this.notes = const Value.absent(),
    this.status = const Value.absent(),
    this.approvalRequired = const Value.absent(),
    this.requestedBy = const Value.absent(),
    this.requestedByName = const Value.absent(),
    this.decidedBy = const Value.absent(),
    this.decidedByName = const Value.absent(),
    this.decisionAt = const Value.absent(),
    this.rejectionReason = const Value.absent(),
    this.cancellationReason = const Value.absent(),
    this.version = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.isAccessible = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalAnimalMovementsCompanion.insert({
    required String id,
    required String organizationId,
    required String animalId,
    required String animalNumber,
    required String sourceFarmId,
    required String sourceFarmName,
    required String sourceShedId,
    required String sourceShedName,
    this.sourceAnimalGroupId = const Value.absent(),
    this.sourceAnimalGroupName = const Value.absent(),
    required String destinationFarmId,
    required String destinationFarmName,
    required String destinationShedId,
    required String destinationShedName,
    this.destinationAnimalGroupId = const Value.absent(),
    this.destinationAnimalGroupName = const Value.absent(),
    required DateTime requestedEffectiveAt,
    this.actualEffectiveAt = const Value.absent(),
    required String reason,
    this.notes = const Value.absent(),
    required String status,
    this.approvalRequired = const Value.absent(),
    required String requestedBy,
    required String requestedByName,
    this.decidedBy = const Value.absent(),
    this.decidedByName = const Value.absent(),
    this.decisionAt = const Value.absent(),
    this.rejectionReason = const Value.absent(),
    this.cancellationReason = const Value.absent(),
    this.version = const Value.absent(),
    required DateTime serverUpdatedAt,
    required DateTime cachedAt,
    this.isAccessible = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       organizationId = Value(organizationId),
       animalId = Value(animalId),
       animalNumber = Value(animalNumber),
       sourceFarmId = Value(sourceFarmId),
       sourceFarmName = Value(sourceFarmName),
       sourceShedId = Value(sourceShedId),
       sourceShedName = Value(sourceShedName),
       destinationFarmId = Value(destinationFarmId),
       destinationFarmName = Value(destinationFarmName),
       destinationShedId = Value(destinationShedId),
       destinationShedName = Value(destinationShedName),
       requestedEffectiveAt = Value(requestedEffectiveAt),
       reason = Value(reason),
       status = Value(status),
       requestedBy = Value(requestedBy),
       requestedByName = Value(requestedByName),
       serverUpdatedAt = Value(serverUpdatedAt),
       cachedAt = Value(cachedAt);
  static Insertable<LocalAnimalMovement> custom({
    Expression<String>? id,
    Expression<String>? organizationId,
    Expression<String>? animalId,
    Expression<String>? animalNumber,
    Expression<String>? sourceFarmId,
    Expression<String>? sourceFarmName,
    Expression<String>? sourceShedId,
    Expression<String>? sourceShedName,
    Expression<String>? sourceAnimalGroupId,
    Expression<String>? sourceAnimalGroupName,
    Expression<String>? destinationFarmId,
    Expression<String>? destinationFarmName,
    Expression<String>? destinationShedId,
    Expression<String>? destinationShedName,
    Expression<String>? destinationAnimalGroupId,
    Expression<String>? destinationAnimalGroupName,
    Expression<DateTime>? requestedEffectiveAt,
    Expression<DateTime>? actualEffectiveAt,
    Expression<String>? reason,
    Expression<String>? notes,
    Expression<String>? status,
    Expression<bool>? approvalRequired,
    Expression<String>? requestedBy,
    Expression<String>? requestedByName,
    Expression<String>? decidedBy,
    Expression<String>? decidedByName,
    Expression<DateTime>? decisionAt,
    Expression<String>? rejectionReason,
    Expression<String>? cancellationReason,
    Expression<int>? version,
    Expression<DateTime>? serverUpdatedAt,
    Expression<DateTime>? cachedAt,
    Expression<bool>? isAccessible,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (organizationId != null) 'organization_id': organizationId,
      if (animalId != null) 'animal_id': animalId,
      if (animalNumber != null) 'animal_number': animalNumber,
      if (sourceFarmId != null) 'source_farm_id': sourceFarmId,
      if (sourceFarmName != null) 'source_farm_name': sourceFarmName,
      if (sourceShedId != null) 'source_shed_id': sourceShedId,
      if (sourceShedName != null) 'source_shed_name': sourceShedName,
      if (sourceAnimalGroupId != null)
        'source_animal_group_id': sourceAnimalGroupId,
      if (sourceAnimalGroupName != null)
        'source_animal_group_name': sourceAnimalGroupName,
      if (destinationFarmId != null) 'destination_farm_id': destinationFarmId,
      if (destinationFarmName != null)
        'destination_farm_name': destinationFarmName,
      if (destinationShedId != null) 'destination_shed_id': destinationShedId,
      if (destinationShedName != null)
        'destination_shed_name': destinationShedName,
      if (destinationAnimalGroupId != null)
        'destination_animal_group_id': destinationAnimalGroupId,
      if (destinationAnimalGroupName != null)
        'destination_animal_group_name': destinationAnimalGroupName,
      if (requestedEffectiveAt != null)
        'requested_effective_at': requestedEffectiveAt,
      if (actualEffectiveAt != null) 'actual_effective_at': actualEffectiveAt,
      if (reason != null) 'reason': reason,
      if (notes != null) 'notes': notes,
      if (status != null) 'status': status,
      if (approvalRequired != null) 'approval_required': approvalRequired,
      if (requestedBy != null) 'requested_by': requestedBy,
      if (requestedByName != null) 'requested_by_name': requestedByName,
      if (decidedBy != null) 'decided_by': decidedBy,
      if (decidedByName != null) 'decided_by_name': decidedByName,
      if (decisionAt != null) 'decision_at': decisionAt,
      if (rejectionReason != null) 'rejection_reason': rejectionReason,
      if (cancellationReason != null) 'cancellation_reason': cancellationReason,
      if (version != null) 'version': version,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (isAccessible != null) 'is_accessible': isAccessible,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalAnimalMovementsCompanion copyWith({
    Value<String>? id,
    Value<String>? organizationId,
    Value<String>? animalId,
    Value<String>? animalNumber,
    Value<String>? sourceFarmId,
    Value<String>? sourceFarmName,
    Value<String>? sourceShedId,
    Value<String>? sourceShedName,
    Value<String?>? sourceAnimalGroupId,
    Value<String?>? sourceAnimalGroupName,
    Value<String>? destinationFarmId,
    Value<String>? destinationFarmName,
    Value<String>? destinationShedId,
    Value<String>? destinationShedName,
    Value<String?>? destinationAnimalGroupId,
    Value<String?>? destinationAnimalGroupName,
    Value<DateTime>? requestedEffectiveAt,
    Value<DateTime?>? actualEffectiveAt,
    Value<String>? reason,
    Value<String?>? notes,
    Value<String>? status,
    Value<bool>? approvalRequired,
    Value<String>? requestedBy,
    Value<String>? requestedByName,
    Value<String?>? decidedBy,
    Value<String?>? decidedByName,
    Value<DateTime?>? decisionAt,
    Value<String?>? rejectionReason,
    Value<String?>? cancellationReason,
    Value<int>? version,
    Value<DateTime>? serverUpdatedAt,
    Value<DateTime>? cachedAt,
    Value<bool>? isAccessible,
    Value<int>? rowid,
  }) {
    return LocalAnimalMovementsCompanion(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      animalId: animalId ?? this.animalId,
      animalNumber: animalNumber ?? this.animalNumber,
      sourceFarmId: sourceFarmId ?? this.sourceFarmId,
      sourceFarmName: sourceFarmName ?? this.sourceFarmName,
      sourceShedId: sourceShedId ?? this.sourceShedId,
      sourceShedName: sourceShedName ?? this.sourceShedName,
      sourceAnimalGroupId: sourceAnimalGroupId ?? this.sourceAnimalGroupId,
      sourceAnimalGroupName:
          sourceAnimalGroupName ?? this.sourceAnimalGroupName,
      destinationFarmId: destinationFarmId ?? this.destinationFarmId,
      destinationFarmName: destinationFarmName ?? this.destinationFarmName,
      destinationShedId: destinationShedId ?? this.destinationShedId,
      destinationShedName: destinationShedName ?? this.destinationShedName,
      destinationAnimalGroupId:
          destinationAnimalGroupId ?? this.destinationAnimalGroupId,
      destinationAnimalGroupName:
          destinationAnimalGroupName ?? this.destinationAnimalGroupName,
      requestedEffectiveAt: requestedEffectiveAt ?? this.requestedEffectiveAt,
      actualEffectiveAt: actualEffectiveAt ?? this.actualEffectiveAt,
      reason: reason ?? this.reason,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      approvalRequired: approvalRequired ?? this.approvalRequired,
      requestedBy: requestedBy ?? this.requestedBy,
      requestedByName: requestedByName ?? this.requestedByName,
      decidedBy: decidedBy ?? this.decidedBy,
      decidedByName: decidedByName ?? this.decidedByName,
      decisionAt: decisionAt ?? this.decisionAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      version: version ?? this.version,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      cachedAt: cachedAt ?? this.cachedAt,
      isAccessible: isAccessible ?? this.isAccessible,
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
    if (animalId.present) {
      map['animal_id'] = Variable<String>(animalId.value);
    }
    if (animalNumber.present) {
      map['animal_number'] = Variable<String>(animalNumber.value);
    }
    if (sourceFarmId.present) {
      map['source_farm_id'] = Variable<String>(sourceFarmId.value);
    }
    if (sourceFarmName.present) {
      map['source_farm_name'] = Variable<String>(sourceFarmName.value);
    }
    if (sourceShedId.present) {
      map['source_shed_id'] = Variable<String>(sourceShedId.value);
    }
    if (sourceShedName.present) {
      map['source_shed_name'] = Variable<String>(sourceShedName.value);
    }
    if (sourceAnimalGroupId.present) {
      map['source_animal_group_id'] = Variable<String>(
        sourceAnimalGroupId.value,
      );
    }
    if (sourceAnimalGroupName.present) {
      map['source_animal_group_name'] = Variable<String>(
        sourceAnimalGroupName.value,
      );
    }
    if (destinationFarmId.present) {
      map['destination_farm_id'] = Variable<String>(destinationFarmId.value);
    }
    if (destinationFarmName.present) {
      map['destination_farm_name'] = Variable<String>(
        destinationFarmName.value,
      );
    }
    if (destinationShedId.present) {
      map['destination_shed_id'] = Variable<String>(destinationShedId.value);
    }
    if (destinationShedName.present) {
      map['destination_shed_name'] = Variable<String>(
        destinationShedName.value,
      );
    }
    if (destinationAnimalGroupId.present) {
      map['destination_animal_group_id'] = Variable<String>(
        destinationAnimalGroupId.value,
      );
    }
    if (destinationAnimalGroupName.present) {
      map['destination_animal_group_name'] = Variable<String>(
        destinationAnimalGroupName.value,
      );
    }
    if (requestedEffectiveAt.present) {
      map['requested_effective_at'] = Variable<DateTime>(
        requestedEffectiveAt.value,
      );
    }
    if (actualEffectiveAt.present) {
      map['actual_effective_at'] = Variable<DateTime>(actualEffectiveAt.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (approvalRequired.present) {
      map['approval_required'] = Variable<bool>(approvalRequired.value);
    }
    if (requestedBy.present) {
      map['requested_by'] = Variable<String>(requestedBy.value);
    }
    if (requestedByName.present) {
      map['requested_by_name'] = Variable<String>(requestedByName.value);
    }
    if (decidedBy.present) {
      map['decided_by'] = Variable<String>(decidedBy.value);
    }
    if (decidedByName.present) {
      map['decided_by_name'] = Variable<String>(decidedByName.value);
    }
    if (decisionAt.present) {
      map['decision_at'] = Variable<DateTime>(decisionAt.value);
    }
    if (rejectionReason.present) {
      map['rejection_reason'] = Variable<String>(rejectionReason.value);
    }
    if (cancellationReason.present) {
      map['cancellation_reason'] = Variable<String>(cancellationReason.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<DateTime>(serverUpdatedAt.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (isAccessible.present) {
      map['is_accessible'] = Variable<bool>(isAccessible.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalAnimalMovementsCompanion(')
          ..write('id: $id, ')
          ..write('organizationId: $organizationId, ')
          ..write('animalId: $animalId, ')
          ..write('animalNumber: $animalNumber, ')
          ..write('sourceFarmId: $sourceFarmId, ')
          ..write('sourceFarmName: $sourceFarmName, ')
          ..write('sourceShedId: $sourceShedId, ')
          ..write('sourceShedName: $sourceShedName, ')
          ..write('sourceAnimalGroupId: $sourceAnimalGroupId, ')
          ..write('sourceAnimalGroupName: $sourceAnimalGroupName, ')
          ..write('destinationFarmId: $destinationFarmId, ')
          ..write('destinationFarmName: $destinationFarmName, ')
          ..write('destinationShedId: $destinationShedId, ')
          ..write('destinationShedName: $destinationShedName, ')
          ..write('destinationAnimalGroupId: $destinationAnimalGroupId, ')
          ..write('destinationAnimalGroupName: $destinationAnimalGroupName, ')
          ..write('requestedEffectiveAt: $requestedEffectiveAt, ')
          ..write('actualEffectiveAt: $actualEffectiveAt, ')
          ..write('reason: $reason, ')
          ..write('notes: $notes, ')
          ..write('status: $status, ')
          ..write('approvalRequired: $approvalRequired, ')
          ..write('requestedBy: $requestedBy, ')
          ..write('requestedByName: $requestedByName, ')
          ..write('decidedBy: $decidedBy, ')
          ..write('decidedByName: $decidedByName, ')
          ..write('decisionAt: $decisionAt, ')
          ..write('rejectionReason: $rejectionReason, ')
          ..write('cancellationReason: $cancellationReason, ')
          ..write('version: $version, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('isAccessible: $isAccessible, ')
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
  late final $LocalAnimalSpeciesTable localAnimalSpecies =
      $LocalAnimalSpeciesTable(this);
  late final $LocalAnimalBreedsTable localAnimalBreeds =
      $LocalAnimalBreedsTable(this);
  late final $LocalAnimalGroupsTable localAnimalGroups =
      $LocalAnimalGroupsTable(this);
  late final $LocalAnimalsTable localAnimals = $LocalAnimalsTable(this);
  late final $LocalAnimalMovementsTable localAnimalMovements =
      $LocalAnimalMovementsTable(this);
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
    localAnimalSpecies,
    localAnimalBreeds,
    localAnimalGroups,
    localAnimals,
    localAnimalMovements,
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
typedef $$LocalAnimalSpeciesTableCreateCompanionBuilder =
    LocalAnimalSpeciesCompanion Function({
      required String id,
      required String code,
      required String name,
      Value<bool> isActive,
      Value<int> version,
      required DateTime serverUpdatedAt,
      required DateTime cachedAt,
      Value<int> rowid,
    });
typedef $$LocalAnimalSpeciesTableUpdateCompanionBuilder =
    LocalAnimalSpeciesCompanion Function({
      Value<String> id,
      Value<String> code,
      Value<String> name,
      Value<bool> isActive,
      Value<int> version,
      Value<DateTime> serverUpdatedAt,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });

class $$LocalAnimalSpeciesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalAnimalSpeciesTable> {
  $$LocalAnimalSpeciesTableFilterComposer({
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

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
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

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalAnimalSpeciesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalAnimalSpeciesTable> {
  $$LocalAnimalSpeciesTableOrderingComposer({
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

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
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

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalAnimalSpeciesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalAnimalSpeciesTable> {
  $$LocalAnimalSpeciesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<DateTime> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$LocalAnimalSpeciesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalAnimalSpeciesTable,
          LocalAnimalSpecy,
          $$LocalAnimalSpeciesTableFilterComposer,
          $$LocalAnimalSpeciesTableOrderingComposer,
          $$LocalAnimalSpeciesTableAnnotationComposer,
          $$LocalAnimalSpeciesTableCreateCompanionBuilder,
          $$LocalAnimalSpeciesTableUpdateCompanionBuilder,
          (
            LocalAnimalSpecy,
            BaseReferences<
              _$AppDatabase,
              $LocalAnimalSpeciesTable,
              LocalAnimalSpecy
            >,
          ),
          LocalAnimalSpecy,
          PrefetchHooks Function()
        > {
  $$LocalAnimalSpeciesTableTableManager(
    _$AppDatabase db,
    $LocalAnimalSpeciesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalAnimalSpeciesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalAnimalSpeciesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalAnimalSpeciesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<DateTime> serverUpdatedAt = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalAnimalSpeciesCompanion(
                id: id,
                code: code,
                name: name,
                isActive: isActive,
                version: version,
                serverUpdatedAt: serverUpdatedAt,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String code,
                required String name,
                Value<bool> isActive = const Value.absent(),
                Value<int> version = const Value.absent(),
                required DateTime serverUpdatedAt,
                required DateTime cachedAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalAnimalSpeciesCompanion.insert(
                id: id,
                code: code,
                name: name,
                isActive: isActive,
                version: version,
                serverUpdatedAt: serverUpdatedAt,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalAnimalSpeciesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalAnimalSpeciesTable,
      LocalAnimalSpecy,
      $$LocalAnimalSpeciesTableFilterComposer,
      $$LocalAnimalSpeciesTableOrderingComposer,
      $$LocalAnimalSpeciesTableAnnotationComposer,
      $$LocalAnimalSpeciesTableCreateCompanionBuilder,
      $$LocalAnimalSpeciesTableUpdateCompanionBuilder,
      (
        LocalAnimalSpecy,
        BaseReferences<
          _$AppDatabase,
          $LocalAnimalSpeciesTable,
          LocalAnimalSpecy
        >,
      ),
      LocalAnimalSpecy,
      PrefetchHooks Function()
    >;
typedef $$LocalAnimalBreedsTableCreateCompanionBuilder =
    LocalAnimalBreedsCompanion Function({
      required String id,
      required String organizationId,
      required String speciesId,
      required String code,
      required String name,
      Value<String?> description,
      Value<bool> isActive,
      Value<int> version,
      required DateTime serverUpdatedAt,
      required DateTime cachedAt,
      Value<bool> isArchived,
      Value<int> rowid,
    });
typedef $$LocalAnimalBreedsTableUpdateCompanionBuilder =
    LocalAnimalBreedsCompanion Function({
      Value<String> id,
      Value<String> organizationId,
      Value<String> speciesId,
      Value<String> code,
      Value<String> name,
      Value<String?> description,
      Value<bool> isActive,
      Value<int> version,
      Value<DateTime> serverUpdatedAt,
      Value<DateTime> cachedAt,
      Value<bool> isArchived,
      Value<int> rowid,
    });

class $$LocalAnimalBreedsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalAnimalBreedsTable> {
  $$LocalAnimalBreedsTableFilterComposer({
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

  ColumnFilters<String> get speciesId => $composableBuilder(
    column: $table.speciesId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
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

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
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

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalAnimalBreedsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalAnimalBreedsTable> {
  $$LocalAnimalBreedsTableOrderingComposer({
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

  ColumnOrderings<String> get speciesId => $composableBuilder(
    column: $table.speciesId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
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

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
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

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalAnimalBreedsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalAnimalBreedsTable> {
  $$LocalAnimalBreedsTableAnnotationComposer({
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

  GeneratedColumn<String> get speciesId =>
      $composableBuilder(column: $table.speciesId, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<DateTime> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );
}

class $$LocalAnimalBreedsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalAnimalBreedsTable,
          LocalAnimalBreed,
          $$LocalAnimalBreedsTableFilterComposer,
          $$LocalAnimalBreedsTableOrderingComposer,
          $$LocalAnimalBreedsTableAnnotationComposer,
          $$LocalAnimalBreedsTableCreateCompanionBuilder,
          $$LocalAnimalBreedsTableUpdateCompanionBuilder,
          (
            LocalAnimalBreed,
            BaseReferences<
              _$AppDatabase,
              $LocalAnimalBreedsTable,
              LocalAnimalBreed
            >,
          ),
          LocalAnimalBreed,
          PrefetchHooks Function()
        > {
  $$LocalAnimalBreedsTableTableManager(
    _$AppDatabase db,
    $LocalAnimalBreedsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalAnimalBreedsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalAnimalBreedsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalAnimalBreedsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> organizationId = const Value.absent(),
                Value<String> speciesId = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<DateTime> serverUpdatedAt = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalAnimalBreedsCompanion(
                id: id,
                organizationId: organizationId,
                speciesId: speciesId,
                code: code,
                name: name,
                description: description,
                isActive: isActive,
                version: version,
                serverUpdatedAt: serverUpdatedAt,
                cachedAt: cachedAt,
                isArchived: isArchived,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String organizationId,
                required String speciesId,
                required String code,
                required String name,
                Value<String?> description = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> version = const Value.absent(),
                required DateTime serverUpdatedAt,
                required DateTime cachedAt,
                Value<bool> isArchived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalAnimalBreedsCompanion.insert(
                id: id,
                organizationId: organizationId,
                speciesId: speciesId,
                code: code,
                name: name,
                description: description,
                isActive: isActive,
                version: version,
                serverUpdatedAt: serverUpdatedAt,
                cachedAt: cachedAt,
                isArchived: isArchived,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalAnimalBreedsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalAnimalBreedsTable,
      LocalAnimalBreed,
      $$LocalAnimalBreedsTableFilterComposer,
      $$LocalAnimalBreedsTableOrderingComposer,
      $$LocalAnimalBreedsTableAnnotationComposer,
      $$LocalAnimalBreedsTableCreateCompanionBuilder,
      $$LocalAnimalBreedsTableUpdateCompanionBuilder,
      (
        LocalAnimalBreed,
        BaseReferences<
          _$AppDatabase,
          $LocalAnimalBreedsTable,
          LocalAnimalBreed
        >,
      ),
      LocalAnimalBreed,
      PrefetchHooks Function()
    >;
typedef $$LocalAnimalGroupsTableCreateCompanionBuilder =
    LocalAnimalGroupsCompanion Function({
      required String id,
      required String organizationId,
      required String farmId,
      Value<String?> defaultShedId,
      required String code,
      required String name,
      Value<String?> description,
      Value<bool> isActive,
      Value<int> version,
      required DateTime serverUpdatedAt,
      required DateTime cachedAt,
      Value<bool> isArchived,
      Value<bool> isAccessible,
      Value<int> rowid,
    });
typedef $$LocalAnimalGroupsTableUpdateCompanionBuilder =
    LocalAnimalGroupsCompanion Function({
      Value<String> id,
      Value<String> organizationId,
      Value<String> farmId,
      Value<String?> defaultShedId,
      Value<String> code,
      Value<String> name,
      Value<String?> description,
      Value<bool> isActive,
      Value<int> version,
      Value<DateTime> serverUpdatedAt,
      Value<DateTime> cachedAt,
      Value<bool> isArchived,
      Value<bool> isAccessible,
      Value<int> rowid,
    });

class $$LocalAnimalGroupsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalAnimalGroupsTable> {
  $$LocalAnimalGroupsTableFilterComposer({
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

  ColumnFilters<String> get defaultShedId => $composableBuilder(
    column: $table.defaultShedId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
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

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
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

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAccessible => $composableBuilder(
    column: $table.isAccessible,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalAnimalGroupsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalAnimalGroupsTable> {
  $$LocalAnimalGroupsTableOrderingComposer({
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

  ColumnOrderings<String> get defaultShedId => $composableBuilder(
    column: $table.defaultShedId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
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

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
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

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAccessible => $composableBuilder(
    column: $table.isAccessible,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalAnimalGroupsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalAnimalGroupsTable> {
  $$LocalAnimalGroupsTableAnnotationComposer({
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

  GeneratedColumn<String> get defaultShedId => $composableBuilder(
    column: $table.defaultShedId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<DateTime> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isAccessible => $composableBuilder(
    column: $table.isAccessible,
    builder: (column) => column,
  );
}

class $$LocalAnimalGroupsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalAnimalGroupsTable,
          LocalAnimalGroup,
          $$LocalAnimalGroupsTableFilterComposer,
          $$LocalAnimalGroupsTableOrderingComposer,
          $$LocalAnimalGroupsTableAnnotationComposer,
          $$LocalAnimalGroupsTableCreateCompanionBuilder,
          $$LocalAnimalGroupsTableUpdateCompanionBuilder,
          (
            LocalAnimalGroup,
            BaseReferences<
              _$AppDatabase,
              $LocalAnimalGroupsTable,
              LocalAnimalGroup
            >,
          ),
          LocalAnimalGroup,
          PrefetchHooks Function()
        > {
  $$LocalAnimalGroupsTableTableManager(
    _$AppDatabase db,
    $LocalAnimalGroupsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalAnimalGroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalAnimalGroupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalAnimalGroupsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> organizationId = const Value.absent(),
                Value<String> farmId = const Value.absent(),
                Value<String?> defaultShedId = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<DateTime> serverUpdatedAt = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<bool> isAccessible = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalAnimalGroupsCompanion(
                id: id,
                organizationId: organizationId,
                farmId: farmId,
                defaultShedId: defaultShedId,
                code: code,
                name: name,
                description: description,
                isActive: isActive,
                version: version,
                serverUpdatedAt: serverUpdatedAt,
                cachedAt: cachedAt,
                isArchived: isArchived,
                isAccessible: isAccessible,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String organizationId,
                required String farmId,
                Value<String?> defaultShedId = const Value.absent(),
                required String code,
                required String name,
                Value<String?> description = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> version = const Value.absent(),
                required DateTime serverUpdatedAt,
                required DateTime cachedAt,
                Value<bool> isArchived = const Value.absent(),
                Value<bool> isAccessible = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalAnimalGroupsCompanion.insert(
                id: id,
                organizationId: organizationId,
                farmId: farmId,
                defaultShedId: defaultShedId,
                code: code,
                name: name,
                description: description,
                isActive: isActive,
                version: version,
                serverUpdatedAt: serverUpdatedAt,
                cachedAt: cachedAt,
                isArchived: isArchived,
                isAccessible: isAccessible,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalAnimalGroupsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalAnimalGroupsTable,
      LocalAnimalGroup,
      $$LocalAnimalGroupsTableFilterComposer,
      $$LocalAnimalGroupsTableOrderingComposer,
      $$LocalAnimalGroupsTableAnnotationComposer,
      $$LocalAnimalGroupsTableCreateCompanionBuilder,
      $$LocalAnimalGroupsTableUpdateCompanionBuilder,
      (
        LocalAnimalGroup,
        BaseReferences<
          _$AppDatabase,
          $LocalAnimalGroupsTable,
          LocalAnimalGroup
        >,
      ),
      LocalAnimalGroup,
      PrefetchHooks Function()
    >;
typedef $$LocalAnimalsTableCreateCompanionBuilder =
    LocalAnimalsCompanion Function({
      required String id,
      required String organizationId,
      required String animalNumber,
      Value<String?> earTagNumber,
      Value<String?> rfidNumber,
      Value<String?> name,
      Value<String?> registrationNumber,
      required String speciesId,
      required String speciesName,
      required String breedId,
      required String breedName,
      required String sex,
      required String lifeStage,
      Value<DateTime?> dateOfBirth,
      Value<bool> isDateOfBirthEstimated,
      Value<String?> colour,
      Value<String?> identifyingMarks,
      required String currentFarmId,
      required String currentFarmName,
      required String currentShedId,
      required String currentShedName,
      Value<String?> currentAnimalGroupId,
      Value<String?> currentAnimalGroupName,
      Value<String?> motherAnimalId,
      Value<String?> motherAnimalNumber,
      Value<String?> fatherAnimalId,
      Value<String?> fatherAnimalNumber,
      Value<String?> externalSireReference,
      required String origin,
      Value<DateTime?> acquisitionDate,
      Value<String?> sourceDescription,
      Value<String?> notes,
      required String operationalStatus,
      Value<int> version,
      required DateTime serverUpdatedAt,
      required DateTime cachedAt,
      Value<bool> isArchived,
      Value<bool> isAccessible,
      Value<int> rowid,
    });
typedef $$LocalAnimalsTableUpdateCompanionBuilder =
    LocalAnimalsCompanion Function({
      Value<String> id,
      Value<String> organizationId,
      Value<String> animalNumber,
      Value<String?> earTagNumber,
      Value<String?> rfidNumber,
      Value<String?> name,
      Value<String?> registrationNumber,
      Value<String> speciesId,
      Value<String> speciesName,
      Value<String> breedId,
      Value<String> breedName,
      Value<String> sex,
      Value<String> lifeStage,
      Value<DateTime?> dateOfBirth,
      Value<bool> isDateOfBirthEstimated,
      Value<String?> colour,
      Value<String?> identifyingMarks,
      Value<String> currentFarmId,
      Value<String> currentFarmName,
      Value<String> currentShedId,
      Value<String> currentShedName,
      Value<String?> currentAnimalGroupId,
      Value<String?> currentAnimalGroupName,
      Value<String?> motherAnimalId,
      Value<String?> motherAnimalNumber,
      Value<String?> fatherAnimalId,
      Value<String?> fatherAnimalNumber,
      Value<String?> externalSireReference,
      Value<String> origin,
      Value<DateTime?> acquisitionDate,
      Value<String?> sourceDescription,
      Value<String?> notes,
      Value<String> operationalStatus,
      Value<int> version,
      Value<DateTime> serverUpdatedAt,
      Value<DateTime> cachedAt,
      Value<bool> isArchived,
      Value<bool> isAccessible,
      Value<int> rowid,
    });

class $$LocalAnimalsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalAnimalsTable> {
  $$LocalAnimalsTableFilterComposer({
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

  ColumnFilters<String> get animalNumber => $composableBuilder(
    column: $table.animalNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get earTagNumber => $composableBuilder(
    column: $table.earTagNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rfidNumber => $composableBuilder(
    column: $table.rfidNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get registrationNumber => $composableBuilder(
    column: $table.registrationNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get speciesId => $composableBuilder(
    column: $table.speciesId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get speciesName => $composableBuilder(
    column: $table.speciesName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get breedId => $composableBuilder(
    column: $table.breedId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get breedName => $composableBuilder(
    column: $table.breedName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sex => $composableBuilder(
    column: $table.sex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lifeStage => $composableBuilder(
    column: $table.lifeStage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateOfBirth => $composableBuilder(
    column: $table.dateOfBirth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDateOfBirthEstimated => $composableBuilder(
    column: $table.isDateOfBirthEstimated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colour => $composableBuilder(
    column: $table.colour,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get identifyingMarks => $composableBuilder(
    column: $table.identifyingMarks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currentFarmId => $composableBuilder(
    column: $table.currentFarmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currentFarmName => $composableBuilder(
    column: $table.currentFarmName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currentShedId => $composableBuilder(
    column: $table.currentShedId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currentShedName => $composableBuilder(
    column: $table.currentShedName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currentAnimalGroupId => $composableBuilder(
    column: $table.currentAnimalGroupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currentAnimalGroupName => $composableBuilder(
    column: $table.currentAnimalGroupName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get motherAnimalId => $composableBuilder(
    column: $table.motherAnimalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get motherAnimalNumber => $composableBuilder(
    column: $table.motherAnimalNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fatherAnimalId => $composableBuilder(
    column: $table.fatherAnimalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fatherAnimalNumber => $composableBuilder(
    column: $table.fatherAnimalNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get externalSireReference => $composableBuilder(
    column: $table.externalSireReference,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get acquisitionDate => $composableBuilder(
    column: $table.acquisitionDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceDescription => $composableBuilder(
    column: $table.sourceDescription,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operationalStatus => $composableBuilder(
    column: $table.operationalStatus,
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

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAccessible => $composableBuilder(
    column: $table.isAccessible,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalAnimalsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalAnimalsTable> {
  $$LocalAnimalsTableOrderingComposer({
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

  ColumnOrderings<String> get animalNumber => $composableBuilder(
    column: $table.animalNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get earTagNumber => $composableBuilder(
    column: $table.earTagNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rfidNumber => $composableBuilder(
    column: $table.rfidNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get registrationNumber => $composableBuilder(
    column: $table.registrationNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get speciesId => $composableBuilder(
    column: $table.speciesId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get speciesName => $composableBuilder(
    column: $table.speciesName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get breedId => $composableBuilder(
    column: $table.breedId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get breedName => $composableBuilder(
    column: $table.breedName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sex => $composableBuilder(
    column: $table.sex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lifeStage => $composableBuilder(
    column: $table.lifeStage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateOfBirth => $composableBuilder(
    column: $table.dateOfBirth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDateOfBirthEstimated => $composableBuilder(
    column: $table.isDateOfBirthEstimated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colour => $composableBuilder(
    column: $table.colour,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get identifyingMarks => $composableBuilder(
    column: $table.identifyingMarks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currentFarmId => $composableBuilder(
    column: $table.currentFarmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currentFarmName => $composableBuilder(
    column: $table.currentFarmName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currentShedId => $composableBuilder(
    column: $table.currentShedId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currentShedName => $composableBuilder(
    column: $table.currentShedName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currentAnimalGroupId => $composableBuilder(
    column: $table.currentAnimalGroupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currentAnimalGroupName => $composableBuilder(
    column: $table.currentAnimalGroupName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get motherAnimalId => $composableBuilder(
    column: $table.motherAnimalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get motherAnimalNumber => $composableBuilder(
    column: $table.motherAnimalNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fatherAnimalId => $composableBuilder(
    column: $table.fatherAnimalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fatherAnimalNumber => $composableBuilder(
    column: $table.fatherAnimalNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get externalSireReference => $composableBuilder(
    column: $table.externalSireReference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get acquisitionDate => $composableBuilder(
    column: $table.acquisitionDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceDescription => $composableBuilder(
    column: $table.sourceDescription,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operationalStatus => $composableBuilder(
    column: $table.operationalStatus,
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

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAccessible => $composableBuilder(
    column: $table.isAccessible,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalAnimalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalAnimalsTable> {
  $$LocalAnimalsTableAnnotationComposer({
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

  GeneratedColumn<String> get animalNumber => $composableBuilder(
    column: $table.animalNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get earTagNumber => $composableBuilder(
    column: $table.earTagNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rfidNumber => $composableBuilder(
    column: $table.rfidNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get registrationNumber => $composableBuilder(
    column: $table.registrationNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get speciesId =>
      $composableBuilder(column: $table.speciesId, builder: (column) => column);

  GeneratedColumn<String> get speciesName => $composableBuilder(
    column: $table.speciesName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get breedId =>
      $composableBuilder(column: $table.breedId, builder: (column) => column);

  GeneratedColumn<String> get breedName =>
      $composableBuilder(column: $table.breedName, builder: (column) => column);

  GeneratedColumn<String> get sex =>
      $composableBuilder(column: $table.sex, builder: (column) => column);

  GeneratedColumn<String> get lifeStage =>
      $composableBuilder(column: $table.lifeStage, builder: (column) => column);

  GeneratedColumn<DateTime> get dateOfBirth => $composableBuilder(
    column: $table.dateOfBirth,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDateOfBirthEstimated => $composableBuilder(
    column: $table.isDateOfBirthEstimated,
    builder: (column) => column,
  );

  GeneratedColumn<String> get colour =>
      $composableBuilder(column: $table.colour, builder: (column) => column);

  GeneratedColumn<String> get identifyingMarks => $composableBuilder(
    column: $table.identifyingMarks,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currentFarmId => $composableBuilder(
    column: $table.currentFarmId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currentFarmName => $composableBuilder(
    column: $table.currentFarmName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currentShedId => $composableBuilder(
    column: $table.currentShedId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currentShedName => $composableBuilder(
    column: $table.currentShedName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currentAnimalGroupId => $composableBuilder(
    column: $table.currentAnimalGroupId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currentAnimalGroupName => $composableBuilder(
    column: $table.currentAnimalGroupName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get motherAnimalId => $composableBuilder(
    column: $table.motherAnimalId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get motherAnimalNumber => $composableBuilder(
    column: $table.motherAnimalNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fatherAnimalId => $composableBuilder(
    column: $table.fatherAnimalId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fatherAnimalNumber => $composableBuilder(
    column: $table.fatherAnimalNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get externalSireReference => $composableBuilder(
    column: $table.externalSireReference,
    builder: (column) => column,
  );

  GeneratedColumn<String> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => column);

  GeneratedColumn<DateTime> get acquisitionDate => $composableBuilder(
    column: $table.acquisitionDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceDescription => $composableBuilder(
    column: $table.sourceDescription,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get operationalStatus => $composableBuilder(
    column: $table.operationalStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<DateTime> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isAccessible => $composableBuilder(
    column: $table.isAccessible,
    builder: (column) => column,
  );
}

class $$LocalAnimalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalAnimalsTable,
          LocalAnimal,
          $$LocalAnimalsTableFilterComposer,
          $$LocalAnimalsTableOrderingComposer,
          $$LocalAnimalsTableAnnotationComposer,
          $$LocalAnimalsTableCreateCompanionBuilder,
          $$LocalAnimalsTableUpdateCompanionBuilder,
          (
            LocalAnimal,
            BaseReferences<_$AppDatabase, $LocalAnimalsTable, LocalAnimal>,
          ),
          LocalAnimal,
          PrefetchHooks Function()
        > {
  $$LocalAnimalsTableTableManager(_$AppDatabase db, $LocalAnimalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalAnimalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalAnimalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalAnimalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> organizationId = const Value.absent(),
                Value<String> animalNumber = const Value.absent(),
                Value<String?> earTagNumber = const Value.absent(),
                Value<String?> rfidNumber = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<String?> registrationNumber = const Value.absent(),
                Value<String> speciesId = const Value.absent(),
                Value<String> speciesName = const Value.absent(),
                Value<String> breedId = const Value.absent(),
                Value<String> breedName = const Value.absent(),
                Value<String> sex = const Value.absent(),
                Value<String> lifeStage = const Value.absent(),
                Value<DateTime?> dateOfBirth = const Value.absent(),
                Value<bool> isDateOfBirthEstimated = const Value.absent(),
                Value<String?> colour = const Value.absent(),
                Value<String?> identifyingMarks = const Value.absent(),
                Value<String> currentFarmId = const Value.absent(),
                Value<String> currentFarmName = const Value.absent(),
                Value<String> currentShedId = const Value.absent(),
                Value<String> currentShedName = const Value.absent(),
                Value<String?> currentAnimalGroupId = const Value.absent(),
                Value<String?> currentAnimalGroupName = const Value.absent(),
                Value<String?> motherAnimalId = const Value.absent(),
                Value<String?> motherAnimalNumber = const Value.absent(),
                Value<String?> fatherAnimalId = const Value.absent(),
                Value<String?> fatherAnimalNumber = const Value.absent(),
                Value<String?> externalSireReference = const Value.absent(),
                Value<String> origin = const Value.absent(),
                Value<DateTime?> acquisitionDate = const Value.absent(),
                Value<String?> sourceDescription = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> operationalStatus = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<DateTime> serverUpdatedAt = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<bool> isAccessible = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalAnimalsCompanion(
                id: id,
                organizationId: organizationId,
                animalNumber: animalNumber,
                earTagNumber: earTagNumber,
                rfidNumber: rfidNumber,
                name: name,
                registrationNumber: registrationNumber,
                speciesId: speciesId,
                speciesName: speciesName,
                breedId: breedId,
                breedName: breedName,
                sex: sex,
                lifeStage: lifeStage,
                dateOfBirth: dateOfBirth,
                isDateOfBirthEstimated: isDateOfBirthEstimated,
                colour: colour,
                identifyingMarks: identifyingMarks,
                currentFarmId: currentFarmId,
                currentFarmName: currentFarmName,
                currentShedId: currentShedId,
                currentShedName: currentShedName,
                currentAnimalGroupId: currentAnimalGroupId,
                currentAnimalGroupName: currentAnimalGroupName,
                motherAnimalId: motherAnimalId,
                motherAnimalNumber: motherAnimalNumber,
                fatherAnimalId: fatherAnimalId,
                fatherAnimalNumber: fatherAnimalNumber,
                externalSireReference: externalSireReference,
                origin: origin,
                acquisitionDate: acquisitionDate,
                sourceDescription: sourceDescription,
                notes: notes,
                operationalStatus: operationalStatus,
                version: version,
                serverUpdatedAt: serverUpdatedAt,
                cachedAt: cachedAt,
                isArchived: isArchived,
                isAccessible: isAccessible,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String organizationId,
                required String animalNumber,
                Value<String?> earTagNumber = const Value.absent(),
                Value<String?> rfidNumber = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<String?> registrationNumber = const Value.absent(),
                required String speciesId,
                required String speciesName,
                required String breedId,
                required String breedName,
                required String sex,
                required String lifeStage,
                Value<DateTime?> dateOfBirth = const Value.absent(),
                Value<bool> isDateOfBirthEstimated = const Value.absent(),
                Value<String?> colour = const Value.absent(),
                Value<String?> identifyingMarks = const Value.absent(),
                required String currentFarmId,
                required String currentFarmName,
                required String currentShedId,
                required String currentShedName,
                Value<String?> currentAnimalGroupId = const Value.absent(),
                Value<String?> currentAnimalGroupName = const Value.absent(),
                Value<String?> motherAnimalId = const Value.absent(),
                Value<String?> motherAnimalNumber = const Value.absent(),
                Value<String?> fatherAnimalId = const Value.absent(),
                Value<String?> fatherAnimalNumber = const Value.absent(),
                Value<String?> externalSireReference = const Value.absent(),
                required String origin,
                Value<DateTime?> acquisitionDate = const Value.absent(),
                Value<String?> sourceDescription = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required String operationalStatus,
                Value<int> version = const Value.absent(),
                required DateTime serverUpdatedAt,
                required DateTime cachedAt,
                Value<bool> isArchived = const Value.absent(),
                Value<bool> isAccessible = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalAnimalsCompanion.insert(
                id: id,
                organizationId: organizationId,
                animalNumber: animalNumber,
                earTagNumber: earTagNumber,
                rfidNumber: rfidNumber,
                name: name,
                registrationNumber: registrationNumber,
                speciesId: speciesId,
                speciesName: speciesName,
                breedId: breedId,
                breedName: breedName,
                sex: sex,
                lifeStage: lifeStage,
                dateOfBirth: dateOfBirth,
                isDateOfBirthEstimated: isDateOfBirthEstimated,
                colour: colour,
                identifyingMarks: identifyingMarks,
                currentFarmId: currentFarmId,
                currentFarmName: currentFarmName,
                currentShedId: currentShedId,
                currentShedName: currentShedName,
                currentAnimalGroupId: currentAnimalGroupId,
                currentAnimalGroupName: currentAnimalGroupName,
                motherAnimalId: motherAnimalId,
                motherAnimalNumber: motherAnimalNumber,
                fatherAnimalId: fatherAnimalId,
                fatherAnimalNumber: fatherAnimalNumber,
                externalSireReference: externalSireReference,
                origin: origin,
                acquisitionDate: acquisitionDate,
                sourceDescription: sourceDescription,
                notes: notes,
                operationalStatus: operationalStatus,
                version: version,
                serverUpdatedAt: serverUpdatedAt,
                cachedAt: cachedAt,
                isArchived: isArchived,
                isAccessible: isAccessible,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalAnimalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalAnimalsTable,
      LocalAnimal,
      $$LocalAnimalsTableFilterComposer,
      $$LocalAnimalsTableOrderingComposer,
      $$LocalAnimalsTableAnnotationComposer,
      $$LocalAnimalsTableCreateCompanionBuilder,
      $$LocalAnimalsTableUpdateCompanionBuilder,
      (
        LocalAnimal,
        BaseReferences<_$AppDatabase, $LocalAnimalsTable, LocalAnimal>,
      ),
      LocalAnimal,
      PrefetchHooks Function()
    >;
typedef $$LocalAnimalMovementsTableCreateCompanionBuilder =
    LocalAnimalMovementsCompanion Function({
      required String id,
      required String organizationId,
      required String animalId,
      required String animalNumber,
      required String sourceFarmId,
      required String sourceFarmName,
      required String sourceShedId,
      required String sourceShedName,
      Value<String?> sourceAnimalGroupId,
      Value<String?> sourceAnimalGroupName,
      required String destinationFarmId,
      required String destinationFarmName,
      required String destinationShedId,
      required String destinationShedName,
      Value<String?> destinationAnimalGroupId,
      Value<String?> destinationAnimalGroupName,
      required DateTime requestedEffectiveAt,
      Value<DateTime?> actualEffectiveAt,
      required String reason,
      Value<String?> notes,
      required String status,
      Value<bool> approvalRequired,
      required String requestedBy,
      required String requestedByName,
      Value<String?> decidedBy,
      Value<String?> decidedByName,
      Value<DateTime?> decisionAt,
      Value<String?> rejectionReason,
      Value<String?> cancellationReason,
      Value<int> version,
      required DateTime serverUpdatedAt,
      required DateTime cachedAt,
      Value<bool> isAccessible,
      Value<int> rowid,
    });
typedef $$LocalAnimalMovementsTableUpdateCompanionBuilder =
    LocalAnimalMovementsCompanion Function({
      Value<String> id,
      Value<String> organizationId,
      Value<String> animalId,
      Value<String> animalNumber,
      Value<String> sourceFarmId,
      Value<String> sourceFarmName,
      Value<String> sourceShedId,
      Value<String> sourceShedName,
      Value<String?> sourceAnimalGroupId,
      Value<String?> sourceAnimalGroupName,
      Value<String> destinationFarmId,
      Value<String> destinationFarmName,
      Value<String> destinationShedId,
      Value<String> destinationShedName,
      Value<String?> destinationAnimalGroupId,
      Value<String?> destinationAnimalGroupName,
      Value<DateTime> requestedEffectiveAt,
      Value<DateTime?> actualEffectiveAt,
      Value<String> reason,
      Value<String?> notes,
      Value<String> status,
      Value<bool> approvalRequired,
      Value<String> requestedBy,
      Value<String> requestedByName,
      Value<String?> decidedBy,
      Value<String?> decidedByName,
      Value<DateTime?> decisionAt,
      Value<String?> rejectionReason,
      Value<String?> cancellationReason,
      Value<int> version,
      Value<DateTime> serverUpdatedAt,
      Value<DateTime> cachedAt,
      Value<bool> isAccessible,
      Value<int> rowid,
    });

class $$LocalAnimalMovementsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalAnimalMovementsTable> {
  $$LocalAnimalMovementsTableFilterComposer({
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

  ColumnFilters<String> get animalId => $composableBuilder(
    column: $table.animalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get animalNumber => $composableBuilder(
    column: $table.animalNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceFarmId => $composableBuilder(
    column: $table.sourceFarmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceFarmName => $composableBuilder(
    column: $table.sourceFarmName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceShedId => $composableBuilder(
    column: $table.sourceShedId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceShedName => $composableBuilder(
    column: $table.sourceShedName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceAnimalGroupId => $composableBuilder(
    column: $table.sourceAnimalGroupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceAnimalGroupName => $composableBuilder(
    column: $table.sourceAnimalGroupName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get destinationFarmId => $composableBuilder(
    column: $table.destinationFarmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get destinationFarmName => $composableBuilder(
    column: $table.destinationFarmName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get destinationShedId => $composableBuilder(
    column: $table.destinationShedId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get destinationShedName => $composableBuilder(
    column: $table.destinationShedName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get destinationAnimalGroupId => $composableBuilder(
    column: $table.destinationAnimalGroupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get destinationAnimalGroupName => $composableBuilder(
    column: $table.destinationAnimalGroupName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get requestedEffectiveAt => $composableBuilder(
    column: $table.requestedEffectiveAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get actualEffectiveAt => $composableBuilder(
    column: $table.actualEffectiveAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get approvalRequired => $composableBuilder(
    column: $table.approvalRequired,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get requestedBy => $composableBuilder(
    column: $table.requestedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get requestedByName => $composableBuilder(
    column: $table.requestedByName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get decidedBy => $composableBuilder(
    column: $table.decidedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get decidedByName => $composableBuilder(
    column: $table.decidedByName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get decisionAt => $composableBuilder(
    column: $table.decisionAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rejectionReason => $composableBuilder(
    column: $table.rejectionReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cancellationReason => $composableBuilder(
    column: $table.cancellationReason,
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

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAccessible => $composableBuilder(
    column: $table.isAccessible,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalAnimalMovementsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalAnimalMovementsTable> {
  $$LocalAnimalMovementsTableOrderingComposer({
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

  ColumnOrderings<String> get animalId => $composableBuilder(
    column: $table.animalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get animalNumber => $composableBuilder(
    column: $table.animalNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceFarmId => $composableBuilder(
    column: $table.sourceFarmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceFarmName => $composableBuilder(
    column: $table.sourceFarmName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceShedId => $composableBuilder(
    column: $table.sourceShedId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceShedName => $composableBuilder(
    column: $table.sourceShedName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceAnimalGroupId => $composableBuilder(
    column: $table.sourceAnimalGroupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceAnimalGroupName => $composableBuilder(
    column: $table.sourceAnimalGroupName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get destinationFarmId => $composableBuilder(
    column: $table.destinationFarmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get destinationFarmName => $composableBuilder(
    column: $table.destinationFarmName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get destinationShedId => $composableBuilder(
    column: $table.destinationShedId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get destinationShedName => $composableBuilder(
    column: $table.destinationShedName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get destinationAnimalGroupId => $composableBuilder(
    column: $table.destinationAnimalGroupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get destinationAnimalGroupName => $composableBuilder(
    column: $table.destinationAnimalGroupName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get requestedEffectiveAt => $composableBuilder(
    column: $table.requestedEffectiveAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get actualEffectiveAt => $composableBuilder(
    column: $table.actualEffectiveAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get approvalRequired => $composableBuilder(
    column: $table.approvalRequired,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get requestedBy => $composableBuilder(
    column: $table.requestedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get requestedByName => $composableBuilder(
    column: $table.requestedByName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get decidedBy => $composableBuilder(
    column: $table.decidedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get decidedByName => $composableBuilder(
    column: $table.decidedByName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get decisionAt => $composableBuilder(
    column: $table.decisionAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rejectionReason => $composableBuilder(
    column: $table.rejectionReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cancellationReason => $composableBuilder(
    column: $table.cancellationReason,
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

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAccessible => $composableBuilder(
    column: $table.isAccessible,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalAnimalMovementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalAnimalMovementsTable> {
  $$LocalAnimalMovementsTableAnnotationComposer({
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

  GeneratedColumn<String> get animalId =>
      $composableBuilder(column: $table.animalId, builder: (column) => column);

  GeneratedColumn<String> get animalNumber => $composableBuilder(
    column: $table.animalNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceFarmId => $composableBuilder(
    column: $table.sourceFarmId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceFarmName => $composableBuilder(
    column: $table.sourceFarmName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceShedId => $composableBuilder(
    column: $table.sourceShedId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceShedName => $composableBuilder(
    column: $table.sourceShedName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceAnimalGroupId => $composableBuilder(
    column: $table.sourceAnimalGroupId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceAnimalGroupName => $composableBuilder(
    column: $table.sourceAnimalGroupName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get destinationFarmId => $composableBuilder(
    column: $table.destinationFarmId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get destinationFarmName => $composableBuilder(
    column: $table.destinationFarmName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get destinationShedId => $composableBuilder(
    column: $table.destinationShedId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get destinationShedName => $composableBuilder(
    column: $table.destinationShedName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get destinationAnimalGroupId => $composableBuilder(
    column: $table.destinationAnimalGroupId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get destinationAnimalGroupName => $composableBuilder(
    column: $table.destinationAnimalGroupName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get requestedEffectiveAt => $composableBuilder(
    column: $table.requestedEffectiveAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get actualEffectiveAt => $composableBuilder(
    column: $table.actualEffectiveAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get approvalRequired => $composableBuilder(
    column: $table.approvalRequired,
    builder: (column) => column,
  );

  GeneratedColumn<String> get requestedBy => $composableBuilder(
    column: $table.requestedBy,
    builder: (column) => column,
  );

  GeneratedColumn<String> get requestedByName => $composableBuilder(
    column: $table.requestedByName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get decidedBy =>
      $composableBuilder(column: $table.decidedBy, builder: (column) => column);

  GeneratedColumn<String> get decidedByName => $composableBuilder(
    column: $table.decidedByName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get decisionAt => $composableBuilder(
    column: $table.decisionAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rejectionReason => $composableBuilder(
    column: $table.rejectionReason,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cancellationReason => $composableBuilder(
    column: $table.cancellationReason,
    builder: (column) => column,
  );

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<DateTime> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);

  GeneratedColumn<bool> get isAccessible => $composableBuilder(
    column: $table.isAccessible,
    builder: (column) => column,
  );
}

class $$LocalAnimalMovementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalAnimalMovementsTable,
          LocalAnimalMovement,
          $$LocalAnimalMovementsTableFilterComposer,
          $$LocalAnimalMovementsTableOrderingComposer,
          $$LocalAnimalMovementsTableAnnotationComposer,
          $$LocalAnimalMovementsTableCreateCompanionBuilder,
          $$LocalAnimalMovementsTableUpdateCompanionBuilder,
          (
            LocalAnimalMovement,
            BaseReferences<
              _$AppDatabase,
              $LocalAnimalMovementsTable,
              LocalAnimalMovement
            >,
          ),
          LocalAnimalMovement,
          PrefetchHooks Function()
        > {
  $$LocalAnimalMovementsTableTableManager(
    _$AppDatabase db,
    $LocalAnimalMovementsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalAnimalMovementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalAnimalMovementsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalAnimalMovementsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> organizationId = const Value.absent(),
                Value<String> animalId = const Value.absent(),
                Value<String> animalNumber = const Value.absent(),
                Value<String> sourceFarmId = const Value.absent(),
                Value<String> sourceFarmName = const Value.absent(),
                Value<String> sourceShedId = const Value.absent(),
                Value<String> sourceShedName = const Value.absent(),
                Value<String?> sourceAnimalGroupId = const Value.absent(),
                Value<String?> sourceAnimalGroupName = const Value.absent(),
                Value<String> destinationFarmId = const Value.absent(),
                Value<String> destinationFarmName = const Value.absent(),
                Value<String> destinationShedId = const Value.absent(),
                Value<String> destinationShedName = const Value.absent(),
                Value<String?> destinationAnimalGroupId = const Value.absent(),
                Value<String?> destinationAnimalGroupName =
                    const Value.absent(),
                Value<DateTime> requestedEffectiveAt = const Value.absent(),
                Value<DateTime?> actualEffectiveAt = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<bool> approvalRequired = const Value.absent(),
                Value<String> requestedBy = const Value.absent(),
                Value<String> requestedByName = const Value.absent(),
                Value<String?> decidedBy = const Value.absent(),
                Value<String?> decidedByName = const Value.absent(),
                Value<DateTime?> decisionAt = const Value.absent(),
                Value<String?> rejectionReason = const Value.absent(),
                Value<String?> cancellationReason = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<DateTime> serverUpdatedAt = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<bool> isAccessible = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalAnimalMovementsCompanion(
                id: id,
                organizationId: organizationId,
                animalId: animalId,
                animalNumber: animalNumber,
                sourceFarmId: sourceFarmId,
                sourceFarmName: sourceFarmName,
                sourceShedId: sourceShedId,
                sourceShedName: sourceShedName,
                sourceAnimalGroupId: sourceAnimalGroupId,
                sourceAnimalGroupName: sourceAnimalGroupName,
                destinationFarmId: destinationFarmId,
                destinationFarmName: destinationFarmName,
                destinationShedId: destinationShedId,
                destinationShedName: destinationShedName,
                destinationAnimalGroupId: destinationAnimalGroupId,
                destinationAnimalGroupName: destinationAnimalGroupName,
                requestedEffectiveAt: requestedEffectiveAt,
                actualEffectiveAt: actualEffectiveAt,
                reason: reason,
                notes: notes,
                status: status,
                approvalRequired: approvalRequired,
                requestedBy: requestedBy,
                requestedByName: requestedByName,
                decidedBy: decidedBy,
                decidedByName: decidedByName,
                decisionAt: decisionAt,
                rejectionReason: rejectionReason,
                cancellationReason: cancellationReason,
                version: version,
                serverUpdatedAt: serverUpdatedAt,
                cachedAt: cachedAt,
                isAccessible: isAccessible,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String organizationId,
                required String animalId,
                required String animalNumber,
                required String sourceFarmId,
                required String sourceFarmName,
                required String sourceShedId,
                required String sourceShedName,
                Value<String?> sourceAnimalGroupId = const Value.absent(),
                Value<String?> sourceAnimalGroupName = const Value.absent(),
                required String destinationFarmId,
                required String destinationFarmName,
                required String destinationShedId,
                required String destinationShedName,
                Value<String?> destinationAnimalGroupId = const Value.absent(),
                Value<String?> destinationAnimalGroupName =
                    const Value.absent(),
                required DateTime requestedEffectiveAt,
                Value<DateTime?> actualEffectiveAt = const Value.absent(),
                required String reason,
                Value<String?> notes = const Value.absent(),
                required String status,
                Value<bool> approvalRequired = const Value.absent(),
                required String requestedBy,
                required String requestedByName,
                Value<String?> decidedBy = const Value.absent(),
                Value<String?> decidedByName = const Value.absent(),
                Value<DateTime?> decisionAt = const Value.absent(),
                Value<String?> rejectionReason = const Value.absent(),
                Value<String?> cancellationReason = const Value.absent(),
                Value<int> version = const Value.absent(),
                required DateTime serverUpdatedAt,
                required DateTime cachedAt,
                Value<bool> isAccessible = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalAnimalMovementsCompanion.insert(
                id: id,
                organizationId: organizationId,
                animalId: animalId,
                animalNumber: animalNumber,
                sourceFarmId: sourceFarmId,
                sourceFarmName: sourceFarmName,
                sourceShedId: sourceShedId,
                sourceShedName: sourceShedName,
                sourceAnimalGroupId: sourceAnimalGroupId,
                sourceAnimalGroupName: sourceAnimalGroupName,
                destinationFarmId: destinationFarmId,
                destinationFarmName: destinationFarmName,
                destinationShedId: destinationShedId,
                destinationShedName: destinationShedName,
                destinationAnimalGroupId: destinationAnimalGroupId,
                destinationAnimalGroupName: destinationAnimalGroupName,
                requestedEffectiveAt: requestedEffectiveAt,
                actualEffectiveAt: actualEffectiveAt,
                reason: reason,
                notes: notes,
                status: status,
                approvalRequired: approvalRequired,
                requestedBy: requestedBy,
                requestedByName: requestedByName,
                decidedBy: decidedBy,
                decidedByName: decidedByName,
                decisionAt: decisionAt,
                rejectionReason: rejectionReason,
                cancellationReason: cancellationReason,
                version: version,
                serverUpdatedAt: serverUpdatedAt,
                cachedAt: cachedAt,
                isAccessible: isAccessible,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalAnimalMovementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalAnimalMovementsTable,
      LocalAnimalMovement,
      $$LocalAnimalMovementsTableFilterComposer,
      $$LocalAnimalMovementsTableOrderingComposer,
      $$LocalAnimalMovementsTableAnnotationComposer,
      $$LocalAnimalMovementsTableCreateCompanionBuilder,
      $$LocalAnimalMovementsTableUpdateCompanionBuilder,
      (
        LocalAnimalMovement,
        BaseReferences<
          _$AppDatabase,
          $LocalAnimalMovementsTable,
          LocalAnimalMovement
        >,
      ),
      LocalAnimalMovement,
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
  $$LocalAnimalSpeciesTableTableManager get localAnimalSpecies =>
      $$LocalAnimalSpeciesTableTableManager(_db, _db.localAnimalSpecies);
  $$LocalAnimalBreedsTableTableManager get localAnimalBreeds =>
      $$LocalAnimalBreedsTableTableManager(_db, _db.localAnimalBreeds);
  $$LocalAnimalGroupsTableTableManager get localAnimalGroups =>
      $$LocalAnimalGroupsTableTableManager(_db, _db.localAnimalGroups);
  $$LocalAnimalsTableTableManager get localAnimals =>
      $$LocalAnimalsTableTableManager(_db, _db.localAnimals);
  $$LocalAnimalMovementsTableTableManager get localAnimalMovements =>
      $$LocalAnimalMovementsTableTableManager(_db, _db.localAnimalMovements);
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
