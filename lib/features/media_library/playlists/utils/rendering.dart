import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:media_library/media_library.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/extensions/playable.dart';
import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/core/media_player/models/playable.dart';
import 'package:harmonoid/features/media_library/playlists/playlist_item.dart';
import 'package:harmonoid/utils/platform_utils.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/widgets.dart';

Future<String?> showCreatePlaylistDialog(BuildContext context) async {
  final name = await showInput(
    context,
    Localization.instance.CREATE_NEW_PLAYLIST,
    Localization.instance.PLAYLIST_CREATE_DIALOG_SUBTITLE,
    Localization.instance.CREATE,
    (value) {
      if (value?.isEmpty ?? true) {
        return '';
      }
      return null;
    },
    keyboardType: TextInputType.name,
    textCapitalization: TextCapitalization.words,
  );

  if (name.isNotEmpty) {
    final mediaLibrary = context.read<MediaLibrary>();
    await mediaLibrary.playlists.create(name);
    return name;
  }
  return null;
}

Future<void> showAddToPlaylistDialog(
  BuildContext context, {
  Track? track,
  Playable? playable,
  List<Track>? tracks,
}) {
  assert(track != null || playable != null || tracks != null);

  void onTap(MediaLibrary mediaLibrary, Playlist playlist) async {
    context.pop();

    if (track != null) {
      await mediaLibrary.playlists.createEntry(
        playlist,
        track: track,
      );
    }
    if (playable != null) {
      await mediaLibrary.playlists.createEntry(
        playlist,
        uri: playable.uri,
        title: playable.playlistEntryTitle,
      );
    }
    if (tracks != null) {
      for (final track in tracks) {
        await mediaLibrary.playlists.createEntry(
          playlist,
          track: track,
        );
      }
    }

    if (Platform.isAndroid) {
      final entry = track?.title ?? playable?.playlistEntryTitle;
      final playlistName = playlist.name;
      if (entry != null) {
        PlatformUtils.instance.showToast(Localization.instance.ADDED_ENTRY_TO_PLAYLIST.replaceAll('"ENTRY"', entry).replaceAll('"PLAYLIST"', playlistName));
      } else {
        PlatformUtils.instance.showToast(Localization.instance.ADDED_N_ENTRIES_TO_PLAYLIST.replaceAll('"N"', tracks?.length.toString() ?? '0').replaceAll('"PLAYLIST"', playlistName));
      }
    }
  }

  if (isDesktop) {
    return showDialog(
      context: context,
      builder: (ctx) => Consumer<MediaLibrary>(
        builder: (context, mediaLibrary, _) {
          final playlists = mediaLibrary.playlists.playlists;
          return AlertDialog(
            contentPadding: const EdgeInsets.only(top: 20.0),
            title: Text(Localization.instance.PLAYLIST_ADD_DIALOG_TITLE),
            content: SizedBox(
              width: 640.0,
              child: Material(
                color: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(height: 1.0),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListItem(
                              leading: Container(
                                width: 56.0,
                                height: 56.0,
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: const CircleAvatar(child: Icon(Icons.add)),
                              ),
                              title: Localization.instance.CREATE_NEW_PLAYLIST,
                              onTap: () => showCreatePlaylistDialog(context),
                            ),
                            const Divider(height: 1.0),
                            for (int i = 0; i < playlists.length; i++) ...[
                              PlaylistItem(
                                playlist: playlists[i],
                                onTap: () => onTap(mediaLibrary, playlists[i]),
                              ),
                              if (i < playlists.length - 1) const Divider(height: 1.0),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 1.0),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: context.pop,
                child: Text(label(Localization.instance.CANCEL)),
              ),
            ],
          );
        },
      ),
    );
  } else {
    return showModalBottomSheet(
      context: context,
      showDragHandle: isMaterial3OrGreater,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, controller) => Consumer<MediaLibrary>(
          builder: (context, mediaLibrary, _) {
            final playlists = mediaLibrary.playlists.playlists;
            return ListView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom,
              ),
              controller: controller,
              shrinkWrap: true,
              children: [
                ListItem(
                  leading: Container(
                    width: 56.0,
                    height: 56.0,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: const CircleAvatar(child: Icon(Icons.add)),
                  ),
                  title: Localization.instance.CREATE_NEW_PLAYLIST,
                  onTap: () => showCreatePlaylistDialog(context),
                ),
                const Divider(height: 1.0),
                for (int i = 0; i < playlists.length; i++)
                  PlaylistItem(
                    playlist: playlists[i],
                    onTap: () => onTap(mediaLibrary, playlists[i]),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
