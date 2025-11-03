import 'package:media_library/media_library.dart';

import 'package:harmonoid/mappers/track.dart';
import 'package:harmonoid/models/playable.dart';

/// Mappers for [PlaylistEntry].
extension PlaylistEntryMappers on PlaylistEntry {
  /// Converts to [Playable].
  Future<Playable?> toPlayable(MediaLibrary mediaLibrary) async {
    if (hash != null) {
      final track = await mediaLibrary.db.selectTrackByHash(hash!);
      return track?.toPlayable();
    }
    if (uri != null) {
      return Playable(
        uri: uri!,
        title: title,
        subtitle: [],
        description: [],
      );
    }
    return null;
  }
}
