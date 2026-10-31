import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/internal/versioned_schema.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

import 'package:harmonoid/state/lyrics/database/database.steps.dart';
import 'package:harmonoid/state/lyrics/models/lyric.dart';
import 'package:harmonoid/state/lyrics/models/lyrics.dart';
import 'package:harmonoid/state/lyrics/models/lyrics_key.dart';
import 'package:harmonoid/state/lyrics/models/lyrics_translation.dart';
import 'package:harmonoid/state/lyrics/models/lyrics_translation_key.dart';

part 'database.g.dart';
part 'tables/lyrics_track_settings.dart';
part 'tables/lyrics_translations.dart';
part 'tables/lyricss.dart';

/// {@template lyrics_database}
///
/// LyricsDatabase
/// --------------
/// The package:drift database containing cached lyrics, lyrics translations & per-track lyrics settings.
/// NOTE: The reported duration can vary between media_kit & tag_reader. So, omit duration from the query.
///
/// {@endtemplate}
@DriftDatabase(tables: [Lyricss, LyricsTranslations, LyricsTrackSettings])
class LyricsDatabase extends _$LyricsDatabase {
  /// {@macro lyrics_database}
  LyricsDatabase(Directory directory, [QueryExecutor? connection]) : super(connection ?? _openConnection(directory));

  @override
  int get schemaVersion => 2;

  /// Gets the cached lyrics with the given [key].
  Future<Lyrics?> getLyrics(LyricsKey key) async {
    final query = select(lyricss)..where((e) => e.track.equals(key.track) & e.artist.equals(key.artist));
    final entry = await query.getSingleOrNull();
    return entry?.lyrics;
  }

  /// Gets whether the cached lyrics exist with the given [key].
  Future<bool> containsLyrics(LyricsKey key) async {
    final count = countAll();
    final query = selectOnly(lyricss)
      ..addColumns([count])
      ..where(lyricss.track.equals(key.track) & lyricss.artist.equals(key.artist));
    final row = await query.getSingle();
    return row.read(count)! > 0;
  }

  /// Sets the cached [lyrics] with the given [key].
  Future<void> setLyrics(LyricsKey key, Lyrics lyrics) async {
    await into(lyricss).insert(
      LyricsEntity(
        track: key.track,
        artist: key.artist,
        lyrics: lyrics,
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  /// Removes the cached lyrics with the given [key].
  Future<void> removeLyrics(LyricsKey key) async {
    final query = delete(lyricss)..where((e) => e.track.equals(key.track) & e.artist.equals(key.artist));
    await query.go();
  }

  /// Gets the cached lyrics translation with the given [key].
  Future<LyricsTranslation?> getLyricsTranslation(LyricsTranslationKey key) async {
    final query = select(lyricsTranslations)..where((e) => e.track.equals(key.track) & e.artist.equals(key.artist) & e.language.equals(key.language));
    final entry = await query.getSingleOrNull();
    if (entry == null) return null;
    return LyricsTranslation(
      same: entry.same,
      lyrics: entry.lyrics,
    );
  }

  /// Sets the cached [lyricsTranslation] with the given [key].
  Future<void> setLyricsTranslation(LyricsTranslationKey key, LyricsTranslation lyricsTranslation) async {
    await into(lyricsTranslations).insert(
      LyricsTranslationEntity(
        track: key.track,
        artist: key.artist,
        language: key.language,
        lyrics: lyricsTranslation.lyrics,
        same: lyricsTranslation.same,
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  /// Gets the per-track lyrics settings with the given [key].
  Future<LyricsTrackSettingsEntity?> getLyricsTrackSettings(LyricsKey key) async {
    final query = select(lyricsTrackSettings)..where((e) => e.track.equals(key.track) & e.artist.equals(key.artist));
    return await query.getSingleOrNull();
  }

  /// Sets the per-track lyrics settings with the given [key].
  Future<void> setLyricsTrackSettings(LyricsKey key, {bool? lyricsVisibility, String? translationLanguage, int? offset}) async {
    await into(lyricsTrackSettings).insert(
      LyricsTrackSettingsEntity(
        track: key.track,
        artist: key.artist,
        lyricsVisibility: lyricsVisibility,
        translationLanguage: translationLanguage,
        offset: offset,
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  /// Removes the per-track lyrics settings with the given [key].
  Future<void> removeLyricsTrackSettings(LyricsKey key) async {
    final query = delete(lyricsTrackSettings)..where((e) => e.track.equals(key.track) & e.artist.equals(key.artist));
    await query.go();
  }

  /// Removes the per-track lyrics visibility setting for all tracks.
  Future<void> clearLyricsVisibilityTrackSettings() async {
    await update(lyricsTrackSettings).write(const LyricsTrackSettingsCompanion(lyricsVisibility: Value(null)));
  }

  static LazyDatabase _openConnection(Directory directory) {
    return LazyDatabase(() async {
      final file = File(path.join(directory.path, 'Lyrics.DB'));
      return NativeDatabase(file);
    });
  }

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onUpgrade: (m, from, to) async {
        // https://drift.simonbinder.eu/Migrations/api/#general-tips
        // https://github.com/simolus3/drift/blob/develop/examples/migrations_example/lib/database.dart
        await transaction(
          () => VersionedSchema.runMigrationSteps(
            migrator: m,
            from: from,
            to: to,
            steps: migrationSteps(
              from1To2: (m, schema) async {
                debugPrint('Migrating Lyrics DB from v1 to v2...');

                // Collapse duplicate lyrics across durations, keeping the last entry.
                // Idempotent, so a retry after a crash or termination in the middle is safe.
                try {
                  await customStatement('''
                  DELETE FROM lyricss
                  WHERE rowid NOT IN (
                    SELECT MAX(rowid)
                    FROM lyricss
                    GROUP BY track, artist
                  )
                ''');
                } catch (exception, stacktrace) {
                  debugPrint(exception.toString());
                  debugPrint(stacktrace.toString());
                }
                // Collapse duplicate translations across durations, keeping the last entry.
                // Idempotent, so a retry after a crash or termination in the middle is safe.
                try {
                  await customStatement('''
                  DELETE FROM lyrics_translations
                  WHERE rowid NOT IN (
                    SELECT MAX(rowid)
                    FROM lyrics_translations
                    GROUP BY track, artist, language
                  )
                ''');
                } catch (exception, stacktrace) {
                  debugPrint(exception.toString());
                  debugPrint(stacktrace.toString());
                }

                await m.alterTable(TableMigration(schema.lyricss));
                await m.alterTable(TableMigration(schema.lyricsTranslations));
                await m.createTable(schema.lyricsTrackSettings);
              },
            ),
          ),
        );
      },
    );
  }
}

class LyricsConverter extends TypeConverter<Lyrics, String> with JsonTypeConverter<Lyrics, String> {
  const LyricsConverter();

  @override
  Lyrics fromSql(String fromDb) {
    final decoded = json.decode(fromDb) as List;
    return decoded.map<Lyric>((e) => Lyric.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  @override
  String toSql(Lyrics value) {
    return json.encode(value.map((e) => e.toJson()).toList());
  }
}
