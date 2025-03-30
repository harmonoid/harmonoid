import 'package:media_kit/media_kit.dart' hide Playable;

import 'package:harmonoid/models/playable.dart';

/// Mappers for [Media].
extension MediaMappers on Media {
  /// Convert to [Playable].
  Playable toPlayable() => Playable.fromJson(extras ?? {});
}
