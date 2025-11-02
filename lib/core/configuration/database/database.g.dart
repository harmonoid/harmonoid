// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $EntriesTable extends Entries with TableInfo<$EntriesTable, Entry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<int> type = GeneratedColumn<int>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _booleanValueMeta = const VerificationMeta(
    'booleanValue',
  );
  @override
  late final GeneratedColumn<bool> booleanValue = GeneratedColumn<bool>(
    'boolean',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("boolean" IN (0, 1))',
    ),
  );
  static const VerificationMeta _integerValueMeta = const VerificationMeta(
    'integerValue',
  );
  @override
  late final GeneratedColumn<int> integerValue = GeneratedColumn<int>(
    'integer',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _doubleValueMeta = const VerificationMeta(
    'doubleValue',
  );
  @override
  late final GeneratedColumn<double> doubleValue = GeneratedColumn<double>(
    'double',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stringValueMeta = const VerificationMeta(
    'stringValue',
  );
  @override
  late final GeneratedColumn<String> stringValue = GeneratedColumn<String>(
    'string',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _jsonValueMeta = const VerificationMeta(
    'jsonValue',
  );
  @override
  late final GeneratedColumn<String> jsonValue = GeneratedColumn<String>(
    'json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    key,
    type,
    booleanValue,
    integerValue,
    doubleValue,
    stringValue,
    jsonValue,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<Entry> instance, {
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
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('boolean')) {
      context.handle(
        _booleanValueMeta,
        booleanValue.isAcceptableOrUnknown(data['boolean']!, _booleanValueMeta),
      );
    }
    if (data.containsKey('integer')) {
      context.handle(
        _integerValueMeta,
        integerValue.isAcceptableOrUnknown(data['integer']!, _integerValueMeta),
      );
    }
    if (data.containsKey('double')) {
      context.handle(
        _doubleValueMeta,
        doubleValue.isAcceptableOrUnknown(data['double']!, _doubleValueMeta),
      );
    }
    if (data.containsKey('string')) {
      context.handle(
        _stringValueMeta,
        stringValue.isAcceptableOrUnknown(data['string']!, _stringValueMeta),
      );
    }
    if (data.containsKey('json')) {
      context.handle(
        _jsonValueMeta,
        jsonValue.isAcceptableOrUnknown(data['json']!, _jsonValueMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  Entry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Entry(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}type'],
      )!,
      booleanValue: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}boolean'],
      ),
      integerValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}integer'],
      ),
      doubleValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}double'],
      ),
      stringValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}string'],
      ),
      jsonValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}json'],
      ),
    );
  }

  @override
  $EntriesTable createAlias(String alias) {
    return $EntriesTable(attachedDatabase, alias);
  }
}

class Entry extends DataClass implements Insertable<Entry> {
  /// Key.
  final String key;

  /// Type.
  final int type;

  /// Boolean value.
  final bool? booleanValue;

  /// Integer value.
  final int? integerValue;

  /// Double value.
  final double? doubleValue;

  /// String value.
  final String? stringValue;

  /// JSON value.
  final String? jsonValue;
  const Entry({
    required this.key,
    required this.type,
    this.booleanValue,
    this.integerValue,
    this.doubleValue,
    this.stringValue,
    this.jsonValue,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['type'] = Variable<int>(type);
    if (!nullToAbsent || booleanValue != null) {
      map['boolean'] = Variable<bool>(booleanValue);
    }
    if (!nullToAbsent || integerValue != null) {
      map['integer'] = Variable<int>(integerValue);
    }
    if (!nullToAbsent || doubleValue != null) {
      map['double'] = Variable<double>(doubleValue);
    }
    if (!nullToAbsent || stringValue != null) {
      map['string'] = Variable<String>(stringValue);
    }
    if (!nullToAbsent || jsonValue != null) {
      map['json'] = Variable<String>(jsonValue);
    }
    return map;
  }

  EntriesCompanion toCompanion(bool nullToAbsent) {
    return EntriesCompanion(
      key: Value(key),
      type: Value(type),
      booleanValue: booleanValue == null && nullToAbsent
          ? const Value.absent()
          : Value(booleanValue),
      integerValue: integerValue == null && nullToAbsent
          ? const Value.absent()
          : Value(integerValue),
      doubleValue: doubleValue == null && nullToAbsent
          ? const Value.absent()
          : Value(doubleValue),
      stringValue: stringValue == null && nullToAbsent
          ? const Value.absent()
          : Value(stringValue),
      jsonValue: jsonValue == null && nullToAbsent
          ? const Value.absent()
          : Value(jsonValue),
    );
  }

  factory Entry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Entry(
      key: serializer.fromJson<String>(json['key']),
      type: serializer.fromJson<int>(json['type']),
      booleanValue: serializer.fromJson<bool?>(json['booleanValue']),
      integerValue: serializer.fromJson<int?>(json['integerValue']),
      doubleValue: serializer.fromJson<double?>(json['doubleValue']),
      stringValue: serializer.fromJson<String?>(json['stringValue']),
      jsonValue: serializer.fromJson<String?>(json['jsonValue']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'type': serializer.toJson<int>(type),
      'booleanValue': serializer.toJson<bool?>(booleanValue),
      'integerValue': serializer.toJson<int?>(integerValue),
      'doubleValue': serializer.toJson<double?>(doubleValue),
      'stringValue': serializer.toJson<String?>(stringValue),
      'jsonValue': serializer.toJson<String?>(jsonValue),
    };
  }

  Entry copyWith({
    String? key,
    int? type,
    Value<bool?> booleanValue = const Value.absent(),
    Value<int?> integerValue = const Value.absent(),
    Value<double?> doubleValue = const Value.absent(),
    Value<String?> stringValue = const Value.absent(),
    Value<String?> jsonValue = const Value.absent(),
  }) => Entry(
    key: key ?? this.key,
    type: type ?? this.type,
    booleanValue: booleanValue.present ? booleanValue.value : this.booleanValue,
    integerValue: integerValue.present ? integerValue.value : this.integerValue,
    doubleValue: doubleValue.present ? doubleValue.value : this.doubleValue,
    stringValue: stringValue.present ? stringValue.value : this.stringValue,
    jsonValue: jsonValue.present ? jsonValue.value : this.jsonValue,
  );
  Entry copyWithCompanion(EntriesCompanion data) {
    return Entry(
      key: data.key.present ? data.key.value : this.key,
      type: data.type.present ? data.type.value : this.type,
      booleanValue: data.booleanValue.present
          ? data.booleanValue.value
          : this.booleanValue,
      integerValue: data.integerValue.present
          ? data.integerValue.value
          : this.integerValue,
      doubleValue: data.doubleValue.present
          ? data.doubleValue.value
          : this.doubleValue,
      stringValue: data.stringValue.present
          ? data.stringValue.value
          : this.stringValue,
      jsonValue: data.jsonValue.present ? data.jsonValue.value : this.jsonValue,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Entry(')
          ..write('key: $key, ')
          ..write('type: $type, ')
          ..write('booleanValue: $booleanValue, ')
          ..write('integerValue: $integerValue, ')
          ..write('doubleValue: $doubleValue, ')
          ..write('stringValue: $stringValue, ')
          ..write('jsonValue: $jsonValue')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    key,
    type,
    booleanValue,
    integerValue,
    doubleValue,
    stringValue,
    jsonValue,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Entry &&
          other.key == this.key &&
          other.type == this.type &&
          other.booleanValue == this.booleanValue &&
          other.integerValue == this.integerValue &&
          other.doubleValue == this.doubleValue &&
          other.stringValue == this.stringValue &&
          other.jsonValue == this.jsonValue);
}

class EntriesCompanion extends UpdateCompanion<Entry> {
  final Value<String> key;
  final Value<int> type;
  final Value<bool?> booleanValue;
  final Value<int?> integerValue;
  final Value<double?> doubleValue;
  final Value<String?> stringValue;
  final Value<String?> jsonValue;
  final Value<int> rowid;
  const EntriesCompanion({
    this.key = const Value.absent(),
    this.type = const Value.absent(),
    this.booleanValue = const Value.absent(),
    this.integerValue = const Value.absent(),
    this.doubleValue = const Value.absent(),
    this.stringValue = const Value.absent(),
    this.jsonValue = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EntriesCompanion.insert({
    required String key,
    required int type,
    this.booleanValue = const Value.absent(),
    this.integerValue = const Value.absent(),
    this.doubleValue = const Value.absent(),
    this.stringValue = const Value.absent(),
    this.jsonValue = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       type = Value(type);
  static Insertable<Entry> custom({
    Expression<String>? key,
    Expression<int>? type,
    Expression<bool>? booleanValue,
    Expression<int>? integerValue,
    Expression<double>? doubleValue,
    Expression<String>? stringValue,
    Expression<String>? jsonValue,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (type != null) 'type': type,
      if (booleanValue != null) 'boolean': booleanValue,
      if (integerValue != null) 'integer': integerValue,
      if (doubleValue != null) 'double': doubleValue,
      if (stringValue != null) 'string': stringValue,
      if (jsonValue != null) 'json': jsonValue,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EntriesCompanion copyWith({
    Value<String>? key,
    Value<int>? type,
    Value<bool?>? booleanValue,
    Value<int?>? integerValue,
    Value<double?>? doubleValue,
    Value<String?>? stringValue,
    Value<String?>? jsonValue,
    Value<int>? rowid,
  }) {
    return EntriesCompanion(
      key: key ?? this.key,
      type: type ?? this.type,
      booleanValue: booleanValue ?? this.booleanValue,
      integerValue: integerValue ?? this.integerValue,
      doubleValue: doubleValue ?? this.doubleValue,
      stringValue: stringValue ?? this.stringValue,
      jsonValue: jsonValue ?? this.jsonValue,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(type.value);
    }
    if (booleanValue.present) {
      map['boolean'] = Variable<bool>(booleanValue.value);
    }
    if (integerValue.present) {
      map['integer'] = Variable<int>(integerValue.value);
    }
    if (doubleValue.present) {
      map['double'] = Variable<double>(doubleValue.value);
    }
    if (stringValue.present) {
      map['string'] = Variable<String>(stringValue.value);
    }
    if (jsonValue.present) {
      map['json'] = Variable<String>(jsonValue.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntriesCompanion(')
          ..write('key: $key, ')
          ..write('type: $type, ')
          ..write('booleanValue: $booleanValue, ')
          ..write('integerValue: $integerValue, ')
          ..write('doubleValue: $doubleValue, ')
          ..write('stringValue: $stringValue, ')
          ..write('jsonValue: $jsonValue, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$Database extends GeneratedDatabase {
  _$Database(QueryExecutor e) : super(e);
  $DatabaseManager get managers => $DatabaseManager(this);
  late final $EntriesTable entries = $EntriesTable(this);
  late final Index indexEntriesTableKey = Index(
    'index_entries_table_key',
    'CREATE INDEX index_entries_table_key ON entries ("key")',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    entries,
    indexEntriesTableKey,
  ];
}

typedef $$EntriesTableCreateCompanionBuilder =
    EntriesCompanion Function({
      required String key,
      required int type,
      Value<bool?> booleanValue,
      Value<int?> integerValue,
      Value<double?> doubleValue,
      Value<String?> stringValue,
      Value<String?> jsonValue,
      Value<int> rowid,
    });
typedef $$EntriesTableUpdateCompanionBuilder =
    EntriesCompanion Function({
      Value<String> key,
      Value<int> type,
      Value<bool?> booleanValue,
      Value<int?> integerValue,
      Value<double?> doubleValue,
      Value<String?> stringValue,
      Value<String?> jsonValue,
      Value<int> rowid,
    });

class $$EntriesTableFilterComposer extends Composer<_$Database, $EntriesTable> {
  $$EntriesTableFilterComposer({
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

  ColumnFilters<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get booleanValue => $composableBuilder(
    column: $table.booleanValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get integerValue => $composableBuilder(
    column: $table.integerValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get doubleValue => $composableBuilder(
    column: $table.doubleValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stringValue => $composableBuilder(
    column: $table.stringValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jsonValue => $composableBuilder(
    column: $table.jsonValue,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EntriesTableOrderingComposer
    extends Composer<_$Database, $EntriesTable> {
  $$EntriesTableOrderingComposer({
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

  ColumnOrderings<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get booleanValue => $composableBuilder(
    column: $table.booleanValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get integerValue => $composableBuilder(
    column: $table.integerValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get doubleValue => $composableBuilder(
    column: $table.doubleValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stringValue => $composableBuilder(
    column: $table.stringValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jsonValue => $composableBuilder(
    column: $table.jsonValue,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EntriesTableAnnotationComposer
    extends Composer<_$Database, $EntriesTable> {
  $$EntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<bool> get booleanValue => $composableBuilder(
    column: $table.booleanValue,
    builder: (column) => column,
  );

  GeneratedColumn<int> get integerValue => $composableBuilder(
    column: $table.integerValue,
    builder: (column) => column,
  );

  GeneratedColumn<double> get doubleValue => $composableBuilder(
    column: $table.doubleValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get stringValue => $composableBuilder(
    column: $table.stringValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get jsonValue =>
      $composableBuilder(column: $table.jsonValue, builder: (column) => column);
}

class $$EntriesTableTableManager
    extends
        RootTableManager<
          _$Database,
          $EntriesTable,
          Entry,
          $$EntriesTableFilterComposer,
          $$EntriesTableOrderingComposer,
          $$EntriesTableAnnotationComposer,
          $$EntriesTableCreateCompanionBuilder,
          $$EntriesTableUpdateCompanionBuilder,
          (Entry, BaseReferences<_$Database, $EntriesTable, Entry>),
          Entry,
          PrefetchHooks Function()
        > {
  $$EntriesTableTableManager(_$Database db, $EntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<int> type = const Value.absent(),
                Value<bool?> booleanValue = const Value.absent(),
                Value<int?> integerValue = const Value.absent(),
                Value<double?> doubleValue = const Value.absent(),
                Value<String?> stringValue = const Value.absent(),
                Value<String?> jsonValue = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EntriesCompanion(
                key: key,
                type: type,
                booleanValue: booleanValue,
                integerValue: integerValue,
                doubleValue: doubleValue,
                stringValue: stringValue,
                jsonValue: jsonValue,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required int type,
                Value<bool?> booleanValue = const Value.absent(),
                Value<int?> integerValue = const Value.absent(),
                Value<double?> doubleValue = const Value.absent(),
                Value<String?> stringValue = const Value.absent(),
                Value<String?> jsonValue = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EntriesCompanion.insert(
                key: key,
                type: type,
                booleanValue: booleanValue,
                integerValue: integerValue,
                doubleValue: doubleValue,
                stringValue: stringValue,
                jsonValue: jsonValue,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$Database,
      $EntriesTable,
      Entry,
      $$EntriesTableFilterComposer,
      $$EntriesTableOrderingComposer,
      $$EntriesTableAnnotationComposer,
      $$EntriesTableCreateCompanionBuilder,
      $$EntriesTableUpdateCompanionBuilder,
      (Entry, BaseReferences<_$Database, $EntriesTable, Entry>),
      Entry,
      PrefetchHooks Function()
    >;

class $DatabaseManager {
  final _$Database _db;
  $DatabaseManager(this._db);
  $$EntriesTableTableManager get entries =>
      $$EntriesTableTableManager(_db, _db.entries);
}
