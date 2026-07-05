import 'package:media_kit/media_kit.dart' hide Playable;

import 'package:harmonoid/core/media_player/models/playable.dart';

/// Mappers for [Media].
extension MediaMappers on Media {
  /// Converts to [Playable].
  Playable toPlayable() => Playable.fromJson(extras ?? {});
}
