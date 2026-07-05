import 'dart:io';
import 'package:media_library/media_library.dart';
import 'package:path/path.dart';

import 'package:harmonoid/mappers/track.dart';
import 'package:harmonoid/core/media_player/models/playable.dart';

/// Mappers for [File].
extension FileMappers on File {
  /// Converts to [Playable].
  Playable toPlayable([MediaLibrary? mediaLibrary]) {
    return mediaLibrary?.lookupTrack(TrackLookupKey(uri: normalize(path)))?.toPlayable() ?? Playable(uri: normalize(path), title: basename(path), subtitle: [], description: []);
  }
}
