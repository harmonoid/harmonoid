import 'package:media_kit/media_kit.dart';

import 'package:harmonoid/models/loop.dart';

/// Mappers for [Loop].
extension LoopMappers on Loop {
  /// Converts to [PlaylistMode].
  PlaylistMode toPlaylistMode() {
    switch (this) {
      case Loop.off:
        return PlaylistMode.none;
      case Loop.one:
        return PlaylistMode.single;
      case Loop.all:
        return PlaylistMode.loop;
    }
  }
}
