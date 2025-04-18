import 'package:flutter/material.dart';
import 'package:media_library/media_library.dart';

import 'package:harmonoid/utils/rendering.dart';

class PlaylistImage extends StatelessWidget {
  final Playlist playlist;
  final List<PlaylistEntry> entries;
  final bool small;
  const PlaylistImage({
    super.key,
    required this.playlist,
    this.entries = const [],
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final padding = small ? 0.0 : 8.0;
    if (entries.length >= 3) {
      return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Image(
              image: cover(
                playlistEntry: entries[0],
                cacheWidth: small ? 64 : null,
              ),
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: padding),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Image(
                    image: cover(
                      playlistEntry: entries[1],
                      cacheWidth: small ? 64 : null,
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: padding),
                Expanded(
                  child: Image(
                    image: cover(
                      playlistEntry: entries[2],
                      cacheWidth: small ? 64 : null,
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    } else if (entries.length == 2) {
      return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Image(
              image: cover(
                playlistEntry: entries[0],
                cacheWidth: small ? 64 : null,
              ),
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: padding),
          Expanded(
            child: Image(
              image: cover(
                playlistEntry: entries[1],
                cacheWidth: small ? 64 : null,
              ),
              fit: BoxFit.cover,
            ),
          ),
        ],
      );
    } else if (entries.length == 1) {
      return Image(
        image: cover(
          playlistEntry: entries[0],
          cacheWidth: small ? 64 : null,
        ),
        fit: BoxFit.cover,
      );
    } else {
      return LayoutBuilder(
        builder: (context, constraint) {
          return Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(constraint.biggest.height / 8),
            child: Icon(
              Icons.music_note,
              size: constraint.biggest.height * 3 / 4,
              color: Theme.of(context).colorScheme.primary,
            ),
          );
        },
      );
    }
  }
}
