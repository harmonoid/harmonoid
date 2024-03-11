import 'package:flutter/material.dart';
import 'package:media_library/media_library.dart';

import 'package:harmonoid/utils/rendering.dart';

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
    final Widget child;
    final padding = small ? 0.0 : 8.0;
    if (entries.length >= 3) {
      child = Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Image(
              image: cover(
                uri: entries[0].uri,
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
                      uri: entries[1].uri,
                      cacheWidth: small ? 64 : null,
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: padding),
                Expanded(
                  child: Image(
                    image: cover(
                      uri: entries[2].uri,
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
      child = Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Image(
              image: cover(
                uri: entries[0].uri,
                cacheWidth: small ? 64 : null,
              ),
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: padding),
          Expanded(
            child: Image(
              image: cover(
                uri: entries[1].uri,
                cacheWidth: small ? 64 : null,
              ),
              fit: BoxFit.cover,
            ),
          ),
        ],
      );
    } else if (entries.length == 1) {
      child = Image(
        image: cover(
          uri: entries[0].uri,
          cacheWidth: small ? 64 : null,
        ),
        fit: BoxFit.cover,
      );
    } else {
      child = Icon(
        Icons.music_note,
        color: Theme.of(context).colorScheme.primary,
      );
    }
    return Card(
      margin: EdgeInsets.zero,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: Container(
        padding: EdgeInsets.all(padding),
        child: Hero(
          tag: playlist,
          child: child,
        ),
      ),
    );
  }
}
