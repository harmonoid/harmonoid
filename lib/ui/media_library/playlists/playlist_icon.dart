import 'package:flutter/material.dart';
import 'package:media_library/media_library.dart';

import 'package:harmonoid/ui/media_library/playlists/playlist_image.dart';

class PlaylistIcon extends StatelessWidget {
  final Playlist playlist;
  final List<PlaylistEntry> entries;
  final bool small;
  const PlaylistIcon({
    super.key,
    required this.playlist,
    this.entries = const [],
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final padding = small ? 0.0 : 8.0;

    return Hero(
      tag: playlist,
      child: Card(
        margin: EdgeInsets.zero,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: Container(
          padding: EdgeInsets.all(padding),
          child: PlaylistImage(
            playlist: playlist,
            entries: entries,
            small: small,
          ),
        ),
      ),
    );
  }
}
