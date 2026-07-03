part of '../database.dart';

/// {@template lyrics_translation_entries}
///
/// LyricsTranslations
/// ------------------
/// The table containing the cached lyrics translations.
///
/// {@endtemplate}
@DataClassName('LyricsTranslationEntity')
class LyricsTranslations extends Table {
  /// Track title.
  TextColumn get track => text().named('track')();

  /// Track artist.
  TextColumn get artist => text().named('artist')();

  /// Track duration (in milliseconds).
  IntColumn get duration => integer().named('duration')();

  /// Target language code.
  TextColumn get language => text().named('language')();

  /// Translated lyrics. Null when [same] is true.
  TextColumn get lyrics => text().named('lyrics').map(const LyricsConverter()).nullable()();

  /// Whether the target language is the same as the source lyrics language.
  BoolColumn get same => boolean().named('same')();

  @override
  Set<Column> get primaryKey => {track, artist, duration, language};
}
