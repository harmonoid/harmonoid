import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:media_library/media_library.dart' hide MediaLibrary;
import 'package:provider/provider.dart';

import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/core/media_library.dart';
import 'package:harmonoid/ui/media_library/playlists/playlist_icon.dart';
import 'package:harmonoid/ui/router.dart';
import 'package:harmonoid/utils/palette_generator.dart';
import 'package:harmonoid/utils/rendering.dart';

class PlaylistItem extends StatelessWidget {
  final Playlist playlist;
  final VoidCallback? onTap;
  const PlaylistItem({super.key, required this.playlist, this.onTap});

  Future<void> onSecondaryPress(BuildContext context, {RelativeRect? position}) async {
    final result = await showMenuItems(context, playlistPopupMenuItems(context, playlist), position: position);
    playlistPopupMenuHandle(context, playlist, result);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MediaLibrary>(
      builder: (context, mediaLibrary, _) {
        return FutureBuilder<List<PlaylistEntry>>(
          future: mediaLibrary.playlists.playlistEntries(playlist),
          builder: (context, snapshot) {
            final entries = snapshot.data;
            return ContextMenuListener(
              onSecondaryPress: (position) {
                onSecondaryPress(context, position: position);
              },
              child: ListTile(
                onTap: onTap ??
                    (entries == null
                        ? null
                        : () async {
                            List<Color>? palette;
                            if (isMaterial2) {
                              try {
                                final result = await PaletteGenerator.fromImageProvider(
                                  cover(
                                    uri: entries[0].uri,
                                    cacheWidth: 64,
                                  ),
                                );
                                palette = result.colors?.toList();
                              } catch (exception, stacktrace) {
                                debugPrint(exception.toString());
                                debugPrint(stacktrace.toString());
                              }
                            }
                            await context.push(
                              '/$kMediaLibraryPath/$kPlaylistPath',
                              extra: PlaylistPathExtra(
                                playlist: playlist,
                                entries: entries,
                                palette: palette,
                              ),
                            );
                          }),
                onLongPress: () {
                  onSecondaryPress(context);
                },
                leading: SizedBox.square(
                  dimension: 56.0,
                  child: PlaylistIcon(
                    playlist: playlist,
                    entries: entries ?? [],
                    small: true,
                  ),
                ),
                title: Text(
                  playlist.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: Text(
                  entries == null ? '' : Language.instance.N_TRACKS.replaceAll('"N"', entries.length.toString()),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
