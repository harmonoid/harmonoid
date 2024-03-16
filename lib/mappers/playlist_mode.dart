import 'package:media_kit/media_kit.dart';

import 'package:harmonoid/models/loop.dart';

/// Mappers for [PlaylistMode].
extension PlaylistModeMappers on PlaylistMode {
  /// Converts to [Loop].
  Loop toLoop() {
    switch (this) {
      case PlaylistMode.none:
        return Loop.off;
      case PlaylistMode.single:
        return Loop.one;
      case PlaylistMode.loop:
        return Loop.all;
    }
  }
}
