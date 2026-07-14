import 'package:flutter/material.dart';
import 'package:media_library/media_library.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/core/media_player/media_player.dart';
import 'package:harmonoid/extensions/build_context.dart';
import 'package:harmonoid/features/media_library/tracks/state/tracks_notifier.dart';
import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/mappers/track.dart';
import 'package:harmonoid/mappers/track_view_type.dart';
import 'package:harmonoid/features/media_library/desktop/desktop_media_library_sort_button.dart';
import 'package:harmonoid/routing/utils/constants.dart';
import 'package:harmonoid/utils/dimensions.dart';

class DesktopMediaLibraryHeader extends StatefulWidget {
  const DesktopMediaLibraryHeader({super.key});

  @override
  DesktopMediaLibraryHeaderState createState() => DesktopMediaLibraryHeaderState();
}

class DesktopMediaLibraryHeaderState extends State<DesktopMediaLibraryHeader> {
  @override
  Widget build(BuildContext context) {
    final path = context.location.split('/').last;
    final tracksNotifier = context.watch<TracksNotifier>();

    if (![kAlbumsPath, kTracksPath, kArtistsPath, kGenresPath, kFoldersPath].contains(path)) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 16.0),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(4.0),
            onTap: () {
              MediaPlayer.instance.open(context.read<MediaLibrary>().tracks.map((e) => e.toPlayable()));
            },
            child: Container(
              height: 44.0,
              padding: const EdgeInsets.only(left: 2.0, right: 6.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.play_arrow,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 4.0),
                  Text(
                    Localization.instance.PLAY_ALL,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.primary),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 4.0),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(4.0),
            onTap: () {
              MediaPlayer.instance.open(context.read<MediaLibrary>().tracks.map((e) => e.toPlayable()), shuffle: true);
            },
            child: Container(
              height: 44.0,
              padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shuffle,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 4.0),
                  Text(
                    Localization.instance.SHUFFLE,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.primary),
                  ),
                ],
              ),
            ),
          ),
        ),
        const Spacer(),
        // Show TrackViewType toggle button for TracksScreen.
        if (path == kTracksPath) ...[
          const SizedBox(width: 4.0),
          IconButton(
            onPressed: tracksNotifier.toggleViewType,
            tooltip: tracksNotifier.viewType.toToggleLabel(),
            icon: Icon(tracksNotifier.viewType.toToggleIcon()),
            iconSize: 20.0,
            color: Theme.of(context).appBarTheme.actionsIconTheme?.color,
          ),
          const SizedBox(width: 4.0),
        ],
        const DesktopMediaLibrarySortButton(floating: false),
        SizedBox(width: margin),
      ],
    );
  }
}
