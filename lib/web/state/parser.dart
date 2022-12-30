import 'package:ytm_client/ytm_client.dart' as ytm_client;
import 'package:media_library/media_library.dart' as media_library;

/// For converting between `package:media_library` and `package:ytm_client` models.
/// Assign possible equivalent values to the fields of `package:media_library` model.
class Parser {
  static media_library.Track track(ytm_client.Track track) =>
      media_library.Track(
        uri: track.uri,
        trackName: track.trackName,
        albumName: track.albumName,
        trackNumber: track.trackNumber,
        discNumber: 1,
        albumLength: 1,
        albumArtistName: track.albumArtistName,
        trackArtistNames: track.trackArtistNames,
        authorNames: [media_library.kUnknownAuthor],
        writerNames: [media_library.kUnknownWriter],
        year: track.year,
        genres: [media_library.kUnknownGenre],
        lyrics: null,
        timeAdded: DateTime.now(),
        duration: track.duration,
        bitrate: null,
      );

  static media_library.Track video(ytm_client.Video video) =>
      media_library.Track(
        uri: video.uri,
        trackName: video.videoName,
        albumName: video.channelName,
        trackNumber: 1,
        discNumber: 1,
        albumLength: 1,
        albumArtistName: video.channelName,
        trackArtistNames: [video.channelName],
        authorNames: [media_library.kUnknownAuthor],
        writerNames: [media_library.kUnknownWriter],
        year: media_library.kUnknownYear,
        genres: [media_library.kUnknownGenre],
        lyrics: null,
        timeAdded: DateTime.now(),
        duration: video.duration,
        bitrate: null,
      );
}
