import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/material.dart';
import 'package:media_library/media_library.dart' hide MediaLibrary;

import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/core/media_player.dart';
import 'package:harmonoid/mappers/playlist_entry.dart';
import 'package:harmonoid/ui/media_library/playlists/playlist_image.dart';
import 'package:harmonoid/utils/constants.dart';
import 'package:harmonoid/utils/rendering.dart';

class PlaylistScreen extends StatefulWidget {
  final Playlist playlist;
  final List<PlaylistEntry> entries;
  final List<Color>? palette;
  const PlaylistScreen({super.key, required this.playlist, required this.entries, this.palette});

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  late final _entries = widget.entries;
  late final String _title = widget.playlist.name;
  late final String _subtitle = isDesktop ? '${Language.instance.ENTRIES}: ${_entries.length}' : Language.instance.N_ENTRIES.replaceAll('"N"', _entries.length.toString());

  @override
  Widget build(BuildContext context) {
    return HeroListItemsScreen(
      palette: widget.palette,
      heroBuilder: (context) {
        if (isDesktop) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Hero(
                tag: widget.playlist,
                child: Card(
                  color: Colors.white,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  margin: EdgeInsets.zero,
                  elevation: Theme.of(context).cardTheme.elevation ?? kDefaultCardElevation,
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipOval(
                        child: PlaylistImage(
                          playlist: widget.playlist,
                          entries: widget.entries,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }
        if (isMobile) {
          return PlaylistImage(
            playlist: widget.playlist,
            entries: widget.entries,
          );
        }
        throw UnimplementedError();
      },
      caption: kCaption,
      title: _title,
      subtitle: _subtitle,
      listItemCount: _entries.length,
      listItemDisplayIndex: true,
      listItemHeaders: [
        Text(Language.instance.TITLE),
      ],
      listItemBuilder: (context, i) {
        if (isDesktop) {
          return [
            Text(
              _entries[i].title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ];
        }
        if (isMobile) {
          return [
            Text(
              _entries[i].title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ];
        }
        throw UnimplementedError();
      },
      listItemPopupMenuBuilder: (context, i) => [/* TODO: */],
      onListItemPressed: (context, i) => MediaPlayer.instance.open(_entries.map((e) => e.toPlayable()).toList(), index: i),
      onListItemPopupMenuItemSelected: (context, i, result) async {
        // TODO:
      },
      mergeHeroAndListItems: true,
      actions: {
        Icons.play_arrow: (_) => MediaPlayer.instance.open(_entries.map((e) => e.toPlayable()).toList()),
        Icons.shuffle: (_) => MediaPlayer.instance.open([..._entries..shuffle()].map((e) => e.toPlayable()).toList()),
        Icons.playlist_add: (_) => MediaPlayer.instance.add(_entries.map((e) => e.toPlayable()).toList()),
      },
      labels: {
        Icons.play_arrow: Language.instance.PLAY_NOW,
        Icons.shuffle: Language.instance.SHUFFLE,
        Icons.playlist_add: Language.instance.ADD_TO_NOW_PLAYING,
      },
    );
  }
}
