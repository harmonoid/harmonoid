part of '../database.dart';

/// {@template lyricss}
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

  /// Lyrics.
  TextColumn get lyrics => text().named('lyrics').map(const LyricsConverter())();

  @override
  Set<Column> get primaryKey => {track, artist};
}
