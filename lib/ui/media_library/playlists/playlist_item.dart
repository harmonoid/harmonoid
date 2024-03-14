import 'package:flutter/material.dart';
import 'package:media_library/media_library.dart' hide MediaLibrary;
import 'package:provider/provider.dart';

import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/core/media_library.dart';
import 'package:harmonoid/ui/media_library/playlists/playlist_icon.dart';

class PlaylistItem extends StatelessWidget {
  final Playlist playlist;
  final VoidCallback? onTap;
  const PlaylistItem({super.key, required this.playlist, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Consumer<MediaLibrary>(
      builder: (context, mediaLibrary, _) {
        return FutureBuilder<List<PlaylistEntry>>(
          future: mediaLibrary.playlists.playlistEntries(playlist),
          builder: (context, snapshot) {
            final entries = snapshot.data;
            return ListTile(
              onTap: onTap ??
                  () {
                    // TODO:
                  },
              leading: SizedBox.square(
                dimension: 56.0,
                child: PlaylistIcon(
                  playlist: playlist,
                  entries: entries ?? [],
                  small: true,
                ),
              ),
              title: Text(playlist.name),
              subtitle: Text(entries == null ? '' : '${entries.length} ${Language.instance.TRACKS}'),
            );
          },
        );
      },
    );
  }
}
