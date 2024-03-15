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
      return Row(
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
      return Image(
        image: cover(
          uri: entries[0].uri,
          cacheWidth: small ? 64 : null,
        ),
        fit: BoxFit.cover,
      );
    } else {
      return Container(
        alignment: Alignment.center,
        padding: small ? const EdgeInsets.all(8.0) : const EdgeInsets.all(56.0),
        child: LayoutBuilder(
          builder: (context, constraint) {
            return Icon(
              Icons.music_note,
              size: constraint.biggest.height,
              color: Theme.of(context).colorScheme.primary,
            );
          },
        ),
      );
    }
  }
}
