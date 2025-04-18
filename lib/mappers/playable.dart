import 'package:flutter/widgets.dart';
import 'package:media_kit/media_kit.dart' hide Playable;
import 'package:mpris_service/mpris_service.dart';
import 'package:uri_parser/uri_parser.dart';

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
}
