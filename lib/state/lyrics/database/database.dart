import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as path;

import 'package:harmonoid/state/lyrics/models/lyric.dart';
import 'package:harmonoid/state/lyrics/models/lyrics.dart';
import 'package:harmonoid/state/lyrics/models/lyrics_translation.dart';
import 'package:harmonoid/state/lyrics/models/lyrics_key.dart';
import 'package:harmonoid/state/lyrics/models/lyrics_translation_key.dart';

part 'tables/lyrics_entries.dart';
part 'tables/lyrics_translation_entries.dart';

part 'database.g.dart';

/// {@template lyrics_database}
///
/// LyricsDatabase
/// --------------
/// The package:drift database containing cached lyrics and lyrics translations.
/// NOTE: The reported duration can vary between media_kit & tag_reader. So, omit duration from the query.
///
/// {@endtemplate}
@DriftDatabase(tables: [Lyricss, LyricsTranslations])
class LyricsDatabase extends _$LyricsDatabase {
  /// {@macro lyrics_database}
  LyricsDatabase(Directory directory) : super(_openConnection(directory));

  @override
  int get schemaVersion => 1;

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
        duration: key.duration,
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
        duration: key.duration,
        language: key.language,
        lyrics: lyricsTranslation.lyrics,
        same: lyricsTranslation.same,
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  static LazyDatabase _openConnection(Directory directory) {
    return LazyDatabase(() async {
      final file = File(path.join(directory.path, 'Lyrics.DB'));
      return NativeDatabase(file);
    });
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
