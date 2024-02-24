// ignore_for_file: unnecessary_null_comparison

import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

import 'package:harmonoid/core/configuration/database/constants.dart';

part 'tables/entries.dart';

part 'database.g.dart';

/// {@template database}
///
/// Database
/// --------
/// The package:drift (SQLite based) database containing the application's configuration.
///
/// {@endtemplate}
@DriftDatabase(tables: [Entries])
class Database extends _$Database {
  Database(Directory directory) : super(_openConnection(directory));

  @override
  int get schemaVersion => 1;

  /// Sets the value of the entry with the given [key].
  Future<void> setValue(
    String key,
    int type, {
    bool? booleanValue,
    int? integerValue,
    String? stringValue,
    dynamic jsonValue,
  }) async {
    if (!(type == kTypeBoolean && booleanValue != null && integerValue == null && stringValue == null && jsonValue == null)) {
      throw ArgumentError('Invalid type: boolean', 'type');
    }
    if (!(type == kTypeInteger && booleanValue == null && integerValue != null && stringValue == null && jsonValue == null)) {
      throw ArgumentError('Invalid type: integer', 'type');
    }
    if (!(type == kTypeString && booleanValue == null && integerValue == null && stringValue != null && jsonValue == null)) {
      throw ArgumentError('Invalid type: string', 'type');
    }
    if (!(type == kTypeJson && booleanValue == null && integerValue == null && stringValue == null && jsonValue != null)) {
      throw ArgumentError('Invalid type: json', 'type');
    }

    await into(entries).insert(
      Entry(
        key: key,
        type: type,
        booleanValue: booleanValue,
        integerValue: integerValue,
        stringValue: stringValue,
        jsonValue: json.encode(jsonValue),
      ),
      mode: InsertMode.replace,
    );
  }

  /// Sets the value of the entry with the given [key] if it does not exist.
  Future<void> setValueIfAbsent(
    String key,
    int type, {
    bool? booleanValue,
    int? integerValue,
    String? stringValue,
    dynamic jsonValue,
  }) async {
    if (!(type == kTypeBoolean && booleanValue != null && integerValue == null && stringValue == null && jsonValue == null)) {
      throw ArgumentError('Invalid type: boolean', 'type');
    }
    if (!(type == kTypeInteger && booleanValue == null && integerValue != null && stringValue == null && jsonValue == null)) {
      throw ArgumentError('Invalid type: integer', 'type');
    }
    if (!(type == kTypeString && booleanValue == null && integerValue == null && stringValue != null && jsonValue == null)) {
      throw ArgumentError('Invalid type: string', 'type');
    }
    if (!(type == kTypeJson && booleanValue == null && integerValue == null && stringValue == null && jsonValue != null)) {
      throw ArgumentError('Invalid type: json', 'type');
    }

    await into(entries).insert(
      Entry(
        key: key,
        type: type,
        booleanValue: booleanValue,
        integerValue: integerValue,
        stringValue: stringValue,
        jsonValue: json.encode(jsonValue),
      ),
      mode: InsertMode.insertOrIgnore,
    );
  }

  /// Gets the boolean value of the entry with the given [key].
  Future<bool?> getBoolean(String key) async {
    final entry = await (select(entries)..where((e) => e.key.equals(key))).getSingleOrNull();
    return entry?.booleanValue;
  }

  /// Gets the integer value of the entry with the given [key].
  Future<int?> getInteger(String key) async {
    final entry = await (select(entries)..where((e) => e.key.equals(key))).getSingleOrNull();
    return entry?.integerValue;
  }

  /// Gets the string value of the entry with the given [key].
  Future<String?> getString(String key) async {
    final entry = await (select(entries)..where((e) => e.key.equals(key))).getSingleOrNull();
    return entry?.stringValue;
  }

  /// Gets the JSON value of the entry with the given [key].
  Future<dynamic> getJson(String key) async {
    final entry = await (select(entries)..where((e) => e.key.equals(key))).getSingleOrNull();
    return entry == null ? null : json.decode(entry.jsonValue);
  }

  static LazyDatabase _openConnection(Directory directory) {
    return LazyDatabase(() async {
      // https://drift.simonbinder.eu/docs/getting-started
      if (Platform.isAndroid) {
        await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
      }
      final cachebase = (await getTemporaryDirectory()).path;
      sqlite3.tempDirectory = cachebase;

      final file = File(path.join(directory.path, 'Configuration.DB'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
