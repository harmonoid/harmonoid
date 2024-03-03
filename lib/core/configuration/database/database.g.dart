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
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<int> type = GeneratedColumn<int>(
      'type', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _booleanValueMeta =
      const VerificationMeta('booleanValue');
  @override
  late final GeneratedColumn<bool> booleanValue = GeneratedColumn<bool>(
      'boolean', aliasedName, true,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("boolean" IN (0, 1))'));
  static const VerificationMeta _integerValueMeta =
      const VerificationMeta('integerValue');
  @override
  late final GeneratedColumn<int> integerValue = GeneratedColumn<int>(
      'integer', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _stringValueMeta =
      const VerificationMeta('stringValue');
  @override
  late final GeneratedColumn<String> stringValue = GeneratedColumn<String>(
      'string', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _jsonValueMeta =
      const VerificationMeta('jsonValue');
  @override
  late final GeneratedColumn<String> jsonValue = GeneratedColumn<String>(
      'json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [key, type, booleanValue, integerValue, stringValue, jsonValue];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entries';
  @override
  VerificationContext validateIntegrity(Insertable<Entry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('boolean')) {
      context.handle(
          _booleanValueMeta,
          booleanValue.isAcceptableOrUnknown(
              data['boolean']!, _booleanValueMeta));
    }
    if (data.containsKey('integer')) {
      context.handle(
          _integerValueMeta,
          integerValue.isAcceptableOrUnknown(
              data['integer']!, _integerValueMeta));
    }
    if (data.containsKey('string')) {
      context.handle(_stringValueMeta,
          stringValue.isAcceptableOrUnknown(data['string']!, _stringValueMeta));
    }
    if (data.containsKey('json')) {
      context.handle(_jsonValueMeta,
          jsonValue.isAcceptableOrUnknown(data['json']!, _jsonValueMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  Entry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Entry(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}type'])!,
      booleanValue: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}boolean']),
      integerValue: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}integer']),
      stringValue: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}string']),
      jsonValue: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}json']),
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

  /// String value.
  final String? stringValue;

  /// JSON value.
  final String? jsonValue;
  const Entry(
      {required this.key,
      required this.type,
      this.booleanValue,
      this.integerValue,
      this.stringValue,
      this.jsonValue});
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
      stringValue: stringValue == null && nullToAbsent
          ? const Value.absent()
          : Value(stringValue),
      jsonValue: jsonValue == null && nullToAbsent
          ? const Value.absent()
          : Value(jsonValue),
    );
  }

  factory Entry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Entry(
      key: serializer.fromJson<String>(json['key']),
      type: serializer.fromJson<int>(json['type']),
      booleanValue: serializer.fromJson<bool?>(json['booleanValue']),
      integerValue: serializer.fromJson<int?>(json['integerValue']),
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
      'stringValue': serializer.toJson<String?>(stringValue),
      'jsonValue': serializer.toJson<String?>(jsonValue),
    };
  }

  Entry copyWith(
          {String? key,
          int? type,
          Value<bool?> booleanValue = const Value.absent(),
          Value<int?> integerValue = const Value.absent(),
          Value<String?> stringValue = const Value.absent(),
          Value<String?> jsonValue = const Value.absent()}) =>
      Entry(
        key: key ?? this.key,
        type: type ?? this.type,
        booleanValue:
            booleanValue.present ? booleanValue.value : this.booleanValue,
        integerValue:
            integerValue.present ? integerValue.value : this.integerValue,
        stringValue: stringValue.present ? stringValue.value : this.stringValue,
        jsonValue: jsonValue.present ? jsonValue.value : this.jsonValue,
      );
  @override
  String toString() {
    return (StringBuffer('Entry(')
          ..write('key: $key, ')
          ..write('type: $type, ')
          ..write('booleanValue: $booleanValue, ')
          ..write('integerValue: $integerValue, ')
          ..write('stringValue: $stringValue, ')
          ..write('jsonValue: $jsonValue')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      key, type, booleanValue, integerValue, stringValue, jsonValue);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Entry &&
          other.key == this.key &&
          other.type == this.type &&
          other.booleanValue == this.booleanValue &&
          other.integerValue == this.integerValue &&
          other.stringValue == this.stringValue &&
          other.jsonValue == this.jsonValue);
}

class EntriesCompanion extends UpdateCompanion<Entry> {
  final Value<String> key;
  final Value<int> type;
  final Value<bool?> booleanValue;
  final Value<int?> integerValue;
  final Value<String?> stringValue;
  final Value<String?> jsonValue;
  final Value<int> rowid;
  const EntriesCompanion({
    this.key = const Value.absent(),
    this.type = const Value.absent(),
    this.booleanValue = const Value.absent(),
    this.integerValue = const Value.absent(),
    this.stringValue = const Value.absent(),
    this.jsonValue = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EntriesCompanion.insert({
    required String key,
    required int type,
    this.booleanValue = const Value.absent(),
    this.integerValue = const Value.absent(),
    this.stringValue = const Value.absent(),
    this.jsonValue = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        type = Value(type);
  static Insertable<Entry> custom({
    Expression<String>? key,
    Expression<int>? type,
    Expression<bool>? booleanValue,
    Expression<int>? integerValue,
    Expression<String>? stringValue,
    Expression<String>? jsonValue,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (type != null) 'type': type,
      if (booleanValue != null) 'boolean': booleanValue,
      if (integerValue != null) 'integer': integerValue,
      if (stringValue != null) 'string': stringValue,
      if (jsonValue != null) 'json': jsonValue,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EntriesCompanion copyWith(
      {Value<String>? key,
      Value<int>? type,
      Value<bool?>? booleanValue,
      Value<int?>? integerValue,
      Value<String?>? stringValue,
      Value<String?>? jsonValue,
      Value<int>? rowid}) {
    return EntriesCompanion(
      key: key ?? this.key,
      type: type ?? this.type,
      booleanValue: booleanValue ?? this.booleanValue,
      integerValue: integerValue ?? this.integerValue,
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
          ..write('stringValue: $stringValue, ')
          ..write('jsonValue: $jsonValue, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$Database extends GeneratedDatabase {
  _$Database(QueryExecutor e) : super(e);
  late final $EntriesTable entries = $EntriesTable(this);
  late final Index indexEntriesTableKey = Index('index_entries_table_key',
      'CREATE INDEX index_entries_table_key ON entries ("key")');
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [entries, indexEntriesTableKey];
}
