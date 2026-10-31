part of '../database.dart';

/// {@template lyrics_track_settings}
///
/// LyricsTrackSettings
/// -------------------
/// The table containing the per-track lyrics settings.
///
/// {@endtemplate}
@DataClassName('LyricsTrackSettingsEntity')
class LyricsTrackSettings extends Table {
  /// Track title.
  TextColumn get track => text().named('track')();

  /// Track artist.
  TextColumn get artist => text().named('artist')();

  /// Whether the lyrics are visible.
  /// NULL: Use global setting.
  BoolColumn get lyricsVisibility => boolean().nullable().named('lyrics_visibility')();

  /// Translation language.
  /// NULL: Use global setting.
  TextColumn get translationLanguage => text().nullable().named('translation_language')();

  /// Offset (in milliseconds).
  IntColumn get offset => integer().nullable().named('offset')();

  @override
  Set<Column> get primaryKey => {track, artist};
}
