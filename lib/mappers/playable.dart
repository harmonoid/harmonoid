import 'package:connections/connections.dart';
import 'package:flutter/widgets.dart';
import 'package:media_kit/media_kit.dart' hide Playable;
import 'package:mpris_service/mpris_service.dart';
import 'package:uri_parser/uri_parser.dart';

import 'package:harmonoid/extensions/string.dart';
import 'package:harmonoid/core/media_player/models/media_player_state.dart';
import 'package:harmonoid/core/media_player/models/playable.dart';
import 'package:harmonoid/state/lyrics/models/lyrics_key.dart';
import 'package:harmonoid/utils/async_file_image.dart';
import 'package:harmonoid/utils/rendering.dart';

/// Mappers for [Playable].
extension PlayableMappers on Playable {
  /// Converts to [Media].
  Media toMedia() => Media(uri, extras: toJson());

  /// Converts to [MPRISMetadata].
  Future<MPRISMetadata> toMPRISMetadata(MediaPlayerState state) async {
    final image = cover(uri: uri);
    final artUrl = switch (image) {
      AsyncFileImage() => (await image.getFile())?.uri,
      FileImage() => image.file.uri,
      NetworkImage() => Uri.parse(image.url),
      _ => null,
    };
    return MPRISMetadata(
      URIParser(uri).result,
      length: state.duration,
      artUrl: artUrl,
      album: description.firstOrNull,
      artist: subtitle,
      title: title,
    );
  }

  /// Converts to Last.fm [ScrobbleRequest].
  ScrobbleRequest? toLastfmScrobbleRequest(DateTime? timestamp, Duration? duration) {
    final artist = subtitle.firstOrNull?.nullIfBlank();
    final album = description.firstOrNull?.nullIfBlank();

    if (artist == null || timestamp == null || duration == null) return null;

    return ScrobbleRequest(
      artist: artist,
      track: title,
      album: album,
      timestamp: timestamp.millisecondsSinceEpoch ~/ 1000,
      duration: duration.inSeconds,
    );
  }

  /// Converts to Last.fm [UpdateNowPlayingRequest].
  UpdateNowPlayingRequest? toLastfmUpdateNowPlayingRequest(Duration? duration) {
    final artist = subtitle.firstOrNull?.nullIfBlank();
    final album = description.firstOrNull?.nullIfBlank();

    if (artist == null || duration == null) return null;

    return UpdateNowPlayingRequest(
      artist: artist,
      track: title,
      album: album,
      duration: duration.inSeconds,
    );
  }

  /// Converts to Listenbrainz [SubmitListensRequest].
  SubmitListensRequest? toListenbrainzSubmitListensRequest(DateTime? listenedAt, Duration? duration) {
    final artist = subtitle.firstOrNull?.nullIfBlank();
    final album = description.firstOrNull?.nullIfBlank();

    if (artist == null || listenedAt == null || duration == null) return null;

    return SubmitListensRequest(
      listenType: ListenType.single,
      payload: [
        SubmitListensPayload(
          listenedAt: listenedAt.millisecondsSinceEpoch ~/ 1000,
          trackMetadata: TrackMetadata(
            artistName: artist,
            trackName: title,
            releaseName: album,
            additionalInfo: AdditionalInfo(
              durationMs: duration.inMilliseconds,
            ),
          ),
        ),
      ],
    );
  }

  /// Converts to Listenbrainz [SubmitListensRequest].
  SubmitListensRequest? toListenbrainzPlayingNowRequest(Duration? duration) {
    final artist = subtitle.firstOrNull?.nullIfBlank();
    final album = description.firstOrNull?.nullIfBlank();

    if (artist == null || duration == null) return null;

    return SubmitListensRequest(
      listenType: ListenType.playingNow,
      payload: [
        SubmitListensPayload(
          trackMetadata: TrackMetadata(
            artistName: artist,
            trackName: title,
            releaseName: album,
            additionalInfo: AdditionalInfo(
              durationMs: duration.inMilliseconds,
            ),
          ),
        ),
      ],
    );
  }

  /// Converts to [LyricsKey].
  LyricsKey toLyricsKey() {
    return LyricsKey(
      track: title,
      artist: subtitle.firstOrNull ?? '',
    );
  }
}
