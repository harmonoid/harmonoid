import 'package:flutter/widgets.dart';
import 'package:lastfm/lastfm.dart';
import 'package:media_kit/media_kit.dart' hide Playable;
import 'package:mpris_service/mpris_service.dart';
import 'package:uri_parser/uri_parser.dart';

import 'package:harmonoid/extensions/string.dart';
import 'package:harmonoid/models/media_player_state.dart';
import 'package:harmonoid/models/playable.dart';
import 'package:harmonoid/utils/async_file_image.dart';
import 'package:harmonoid/utils/rendering.dart';

/// Mappers for [Playable].
extension PlayableMappers on Playable {
  /// Convert to [Media].
  Media toMedia() => Media(uri, extras: toJson());

  /// Convert to [MPRISMetadata].
  Future<MPRISMetadata> toMPRISMetadata(MediaPlayerState state) async {
    final image = cover(uri: uri);
    final artUrl = switch (image) {
      AsyncFileImage() => (await image.file)?.uri,
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

  /// Convert to [ScrobbleRequest].
  ScrobbleRequest? toScrobbleRequest(DateTime? timestamp, Duration? duration) {
    final artist = subtitle.firstOrNull?.nullIfBlank();
    final album = description.firstOrNull?.nullIfBlank();

    if (artist == null || timestamp == null || duration == null || duration < const Duration(seconds: 30)) return null;

    return ScrobbleRequest(
      artist: artist,
      track: title,
      album: album,
      timestamp: timestamp.millisecondsSinceEpoch ~/ 1000,
      duration: duration.inSeconds,
    );
  }

  /// Convert to [UpdateNowPlayingRequest].
  UpdateNowPlayingRequest? toUpdateNowPlayingRequest(Duration? duration) {
    final artist = subtitle.firstOrNull?.nullIfBlank();
    final album = description.firstOrNull?.nullIfBlank();

    if (artist == null || duration == null || duration < const Duration(seconds: 30)) return null;

    return UpdateNowPlayingRequest(
      artist: artist,
      track: title,
      album: album,
      duration: duration.inSeconds,
    );
  }
}
