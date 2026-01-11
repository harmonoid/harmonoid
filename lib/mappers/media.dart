import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart' hide Playable;

import 'package:harmonoid/models/playable.dart';

/// Mappers for [Media].
extension MediaMappers on Media {
  /// Converts to [Playable].
  Future<Playable> toPlayable() => compute(Playable.fromJson, extras ?? {});
}
