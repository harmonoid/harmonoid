import 'package:flutter/material.dart';
import 'package:harmonoid/ui/media_library/playlists/playlist_item.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/core/media_library.dart';

class PlaylistsScreen extends StatefulWidget {
  const PlaylistsScreen({super.key});

  @override
  State<PlaylistsScreen> createState() => PlaylistsScreenState();
}

class PlaylistsScreenState extends State<PlaylistsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Consumer<MediaLibrary>(
        builder: (context, mediaLibrary, _) {
          return ListView.separated(
            separatorBuilder: (context, i) => const Divider(height: 1.0),
            itemCount: mediaLibrary.playlists.playlists.length,
            itemBuilder: (context, i) {
              return PlaylistItem(
                playlist: mediaLibrary.playlists.playlists[i],
              );
            },
          );
        },
      ),
    );
  }
}
