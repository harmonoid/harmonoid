import 'package:media_kit/media_kit.dart';

import 'package:harmonoid/models/loop.dart';

/// Mappers for [Loop].
extension LoopMappers on Loop {
  /// Converts to [PlaylistMode].
  PlaylistMode toPlaylistMode() => switch (this) {
        Loop.off => PlaylistMode.none,
        Loop.one => PlaylistMode.single,
        Loop.all => PlaylistMode.loop,
      };
}
