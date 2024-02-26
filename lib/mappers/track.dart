import 'package:media_library/media_library.dart';

import 'package:harmonoid/models/playable.dart';

/// Mappers for [Track].
extension TrackMappers on Track {
  /// Convert to [Playable].
  Playable toPlayable() => Playable(
        uri: uri,
        title: title,
        subtitle: [...artists.take(2)],
        description: [if (album.isNotEmpty) album.toString(), if (year > 0) year.toString()],
      );
}
