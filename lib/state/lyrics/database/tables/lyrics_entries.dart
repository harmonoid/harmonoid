part of '../database.dart';

/// {@template lyrics_entries}
///
/// Lyricss
/// -------
/// The table containing the cached lyrics.
///
/// {@endtemplate}
@DataClassName('LyricsEntity')
class Lyricss extends Table {
  /// Track title.
  TextColumn get track => text().named('track')();

  /// Track artist.
  TextColumn get artist => text().named('artist')();

  /// Track duration (in milliseconds).
  IntColumn get duration => integer().named('duration')();

  /// Lyrics.
  TextColumn get lyrics => text().named('lyrics').map(const LyricsConverter())();

  @override
  Set<Column> get primaryKey => {track, artist, duration};
}
