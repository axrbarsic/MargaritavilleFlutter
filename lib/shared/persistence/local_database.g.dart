// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_database.dart';

// ignore_for_file: type=lint
class $HousekeeperCatalogRecordsTable extends HousekeeperCatalogRecords
    with TableInfo<$HousekeeperCatalogRecordsTable, HousekeeperCatalogRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HousekeeperCatalogRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paletteKeyMeta = const VerificationMeta(
    'paletteKey',
  );
  @override
  late final GeneratedColumn<String> paletteKey = GeneratedColumn<String>(
    'palette_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    displayName,
    paletteKey,
    sortOrder,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'housekeeper_catalog_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<HousekeeperCatalogRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('palette_key')) {
      context.handle(
        _paletteKeyMeta,
        paletteKey.isAcceptableOrUnknown(data['palette_key']!, _paletteKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_paletteKeyMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {sortOrder},
  ];
  @override
  HousekeeperCatalogRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HousekeeperCatalogRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      paletteKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}palette_key'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $HousekeeperCatalogRecordsTable createAlias(String alias) {
    return $HousekeeperCatalogRecordsTable(attachedDatabase, alias);
  }
}

class HousekeeperCatalogRow extends DataClass
    implements Insertable<HousekeeperCatalogRow> {
  final String id;
  final String displayName;
  final String paletteKey;
  final int sortOrder;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const HousekeeperCatalogRow({
    required this.id,
    required this.displayName,
    required this.paletteKey,
    required this.sortOrder,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['display_name'] = Variable<String>(displayName);
    map['palette_key'] = Variable<String>(paletteKey);
    map['sort_order'] = Variable<int>(sortOrder);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  HousekeeperCatalogRecordsCompanion toCompanion(bool nullToAbsent) {
    return HousekeeperCatalogRecordsCompanion(
      id: Value(id),
      displayName: Value(displayName),
      paletteKey: Value(paletteKey),
      sortOrder: Value(sortOrder),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory HousekeeperCatalogRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HousekeeperCatalogRow(
      id: serializer.fromJson<String>(json['id']),
      displayName: serializer.fromJson<String>(json['displayName']),
      paletteKey: serializer.fromJson<String>(json['paletteKey']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'displayName': serializer.toJson<String>(displayName),
      'paletteKey': serializer.toJson<String>(paletteKey),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  HousekeeperCatalogRow copyWith({
    String? id,
    String? displayName,
    String? paletteKey,
    int? sortOrder,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => HousekeeperCatalogRow(
    id: id ?? this.id,
    displayName: displayName ?? this.displayName,
    paletteKey: paletteKey ?? this.paletteKey,
    sortOrder: sortOrder ?? this.sortOrder,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  HousekeeperCatalogRow copyWithCompanion(
    HousekeeperCatalogRecordsCompanion data,
  ) {
    return HousekeeperCatalogRow(
      id: data.id.present ? data.id.value : this.id,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      paletteKey: data.paletteKey.present
          ? data.paletteKey.value
          : this.paletteKey,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HousekeeperCatalogRow(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('paletteKey: $paletteKey, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, displayName, paletteKey, sortOrder, updatedAt, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HousekeeperCatalogRow &&
          other.id == this.id &&
          other.displayName == this.displayName &&
          other.paletteKey == this.paletteKey &&
          other.sortOrder == this.sortOrder &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class HousekeeperCatalogRecordsCompanion
    extends UpdateCompanion<HousekeeperCatalogRow> {
  final Value<String> id;
  final Value<String> displayName;
  final Value<String> paletteKey;
  final Value<int> sortOrder;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const HousekeeperCatalogRecordsCompanion({
    this.id = const Value.absent(),
    this.displayName = const Value.absent(),
    this.paletteKey = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HousekeeperCatalogRecordsCompanion.insert({
    required String id,
    required String displayName,
    required String paletteKey,
    required int sortOrder,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       displayName = Value(displayName),
       paletteKey = Value(paletteKey),
       sortOrder = Value(sortOrder),
       updatedAt = Value(updatedAt);
  static Insertable<HousekeeperCatalogRow> custom({
    Expression<String>? id,
    Expression<String>? displayName,
    Expression<String>? paletteKey,
    Expression<int>? sortOrder,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (displayName != null) 'display_name': displayName,
      if (paletteKey != null) 'palette_key': paletteKey,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HousekeeperCatalogRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? displayName,
    Value<String>? paletteKey,
    Value<int>? sortOrder,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return HousekeeperCatalogRecordsCompanion(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      paletteKey: paletteKey ?? this.paletteKey,
      sortOrder: sortOrder ?? this.sortOrder,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (paletteKey.present) {
      map['palette_key'] = Variable<String>(paletteKey.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HousekeeperCatalogRecordsCompanion(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('paletteKey: $paletteKey, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkSessionRecordsTable extends WorkSessionRecords
    with TableInfo<$WorkSessionRecordsTable, WorkSessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkSessionRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _canonicalSchemaVersionMeta =
      const VerificationMeta('canonicalSchemaVersion');
  @override
  late final GeneratedColumn<int> canonicalSchemaVersion = GeneratedColumn<int>(
    'canonical_schema_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hotelIdMeta = const VerificationMeta(
    'hotelId',
  );
  @override
  late final GeneratedColumn<String> hotelId = GeneratedColumn<String>(
    'hotel_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hotelNameMeta = const VerificationMeta(
    'hotelName',
  );
  @override
  late final GeneratedColumn<String> hotelName = GeneratedColumn<String>(
    'hotel_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workflowMeta = const VerificationMeta(
    'workflow',
  );
  @override
  late final GeneratedColumn<String> workflow = GeneratedColumn<String>(
    'workflow',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
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
  static const VerificationMeta _workdayLockedMeta = const VerificationMeta(
    'workdayLocked',
  );
  @override
  late final GeneratedColumn<bool> workdayLocked = GeneratedColumn<bool>(
    'workday_locked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("workday_locked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lockUpdatedAtMeta = const VerificationMeta(
    'lockUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lockUpdatedAt =
      GeneratedColumn<DateTime>(
        'lock_updated_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    canonicalSchemaVersion,
    hotelId,
    hotelName,
    workflow,
    startedAt,
    updatedAt,
    workdayLocked,
    lockUpdatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'work_session_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkSessionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('canonical_schema_version')) {
      context.handle(
        _canonicalSchemaVersionMeta,
        canonicalSchemaVersion.isAcceptableOrUnknown(
          data['canonical_schema_version']!,
          _canonicalSchemaVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_canonicalSchemaVersionMeta);
    }
    if (data.containsKey('hotel_id')) {
      context.handle(
        _hotelIdMeta,
        hotelId.isAcceptableOrUnknown(data['hotel_id']!, _hotelIdMeta),
      );
    } else if (isInserting) {
      context.missing(_hotelIdMeta);
    }
    if (data.containsKey('hotel_name')) {
      context.handle(
        _hotelNameMeta,
        hotelName.isAcceptableOrUnknown(data['hotel_name']!, _hotelNameMeta),
      );
    } else if (isInserting) {
      context.missing(_hotelNameMeta);
    }
    if (data.containsKey('workflow')) {
      context.handle(
        _workflowMeta,
        workflow.isAcceptableOrUnknown(data['workflow']!, _workflowMeta),
      );
    } else if (isInserting) {
      context.missing(_workflowMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('workday_locked')) {
      context.handle(
        _workdayLockedMeta,
        workdayLocked.isAcceptableOrUnknown(
          data['workday_locked']!,
          _workdayLockedMeta,
        ),
      );
    }
    if (data.containsKey('lock_updated_at')) {
      context.handle(
        _lockUpdatedAtMeta,
        lockUpdatedAt.isAcceptableOrUnknown(
          data['lock_updated_at']!,
          _lockUpdatedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkSessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkSessionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      canonicalSchemaVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}canonical_schema_version'],
      )!,
      hotelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hotel_id'],
      )!,
      hotelName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hotel_name'],
      )!,
      workflow: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workflow'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      workdayLocked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}workday_locked'],
      )!,
      lockUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}lock_updated_at'],
      ),
    );
  }

  @override
  $WorkSessionRecordsTable createAlias(String alias) {
    return $WorkSessionRecordsTable(attachedDatabase, alias);
  }
}

class WorkSessionRow extends DataClass implements Insertable<WorkSessionRow> {
  final String id;
  final int canonicalSchemaVersion;
  final String hotelId;
  final String hotelName;
  final String workflow;
  final DateTime startedAt;
  final DateTime updatedAt;
  final bool workdayLocked;
  final DateTime? lockUpdatedAt;
  const WorkSessionRow({
    required this.id,
    required this.canonicalSchemaVersion,
    required this.hotelId,
    required this.hotelName,
    required this.workflow,
    required this.startedAt,
    required this.updatedAt,
    required this.workdayLocked,
    this.lockUpdatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['canonical_schema_version'] = Variable<int>(canonicalSchemaVersion);
    map['hotel_id'] = Variable<String>(hotelId);
    map['hotel_name'] = Variable<String>(hotelName);
    map['workflow'] = Variable<String>(workflow);
    map['started_at'] = Variable<DateTime>(startedAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['workday_locked'] = Variable<bool>(workdayLocked);
    if (!nullToAbsent || lockUpdatedAt != null) {
      map['lock_updated_at'] = Variable<DateTime>(lockUpdatedAt);
    }
    return map;
  }

  WorkSessionRecordsCompanion toCompanion(bool nullToAbsent) {
    return WorkSessionRecordsCompanion(
      id: Value(id),
      canonicalSchemaVersion: Value(canonicalSchemaVersion),
      hotelId: Value(hotelId),
      hotelName: Value(hotelName),
      workflow: Value(workflow),
      startedAt: Value(startedAt),
      updatedAt: Value(updatedAt),
      workdayLocked: Value(workdayLocked),
      lockUpdatedAt: lockUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lockUpdatedAt),
    );
  }

  factory WorkSessionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkSessionRow(
      id: serializer.fromJson<String>(json['id']),
      canonicalSchemaVersion: serializer.fromJson<int>(
        json['canonicalSchemaVersion'],
      ),
      hotelId: serializer.fromJson<String>(json['hotelId']),
      hotelName: serializer.fromJson<String>(json['hotelName']),
      workflow: serializer.fromJson<String>(json['workflow']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      workdayLocked: serializer.fromJson<bool>(json['workdayLocked']),
      lockUpdatedAt: serializer.fromJson<DateTime?>(json['lockUpdatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'canonicalSchemaVersion': serializer.toJson<int>(canonicalSchemaVersion),
      'hotelId': serializer.toJson<String>(hotelId),
      'hotelName': serializer.toJson<String>(hotelName),
      'workflow': serializer.toJson<String>(workflow),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'workdayLocked': serializer.toJson<bool>(workdayLocked),
      'lockUpdatedAt': serializer.toJson<DateTime?>(lockUpdatedAt),
    };
  }

  WorkSessionRow copyWith({
    String? id,
    int? canonicalSchemaVersion,
    String? hotelId,
    String? hotelName,
    String? workflow,
    DateTime? startedAt,
    DateTime? updatedAt,
    bool? workdayLocked,
    Value<DateTime?> lockUpdatedAt = const Value.absent(),
  }) => WorkSessionRow(
    id: id ?? this.id,
    canonicalSchemaVersion:
        canonicalSchemaVersion ?? this.canonicalSchemaVersion,
    hotelId: hotelId ?? this.hotelId,
    hotelName: hotelName ?? this.hotelName,
    workflow: workflow ?? this.workflow,
    startedAt: startedAt ?? this.startedAt,
    updatedAt: updatedAt ?? this.updatedAt,
    workdayLocked: workdayLocked ?? this.workdayLocked,
    lockUpdatedAt: lockUpdatedAt.present
        ? lockUpdatedAt.value
        : this.lockUpdatedAt,
  );
  WorkSessionRow copyWithCompanion(WorkSessionRecordsCompanion data) {
    return WorkSessionRow(
      id: data.id.present ? data.id.value : this.id,
      canonicalSchemaVersion: data.canonicalSchemaVersion.present
          ? data.canonicalSchemaVersion.value
          : this.canonicalSchemaVersion,
      hotelId: data.hotelId.present ? data.hotelId.value : this.hotelId,
      hotelName: data.hotelName.present ? data.hotelName.value : this.hotelName,
      workflow: data.workflow.present ? data.workflow.value : this.workflow,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      workdayLocked: data.workdayLocked.present
          ? data.workdayLocked.value
          : this.workdayLocked,
      lockUpdatedAt: data.lockUpdatedAt.present
          ? data.lockUpdatedAt.value
          : this.lockUpdatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkSessionRow(')
          ..write('id: $id, ')
          ..write('canonicalSchemaVersion: $canonicalSchemaVersion, ')
          ..write('hotelId: $hotelId, ')
          ..write('hotelName: $hotelName, ')
          ..write('workflow: $workflow, ')
          ..write('startedAt: $startedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('workdayLocked: $workdayLocked, ')
          ..write('lockUpdatedAt: $lockUpdatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    canonicalSchemaVersion,
    hotelId,
    hotelName,
    workflow,
    startedAt,
    updatedAt,
    workdayLocked,
    lockUpdatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkSessionRow &&
          other.id == this.id &&
          other.canonicalSchemaVersion == this.canonicalSchemaVersion &&
          other.hotelId == this.hotelId &&
          other.hotelName == this.hotelName &&
          other.workflow == this.workflow &&
          other.startedAt == this.startedAt &&
          other.updatedAt == this.updatedAt &&
          other.workdayLocked == this.workdayLocked &&
          other.lockUpdatedAt == this.lockUpdatedAt);
}

class WorkSessionRecordsCompanion extends UpdateCompanion<WorkSessionRow> {
  final Value<String> id;
  final Value<int> canonicalSchemaVersion;
  final Value<String> hotelId;
  final Value<String> hotelName;
  final Value<String> workflow;
  final Value<DateTime> startedAt;
  final Value<DateTime> updatedAt;
  final Value<bool> workdayLocked;
  final Value<DateTime?> lockUpdatedAt;
  final Value<int> rowid;
  const WorkSessionRecordsCompanion({
    this.id = const Value.absent(),
    this.canonicalSchemaVersion = const Value.absent(),
    this.hotelId = const Value.absent(),
    this.hotelName = const Value.absent(),
    this.workflow = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.workdayLocked = const Value.absent(),
    this.lockUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkSessionRecordsCompanion.insert({
    required String id,
    required int canonicalSchemaVersion,
    required String hotelId,
    required String hotelName,
    required String workflow,
    required DateTime startedAt,
    required DateTime updatedAt,
    this.workdayLocked = const Value.absent(),
    this.lockUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       canonicalSchemaVersion = Value(canonicalSchemaVersion),
       hotelId = Value(hotelId),
       hotelName = Value(hotelName),
       workflow = Value(workflow),
       startedAt = Value(startedAt),
       updatedAt = Value(updatedAt);
  static Insertable<WorkSessionRow> custom({
    Expression<String>? id,
    Expression<int>? canonicalSchemaVersion,
    Expression<String>? hotelId,
    Expression<String>? hotelName,
    Expression<String>? workflow,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? workdayLocked,
    Expression<DateTime>? lockUpdatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (canonicalSchemaVersion != null)
        'canonical_schema_version': canonicalSchemaVersion,
      if (hotelId != null) 'hotel_id': hotelId,
      if (hotelName != null) 'hotel_name': hotelName,
      if (workflow != null) 'workflow': workflow,
      if (startedAt != null) 'started_at': startedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (workdayLocked != null) 'workday_locked': workdayLocked,
      if (lockUpdatedAt != null) 'lock_updated_at': lockUpdatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkSessionRecordsCompanion copyWith({
    Value<String>? id,
    Value<int>? canonicalSchemaVersion,
    Value<String>? hotelId,
    Value<String>? hotelName,
    Value<String>? workflow,
    Value<DateTime>? startedAt,
    Value<DateTime>? updatedAt,
    Value<bool>? workdayLocked,
    Value<DateTime?>? lockUpdatedAt,
    Value<int>? rowid,
  }) {
    return WorkSessionRecordsCompanion(
      id: id ?? this.id,
      canonicalSchemaVersion:
          canonicalSchemaVersion ?? this.canonicalSchemaVersion,
      hotelId: hotelId ?? this.hotelId,
      hotelName: hotelName ?? this.hotelName,
      workflow: workflow ?? this.workflow,
      startedAt: startedAt ?? this.startedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      workdayLocked: workdayLocked ?? this.workdayLocked,
      lockUpdatedAt: lockUpdatedAt ?? this.lockUpdatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (canonicalSchemaVersion.present) {
      map['canonical_schema_version'] = Variable<int>(
        canonicalSchemaVersion.value,
      );
    }
    if (hotelId.present) {
      map['hotel_id'] = Variable<String>(hotelId.value);
    }
    if (hotelName.present) {
      map['hotel_name'] = Variable<String>(hotelName.value);
    }
    if (workflow.present) {
      map['workflow'] = Variable<String>(workflow.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (workdayLocked.present) {
      map['workday_locked'] = Variable<bool>(workdayLocked.value);
    }
    if (lockUpdatedAt.present) {
      map['lock_updated_at'] = Variable<DateTime>(lockUpdatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkSessionRecordsCompanion(')
          ..write('id: $id, ')
          ..write('canonicalSchemaVersion: $canonicalSchemaVersion, ')
          ..write('hotelId: $hotelId, ')
          ..write('hotelName: $hotelName, ')
          ..write('workflow: $workflow, ')
          ..write('startedAt: $startedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('workdayLocked: $workdayLocked, ')
          ..write('lockUpdatedAt: $lockUpdatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HousekeeperRecordsTable extends HousekeeperRecords
    with TableInfo<$HousekeeperRecordsTable, HousekeeperRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HousekeeperRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES work_session_records (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paletteKeyMeta = const VerificationMeta(
    'paletteKey',
  );
  @override
  late final GeneratedColumn<String> paletteKey = GeneratedColumn<String>(
    'palette_key',
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
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    sessionId,
    id,
    displayName,
    paletteKey,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'housekeeper_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<HousekeeperRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('palette_key')) {
      context.handle(
        _paletteKeyMeta,
        paletteKey.isAcceptableOrUnknown(data['palette_key']!, _paletteKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_paletteKeyMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sessionId, id};
  @override
  HousekeeperRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HousekeeperRow(
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      paletteKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}palette_key'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $HousekeeperRecordsTable createAlias(String alias) {
    return $HousekeeperRecordsTable(attachedDatabase, alias);
  }
}

class HousekeeperRow extends DataClass implements Insertable<HousekeeperRow> {
  final String sessionId;
  final String id;
  final String displayName;
  final String paletteKey;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const HousekeeperRow({
    required this.sessionId,
    required this.id,
    required this.displayName,
    required this.paletteKey,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['session_id'] = Variable<String>(sessionId);
    map['id'] = Variable<String>(id);
    map['display_name'] = Variable<String>(displayName);
    map['palette_key'] = Variable<String>(paletteKey);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  HousekeeperRecordsCompanion toCompanion(bool nullToAbsent) {
    return HousekeeperRecordsCompanion(
      sessionId: Value(sessionId),
      id: Value(id),
      displayName: Value(displayName),
      paletteKey: Value(paletteKey),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory HousekeeperRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HousekeeperRow(
      sessionId: serializer.fromJson<String>(json['sessionId']),
      id: serializer.fromJson<String>(json['id']),
      displayName: serializer.fromJson<String>(json['displayName']),
      paletteKey: serializer.fromJson<String>(json['paletteKey']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sessionId': serializer.toJson<String>(sessionId),
      'id': serializer.toJson<String>(id),
      'displayName': serializer.toJson<String>(displayName),
      'paletteKey': serializer.toJson<String>(paletteKey),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  HousekeeperRow copyWith({
    String? sessionId,
    String? id,
    String? displayName,
    String? paletteKey,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => HousekeeperRow(
    sessionId: sessionId ?? this.sessionId,
    id: id ?? this.id,
    displayName: displayName ?? this.displayName,
    paletteKey: paletteKey ?? this.paletteKey,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  HousekeeperRow copyWithCompanion(HousekeeperRecordsCompanion data) {
    return HousekeeperRow(
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      id: data.id.present ? data.id.value : this.id,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      paletteKey: data.paletteKey.present
          ? data.paletteKey.value
          : this.paletteKey,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HousekeeperRow(')
          ..write('sessionId: $sessionId, ')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('paletteKey: $paletteKey, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(sessionId, id, displayName, paletteKey, updatedAt, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HousekeeperRow &&
          other.sessionId == this.sessionId &&
          other.id == this.id &&
          other.displayName == this.displayName &&
          other.paletteKey == this.paletteKey &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class HousekeeperRecordsCompanion extends UpdateCompanion<HousekeeperRow> {
  final Value<String> sessionId;
  final Value<String> id;
  final Value<String> displayName;
  final Value<String> paletteKey;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const HousekeeperRecordsCompanion({
    this.sessionId = const Value.absent(),
    this.id = const Value.absent(),
    this.displayName = const Value.absent(),
    this.paletteKey = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HousekeeperRecordsCompanion.insert({
    required String sessionId,
    required String id,
    required String displayName,
    required String paletteKey,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : sessionId = Value(sessionId),
       id = Value(id),
       displayName = Value(displayName),
       paletteKey = Value(paletteKey),
       updatedAt = Value(updatedAt);
  static Insertable<HousekeeperRow> custom({
    Expression<String>? sessionId,
    Expression<String>? id,
    Expression<String>? displayName,
    Expression<String>? paletteKey,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sessionId != null) 'session_id': sessionId,
      if (id != null) 'id': id,
      if (displayName != null) 'display_name': displayName,
      if (paletteKey != null) 'palette_key': paletteKey,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HousekeeperRecordsCompanion copyWith({
    Value<String>? sessionId,
    Value<String>? id,
    Value<String>? displayName,
    Value<String>? paletteKey,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return HousekeeperRecordsCompanion(
      sessionId: sessionId ?? this.sessionId,
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      paletteKey: paletteKey ?? this.paletteKey,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (paletteKey.present) {
      map['palette_key'] = Variable<String>(paletteKey.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HousekeeperRecordsCompanion(')
          ..write('sessionId: $sessionId, ')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('paletteKey: $paletteKey, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkAssignmentRecordsTable extends WorkAssignmentRecords
    with TableInfo<$WorkAssignmentRecordsTable, WorkAssignmentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkAssignmentRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES work_session_records (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cartNumberMeta = const VerificationMeta(
    'cartNumber',
  );
  @override
  late final GeneratedColumn<int> cartNumber = GeneratedColumn<int>(
    'cart_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _housekeeperIdMeta = const VerificationMeta(
    'housekeeperId',
  );
  @override
  late final GeneratedColumn<String> housekeeperId = GeneratedColumn<String>(
    'housekeeper_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _territoryIdMeta = const VerificationMeta(
    'territoryId',
  );
  @override
  late final GeneratedColumn<String> territoryId = GeneratedColumn<String>(
    'territory_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _assignedAtMeta = const VerificationMeta(
    'assignedAt',
  );
  @override
  late final GeneratedColumn<DateTime> assignedAt = GeneratedColumn<DateTime>(
    'assigned_at',
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
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    sessionId,
    id,
    cartNumber,
    housekeeperId,
    territoryId,
    assignedAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'work_assignment_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkAssignmentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('cart_number')) {
      context.handle(
        _cartNumberMeta,
        cartNumber.isAcceptableOrUnknown(data['cart_number']!, _cartNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_cartNumberMeta);
    }
    if (data.containsKey('housekeeper_id')) {
      context.handle(
        _housekeeperIdMeta,
        housekeeperId.isAcceptableOrUnknown(
          data['housekeeper_id']!,
          _housekeeperIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_housekeeperIdMeta);
    }
    if (data.containsKey('territory_id')) {
      context.handle(
        _territoryIdMeta,
        territoryId.isAcceptableOrUnknown(
          data['territory_id']!,
          _territoryIdMeta,
        ),
      );
    }
    if (data.containsKey('assigned_at')) {
      context.handle(
        _assignedAtMeta,
        assignedAt.isAcceptableOrUnknown(data['assigned_at']!, _assignedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_assignedAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sessionId, id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {sessionId, cartNumber},
  ];
  @override
  WorkAssignmentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkAssignmentRow(
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      cartNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cart_number'],
      )!,
      housekeeperId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}housekeeper_id'],
      )!,
      territoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}territory_id'],
      ),
      assignedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}assigned_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $WorkAssignmentRecordsTable createAlias(String alias) {
    return $WorkAssignmentRecordsTable(attachedDatabase, alias);
  }
}

class WorkAssignmentRow extends DataClass
    implements Insertable<WorkAssignmentRow> {
  final String sessionId;
  final String id;
  final int cartNumber;
  final String housekeeperId;
  final String? territoryId;
  final DateTime assignedAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const WorkAssignmentRow({
    required this.sessionId,
    required this.id,
    required this.cartNumber,
    required this.housekeeperId,
    this.territoryId,
    required this.assignedAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['session_id'] = Variable<String>(sessionId);
    map['id'] = Variable<String>(id);
    map['cart_number'] = Variable<int>(cartNumber);
    map['housekeeper_id'] = Variable<String>(housekeeperId);
    if (!nullToAbsent || territoryId != null) {
      map['territory_id'] = Variable<String>(territoryId);
    }
    map['assigned_at'] = Variable<DateTime>(assignedAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  WorkAssignmentRecordsCompanion toCompanion(bool nullToAbsent) {
    return WorkAssignmentRecordsCompanion(
      sessionId: Value(sessionId),
      id: Value(id),
      cartNumber: Value(cartNumber),
      housekeeperId: Value(housekeeperId),
      territoryId: territoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(territoryId),
      assignedAt: Value(assignedAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory WorkAssignmentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkAssignmentRow(
      sessionId: serializer.fromJson<String>(json['sessionId']),
      id: serializer.fromJson<String>(json['id']),
      cartNumber: serializer.fromJson<int>(json['cartNumber']),
      housekeeperId: serializer.fromJson<String>(json['housekeeperId']),
      territoryId: serializer.fromJson<String?>(json['territoryId']),
      assignedAt: serializer.fromJson<DateTime>(json['assignedAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sessionId': serializer.toJson<String>(sessionId),
      'id': serializer.toJson<String>(id),
      'cartNumber': serializer.toJson<int>(cartNumber),
      'housekeeperId': serializer.toJson<String>(housekeeperId),
      'territoryId': serializer.toJson<String?>(territoryId),
      'assignedAt': serializer.toJson<DateTime>(assignedAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  WorkAssignmentRow copyWith({
    String? sessionId,
    String? id,
    int? cartNumber,
    String? housekeeperId,
    Value<String?> territoryId = const Value.absent(),
    DateTime? assignedAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => WorkAssignmentRow(
    sessionId: sessionId ?? this.sessionId,
    id: id ?? this.id,
    cartNumber: cartNumber ?? this.cartNumber,
    housekeeperId: housekeeperId ?? this.housekeeperId,
    territoryId: territoryId.present ? territoryId.value : this.territoryId,
    assignedAt: assignedAt ?? this.assignedAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  WorkAssignmentRow copyWithCompanion(WorkAssignmentRecordsCompanion data) {
    return WorkAssignmentRow(
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      id: data.id.present ? data.id.value : this.id,
      cartNumber: data.cartNumber.present
          ? data.cartNumber.value
          : this.cartNumber,
      housekeeperId: data.housekeeperId.present
          ? data.housekeeperId.value
          : this.housekeeperId,
      territoryId: data.territoryId.present
          ? data.territoryId.value
          : this.territoryId,
      assignedAt: data.assignedAt.present
          ? data.assignedAt.value
          : this.assignedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkAssignmentRow(')
          ..write('sessionId: $sessionId, ')
          ..write('id: $id, ')
          ..write('cartNumber: $cartNumber, ')
          ..write('housekeeperId: $housekeeperId, ')
          ..write('territoryId: $territoryId, ')
          ..write('assignedAt: $assignedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    sessionId,
    id,
    cartNumber,
    housekeeperId,
    territoryId,
    assignedAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkAssignmentRow &&
          other.sessionId == this.sessionId &&
          other.id == this.id &&
          other.cartNumber == this.cartNumber &&
          other.housekeeperId == this.housekeeperId &&
          other.territoryId == this.territoryId &&
          other.assignedAt == this.assignedAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class WorkAssignmentRecordsCompanion
    extends UpdateCompanion<WorkAssignmentRow> {
  final Value<String> sessionId;
  final Value<String> id;
  final Value<int> cartNumber;
  final Value<String> housekeeperId;
  final Value<String?> territoryId;
  final Value<DateTime> assignedAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const WorkAssignmentRecordsCompanion({
    this.sessionId = const Value.absent(),
    this.id = const Value.absent(),
    this.cartNumber = const Value.absent(),
    this.housekeeperId = const Value.absent(),
    this.territoryId = const Value.absent(),
    this.assignedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkAssignmentRecordsCompanion.insert({
    required String sessionId,
    required String id,
    required int cartNumber,
    required String housekeeperId,
    this.territoryId = const Value.absent(),
    required DateTime assignedAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : sessionId = Value(sessionId),
       id = Value(id),
       cartNumber = Value(cartNumber),
       housekeeperId = Value(housekeeperId),
       assignedAt = Value(assignedAt),
       updatedAt = Value(updatedAt);
  static Insertable<WorkAssignmentRow> custom({
    Expression<String>? sessionId,
    Expression<String>? id,
    Expression<int>? cartNumber,
    Expression<String>? housekeeperId,
    Expression<String>? territoryId,
    Expression<DateTime>? assignedAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sessionId != null) 'session_id': sessionId,
      if (id != null) 'id': id,
      if (cartNumber != null) 'cart_number': cartNumber,
      if (housekeeperId != null) 'housekeeper_id': housekeeperId,
      if (territoryId != null) 'territory_id': territoryId,
      if (assignedAt != null) 'assigned_at': assignedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkAssignmentRecordsCompanion copyWith({
    Value<String>? sessionId,
    Value<String>? id,
    Value<int>? cartNumber,
    Value<String>? housekeeperId,
    Value<String?>? territoryId,
    Value<DateTime>? assignedAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return WorkAssignmentRecordsCompanion(
      sessionId: sessionId ?? this.sessionId,
      id: id ?? this.id,
      cartNumber: cartNumber ?? this.cartNumber,
      housekeeperId: housekeeperId ?? this.housekeeperId,
      territoryId: territoryId ?? this.territoryId,
      assignedAt: assignedAt ?? this.assignedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (cartNumber.present) {
      map['cart_number'] = Variable<int>(cartNumber.value);
    }
    if (housekeeperId.present) {
      map['housekeeper_id'] = Variable<String>(housekeeperId.value);
    }
    if (territoryId.present) {
      map['territory_id'] = Variable<String>(territoryId.value);
    }
    if (assignedAt.present) {
      map['assigned_at'] = Variable<DateTime>(assignedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkAssignmentRecordsCompanion(')
          ..write('sessionId: $sessionId, ')
          ..write('id: $id, ')
          ..write('cartNumber: $cartNumber, ')
          ..write('housekeeperId: $housekeeperId, ')
          ..write('territoryId: $territoryId, ')
          ..write('assignedAt: $assignedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RoomStateRecordsTable extends RoomStateRecords
    with TableInfo<$RoomStateRecordsTable, RoomStateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoomStateRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES work_session_records (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _roomNumberMeta = const VerificationMeta(
    'roomNumber',
  );
  @override
  late final GeneratedColumn<String> roomNumber = GeneratedColumn<String>(
    'room_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _assignmentIdMeta = const VerificationMeta(
    'assignmentId',
  );
  @override
  late final GeneratedColumn<String> assignmentId = GeneratedColumn<String>(
    'assignment_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phaseMeta = const VerificationMeta('phase');
  @override
  late final GeneratedColumn<String> phase = GeneratedColumn<String>(
    'phase',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isVipMeta = const VerificationMeta('isVip');
  @override
  late final GeneratedColumn<bool> isVip = GeneratedColumn<bool>(
    'is_vip',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_vip" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _scheduledForMeta = const VerificationMeta(
    'scheduledFor',
  );
  @override
  late final GeneratedColumn<DateTime> scheduledFor = GeneratedColumn<DateTime>(
    'scheduled_for',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _selectedAtMeta = const VerificationMeta(
    'selectedAt',
  );
  @override
  late final GeneratedColumn<DateTime> selectedAt = GeneratedColumn<DateTime>(
    'selected_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phaseUpdatedAtMeta = const VerificationMeta(
    'phaseUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> phaseUpdatedAt =
      GeneratedColumn<DateTime>(
        'phase_updated_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _openedAtMeta = const VerificationMeta(
    'openedAt',
  );
  @override
  late final GeneratedColumn<DateTime> openedAt = GeneratedColumn<DateTime>(
    'opened_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _vipUpdatedAtMeta = const VerificationMeta(
    'vipUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> vipUpdatedAt = GeneratedColumn<DateTime>(
    'vip_updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scheduledUpdatedAtMeta =
      const VerificationMeta('scheduledUpdatedAt');
  @override
  late final GeneratedColumn<DateTime> scheduledUpdatedAt =
      GeneratedColumn<DateTime>(
        'scheduled_updated_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    sessionId,
    roomNumber,
    assignmentId,
    phase,
    isVip,
    scheduledFor,
    deletedAt,
    selectedAt,
    phaseUpdatedAt,
    openedAt,
    completedAt,
    vipUpdatedAt,
    scheduledUpdatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'room_state_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<RoomStateRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('room_number')) {
      context.handle(
        _roomNumberMeta,
        roomNumber.isAcceptableOrUnknown(data['room_number']!, _roomNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_roomNumberMeta);
    }
    if (data.containsKey('assignment_id')) {
      context.handle(
        _assignmentIdMeta,
        assignmentId.isAcceptableOrUnknown(
          data['assignment_id']!,
          _assignmentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_assignmentIdMeta);
    }
    if (data.containsKey('phase')) {
      context.handle(
        _phaseMeta,
        phase.isAcceptableOrUnknown(data['phase']!, _phaseMeta),
      );
    } else if (isInserting) {
      context.missing(_phaseMeta);
    }
    if (data.containsKey('is_vip')) {
      context.handle(
        _isVipMeta,
        isVip.isAcceptableOrUnknown(data['is_vip']!, _isVipMeta),
      );
    }
    if (data.containsKey('scheduled_for')) {
      context.handle(
        _scheduledForMeta,
        scheduledFor.isAcceptableOrUnknown(
          data['scheduled_for']!,
          _scheduledForMeta,
        ),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('selected_at')) {
      context.handle(
        _selectedAtMeta,
        selectedAt.isAcceptableOrUnknown(data['selected_at']!, _selectedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_selectedAtMeta);
    }
    if (data.containsKey('phase_updated_at')) {
      context.handle(
        _phaseUpdatedAtMeta,
        phaseUpdatedAt.isAcceptableOrUnknown(
          data['phase_updated_at']!,
          _phaseUpdatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_phaseUpdatedAtMeta);
    }
    if (data.containsKey('opened_at')) {
      context.handle(
        _openedAtMeta,
        openedAt.isAcceptableOrUnknown(data['opened_at']!, _openedAtMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('vip_updated_at')) {
      context.handle(
        _vipUpdatedAtMeta,
        vipUpdatedAt.isAcceptableOrUnknown(
          data['vip_updated_at']!,
          _vipUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('scheduled_updated_at')) {
      context.handle(
        _scheduledUpdatedAtMeta,
        scheduledUpdatedAt.isAcceptableOrUnknown(
          data['scheduled_updated_at']!,
          _scheduledUpdatedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sessionId, roomNumber};
  @override
  RoomStateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoomStateRow(
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      roomNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}room_number'],
      )!,
      assignmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assignment_id'],
      )!,
      phase: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phase'],
      )!,
      isVip: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_vip'],
      )!,
      scheduledFor: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scheduled_for'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      selectedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}selected_at'],
      )!,
      phaseUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}phase_updated_at'],
      )!,
      openedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}opened_at'],
      ),
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      vipUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}vip_updated_at'],
      ),
      scheduledUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scheduled_updated_at'],
      ),
    );
  }

  @override
  $RoomStateRecordsTable createAlias(String alias) {
    return $RoomStateRecordsTable(attachedDatabase, alias);
  }
}

class RoomStateRow extends DataClass implements Insertable<RoomStateRow> {
  final String sessionId;
  final String roomNumber;
  final String assignmentId;
  final String phase;
  final bool isVip;
  final DateTime? scheduledFor;
  final DateTime? deletedAt;
  final DateTime selectedAt;
  final DateTime phaseUpdatedAt;
  final DateTime? openedAt;
  final DateTime? completedAt;
  final DateTime? vipUpdatedAt;
  final DateTime? scheduledUpdatedAt;
  const RoomStateRow({
    required this.sessionId,
    required this.roomNumber,
    required this.assignmentId,
    required this.phase,
    required this.isVip,
    this.scheduledFor,
    this.deletedAt,
    required this.selectedAt,
    required this.phaseUpdatedAt,
    this.openedAt,
    this.completedAt,
    this.vipUpdatedAt,
    this.scheduledUpdatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['session_id'] = Variable<String>(sessionId);
    map['room_number'] = Variable<String>(roomNumber);
    map['assignment_id'] = Variable<String>(assignmentId);
    map['phase'] = Variable<String>(phase);
    map['is_vip'] = Variable<bool>(isVip);
    if (!nullToAbsent || scheduledFor != null) {
      map['scheduled_for'] = Variable<DateTime>(scheduledFor);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['selected_at'] = Variable<DateTime>(selectedAt);
    map['phase_updated_at'] = Variable<DateTime>(phaseUpdatedAt);
    if (!nullToAbsent || openedAt != null) {
      map['opened_at'] = Variable<DateTime>(openedAt);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    if (!nullToAbsent || vipUpdatedAt != null) {
      map['vip_updated_at'] = Variable<DateTime>(vipUpdatedAt);
    }
    if (!nullToAbsent || scheduledUpdatedAt != null) {
      map['scheduled_updated_at'] = Variable<DateTime>(scheduledUpdatedAt);
    }
    return map;
  }

  RoomStateRecordsCompanion toCompanion(bool nullToAbsent) {
    return RoomStateRecordsCompanion(
      sessionId: Value(sessionId),
      roomNumber: Value(roomNumber),
      assignmentId: Value(assignmentId),
      phase: Value(phase),
      isVip: Value(isVip),
      scheduledFor: scheduledFor == null && nullToAbsent
          ? const Value.absent()
          : Value(scheduledFor),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      selectedAt: Value(selectedAt),
      phaseUpdatedAt: Value(phaseUpdatedAt),
      openedAt: openedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(openedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      vipUpdatedAt: vipUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(vipUpdatedAt),
      scheduledUpdatedAt: scheduledUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(scheduledUpdatedAt),
    );
  }

  factory RoomStateRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoomStateRow(
      sessionId: serializer.fromJson<String>(json['sessionId']),
      roomNumber: serializer.fromJson<String>(json['roomNumber']),
      assignmentId: serializer.fromJson<String>(json['assignmentId']),
      phase: serializer.fromJson<String>(json['phase']),
      isVip: serializer.fromJson<bool>(json['isVip']),
      scheduledFor: serializer.fromJson<DateTime?>(json['scheduledFor']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      selectedAt: serializer.fromJson<DateTime>(json['selectedAt']),
      phaseUpdatedAt: serializer.fromJson<DateTime>(json['phaseUpdatedAt']),
      openedAt: serializer.fromJson<DateTime?>(json['openedAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      vipUpdatedAt: serializer.fromJson<DateTime?>(json['vipUpdatedAt']),
      scheduledUpdatedAt: serializer.fromJson<DateTime?>(
        json['scheduledUpdatedAt'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sessionId': serializer.toJson<String>(sessionId),
      'roomNumber': serializer.toJson<String>(roomNumber),
      'assignmentId': serializer.toJson<String>(assignmentId),
      'phase': serializer.toJson<String>(phase),
      'isVip': serializer.toJson<bool>(isVip),
      'scheduledFor': serializer.toJson<DateTime?>(scheduledFor),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'selectedAt': serializer.toJson<DateTime>(selectedAt),
      'phaseUpdatedAt': serializer.toJson<DateTime>(phaseUpdatedAt),
      'openedAt': serializer.toJson<DateTime?>(openedAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'vipUpdatedAt': serializer.toJson<DateTime?>(vipUpdatedAt),
      'scheduledUpdatedAt': serializer.toJson<DateTime?>(scheduledUpdatedAt),
    };
  }

  RoomStateRow copyWith({
    String? sessionId,
    String? roomNumber,
    String? assignmentId,
    String? phase,
    bool? isVip,
    Value<DateTime?> scheduledFor = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
    DateTime? selectedAt,
    DateTime? phaseUpdatedAt,
    Value<DateTime?> openedAt = const Value.absent(),
    Value<DateTime?> completedAt = const Value.absent(),
    Value<DateTime?> vipUpdatedAt = const Value.absent(),
    Value<DateTime?> scheduledUpdatedAt = const Value.absent(),
  }) => RoomStateRow(
    sessionId: sessionId ?? this.sessionId,
    roomNumber: roomNumber ?? this.roomNumber,
    assignmentId: assignmentId ?? this.assignmentId,
    phase: phase ?? this.phase,
    isVip: isVip ?? this.isVip,
    scheduledFor: scheduledFor.present ? scheduledFor.value : this.scheduledFor,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    selectedAt: selectedAt ?? this.selectedAt,
    phaseUpdatedAt: phaseUpdatedAt ?? this.phaseUpdatedAt,
    openedAt: openedAt.present ? openedAt.value : this.openedAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    vipUpdatedAt: vipUpdatedAt.present ? vipUpdatedAt.value : this.vipUpdatedAt,
    scheduledUpdatedAt: scheduledUpdatedAt.present
        ? scheduledUpdatedAt.value
        : this.scheduledUpdatedAt,
  );
  RoomStateRow copyWithCompanion(RoomStateRecordsCompanion data) {
    return RoomStateRow(
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      roomNumber: data.roomNumber.present
          ? data.roomNumber.value
          : this.roomNumber,
      assignmentId: data.assignmentId.present
          ? data.assignmentId.value
          : this.assignmentId,
      phase: data.phase.present ? data.phase.value : this.phase,
      isVip: data.isVip.present ? data.isVip.value : this.isVip,
      scheduledFor: data.scheduledFor.present
          ? data.scheduledFor.value
          : this.scheduledFor,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      selectedAt: data.selectedAt.present
          ? data.selectedAt.value
          : this.selectedAt,
      phaseUpdatedAt: data.phaseUpdatedAt.present
          ? data.phaseUpdatedAt.value
          : this.phaseUpdatedAt,
      openedAt: data.openedAt.present ? data.openedAt.value : this.openedAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      vipUpdatedAt: data.vipUpdatedAt.present
          ? data.vipUpdatedAt.value
          : this.vipUpdatedAt,
      scheduledUpdatedAt: data.scheduledUpdatedAt.present
          ? data.scheduledUpdatedAt.value
          : this.scheduledUpdatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoomStateRow(')
          ..write('sessionId: $sessionId, ')
          ..write('roomNumber: $roomNumber, ')
          ..write('assignmentId: $assignmentId, ')
          ..write('phase: $phase, ')
          ..write('isVip: $isVip, ')
          ..write('scheduledFor: $scheduledFor, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('selectedAt: $selectedAt, ')
          ..write('phaseUpdatedAt: $phaseUpdatedAt, ')
          ..write('openedAt: $openedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('vipUpdatedAt: $vipUpdatedAt, ')
          ..write('scheduledUpdatedAt: $scheduledUpdatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    sessionId,
    roomNumber,
    assignmentId,
    phase,
    isVip,
    scheduledFor,
    deletedAt,
    selectedAt,
    phaseUpdatedAt,
    openedAt,
    completedAt,
    vipUpdatedAt,
    scheduledUpdatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoomStateRow &&
          other.sessionId == this.sessionId &&
          other.roomNumber == this.roomNumber &&
          other.assignmentId == this.assignmentId &&
          other.phase == this.phase &&
          other.isVip == this.isVip &&
          other.scheduledFor == this.scheduledFor &&
          other.deletedAt == this.deletedAt &&
          other.selectedAt == this.selectedAt &&
          other.phaseUpdatedAt == this.phaseUpdatedAt &&
          other.openedAt == this.openedAt &&
          other.completedAt == this.completedAt &&
          other.vipUpdatedAt == this.vipUpdatedAt &&
          other.scheduledUpdatedAt == this.scheduledUpdatedAt);
}

class RoomStateRecordsCompanion extends UpdateCompanion<RoomStateRow> {
  final Value<String> sessionId;
  final Value<String> roomNumber;
  final Value<String> assignmentId;
  final Value<String> phase;
  final Value<bool> isVip;
  final Value<DateTime?> scheduledFor;
  final Value<DateTime?> deletedAt;
  final Value<DateTime> selectedAt;
  final Value<DateTime> phaseUpdatedAt;
  final Value<DateTime?> openedAt;
  final Value<DateTime?> completedAt;
  final Value<DateTime?> vipUpdatedAt;
  final Value<DateTime?> scheduledUpdatedAt;
  final Value<int> rowid;
  const RoomStateRecordsCompanion({
    this.sessionId = const Value.absent(),
    this.roomNumber = const Value.absent(),
    this.assignmentId = const Value.absent(),
    this.phase = const Value.absent(),
    this.isVip = const Value.absent(),
    this.scheduledFor = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.selectedAt = const Value.absent(),
    this.phaseUpdatedAt = const Value.absent(),
    this.openedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.vipUpdatedAt = const Value.absent(),
    this.scheduledUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoomStateRecordsCompanion.insert({
    required String sessionId,
    required String roomNumber,
    required String assignmentId,
    required String phase,
    this.isVip = const Value.absent(),
    this.scheduledFor = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required DateTime selectedAt,
    required DateTime phaseUpdatedAt,
    this.openedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.vipUpdatedAt = const Value.absent(),
    this.scheduledUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : sessionId = Value(sessionId),
       roomNumber = Value(roomNumber),
       assignmentId = Value(assignmentId),
       phase = Value(phase),
       selectedAt = Value(selectedAt),
       phaseUpdatedAt = Value(phaseUpdatedAt);
  static Insertable<RoomStateRow> custom({
    Expression<String>? sessionId,
    Expression<String>? roomNumber,
    Expression<String>? assignmentId,
    Expression<String>? phase,
    Expression<bool>? isVip,
    Expression<DateTime>? scheduledFor,
    Expression<DateTime>? deletedAt,
    Expression<DateTime>? selectedAt,
    Expression<DateTime>? phaseUpdatedAt,
    Expression<DateTime>? openedAt,
    Expression<DateTime>? completedAt,
    Expression<DateTime>? vipUpdatedAt,
    Expression<DateTime>? scheduledUpdatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sessionId != null) 'session_id': sessionId,
      if (roomNumber != null) 'room_number': roomNumber,
      if (assignmentId != null) 'assignment_id': assignmentId,
      if (phase != null) 'phase': phase,
      if (isVip != null) 'is_vip': isVip,
      if (scheduledFor != null) 'scheduled_for': scheduledFor,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (selectedAt != null) 'selected_at': selectedAt,
      if (phaseUpdatedAt != null) 'phase_updated_at': phaseUpdatedAt,
      if (openedAt != null) 'opened_at': openedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (vipUpdatedAt != null) 'vip_updated_at': vipUpdatedAt,
      if (scheduledUpdatedAt != null)
        'scheduled_updated_at': scheduledUpdatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoomStateRecordsCompanion copyWith({
    Value<String>? sessionId,
    Value<String>? roomNumber,
    Value<String>? assignmentId,
    Value<String>? phase,
    Value<bool>? isVip,
    Value<DateTime?>? scheduledFor,
    Value<DateTime?>? deletedAt,
    Value<DateTime>? selectedAt,
    Value<DateTime>? phaseUpdatedAt,
    Value<DateTime?>? openedAt,
    Value<DateTime?>? completedAt,
    Value<DateTime?>? vipUpdatedAt,
    Value<DateTime?>? scheduledUpdatedAt,
    Value<int>? rowid,
  }) {
    return RoomStateRecordsCompanion(
      sessionId: sessionId ?? this.sessionId,
      roomNumber: roomNumber ?? this.roomNumber,
      assignmentId: assignmentId ?? this.assignmentId,
      phase: phase ?? this.phase,
      isVip: isVip ?? this.isVip,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      deletedAt: deletedAt ?? this.deletedAt,
      selectedAt: selectedAt ?? this.selectedAt,
      phaseUpdatedAt: phaseUpdatedAt ?? this.phaseUpdatedAt,
      openedAt: openedAt ?? this.openedAt,
      completedAt: completedAt ?? this.completedAt,
      vipUpdatedAt: vipUpdatedAt ?? this.vipUpdatedAt,
      scheduledUpdatedAt: scheduledUpdatedAt ?? this.scheduledUpdatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (roomNumber.present) {
      map['room_number'] = Variable<String>(roomNumber.value);
    }
    if (assignmentId.present) {
      map['assignment_id'] = Variable<String>(assignmentId.value);
    }
    if (phase.present) {
      map['phase'] = Variable<String>(phase.value);
    }
    if (isVip.present) {
      map['is_vip'] = Variable<bool>(isVip.value);
    }
    if (scheduledFor.present) {
      map['scheduled_for'] = Variable<DateTime>(scheduledFor.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (selectedAt.present) {
      map['selected_at'] = Variable<DateTime>(selectedAt.value);
    }
    if (phaseUpdatedAt.present) {
      map['phase_updated_at'] = Variable<DateTime>(phaseUpdatedAt.value);
    }
    if (openedAt.present) {
      map['opened_at'] = Variable<DateTime>(openedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (vipUpdatedAt.present) {
      map['vip_updated_at'] = Variable<DateTime>(vipUpdatedAt.value);
    }
    if (scheduledUpdatedAt.present) {
      map['scheduled_updated_at'] = Variable<DateTime>(
        scheduledUpdatedAt.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoomStateRecordsCompanion(')
          ..write('sessionId: $sessionId, ')
          ..write('roomNumber: $roomNumber, ')
          ..write('assignmentId: $assignmentId, ')
          ..write('phase: $phase, ')
          ..write('isVip: $isVip, ')
          ..write('scheduledFor: $scheduledFor, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('selectedAt: $selectedAt, ')
          ..write('phaseUpdatedAt: $phaseUpdatedAt, ')
          ..write('openedAt: $openedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('vipUpdatedAt: $vipUpdatedAt, ')
          ..write('scheduledUpdatedAt: $scheduledUpdatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RoomNoteRecordsTable extends RoomNoteRecords
    with TableInfo<$RoomNoteRecordsTable, RoomNoteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoomNoteRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES work_session_records (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _roomNumberMeta = const VerificationMeta(
    'roomNumber',
  );
  @override
  late final GeneratedColumn<String> roomNumber = GeneratedColumn<String>(
    'room_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _textValueMeta = const VerificationMeta(
    'textValue',
  );
  @override
  late final GeneratedColumn<String> textValue = GeneratedColumn<String>(
    'text_value',
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
  static const VerificationMeta _lastCommandIdMeta = const VerificationMeta(
    'lastCommandId',
  );
  @override
  late final GeneratedColumn<String> lastCommandId = GeneratedColumn<String>(
    'last_command_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    sessionId,
    roomNumber,
    textValue,
    updatedAt,
    lastCommandId,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'room_note_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<RoomNoteRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('room_number')) {
      context.handle(
        _roomNumberMeta,
        roomNumber.isAcceptableOrUnknown(data['room_number']!, _roomNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_roomNumberMeta);
    }
    if (data.containsKey('text_value')) {
      context.handle(
        _textValueMeta,
        textValue.isAcceptableOrUnknown(data['text_value']!, _textValueMeta),
      );
    } else if (isInserting) {
      context.missing(_textValueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('last_command_id')) {
      context.handle(
        _lastCommandIdMeta,
        lastCommandId.isAcceptableOrUnknown(
          data['last_command_id']!,
          _lastCommandIdMeta,
        ),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sessionId, roomNumber};
  @override
  RoomNoteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoomNoteRow(
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      roomNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}room_number'],
      )!,
      textValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text_value'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      lastCommandId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_command_id'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $RoomNoteRecordsTable createAlias(String alias) {
    return $RoomNoteRecordsTable(attachedDatabase, alias);
  }
}

class RoomNoteRow extends DataClass implements Insertable<RoomNoteRow> {
  final String sessionId;
  final String roomNumber;
  final String textValue;
  final DateTime updatedAt;
  final String? lastCommandId;
  final DateTime? deletedAt;
  const RoomNoteRow({
    required this.sessionId,
    required this.roomNumber,
    required this.textValue,
    required this.updatedAt,
    this.lastCommandId,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['session_id'] = Variable<String>(sessionId);
    map['room_number'] = Variable<String>(roomNumber);
    map['text_value'] = Variable<String>(textValue);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || lastCommandId != null) {
      map['last_command_id'] = Variable<String>(lastCommandId);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  RoomNoteRecordsCompanion toCompanion(bool nullToAbsent) {
    return RoomNoteRecordsCompanion(
      sessionId: Value(sessionId),
      roomNumber: Value(roomNumber),
      textValue: Value(textValue),
      updatedAt: Value(updatedAt),
      lastCommandId: lastCommandId == null && nullToAbsent
          ? const Value.absent()
          : Value(lastCommandId),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory RoomNoteRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoomNoteRow(
      sessionId: serializer.fromJson<String>(json['sessionId']),
      roomNumber: serializer.fromJson<String>(json['roomNumber']),
      textValue: serializer.fromJson<String>(json['textValue']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      lastCommandId: serializer.fromJson<String?>(json['lastCommandId']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sessionId': serializer.toJson<String>(sessionId),
      'roomNumber': serializer.toJson<String>(roomNumber),
      'textValue': serializer.toJson<String>(textValue),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'lastCommandId': serializer.toJson<String?>(lastCommandId),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  RoomNoteRow copyWith({
    String? sessionId,
    String? roomNumber,
    String? textValue,
    DateTime? updatedAt,
    Value<String?> lastCommandId = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => RoomNoteRow(
    sessionId: sessionId ?? this.sessionId,
    roomNumber: roomNumber ?? this.roomNumber,
    textValue: textValue ?? this.textValue,
    updatedAt: updatedAt ?? this.updatedAt,
    lastCommandId: lastCommandId.present
        ? lastCommandId.value
        : this.lastCommandId,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  RoomNoteRow copyWithCompanion(RoomNoteRecordsCompanion data) {
    return RoomNoteRow(
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      roomNumber: data.roomNumber.present
          ? data.roomNumber.value
          : this.roomNumber,
      textValue: data.textValue.present ? data.textValue.value : this.textValue,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      lastCommandId: data.lastCommandId.present
          ? data.lastCommandId.value
          : this.lastCommandId,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoomNoteRow(')
          ..write('sessionId: $sessionId, ')
          ..write('roomNumber: $roomNumber, ')
          ..write('textValue: $textValue, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastCommandId: $lastCommandId, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    sessionId,
    roomNumber,
    textValue,
    updatedAt,
    lastCommandId,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoomNoteRow &&
          other.sessionId == this.sessionId &&
          other.roomNumber == this.roomNumber &&
          other.textValue == this.textValue &&
          other.updatedAt == this.updatedAt &&
          other.lastCommandId == this.lastCommandId &&
          other.deletedAt == this.deletedAt);
}

class RoomNoteRecordsCompanion extends UpdateCompanion<RoomNoteRow> {
  final Value<String> sessionId;
  final Value<String> roomNumber;
  final Value<String> textValue;
  final Value<DateTime> updatedAt;
  final Value<String?> lastCommandId;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const RoomNoteRecordsCompanion({
    this.sessionId = const Value.absent(),
    this.roomNumber = const Value.absent(),
    this.textValue = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastCommandId = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoomNoteRecordsCompanion.insert({
    required String sessionId,
    required String roomNumber,
    required String textValue,
    required DateTime updatedAt,
    this.lastCommandId = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : sessionId = Value(sessionId),
       roomNumber = Value(roomNumber),
       textValue = Value(textValue),
       updatedAt = Value(updatedAt);
  static Insertable<RoomNoteRow> custom({
    Expression<String>? sessionId,
    Expression<String>? roomNumber,
    Expression<String>? textValue,
    Expression<DateTime>? updatedAt,
    Expression<String>? lastCommandId,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sessionId != null) 'session_id': sessionId,
      if (roomNumber != null) 'room_number': roomNumber,
      if (textValue != null) 'text_value': textValue,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (lastCommandId != null) 'last_command_id': lastCommandId,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoomNoteRecordsCompanion copyWith({
    Value<String>? sessionId,
    Value<String>? roomNumber,
    Value<String>? textValue,
    Value<DateTime>? updatedAt,
    Value<String?>? lastCommandId,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return RoomNoteRecordsCompanion(
      sessionId: sessionId ?? this.sessionId,
      roomNumber: roomNumber ?? this.roomNumber,
      textValue: textValue ?? this.textValue,
      updatedAt: updatedAt ?? this.updatedAt,
      lastCommandId: lastCommandId ?? this.lastCommandId,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (roomNumber.present) {
      map['room_number'] = Variable<String>(roomNumber.value);
    }
    if (textValue.present) {
      map['text_value'] = Variable<String>(textValue.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (lastCommandId.present) {
      map['last_command_id'] = Variable<String>(lastCommandId.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoomNoteRecordsCompanion(')
          ..write('sessionId: $sessionId, ')
          ..write('roomNumber: $roomNumber, ')
          ..write('textValue: $textValue, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastCommandId: $lastCommandId, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AssignmentNoteRecordsTable extends AssignmentNoteRecords
    with TableInfo<$AssignmentNoteRecordsTable, AssignmentNoteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssignmentNoteRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES work_session_records (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _assignmentIdMeta = const VerificationMeta(
    'assignmentId',
  );
  @override
  late final GeneratedColumn<String> assignmentId = GeneratedColumn<String>(
    'assignment_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _textValueMeta = const VerificationMeta(
    'textValue',
  );
  @override
  late final GeneratedColumn<String> textValue = GeneratedColumn<String>(
    'text_value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMicrosMeta = const VerificationMeta(
    'updatedAtMicros',
  );
  @override
  late final GeneratedColumn<int> updatedAtMicros = GeneratedColumn<int>(
    'updated_at_micros',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastCommandIdMeta = const VerificationMeta(
    'lastCommandId',
  );
  @override
  late final GeneratedColumn<String> lastCommandId = GeneratedColumn<String>(
    'last_command_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMicrosMeta = const VerificationMeta(
    'deletedAtMicros',
  );
  @override
  late final GeneratedColumn<int> deletedAtMicros = GeneratedColumn<int>(
    'deleted_at_micros',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    sessionId,
    assignmentId,
    textValue,
    updatedAtMicros,
    lastCommandId,
    deletedAtMicros,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'assignment_note_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<AssignmentNoteRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('assignment_id')) {
      context.handle(
        _assignmentIdMeta,
        assignmentId.isAcceptableOrUnknown(
          data['assignment_id']!,
          _assignmentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_assignmentIdMeta);
    }
    if (data.containsKey('text_value')) {
      context.handle(
        _textValueMeta,
        textValue.isAcceptableOrUnknown(data['text_value']!, _textValueMeta),
      );
    } else if (isInserting) {
      context.missing(_textValueMeta);
    }
    if (data.containsKey('updated_at_micros')) {
      context.handle(
        _updatedAtMicrosMeta,
        updatedAtMicros.isAcceptableOrUnknown(
          data['updated_at_micros']!,
          _updatedAtMicrosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMicrosMeta);
    }
    if (data.containsKey('last_command_id')) {
      context.handle(
        _lastCommandIdMeta,
        lastCommandId.isAcceptableOrUnknown(
          data['last_command_id']!,
          _lastCommandIdMeta,
        ),
      );
    }
    if (data.containsKey('deleted_at_micros')) {
      context.handle(
        _deletedAtMicrosMeta,
        deletedAtMicros.isAcceptableOrUnknown(
          data['deleted_at_micros']!,
          _deletedAtMicrosMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sessionId, assignmentId};
  @override
  AssignmentNoteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AssignmentNoteRow(
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      assignmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assignment_id'],
      )!,
      textValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text_value'],
      )!,
      updatedAtMicros: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_micros'],
      )!,
      lastCommandId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_command_id'],
      ),
      deletedAtMicros: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at_micros'],
      ),
    );
  }

  @override
  $AssignmentNoteRecordsTable createAlias(String alias) {
    return $AssignmentNoteRecordsTable(attachedDatabase, alias);
  }
}

class AssignmentNoteRow extends DataClass
    implements Insertable<AssignmentNoteRow> {
  final String sessionId;
  final String assignmentId;
  final String textValue;
  final int updatedAtMicros;
  final String? lastCommandId;
  final int? deletedAtMicros;
  const AssignmentNoteRow({
    required this.sessionId,
    required this.assignmentId,
    required this.textValue,
    required this.updatedAtMicros,
    this.lastCommandId,
    this.deletedAtMicros,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['session_id'] = Variable<String>(sessionId);
    map['assignment_id'] = Variable<String>(assignmentId);
    map['text_value'] = Variable<String>(textValue);
    map['updated_at_micros'] = Variable<int>(updatedAtMicros);
    if (!nullToAbsent || lastCommandId != null) {
      map['last_command_id'] = Variable<String>(lastCommandId);
    }
    if (!nullToAbsent || deletedAtMicros != null) {
      map['deleted_at_micros'] = Variable<int>(deletedAtMicros);
    }
    return map;
  }

  AssignmentNoteRecordsCompanion toCompanion(bool nullToAbsent) {
    return AssignmentNoteRecordsCompanion(
      sessionId: Value(sessionId),
      assignmentId: Value(assignmentId),
      textValue: Value(textValue),
      updatedAtMicros: Value(updatedAtMicros),
      lastCommandId: lastCommandId == null && nullToAbsent
          ? const Value.absent()
          : Value(lastCommandId),
      deletedAtMicros: deletedAtMicros == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAtMicros),
    );
  }

  factory AssignmentNoteRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AssignmentNoteRow(
      sessionId: serializer.fromJson<String>(json['sessionId']),
      assignmentId: serializer.fromJson<String>(json['assignmentId']),
      textValue: serializer.fromJson<String>(json['textValue']),
      updatedAtMicros: serializer.fromJson<int>(json['updatedAtMicros']),
      lastCommandId: serializer.fromJson<String?>(json['lastCommandId']),
      deletedAtMicros: serializer.fromJson<int?>(json['deletedAtMicros']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sessionId': serializer.toJson<String>(sessionId),
      'assignmentId': serializer.toJson<String>(assignmentId),
      'textValue': serializer.toJson<String>(textValue),
      'updatedAtMicros': serializer.toJson<int>(updatedAtMicros),
      'lastCommandId': serializer.toJson<String?>(lastCommandId),
      'deletedAtMicros': serializer.toJson<int?>(deletedAtMicros),
    };
  }

  AssignmentNoteRow copyWith({
    String? sessionId,
    String? assignmentId,
    String? textValue,
    int? updatedAtMicros,
    Value<String?> lastCommandId = const Value.absent(),
    Value<int?> deletedAtMicros = const Value.absent(),
  }) => AssignmentNoteRow(
    sessionId: sessionId ?? this.sessionId,
    assignmentId: assignmentId ?? this.assignmentId,
    textValue: textValue ?? this.textValue,
    updatedAtMicros: updatedAtMicros ?? this.updatedAtMicros,
    lastCommandId: lastCommandId.present
        ? lastCommandId.value
        : this.lastCommandId,
    deletedAtMicros: deletedAtMicros.present
        ? deletedAtMicros.value
        : this.deletedAtMicros,
  );
  AssignmentNoteRow copyWithCompanion(AssignmentNoteRecordsCompanion data) {
    return AssignmentNoteRow(
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      assignmentId: data.assignmentId.present
          ? data.assignmentId.value
          : this.assignmentId,
      textValue: data.textValue.present ? data.textValue.value : this.textValue,
      updatedAtMicros: data.updatedAtMicros.present
          ? data.updatedAtMicros.value
          : this.updatedAtMicros,
      lastCommandId: data.lastCommandId.present
          ? data.lastCommandId.value
          : this.lastCommandId,
      deletedAtMicros: data.deletedAtMicros.present
          ? data.deletedAtMicros.value
          : this.deletedAtMicros,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AssignmentNoteRow(')
          ..write('sessionId: $sessionId, ')
          ..write('assignmentId: $assignmentId, ')
          ..write('textValue: $textValue, ')
          ..write('updatedAtMicros: $updatedAtMicros, ')
          ..write('lastCommandId: $lastCommandId, ')
          ..write('deletedAtMicros: $deletedAtMicros')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    sessionId,
    assignmentId,
    textValue,
    updatedAtMicros,
    lastCommandId,
    deletedAtMicros,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AssignmentNoteRow &&
          other.sessionId == this.sessionId &&
          other.assignmentId == this.assignmentId &&
          other.textValue == this.textValue &&
          other.updatedAtMicros == this.updatedAtMicros &&
          other.lastCommandId == this.lastCommandId &&
          other.deletedAtMicros == this.deletedAtMicros);
}

class AssignmentNoteRecordsCompanion
    extends UpdateCompanion<AssignmentNoteRow> {
  final Value<String> sessionId;
  final Value<String> assignmentId;
  final Value<String> textValue;
  final Value<int> updatedAtMicros;
  final Value<String?> lastCommandId;
  final Value<int?> deletedAtMicros;
  final Value<int> rowid;
  const AssignmentNoteRecordsCompanion({
    this.sessionId = const Value.absent(),
    this.assignmentId = const Value.absent(),
    this.textValue = const Value.absent(),
    this.updatedAtMicros = const Value.absent(),
    this.lastCommandId = const Value.absent(),
    this.deletedAtMicros = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AssignmentNoteRecordsCompanion.insert({
    required String sessionId,
    required String assignmentId,
    required String textValue,
    required int updatedAtMicros,
    this.lastCommandId = const Value.absent(),
    this.deletedAtMicros = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : sessionId = Value(sessionId),
       assignmentId = Value(assignmentId),
       textValue = Value(textValue),
       updatedAtMicros = Value(updatedAtMicros);
  static Insertable<AssignmentNoteRow> custom({
    Expression<String>? sessionId,
    Expression<String>? assignmentId,
    Expression<String>? textValue,
    Expression<int>? updatedAtMicros,
    Expression<String>? lastCommandId,
    Expression<int>? deletedAtMicros,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sessionId != null) 'session_id': sessionId,
      if (assignmentId != null) 'assignment_id': assignmentId,
      if (textValue != null) 'text_value': textValue,
      if (updatedAtMicros != null) 'updated_at_micros': updatedAtMicros,
      if (lastCommandId != null) 'last_command_id': lastCommandId,
      if (deletedAtMicros != null) 'deleted_at_micros': deletedAtMicros,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AssignmentNoteRecordsCompanion copyWith({
    Value<String>? sessionId,
    Value<String>? assignmentId,
    Value<String>? textValue,
    Value<int>? updatedAtMicros,
    Value<String?>? lastCommandId,
    Value<int?>? deletedAtMicros,
    Value<int>? rowid,
  }) {
    return AssignmentNoteRecordsCompanion(
      sessionId: sessionId ?? this.sessionId,
      assignmentId: assignmentId ?? this.assignmentId,
      textValue: textValue ?? this.textValue,
      updatedAtMicros: updatedAtMicros ?? this.updatedAtMicros,
      lastCommandId: lastCommandId ?? this.lastCommandId,
      deletedAtMicros: deletedAtMicros ?? this.deletedAtMicros,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (assignmentId.present) {
      map['assignment_id'] = Variable<String>(assignmentId.value);
    }
    if (textValue.present) {
      map['text_value'] = Variable<String>(textValue.value);
    }
    if (updatedAtMicros.present) {
      map['updated_at_micros'] = Variable<int>(updatedAtMicros.value);
    }
    if (lastCommandId.present) {
      map['last_command_id'] = Variable<String>(lastCommandId.value);
    }
    if (deletedAtMicros.present) {
      map['deleted_at_micros'] = Variable<int>(deletedAtMicros.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssignmentNoteRecordsCompanion(')
          ..write('sessionId: $sessionId, ')
          ..write('assignmentId: $assignmentId, ')
          ..write('textValue: $textValue, ')
          ..write('updatedAtMicros: $updatedAtMicros, ')
          ..write('lastCommandId: $lastCommandId, ')
          ..write('deletedAtMicros: $deletedAtMicros, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CartConsumableRecordsTable extends CartConsumableRecords
    with TableInfo<$CartConsumableRecordsTable, CartConsumableRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CartConsumableRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES work_session_records (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _assignmentIdMeta = const VerificationMeta(
    'assignmentId',
  );
  @override
  late final GeneratedColumn<String> assignmentId = GeneratedColumn<String>(
    'assignment_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMicrosMeta = const VerificationMeta(
    'updatedAtMicros',
  );
  @override
  late final GeneratedColumn<int> updatedAtMicros = GeneratedColumn<int>(
    'updated_at_micros',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastCommandIdMeta = const VerificationMeta(
    'lastCommandId',
  );
  @override
  late final GeneratedColumn<String> lastCommandId = GeneratedColumn<String>(
    'last_command_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMicrosMeta = const VerificationMeta(
    'completedAtMicros',
  );
  @override
  late final GeneratedColumn<int> completedAtMicros = GeneratedColumn<int>(
    'completed_at_micros',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMicrosMeta = const VerificationMeta(
    'deletedAtMicros',
  );
  @override
  late final GeneratedColumn<int> deletedAtMicros = GeneratedColumn<int>(
    'deleted_at_micros',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    sessionId,
    assignmentId,
    itemId,
    title,
    quantity,
    updatedAtMicros,
    lastCommandId,
    completedAtMicros,
    deletedAtMicros,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cart_consumable_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<CartConsumableRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('assignment_id')) {
      context.handle(
        _assignmentIdMeta,
        assignmentId.isAcceptableOrUnknown(
          data['assignment_id']!,
          _assignmentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_assignmentIdMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('updated_at_micros')) {
      context.handle(
        _updatedAtMicrosMeta,
        updatedAtMicros.isAcceptableOrUnknown(
          data['updated_at_micros']!,
          _updatedAtMicrosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMicrosMeta);
    }
    if (data.containsKey('last_command_id')) {
      context.handle(
        _lastCommandIdMeta,
        lastCommandId.isAcceptableOrUnknown(
          data['last_command_id']!,
          _lastCommandIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastCommandIdMeta);
    }
    if (data.containsKey('completed_at_micros')) {
      context.handle(
        _completedAtMicrosMeta,
        completedAtMicros.isAcceptableOrUnknown(
          data['completed_at_micros']!,
          _completedAtMicrosMeta,
        ),
      );
    }
    if (data.containsKey('deleted_at_micros')) {
      context.handle(
        _deletedAtMicrosMeta,
        deletedAtMicros.isAcceptableOrUnknown(
          data['deleted_at_micros']!,
          _deletedAtMicrosMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sessionId, assignmentId, itemId};
  @override
  CartConsumableRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CartConsumableRow(
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      assignmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assignment_id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      updatedAtMicros: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_micros'],
      )!,
      lastCommandId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_command_id'],
      )!,
      completedAtMicros: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_at_micros'],
      ),
      deletedAtMicros: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at_micros'],
      ),
    );
  }

  @override
  $CartConsumableRecordsTable createAlias(String alias) {
    return $CartConsumableRecordsTable(attachedDatabase, alias);
  }
}

class CartConsumableRow extends DataClass
    implements Insertable<CartConsumableRow> {
  final String sessionId;
  final String assignmentId;
  final String itemId;
  final String title;
  final int quantity;
  final int updatedAtMicros;
  final String lastCommandId;
  final int? completedAtMicros;
  final int? deletedAtMicros;
  const CartConsumableRow({
    required this.sessionId,
    required this.assignmentId,
    required this.itemId,
    required this.title,
    required this.quantity,
    required this.updatedAtMicros,
    required this.lastCommandId,
    this.completedAtMicros,
    this.deletedAtMicros,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['session_id'] = Variable<String>(sessionId);
    map['assignment_id'] = Variable<String>(assignmentId);
    map['item_id'] = Variable<String>(itemId);
    map['title'] = Variable<String>(title);
    map['quantity'] = Variable<int>(quantity);
    map['updated_at_micros'] = Variable<int>(updatedAtMicros);
    map['last_command_id'] = Variable<String>(lastCommandId);
    if (!nullToAbsent || completedAtMicros != null) {
      map['completed_at_micros'] = Variable<int>(completedAtMicros);
    }
    if (!nullToAbsent || deletedAtMicros != null) {
      map['deleted_at_micros'] = Variable<int>(deletedAtMicros);
    }
    return map;
  }

  CartConsumableRecordsCompanion toCompanion(bool nullToAbsent) {
    return CartConsumableRecordsCompanion(
      sessionId: Value(sessionId),
      assignmentId: Value(assignmentId),
      itemId: Value(itemId),
      title: Value(title),
      quantity: Value(quantity),
      updatedAtMicros: Value(updatedAtMicros),
      lastCommandId: Value(lastCommandId),
      completedAtMicros: completedAtMicros == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAtMicros),
      deletedAtMicros: deletedAtMicros == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAtMicros),
    );
  }

  factory CartConsumableRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CartConsumableRow(
      sessionId: serializer.fromJson<String>(json['sessionId']),
      assignmentId: serializer.fromJson<String>(json['assignmentId']),
      itemId: serializer.fromJson<String>(json['itemId']),
      title: serializer.fromJson<String>(json['title']),
      quantity: serializer.fromJson<int>(json['quantity']),
      updatedAtMicros: serializer.fromJson<int>(json['updatedAtMicros']),
      lastCommandId: serializer.fromJson<String>(json['lastCommandId']),
      completedAtMicros: serializer.fromJson<int?>(json['completedAtMicros']),
      deletedAtMicros: serializer.fromJson<int?>(json['deletedAtMicros']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sessionId': serializer.toJson<String>(sessionId),
      'assignmentId': serializer.toJson<String>(assignmentId),
      'itemId': serializer.toJson<String>(itemId),
      'title': serializer.toJson<String>(title),
      'quantity': serializer.toJson<int>(quantity),
      'updatedAtMicros': serializer.toJson<int>(updatedAtMicros),
      'lastCommandId': serializer.toJson<String>(lastCommandId),
      'completedAtMicros': serializer.toJson<int?>(completedAtMicros),
      'deletedAtMicros': serializer.toJson<int?>(deletedAtMicros),
    };
  }

  CartConsumableRow copyWith({
    String? sessionId,
    String? assignmentId,
    String? itemId,
    String? title,
    int? quantity,
    int? updatedAtMicros,
    String? lastCommandId,
    Value<int?> completedAtMicros = const Value.absent(),
    Value<int?> deletedAtMicros = const Value.absent(),
  }) => CartConsumableRow(
    sessionId: sessionId ?? this.sessionId,
    assignmentId: assignmentId ?? this.assignmentId,
    itemId: itemId ?? this.itemId,
    title: title ?? this.title,
    quantity: quantity ?? this.quantity,
    updatedAtMicros: updatedAtMicros ?? this.updatedAtMicros,
    lastCommandId: lastCommandId ?? this.lastCommandId,
    completedAtMicros: completedAtMicros.present
        ? completedAtMicros.value
        : this.completedAtMicros,
    deletedAtMicros: deletedAtMicros.present
        ? deletedAtMicros.value
        : this.deletedAtMicros,
  );
  CartConsumableRow copyWithCompanion(CartConsumableRecordsCompanion data) {
    return CartConsumableRow(
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      assignmentId: data.assignmentId.present
          ? data.assignmentId.value
          : this.assignmentId,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      title: data.title.present ? data.title.value : this.title,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      updatedAtMicros: data.updatedAtMicros.present
          ? data.updatedAtMicros.value
          : this.updatedAtMicros,
      lastCommandId: data.lastCommandId.present
          ? data.lastCommandId.value
          : this.lastCommandId,
      completedAtMicros: data.completedAtMicros.present
          ? data.completedAtMicros.value
          : this.completedAtMicros,
      deletedAtMicros: data.deletedAtMicros.present
          ? data.deletedAtMicros.value
          : this.deletedAtMicros,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CartConsumableRow(')
          ..write('sessionId: $sessionId, ')
          ..write('assignmentId: $assignmentId, ')
          ..write('itemId: $itemId, ')
          ..write('title: $title, ')
          ..write('quantity: $quantity, ')
          ..write('updatedAtMicros: $updatedAtMicros, ')
          ..write('lastCommandId: $lastCommandId, ')
          ..write('completedAtMicros: $completedAtMicros, ')
          ..write('deletedAtMicros: $deletedAtMicros')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    sessionId,
    assignmentId,
    itemId,
    title,
    quantity,
    updatedAtMicros,
    lastCommandId,
    completedAtMicros,
    deletedAtMicros,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CartConsumableRow &&
          other.sessionId == this.sessionId &&
          other.assignmentId == this.assignmentId &&
          other.itemId == this.itemId &&
          other.title == this.title &&
          other.quantity == this.quantity &&
          other.updatedAtMicros == this.updatedAtMicros &&
          other.lastCommandId == this.lastCommandId &&
          other.completedAtMicros == this.completedAtMicros &&
          other.deletedAtMicros == this.deletedAtMicros);
}

class CartConsumableRecordsCompanion
    extends UpdateCompanion<CartConsumableRow> {
  final Value<String> sessionId;
  final Value<String> assignmentId;
  final Value<String> itemId;
  final Value<String> title;
  final Value<int> quantity;
  final Value<int> updatedAtMicros;
  final Value<String> lastCommandId;
  final Value<int?> completedAtMicros;
  final Value<int?> deletedAtMicros;
  final Value<int> rowid;
  const CartConsumableRecordsCompanion({
    this.sessionId = const Value.absent(),
    this.assignmentId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.title = const Value.absent(),
    this.quantity = const Value.absent(),
    this.updatedAtMicros = const Value.absent(),
    this.lastCommandId = const Value.absent(),
    this.completedAtMicros = const Value.absent(),
    this.deletedAtMicros = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CartConsumableRecordsCompanion.insert({
    required String sessionId,
    required String assignmentId,
    required String itemId,
    required String title,
    required int quantity,
    required int updatedAtMicros,
    required String lastCommandId,
    this.completedAtMicros = const Value.absent(),
    this.deletedAtMicros = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : sessionId = Value(sessionId),
       assignmentId = Value(assignmentId),
       itemId = Value(itemId),
       title = Value(title),
       quantity = Value(quantity),
       updatedAtMicros = Value(updatedAtMicros),
       lastCommandId = Value(lastCommandId);
  static Insertable<CartConsumableRow> custom({
    Expression<String>? sessionId,
    Expression<String>? assignmentId,
    Expression<String>? itemId,
    Expression<String>? title,
    Expression<int>? quantity,
    Expression<int>? updatedAtMicros,
    Expression<String>? lastCommandId,
    Expression<int>? completedAtMicros,
    Expression<int>? deletedAtMicros,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sessionId != null) 'session_id': sessionId,
      if (assignmentId != null) 'assignment_id': assignmentId,
      if (itemId != null) 'item_id': itemId,
      if (title != null) 'title': title,
      if (quantity != null) 'quantity': quantity,
      if (updatedAtMicros != null) 'updated_at_micros': updatedAtMicros,
      if (lastCommandId != null) 'last_command_id': lastCommandId,
      if (completedAtMicros != null) 'completed_at_micros': completedAtMicros,
      if (deletedAtMicros != null) 'deleted_at_micros': deletedAtMicros,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CartConsumableRecordsCompanion copyWith({
    Value<String>? sessionId,
    Value<String>? assignmentId,
    Value<String>? itemId,
    Value<String>? title,
    Value<int>? quantity,
    Value<int>? updatedAtMicros,
    Value<String>? lastCommandId,
    Value<int?>? completedAtMicros,
    Value<int?>? deletedAtMicros,
    Value<int>? rowid,
  }) {
    return CartConsumableRecordsCompanion(
      sessionId: sessionId ?? this.sessionId,
      assignmentId: assignmentId ?? this.assignmentId,
      itemId: itemId ?? this.itemId,
      title: title ?? this.title,
      quantity: quantity ?? this.quantity,
      updatedAtMicros: updatedAtMicros ?? this.updatedAtMicros,
      lastCommandId: lastCommandId ?? this.lastCommandId,
      completedAtMicros: completedAtMicros ?? this.completedAtMicros,
      deletedAtMicros: deletedAtMicros ?? this.deletedAtMicros,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (assignmentId.present) {
      map['assignment_id'] = Variable<String>(assignmentId.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (updatedAtMicros.present) {
      map['updated_at_micros'] = Variable<int>(updatedAtMicros.value);
    }
    if (lastCommandId.present) {
      map['last_command_id'] = Variable<String>(lastCommandId.value);
    }
    if (completedAtMicros.present) {
      map['completed_at_micros'] = Variable<int>(completedAtMicros.value);
    }
    if (deletedAtMicros.present) {
      map['deleted_at_micros'] = Variable<int>(deletedAtMicros.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CartConsumableRecordsCompanion(')
          ..write('sessionId: $sessionId, ')
          ..write('assignmentId: $assignmentId, ')
          ..write('itemId: $itemId, ')
          ..write('title: $title, ')
          ..write('quantity: $quantity, ')
          ..write('updatedAtMicros: $updatedAtMicros, ')
          ..write('lastCommandId: $lastCommandId, ')
          ..write('completedAtMicros: $completedAtMicros, ')
          ..write('deletedAtMicros: $deletedAtMicros, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HistoryEventRecordsTable extends HistoryEventRecords
    with TableInfo<$HistoryEventRecordsTable, HistoryEventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HistoryEventRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES work_session_records (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _commandIdMeta = const VerificationMeta(
    'commandId',
  );
  @override
  late final GeneratedColumn<String> commandId = GeneratedColumn<String>(
    'command_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventTypeMeta = const VerificationMeta(
    'eventType',
  );
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
    'event_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventVersionMeta = const VerificationMeta(
    'eventVersion',
  );
  @override
  late final GeneratedColumn<int> eventVersion = GeneratedColumn<int>(
    'event_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
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
  static const VerificationMeta _happenedAtMeta = const VerificationMeta(
    'happenedAt',
  );
  @override
  late final GeneratedColumn<DateTime> happenedAt = GeneratedColumn<DateTime>(
    'happened_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    commandId,
    eventType,
    eventVersion,
    payloadJson,
    happenedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'history_event_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<HistoryEventRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('command_id')) {
      context.handle(
        _commandIdMeta,
        commandId.isAcceptableOrUnknown(data['command_id']!, _commandIdMeta),
      );
    } else if (isInserting) {
      context.missing(_commandIdMeta);
    }
    if (data.containsKey('event_type')) {
      context.handle(
        _eventTypeMeta,
        eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('event_version')) {
      context.handle(
        _eventVersionMeta,
        eventVersion.isAcceptableOrUnknown(
          data['event_version']!,
          _eventVersionMeta,
        ),
      );
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
    if (data.containsKey('happened_at')) {
      context.handle(
        _happenedAtMeta,
        happenedAt.isAcceptableOrUnknown(data['happened_at']!, _happenedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_happenedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HistoryEventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HistoryEventRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      commandId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}command_id'],
      )!,
      eventType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_type'],
      )!,
      eventVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}event_version'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      happenedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}happened_at'],
      )!,
    );
  }

  @override
  $HistoryEventRecordsTable createAlias(String alias) {
    return $HistoryEventRecordsTable(attachedDatabase, alias);
  }
}

class HistoryEventRow extends DataClass implements Insertable<HistoryEventRow> {
  final String id;
  final String sessionId;
  final String commandId;
  final String eventType;
  final int eventVersion;
  final String payloadJson;
  final DateTime happenedAt;
  const HistoryEventRow({
    required this.id,
    required this.sessionId,
    required this.commandId,
    required this.eventType,
    required this.eventVersion,
    required this.payloadJson,
    required this.happenedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['command_id'] = Variable<String>(commandId);
    map['event_type'] = Variable<String>(eventType);
    map['event_version'] = Variable<int>(eventVersion);
    map['payload_json'] = Variable<String>(payloadJson);
    map['happened_at'] = Variable<DateTime>(happenedAt);
    return map;
  }

  HistoryEventRecordsCompanion toCompanion(bool nullToAbsent) {
    return HistoryEventRecordsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      commandId: Value(commandId),
      eventType: Value(eventType),
      eventVersion: Value(eventVersion),
      payloadJson: Value(payloadJson),
      happenedAt: Value(happenedAt),
    );
  }

  factory HistoryEventRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HistoryEventRow(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      commandId: serializer.fromJson<String>(json['commandId']),
      eventType: serializer.fromJson<String>(json['eventType']),
      eventVersion: serializer.fromJson<int>(json['eventVersion']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      happenedAt: serializer.fromJson<DateTime>(json['happenedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'commandId': serializer.toJson<String>(commandId),
      'eventType': serializer.toJson<String>(eventType),
      'eventVersion': serializer.toJson<int>(eventVersion),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'happenedAt': serializer.toJson<DateTime>(happenedAt),
    };
  }

  HistoryEventRow copyWith({
    String? id,
    String? sessionId,
    String? commandId,
    String? eventType,
    int? eventVersion,
    String? payloadJson,
    DateTime? happenedAt,
  }) => HistoryEventRow(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    commandId: commandId ?? this.commandId,
    eventType: eventType ?? this.eventType,
    eventVersion: eventVersion ?? this.eventVersion,
    payloadJson: payloadJson ?? this.payloadJson,
    happenedAt: happenedAt ?? this.happenedAt,
  );
  HistoryEventRow copyWithCompanion(HistoryEventRecordsCompanion data) {
    return HistoryEventRow(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      commandId: data.commandId.present ? data.commandId.value : this.commandId,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      eventVersion: data.eventVersion.present
          ? data.eventVersion.value
          : this.eventVersion,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      happenedAt: data.happenedAt.present
          ? data.happenedAt.value
          : this.happenedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HistoryEventRow(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('commandId: $commandId, ')
          ..write('eventType: $eventType, ')
          ..write('eventVersion: $eventVersion, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('happenedAt: $happenedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    commandId,
    eventType,
    eventVersion,
    payloadJson,
    happenedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HistoryEventRow &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.commandId == this.commandId &&
          other.eventType == this.eventType &&
          other.eventVersion == this.eventVersion &&
          other.payloadJson == this.payloadJson &&
          other.happenedAt == this.happenedAt);
}

class HistoryEventRecordsCompanion extends UpdateCompanion<HistoryEventRow> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<String> commandId;
  final Value<String> eventType;
  final Value<int> eventVersion;
  final Value<String> payloadJson;
  final Value<DateTime> happenedAt;
  final Value<int> rowid;
  const HistoryEventRecordsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.commandId = const Value.absent(),
    this.eventType = const Value.absent(),
    this.eventVersion = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.happenedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HistoryEventRecordsCompanion.insert({
    required String id,
    required String sessionId,
    required String commandId,
    required String eventType,
    this.eventVersion = const Value.absent(),
    required String payloadJson,
    required DateTime happenedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId),
       commandId = Value(commandId),
       eventType = Value(eventType),
       payloadJson = Value(payloadJson),
       happenedAt = Value(happenedAt);
  static Insertable<HistoryEventRow> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<String>? commandId,
    Expression<String>? eventType,
    Expression<int>? eventVersion,
    Expression<String>? payloadJson,
    Expression<DateTime>? happenedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (commandId != null) 'command_id': commandId,
      if (eventType != null) 'event_type': eventType,
      if (eventVersion != null) 'event_version': eventVersion,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (happenedAt != null) 'happened_at': happenedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HistoryEventRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionId,
    Value<String>? commandId,
    Value<String>? eventType,
    Value<int>? eventVersion,
    Value<String>? payloadJson,
    Value<DateTime>? happenedAt,
    Value<int>? rowid,
  }) {
    return HistoryEventRecordsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      commandId: commandId ?? this.commandId,
      eventType: eventType ?? this.eventType,
      eventVersion: eventVersion ?? this.eventVersion,
      payloadJson: payloadJson ?? this.payloadJson,
      happenedAt: happenedAt ?? this.happenedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (commandId.present) {
      map['command_id'] = Variable<String>(commandId.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (eventVersion.present) {
      map['event_version'] = Variable<int>(eventVersion.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (happenedAt.present) {
      map['happened_at'] = Variable<DateTime>(happenedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HistoryEventRecordsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('commandId: $commandId, ')
          ..write('eventType: $eventType, ')
          ..write('eventVersion: $eventVersion, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('happenedAt: $happenedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CommandReceiptRecordsTable extends CommandReceiptRecords
    with TableInfo<$CommandReceiptRecordsTable, CommandReceiptRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CommandReceiptRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES work_session_records (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _commandIdMeta = const VerificationMeta(
    'commandId',
  );
  @override
  late final GeneratedColumn<String> commandId = GeneratedColumn<String>(
    'command_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _commandVersionMeta = const VerificationMeta(
    'commandVersion',
  );
  @override
  late final GeneratedColumn<int> commandVersion = GeneratedColumn<int>(
    'command_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _commandTypeMeta = const VerificationMeta(
    'commandType',
  );
  @override
  late final GeneratedColumn<String> commandType = GeneratedColumn<String>(
    'command_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _commandFingerprintMeta =
      const VerificationMeta('commandFingerprint');
  @override
  late final GeneratedColumn<String> commandFingerprint =
      GeneratedColumn<String>(
        'command_fingerprint',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _issuedAtMicrosMeta = const VerificationMeta(
    'issuedAtMicros',
  );
  @override
  late final GeneratedColumn<int> issuedAtMicros = GeneratedColumn<int>(
    'issued_at_micros',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _outcomeMeta = const VerificationMeta(
    'outcome',
  );
  @override
  late final GeneratedColumn<String> outcome = GeneratedColumn<String>(
    'outcome',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _processedAtMeta = const VerificationMeta(
    'processedAt',
  );
  @override
  late final GeneratedColumn<DateTime> processedAt = GeneratedColumn<DateTime>(
    'processed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    sessionId,
    commandId,
    commandVersion,
    commandType,
    commandFingerprint,
    issuedAtMicros,
    outcome,
    processedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'command_receipt_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<CommandReceiptRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('command_id')) {
      context.handle(
        _commandIdMeta,
        commandId.isAcceptableOrUnknown(data['command_id']!, _commandIdMeta),
      );
    } else if (isInserting) {
      context.missing(_commandIdMeta);
    }
    if (data.containsKey('command_version')) {
      context.handle(
        _commandVersionMeta,
        commandVersion.isAcceptableOrUnknown(
          data['command_version']!,
          _commandVersionMeta,
        ),
      );
    }
    if (data.containsKey('command_type')) {
      context.handle(
        _commandTypeMeta,
        commandType.isAcceptableOrUnknown(
          data['command_type']!,
          _commandTypeMeta,
        ),
      );
    }
    if (data.containsKey('command_fingerprint')) {
      context.handle(
        _commandFingerprintMeta,
        commandFingerprint.isAcceptableOrUnknown(
          data['command_fingerprint']!,
          _commandFingerprintMeta,
        ),
      );
    }
    if (data.containsKey('issued_at_micros')) {
      context.handle(
        _issuedAtMicrosMeta,
        issuedAtMicros.isAcceptableOrUnknown(
          data['issued_at_micros']!,
          _issuedAtMicrosMeta,
        ),
      );
    }
    if (data.containsKey('outcome')) {
      context.handle(
        _outcomeMeta,
        outcome.isAcceptableOrUnknown(data['outcome']!, _outcomeMeta),
      );
    } else if (isInserting) {
      context.missing(_outcomeMeta);
    }
    if (data.containsKey('processed_at')) {
      context.handle(
        _processedAtMeta,
        processedAt.isAcceptableOrUnknown(
          data['processed_at']!,
          _processedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_processedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sessionId, commandId};
  @override
  CommandReceiptRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CommandReceiptRow(
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      commandId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}command_id'],
      )!,
      commandVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}command_version'],
      )!,
      commandType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}command_type'],
      ),
      commandFingerprint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}command_fingerprint'],
      ),
      issuedAtMicros: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}issued_at_micros'],
      ),
      outcome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}outcome'],
      )!,
      processedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}processed_at'],
      )!,
    );
  }

  @override
  $CommandReceiptRecordsTable createAlias(String alias) {
    return $CommandReceiptRecordsTable(attachedDatabase, alias);
  }
}

class CommandReceiptRow extends DataClass
    implements Insertable<CommandReceiptRow> {
  final String sessionId;
  final String commandId;
  final int commandVersion;
  final String? commandType;
  final String? commandFingerprint;
  final int? issuedAtMicros;
  final String outcome;
  final DateTime processedAt;
  const CommandReceiptRow({
    required this.sessionId,
    required this.commandId,
    required this.commandVersion,
    this.commandType,
    this.commandFingerprint,
    this.issuedAtMicros,
    required this.outcome,
    required this.processedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['session_id'] = Variable<String>(sessionId);
    map['command_id'] = Variable<String>(commandId);
    map['command_version'] = Variable<int>(commandVersion);
    if (!nullToAbsent || commandType != null) {
      map['command_type'] = Variable<String>(commandType);
    }
    if (!nullToAbsent || commandFingerprint != null) {
      map['command_fingerprint'] = Variable<String>(commandFingerprint);
    }
    if (!nullToAbsent || issuedAtMicros != null) {
      map['issued_at_micros'] = Variable<int>(issuedAtMicros);
    }
    map['outcome'] = Variable<String>(outcome);
    map['processed_at'] = Variable<DateTime>(processedAt);
    return map;
  }

  CommandReceiptRecordsCompanion toCompanion(bool nullToAbsent) {
    return CommandReceiptRecordsCompanion(
      sessionId: Value(sessionId),
      commandId: Value(commandId),
      commandVersion: Value(commandVersion),
      commandType: commandType == null && nullToAbsent
          ? const Value.absent()
          : Value(commandType),
      commandFingerprint: commandFingerprint == null && nullToAbsent
          ? const Value.absent()
          : Value(commandFingerprint),
      issuedAtMicros: issuedAtMicros == null && nullToAbsent
          ? const Value.absent()
          : Value(issuedAtMicros),
      outcome: Value(outcome),
      processedAt: Value(processedAt),
    );
  }

  factory CommandReceiptRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CommandReceiptRow(
      sessionId: serializer.fromJson<String>(json['sessionId']),
      commandId: serializer.fromJson<String>(json['commandId']),
      commandVersion: serializer.fromJson<int>(json['commandVersion']),
      commandType: serializer.fromJson<String?>(json['commandType']),
      commandFingerprint: serializer.fromJson<String?>(
        json['commandFingerprint'],
      ),
      issuedAtMicros: serializer.fromJson<int?>(json['issuedAtMicros']),
      outcome: serializer.fromJson<String>(json['outcome']),
      processedAt: serializer.fromJson<DateTime>(json['processedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sessionId': serializer.toJson<String>(sessionId),
      'commandId': serializer.toJson<String>(commandId),
      'commandVersion': serializer.toJson<int>(commandVersion),
      'commandType': serializer.toJson<String?>(commandType),
      'commandFingerprint': serializer.toJson<String?>(commandFingerprint),
      'issuedAtMicros': serializer.toJson<int?>(issuedAtMicros),
      'outcome': serializer.toJson<String>(outcome),
      'processedAt': serializer.toJson<DateTime>(processedAt),
    };
  }

  CommandReceiptRow copyWith({
    String? sessionId,
    String? commandId,
    int? commandVersion,
    Value<String?> commandType = const Value.absent(),
    Value<String?> commandFingerprint = const Value.absent(),
    Value<int?> issuedAtMicros = const Value.absent(),
    String? outcome,
    DateTime? processedAt,
  }) => CommandReceiptRow(
    sessionId: sessionId ?? this.sessionId,
    commandId: commandId ?? this.commandId,
    commandVersion: commandVersion ?? this.commandVersion,
    commandType: commandType.present ? commandType.value : this.commandType,
    commandFingerprint: commandFingerprint.present
        ? commandFingerprint.value
        : this.commandFingerprint,
    issuedAtMicros: issuedAtMicros.present
        ? issuedAtMicros.value
        : this.issuedAtMicros,
    outcome: outcome ?? this.outcome,
    processedAt: processedAt ?? this.processedAt,
  );
  CommandReceiptRow copyWithCompanion(CommandReceiptRecordsCompanion data) {
    return CommandReceiptRow(
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      commandId: data.commandId.present ? data.commandId.value : this.commandId,
      commandVersion: data.commandVersion.present
          ? data.commandVersion.value
          : this.commandVersion,
      commandType: data.commandType.present
          ? data.commandType.value
          : this.commandType,
      commandFingerprint: data.commandFingerprint.present
          ? data.commandFingerprint.value
          : this.commandFingerprint,
      issuedAtMicros: data.issuedAtMicros.present
          ? data.issuedAtMicros.value
          : this.issuedAtMicros,
      outcome: data.outcome.present ? data.outcome.value : this.outcome,
      processedAt: data.processedAt.present
          ? data.processedAt.value
          : this.processedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CommandReceiptRow(')
          ..write('sessionId: $sessionId, ')
          ..write('commandId: $commandId, ')
          ..write('commandVersion: $commandVersion, ')
          ..write('commandType: $commandType, ')
          ..write('commandFingerprint: $commandFingerprint, ')
          ..write('issuedAtMicros: $issuedAtMicros, ')
          ..write('outcome: $outcome, ')
          ..write('processedAt: $processedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    sessionId,
    commandId,
    commandVersion,
    commandType,
    commandFingerprint,
    issuedAtMicros,
    outcome,
    processedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CommandReceiptRow &&
          other.sessionId == this.sessionId &&
          other.commandId == this.commandId &&
          other.commandVersion == this.commandVersion &&
          other.commandType == this.commandType &&
          other.commandFingerprint == this.commandFingerprint &&
          other.issuedAtMicros == this.issuedAtMicros &&
          other.outcome == this.outcome &&
          other.processedAt == this.processedAt);
}

class CommandReceiptRecordsCompanion
    extends UpdateCompanion<CommandReceiptRow> {
  final Value<String> sessionId;
  final Value<String> commandId;
  final Value<int> commandVersion;
  final Value<String?> commandType;
  final Value<String?> commandFingerprint;
  final Value<int?> issuedAtMicros;
  final Value<String> outcome;
  final Value<DateTime> processedAt;
  final Value<int> rowid;
  const CommandReceiptRecordsCompanion({
    this.sessionId = const Value.absent(),
    this.commandId = const Value.absent(),
    this.commandVersion = const Value.absent(),
    this.commandType = const Value.absent(),
    this.commandFingerprint = const Value.absent(),
    this.issuedAtMicros = const Value.absent(),
    this.outcome = const Value.absent(),
    this.processedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CommandReceiptRecordsCompanion.insert({
    required String sessionId,
    required String commandId,
    this.commandVersion = const Value.absent(),
    this.commandType = const Value.absent(),
    this.commandFingerprint = const Value.absent(),
    this.issuedAtMicros = const Value.absent(),
    required String outcome,
    required DateTime processedAt,
    this.rowid = const Value.absent(),
  }) : sessionId = Value(sessionId),
       commandId = Value(commandId),
       outcome = Value(outcome),
       processedAt = Value(processedAt);
  static Insertable<CommandReceiptRow> custom({
    Expression<String>? sessionId,
    Expression<String>? commandId,
    Expression<int>? commandVersion,
    Expression<String>? commandType,
    Expression<String>? commandFingerprint,
    Expression<int>? issuedAtMicros,
    Expression<String>? outcome,
    Expression<DateTime>? processedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sessionId != null) 'session_id': sessionId,
      if (commandId != null) 'command_id': commandId,
      if (commandVersion != null) 'command_version': commandVersion,
      if (commandType != null) 'command_type': commandType,
      if (commandFingerprint != null) 'command_fingerprint': commandFingerprint,
      if (issuedAtMicros != null) 'issued_at_micros': issuedAtMicros,
      if (outcome != null) 'outcome': outcome,
      if (processedAt != null) 'processed_at': processedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CommandReceiptRecordsCompanion copyWith({
    Value<String>? sessionId,
    Value<String>? commandId,
    Value<int>? commandVersion,
    Value<String?>? commandType,
    Value<String?>? commandFingerprint,
    Value<int?>? issuedAtMicros,
    Value<String>? outcome,
    Value<DateTime>? processedAt,
    Value<int>? rowid,
  }) {
    return CommandReceiptRecordsCompanion(
      sessionId: sessionId ?? this.sessionId,
      commandId: commandId ?? this.commandId,
      commandVersion: commandVersion ?? this.commandVersion,
      commandType: commandType ?? this.commandType,
      commandFingerprint: commandFingerprint ?? this.commandFingerprint,
      issuedAtMicros: issuedAtMicros ?? this.issuedAtMicros,
      outcome: outcome ?? this.outcome,
      processedAt: processedAt ?? this.processedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (commandId.present) {
      map['command_id'] = Variable<String>(commandId.value);
    }
    if (commandVersion.present) {
      map['command_version'] = Variable<int>(commandVersion.value);
    }
    if (commandType.present) {
      map['command_type'] = Variable<String>(commandType.value);
    }
    if (commandFingerprint.present) {
      map['command_fingerprint'] = Variable<String>(commandFingerprint.value);
    }
    if (issuedAtMicros.present) {
      map['issued_at_micros'] = Variable<int>(issuedAtMicros.value);
    }
    if (outcome.present) {
      map['outcome'] = Variable<String>(outcome.value);
    }
    if (processedAt.present) {
      map['processed_at'] = Variable<DateTime>(processedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CommandReceiptRecordsCompanion(')
          ..write('sessionId: $sessionId, ')
          ..write('commandId: $commandId, ')
          ..write('commandVersion: $commandVersion, ')
          ..write('commandType: $commandType, ')
          ..write('commandFingerprint: $commandFingerprint, ')
          ..write('issuedAtMicros: $issuedAtMicros, ')
          ..write('outcome: $outcome, ')
          ..write('processedAt: $processedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncOutboxRecordsTable extends SyncOutboxRecords
    with TableInfo<$SyncOutboxRecordsTable, SyncOutboxRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncOutboxRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
    'event_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES work_session_records (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _attemptCountMeta = const VerificationMeta(
    'attemptCount',
  );
  @override
  late final GeneratedColumn<int> attemptCount = GeneratedColumn<int>(
    'attempt_count',
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
  static const VerificationMeta _acknowledgedAtMeta = const VerificationMeta(
    'acknowledgedAt',
  );
  @override
  late final GeneratedColumn<DateTime> acknowledgedAt =
      GeneratedColumn<DateTime>(
        'acknowledged_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    eventId,
    sessionId,
    attemptCount,
    nextAttemptAt,
    acknowledgedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_outbox_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncOutboxRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
      );
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('attempt_count')) {
      context.handle(
        _attemptCountMeta,
        attemptCount.isAcceptableOrUnknown(
          data['attempt_count']!,
          _attemptCountMeta,
        ),
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
    if (data.containsKey('acknowledged_at')) {
      context.handle(
        _acknowledgedAtMeta,
        acknowledgedAt.isAcceptableOrUnknown(
          data['acknowledged_at']!,
          _acknowledgedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {eventId};
  @override
  SyncOutboxRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncOutboxRow(
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      attemptCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt_count'],
      )!,
      nextAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_attempt_at'],
      ),
      acknowledgedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}acknowledged_at'],
      ),
    );
  }

  @override
  $SyncOutboxRecordsTable createAlias(String alias) {
    return $SyncOutboxRecordsTable(attachedDatabase, alias);
  }
}

class SyncOutboxRow extends DataClass implements Insertable<SyncOutboxRow> {
  final String eventId;
  final String sessionId;
  final int attemptCount;
  final DateTime? nextAttemptAt;
  final DateTime? acknowledgedAt;
  const SyncOutboxRow({
    required this.eventId,
    required this.sessionId,
    required this.attemptCount,
    this.nextAttemptAt,
    this.acknowledgedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['event_id'] = Variable<String>(eventId);
    map['session_id'] = Variable<String>(sessionId);
    map['attempt_count'] = Variable<int>(attemptCount);
    if (!nullToAbsent || nextAttemptAt != null) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt);
    }
    if (!nullToAbsent || acknowledgedAt != null) {
      map['acknowledged_at'] = Variable<DateTime>(acknowledgedAt);
    }
    return map;
  }

  SyncOutboxRecordsCompanion toCompanion(bool nullToAbsent) {
    return SyncOutboxRecordsCompanion(
      eventId: Value(eventId),
      sessionId: Value(sessionId),
      attemptCount: Value(attemptCount),
      nextAttemptAt: nextAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextAttemptAt),
      acknowledgedAt: acknowledgedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(acknowledgedAt),
    );
  }

  factory SyncOutboxRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncOutboxRow(
      eventId: serializer.fromJson<String>(json['eventId']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      attemptCount: serializer.fromJson<int>(json['attemptCount']),
      nextAttemptAt: serializer.fromJson<DateTime?>(json['nextAttemptAt']),
      acknowledgedAt: serializer.fromJson<DateTime?>(json['acknowledgedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'eventId': serializer.toJson<String>(eventId),
      'sessionId': serializer.toJson<String>(sessionId),
      'attemptCount': serializer.toJson<int>(attemptCount),
      'nextAttemptAt': serializer.toJson<DateTime?>(nextAttemptAt),
      'acknowledgedAt': serializer.toJson<DateTime?>(acknowledgedAt),
    };
  }

  SyncOutboxRow copyWith({
    String? eventId,
    String? sessionId,
    int? attemptCount,
    Value<DateTime?> nextAttemptAt = const Value.absent(),
    Value<DateTime?> acknowledgedAt = const Value.absent(),
  }) => SyncOutboxRow(
    eventId: eventId ?? this.eventId,
    sessionId: sessionId ?? this.sessionId,
    attemptCount: attemptCount ?? this.attemptCount,
    nextAttemptAt: nextAttemptAt.present
        ? nextAttemptAt.value
        : this.nextAttemptAt,
    acknowledgedAt: acknowledgedAt.present
        ? acknowledgedAt.value
        : this.acknowledgedAt,
  );
  SyncOutboxRow copyWithCompanion(SyncOutboxRecordsCompanion data) {
    return SyncOutboxRow(
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      attemptCount: data.attemptCount.present
          ? data.attemptCount.value
          : this.attemptCount,
      nextAttemptAt: data.nextAttemptAt.present
          ? data.nextAttemptAt.value
          : this.nextAttemptAt,
      acknowledgedAt: data.acknowledgedAt.present
          ? data.acknowledgedAt.value
          : this.acknowledgedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxRow(')
          ..write('eventId: $eventId, ')
          ..write('sessionId: $sessionId, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('acknowledgedAt: $acknowledgedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    eventId,
    sessionId,
    attemptCount,
    nextAttemptAt,
    acknowledgedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncOutboxRow &&
          other.eventId == this.eventId &&
          other.sessionId == this.sessionId &&
          other.attemptCount == this.attemptCount &&
          other.nextAttemptAt == this.nextAttemptAt &&
          other.acknowledgedAt == this.acknowledgedAt);
}

class SyncOutboxRecordsCompanion extends UpdateCompanion<SyncOutboxRow> {
  final Value<String> eventId;
  final Value<String> sessionId;
  final Value<int> attemptCount;
  final Value<DateTime?> nextAttemptAt;
  final Value<DateTime?> acknowledgedAt;
  final Value<int> rowid;
  const SyncOutboxRecordsCompanion({
    this.eventId = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.acknowledgedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncOutboxRecordsCompanion.insert({
    required String eventId,
    required String sessionId,
    this.attemptCount = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.acknowledgedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : eventId = Value(eventId),
       sessionId = Value(sessionId);
  static Insertable<SyncOutboxRow> custom({
    Expression<String>? eventId,
    Expression<String>? sessionId,
    Expression<int>? attemptCount,
    Expression<DateTime>? nextAttemptAt,
    Expression<DateTime>? acknowledgedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (eventId != null) 'event_id': eventId,
      if (sessionId != null) 'session_id': sessionId,
      if (attemptCount != null) 'attempt_count': attemptCount,
      if (nextAttemptAt != null) 'next_attempt_at': nextAttemptAt,
      if (acknowledgedAt != null) 'acknowledged_at': acknowledgedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncOutboxRecordsCompanion copyWith({
    Value<String>? eventId,
    Value<String>? sessionId,
    Value<int>? attemptCount,
    Value<DateTime?>? nextAttemptAt,
    Value<DateTime?>? acknowledgedAt,
    Value<int>? rowid,
  }) {
    return SyncOutboxRecordsCompanion(
      eventId: eventId ?? this.eventId,
      sessionId: sessionId ?? this.sessionId,
      attemptCount: attemptCount ?? this.attemptCount,
      nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
      acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (attemptCount.present) {
      map['attempt_count'] = Variable<int>(attemptCount.value);
    }
    if (nextAttemptAt.present) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt.value);
    }
    if (acknowledgedAt.present) {
      map['acknowledged_at'] = Variable<DateTime>(acknowledgedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxRecordsCompanion(')
          ..write('eventId: $eventId, ')
          ..write('sessionId: $sessionId, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('acknowledgedAt: $acknowledgedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncInboxRecordsTable extends SyncInboxRecords
    with TableInfo<$SyncInboxRecordsTable, SyncInboxRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncInboxRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
    'event_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _checksumMeta = const VerificationMeta(
    'checksum',
  );
  @override
  late final GeneratedColumn<String> checksum = GeneratedColumn<String>(
    'checksum',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _receivedAtMeta = const VerificationMeta(
    'receivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> receivedAt = GeneratedColumn<DateTime>(
    'received_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _appliedAtMeta = const VerificationMeta(
    'appliedAt',
  );
  @override
  late final GeneratedColumn<DateTime> appliedAt = GeneratedColumn<DateTime>(
    'applied_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    eventId,
    checksum,
    receivedAt,
    appliedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_inbox_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncInboxRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
      );
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('checksum')) {
      context.handle(
        _checksumMeta,
        checksum.isAcceptableOrUnknown(data['checksum']!, _checksumMeta),
      );
    } else if (isInserting) {
      context.missing(_checksumMeta);
    }
    if (data.containsKey('received_at')) {
      context.handle(
        _receivedAtMeta,
        receivedAt.isAcceptableOrUnknown(data['received_at']!, _receivedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_receivedAtMeta);
    }
    if (data.containsKey('applied_at')) {
      context.handle(
        _appliedAtMeta,
        appliedAt.isAcceptableOrUnknown(data['applied_at']!, _appliedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {eventId};
  @override
  SyncInboxRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncInboxRow(
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_id'],
      )!,
      checksum: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}checksum'],
      )!,
      receivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}received_at'],
      )!,
      appliedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}applied_at'],
      ),
    );
  }

  @override
  $SyncInboxRecordsTable createAlias(String alias) {
    return $SyncInboxRecordsTable(attachedDatabase, alias);
  }
}

class SyncInboxRow extends DataClass implements Insertable<SyncInboxRow> {
  final String eventId;
  final String checksum;
  final DateTime receivedAt;
  final DateTime? appliedAt;
  const SyncInboxRow({
    required this.eventId,
    required this.checksum,
    required this.receivedAt,
    this.appliedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['event_id'] = Variable<String>(eventId);
    map['checksum'] = Variable<String>(checksum);
    map['received_at'] = Variable<DateTime>(receivedAt);
    if (!nullToAbsent || appliedAt != null) {
      map['applied_at'] = Variable<DateTime>(appliedAt);
    }
    return map;
  }

  SyncInboxRecordsCompanion toCompanion(bool nullToAbsent) {
    return SyncInboxRecordsCompanion(
      eventId: Value(eventId),
      checksum: Value(checksum),
      receivedAt: Value(receivedAt),
      appliedAt: appliedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(appliedAt),
    );
  }

  factory SyncInboxRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncInboxRow(
      eventId: serializer.fromJson<String>(json['eventId']),
      checksum: serializer.fromJson<String>(json['checksum']),
      receivedAt: serializer.fromJson<DateTime>(json['receivedAt']),
      appliedAt: serializer.fromJson<DateTime?>(json['appliedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'eventId': serializer.toJson<String>(eventId),
      'checksum': serializer.toJson<String>(checksum),
      'receivedAt': serializer.toJson<DateTime>(receivedAt),
      'appliedAt': serializer.toJson<DateTime?>(appliedAt),
    };
  }

  SyncInboxRow copyWith({
    String? eventId,
    String? checksum,
    DateTime? receivedAt,
    Value<DateTime?> appliedAt = const Value.absent(),
  }) => SyncInboxRow(
    eventId: eventId ?? this.eventId,
    checksum: checksum ?? this.checksum,
    receivedAt: receivedAt ?? this.receivedAt,
    appliedAt: appliedAt.present ? appliedAt.value : this.appliedAt,
  );
  SyncInboxRow copyWithCompanion(SyncInboxRecordsCompanion data) {
    return SyncInboxRow(
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      checksum: data.checksum.present ? data.checksum.value : this.checksum,
      receivedAt: data.receivedAt.present
          ? data.receivedAt.value
          : this.receivedAt,
      appliedAt: data.appliedAt.present ? data.appliedAt.value : this.appliedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncInboxRow(')
          ..write('eventId: $eventId, ')
          ..write('checksum: $checksum, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('appliedAt: $appliedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(eventId, checksum, receivedAt, appliedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncInboxRow &&
          other.eventId == this.eventId &&
          other.checksum == this.checksum &&
          other.receivedAt == this.receivedAt &&
          other.appliedAt == this.appliedAt);
}

class SyncInboxRecordsCompanion extends UpdateCompanion<SyncInboxRow> {
  final Value<String> eventId;
  final Value<String> checksum;
  final Value<DateTime> receivedAt;
  final Value<DateTime?> appliedAt;
  final Value<int> rowid;
  const SyncInboxRecordsCompanion({
    this.eventId = const Value.absent(),
    this.checksum = const Value.absent(),
    this.receivedAt = const Value.absent(),
    this.appliedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncInboxRecordsCompanion.insert({
    required String eventId,
    required String checksum,
    required DateTime receivedAt,
    this.appliedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : eventId = Value(eventId),
       checksum = Value(checksum),
       receivedAt = Value(receivedAt);
  static Insertable<SyncInboxRow> custom({
    Expression<String>? eventId,
    Expression<String>? checksum,
    Expression<DateTime>? receivedAt,
    Expression<DateTime>? appliedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (eventId != null) 'event_id': eventId,
      if (checksum != null) 'checksum': checksum,
      if (receivedAt != null) 'received_at': receivedAt,
      if (appliedAt != null) 'applied_at': appliedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncInboxRecordsCompanion copyWith({
    Value<String>? eventId,
    Value<String>? checksum,
    Value<DateTime>? receivedAt,
    Value<DateTime?>? appliedAt,
    Value<int>? rowid,
  }) {
    return SyncInboxRecordsCompanion(
      eventId: eventId ?? this.eventId,
      checksum: checksum ?? this.checksum,
      receivedAt: receivedAt ?? this.receivedAt,
      appliedAt: appliedAt ?? this.appliedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (checksum.present) {
      map['checksum'] = Variable<String>(checksum.value);
    }
    if (receivedAt.present) {
      map['received_at'] = Variable<DateTime>(receivedAt.value);
    }
    if (appliedAt.present) {
      map['applied_at'] = Variable<DateTime>(appliedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncInboxRecordsCompanion(')
          ..write('eventId: $eventId, ')
          ..write('checksum: $checksum, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('appliedAt: $appliedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MediaManifestRecordsTable extends MediaManifestRecords
    with TableInfo<$MediaManifestRecordsTable, MediaManifestRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MediaManifestRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES work_session_records (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _assignmentIdMeta = const VerificationMeta(
    'assignmentId',
  );
  @override
  late final GeneratedColumn<String> assignmentId = GeneratedColumn<String>(
    'assignment_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _roomNumberMeta = const VerificationMeta(
    'roomNumber',
  );
  @override
  late final GeneratedColumn<String> roomNumber = GeneratedColumn<String>(
    'room_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _relativePathMeta = const VerificationMeta(
    'relativePath',
  );
  @override
  late final GeneratedColumn<String> relativePath = GeneratedColumn<String>(
    'relative_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _checksumSha256Meta = const VerificationMeta(
    'checksumSha256',
  );
  @override
  late final GeneratedColumn<String> checksumSha256 = GeneratedColumn<String>(
    'checksum_sha256',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originDeviceIdMeta = const VerificationMeta(
    'originDeviceId',
  );
  @override
  late final GeneratedColumn<String> originDeviceId = GeneratedColumn<String>(
    'origin_device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta(
    'mimeType',
  );
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mime_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _transcriptMeta = const VerificationMeta(
    'transcript',
  );
  @override
  late final GeneratedColumn<String> transcript = GeneratedColumn<String>(
    'transcript',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _byteLengthMeta = const VerificationMeta(
    'byteLength',
  );
  @override
  late final GeneratedColumn<int> byteLength = GeneratedColumn<int>(
    'byte_length',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _widthPixelsMeta = const VerificationMeta(
    'widthPixels',
  );
  @override
  late final GeneratedColumn<int> widthPixels = GeneratedColumn<int>(
    'width_pixels',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heightPixelsMeta = const VerificationMeta(
    'heightPixels',
  );
  @override
  late final GeneratedColumn<int> heightPixels = GeneratedColumn<int>(
    'height_pixels',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originalExtensionMeta = const VerificationMeta(
    'originalExtension',
  );
  @override
  late final GeneratedColumn<String> originalExtension =
      GeneratedColumn<String>(
        'original_extension',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _orientationMeta = const VerificationMeta(
    'orientation',
  );
  @override
  late final GeneratedColumn<int> orientation = GeneratedColumn<int>(
    'orientation',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _colorSpaceMeta = const VerificationMeta(
    'colorSpace',
  );
  @override
  late final GeneratedColumn<String> colorSpace = GeneratedColumn<String>(
    'color_space',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isHdrMeta = const VerificationMeta('isHdr');
  @override
  late final GeneratedColumn<bool> isHdr = GeneratedColumn<bool>(
    'is_hdr',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_hdr" IN (0, 1))',
    ),
  );
  static const VerificationMeta _lastCommandIdMeta = const VerificationMeta(
    'lastCommandId',
  );
  @override
  late final GeneratedColumn<String> lastCommandId = GeneratedColumn<String>(
    'last_command_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    assignmentId,
    roomNumber,
    kind,
    relativePath,
    checksumSha256,
    originDeviceId,
    createdAt,
    updatedAt,
    mimeType,
    durationMs,
    transcript,
    byteLength,
    widthPixels,
    heightPixels,
    originalExtension,
    orientation,
    colorSpace,
    isHdr,
    lastCommandId,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'media_manifest_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<MediaManifestRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('assignment_id')) {
      context.handle(
        _assignmentIdMeta,
        assignmentId.isAcceptableOrUnknown(
          data['assignment_id']!,
          _assignmentIdMeta,
        ),
      );
    }
    if (data.containsKey('room_number')) {
      context.handle(
        _roomNumberMeta,
        roomNumber.isAcceptableOrUnknown(data['room_number']!, _roomNumberMeta),
      );
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('relative_path')) {
      context.handle(
        _relativePathMeta,
        relativePath.isAcceptableOrUnknown(
          data['relative_path']!,
          _relativePathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_relativePathMeta);
    }
    if (data.containsKey('checksum_sha256')) {
      context.handle(
        _checksumSha256Meta,
        checksumSha256.isAcceptableOrUnknown(
          data['checksum_sha256']!,
          _checksumSha256Meta,
        ),
      );
    } else if (isInserting) {
      context.missing(_checksumSha256Meta);
    }
    if (data.containsKey('origin_device_id')) {
      context.handle(
        _originDeviceIdMeta,
        originDeviceId.isAcceptableOrUnknown(
          data['origin_device_id']!,
          _originDeviceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originDeviceIdMeta);
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
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('transcript')) {
      context.handle(
        _transcriptMeta,
        transcript.isAcceptableOrUnknown(data['transcript']!, _transcriptMeta),
      );
    }
    if (data.containsKey('byte_length')) {
      context.handle(
        _byteLengthMeta,
        byteLength.isAcceptableOrUnknown(data['byte_length']!, _byteLengthMeta),
      );
    }
    if (data.containsKey('width_pixels')) {
      context.handle(
        _widthPixelsMeta,
        widthPixels.isAcceptableOrUnknown(
          data['width_pixels']!,
          _widthPixelsMeta,
        ),
      );
    }
    if (data.containsKey('height_pixels')) {
      context.handle(
        _heightPixelsMeta,
        heightPixels.isAcceptableOrUnknown(
          data['height_pixels']!,
          _heightPixelsMeta,
        ),
      );
    }
    if (data.containsKey('original_extension')) {
      context.handle(
        _originalExtensionMeta,
        originalExtension.isAcceptableOrUnknown(
          data['original_extension']!,
          _originalExtensionMeta,
        ),
      );
    }
    if (data.containsKey('orientation')) {
      context.handle(
        _orientationMeta,
        orientation.isAcceptableOrUnknown(
          data['orientation']!,
          _orientationMeta,
        ),
      );
    }
    if (data.containsKey('color_space')) {
      context.handle(
        _colorSpaceMeta,
        colorSpace.isAcceptableOrUnknown(data['color_space']!, _colorSpaceMeta),
      );
    }
    if (data.containsKey('is_hdr')) {
      context.handle(
        _isHdrMeta,
        isHdr.isAcceptableOrUnknown(data['is_hdr']!, _isHdrMeta),
      );
    }
    if (data.containsKey('last_command_id')) {
      context.handle(
        _lastCommandIdMeta,
        lastCommandId.isAcceptableOrUnknown(
          data['last_command_id']!,
          _lastCommandIdMeta,
        ),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MediaManifestRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MediaManifestRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      assignmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assignment_id'],
      ),
      roomNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}room_number'],
      ),
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      relativePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relative_path'],
      )!,
      checksumSha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}checksum_sha256'],
      )!,
      originDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin_device_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      ),
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      ),
      transcript: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transcript'],
      ),
      byteLength: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}byte_length'],
      ),
      widthPixels: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}width_pixels'],
      ),
      heightPixels: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}height_pixels'],
      ),
      originalExtension: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_extension'],
      ),
      orientation: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}orientation'],
      ),
      colorSpace: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color_space'],
      ),
      isHdr: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_hdr'],
      ),
      lastCommandId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_command_id'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $MediaManifestRecordsTable createAlias(String alias) {
    return $MediaManifestRecordsTable(attachedDatabase, alias);
  }
}

class MediaManifestRow extends DataClass
    implements Insertable<MediaManifestRow> {
  final String id;
  final String sessionId;
  final String? assignmentId;
  final String? roomNumber;
  final String kind;
  final String relativePath;
  final String checksumSha256;
  final String originDeviceId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? mimeType;
  final int? durationMs;
  final String? transcript;
  final int? byteLength;
  final int? widthPixels;
  final int? heightPixels;
  final String? originalExtension;
  final int? orientation;
  final String? colorSpace;
  final bool? isHdr;
  final String? lastCommandId;
  final DateTime? deletedAt;
  const MediaManifestRow({
    required this.id,
    required this.sessionId,
    this.assignmentId,
    this.roomNumber,
    required this.kind,
    required this.relativePath,
    required this.checksumSha256,
    required this.originDeviceId,
    required this.createdAt,
    required this.updatedAt,
    this.mimeType,
    this.durationMs,
    this.transcript,
    this.byteLength,
    this.widthPixels,
    this.heightPixels,
    this.originalExtension,
    this.orientation,
    this.colorSpace,
    this.isHdr,
    this.lastCommandId,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    if (!nullToAbsent || assignmentId != null) {
      map['assignment_id'] = Variable<String>(assignmentId);
    }
    if (!nullToAbsent || roomNumber != null) {
      map['room_number'] = Variable<String>(roomNumber);
    }
    map['kind'] = Variable<String>(kind);
    map['relative_path'] = Variable<String>(relativePath);
    map['checksum_sha256'] = Variable<String>(checksumSha256);
    map['origin_device_id'] = Variable<String>(originDeviceId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || mimeType != null) {
      map['mime_type'] = Variable<String>(mimeType);
    }
    if (!nullToAbsent || durationMs != null) {
      map['duration_ms'] = Variable<int>(durationMs);
    }
    if (!nullToAbsent || transcript != null) {
      map['transcript'] = Variable<String>(transcript);
    }
    if (!nullToAbsent || byteLength != null) {
      map['byte_length'] = Variable<int>(byteLength);
    }
    if (!nullToAbsent || widthPixels != null) {
      map['width_pixels'] = Variable<int>(widthPixels);
    }
    if (!nullToAbsent || heightPixels != null) {
      map['height_pixels'] = Variable<int>(heightPixels);
    }
    if (!nullToAbsent || originalExtension != null) {
      map['original_extension'] = Variable<String>(originalExtension);
    }
    if (!nullToAbsent || orientation != null) {
      map['orientation'] = Variable<int>(orientation);
    }
    if (!nullToAbsent || colorSpace != null) {
      map['color_space'] = Variable<String>(colorSpace);
    }
    if (!nullToAbsent || isHdr != null) {
      map['is_hdr'] = Variable<bool>(isHdr);
    }
    if (!nullToAbsent || lastCommandId != null) {
      map['last_command_id'] = Variable<String>(lastCommandId);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  MediaManifestRecordsCompanion toCompanion(bool nullToAbsent) {
    return MediaManifestRecordsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      assignmentId: assignmentId == null && nullToAbsent
          ? const Value.absent()
          : Value(assignmentId),
      roomNumber: roomNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(roomNumber),
      kind: Value(kind),
      relativePath: Value(relativePath),
      checksumSha256: Value(checksumSha256),
      originDeviceId: Value(originDeviceId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      mimeType: mimeType == null && nullToAbsent
          ? const Value.absent()
          : Value(mimeType),
      durationMs: durationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMs),
      transcript: transcript == null && nullToAbsent
          ? const Value.absent()
          : Value(transcript),
      byteLength: byteLength == null && nullToAbsent
          ? const Value.absent()
          : Value(byteLength),
      widthPixels: widthPixels == null && nullToAbsent
          ? const Value.absent()
          : Value(widthPixels),
      heightPixels: heightPixels == null && nullToAbsent
          ? const Value.absent()
          : Value(heightPixels),
      originalExtension: originalExtension == null && nullToAbsent
          ? const Value.absent()
          : Value(originalExtension),
      orientation: orientation == null && nullToAbsent
          ? const Value.absent()
          : Value(orientation),
      colorSpace: colorSpace == null && nullToAbsent
          ? const Value.absent()
          : Value(colorSpace),
      isHdr: isHdr == null && nullToAbsent
          ? const Value.absent()
          : Value(isHdr),
      lastCommandId: lastCommandId == null && nullToAbsent
          ? const Value.absent()
          : Value(lastCommandId),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory MediaManifestRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MediaManifestRow(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      assignmentId: serializer.fromJson<String?>(json['assignmentId']),
      roomNumber: serializer.fromJson<String?>(json['roomNumber']),
      kind: serializer.fromJson<String>(json['kind']),
      relativePath: serializer.fromJson<String>(json['relativePath']),
      checksumSha256: serializer.fromJson<String>(json['checksumSha256']),
      originDeviceId: serializer.fromJson<String>(json['originDeviceId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      mimeType: serializer.fromJson<String?>(json['mimeType']),
      durationMs: serializer.fromJson<int?>(json['durationMs']),
      transcript: serializer.fromJson<String?>(json['transcript']),
      byteLength: serializer.fromJson<int?>(json['byteLength']),
      widthPixels: serializer.fromJson<int?>(json['widthPixels']),
      heightPixels: serializer.fromJson<int?>(json['heightPixels']),
      originalExtension: serializer.fromJson<String?>(
        json['originalExtension'],
      ),
      orientation: serializer.fromJson<int?>(json['orientation']),
      colorSpace: serializer.fromJson<String?>(json['colorSpace']),
      isHdr: serializer.fromJson<bool?>(json['isHdr']),
      lastCommandId: serializer.fromJson<String?>(json['lastCommandId']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'assignmentId': serializer.toJson<String?>(assignmentId),
      'roomNumber': serializer.toJson<String?>(roomNumber),
      'kind': serializer.toJson<String>(kind),
      'relativePath': serializer.toJson<String>(relativePath),
      'checksumSha256': serializer.toJson<String>(checksumSha256),
      'originDeviceId': serializer.toJson<String>(originDeviceId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'mimeType': serializer.toJson<String?>(mimeType),
      'durationMs': serializer.toJson<int?>(durationMs),
      'transcript': serializer.toJson<String?>(transcript),
      'byteLength': serializer.toJson<int?>(byteLength),
      'widthPixels': serializer.toJson<int?>(widthPixels),
      'heightPixels': serializer.toJson<int?>(heightPixels),
      'originalExtension': serializer.toJson<String?>(originalExtension),
      'orientation': serializer.toJson<int?>(orientation),
      'colorSpace': serializer.toJson<String?>(colorSpace),
      'isHdr': serializer.toJson<bool?>(isHdr),
      'lastCommandId': serializer.toJson<String?>(lastCommandId),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  MediaManifestRow copyWith({
    String? id,
    String? sessionId,
    Value<String?> assignmentId = const Value.absent(),
    Value<String?> roomNumber = const Value.absent(),
    String? kind,
    String? relativePath,
    String? checksumSha256,
    String? originDeviceId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<String?> mimeType = const Value.absent(),
    Value<int?> durationMs = const Value.absent(),
    Value<String?> transcript = const Value.absent(),
    Value<int?> byteLength = const Value.absent(),
    Value<int?> widthPixels = const Value.absent(),
    Value<int?> heightPixels = const Value.absent(),
    Value<String?> originalExtension = const Value.absent(),
    Value<int?> orientation = const Value.absent(),
    Value<String?> colorSpace = const Value.absent(),
    Value<bool?> isHdr = const Value.absent(),
    Value<String?> lastCommandId = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => MediaManifestRow(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    assignmentId: assignmentId.present ? assignmentId.value : this.assignmentId,
    roomNumber: roomNumber.present ? roomNumber.value : this.roomNumber,
    kind: kind ?? this.kind,
    relativePath: relativePath ?? this.relativePath,
    checksumSha256: checksumSha256 ?? this.checksumSha256,
    originDeviceId: originDeviceId ?? this.originDeviceId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    mimeType: mimeType.present ? mimeType.value : this.mimeType,
    durationMs: durationMs.present ? durationMs.value : this.durationMs,
    transcript: transcript.present ? transcript.value : this.transcript,
    byteLength: byteLength.present ? byteLength.value : this.byteLength,
    widthPixels: widthPixels.present ? widthPixels.value : this.widthPixels,
    heightPixels: heightPixels.present ? heightPixels.value : this.heightPixels,
    originalExtension: originalExtension.present
        ? originalExtension.value
        : this.originalExtension,
    orientation: orientation.present ? orientation.value : this.orientation,
    colorSpace: colorSpace.present ? colorSpace.value : this.colorSpace,
    isHdr: isHdr.present ? isHdr.value : this.isHdr,
    lastCommandId: lastCommandId.present
        ? lastCommandId.value
        : this.lastCommandId,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  MediaManifestRow copyWithCompanion(MediaManifestRecordsCompanion data) {
    return MediaManifestRow(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      assignmentId: data.assignmentId.present
          ? data.assignmentId.value
          : this.assignmentId,
      roomNumber: data.roomNumber.present
          ? data.roomNumber.value
          : this.roomNumber,
      kind: data.kind.present ? data.kind.value : this.kind,
      relativePath: data.relativePath.present
          ? data.relativePath.value
          : this.relativePath,
      checksumSha256: data.checksumSha256.present
          ? data.checksumSha256.value
          : this.checksumSha256,
      originDeviceId: data.originDeviceId.present
          ? data.originDeviceId.value
          : this.originDeviceId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      transcript: data.transcript.present
          ? data.transcript.value
          : this.transcript,
      byteLength: data.byteLength.present
          ? data.byteLength.value
          : this.byteLength,
      widthPixels: data.widthPixels.present
          ? data.widthPixels.value
          : this.widthPixels,
      heightPixels: data.heightPixels.present
          ? data.heightPixels.value
          : this.heightPixels,
      originalExtension: data.originalExtension.present
          ? data.originalExtension.value
          : this.originalExtension,
      orientation: data.orientation.present
          ? data.orientation.value
          : this.orientation,
      colorSpace: data.colorSpace.present
          ? data.colorSpace.value
          : this.colorSpace,
      isHdr: data.isHdr.present ? data.isHdr.value : this.isHdr,
      lastCommandId: data.lastCommandId.present
          ? data.lastCommandId.value
          : this.lastCommandId,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MediaManifestRow(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('assignmentId: $assignmentId, ')
          ..write('roomNumber: $roomNumber, ')
          ..write('kind: $kind, ')
          ..write('relativePath: $relativePath, ')
          ..write('checksumSha256: $checksumSha256, ')
          ..write('originDeviceId: $originDeviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('mimeType: $mimeType, ')
          ..write('durationMs: $durationMs, ')
          ..write('transcript: $transcript, ')
          ..write('byteLength: $byteLength, ')
          ..write('widthPixels: $widthPixels, ')
          ..write('heightPixels: $heightPixels, ')
          ..write('originalExtension: $originalExtension, ')
          ..write('orientation: $orientation, ')
          ..write('colorSpace: $colorSpace, ')
          ..write('isHdr: $isHdr, ')
          ..write('lastCommandId: $lastCommandId, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    sessionId,
    assignmentId,
    roomNumber,
    kind,
    relativePath,
    checksumSha256,
    originDeviceId,
    createdAt,
    updatedAt,
    mimeType,
    durationMs,
    transcript,
    byteLength,
    widthPixels,
    heightPixels,
    originalExtension,
    orientation,
    colorSpace,
    isHdr,
    lastCommandId,
    deletedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MediaManifestRow &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.assignmentId == this.assignmentId &&
          other.roomNumber == this.roomNumber &&
          other.kind == this.kind &&
          other.relativePath == this.relativePath &&
          other.checksumSha256 == this.checksumSha256 &&
          other.originDeviceId == this.originDeviceId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.mimeType == this.mimeType &&
          other.durationMs == this.durationMs &&
          other.transcript == this.transcript &&
          other.byteLength == this.byteLength &&
          other.widthPixels == this.widthPixels &&
          other.heightPixels == this.heightPixels &&
          other.originalExtension == this.originalExtension &&
          other.orientation == this.orientation &&
          other.colorSpace == this.colorSpace &&
          other.isHdr == this.isHdr &&
          other.lastCommandId == this.lastCommandId &&
          other.deletedAt == this.deletedAt);
}

class MediaManifestRecordsCompanion extends UpdateCompanion<MediaManifestRow> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<String?> assignmentId;
  final Value<String?> roomNumber;
  final Value<String> kind;
  final Value<String> relativePath;
  final Value<String> checksumSha256;
  final Value<String> originDeviceId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String?> mimeType;
  final Value<int?> durationMs;
  final Value<String?> transcript;
  final Value<int?> byteLength;
  final Value<int?> widthPixels;
  final Value<int?> heightPixels;
  final Value<String?> originalExtension;
  final Value<int?> orientation;
  final Value<String?> colorSpace;
  final Value<bool?> isHdr;
  final Value<String?> lastCommandId;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const MediaManifestRecordsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.assignmentId = const Value.absent(),
    this.roomNumber = const Value.absent(),
    this.kind = const Value.absent(),
    this.relativePath = const Value.absent(),
    this.checksumSha256 = const Value.absent(),
    this.originDeviceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.transcript = const Value.absent(),
    this.byteLength = const Value.absent(),
    this.widthPixels = const Value.absent(),
    this.heightPixels = const Value.absent(),
    this.originalExtension = const Value.absent(),
    this.orientation = const Value.absent(),
    this.colorSpace = const Value.absent(),
    this.isHdr = const Value.absent(),
    this.lastCommandId = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MediaManifestRecordsCompanion.insert({
    required String id,
    required String sessionId,
    this.assignmentId = const Value.absent(),
    this.roomNumber = const Value.absent(),
    required String kind,
    required String relativePath,
    required String checksumSha256,
    required String originDeviceId,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.mimeType = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.transcript = const Value.absent(),
    this.byteLength = const Value.absent(),
    this.widthPixels = const Value.absent(),
    this.heightPixels = const Value.absent(),
    this.originalExtension = const Value.absent(),
    this.orientation = const Value.absent(),
    this.colorSpace = const Value.absent(),
    this.isHdr = const Value.absent(),
    this.lastCommandId = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId),
       kind = Value(kind),
       relativePath = Value(relativePath),
       checksumSha256 = Value(checksumSha256),
       originDeviceId = Value(originDeviceId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<MediaManifestRow> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<String>? assignmentId,
    Expression<String>? roomNumber,
    Expression<String>? kind,
    Expression<String>? relativePath,
    Expression<String>? checksumSha256,
    Expression<String>? originDeviceId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? mimeType,
    Expression<int>? durationMs,
    Expression<String>? transcript,
    Expression<int>? byteLength,
    Expression<int>? widthPixels,
    Expression<int>? heightPixels,
    Expression<String>? originalExtension,
    Expression<int>? orientation,
    Expression<String>? colorSpace,
    Expression<bool>? isHdr,
    Expression<String>? lastCommandId,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (assignmentId != null) 'assignment_id': assignmentId,
      if (roomNumber != null) 'room_number': roomNumber,
      if (kind != null) 'kind': kind,
      if (relativePath != null) 'relative_path': relativePath,
      if (checksumSha256 != null) 'checksum_sha256': checksumSha256,
      if (originDeviceId != null) 'origin_device_id': originDeviceId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (mimeType != null) 'mime_type': mimeType,
      if (durationMs != null) 'duration_ms': durationMs,
      if (transcript != null) 'transcript': transcript,
      if (byteLength != null) 'byte_length': byteLength,
      if (widthPixels != null) 'width_pixels': widthPixels,
      if (heightPixels != null) 'height_pixels': heightPixels,
      if (originalExtension != null) 'original_extension': originalExtension,
      if (orientation != null) 'orientation': orientation,
      if (colorSpace != null) 'color_space': colorSpace,
      if (isHdr != null) 'is_hdr': isHdr,
      if (lastCommandId != null) 'last_command_id': lastCommandId,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MediaManifestRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionId,
    Value<String?>? assignmentId,
    Value<String?>? roomNumber,
    Value<String>? kind,
    Value<String>? relativePath,
    Value<String>? checksumSha256,
    Value<String>? originDeviceId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String?>? mimeType,
    Value<int?>? durationMs,
    Value<String?>? transcript,
    Value<int?>? byteLength,
    Value<int?>? widthPixels,
    Value<int?>? heightPixels,
    Value<String?>? originalExtension,
    Value<int?>? orientation,
    Value<String?>? colorSpace,
    Value<bool?>? isHdr,
    Value<String?>? lastCommandId,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return MediaManifestRecordsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      assignmentId: assignmentId ?? this.assignmentId,
      roomNumber: roomNumber ?? this.roomNumber,
      kind: kind ?? this.kind,
      relativePath: relativePath ?? this.relativePath,
      checksumSha256: checksumSha256 ?? this.checksumSha256,
      originDeviceId: originDeviceId ?? this.originDeviceId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      mimeType: mimeType ?? this.mimeType,
      durationMs: durationMs ?? this.durationMs,
      transcript: transcript ?? this.transcript,
      byteLength: byteLength ?? this.byteLength,
      widthPixels: widthPixels ?? this.widthPixels,
      heightPixels: heightPixels ?? this.heightPixels,
      originalExtension: originalExtension ?? this.originalExtension,
      orientation: orientation ?? this.orientation,
      colorSpace: colorSpace ?? this.colorSpace,
      isHdr: isHdr ?? this.isHdr,
      lastCommandId: lastCommandId ?? this.lastCommandId,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (assignmentId.present) {
      map['assignment_id'] = Variable<String>(assignmentId.value);
    }
    if (roomNumber.present) {
      map['room_number'] = Variable<String>(roomNumber.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (relativePath.present) {
      map['relative_path'] = Variable<String>(relativePath.value);
    }
    if (checksumSha256.present) {
      map['checksum_sha256'] = Variable<String>(checksumSha256.value);
    }
    if (originDeviceId.present) {
      map['origin_device_id'] = Variable<String>(originDeviceId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (transcript.present) {
      map['transcript'] = Variable<String>(transcript.value);
    }
    if (byteLength.present) {
      map['byte_length'] = Variable<int>(byteLength.value);
    }
    if (widthPixels.present) {
      map['width_pixels'] = Variable<int>(widthPixels.value);
    }
    if (heightPixels.present) {
      map['height_pixels'] = Variable<int>(heightPixels.value);
    }
    if (originalExtension.present) {
      map['original_extension'] = Variable<String>(originalExtension.value);
    }
    if (orientation.present) {
      map['orientation'] = Variable<int>(orientation.value);
    }
    if (colorSpace.present) {
      map['color_space'] = Variable<String>(colorSpace.value);
    }
    if (isHdr.present) {
      map['is_hdr'] = Variable<bool>(isHdr.value);
    }
    if (lastCommandId.present) {
      map['last_command_id'] = Variable<String>(lastCommandId.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MediaManifestRecordsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('assignmentId: $assignmentId, ')
          ..write('roomNumber: $roomNumber, ')
          ..write('kind: $kind, ')
          ..write('relativePath: $relativePath, ')
          ..write('checksumSha256: $checksumSha256, ')
          ..write('originDeviceId: $originDeviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('mimeType: $mimeType, ')
          ..write('durationMs: $durationMs, ')
          ..write('transcript: $transcript, ')
          ..write('byteLength: $byteLength, ')
          ..write('widthPixels: $widthPixels, ')
          ..write('heightPixels: $heightPixels, ')
          ..write('originalExtension: $originalExtension, ')
          ..write('orientation: $orientation, ')
          ..write('colorSpace: $colorSpace, ')
          ..write('isHdr: $isHdr, ')
          ..write('lastCommandId: $lastCommandId, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MediaPromotionRecordsTable extends MediaPromotionRecords
    with TableInfo<$MediaPromotionRecordsTable, MediaPromotionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MediaPromotionRecordsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _commandIdMeta = const VerificationMeta(
    'commandId',
  );
  @override
  late final GeneratedColumn<String> commandId = GeneratedColumn<String>(
    'command_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mediaIdMeta = const VerificationMeta(
    'mediaId',
  );
  @override
  late final GeneratedColumn<String> mediaId = GeneratedColumn<String>(
    'media_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES work_session_records (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _roomNumberMeta = const VerificationMeta(
    'roomNumber',
  );
  @override
  late final GeneratedColumn<String> roomNumber = GeneratedColumn<String>(
    'room_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _assignmentIdMeta = const VerificationMeta(
    'assignmentId',
  );
  @override
  late final GeneratedColumn<String> assignmentId = GeneratedColumn<String>(
    'assignment_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stagedRelativePathMeta =
      const VerificationMeta('stagedRelativePath');
  @override
  late final GeneratedColumn<String> stagedRelativePath =
      GeneratedColumn<String>(
        'staged_relative_path',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _transientFilePathMeta = const VerificationMeta(
    'transientFilePath',
  );
  @override
  late final GeneratedColumn<String> transientFilePath =
      GeneratedColumn<String>(
        'transient_file_path',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _finalRelativePathMeta = const VerificationMeta(
    'finalRelativePath',
  );
  @override
  late final GeneratedColumn<String> finalRelativePath =
      GeneratedColumn<String>(
        'final_relative_path',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _checksumSha256Meta = const VerificationMeta(
    'checksumSha256',
  );
  @override
  late final GeneratedColumn<String> checksumSha256 = GeneratedColumn<String>(
    'checksum_sha256',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _byteLengthMeta = const VerificationMeta(
    'byteLength',
  );
  @override
  late final GeneratedColumn<int> byteLength = GeneratedColumn<int>(
    'byte_length',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originDeviceIdMeta = const VerificationMeta(
    'originDeviceId',
  );
  @override
  late final GeneratedColumn<String> originDeviceId = GeneratedColumn<String>(
    'origin_device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _issuedAtMeta = const VerificationMeta(
    'issuedAt',
  );
  @override
  late final GeneratedColumn<DateTime> issuedAt = GeneratedColumn<DateTime>(
    'issued_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta(
    'mimeType',
  );
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mime_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _transcriptMeta = const VerificationMeta(
    'transcript',
  );
  @override
  late final GeneratedColumn<String> transcript = GeneratedColumn<String>(
    'transcript',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _widthPixelsMeta = const VerificationMeta(
    'widthPixels',
  );
  @override
  late final GeneratedColumn<int> widthPixels = GeneratedColumn<int>(
    'width_pixels',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heightPixelsMeta = const VerificationMeta(
    'heightPixels',
  );
  @override
  late final GeneratedColumn<int> heightPixels = GeneratedColumn<int>(
    'height_pixels',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originalExtensionMeta = const VerificationMeta(
    'originalExtension',
  );
  @override
  late final GeneratedColumn<String> originalExtension =
      GeneratedColumn<String>(
        'original_extension',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _orientationMeta = const VerificationMeta(
    'orientation',
  );
  @override
  late final GeneratedColumn<int> orientation = GeneratedColumn<int>(
    'orientation',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _colorSpaceMeta = const VerificationMeta(
    'colorSpace',
  );
  @override
  late final GeneratedColumn<String> colorSpace = GeneratedColumn<String>(
    'color_space',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isHdrMeta = const VerificationMeta('isHdr');
  @override
  late final GeneratedColumn<bool> isHdr = GeneratedColumn<bool>(
    'is_hdr',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_hdr" IN (0, 1))',
    ),
  );
  static const VerificationMeta _quarantinedAtMeta = const VerificationMeta(
    'quarantinedAt',
  );
  @override
  late final GeneratedColumn<DateTime> quarantinedAt =
      GeneratedColumn<DateTime>(
        'quarantined_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _failureReasonMeta = const VerificationMeta(
    'failureReason',
  );
  @override
  late final GeneratedColumn<String> failureReason = GeneratedColumn<String>(
    'failure_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    operationId,
    commandId,
    mediaId,
    sessionId,
    roomNumber,
    assignmentId,
    kind,
    stagedRelativePath,
    transientFilePath,
    finalRelativePath,
    checksumSha256,
    byteLength,
    originDeviceId,
    createdAt,
    issuedAt,
    mimeType,
    durationMs,
    transcript,
    widthPixels,
    heightPixels,
    originalExtension,
    orientation,
    colorSpace,
    isHdr,
    quarantinedAt,
    failureReason,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'media_promotion_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<MediaPromotionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
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
    if (data.containsKey('command_id')) {
      context.handle(
        _commandIdMeta,
        commandId.isAcceptableOrUnknown(data['command_id']!, _commandIdMeta),
      );
    } else if (isInserting) {
      context.missing(_commandIdMeta);
    }
    if (data.containsKey('media_id')) {
      context.handle(
        _mediaIdMeta,
        mediaId.isAcceptableOrUnknown(data['media_id']!, _mediaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_mediaIdMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('room_number')) {
      context.handle(
        _roomNumberMeta,
        roomNumber.isAcceptableOrUnknown(data['room_number']!, _roomNumberMeta),
      );
    }
    if (data.containsKey('assignment_id')) {
      context.handle(
        _assignmentIdMeta,
        assignmentId.isAcceptableOrUnknown(
          data['assignment_id']!,
          _assignmentIdMeta,
        ),
      );
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('staged_relative_path')) {
      context.handle(
        _stagedRelativePathMeta,
        stagedRelativePath.isAcceptableOrUnknown(
          data['staged_relative_path']!,
          _stagedRelativePathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_stagedRelativePathMeta);
    }
    if (data.containsKey('transient_file_path')) {
      context.handle(
        _transientFilePathMeta,
        transientFilePath.isAcceptableOrUnknown(
          data['transient_file_path']!,
          _transientFilePathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transientFilePathMeta);
    }
    if (data.containsKey('final_relative_path')) {
      context.handle(
        _finalRelativePathMeta,
        finalRelativePath.isAcceptableOrUnknown(
          data['final_relative_path']!,
          _finalRelativePathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_finalRelativePathMeta);
    }
    if (data.containsKey('checksum_sha256')) {
      context.handle(
        _checksumSha256Meta,
        checksumSha256.isAcceptableOrUnknown(
          data['checksum_sha256']!,
          _checksumSha256Meta,
        ),
      );
    } else if (isInserting) {
      context.missing(_checksumSha256Meta);
    }
    if (data.containsKey('byte_length')) {
      context.handle(
        _byteLengthMeta,
        byteLength.isAcceptableOrUnknown(data['byte_length']!, _byteLengthMeta),
      );
    } else if (isInserting) {
      context.missing(_byteLengthMeta);
    }
    if (data.containsKey('origin_device_id')) {
      context.handle(
        _originDeviceIdMeta,
        originDeviceId.isAcceptableOrUnknown(
          data['origin_device_id']!,
          _originDeviceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originDeviceIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('issued_at')) {
      context.handle(
        _issuedAtMeta,
        issuedAt.isAcceptableOrUnknown(data['issued_at']!, _issuedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_issuedAtMeta);
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('transcript')) {
      context.handle(
        _transcriptMeta,
        transcript.isAcceptableOrUnknown(data['transcript']!, _transcriptMeta),
      );
    }
    if (data.containsKey('width_pixels')) {
      context.handle(
        _widthPixelsMeta,
        widthPixels.isAcceptableOrUnknown(
          data['width_pixels']!,
          _widthPixelsMeta,
        ),
      );
    }
    if (data.containsKey('height_pixels')) {
      context.handle(
        _heightPixelsMeta,
        heightPixels.isAcceptableOrUnknown(
          data['height_pixels']!,
          _heightPixelsMeta,
        ),
      );
    }
    if (data.containsKey('original_extension')) {
      context.handle(
        _originalExtensionMeta,
        originalExtension.isAcceptableOrUnknown(
          data['original_extension']!,
          _originalExtensionMeta,
        ),
      );
    }
    if (data.containsKey('orientation')) {
      context.handle(
        _orientationMeta,
        orientation.isAcceptableOrUnknown(
          data['orientation']!,
          _orientationMeta,
        ),
      );
    }
    if (data.containsKey('color_space')) {
      context.handle(
        _colorSpaceMeta,
        colorSpace.isAcceptableOrUnknown(data['color_space']!, _colorSpaceMeta),
      );
    }
    if (data.containsKey('is_hdr')) {
      context.handle(
        _isHdrMeta,
        isHdr.isAcceptableOrUnknown(data['is_hdr']!, _isHdrMeta),
      );
    }
    if (data.containsKey('quarantined_at')) {
      context.handle(
        _quarantinedAtMeta,
        quarantinedAt.isAcceptableOrUnknown(
          data['quarantined_at']!,
          _quarantinedAtMeta,
        ),
      );
    }
    if (data.containsKey('failure_reason')) {
      context.handle(
        _failureReasonMeta,
        failureReason.isAcceptableOrUnknown(
          data['failure_reason']!,
          _failureReasonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {operationId};
  @override
  MediaPromotionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MediaPromotionRow(
      operationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation_id'],
      )!,
      commandId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}command_id'],
      )!,
      mediaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      roomNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}room_number'],
      ),
      assignmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assignment_id'],
      ),
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      stagedRelativePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}staged_relative_path'],
      )!,
      transientFilePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transient_file_path'],
      )!,
      finalRelativePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}final_relative_path'],
      )!,
      checksumSha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}checksum_sha256'],
      )!,
      byteLength: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}byte_length'],
      )!,
      originDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin_device_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      issuedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}issued_at'],
      )!,
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      ),
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      ),
      transcript: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transcript'],
      ),
      widthPixels: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}width_pixels'],
      ),
      heightPixels: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}height_pixels'],
      ),
      originalExtension: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_extension'],
      ),
      orientation: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}orientation'],
      ),
      colorSpace: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color_space'],
      ),
      isHdr: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_hdr'],
      ),
      quarantinedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}quarantined_at'],
      ),
      failureReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}failure_reason'],
      ),
    );
  }

  @override
  $MediaPromotionRecordsTable createAlias(String alias) {
    return $MediaPromotionRecordsTable(attachedDatabase, alias);
  }
}

class MediaPromotionRow extends DataClass
    implements Insertable<MediaPromotionRow> {
  final String operationId;
  final String commandId;
  final String mediaId;
  final String sessionId;
  final String? roomNumber;
  final String? assignmentId;
  final String kind;
  final String stagedRelativePath;
  final String transientFilePath;
  final String finalRelativePath;
  final String checksumSha256;
  final int byteLength;
  final String originDeviceId;
  final DateTime createdAt;
  final DateTime issuedAt;
  final String? mimeType;
  final int? durationMs;
  final String? transcript;
  final int? widthPixels;
  final int? heightPixels;
  final String? originalExtension;
  final int? orientation;
  final String? colorSpace;
  final bool? isHdr;
  final DateTime? quarantinedAt;
  final String? failureReason;
  const MediaPromotionRow({
    required this.operationId,
    required this.commandId,
    required this.mediaId,
    required this.sessionId,
    this.roomNumber,
    this.assignmentId,
    required this.kind,
    required this.stagedRelativePath,
    required this.transientFilePath,
    required this.finalRelativePath,
    required this.checksumSha256,
    required this.byteLength,
    required this.originDeviceId,
    required this.createdAt,
    required this.issuedAt,
    this.mimeType,
    this.durationMs,
    this.transcript,
    this.widthPixels,
    this.heightPixels,
    this.originalExtension,
    this.orientation,
    this.colorSpace,
    this.isHdr,
    this.quarantinedAt,
    this.failureReason,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['operation_id'] = Variable<String>(operationId);
    map['command_id'] = Variable<String>(commandId);
    map['media_id'] = Variable<String>(mediaId);
    map['session_id'] = Variable<String>(sessionId);
    if (!nullToAbsent || roomNumber != null) {
      map['room_number'] = Variable<String>(roomNumber);
    }
    if (!nullToAbsent || assignmentId != null) {
      map['assignment_id'] = Variable<String>(assignmentId);
    }
    map['kind'] = Variable<String>(kind);
    map['staged_relative_path'] = Variable<String>(stagedRelativePath);
    map['transient_file_path'] = Variable<String>(transientFilePath);
    map['final_relative_path'] = Variable<String>(finalRelativePath);
    map['checksum_sha256'] = Variable<String>(checksumSha256);
    map['byte_length'] = Variable<int>(byteLength);
    map['origin_device_id'] = Variable<String>(originDeviceId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['issued_at'] = Variable<DateTime>(issuedAt);
    if (!nullToAbsent || mimeType != null) {
      map['mime_type'] = Variable<String>(mimeType);
    }
    if (!nullToAbsent || durationMs != null) {
      map['duration_ms'] = Variable<int>(durationMs);
    }
    if (!nullToAbsent || transcript != null) {
      map['transcript'] = Variable<String>(transcript);
    }
    if (!nullToAbsent || widthPixels != null) {
      map['width_pixels'] = Variable<int>(widthPixels);
    }
    if (!nullToAbsent || heightPixels != null) {
      map['height_pixels'] = Variable<int>(heightPixels);
    }
    if (!nullToAbsent || originalExtension != null) {
      map['original_extension'] = Variable<String>(originalExtension);
    }
    if (!nullToAbsent || orientation != null) {
      map['orientation'] = Variable<int>(orientation);
    }
    if (!nullToAbsent || colorSpace != null) {
      map['color_space'] = Variable<String>(colorSpace);
    }
    if (!nullToAbsent || isHdr != null) {
      map['is_hdr'] = Variable<bool>(isHdr);
    }
    if (!nullToAbsent || quarantinedAt != null) {
      map['quarantined_at'] = Variable<DateTime>(quarantinedAt);
    }
    if (!nullToAbsent || failureReason != null) {
      map['failure_reason'] = Variable<String>(failureReason);
    }
    return map;
  }

  MediaPromotionRecordsCompanion toCompanion(bool nullToAbsent) {
    return MediaPromotionRecordsCompanion(
      operationId: Value(operationId),
      commandId: Value(commandId),
      mediaId: Value(mediaId),
      sessionId: Value(sessionId),
      roomNumber: roomNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(roomNumber),
      assignmentId: assignmentId == null && nullToAbsent
          ? const Value.absent()
          : Value(assignmentId),
      kind: Value(kind),
      stagedRelativePath: Value(stagedRelativePath),
      transientFilePath: Value(transientFilePath),
      finalRelativePath: Value(finalRelativePath),
      checksumSha256: Value(checksumSha256),
      byteLength: Value(byteLength),
      originDeviceId: Value(originDeviceId),
      createdAt: Value(createdAt),
      issuedAt: Value(issuedAt),
      mimeType: mimeType == null && nullToAbsent
          ? const Value.absent()
          : Value(mimeType),
      durationMs: durationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMs),
      transcript: transcript == null && nullToAbsent
          ? const Value.absent()
          : Value(transcript),
      widthPixels: widthPixels == null && nullToAbsent
          ? const Value.absent()
          : Value(widthPixels),
      heightPixels: heightPixels == null && nullToAbsent
          ? const Value.absent()
          : Value(heightPixels),
      originalExtension: originalExtension == null && nullToAbsent
          ? const Value.absent()
          : Value(originalExtension),
      orientation: orientation == null && nullToAbsent
          ? const Value.absent()
          : Value(orientation),
      colorSpace: colorSpace == null && nullToAbsent
          ? const Value.absent()
          : Value(colorSpace),
      isHdr: isHdr == null && nullToAbsent
          ? const Value.absent()
          : Value(isHdr),
      quarantinedAt: quarantinedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(quarantinedAt),
      failureReason: failureReason == null && nullToAbsent
          ? const Value.absent()
          : Value(failureReason),
    );
  }

  factory MediaPromotionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MediaPromotionRow(
      operationId: serializer.fromJson<String>(json['operationId']),
      commandId: serializer.fromJson<String>(json['commandId']),
      mediaId: serializer.fromJson<String>(json['mediaId']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      roomNumber: serializer.fromJson<String?>(json['roomNumber']),
      assignmentId: serializer.fromJson<String?>(json['assignmentId']),
      kind: serializer.fromJson<String>(json['kind']),
      stagedRelativePath: serializer.fromJson<String>(
        json['stagedRelativePath'],
      ),
      transientFilePath: serializer.fromJson<String>(json['transientFilePath']),
      finalRelativePath: serializer.fromJson<String>(json['finalRelativePath']),
      checksumSha256: serializer.fromJson<String>(json['checksumSha256']),
      byteLength: serializer.fromJson<int>(json['byteLength']),
      originDeviceId: serializer.fromJson<String>(json['originDeviceId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      issuedAt: serializer.fromJson<DateTime>(json['issuedAt']),
      mimeType: serializer.fromJson<String?>(json['mimeType']),
      durationMs: serializer.fromJson<int?>(json['durationMs']),
      transcript: serializer.fromJson<String?>(json['transcript']),
      widthPixels: serializer.fromJson<int?>(json['widthPixels']),
      heightPixels: serializer.fromJson<int?>(json['heightPixels']),
      originalExtension: serializer.fromJson<String?>(
        json['originalExtension'],
      ),
      orientation: serializer.fromJson<int?>(json['orientation']),
      colorSpace: serializer.fromJson<String?>(json['colorSpace']),
      isHdr: serializer.fromJson<bool?>(json['isHdr']),
      quarantinedAt: serializer.fromJson<DateTime?>(json['quarantinedAt']),
      failureReason: serializer.fromJson<String?>(json['failureReason']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'operationId': serializer.toJson<String>(operationId),
      'commandId': serializer.toJson<String>(commandId),
      'mediaId': serializer.toJson<String>(mediaId),
      'sessionId': serializer.toJson<String>(sessionId),
      'roomNumber': serializer.toJson<String?>(roomNumber),
      'assignmentId': serializer.toJson<String?>(assignmentId),
      'kind': serializer.toJson<String>(kind),
      'stagedRelativePath': serializer.toJson<String>(stagedRelativePath),
      'transientFilePath': serializer.toJson<String>(transientFilePath),
      'finalRelativePath': serializer.toJson<String>(finalRelativePath),
      'checksumSha256': serializer.toJson<String>(checksumSha256),
      'byteLength': serializer.toJson<int>(byteLength),
      'originDeviceId': serializer.toJson<String>(originDeviceId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'issuedAt': serializer.toJson<DateTime>(issuedAt),
      'mimeType': serializer.toJson<String?>(mimeType),
      'durationMs': serializer.toJson<int?>(durationMs),
      'transcript': serializer.toJson<String?>(transcript),
      'widthPixels': serializer.toJson<int?>(widthPixels),
      'heightPixels': serializer.toJson<int?>(heightPixels),
      'originalExtension': serializer.toJson<String?>(originalExtension),
      'orientation': serializer.toJson<int?>(orientation),
      'colorSpace': serializer.toJson<String?>(colorSpace),
      'isHdr': serializer.toJson<bool?>(isHdr),
      'quarantinedAt': serializer.toJson<DateTime?>(quarantinedAt),
      'failureReason': serializer.toJson<String?>(failureReason),
    };
  }

  MediaPromotionRow copyWith({
    String? operationId,
    String? commandId,
    String? mediaId,
    String? sessionId,
    Value<String?> roomNumber = const Value.absent(),
    Value<String?> assignmentId = const Value.absent(),
    String? kind,
    String? stagedRelativePath,
    String? transientFilePath,
    String? finalRelativePath,
    String? checksumSha256,
    int? byteLength,
    String? originDeviceId,
    DateTime? createdAt,
    DateTime? issuedAt,
    Value<String?> mimeType = const Value.absent(),
    Value<int?> durationMs = const Value.absent(),
    Value<String?> transcript = const Value.absent(),
    Value<int?> widthPixels = const Value.absent(),
    Value<int?> heightPixels = const Value.absent(),
    Value<String?> originalExtension = const Value.absent(),
    Value<int?> orientation = const Value.absent(),
    Value<String?> colorSpace = const Value.absent(),
    Value<bool?> isHdr = const Value.absent(),
    Value<DateTime?> quarantinedAt = const Value.absent(),
    Value<String?> failureReason = const Value.absent(),
  }) => MediaPromotionRow(
    operationId: operationId ?? this.operationId,
    commandId: commandId ?? this.commandId,
    mediaId: mediaId ?? this.mediaId,
    sessionId: sessionId ?? this.sessionId,
    roomNumber: roomNumber.present ? roomNumber.value : this.roomNumber,
    assignmentId: assignmentId.present ? assignmentId.value : this.assignmentId,
    kind: kind ?? this.kind,
    stagedRelativePath: stagedRelativePath ?? this.stagedRelativePath,
    transientFilePath: transientFilePath ?? this.transientFilePath,
    finalRelativePath: finalRelativePath ?? this.finalRelativePath,
    checksumSha256: checksumSha256 ?? this.checksumSha256,
    byteLength: byteLength ?? this.byteLength,
    originDeviceId: originDeviceId ?? this.originDeviceId,
    createdAt: createdAt ?? this.createdAt,
    issuedAt: issuedAt ?? this.issuedAt,
    mimeType: mimeType.present ? mimeType.value : this.mimeType,
    durationMs: durationMs.present ? durationMs.value : this.durationMs,
    transcript: transcript.present ? transcript.value : this.transcript,
    widthPixels: widthPixels.present ? widthPixels.value : this.widthPixels,
    heightPixels: heightPixels.present ? heightPixels.value : this.heightPixels,
    originalExtension: originalExtension.present
        ? originalExtension.value
        : this.originalExtension,
    orientation: orientation.present ? orientation.value : this.orientation,
    colorSpace: colorSpace.present ? colorSpace.value : this.colorSpace,
    isHdr: isHdr.present ? isHdr.value : this.isHdr,
    quarantinedAt: quarantinedAt.present
        ? quarantinedAt.value
        : this.quarantinedAt,
    failureReason: failureReason.present
        ? failureReason.value
        : this.failureReason,
  );
  MediaPromotionRow copyWithCompanion(MediaPromotionRecordsCompanion data) {
    return MediaPromotionRow(
      operationId: data.operationId.present
          ? data.operationId.value
          : this.operationId,
      commandId: data.commandId.present ? data.commandId.value : this.commandId,
      mediaId: data.mediaId.present ? data.mediaId.value : this.mediaId,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      roomNumber: data.roomNumber.present
          ? data.roomNumber.value
          : this.roomNumber,
      assignmentId: data.assignmentId.present
          ? data.assignmentId.value
          : this.assignmentId,
      kind: data.kind.present ? data.kind.value : this.kind,
      stagedRelativePath: data.stagedRelativePath.present
          ? data.stagedRelativePath.value
          : this.stagedRelativePath,
      transientFilePath: data.transientFilePath.present
          ? data.transientFilePath.value
          : this.transientFilePath,
      finalRelativePath: data.finalRelativePath.present
          ? data.finalRelativePath.value
          : this.finalRelativePath,
      checksumSha256: data.checksumSha256.present
          ? data.checksumSha256.value
          : this.checksumSha256,
      byteLength: data.byteLength.present
          ? data.byteLength.value
          : this.byteLength,
      originDeviceId: data.originDeviceId.present
          ? data.originDeviceId.value
          : this.originDeviceId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      issuedAt: data.issuedAt.present ? data.issuedAt.value : this.issuedAt,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      transcript: data.transcript.present
          ? data.transcript.value
          : this.transcript,
      widthPixels: data.widthPixels.present
          ? data.widthPixels.value
          : this.widthPixels,
      heightPixels: data.heightPixels.present
          ? data.heightPixels.value
          : this.heightPixels,
      originalExtension: data.originalExtension.present
          ? data.originalExtension.value
          : this.originalExtension,
      orientation: data.orientation.present
          ? data.orientation.value
          : this.orientation,
      colorSpace: data.colorSpace.present
          ? data.colorSpace.value
          : this.colorSpace,
      isHdr: data.isHdr.present ? data.isHdr.value : this.isHdr,
      quarantinedAt: data.quarantinedAt.present
          ? data.quarantinedAt.value
          : this.quarantinedAt,
      failureReason: data.failureReason.present
          ? data.failureReason.value
          : this.failureReason,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MediaPromotionRow(')
          ..write('operationId: $operationId, ')
          ..write('commandId: $commandId, ')
          ..write('mediaId: $mediaId, ')
          ..write('sessionId: $sessionId, ')
          ..write('roomNumber: $roomNumber, ')
          ..write('assignmentId: $assignmentId, ')
          ..write('kind: $kind, ')
          ..write('stagedRelativePath: $stagedRelativePath, ')
          ..write('transientFilePath: $transientFilePath, ')
          ..write('finalRelativePath: $finalRelativePath, ')
          ..write('checksumSha256: $checksumSha256, ')
          ..write('byteLength: $byteLength, ')
          ..write('originDeviceId: $originDeviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('issuedAt: $issuedAt, ')
          ..write('mimeType: $mimeType, ')
          ..write('durationMs: $durationMs, ')
          ..write('transcript: $transcript, ')
          ..write('widthPixels: $widthPixels, ')
          ..write('heightPixels: $heightPixels, ')
          ..write('originalExtension: $originalExtension, ')
          ..write('orientation: $orientation, ')
          ..write('colorSpace: $colorSpace, ')
          ..write('isHdr: $isHdr, ')
          ..write('quarantinedAt: $quarantinedAt, ')
          ..write('failureReason: $failureReason')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    operationId,
    commandId,
    mediaId,
    sessionId,
    roomNumber,
    assignmentId,
    kind,
    stagedRelativePath,
    transientFilePath,
    finalRelativePath,
    checksumSha256,
    byteLength,
    originDeviceId,
    createdAt,
    issuedAt,
    mimeType,
    durationMs,
    transcript,
    widthPixels,
    heightPixels,
    originalExtension,
    orientation,
    colorSpace,
    isHdr,
    quarantinedAt,
    failureReason,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MediaPromotionRow &&
          other.operationId == this.operationId &&
          other.commandId == this.commandId &&
          other.mediaId == this.mediaId &&
          other.sessionId == this.sessionId &&
          other.roomNumber == this.roomNumber &&
          other.assignmentId == this.assignmentId &&
          other.kind == this.kind &&
          other.stagedRelativePath == this.stagedRelativePath &&
          other.transientFilePath == this.transientFilePath &&
          other.finalRelativePath == this.finalRelativePath &&
          other.checksumSha256 == this.checksumSha256 &&
          other.byteLength == this.byteLength &&
          other.originDeviceId == this.originDeviceId &&
          other.createdAt == this.createdAt &&
          other.issuedAt == this.issuedAt &&
          other.mimeType == this.mimeType &&
          other.durationMs == this.durationMs &&
          other.transcript == this.transcript &&
          other.widthPixels == this.widthPixels &&
          other.heightPixels == this.heightPixels &&
          other.originalExtension == this.originalExtension &&
          other.orientation == this.orientation &&
          other.colorSpace == this.colorSpace &&
          other.isHdr == this.isHdr &&
          other.quarantinedAt == this.quarantinedAt &&
          other.failureReason == this.failureReason);
}

class MediaPromotionRecordsCompanion
    extends UpdateCompanion<MediaPromotionRow> {
  final Value<String> operationId;
  final Value<String> commandId;
  final Value<String> mediaId;
  final Value<String> sessionId;
  final Value<String?> roomNumber;
  final Value<String?> assignmentId;
  final Value<String> kind;
  final Value<String> stagedRelativePath;
  final Value<String> transientFilePath;
  final Value<String> finalRelativePath;
  final Value<String> checksumSha256;
  final Value<int> byteLength;
  final Value<String> originDeviceId;
  final Value<DateTime> createdAt;
  final Value<DateTime> issuedAt;
  final Value<String?> mimeType;
  final Value<int?> durationMs;
  final Value<String?> transcript;
  final Value<int?> widthPixels;
  final Value<int?> heightPixels;
  final Value<String?> originalExtension;
  final Value<int?> orientation;
  final Value<String?> colorSpace;
  final Value<bool?> isHdr;
  final Value<DateTime?> quarantinedAt;
  final Value<String?> failureReason;
  final Value<int> rowid;
  const MediaPromotionRecordsCompanion({
    this.operationId = const Value.absent(),
    this.commandId = const Value.absent(),
    this.mediaId = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.roomNumber = const Value.absent(),
    this.assignmentId = const Value.absent(),
    this.kind = const Value.absent(),
    this.stagedRelativePath = const Value.absent(),
    this.transientFilePath = const Value.absent(),
    this.finalRelativePath = const Value.absent(),
    this.checksumSha256 = const Value.absent(),
    this.byteLength = const Value.absent(),
    this.originDeviceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.issuedAt = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.transcript = const Value.absent(),
    this.widthPixels = const Value.absent(),
    this.heightPixels = const Value.absent(),
    this.originalExtension = const Value.absent(),
    this.orientation = const Value.absent(),
    this.colorSpace = const Value.absent(),
    this.isHdr = const Value.absent(),
    this.quarantinedAt = const Value.absent(),
    this.failureReason = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MediaPromotionRecordsCompanion.insert({
    required String operationId,
    required String commandId,
    required String mediaId,
    required String sessionId,
    this.roomNumber = const Value.absent(),
    this.assignmentId = const Value.absent(),
    required String kind,
    required String stagedRelativePath,
    required String transientFilePath,
    required String finalRelativePath,
    required String checksumSha256,
    required int byteLength,
    required String originDeviceId,
    required DateTime createdAt,
    required DateTime issuedAt,
    this.mimeType = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.transcript = const Value.absent(),
    this.widthPixels = const Value.absent(),
    this.heightPixels = const Value.absent(),
    this.originalExtension = const Value.absent(),
    this.orientation = const Value.absent(),
    this.colorSpace = const Value.absent(),
    this.isHdr = const Value.absent(),
    this.quarantinedAt = const Value.absent(),
    this.failureReason = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : operationId = Value(operationId),
       commandId = Value(commandId),
       mediaId = Value(mediaId),
       sessionId = Value(sessionId),
       kind = Value(kind),
       stagedRelativePath = Value(stagedRelativePath),
       transientFilePath = Value(transientFilePath),
       finalRelativePath = Value(finalRelativePath),
       checksumSha256 = Value(checksumSha256),
       byteLength = Value(byteLength),
       originDeviceId = Value(originDeviceId),
       createdAt = Value(createdAt),
       issuedAt = Value(issuedAt);
  static Insertable<MediaPromotionRow> custom({
    Expression<String>? operationId,
    Expression<String>? commandId,
    Expression<String>? mediaId,
    Expression<String>? sessionId,
    Expression<String>? roomNumber,
    Expression<String>? assignmentId,
    Expression<String>? kind,
    Expression<String>? stagedRelativePath,
    Expression<String>? transientFilePath,
    Expression<String>? finalRelativePath,
    Expression<String>? checksumSha256,
    Expression<int>? byteLength,
    Expression<String>? originDeviceId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? issuedAt,
    Expression<String>? mimeType,
    Expression<int>? durationMs,
    Expression<String>? transcript,
    Expression<int>? widthPixels,
    Expression<int>? heightPixels,
    Expression<String>? originalExtension,
    Expression<int>? orientation,
    Expression<String>? colorSpace,
    Expression<bool>? isHdr,
    Expression<DateTime>? quarantinedAt,
    Expression<String>? failureReason,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (operationId != null) 'operation_id': operationId,
      if (commandId != null) 'command_id': commandId,
      if (mediaId != null) 'media_id': mediaId,
      if (sessionId != null) 'session_id': sessionId,
      if (roomNumber != null) 'room_number': roomNumber,
      if (assignmentId != null) 'assignment_id': assignmentId,
      if (kind != null) 'kind': kind,
      if (stagedRelativePath != null)
        'staged_relative_path': stagedRelativePath,
      if (transientFilePath != null) 'transient_file_path': transientFilePath,
      if (finalRelativePath != null) 'final_relative_path': finalRelativePath,
      if (checksumSha256 != null) 'checksum_sha256': checksumSha256,
      if (byteLength != null) 'byte_length': byteLength,
      if (originDeviceId != null) 'origin_device_id': originDeviceId,
      if (createdAt != null) 'created_at': createdAt,
      if (issuedAt != null) 'issued_at': issuedAt,
      if (mimeType != null) 'mime_type': mimeType,
      if (durationMs != null) 'duration_ms': durationMs,
      if (transcript != null) 'transcript': transcript,
      if (widthPixels != null) 'width_pixels': widthPixels,
      if (heightPixels != null) 'height_pixels': heightPixels,
      if (originalExtension != null) 'original_extension': originalExtension,
      if (orientation != null) 'orientation': orientation,
      if (colorSpace != null) 'color_space': colorSpace,
      if (isHdr != null) 'is_hdr': isHdr,
      if (quarantinedAt != null) 'quarantined_at': quarantinedAt,
      if (failureReason != null) 'failure_reason': failureReason,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MediaPromotionRecordsCompanion copyWith({
    Value<String>? operationId,
    Value<String>? commandId,
    Value<String>? mediaId,
    Value<String>? sessionId,
    Value<String?>? roomNumber,
    Value<String?>? assignmentId,
    Value<String>? kind,
    Value<String>? stagedRelativePath,
    Value<String>? transientFilePath,
    Value<String>? finalRelativePath,
    Value<String>? checksumSha256,
    Value<int>? byteLength,
    Value<String>? originDeviceId,
    Value<DateTime>? createdAt,
    Value<DateTime>? issuedAt,
    Value<String?>? mimeType,
    Value<int?>? durationMs,
    Value<String?>? transcript,
    Value<int?>? widthPixels,
    Value<int?>? heightPixels,
    Value<String?>? originalExtension,
    Value<int?>? orientation,
    Value<String?>? colorSpace,
    Value<bool?>? isHdr,
    Value<DateTime?>? quarantinedAt,
    Value<String?>? failureReason,
    Value<int>? rowid,
  }) {
    return MediaPromotionRecordsCompanion(
      operationId: operationId ?? this.operationId,
      commandId: commandId ?? this.commandId,
      mediaId: mediaId ?? this.mediaId,
      sessionId: sessionId ?? this.sessionId,
      roomNumber: roomNumber ?? this.roomNumber,
      assignmentId: assignmentId ?? this.assignmentId,
      kind: kind ?? this.kind,
      stagedRelativePath: stagedRelativePath ?? this.stagedRelativePath,
      transientFilePath: transientFilePath ?? this.transientFilePath,
      finalRelativePath: finalRelativePath ?? this.finalRelativePath,
      checksumSha256: checksumSha256 ?? this.checksumSha256,
      byteLength: byteLength ?? this.byteLength,
      originDeviceId: originDeviceId ?? this.originDeviceId,
      createdAt: createdAt ?? this.createdAt,
      issuedAt: issuedAt ?? this.issuedAt,
      mimeType: mimeType ?? this.mimeType,
      durationMs: durationMs ?? this.durationMs,
      transcript: transcript ?? this.transcript,
      widthPixels: widthPixels ?? this.widthPixels,
      heightPixels: heightPixels ?? this.heightPixels,
      originalExtension: originalExtension ?? this.originalExtension,
      orientation: orientation ?? this.orientation,
      colorSpace: colorSpace ?? this.colorSpace,
      isHdr: isHdr ?? this.isHdr,
      quarantinedAt: quarantinedAt ?? this.quarantinedAt,
      failureReason: failureReason ?? this.failureReason,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (operationId.present) {
      map['operation_id'] = Variable<String>(operationId.value);
    }
    if (commandId.present) {
      map['command_id'] = Variable<String>(commandId.value);
    }
    if (mediaId.present) {
      map['media_id'] = Variable<String>(mediaId.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (roomNumber.present) {
      map['room_number'] = Variable<String>(roomNumber.value);
    }
    if (assignmentId.present) {
      map['assignment_id'] = Variable<String>(assignmentId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (stagedRelativePath.present) {
      map['staged_relative_path'] = Variable<String>(stagedRelativePath.value);
    }
    if (transientFilePath.present) {
      map['transient_file_path'] = Variable<String>(transientFilePath.value);
    }
    if (finalRelativePath.present) {
      map['final_relative_path'] = Variable<String>(finalRelativePath.value);
    }
    if (checksumSha256.present) {
      map['checksum_sha256'] = Variable<String>(checksumSha256.value);
    }
    if (byteLength.present) {
      map['byte_length'] = Variable<int>(byteLength.value);
    }
    if (originDeviceId.present) {
      map['origin_device_id'] = Variable<String>(originDeviceId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (issuedAt.present) {
      map['issued_at'] = Variable<DateTime>(issuedAt.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (transcript.present) {
      map['transcript'] = Variable<String>(transcript.value);
    }
    if (widthPixels.present) {
      map['width_pixels'] = Variable<int>(widthPixels.value);
    }
    if (heightPixels.present) {
      map['height_pixels'] = Variable<int>(heightPixels.value);
    }
    if (originalExtension.present) {
      map['original_extension'] = Variable<String>(originalExtension.value);
    }
    if (orientation.present) {
      map['orientation'] = Variable<int>(orientation.value);
    }
    if (colorSpace.present) {
      map['color_space'] = Variable<String>(colorSpace.value);
    }
    if (isHdr.present) {
      map['is_hdr'] = Variable<bool>(isHdr.value);
    }
    if (quarantinedAt.present) {
      map['quarantined_at'] = Variable<DateTime>(quarantinedAt.value);
    }
    if (failureReason.present) {
      map['failure_reason'] = Variable<String>(failureReason.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MediaPromotionRecordsCompanion(')
          ..write('operationId: $operationId, ')
          ..write('commandId: $commandId, ')
          ..write('mediaId: $mediaId, ')
          ..write('sessionId: $sessionId, ')
          ..write('roomNumber: $roomNumber, ')
          ..write('assignmentId: $assignmentId, ')
          ..write('kind: $kind, ')
          ..write('stagedRelativePath: $stagedRelativePath, ')
          ..write('transientFilePath: $transientFilePath, ')
          ..write('finalRelativePath: $finalRelativePath, ')
          ..write('checksumSha256: $checksumSha256, ')
          ..write('byteLength: $byteLength, ')
          ..write('originDeviceId: $originDeviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('issuedAt: $issuedAt, ')
          ..write('mimeType: $mimeType, ')
          ..write('durationMs: $durationMs, ')
          ..write('transcript: $transcript, ')
          ..write('widthPixels: $widthPixels, ')
          ..write('heightPixels: $heightPixels, ')
          ..write('originalExtension: $originalExtension, ')
          ..write('orientation: $orientation, ')
          ..write('colorSpace: $colorSpace, ')
          ..write('isHdr: $isHdr, ')
          ..write('quarantinedAt: $quarantinedAt, ')
          ..write('failureReason: $failureReason, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $HousekeeperCatalogRecordsTable housekeeperCatalogRecords =
      $HousekeeperCatalogRecordsTable(this);
  late final $WorkSessionRecordsTable workSessionRecords =
      $WorkSessionRecordsTable(this);
  late final $HousekeeperRecordsTable housekeeperRecords =
      $HousekeeperRecordsTable(this);
  late final $WorkAssignmentRecordsTable workAssignmentRecords =
      $WorkAssignmentRecordsTable(this);
  late final $RoomStateRecordsTable roomStateRecords = $RoomStateRecordsTable(
    this,
  );
  late final $RoomNoteRecordsTable roomNoteRecords = $RoomNoteRecordsTable(
    this,
  );
  late final $AssignmentNoteRecordsTable assignmentNoteRecords =
      $AssignmentNoteRecordsTable(this);
  late final $CartConsumableRecordsTable cartConsumableRecords =
      $CartConsumableRecordsTable(this);
  late final $HistoryEventRecordsTable historyEventRecords =
      $HistoryEventRecordsTable(this);
  late final $CommandReceiptRecordsTable commandReceiptRecords =
      $CommandReceiptRecordsTable(this);
  late final $SyncOutboxRecordsTable syncOutboxRecords =
      $SyncOutboxRecordsTable(this);
  late final $SyncInboxRecordsTable syncInboxRecords = $SyncInboxRecordsTable(
    this,
  );
  late final $MediaManifestRecordsTable mediaManifestRecords =
      $MediaManifestRecordsTable(this);
  late final $MediaPromotionRecordsTable mediaPromotionRecords =
      $MediaPromotionRecordsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    housekeeperCatalogRecords,
    workSessionRecords,
    housekeeperRecords,
    workAssignmentRecords,
    roomStateRecords,
    roomNoteRecords,
    assignmentNoteRecords,
    cartConsumableRecords,
    historyEventRecords,
    commandReceiptRecords,
    syncOutboxRecords,
    syncInboxRecords,
    mediaManifestRecords,
    mediaPromotionRecords,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'work_session_records',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('housekeeper_records', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'work_session_records',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('work_assignment_records', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'work_session_records',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('room_state_records', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'work_session_records',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('room_note_records', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'work_session_records',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('assignment_note_records', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'work_session_records',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('cart_consumable_records', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'work_session_records',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('history_event_records', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'work_session_records',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('command_receipt_records', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'work_session_records',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('sync_outbox_records', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'work_session_records',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('media_manifest_records', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'work_session_records',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('media_promotion_records', kind: UpdateKind.delete)],
    ),
  ]);
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$HousekeeperCatalogRecordsTableCreateCompanionBuilder =
    HousekeeperCatalogRecordsCompanion Function({
      required String id,
      required String displayName,
      required String paletteKey,
      required int sortOrder,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$HousekeeperCatalogRecordsTableUpdateCompanionBuilder =
    HousekeeperCatalogRecordsCompanion Function({
      Value<String> id,
      Value<String> displayName,
      Value<String> paletteKey,
      Value<int> sortOrder,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

class $$HousekeeperCatalogRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $HousekeeperCatalogRecordsTable> {
  $$HousekeeperCatalogRecordsTableFilterComposer({
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

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paletteKey => $composableBuilder(
    column: $table.paletteKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HousekeeperCatalogRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $HousekeeperCatalogRecordsTable> {
  $$HousekeeperCatalogRecordsTableOrderingComposer({
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

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paletteKey => $composableBuilder(
    column: $table.paletteKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HousekeeperCatalogRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HousekeeperCatalogRecordsTable> {
  $$HousekeeperCatalogRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paletteKey => $composableBuilder(
    column: $table.paletteKey,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$HousekeeperCatalogRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HousekeeperCatalogRecordsTable,
          HousekeeperCatalogRow,
          $$HousekeeperCatalogRecordsTableFilterComposer,
          $$HousekeeperCatalogRecordsTableOrderingComposer,
          $$HousekeeperCatalogRecordsTableAnnotationComposer,
          $$HousekeeperCatalogRecordsTableCreateCompanionBuilder,
          $$HousekeeperCatalogRecordsTableUpdateCompanionBuilder,
          (
            HousekeeperCatalogRow,
            BaseReferences<
              _$AppDatabase,
              $HousekeeperCatalogRecordsTable,
              HousekeeperCatalogRow
            >,
          ),
          HousekeeperCatalogRow,
          PrefetchHooks Function()
        > {
  $$HousekeeperCatalogRecordsTableTableManager(
    _$AppDatabase db,
    $HousekeeperCatalogRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HousekeeperCatalogRecordsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$HousekeeperCatalogRecordsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$HousekeeperCatalogRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String> paletteKey = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HousekeeperCatalogRecordsCompanion(
                id: id,
                displayName: displayName,
                paletteKey: paletteKey,
                sortOrder: sortOrder,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String displayName,
                required String paletteKey,
                required int sortOrder,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HousekeeperCatalogRecordsCompanion.insert(
                id: id,
                displayName: displayName,
                paletteKey: paletteKey,
                sortOrder: sortOrder,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HousekeeperCatalogRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HousekeeperCatalogRecordsTable,
      HousekeeperCatalogRow,
      $$HousekeeperCatalogRecordsTableFilterComposer,
      $$HousekeeperCatalogRecordsTableOrderingComposer,
      $$HousekeeperCatalogRecordsTableAnnotationComposer,
      $$HousekeeperCatalogRecordsTableCreateCompanionBuilder,
      $$HousekeeperCatalogRecordsTableUpdateCompanionBuilder,
      (
        HousekeeperCatalogRow,
        BaseReferences<
          _$AppDatabase,
          $HousekeeperCatalogRecordsTable,
          HousekeeperCatalogRow
        >,
      ),
      HousekeeperCatalogRow,
      PrefetchHooks Function()
    >;
typedef $$WorkSessionRecordsTableCreateCompanionBuilder =
    WorkSessionRecordsCompanion Function({
      required String id,
      required int canonicalSchemaVersion,
      required String hotelId,
      required String hotelName,
      required String workflow,
      required DateTime startedAt,
      required DateTime updatedAt,
      Value<bool> workdayLocked,
      Value<DateTime?> lockUpdatedAt,
      Value<int> rowid,
    });
typedef $$WorkSessionRecordsTableUpdateCompanionBuilder =
    WorkSessionRecordsCompanion Function({
      Value<String> id,
      Value<int> canonicalSchemaVersion,
      Value<String> hotelId,
      Value<String> hotelName,
      Value<String> workflow,
      Value<DateTime> startedAt,
      Value<DateTime> updatedAt,
      Value<bool> workdayLocked,
      Value<DateTime?> lockUpdatedAt,
      Value<int> rowid,
    });

final class $$WorkSessionRecordsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $WorkSessionRecordsTable,
          WorkSessionRow
        > {
  $$WorkSessionRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$HousekeeperRecordsTable, List<HousekeeperRow>>
  _housekeeperRecordsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.housekeeperRecords,
        aliasName: 'work_session_records__id__housekeeper_records__session_id',
      );

  $$HousekeeperRecordsTableProcessedTableManager get housekeeperRecordsRefs {
    final manager = $$HousekeeperRecordsTableTableManager(
      $_db,
      $_db.housekeeperRecords,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _housekeeperRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $WorkAssignmentRecordsTable,
    List<WorkAssignmentRow>
  >
  _workAssignmentRecordsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.workAssignmentRecords,
        aliasName:
            'work_session_records__id__work_assignment_records__session_id',
      );

  $$WorkAssignmentRecordsTableProcessedTableManager
  get workAssignmentRecordsRefs {
    final manager = $$WorkAssignmentRecordsTableTableManager(
      $_db,
      $_db.workAssignmentRecords,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _workAssignmentRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RoomStateRecordsTable, List<RoomStateRow>>
  _roomStateRecordsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.roomStateRecords,
    aliasName: 'work_session_records__id__room_state_records__session_id',
  );

  $$RoomStateRecordsTableProcessedTableManager get roomStateRecordsRefs {
    final manager = $$RoomStateRecordsTableTableManager(
      $_db,
      $_db.roomStateRecords,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _roomStateRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RoomNoteRecordsTable, List<RoomNoteRow>>
  _roomNoteRecordsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.roomNoteRecords,
    aliasName: 'work_session_records__id__room_note_records__session_id',
  );

  $$RoomNoteRecordsTableProcessedTableManager get roomNoteRecordsRefs {
    final manager = $$RoomNoteRecordsTableTableManager(
      $_db,
      $_db.roomNoteRecords,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _roomNoteRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $AssignmentNoteRecordsTable,
    List<AssignmentNoteRow>
  >
  _assignmentNoteRecordsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.assignmentNoteRecords,
        aliasName:
            'work_session_records__id__assignment_note_records__session_id',
      );

  $$AssignmentNoteRecordsTableProcessedTableManager
  get assignmentNoteRecordsRefs {
    final manager = $$AssignmentNoteRecordsTableTableManager(
      $_db,
      $_db.assignmentNoteRecords,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _assignmentNoteRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $CartConsumableRecordsTable,
    List<CartConsumableRow>
  >
  _cartConsumableRecordsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.cartConsumableRecords,
        aliasName:
            'work_session_records__id__cart_consumable_records__session_id',
      );

  $$CartConsumableRecordsTableProcessedTableManager
  get cartConsumableRecordsRefs {
    final manager = $$CartConsumableRecordsTableTableManager(
      $_db,
      $_db.cartConsumableRecords,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _cartConsumableRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$HistoryEventRecordsTable, List<HistoryEventRow>>
  _historyEventRecordsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.historyEventRecords,
        aliasName:
            'work_session_records__id__history_event_records__session_id',
      );

  $$HistoryEventRecordsTableProcessedTableManager get historyEventRecordsRefs {
    final manager = $$HistoryEventRecordsTableTableManager(
      $_db,
      $_db.historyEventRecords,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _historyEventRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $CommandReceiptRecordsTable,
    List<CommandReceiptRow>
  >
  _commandReceiptRecordsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.commandReceiptRecords,
        aliasName:
            'work_session_records__id__command_receipt_records__session_id',
      );

  $$CommandReceiptRecordsTableProcessedTableManager
  get commandReceiptRecordsRefs {
    final manager = $$CommandReceiptRecordsTableTableManager(
      $_db,
      $_db.commandReceiptRecords,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _commandReceiptRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SyncOutboxRecordsTable, List<SyncOutboxRow>>
  _syncOutboxRecordsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.syncOutboxRecords,
        aliasName: 'work_session_records__id__sync_outbox_records__session_id',
      );

  $$SyncOutboxRecordsTableProcessedTableManager get syncOutboxRecordsRefs {
    final manager = $$SyncOutboxRecordsTableTableManager(
      $_db,
      $_db.syncOutboxRecords,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _syncOutboxRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MediaManifestRecordsTable, List<MediaManifestRow>>
  _mediaManifestRecordsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.mediaManifestRecords,
        aliasName:
            'work_session_records__id__media_manifest_records__session_id',
      );

  $$MediaManifestRecordsTableProcessedTableManager
  get mediaManifestRecordsRefs {
    final manager = $$MediaManifestRecordsTableTableManager(
      $_db,
      $_db.mediaManifestRecords,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _mediaManifestRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $MediaPromotionRecordsTable,
    List<MediaPromotionRow>
  >
  _mediaPromotionRecordsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.mediaPromotionRecords,
        aliasName:
            'work_session_records__id__media_promotion_records__session_id',
      );

  $$MediaPromotionRecordsTableProcessedTableManager
  get mediaPromotionRecordsRefs {
    final manager = $$MediaPromotionRecordsTableTableManager(
      $_db,
      $_db.mediaPromotionRecords,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _mediaPromotionRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WorkSessionRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkSessionRecordsTable> {
  $$WorkSessionRecordsTableFilterComposer({
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

  ColumnFilters<int> get canonicalSchemaVersion => $composableBuilder(
    column: $table.canonicalSchemaVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hotelId => $composableBuilder(
    column: $table.hotelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hotelName => $composableBuilder(
    column: $table.hotelName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workflow => $composableBuilder(
    column: $table.workflow,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get workdayLocked => $composableBuilder(
    column: $table.workdayLocked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lockUpdatedAt => $composableBuilder(
    column: $table.lockUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> housekeeperRecordsRefs(
    Expression<bool> Function($$HousekeeperRecordsTableFilterComposer f) f,
  ) {
    final $$HousekeeperRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.housekeeperRecords,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HousekeeperRecordsTableFilterComposer(
            $db: $db,
            $table: $db.housekeeperRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> workAssignmentRecordsRefs(
    Expression<bool> Function($$WorkAssignmentRecordsTableFilterComposer f) f,
  ) {
    final $$WorkAssignmentRecordsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.workAssignmentRecords,
          getReferencedColumn: (t) => t.sessionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkAssignmentRecordsTableFilterComposer(
                $db: $db,
                $table: $db.workAssignmentRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> roomStateRecordsRefs(
    Expression<bool> Function($$RoomStateRecordsTableFilterComposer f) f,
  ) {
    final $$RoomStateRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.roomStateRecords,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoomStateRecordsTableFilterComposer(
            $db: $db,
            $table: $db.roomStateRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> roomNoteRecordsRefs(
    Expression<bool> Function($$RoomNoteRecordsTableFilterComposer f) f,
  ) {
    final $$RoomNoteRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.roomNoteRecords,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoomNoteRecordsTableFilterComposer(
            $db: $db,
            $table: $db.roomNoteRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> assignmentNoteRecordsRefs(
    Expression<bool> Function($$AssignmentNoteRecordsTableFilterComposer f) f,
  ) {
    final $$AssignmentNoteRecordsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.assignmentNoteRecords,
          getReferencedColumn: (t) => t.sessionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AssignmentNoteRecordsTableFilterComposer(
                $db: $db,
                $table: $db.assignmentNoteRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> cartConsumableRecordsRefs(
    Expression<bool> Function($$CartConsumableRecordsTableFilterComposer f) f,
  ) {
    final $$CartConsumableRecordsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.cartConsumableRecords,
          getReferencedColumn: (t) => t.sessionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CartConsumableRecordsTableFilterComposer(
                $db: $db,
                $table: $db.cartConsumableRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> historyEventRecordsRefs(
    Expression<bool> Function($$HistoryEventRecordsTableFilterComposer f) f,
  ) {
    final $$HistoryEventRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.historyEventRecords,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HistoryEventRecordsTableFilterComposer(
            $db: $db,
            $table: $db.historyEventRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> commandReceiptRecordsRefs(
    Expression<bool> Function($$CommandReceiptRecordsTableFilterComposer f) f,
  ) {
    final $$CommandReceiptRecordsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.commandReceiptRecords,
          getReferencedColumn: (t) => t.sessionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CommandReceiptRecordsTableFilterComposer(
                $db: $db,
                $table: $db.commandReceiptRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> syncOutboxRecordsRefs(
    Expression<bool> Function($$SyncOutboxRecordsTableFilterComposer f) f,
  ) {
    final $$SyncOutboxRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.syncOutboxRecords,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncOutboxRecordsTableFilterComposer(
            $db: $db,
            $table: $db.syncOutboxRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> mediaManifestRecordsRefs(
    Expression<bool> Function($$MediaManifestRecordsTableFilterComposer f) f,
  ) {
    final $$MediaManifestRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mediaManifestRecords,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaManifestRecordsTableFilterComposer(
            $db: $db,
            $table: $db.mediaManifestRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> mediaPromotionRecordsRefs(
    Expression<bool> Function($$MediaPromotionRecordsTableFilterComposer f) f,
  ) {
    final $$MediaPromotionRecordsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.mediaPromotionRecords,
          getReferencedColumn: (t) => t.sessionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MediaPromotionRecordsTableFilterComposer(
                $db: $db,
                $table: $db.mediaPromotionRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$WorkSessionRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkSessionRecordsTable> {
  $$WorkSessionRecordsTableOrderingComposer({
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

  ColumnOrderings<int> get canonicalSchemaVersion => $composableBuilder(
    column: $table.canonicalSchemaVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hotelId => $composableBuilder(
    column: $table.hotelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hotelName => $composableBuilder(
    column: $table.hotelName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workflow => $composableBuilder(
    column: $table.workflow,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get workdayLocked => $composableBuilder(
    column: $table.workdayLocked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lockUpdatedAt => $composableBuilder(
    column: $table.lockUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkSessionRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkSessionRecordsTable> {
  $$WorkSessionRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get canonicalSchemaVersion => $composableBuilder(
    column: $table.canonicalSchemaVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get hotelId =>
      $composableBuilder(column: $table.hotelId, builder: (column) => column);

  GeneratedColumn<String> get hotelName =>
      $composableBuilder(column: $table.hotelName, builder: (column) => column);

  GeneratedColumn<String> get workflow =>
      $composableBuilder(column: $table.workflow, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get workdayLocked => $composableBuilder(
    column: $table.workdayLocked,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lockUpdatedAt => $composableBuilder(
    column: $table.lockUpdatedAt,
    builder: (column) => column,
  );

  Expression<T> housekeeperRecordsRefs<T extends Object>(
    Expression<T> Function($$HousekeeperRecordsTableAnnotationComposer a) f,
  ) {
    final $$HousekeeperRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.housekeeperRecords,
          getReferencedColumn: (t) => t.sessionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$HousekeeperRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.housekeeperRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> workAssignmentRecordsRefs<T extends Object>(
    Expression<T> Function($$WorkAssignmentRecordsTableAnnotationComposer a) f,
  ) {
    final $$WorkAssignmentRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.workAssignmentRecords,
          getReferencedColumn: (t) => t.sessionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkAssignmentRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.workAssignmentRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> roomStateRecordsRefs<T extends Object>(
    Expression<T> Function($$RoomStateRecordsTableAnnotationComposer a) f,
  ) {
    final $$RoomStateRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.roomStateRecords,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoomStateRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.roomStateRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> roomNoteRecordsRefs<T extends Object>(
    Expression<T> Function($$RoomNoteRecordsTableAnnotationComposer a) f,
  ) {
    final $$RoomNoteRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.roomNoteRecords,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoomNoteRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.roomNoteRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> assignmentNoteRecordsRefs<T extends Object>(
    Expression<T> Function($$AssignmentNoteRecordsTableAnnotationComposer a) f,
  ) {
    final $$AssignmentNoteRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.assignmentNoteRecords,
          getReferencedColumn: (t) => t.sessionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AssignmentNoteRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.assignmentNoteRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> cartConsumableRecordsRefs<T extends Object>(
    Expression<T> Function($$CartConsumableRecordsTableAnnotationComposer a) f,
  ) {
    final $$CartConsumableRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.cartConsumableRecords,
          getReferencedColumn: (t) => t.sessionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CartConsumableRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.cartConsumableRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> historyEventRecordsRefs<T extends Object>(
    Expression<T> Function($$HistoryEventRecordsTableAnnotationComposer a) f,
  ) {
    final $$HistoryEventRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.historyEventRecords,
          getReferencedColumn: (t) => t.sessionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$HistoryEventRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.historyEventRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> commandReceiptRecordsRefs<T extends Object>(
    Expression<T> Function($$CommandReceiptRecordsTableAnnotationComposer a) f,
  ) {
    final $$CommandReceiptRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.commandReceiptRecords,
          getReferencedColumn: (t) => t.sessionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CommandReceiptRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.commandReceiptRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> syncOutboxRecordsRefs<T extends Object>(
    Expression<T> Function($$SyncOutboxRecordsTableAnnotationComposer a) f,
  ) {
    final $$SyncOutboxRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.syncOutboxRecords,
          getReferencedColumn: (t) => t.sessionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SyncOutboxRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.syncOutboxRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> mediaManifestRecordsRefs<T extends Object>(
    Expression<T> Function($$MediaManifestRecordsTableAnnotationComposer a) f,
  ) {
    final $$MediaManifestRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.mediaManifestRecords,
          getReferencedColumn: (t) => t.sessionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MediaManifestRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.mediaManifestRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> mediaPromotionRecordsRefs<T extends Object>(
    Expression<T> Function($$MediaPromotionRecordsTableAnnotationComposer a) f,
  ) {
    final $$MediaPromotionRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.mediaPromotionRecords,
          getReferencedColumn: (t) => t.sessionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MediaPromotionRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.mediaPromotionRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$WorkSessionRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkSessionRecordsTable,
          WorkSessionRow,
          $$WorkSessionRecordsTableFilterComposer,
          $$WorkSessionRecordsTableOrderingComposer,
          $$WorkSessionRecordsTableAnnotationComposer,
          $$WorkSessionRecordsTableCreateCompanionBuilder,
          $$WorkSessionRecordsTableUpdateCompanionBuilder,
          (WorkSessionRow, $$WorkSessionRecordsTableReferences),
          WorkSessionRow,
          PrefetchHooks Function({
            bool housekeeperRecordsRefs,
            bool workAssignmentRecordsRefs,
            bool roomStateRecordsRefs,
            bool roomNoteRecordsRefs,
            bool assignmentNoteRecordsRefs,
            bool cartConsumableRecordsRefs,
            bool historyEventRecordsRefs,
            bool commandReceiptRecordsRefs,
            bool syncOutboxRecordsRefs,
            bool mediaManifestRecordsRefs,
            bool mediaPromotionRecordsRefs,
          })
        > {
  $$WorkSessionRecordsTableTableManager(
    _$AppDatabase db,
    $WorkSessionRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkSessionRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkSessionRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkSessionRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> canonicalSchemaVersion = const Value.absent(),
                Value<String> hotelId = const Value.absent(),
                Value<String> hotelName = const Value.absent(),
                Value<String> workflow = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> workdayLocked = const Value.absent(),
                Value<DateTime?> lockUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkSessionRecordsCompanion(
                id: id,
                canonicalSchemaVersion: canonicalSchemaVersion,
                hotelId: hotelId,
                hotelName: hotelName,
                workflow: workflow,
                startedAt: startedAt,
                updatedAt: updatedAt,
                workdayLocked: workdayLocked,
                lockUpdatedAt: lockUpdatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int canonicalSchemaVersion,
                required String hotelId,
                required String hotelName,
                required String workflow,
                required DateTime startedAt,
                required DateTime updatedAt,
                Value<bool> workdayLocked = const Value.absent(),
                Value<DateTime?> lockUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkSessionRecordsCompanion.insert(
                id: id,
                canonicalSchemaVersion: canonicalSchemaVersion,
                hotelId: hotelId,
                hotelName: hotelName,
                workflow: workflow,
                startedAt: startedAt,
                updatedAt: updatedAt,
                workdayLocked: workdayLocked,
                lockUpdatedAt: lockUpdatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WorkSessionRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                housekeeperRecordsRefs = false,
                workAssignmentRecordsRefs = false,
                roomStateRecordsRefs = false,
                roomNoteRecordsRefs = false,
                assignmentNoteRecordsRefs = false,
                cartConsumableRecordsRefs = false,
                historyEventRecordsRefs = false,
                commandReceiptRecordsRefs = false,
                syncOutboxRecordsRefs = false,
                mediaManifestRecordsRefs = false,
                mediaPromotionRecordsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (housekeeperRecordsRefs) db.housekeeperRecords,
                    if (workAssignmentRecordsRefs) db.workAssignmentRecords,
                    if (roomStateRecordsRefs) db.roomStateRecords,
                    if (roomNoteRecordsRefs) db.roomNoteRecords,
                    if (assignmentNoteRecordsRefs) db.assignmentNoteRecords,
                    if (cartConsumableRecordsRefs) db.cartConsumableRecords,
                    if (historyEventRecordsRefs) db.historyEventRecords,
                    if (commandReceiptRecordsRefs) db.commandReceiptRecords,
                    if (syncOutboxRecordsRefs) db.syncOutboxRecords,
                    if (mediaManifestRecordsRefs) db.mediaManifestRecords,
                    if (mediaPromotionRecordsRefs) db.mediaPromotionRecords,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (housekeeperRecordsRefs)
                        await $_getPrefetchedData<
                          WorkSessionRow,
                          $WorkSessionRecordsTable,
                          HousekeeperRow
                        >(
                          currentTable: table,
                          referencedTable: $$WorkSessionRecordsTableReferences
                              ._housekeeperRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkSessionRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).housekeeperRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (workAssignmentRecordsRefs)
                        await $_getPrefetchedData<
                          WorkSessionRow,
                          $WorkSessionRecordsTable,
                          WorkAssignmentRow
                        >(
                          currentTable: table,
                          referencedTable: $$WorkSessionRecordsTableReferences
                              ._workAssignmentRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkSessionRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).workAssignmentRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (roomStateRecordsRefs)
                        await $_getPrefetchedData<
                          WorkSessionRow,
                          $WorkSessionRecordsTable,
                          RoomStateRow
                        >(
                          currentTable: table,
                          referencedTable: $$WorkSessionRecordsTableReferences
                              ._roomStateRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkSessionRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).roomStateRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (roomNoteRecordsRefs)
                        await $_getPrefetchedData<
                          WorkSessionRow,
                          $WorkSessionRecordsTable,
                          RoomNoteRow
                        >(
                          currentTable: table,
                          referencedTable: $$WorkSessionRecordsTableReferences
                              ._roomNoteRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkSessionRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).roomNoteRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (assignmentNoteRecordsRefs)
                        await $_getPrefetchedData<
                          WorkSessionRow,
                          $WorkSessionRecordsTable,
                          AssignmentNoteRow
                        >(
                          currentTable: table,
                          referencedTable: $$WorkSessionRecordsTableReferences
                              ._assignmentNoteRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkSessionRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).assignmentNoteRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (cartConsumableRecordsRefs)
                        await $_getPrefetchedData<
                          WorkSessionRow,
                          $WorkSessionRecordsTable,
                          CartConsumableRow
                        >(
                          currentTable: table,
                          referencedTable: $$WorkSessionRecordsTableReferences
                              ._cartConsumableRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkSessionRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).cartConsumableRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (historyEventRecordsRefs)
                        await $_getPrefetchedData<
                          WorkSessionRow,
                          $WorkSessionRecordsTable,
                          HistoryEventRow
                        >(
                          currentTable: table,
                          referencedTable: $$WorkSessionRecordsTableReferences
                              ._historyEventRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkSessionRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).historyEventRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (commandReceiptRecordsRefs)
                        await $_getPrefetchedData<
                          WorkSessionRow,
                          $WorkSessionRecordsTable,
                          CommandReceiptRow
                        >(
                          currentTable: table,
                          referencedTable: $$WorkSessionRecordsTableReferences
                              ._commandReceiptRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkSessionRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).commandReceiptRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (syncOutboxRecordsRefs)
                        await $_getPrefetchedData<
                          WorkSessionRow,
                          $WorkSessionRecordsTable,
                          SyncOutboxRow
                        >(
                          currentTable: table,
                          referencedTable: $$WorkSessionRecordsTableReferences
                              ._syncOutboxRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkSessionRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).syncOutboxRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (mediaManifestRecordsRefs)
                        await $_getPrefetchedData<
                          WorkSessionRow,
                          $WorkSessionRecordsTable,
                          MediaManifestRow
                        >(
                          currentTable: table,
                          referencedTable: $$WorkSessionRecordsTableReferences
                              ._mediaManifestRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkSessionRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).mediaManifestRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (mediaPromotionRecordsRefs)
                        await $_getPrefetchedData<
                          WorkSessionRow,
                          $WorkSessionRecordsTable,
                          MediaPromotionRow
                        >(
                          currentTable: table,
                          referencedTable: $$WorkSessionRecordsTableReferences
                              ._mediaPromotionRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkSessionRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).mediaPromotionRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
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

typedef $$WorkSessionRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkSessionRecordsTable,
      WorkSessionRow,
      $$WorkSessionRecordsTableFilterComposer,
      $$WorkSessionRecordsTableOrderingComposer,
      $$WorkSessionRecordsTableAnnotationComposer,
      $$WorkSessionRecordsTableCreateCompanionBuilder,
      $$WorkSessionRecordsTableUpdateCompanionBuilder,
      (WorkSessionRow, $$WorkSessionRecordsTableReferences),
      WorkSessionRow,
      PrefetchHooks Function({
        bool housekeeperRecordsRefs,
        bool workAssignmentRecordsRefs,
        bool roomStateRecordsRefs,
        bool roomNoteRecordsRefs,
        bool assignmentNoteRecordsRefs,
        bool cartConsumableRecordsRefs,
        bool historyEventRecordsRefs,
        bool commandReceiptRecordsRefs,
        bool syncOutboxRecordsRefs,
        bool mediaManifestRecordsRefs,
        bool mediaPromotionRecordsRefs,
      })
    >;
typedef $$HousekeeperRecordsTableCreateCompanionBuilder =
    HousekeeperRecordsCompanion Function({
      required String sessionId,
      required String id,
      required String displayName,
      required String paletteKey,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$HousekeeperRecordsTableUpdateCompanionBuilder =
    HousekeeperRecordsCompanion Function({
      Value<String> sessionId,
      Value<String> id,
      Value<String> displayName,
      Value<String> paletteKey,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$HousekeeperRecordsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $HousekeeperRecordsTable,
          HousekeeperRow
        > {
  $$HousekeeperRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WorkSessionRecordsTable _sessionIdTable(_$AppDatabase db) => db
      .workSessionRecords
      .createAlias('housekeeper_records__session_id__work_session_records__id');

  $$WorkSessionRecordsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$WorkSessionRecordsTableTableManager(
      $_db,
      $_db.workSessionRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$HousekeeperRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $HousekeeperRecordsTable> {
  $$HousekeeperRecordsTableFilterComposer({
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

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paletteKey => $composableBuilder(
    column: $table.paletteKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkSessionRecordsTableFilterComposer get sessionId {
    final $$WorkSessionRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.workSessionRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkSessionRecordsTableFilterComposer(
            $db: $db,
            $table: $db.workSessionRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HousekeeperRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $HousekeeperRecordsTable> {
  $$HousekeeperRecordsTableOrderingComposer({
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

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paletteKey => $composableBuilder(
    column: $table.paletteKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkSessionRecordsTableOrderingComposer get sessionId {
    final $$WorkSessionRecordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.workSessionRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkSessionRecordsTableOrderingComposer(
            $db: $db,
            $table: $db.workSessionRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HousekeeperRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HousekeeperRecordsTable> {
  $$HousekeeperRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paletteKey => $composableBuilder(
    column: $table.paletteKey,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$WorkSessionRecordsTableAnnotationComposer get sessionId {
    final $$WorkSessionRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.sessionId,
          referencedTable: $db.workSessionRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkSessionRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.workSessionRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$HousekeeperRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HousekeeperRecordsTable,
          HousekeeperRow,
          $$HousekeeperRecordsTableFilterComposer,
          $$HousekeeperRecordsTableOrderingComposer,
          $$HousekeeperRecordsTableAnnotationComposer,
          $$HousekeeperRecordsTableCreateCompanionBuilder,
          $$HousekeeperRecordsTableUpdateCompanionBuilder,
          (HousekeeperRow, $$HousekeeperRecordsTableReferences),
          HousekeeperRow,
          PrefetchHooks Function({bool sessionId})
        > {
  $$HousekeeperRecordsTableTableManager(
    _$AppDatabase db,
    $HousekeeperRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HousekeeperRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HousekeeperRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HousekeeperRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> sessionId = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String> paletteKey = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HousekeeperRecordsCompanion(
                sessionId: sessionId,
                id: id,
                displayName: displayName,
                paletteKey: paletteKey,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sessionId,
                required String id,
                required String displayName,
                required String paletteKey,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HousekeeperRecordsCompanion.insert(
                sessionId: sessionId,
                id: id,
                displayName: displayName,
                paletteKey: paletteKey,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$HousekeeperRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
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
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable:
                                    $$HousekeeperRecordsTableReferences
                                        ._sessionIdTable(db),
                                referencedColumn:
                                    $$HousekeeperRecordsTableReferences
                                        ._sessionIdTable(db)
                                        .id,
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

typedef $$HousekeeperRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HousekeeperRecordsTable,
      HousekeeperRow,
      $$HousekeeperRecordsTableFilterComposer,
      $$HousekeeperRecordsTableOrderingComposer,
      $$HousekeeperRecordsTableAnnotationComposer,
      $$HousekeeperRecordsTableCreateCompanionBuilder,
      $$HousekeeperRecordsTableUpdateCompanionBuilder,
      (HousekeeperRow, $$HousekeeperRecordsTableReferences),
      HousekeeperRow,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$WorkAssignmentRecordsTableCreateCompanionBuilder =
    WorkAssignmentRecordsCompanion Function({
      required String sessionId,
      required String id,
      required int cartNumber,
      required String housekeeperId,
      Value<String?> territoryId,
      required DateTime assignedAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$WorkAssignmentRecordsTableUpdateCompanionBuilder =
    WorkAssignmentRecordsCompanion Function({
      Value<String> sessionId,
      Value<String> id,
      Value<int> cartNumber,
      Value<String> housekeeperId,
      Value<String?> territoryId,
      Value<DateTime> assignedAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$WorkAssignmentRecordsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $WorkAssignmentRecordsTable,
          WorkAssignmentRow
        > {
  $$WorkAssignmentRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WorkSessionRecordsTable _sessionIdTable(_$AppDatabase db) =>
      db.workSessionRecords.createAlias(
        'work_assignment_records__session_id__work_session_records__id',
      );

  $$WorkSessionRecordsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$WorkSessionRecordsTableTableManager(
      $_db,
      $_db.workSessionRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WorkAssignmentRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkAssignmentRecordsTable> {
  $$WorkAssignmentRecordsTableFilterComposer({
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

  ColumnFilters<int> get cartNumber => $composableBuilder(
    column: $table.cartNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get housekeeperId => $composableBuilder(
    column: $table.housekeeperId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get territoryId => $composableBuilder(
    column: $table.territoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get assignedAt => $composableBuilder(
    column: $table.assignedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkSessionRecordsTableFilterComposer get sessionId {
    final $$WorkSessionRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.workSessionRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkSessionRecordsTableFilterComposer(
            $db: $db,
            $table: $db.workSessionRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkAssignmentRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkAssignmentRecordsTable> {
  $$WorkAssignmentRecordsTableOrderingComposer({
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

  ColumnOrderings<int> get cartNumber => $composableBuilder(
    column: $table.cartNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get housekeeperId => $composableBuilder(
    column: $table.housekeeperId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get territoryId => $composableBuilder(
    column: $table.territoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get assignedAt => $composableBuilder(
    column: $table.assignedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkSessionRecordsTableOrderingComposer get sessionId {
    final $$WorkSessionRecordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.workSessionRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkSessionRecordsTableOrderingComposer(
            $db: $db,
            $table: $db.workSessionRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkAssignmentRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkAssignmentRecordsTable> {
  $$WorkAssignmentRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get cartNumber => $composableBuilder(
    column: $table.cartNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get housekeeperId => $composableBuilder(
    column: $table.housekeeperId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get territoryId => $composableBuilder(
    column: $table.territoryId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get assignedAt => $composableBuilder(
    column: $table.assignedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$WorkSessionRecordsTableAnnotationComposer get sessionId {
    final $$WorkSessionRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.sessionId,
          referencedTable: $db.workSessionRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkSessionRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.workSessionRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$WorkAssignmentRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkAssignmentRecordsTable,
          WorkAssignmentRow,
          $$WorkAssignmentRecordsTableFilterComposer,
          $$WorkAssignmentRecordsTableOrderingComposer,
          $$WorkAssignmentRecordsTableAnnotationComposer,
          $$WorkAssignmentRecordsTableCreateCompanionBuilder,
          $$WorkAssignmentRecordsTableUpdateCompanionBuilder,
          (WorkAssignmentRow, $$WorkAssignmentRecordsTableReferences),
          WorkAssignmentRow,
          PrefetchHooks Function({bool sessionId})
        > {
  $$WorkAssignmentRecordsTableTableManager(
    _$AppDatabase db,
    $WorkAssignmentRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkAssignmentRecordsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$WorkAssignmentRecordsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$WorkAssignmentRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> sessionId = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<int> cartNumber = const Value.absent(),
                Value<String> housekeeperId = const Value.absent(),
                Value<String?> territoryId = const Value.absent(),
                Value<DateTime> assignedAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkAssignmentRecordsCompanion(
                sessionId: sessionId,
                id: id,
                cartNumber: cartNumber,
                housekeeperId: housekeeperId,
                territoryId: territoryId,
                assignedAt: assignedAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sessionId,
                required String id,
                required int cartNumber,
                required String housekeeperId,
                Value<String?> territoryId = const Value.absent(),
                required DateTime assignedAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkAssignmentRecordsCompanion.insert(
                sessionId: sessionId,
                id: id,
                cartNumber: cartNumber,
                housekeeperId: housekeeperId,
                territoryId: territoryId,
                assignedAt: assignedAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WorkAssignmentRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
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
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable:
                                    $$WorkAssignmentRecordsTableReferences
                                        ._sessionIdTable(db),
                                referencedColumn:
                                    $$WorkAssignmentRecordsTableReferences
                                        ._sessionIdTable(db)
                                        .id,
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

typedef $$WorkAssignmentRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkAssignmentRecordsTable,
      WorkAssignmentRow,
      $$WorkAssignmentRecordsTableFilterComposer,
      $$WorkAssignmentRecordsTableOrderingComposer,
      $$WorkAssignmentRecordsTableAnnotationComposer,
      $$WorkAssignmentRecordsTableCreateCompanionBuilder,
      $$WorkAssignmentRecordsTableUpdateCompanionBuilder,
      (WorkAssignmentRow, $$WorkAssignmentRecordsTableReferences),
      WorkAssignmentRow,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$RoomStateRecordsTableCreateCompanionBuilder =
    RoomStateRecordsCompanion Function({
      required String sessionId,
      required String roomNumber,
      required String assignmentId,
      required String phase,
      Value<bool> isVip,
      Value<DateTime?> scheduledFor,
      Value<DateTime?> deletedAt,
      required DateTime selectedAt,
      required DateTime phaseUpdatedAt,
      Value<DateTime?> openedAt,
      Value<DateTime?> completedAt,
      Value<DateTime?> vipUpdatedAt,
      Value<DateTime?> scheduledUpdatedAt,
      Value<int> rowid,
    });
typedef $$RoomStateRecordsTableUpdateCompanionBuilder =
    RoomStateRecordsCompanion Function({
      Value<String> sessionId,
      Value<String> roomNumber,
      Value<String> assignmentId,
      Value<String> phase,
      Value<bool> isVip,
      Value<DateTime?> scheduledFor,
      Value<DateTime?> deletedAt,
      Value<DateTime> selectedAt,
      Value<DateTime> phaseUpdatedAt,
      Value<DateTime?> openedAt,
      Value<DateTime?> completedAt,
      Value<DateTime?> vipUpdatedAt,
      Value<DateTime?> scheduledUpdatedAt,
      Value<int> rowid,
    });

final class $$RoomStateRecordsTableReferences
    extends
        BaseReferences<_$AppDatabase, $RoomStateRecordsTable, RoomStateRow> {
  $$RoomStateRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WorkSessionRecordsTable _sessionIdTable(_$AppDatabase db) => db
      .workSessionRecords
      .createAlias('room_state_records__session_id__work_session_records__id');

  $$WorkSessionRecordsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$WorkSessionRecordsTableTableManager(
      $_db,
      $_db.workSessionRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RoomStateRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $RoomStateRecordsTable> {
  $$RoomStateRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get roomNumber => $composableBuilder(
    column: $table.roomNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assignmentId => $composableBuilder(
    column: $table.assignmentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phase => $composableBuilder(
    column: $table.phase,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isVip => $composableBuilder(
    column: $table.isVip,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scheduledFor => $composableBuilder(
    column: $table.scheduledFor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get selectedAt => $composableBuilder(
    column: $table.selectedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get phaseUpdatedAt => $composableBuilder(
    column: $table.phaseUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get openedAt => $composableBuilder(
    column: $table.openedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get vipUpdatedAt => $composableBuilder(
    column: $table.vipUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scheduledUpdatedAt => $composableBuilder(
    column: $table.scheduledUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkSessionRecordsTableFilterComposer get sessionId {
    final $$WorkSessionRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.workSessionRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkSessionRecordsTableFilterComposer(
            $db: $db,
            $table: $db.workSessionRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoomStateRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $RoomStateRecordsTable> {
  $$RoomStateRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get roomNumber => $composableBuilder(
    column: $table.roomNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assignmentId => $composableBuilder(
    column: $table.assignmentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phase => $composableBuilder(
    column: $table.phase,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isVip => $composableBuilder(
    column: $table.isVip,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scheduledFor => $composableBuilder(
    column: $table.scheduledFor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get selectedAt => $composableBuilder(
    column: $table.selectedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get phaseUpdatedAt => $composableBuilder(
    column: $table.phaseUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get openedAt => $composableBuilder(
    column: $table.openedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get vipUpdatedAt => $composableBuilder(
    column: $table.vipUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scheduledUpdatedAt => $composableBuilder(
    column: $table.scheduledUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkSessionRecordsTableOrderingComposer get sessionId {
    final $$WorkSessionRecordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.workSessionRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkSessionRecordsTableOrderingComposer(
            $db: $db,
            $table: $db.workSessionRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoomStateRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoomStateRecordsTable> {
  $$RoomStateRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get roomNumber => $composableBuilder(
    column: $table.roomNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get assignmentId => $composableBuilder(
    column: $table.assignmentId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get phase =>
      $composableBuilder(column: $table.phase, builder: (column) => column);

  GeneratedColumn<bool> get isVip =>
      $composableBuilder(column: $table.isVip, builder: (column) => column);

  GeneratedColumn<DateTime> get scheduledFor => $composableBuilder(
    column: $table.scheduledFor,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get selectedAt => $composableBuilder(
    column: $table.selectedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get phaseUpdatedAt => $composableBuilder(
    column: $table.phaseUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get openedAt =>
      $composableBuilder(column: $table.openedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get vipUpdatedAt => $composableBuilder(
    column: $table.vipUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get scheduledUpdatedAt => $composableBuilder(
    column: $table.scheduledUpdatedAt,
    builder: (column) => column,
  );

  $$WorkSessionRecordsTableAnnotationComposer get sessionId {
    final $$WorkSessionRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.sessionId,
          referencedTable: $db.workSessionRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkSessionRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.workSessionRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$RoomStateRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RoomStateRecordsTable,
          RoomStateRow,
          $$RoomStateRecordsTableFilterComposer,
          $$RoomStateRecordsTableOrderingComposer,
          $$RoomStateRecordsTableAnnotationComposer,
          $$RoomStateRecordsTableCreateCompanionBuilder,
          $$RoomStateRecordsTableUpdateCompanionBuilder,
          (RoomStateRow, $$RoomStateRecordsTableReferences),
          RoomStateRow,
          PrefetchHooks Function({bool sessionId})
        > {
  $$RoomStateRecordsTableTableManager(
    _$AppDatabase db,
    $RoomStateRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoomStateRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoomStateRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoomStateRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> sessionId = const Value.absent(),
                Value<String> roomNumber = const Value.absent(),
                Value<String> assignmentId = const Value.absent(),
                Value<String> phase = const Value.absent(),
                Value<bool> isVip = const Value.absent(),
                Value<DateTime?> scheduledFor = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<DateTime> selectedAt = const Value.absent(),
                Value<DateTime> phaseUpdatedAt = const Value.absent(),
                Value<DateTime?> openedAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<DateTime?> vipUpdatedAt = const Value.absent(),
                Value<DateTime?> scheduledUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoomStateRecordsCompanion(
                sessionId: sessionId,
                roomNumber: roomNumber,
                assignmentId: assignmentId,
                phase: phase,
                isVip: isVip,
                scheduledFor: scheduledFor,
                deletedAt: deletedAt,
                selectedAt: selectedAt,
                phaseUpdatedAt: phaseUpdatedAt,
                openedAt: openedAt,
                completedAt: completedAt,
                vipUpdatedAt: vipUpdatedAt,
                scheduledUpdatedAt: scheduledUpdatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sessionId,
                required String roomNumber,
                required String assignmentId,
                required String phase,
                Value<bool> isVip = const Value.absent(),
                Value<DateTime?> scheduledFor = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required DateTime selectedAt,
                required DateTime phaseUpdatedAt,
                Value<DateTime?> openedAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<DateTime?> vipUpdatedAt = const Value.absent(),
                Value<DateTime?> scheduledUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoomStateRecordsCompanion.insert(
                sessionId: sessionId,
                roomNumber: roomNumber,
                assignmentId: assignmentId,
                phase: phase,
                isVip: isVip,
                scheduledFor: scheduledFor,
                deletedAt: deletedAt,
                selectedAt: selectedAt,
                phaseUpdatedAt: phaseUpdatedAt,
                openedAt: openedAt,
                completedAt: completedAt,
                vipUpdatedAt: vipUpdatedAt,
                scheduledUpdatedAt: scheduledUpdatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RoomStateRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
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
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable:
                                    $$RoomStateRecordsTableReferences
                                        ._sessionIdTable(db),
                                referencedColumn:
                                    $$RoomStateRecordsTableReferences
                                        ._sessionIdTable(db)
                                        .id,
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

typedef $$RoomStateRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RoomStateRecordsTable,
      RoomStateRow,
      $$RoomStateRecordsTableFilterComposer,
      $$RoomStateRecordsTableOrderingComposer,
      $$RoomStateRecordsTableAnnotationComposer,
      $$RoomStateRecordsTableCreateCompanionBuilder,
      $$RoomStateRecordsTableUpdateCompanionBuilder,
      (RoomStateRow, $$RoomStateRecordsTableReferences),
      RoomStateRow,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$RoomNoteRecordsTableCreateCompanionBuilder =
    RoomNoteRecordsCompanion Function({
      required String sessionId,
      required String roomNumber,
      required String textValue,
      required DateTime updatedAt,
      Value<String?> lastCommandId,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$RoomNoteRecordsTableUpdateCompanionBuilder =
    RoomNoteRecordsCompanion Function({
      Value<String> sessionId,
      Value<String> roomNumber,
      Value<String> textValue,
      Value<DateTime> updatedAt,
      Value<String?> lastCommandId,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$RoomNoteRecordsTableReferences
    extends BaseReferences<_$AppDatabase, $RoomNoteRecordsTable, RoomNoteRow> {
  $$RoomNoteRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WorkSessionRecordsTable _sessionIdTable(_$AppDatabase db) => db
      .workSessionRecords
      .createAlias('room_note_records__session_id__work_session_records__id');

  $$WorkSessionRecordsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$WorkSessionRecordsTableTableManager(
      $_db,
      $_db.workSessionRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RoomNoteRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $RoomNoteRecordsTable> {
  $$RoomNoteRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get roomNumber => $composableBuilder(
    column: $table.roomNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textValue => $composableBuilder(
    column: $table.textValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastCommandId => $composableBuilder(
    column: $table.lastCommandId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkSessionRecordsTableFilterComposer get sessionId {
    final $$WorkSessionRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.workSessionRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkSessionRecordsTableFilterComposer(
            $db: $db,
            $table: $db.workSessionRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoomNoteRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $RoomNoteRecordsTable> {
  $$RoomNoteRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get roomNumber => $composableBuilder(
    column: $table.roomNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textValue => $composableBuilder(
    column: $table.textValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastCommandId => $composableBuilder(
    column: $table.lastCommandId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkSessionRecordsTableOrderingComposer get sessionId {
    final $$WorkSessionRecordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.workSessionRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkSessionRecordsTableOrderingComposer(
            $db: $db,
            $table: $db.workSessionRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoomNoteRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoomNoteRecordsTable> {
  $$RoomNoteRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get roomNumber => $composableBuilder(
    column: $table.roomNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get textValue =>
      $composableBuilder(column: $table.textValue, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get lastCommandId => $composableBuilder(
    column: $table.lastCommandId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$WorkSessionRecordsTableAnnotationComposer get sessionId {
    final $$WorkSessionRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.sessionId,
          referencedTable: $db.workSessionRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkSessionRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.workSessionRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$RoomNoteRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RoomNoteRecordsTable,
          RoomNoteRow,
          $$RoomNoteRecordsTableFilterComposer,
          $$RoomNoteRecordsTableOrderingComposer,
          $$RoomNoteRecordsTableAnnotationComposer,
          $$RoomNoteRecordsTableCreateCompanionBuilder,
          $$RoomNoteRecordsTableUpdateCompanionBuilder,
          (RoomNoteRow, $$RoomNoteRecordsTableReferences),
          RoomNoteRow,
          PrefetchHooks Function({bool sessionId})
        > {
  $$RoomNoteRecordsTableTableManager(
    _$AppDatabase db,
    $RoomNoteRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoomNoteRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoomNoteRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoomNoteRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> sessionId = const Value.absent(),
                Value<String> roomNumber = const Value.absent(),
                Value<String> textValue = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String?> lastCommandId = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoomNoteRecordsCompanion(
                sessionId: sessionId,
                roomNumber: roomNumber,
                textValue: textValue,
                updatedAt: updatedAt,
                lastCommandId: lastCommandId,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sessionId,
                required String roomNumber,
                required String textValue,
                required DateTime updatedAt,
                Value<String?> lastCommandId = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoomNoteRecordsCompanion.insert(
                sessionId: sessionId,
                roomNumber: roomNumber,
                textValue: textValue,
                updatedAt: updatedAt,
                lastCommandId: lastCommandId,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RoomNoteRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
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
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable:
                                    $$RoomNoteRecordsTableReferences
                                        ._sessionIdTable(db),
                                referencedColumn:
                                    $$RoomNoteRecordsTableReferences
                                        ._sessionIdTable(db)
                                        .id,
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

typedef $$RoomNoteRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RoomNoteRecordsTable,
      RoomNoteRow,
      $$RoomNoteRecordsTableFilterComposer,
      $$RoomNoteRecordsTableOrderingComposer,
      $$RoomNoteRecordsTableAnnotationComposer,
      $$RoomNoteRecordsTableCreateCompanionBuilder,
      $$RoomNoteRecordsTableUpdateCompanionBuilder,
      (RoomNoteRow, $$RoomNoteRecordsTableReferences),
      RoomNoteRow,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$AssignmentNoteRecordsTableCreateCompanionBuilder =
    AssignmentNoteRecordsCompanion Function({
      required String sessionId,
      required String assignmentId,
      required String textValue,
      required int updatedAtMicros,
      Value<String?> lastCommandId,
      Value<int?> deletedAtMicros,
      Value<int> rowid,
    });
typedef $$AssignmentNoteRecordsTableUpdateCompanionBuilder =
    AssignmentNoteRecordsCompanion Function({
      Value<String> sessionId,
      Value<String> assignmentId,
      Value<String> textValue,
      Value<int> updatedAtMicros,
      Value<String?> lastCommandId,
      Value<int?> deletedAtMicros,
      Value<int> rowid,
    });

final class $$AssignmentNoteRecordsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $AssignmentNoteRecordsTable,
          AssignmentNoteRow
        > {
  $$AssignmentNoteRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WorkSessionRecordsTable _sessionIdTable(_$AppDatabase db) =>
      db.workSessionRecords.createAlias(
        'assignment_note_records__session_id__work_session_records__id',
      );

  $$WorkSessionRecordsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$WorkSessionRecordsTableTableManager(
      $_db,
      $_db.workSessionRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AssignmentNoteRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $AssignmentNoteRecordsTable> {
  $$AssignmentNoteRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get assignmentId => $composableBuilder(
    column: $table.assignmentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textValue => $composableBuilder(
    column: $table.textValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMicros => $composableBuilder(
    column: $table.updatedAtMicros,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastCommandId => $composableBuilder(
    column: $table.lastCommandId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAtMicros => $composableBuilder(
    column: $table.deletedAtMicros,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkSessionRecordsTableFilterComposer get sessionId {
    final $$WorkSessionRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.workSessionRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkSessionRecordsTableFilterComposer(
            $db: $db,
            $table: $db.workSessionRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AssignmentNoteRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $AssignmentNoteRecordsTable> {
  $$AssignmentNoteRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get assignmentId => $composableBuilder(
    column: $table.assignmentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textValue => $composableBuilder(
    column: $table.textValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMicros => $composableBuilder(
    column: $table.updatedAtMicros,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastCommandId => $composableBuilder(
    column: $table.lastCommandId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAtMicros => $composableBuilder(
    column: $table.deletedAtMicros,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkSessionRecordsTableOrderingComposer get sessionId {
    final $$WorkSessionRecordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.workSessionRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkSessionRecordsTableOrderingComposer(
            $db: $db,
            $table: $db.workSessionRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AssignmentNoteRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AssignmentNoteRecordsTable> {
  $$AssignmentNoteRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get assignmentId => $composableBuilder(
    column: $table.assignmentId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get textValue =>
      $composableBuilder(column: $table.textValue, builder: (column) => column);

  GeneratedColumn<int> get updatedAtMicros => $composableBuilder(
    column: $table.updatedAtMicros,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastCommandId => $composableBuilder(
    column: $table.lastCommandId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAtMicros => $composableBuilder(
    column: $table.deletedAtMicros,
    builder: (column) => column,
  );

  $$WorkSessionRecordsTableAnnotationComposer get sessionId {
    final $$WorkSessionRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.sessionId,
          referencedTable: $db.workSessionRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkSessionRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.workSessionRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$AssignmentNoteRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AssignmentNoteRecordsTable,
          AssignmentNoteRow,
          $$AssignmentNoteRecordsTableFilterComposer,
          $$AssignmentNoteRecordsTableOrderingComposer,
          $$AssignmentNoteRecordsTableAnnotationComposer,
          $$AssignmentNoteRecordsTableCreateCompanionBuilder,
          $$AssignmentNoteRecordsTableUpdateCompanionBuilder,
          (AssignmentNoteRow, $$AssignmentNoteRecordsTableReferences),
          AssignmentNoteRow,
          PrefetchHooks Function({bool sessionId})
        > {
  $$AssignmentNoteRecordsTableTableManager(
    _$AppDatabase db,
    $AssignmentNoteRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AssignmentNoteRecordsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$AssignmentNoteRecordsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$AssignmentNoteRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> sessionId = const Value.absent(),
                Value<String> assignmentId = const Value.absent(),
                Value<String> textValue = const Value.absent(),
                Value<int> updatedAtMicros = const Value.absent(),
                Value<String?> lastCommandId = const Value.absent(),
                Value<int?> deletedAtMicros = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AssignmentNoteRecordsCompanion(
                sessionId: sessionId,
                assignmentId: assignmentId,
                textValue: textValue,
                updatedAtMicros: updatedAtMicros,
                lastCommandId: lastCommandId,
                deletedAtMicros: deletedAtMicros,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sessionId,
                required String assignmentId,
                required String textValue,
                required int updatedAtMicros,
                Value<String?> lastCommandId = const Value.absent(),
                Value<int?> deletedAtMicros = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AssignmentNoteRecordsCompanion.insert(
                sessionId: sessionId,
                assignmentId: assignmentId,
                textValue: textValue,
                updatedAtMicros: updatedAtMicros,
                lastCommandId: lastCommandId,
                deletedAtMicros: deletedAtMicros,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AssignmentNoteRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
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
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable:
                                    $$AssignmentNoteRecordsTableReferences
                                        ._sessionIdTable(db),
                                referencedColumn:
                                    $$AssignmentNoteRecordsTableReferences
                                        ._sessionIdTable(db)
                                        .id,
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

typedef $$AssignmentNoteRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AssignmentNoteRecordsTable,
      AssignmentNoteRow,
      $$AssignmentNoteRecordsTableFilterComposer,
      $$AssignmentNoteRecordsTableOrderingComposer,
      $$AssignmentNoteRecordsTableAnnotationComposer,
      $$AssignmentNoteRecordsTableCreateCompanionBuilder,
      $$AssignmentNoteRecordsTableUpdateCompanionBuilder,
      (AssignmentNoteRow, $$AssignmentNoteRecordsTableReferences),
      AssignmentNoteRow,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$CartConsumableRecordsTableCreateCompanionBuilder =
    CartConsumableRecordsCompanion Function({
      required String sessionId,
      required String assignmentId,
      required String itemId,
      required String title,
      required int quantity,
      required int updatedAtMicros,
      required String lastCommandId,
      Value<int?> completedAtMicros,
      Value<int?> deletedAtMicros,
      Value<int> rowid,
    });
typedef $$CartConsumableRecordsTableUpdateCompanionBuilder =
    CartConsumableRecordsCompanion Function({
      Value<String> sessionId,
      Value<String> assignmentId,
      Value<String> itemId,
      Value<String> title,
      Value<int> quantity,
      Value<int> updatedAtMicros,
      Value<String> lastCommandId,
      Value<int?> completedAtMicros,
      Value<int?> deletedAtMicros,
      Value<int> rowid,
    });

final class $$CartConsumableRecordsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $CartConsumableRecordsTable,
          CartConsumableRow
        > {
  $$CartConsumableRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WorkSessionRecordsTable _sessionIdTable(_$AppDatabase db) =>
      db.workSessionRecords.createAlias(
        'cart_consumable_records__session_id__work_session_records__id',
      );

  $$WorkSessionRecordsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$WorkSessionRecordsTableTableManager(
      $_db,
      $_db.workSessionRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CartConsumableRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $CartConsumableRecordsTable> {
  $$CartConsumableRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get assignmentId => $composableBuilder(
    column: $table.assignmentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMicros => $composableBuilder(
    column: $table.updatedAtMicros,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastCommandId => $composableBuilder(
    column: $table.lastCommandId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedAtMicros => $composableBuilder(
    column: $table.completedAtMicros,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAtMicros => $composableBuilder(
    column: $table.deletedAtMicros,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkSessionRecordsTableFilterComposer get sessionId {
    final $$WorkSessionRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.workSessionRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkSessionRecordsTableFilterComposer(
            $db: $db,
            $table: $db.workSessionRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CartConsumableRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $CartConsumableRecordsTable> {
  $$CartConsumableRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get assignmentId => $composableBuilder(
    column: $table.assignmentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMicros => $composableBuilder(
    column: $table.updatedAtMicros,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastCommandId => $composableBuilder(
    column: $table.lastCommandId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedAtMicros => $composableBuilder(
    column: $table.completedAtMicros,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAtMicros => $composableBuilder(
    column: $table.deletedAtMicros,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkSessionRecordsTableOrderingComposer get sessionId {
    final $$WorkSessionRecordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.workSessionRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkSessionRecordsTableOrderingComposer(
            $db: $db,
            $table: $db.workSessionRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CartConsumableRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CartConsumableRecordsTable> {
  $$CartConsumableRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get assignmentId => $composableBuilder(
    column: $table.assignmentId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<int> get updatedAtMicros => $composableBuilder(
    column: $table.updatedAtMicros,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastCommandId => $composableBuilder(
    column: $table.lastCommandId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get completedAtMicros => $composableBuilder(
    column: $table.completedAtMicros,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAtMicros => $composableBuilder(
    column: $table.deletedAtMicros,
    builder: (column) => column,
  );

  $$WorkSessionRecordsTableAnnotationComposer get sessionId {
    final $$WorkSessionRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.sessionId,
          referencedTable: $db.workSessionRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkSessionRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.workSessionRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$CartConsumableRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CartConsumableRecordsTable,
          CartConsumableRow,
          $$CartConsumableRecordsTableFilterComposer,
          $$CartConsumableRecordsTableOrderingComposer,
          $$CartConsumableRecordsTableAnnotationComposer,
          $$CartConsumableRecordsTableCreateCompanionBuilder,
          $$CartConsumableRecordsTableUpdateCompanionBuilder,
          (CartConsumableRow, $$CartConsumableRecordsTableReferences),
          CartConsumableRow,
          PrefetchHooks Function({bool sessionId})
        > {
  $$CartConsumableRecordsTableTableManager(
    _$AppDatabase db,
    $CartConsumableRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CartConsumableRecordsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$CartConsumableRecordsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CartConsumableRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> sessionId = const Value.absent(),
                Value<String> assignmentId = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<int> updatedAtMicros = const Value.absent(),
                Value<String> lastCommandId = const Value.absent(),
                Value<int?> completedAtMicros = const Value.absent(),
                Value<int?> deletedAtMicros = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CartConsumableRecordsCompanion(
                sessionId: sessionId,
                assignmentId: assignmentId,
                itemId: itemId,
                title: title,
                quantity: quantity,
                updatedAtMicros: updatedAtMicros,
                lastCommandId: lastCommandId,
                completedAtMicros: completedAtMicros,
                deletedAtMicros: deletedAtMicros,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sessionId,
                required String assignmentId,
                required String itemId,
                required String title,
                required int quantity,
                required int updatedAtMicros,
                required String lastCommandId,
                Value<int?> completedAtMicros = const Value.absent(),
                Value<int?> deletedAtMicros = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CartConsumableRecordsCompanion.insert(
                sessionId: sessionId,
                assignmentId: assignmentId,
                itemId: itemId,
                title: title,
                quantity: quantity,
                updatedAtMicros: updatedAtMicros,
                lastCommandId: lastCommandId,
                completedAtMicros: completedAtMicros,
                deletedAtMicros: deletedAtMicros,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CartConsumableRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
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
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable:
                                    $$CartConsumableRecordsTableReferences
                                        ._sessionIdTable(db),
                                referencedColumn:
                                    $$CartConsumableRecordsTableReferences
                                        ._sessionIdTable(db)
                                        .id,
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

typedef $$CartConsumableRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CartConsumableRecordsTable,
      CartConsumableRow,
      $$CartConsumableRecordsTableFilterComposer,
      $$CartConsumableRecordsTableOrderingComposer,
      $$CartConsumableRecordsTableAnnotationComposer,
      $$CartConsumableRecordsTableCreateCompanionBuilder,
      $$CartConsumableRecordsTableUpdateCompanionBuilder,
      (CartConsumableRow, $$CartConsumableRecordsTableReferences),
      CartConsumableRow,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$HistoryEventRecordsTableCreateCompanionBuilder =
    HistoryEventRecordsCompanion Function({
      required String id,
      required String sessionId,
      required String commandId,
      required String eventType,
      Value<int> eventVersion,
      required String payloadJson,
      required DateTime happenedAt,
      Value<int> rowid,
    });
typedef $$HistoryEventRecordsTableUpdateCompanionBuilder =
    HistoryEventRecordsCompanion Function({
      Value<String> id,
      Value<String> sessionId,
      Value<String> commandId,
      Value<String> eventType,
      Value<int> eventVersion,
      Value<String> payloadJson,
      Value<DateTime> happenedAt,
      Value<int> rowid,
    });

final class $$HistoryEventRecordsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $HistoryEventRecordsTable,
          HistoryEventRow
        > {
  $$HistoryEventRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WorkSessionRecordsTable _sessionIdTable(_$AppDatabase db) =>
      db.workSessionRecords.createAlias(
        'history_event_records__session_id__work_session_records__id',
      );

  $$WorkSessionRecordsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$WorkSessionRecordsTableTableManager(
      $_db,
      $_db.workSessionRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$HistoryEventRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $HistoryEventRecordsTable> {
  $$HistoryEventRecordsTableFilterComposer({
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

  ColumnFilters<String> get commandId => $composableBuilder(
    column: $table.commandId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get eventVersion => $composableBuilder(
    column: $table.eventVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get happenedAt => $composableBuilder(
    column: $table.happenedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkSessionRecordsTableFilterComposer get sessionId {
    final $$WorkSessionRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.workSessionRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkSessionRecordsTableFilterComposer(
            $db: $db,
            $table: $db.workSessionRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HistoryEventRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $HistoryEventRecordsTable> {
  $$HistoryEventRecordsTableOrderingComposer({
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

  ColumnOrderings<String> get commandId => $composableBuilder(
    column: $table.commandId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get eventVersion => $composableBuilder(
    column: $table.eventVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get happenedAt => $composableBuilder(
    column: $table.happenedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkSessionRecordsTableOrderingComposer get sessionId {
    final $$WorkSessionRecordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.workSessionRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkSessionRecordsTableOrderingComposer(
            $db: $db,
            $table: $db.workSessionRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HistoryEventRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HistoryEventRecordsTable> {
  $$HistoryEventRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get commandId =>
      $composableBuilder(column: $table.commandId, builder: (column) => column);

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<int> get eventVersion => $composableBuilder(
    column: $table.eventVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get happenedAt => $composableBuilder(
    column: $table.happenedAt,
    builder: (column) => column,
  );

  $$WorkSessionRecordsTableAnnotationComposer get sessionId {
    final $$WorkSessionRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.sessionId,
          referencedTable: $db.workSessionRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkSessionRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.workSessionRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$HistoryEventRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HistoryEventRecordsTable,
          HistoryEventRow,
          $$HistoryEventRecordsTableFilterComposer,
          $$HistoryEventRecordsTableOrderingComposer,
          $$HistoryEventRecordsTableAnnotationComposer,
          $$HistoryEventRecordsTableCreateCompanionBuilder,
          $$HistoryEventRecordsTableUpdateCompanionBuilder,
          (HistoryEventRow, $$HistoryEventRecordsTableReferences),
          HistoryEventRow,
          PrefetchHooks Function({bool sessionId})
        > {
  $$HistoryEventRecordsTableTableManager(
    _$AppDatabase db,
    $HistoryEventRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HistoryEventRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HistoryEventRecordsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$HistoryEventRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String> commandId = const Value.absent(),
                Value<String> eventType = const Value.absent(),
                Value<int> eventVersion = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<DateTime> happenedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HistoryEventRecordsCompanion(
                id: id,
                sessionId: sessionId,
                commandId: commandId,
                eventType: eventType,
                eventVersion: eventVersion,
                payloadJson: payloadJson,
                happenedAt: happenedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sessionId,
                required String commandId,
                required String eventType,
                Value<int> eventVersion = const Value.absent(),
                required String payloadJson,
                required DateTime happenedAt,
                Value<int> rowid = const Value.absent(),
              }) => HistoryEventRecordsCompanion.insert(
                id: id,
                sessionId: sessionId,
                commandId: commandId,
                eventType: eventType,
                eventVersion: eventVersion,
                payloadJson: payloadJson,
                happenedAt: happenedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$HistoryEventRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
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
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable:
                                    $$HistoryEventRecordsTableReferences
                                        ._sessionIdTable(db),
                                referencedColumn:
                                    $$HistoryEventRecordsTableReferences
                                        ._sessionIdTable(db)
                                        .id,
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

typedef $$HistoryEventRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HistoryEventRecordsTable,
      HistoryEventRow,
      $$HistoryEventRecordsTableFilterComposer,
      $$HistoryEventRecordsTableOrderingComposer,
      $$HistoryEventRecordsTableAnnotationComposer,
      $$HistoryEventRecordsTableCreateCompanionBuilder,
      $$HistoryEventRecordsTableUpdateCompanionBuilder,
      (HistoryEventRow, $$HistoryEventRecordsTableReferences),
      HistoryEventRow,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$CommandReceiptRecordsTableCreateCompanionBuilder =
    CommandReceiptRecordsCompanion Function({
      required String sessionId,
      required String commandId,
      Value<int> commandVersion,
      Value<String?> commandType,
      Value<String?> commandFingerprint,
      Value<int?> issuedAtMicros,
      required String outcome,
      required DateTime processedAt,
      Value<int> rowid,
    });
typedef $$CommandReceiptRecordsTableUpdateCompanionBuilder =
    CommandReceiptRecordsCompanion Function({
      Value<String> sessionId,
      Value<String> commandId,
      Value<int> commandVersion,
      Value<String?> commandType,
      Value<String?> commandFingerprint,
      Value<int?> issuedAtMicros,
      Value<String> outcome,
      Value<DateTime> processedAt,
      Value<int> rowid,
    });

final class $$CommandReceiptRecordsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $CommandReceiptRecordsTable,
          CommandReceiptRow
        > {
  $$CommandReceiptRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WorkSessionRecordsTable _sessionIdTable(_$AppDatabase db) =>
      db.workSessionRecords.createAlias(
        'command_receipt_records__session_id__work_session_records__id',
      );

  $$WorkSessionRecordsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$WorkSessionRecordsTableTableManager(
      $_db,
      $_db.workSessionRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CommandReceiptRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $CommandReceiptRecordsTable> {
  $$CommandReceiptRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get commandId => $composableBuilder(
    column: $table.commandId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get commandVersion => $composableBuilder(
    column: $table.commandVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get commandType => $composableBuilder(
    column: $table.commandType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get commandFingerprint => $composableBuilder(
    column: $table.commandFingerprint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get issuedAtMicros => $composableBuilder(
    column: $table.issuedAtMicros,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get processedAt => $composableBuilder(
    column: $table.processedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkSessionRecordsTableFilterComposer get sessionId {
    final $$WorkSessionRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.workSessionRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkSessionRecordsTableFilterComposer(
            $db: $db,
            $table: $db.workSessionRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CommandReceiptRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $CommandReceiptRecordsTable> {
  $$CommandReceiptRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get commandId => $composableBuilder(
    column: $table.commandId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get commandVersion => $composableBuilder(
    column: $table.commandVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get commandType => $composableBuilder(
    column: $table.commandType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get commandFingerprint => $composableBuilder(
    column: $table.commandFingerprint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get issuedAtMicros => $composableBuilder(
    column: $table.issuedAtMicros,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get processedAt => $composableBuilder(
    column: $table.processedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkSessionRecordsTableOrderingComposer get sessionId {
    final $$WorkSessionRecordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.workSessionRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkSessionRecordsTableOrderingComposer(
            $db: $db,
            $table: $db.workSessionRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CommandReceiptRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CommandReceiptRecordsTable> {
  $$CommandReceiptRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get commandId =>
      $composableBuilder(column: $table.commandId, builder: (column) => column);

  GeneratedColumn<int> get commandVersion => $composableBuilder(
    column: $table.commandVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get commandType => $composableBuilder(
    column: $table.commandType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get commandFingerprint => $composableBuilder(
    column: $table.commandFingerprint,
    builder: (column) => column,
  );

  GeneratedColumn<int> get issuedAtMicros => $composableBuilder(
    column: $table.issuedAtMicros,
    builder: (column) => column,
  );

  GeneratedColumn<String> get outcome =>
      $composableBuilder(column: $table.outcome, builder: (column) => column);

  GeneratedColumn<DateTime> get processedAt => $composableBuilder(
    column: $table.processedAt,
    builder: (column) => column,
  );

  $$WorkSessionRecordsTableAnnotationComposer get sessionId {
    final $$WorkSessionRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.sessionId,
          referencedTable: $db.workSessionRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkSessionRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.workSessionRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$CommandReceiptRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CommandReceiptRecordsTable,
          CommandReceiptRow,
          $$CommandReceiptRecordsTableFilterComposer,
          $$CommandReceiptRecordsTableOrderingComposer,
          $$CommandReceiptRecordsTableAnnotationComposer,
          $$CommandReceiptRecordsTableCreateCompanionBuilder,
          $$CommandReceiptRecordsTableUpdateCompanionBuilder,
          (CommandReceiptRow, $$CommandReceiptRecordsTableReferences),
          CommandReceiptRow,
          PrefetchHooks Function({bool sessionId})
        > {
  $$CommandReceiptRecordsTableTableManager(
    _$AppDatabase db,
    $CommandReceiptRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CommandReceiptRecordsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$CommandReceiptRecordsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CommandReceiptRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> sessionId = const Value.absent(),
                Value<String> commandId = const Value.absent(),
                Value<int> commandVersion = const Value.absent(),
                Value<String?> commandType = const Value.absent(),
                Value<String?> commandFingerprint = const Value.absent(),
                Value<int?> issuedAtMicros = const Value.absent(),
                Value<String> outcome = const Value.absent(),
                Value<DateTime> processedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CommandReceiptRecordsCompanion(
                sessionId: sessionId,
                commandId: commandId,
                commandVersion: commandVersion,
                commandType: commandType,
                commandFingerprint: commandFingerprint,
                issuedAtMicros: issuedAtMicros,
                outcome: outcome,
                processedAt: processedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sessionId,
                required String commandId,
                Value<int> commandVersion = const Value.absent(),
                Value<String?> commandType = const Value.absent(),
                Value<String?> commandFingerprint = const Value.absent(),
                Value<int?> issuedAtMicros = const Value.absent(),
                required String outcome,
                required DateTime processedAt,
                Value<int> rowid = const Value.absent(),
              }) => CommandReceiptRecordsCompanion.insert(
                sessionId: sessionId,
                commandId: commandId,
                commandVersion: commandVersion,
                commandType: commandType,
                commandFingerprint: commandFingerprint,
                issuedAtMicros: issuedAtMicros,
                outcome: outcome,
                processedAt: processedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CommandReceiptRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
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
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable:
                                    $$CommandReceiptRecordsTableReferences
                                        ._sessionIdTable(db),
                                referencedColumn:
                                    $$CommandReceiptRecordsTableReferences
                                        ._sessionIdTable(db)
                                        .id,
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

typedef $$CommandReceiptRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CommandReceiptRecordsTable,
      CommandReceiptRow,
      $$CommandReceiptRecordsTableFilterComposer,
      $$CommandReceiptRecordsTableOrderingComposer,
      $$CommandReceiptRecordsTableAnnotationComposer,
      $$CommandReceiptRecordsTableCreateCompanionBuilder,
      $$CommandReceiptRecordsTableUpdateCompanionBuilder,
      (CommandReceiptRow, $$CommandReceiptRecordsTableReferences),
      CommandReceiptRow,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$SyncOutboxRecordsTableCreateCompanionBuilder =
    SyncOutboxRecordsCompanion Function({
      required String eventId,
      required String sessionId,
      Value<int> attemptCount,
      Value<DateTime?> nextAttemptAt,
      Value<DateTime?> acknowledgedAt,
      Value<int> rowid,
    });
typedef $$SyncOutboxRecordsTableUpdateCompanionBuilder =
    SyncOutboxRecordsCompanion Function({
      Value<String> eventId,
      Value<String> sessionId,
      Value<int> attemptCount,
      Value<DateTime?> nextAttemptAt,
      Value<DateTime?> acknowledgedAt,
      Value<int> rowid,
    });

final class $$SyncOutboxRecordsTableReferences
    extends
        BaseReferences<_$AppDatabase, $SyncOutboxRecordsTable, SyncOutboxRow> {
  $$SyncOutboxRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WorkSessionRecordsTable _sessionIdTable(_$AppDatabase db) => db
      .workSessionRecords
      .createAlias('sync_outbox_records__session_id__work_session_records__id');

  $$WorkSessionRecordsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$WorkSessionRecordsTableTableManager(
      $_db,
      $_db.workSessionRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SyncOutboxRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncOutboxRecordsTable> {
  $$SyncOutboxRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get acknowledgedAt => $composableBuilder(
    column: $table.acknowledgedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkSessionRecordsTableFilterComposer get sessionId {
    final $$WorkSessionRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.workSessionRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkSessionRecordsTableFilterComposer(
            $db: $db,
            $table: $db.workSessionRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SyncOutboxRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncOutboxRecordsTable> {
  $$SyncOutboxRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get acknowledgedAt => $composableBuilder(
    column: $table.acknowledgedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkSessionRecordsTableOrderingComposer get sessionId {
    final $$WorkSessionRecordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.workSessionRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkSessionRecordsTableOrderingComposer(
            $db: $db,
            $table: $db.workSessionRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SyncOutboxRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncOutboxRecordsTable> {
  $$SyncOutboxRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get eventId =>
      $composableBuilder(column: $table.eventId, builder: (column) => column);

  GeneratedColumn<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get acknowledgedAt => $composableBuilder(
    column: $table.acknowledgedAt,
    builder: (column) => column,
  );

  $$WorkSessionRecordsTableAnnotationComposer get sessionId {
    final $$WorkSessionRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.sessionId,
          referencedTable: $db.workSessionRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkSessionRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.workSessionRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$SyncOutboxRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncOutboxRecordsTable,
          SyncOutboxRow,
          $$SyncOutboxRecordsTableFilterComposer,
          $$SyncOutboxRecordsTableOrderingComposer,
          $$SyncOutboxRecordsTableAnnotationComposer,
          $$SyncOutboxRecordsTableCreateCompanionBuilder,
          $$SyncOutboxRecordsTableUpdateCompanionBuilder,
          (SyncOutboxRow, $$SyncOutboxRecordsTableReferences),
          SyncOutboxRow,
          PrefetchHooks Function({bool sessionId})
        > {
  $$SyncOutboxRecordsTableTableManager(
    _$AppDatabase db,
    $SyncOutboxRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncOutboxRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncOutboxRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncOutboxRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> eventId = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<int> attemptCount = const Value.absent(),
                Value<DateTime?> nextAttemptAt = const Value.absent(),
                Value<DateTime?> acknowledgedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncOutboxRecordsCompanion(
                eventId: eventId,
                sessionId: sessionId,
                attemptCount: attemptCount,
                nextAttemptAt: nextAttemptAt,
                acknowledgedAt: acknowledgedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String eventId,
                required String sessionId,
                Value<int> attemptCount = const Value.absent(),
                Value<DateTime?> nextAttemptAt = const Value.absent(),
                Value<DateTime?> acknowledgedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncOutboxRecordsCompanion.insert(
                eventId: eventId,
                sessionId: sessionId,
                attemptCount: attemptCount,
                nextAttemptAt: nextAttemptAt,
                acknowledgedAt: acknowledgedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SyncOutboxRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
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
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable:
                                    $$SyncOutboxRecordsTableReferences
                                        ._sessionIdTable(db),
                                referencedColumn:
                                    $$SyncOutboxRecordsTableReferences
                                        ._sessionIdTable(db)
                                        .id,
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

typedef $$SyncOutboxRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncOutboxRecordsTable,
      SyncOutboxRow,
      $$SyncOutboxRecordsTableFilterComposer,
      $$SyncOutboxRecordsTableOrderingComposer,
      $$SyncOutboxRecordsTableAnnotationComposer,
      $$SyncOutboxRecordsTableCreateCompanionBuilder,
      $$SyncOutboxRecordsTableUpdateCompanionBuilder,
      (SyncOutboxRow, $$SyncOutboxRecordsTableReferences),
      SyncOutboxRow,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$SyncInboxRecordsTableCreateCompanionBuilder =
    SyncInboxRecordsCompanion Function({
      required String eventId,
      required String checksum,
      required DateTime receivedAt,
      Value<DateTime?> appliedAt,
      Value<int> rowid,
    });
typedef $$SyncInboxRecordsTableUpdateCompanionBuilder =
    SyncInboxRecordsCompanion Function({
      Value<String> eventId,
      Value<String> checksum,
      Value<DateTime> receivedAt,
      Value<DateTime?> appliedAt,
      Value<int> rowid,
    });

class $$SyncInboxRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncInboxRecordsTable> {
  $$SyncInboxRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get checksum => $composableBuilder(
    column: $table.checksum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get appliedAt => $composableBuilder(
    column: $table.appliedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncInboxRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncInboxRecordsTable> {
  $$SyncInboxRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get checksum => $composableBuilder(
    column: $table.checksum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get appliedAt => $composableBuilder(
    column: $table.appliedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncInboxRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncInboxRecordsTable> {
  $$SyncInboxRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get eventId =>
      $composableBuilder(column: $table.eventId, builder: (column) => column);

  GeneratedColumn<String> get checksum =>
      $composableBuilder(column: $table.checksum, builder: (column) => column);

  GeneratedColumn<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get appliedAt =>
      $composableBuilder(column: $table.appliedAt, builder: (column) => column);
}

class $$SyncInboxRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncInboxRecordsTable,
          SyncInboxRow,
          $$SyncInboxRecordsTableFilterComposer,
          $$SyncInboxRecordsTableOrderingComposer,
          $$SyncInboxRecordsTableAnnotationComposer,
          $$SyncInboxRecordsTableCreateCompanionBuilder,
          $$SyncInboxRecordsTableUpdateCompanionBuilder,
          (
            SyncInboxRow,
            BaseReferences<_$AppDatabase, $SyncInboxRecordsTable, SyncInboxRow>,
          ),
          SyncInboxRow,
          PrefetchHooks Function()
        > {
  $$SyncInboxRecordsTableTableManager(
    _$AppDatabase db,
    $SyncInboxRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncInboxRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncInboxRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncInboxRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> eventId = const Value.absent(),
                Value<String> checksum = const Value.absent(),
                Value<DateTime> receivedAt = const Value.absent(),
                Value<DateTime?> appliedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncInboxRecordsCompanion(
                eventId: eventId,
                checksum: checksum,
                receivedAt: receivedAt,
                appliedAt: appliedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String eventId,
                required String checksum,
                required DateTime receivedAt,
                Value<DateTime?> appliedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncInboxRecordsCompanion.insert(
                eventId: eventId,
                checksum: checksum,
                receivedAt: receivedAt,
                appliedAt: appliedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncInboxRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncInboxRecordsTable,
      SyncInboxRow,
      $$SyncInboxRecordsTableFilterComposer,
      $$SyncInboxRecordsTableOrderingComposer,
      $$SyncInboxRecordsTableAnnotationComposer,
      $$SyncInboxRecordsTableCreateCompanionBuilder,
      $$SyncInboxRecordsTableUpdateCompanionBuilder,
      (
        SyncInboxRow,
        BaseReferences<_$AppDatabase, $SyncInboxRecordsTable, SyncInboxRow>,
      ),
      SyncInboxRow,
      PrefetchHooks Function()
    >;
typedef $$MediaManifestRecordsTableCreateCompanionBuilder =
    MediaManifestRecordsCompanion Function({
      required String id,
      required String sessionId,
      Value<String?> assignmentId,
      Value<String?> roomNumber,
      required String kind,
      required String relativePath,
      required String checksumSha256,
      required String originDeviceId,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<String?> mimeType,
      Value<int?> durationMs,
      Value<String?> transcript,
      Value<int?> byteLength,
      Value<int?> widthPixels,
      Value<int?> heightPixels,
      Value<String?> originalExtension,
      Value<int?> orientation,
      Value<String?> colorSpace,
      Value<bool?> isHdr,
      Value<String?> lastCommandId,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$MediaManifestRecordsTableUpdateCompanionBuilder =
    MediaManifestRecordsCompanion Function({
      Value<String> id,
      Value<String> sessionId,
      Value<String?> assignmentId,
      Value<String?> roomNumber,
      Value<String> kind,
      Value<String> relativePath,
      Value<String> checksumSha256,
      Value<String> originDeviceId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String?> mimeType,
      Value<int?> durationMs,
      Value<String?> transcript,
      Value<int?> byteLength,
      Value<int?> widthPixels,
      Value<int?> heightPixels,
      Value<String?> originalExtension,
      Value<int?> orientation,
      Value<String?> colorSpace,
      Value<bool?> isHdr,
      Value<String?> lastCommandId,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$MediaManifestRecordsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $MediaManifestRecordsTable,
          MediaManifestRow
        > {
  $$MediaManifestRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WorkSessionRecordsTable _sessionIdTable(_$AppDatabase db) =>
      db.workSessionRecords.createAlias(
        'media_manifest_records__session_id__work_session_records__id',
      );

  $$WorkSessionRecordsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$WorkSessionRecordsTableTableManager(
      $_db,
      $_db.workSessionRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MediaManifestRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $MediaManifestRecordsTable> {
  $$MediaManifestRecordsTableFilterComposer({
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

  ColumnFilters<String> get assignmentId => $composableBuilder(
    column: $table.assignmentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get roomNumber => $composableBuilder(
    column: $table.roomNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get checksumSha256 => $composableBuilder(
    column: $table.checksumSha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originDeviceId => $composableBuilder(
    column: $table.originDeviceId,
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

  ColumnFilters<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transcript => $composableBuilder(
    column: $table.transcript,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get byteLength => $composableBuilder(
    column: $table.byteLength,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get widthPixels => $composableBuilder(
    column: $table.widthPixels,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get heightPixels => $composableBuilder(
    column: $table.heightPixels,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalExtension => $composableBuilder(
    column: $table.originalExtension,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orientation => $composableBuilder(
    column: $table.orientation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colorSpace => $composableBuilder(
    column: $table.colorSpace,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isHdr => $composableBuilder(
    column: $table.isHdr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastCommandId => $composableBuilder(
    column: $table.lastCommandId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkSessionRecordsTableFilterComposer get sessionId {
    final $$WorkSessionRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.workSessionRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkSessionRecordsTableFilterComposer(
            $db: $db,
            $table: $db.workSessionRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MediaManifestRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $MediaManifestRecordsTable> {
  $$MediaManifestRecordsTableOrderingComposer({
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

  ColumnOrderings<String> get assignmentId => $composableBuilder(
    column: $table.assignmentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get roomNumber => $composableBuilder(
    column: $table.roomNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get checksumSha256 => $composableBuilder(
    column: $table.checksumSha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originDeviceId => $composableBuilder(
    column: $table.originDeviceId,
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

  ColumnOrderings<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transcript => $composableBuilder(
    column: $table.transcript,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get byteLength => $composableBuilder(
    column: $table.byteLength,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get widthPixels => $composableBuilder(
    column: $table.widthPixels,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get heightPixels => $composableBuilder(
    column: $table.heightPixels,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalExtension => $composableBuilder(
    column: $table.originalExtension,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orientation => $composableBuilder(
    column: $table.orientation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorSpace => $composableBuilder(
    column: $table.colorSpace,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isHdr => $composableBuilder(
    column: $table.isHdr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastCommandId => $composableBuilder(
    column: $table.lastCommandId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkSessionRecordsTableOrderingComposer get sessionId {
    final $$WorkSessionRecordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.workSessionRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkSessionRecordsTableOrderingComposer(
            $db: $db,
            $table: $db.workSessionRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MediaManifestRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MediaManifestRecordsTable> {
  $$MediaManifestRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get assignmentId => $composableBuilder(
    column: $table.assignmentId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get roomNumber => $composableBuilder(
    column: $table.roomNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get checksumSha256 => $composableBuilder(
    column: $table.checksumSha256,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originDeviceId => $composableBuilder(
    column: $table.originDeviceId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get transcript => $composableBuilder(
    column: $table.transcript,
    builder: (column) => column,
  );

  GeneratedColumn<int> get byteLength => $composableBuilder(
    column: $table.byteLength,
    builder: (column) => column,
  );

  GeneratedColumn<int> get widthPixels => $composableBuilder(
    column: $table.widthPixels,
    builder: (column) => column,
  );

  GeneratedColumn<int> get heightPixels => $composableBuilder(
    column: $table.heightPixels,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originalExtension => $composableBuilder(
    column: $table.originalExtension,
    builder: (column) => column,
  );

  GeneratedColumn<int> get orientation => $composableBuilder(
    column: $table.orientation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get colorSpace => $composableBuilder(
    column: $table.colorSpace,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isHdr =>
      $composableBuilder(column: $table.isHdr, builder: (column) => column);

  GeneratedColumn<String> get lastCommandId => $composableBuilder(
    column: $table.lastCommandId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$WorkSessionRecordsTableAnnotationComposer get sessionId {
    final $$WorkSessionRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.sessionId,
          referencedTable: $db.workSessionRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkSessionRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.workSessionRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$MediaManifestRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MediaManifestRecordsTable,
          MediaManifestRow,
          $$MediaManifestRecordsTableFilterComposer,
          $$MediaManifestRecordsTableOrderingComposer,
          $$MediaManifestRecordsTableAnnotationComposer,
          $$MediaManifestRecordsTableCreateCompanionBuilder,
          $$MediaManifestRecordsTableUpdateCompanionBuilder,
          (MediaManifestRow, $$MediaManifestRecordsTableReferences),
          MediaManifestRow,
          PrefetchHooks Function({bool sessionId})
        > {
  $$MediaManifestRecordsTableTableManager(
    _$AppDatabase db,
    $MediaManifestRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MediaManifestRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MediaManifestRecordsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$MediaManifestRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String?> assignmentId = const Value.absent(),
                Value<String?> roomNumber = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> relativePath = const Value.absent(),
                Value<String> checksumSha256 = const Value.absent(),
                Value<String> originDeviceId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String?> mimeType = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<String?> transcript = const Value.absent(),
                Value<int?> byteLength = const Value.absent(),
                Value<int?> widthPixels = const Value.absent(),
                Value<int?> heightPixels = const Value.absent(),
                Value<String?> originalExtension = const Value.absent(),
                Value<int?> orientation = const Value.absent(),
                Value<String?> colorSpace = const Value.absent(),
                Value<bool?> isHdr = const Value.absent(),
                Value<String?> lastCommandId = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MediaManifestRecordsCompanion(
                id: id,
                sessionId: sessionId,
                assignmentId: assignmentId,
                roomNumber: roomNumber,
                kind: kind,
                relativePath: relativePath,
                checksumSha256: checksumSha256,
                originDeviceId: originDeviceId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                mimeType: mimeType,
                durationMs: durationMs,
                transcript: transcript,
                byteLength: byteLength,
                widthPixels: widthPixels,
                heightPixels: heightPixels,
                originalExtension: originalExtension,
                orientation: orientation,
                colorSpace: colorSpace,
                isHdr: isHdr,
                lastCommandId: lastCommandId,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sessionId,
                Value<String?> assignmentId = const Value.absent(),
                Value<String?> roomNumber = const Value.absent(),
                required String kind,
                required String relativePath,
                required String checksumSha256,
                required String originDeviceId,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<String?> mimeType = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<String?> transcript = const Value.absent(),
                Value<int?> byteLength = const Value.absent(),
                Value<int?> widthPixels = const Value.absent(),
                Value<int?> heightPixels = const Value.absent(),
                Value<String?> originalExtension = const Value.absent(),
                Value<int?> orientation = const Value.absent(),
                Value<String?> colorSpace = const Value.absent(),
                Value<bool?> isHdr = const Value.absent(),
                Value<String?> lastCommandId = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MediaManifestRecordsCompanion.insert(
                id: id,
                sessionId: sessionId,
                assignmentId: assignmentId,
                roomNumber: roomNumber,
                kind: kind,
                relativePath: relativePath,
                checksumSha256: checksumSha256,
                originDeviceId: originDeviceId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                mimeType: mimeType,
                durationMs: durationMs,
                transcript: transcript,
                byteLength: byteLength,
                widthPixels: widthPixels,
                heightPixels: heightPixels,
                originalExtension: originalExtension,
                orientation: orientation,
                colorSpace: colorSpace,
                isHdr: isHdr,
                lastCommandId: lastCommandId,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MediaManifestRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
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
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable:
                                    $$MediaManifestRecordsTableReferences
                                        ._sessionIdTable(db),
                                referencedColumn:
                                    $$MediaManifestRecordsTableReferences
                                        ._sessionIdTable(db)
                                        .id,
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

typedef $$MediaManifestRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MediaManifestRecordsTable,
      MediaManifestRow,
      $$MediaManifestRecordsTableFilterComposer,
      $$MediaManifestRecordsTableOrderingComposer,
      $$MediaManifestRecordsTableAnnotationComposer,
      $$MediaManifestRecordsTableCreateCompanionBuilder,
      $$MediaManifestRecordsTableUpdateCompanionBuilder,
      (MediaManifestRow, $$MediaManifestRecordsTableReferences),
      MediaManifestRow,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$MediaPromotionRecordsTableCreateCompanionBuilder =
    MediaPromotionRecordsCompanion Function({
      required String operationId,
      required String commandId,
      required String mediaId,
      required String sessionId,
      Value<String?> roomNumber,
      Value<String?> assignmentId,
      required String kind,
      required String stagedRelativePath,
      required String transientFilePath,
      required String finalRelativePath,
      required String checksumSha256,
      required int byteLength,
      required String originDeviceId,
      required DateTime createdAt,
      required DateTime issuedAt,
      Value<String?> mimeType,
      Value<int?> durationMs,
      Value<String?> transcript,
      Value<int?> widthPixels,
      Value<int?> heightPixels,
      Value<String?> originalExtension,
      Value<int?> orientation,
      Value<String?> colorSpace,
      Value<bool?> isHdr,
      Value<DateTime?> quarantinedAt,
      Value<String?> failureReason,
      Value<int> rowid,
    });
typedef $$MediaPromotionRecordsTableUpdateCompanionBuilder =
    MediaPromotionRecordsCompanion Function({
      Value<String> operationId,
      Value<String> commandId,
      Value<String> mediaId,
      Value<String> sessionId,
      Value<String?> roomNumber,
      Value<String?> assignmentId,
      Value<String> kind,
      Value<String> stagedRelativePath,
      Value<String> transientFilePath,
      Value<String> finalRelativePath,
      Value<String> checksumSha256,
      Value<int> byteLength,
      Value<String> originDeviceId,
      Value<DateTime> createdAt,
      Value<DateTime> issuedAt,
      Value<String?> mimeType,
      Value<int?> durationMs,
      Value<String?> transcript,
      Value<int?> widthPixels,
      Value<int?> heightPixels,
      Value<String?> originalExtension,
      Value<int?> orientation,
      Value<String?> colorSpace,
      Value<bool?> isHdr,
      Value<DateTime?> quarantinedAt,
      Value<String?> failureReason,
      Value<int> rowid,
    });

final class $$MediaPromotionRecordsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $MediaPromotionRecordsTable,
          MediaPromotionRow
        > {
  $$MediaPromotionRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WorkSessionRecordsTable _sessionIdTable(_$AppDatabase db) =>
      db.workSessionRecords.createAlias(
        'media_promotion_records__session_id__work_session_records__id',
      );

  $$WorkSessionRecordsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$WorkSessionRecordsTableTableManager(
      $_db,
      $_db.workSessionRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MediaPromotionRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $MediaPromotionRecordsTable> {
  $$MediaPromotionRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get commandId => $composableBuilder(
    column: $table.commandId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mediaId => $composableBuilder(
    column: $table.mediaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get roomNumber => $composableBuilder(
    column: $table.roomNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assignmentId => $composableBuilder(
    column: $table.assignmentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stagedRelativePath => $composableBuilder(
    column: $table.stagedRelativePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transientFilePath => $composableBuilder(
    column: $table.transientFilePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get finalRelativePath => $composableBuilder(
    column: $table.finalRelativePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get checksumSha256 => $composableBuilder(
    column: $table.checksumSha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get byteLength => $composableBuilder(
    column: $table.byteLength,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originDeviceId => $composableBuilder(
    column: $table.originDeviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get issuedAt => $composableBuilder(
    column: $table.issuedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transcript => $composableBuilder(
    column: $table.transcript,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get widthPixels => $composableBuilder(
    column: $table.widthPixels,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get heightPixels => $composableBuilder(
    column: $table.heightPixels,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalExtension => $composableBuilder(
    column: $table.originalExtension,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orientation => $composableBuilder(
    column: $table.orientation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colorSpace => $composableBuilder(
    column: $table.colorSpace,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isHdr => $composableBuilder(
    column: $table.isHdr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get quarantinedAt => $composableBuilder(
    column: $table.quarantinedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get failureReason => $composableBuilder(
    column: $table.failureReason,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkSessionRecordsTableFilterComposer get sessionId {
    final $$WorkSessionRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.workSessionRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkSessionRecordsTableFilterComposer(
            $db: $db,
            $table: $db.workSessionRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MediaPromotionRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $MediaPromotionRecordsTable> {
  $$MediaPromotionRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get commandId => $composableBuilder(
    column: $table.commandId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mediaId => $composableBuilder(
    column: $table.mediaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get roomNumber => $composableBuilder(
    column: $table.roomNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assignmentId => $composableBuilder(
    column: $table.assignmentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stagedRelativePath => $composableBuilder(
    column: $table.stagedRelativePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transientFilePath => $composableBuilder(
    column: $table.transientFilePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get finalRelativePath => $composableBuilder(
    column: $table.finalRelativePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get checksumSha256 => $composableBuilder(
    column: $table.checksumSha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get byteLength => $composableBuilder(
    column: $table.byteLength,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originDeviceId => $composableBuilder(
    column: $table.originDeviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get issuedAt => $composableBuilder(
    column: $table.issuedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transcript => $composableBuilder(
    column: $table.transcript,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get widthPixels => $composableBuilder(
    column: $table.widthPixels,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get heightPixels => $composableBuilder(
    column: $table.heightPixels,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalExtension => $composableBuilder(
    column: $table.originalExtension,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orientation => $composableBuilder(
    column: $table.orientation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorSpace => $composableBuilder(
    column: $table.colorSpace,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isHdr => $composableBuilder(
    column: $table.isHdr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get quarantinedAt => $composableBuilder(
    column: $table.quarantinedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get failureReason => $composableBuilder(
    column: $table.failureReason,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkSessionRecordsTableOrderingComposer get sessionId {
    final $$WorkSessionRecordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.workSessionRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkSessionRecordsTableOrderingComposer(
            $db: $db,
            $table: $db.workSessionRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MediaPromotionRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MediaPromotionRecordsTable> {
  $$MediaPromotionRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get commandId =>
      $composableBuilder(column: $table.commandId, builder: (column) => column);

  GeneratedColumn<String> get mediaId =>
      $composableBuilder(column: $table.mediaId, builder: (column) => column);

  GeneratedColumn<String> get roomNumber => $composableBuilder(
    column: $table.roomNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get assignmentId => $composableBuilder(
    column: $table.assignmentId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get stagedRelativePath => $composableBuilder(
    column: $table.stagedRelativePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get transientFilePath => $composableBuilder(
    column: $table.transientFilePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get finalRelativePath => $composableBuilder(
    column: $table.finalRelativePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get checksumSha256 => $composableBuilder(
    column: $table.checksumSha256,
    builder: (column) => column,
  );

  GeneratedColumn<int> get byteLength => $composableBuilder(
    column: $table.byteLength,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originDeviceId => $composableBuilder(
    column: $table.originDeviceId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get issuedAt =>
      $composableBuilder(column: $table.issuedAt, builder: (column) => column);

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get transcript => $composableBuilder(
    column: $table.transcript,
    builder: (column) => column,
  );

  GeneratedColumn<int> get widthPixels => $composableBuilder(
    column: $table.widthPixels,
    builder: (column) => column,
  );

  GeneratedColumn<int> get heightPixels => $composableBuilder(
    column: $table.heightPixels,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originalExtension => $composableBuilder(
    column: $table.originalExtension,
    builder: (column) => column,
  );

  GeneratedColumn<int> get orientation => $composableBuilder(
    column: $table.orientation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get colorSpace => $composableBuilder(
    column: $table.colorSpace,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isHdr =>
      $composableBuilder(column: $table.isHdr, builder: (column) => column);

  GeneratedColumn<DateTime> get quarantinedAt => $composableBuilder(
    column: $table.quarantinedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get failureReason => $composableBuilder(
    column: $table.failureReason,
    builder: (column) => column,
  );

  $$WorkSessionRecordsTableAnnotationComposer get sessionId {
    final $$WorkSessionRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.sessionId,
          referencedTable: $db.workSessionRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkSessionRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.workSessionRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$MediaPromotionRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MediaPromotionRecordsTable,
          MediaPromotionRow,
          $$MediaPromotionRecordsTableFilterComposer,
          $$MediaPromotionRecordsTableOrderingComposer,
          $$MediaPromotionRecordsTableAnnotationComposer,
          $$MediaPromotionRecordsTableCreateCompanionBuilder,
          $$MediaPromotionRecordsTableUpdateCompanionBuilder,
          (MediaPromotionRow, $$MediaPromotionRecordsTableReferences),
          MediaPromotionRow,
          PrefetchHooks Function({bool sessionId})
        > {
  $$MediaPromotionRecordsTableTableManager(
    _$AppDatabase db,
    $MediaPromotionRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MediaPromotionRecordsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$MediaPromotionRecordsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$MediaPromotionRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> operationId = const Value.absent(),
                Value<String> commandId = const Value.absent(),
                Value<String> mediaId = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String?> roomNumber = const Value.absent(),
                Value<String?> assignmentId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> stagedRelativePath = const Value.absent(),
                Value<String> transientFilePath = const Value.absent(),
                Value<String> finalRelativePath = const Value.absent(),
                Value<String> checksumSha256 = const Value.absent(),
                Value<int> byteLength = const Value.absent(),
                Value<String> originDeviceId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> issuedAt = const Value.absent(),
                Value<String?> mimeType = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<String?> transcript = const Value.absent(),
                Value<int?> widthPixels = const Value.absent(),
                Value<int?> heightPixels = const Value.absent(),
                Value<String?> originalExtension = const Value.absent(),
                Value<int?> orientation = const Value.absent(),
                Value<String?> colorSpace = const Value.absent(),
                Value<bool?> isHdr = const Value.absent(),
                Value<DateTime?> quarantinedAt = const Value.absent(),
                Value<String?> failureReason = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MediaPromotionRecordsCompanion(
                operationId: operationId,
                commandId: commandId,
                mediaId: mediaId,
                sessionId: sessionId,
                roomNumber: roomNumber,
                assignmentId: assignmentId,
                kind: kind,
                stagedRelativePath: stagedRelativePath,
                transientFilePath: transientFilePath,
                finalRelativePath: finalRelativePath,
                checksumSha256: checksumSha256,
                byteLength: byteLength,
                originDeviceId: originDeviceId,
                createdAt: createdAt,
                issuedAt: issuedAt,
                mimeType: mimeType,
                durationMs: durationMs,
                transcript: transcript,
                widthPixels: widthPixels,
                heightPixels: heightPixels,
                originalExtension: originalExtension,
                orientation: orientation,
                colorSpace: colorSpace,
                isHdr: isHdr,
                quarantinedAt: quarantinedAt,
                failureReason: failureReason,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String operationId,
                required String commandId,
                required String mediaId,
                required String sessionId,
                Value<String?> roomNumber = const Value.absent(),
                Value<String?> assignmentId = const Value.absent(),
                required String kind,
                required String stagedRelativePath,
                required String transientFilePath,
                required String finalRelativePath,
                required String checksumSha256,
                required int byteLength,
                required String originDeviceId,
                required DateTime createdAt,
                required DateTime issuedAt,
                Value<String?> mimeType = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<String?> transcript = const Value.absent(),
                Value<int?> widthPixels = const Value.absent(),
                Value<int?> heightPixels = const Value.absent(),
                Value<String?> originalExtension = const Value.absent(),
                Value<int?> orientation = const Value.absent(),
                Value<String?> colorSpace = const Value.absent(),
                Value<bool?> isHdr = const Value.absent(),
                Value<DateTime?> quarantinedAt = const Value.absent(),
                Value<String?> failureReason = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MediaPromotionRecordsCompanion.insert(
                operationId: operationId,
                commandId: commandId,
                mediaId: mediaId,
                sessionId: sessionId,
                roomNumber: roomNumber,
                assignmentId: assignmentId,
                kind: kind,
                stagedRelativePath: stagedRelativePath,
                transientFilePath: transientFilePath,
                finalRelativePath: finalRelativePath,
                checksumSha256: checksumSha256,
                byteLength: byteLength,
                originDeviceId: originDeviceId,
                createdAt: createdAt,
                issuedAt: issuedAt,
                mimeType: mimeType,
                durationMs: durationMs,
                transcript: transcript,
                widthPixels: widthPixels,
                heightPixels: heightPixels,
                originalExtension: originalExtension,
                orientation: orientation,
                colorSpace: colorSpace,
                isHdr: isHdr,
                quarantinedAt: quarantinedAt,
                failureReason: failureReason,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MediaPromotionRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
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
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable:
                                    $$MediaPromotionRecordsTableReferences
                                        ._sessionIdTable(db),
                                referencedColumn:
                                    $$MediaPromotionRecordsTableReferences
                                        ._sessionIdTable(db)
                                        .id,
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

typedef $$MediaPromotionRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MediaPromotionRecordsTable,
      MediaPromotionRow,
      $$MediaPromotionRecordsTableFilterComposer,
      $$MediaPromotionRecordsTableOrderingComposer,
      $$MediaPromotionRecordsTableAnnotationComposer,
      $$MediaPromotionRecordsTableCreateCompanionBuilder,
      $$MediaPromotionRecordsTableUpdateCompanionBuilder,
      (MediaPromotionRow, $$MediaPromotionRecordsTableReferences),
      MediaPromotionRow,
      PrefetchHooks Function({bool sessionId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$HousekeeperCatalogRecordsTableTableManager get housekeeperCatalogRecords =>
      $$HousekeeperCatalogRecordsTableTableManager(
        _db,
        _db.housekeeperCatalogRecords,
      );
  $$WorkSessionRecordsTableTableManager get workSessionRecords =>
      $$WorkSessionRecordsTableTableManager(_db, _db.workSessionRecords);
  $$HousekeeperRecordsTableTableManager get housekeeperRecords =>
      $$HousekeeperRecordsTableTableManager(_db, _db.housekeeperRecords);
  $$WorkAssignmentRecordsTableTableManager get workAssignmentRecords =>
      $$WorkAssignmentRecordsTableTableManager(_db, _db.workAssignmentRecords);
  $$RoomStateRecordsTableTableManager get roomStateRecords =>
      $$RoomStateRecordsTableTableManager(_db, _db.roomStateRecords);
  $$RoomNoteRecordsTableTableManager get roomNoteRecords =>
      $$RoomNoteRecordsTableTableManager(_db, _db.roomNoteRecords);
  $$AssignmentNoteRecordsTableTableManager get assignmentNoteRecords =>
      $$AssignmentNoteRecordsTableTableManager(_db, _db.assignmentNoteRecords);
  $$CartConsumableRecordsTableTableManager get cartConsumableRecords =>
      $$CartConsumableRecordsTableTableManager(_db, _db.cartConsumableRecords);
  $$HistoryEventRecordsTableTableManager get historyEventRecords =>
      $$HistoryEventRecordsTableTableManager(_db, _db.historyEventRecords);
  $$CommandReceiptRecordsTableTableManager get commandReceiptRecords =>
      $$CommandReceiptRecordsTableTableManager(_db, _db.commandReceiptRecords);
  $$SyncOutboxRecordsTableTableManager get syncOutboxRecords =>
      $$SyncOutboxRecordsTableTableManager(_db, _db.syncOutboxRecords);
  $$SyncInboxRecordsTableTableManager get syncInboxRecords =>
      $$SyncInboxRecordsTableTableManager(_db, _db.syncInboxRecords);
  $$MediaManifestRecordsTableTableManager get mediaManifestRecords =>
      $$MediaManifestRecordsTableTableManager(_db, _db.mediaManifestRecords);
  $$MediaPromotionRecordsTableTableManager get mediaPromotionRecords =>
      $$MediaPromotionRecordsTableTableManager(_db, _db.mediaPromotionRecords);
}
