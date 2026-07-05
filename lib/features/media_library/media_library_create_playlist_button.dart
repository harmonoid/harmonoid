import 'package:flutter/material.dart';

import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/features/media_library/playlists/utils/rendering.dart';

class MediaLibraryCreatePlaylistButton extends StatelessWidget {
  const MediaLibraryCreatePlaylistButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'media-library-create-playlist-button',
      tooltip: Localization.instance.CREATE_NEW_PLAYLIST,
      onPressed: () => showCreatePlaylistDialog(context),
      child: const Icon(Icons.edit),
    );
  }
}
