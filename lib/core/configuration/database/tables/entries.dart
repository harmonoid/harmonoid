part of '../database.dart';

/// {@template entries}
///
/// Entries
/// -------
/// Table containing entries in the configuration database.
///
/// {@endtemplate}
@DataClassName('Entry')
@TableIndex(name: 'index_entries_table_key', columns: {#key})
class Entries extends Table {
  /// Key.
  TextColumn get key => text().named('key')();

  /// Type.
  IntColumn get type => integer().named('type')();

  /// Boolean value.
  BoolColumn get booleanValue => boolean().named('boolean').nullable()();

  /// Integer value.
  IntColumn get integerValue => integer().named('integer').nullable()();

  /// Double value.
  RealColumn get doubleValue => real().named('double').nullable()();

  /// String value.
  TextColumn get stringValue => text().named('string').nullable()();

  /// JSON value.
  TextColumn get jsonValue => text().named('json').nullable()();

  @override
  Set<Column> get primaryKey => {key};
}
