import 'package:media_library/media_library.dart';
import 'package:tag_reader/tag_reader.dart';

/// Mappers for [Tags].
extension TagsExtension on Tags {
  /// Convert to [Track].
  Track toTrack() => Track(
        uri: uri,
        title: title,
        album: album,
        albumArtist: albumArtist,
        discNumber: discNumber,
        trackNumber: trackNumber,
        albumLength: albumLength,
        year: year,
        lyrics: lyrics,
        duration: duration,
        bitrate: bitrate,
        timestamp: timestamp,
        artists: artists,
        genres: genres,
      );
}
