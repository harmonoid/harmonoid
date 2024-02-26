import 'package:media_library/media_library.dart';

/// Extensions for [Track].
extension TrackExtensions on Track {
  /// Share subject.
  String get shareSubject => [
        title,
        artists.take(2).join(', '),
        album,
        year.toString(),
      ].where((e) => e.isNotEmpty).join(' • ');

  /// Playlist entry title.
  String get playlistEntryTitle => [
        title,
        artists.take(2).join(', '),
      ].where((e) => e.isNotEmpty).join(' • ');
}
