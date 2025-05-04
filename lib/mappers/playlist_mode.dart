import 'package:media_kit/media_kit.dart';

import 'package:harmonoid/models/loop.dart';

/// Mappers for [PlaylistMode].
extension PlaylistModeMappers on PlaylistMode {
  /// Converts to [Loop].
  Loop toLoop() => switch (this) {
        PlaylistMode.none => Loop.off,
        PlaylistMode.single => Loop.one,
        PlaylistMode.loop => Loop.all,
      };
}
