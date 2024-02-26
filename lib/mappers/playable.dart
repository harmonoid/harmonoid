import 'package:media_kit/media_kit.dart' hide Playable;

import 'package:harmonoid/models/playable.dart';

/// Mappers for [Playable].
extension PlayableMappers on Playable {
  /// Convert to [Media].
  Media toMedia() => Media(uri, extras: toJson());
}
