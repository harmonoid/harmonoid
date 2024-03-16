import 'package:media_library/media_library.dart';

import 'package:harmonoid/models/playable.dart';

/// Mappers for [PlaylistEntry].
extension PlaylistEntryMappers on PlaylistEntry {
  /// Convert to [Playable].
  Playable toPlayable() => Playable(
        uri: uri,
        title: title,
        subtitle: [],
        description: [],
      );
}
