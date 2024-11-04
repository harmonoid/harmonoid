import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:harmonoid/core/media_library.dart';
import 'package:harmonoid/models/playable.dart';
import 'package:media_library/media_library.dart' hide MediaLibrary;

import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/core/media_player/media_player.dart';
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
  String get _title => widget.playlist.name;
  String get _subtitle => isDesktop ? '${Localization.instance.ENTRIES}: ${_entries.length}' : Localization.instance.N_ENTRIES.replaceAll('"N"', _entries.length.toString());

  Future<List<Playable>> get _playables async {
    final result = await Future.wait(_entries.map((e) => e.toPlayable(MediaLibrary.instance)));
    return result.whereNotNull().toList();
  }

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
                          entries: _entries,
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
            entries: _entries,
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
        Text(Localization.instance.TITLE),
      ],
      listItemBuilder: (context, i) {
        if (isDesktop) {
          return [
            IgnorePointer(
              child: Text(
                _entries[i].title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
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
      listItemPopupMenuBuilder: (context, i) => playlistEntryPopupMenuItems(context, _entries[i]),
      onListItemPressed: (context, i) async => MediaPlayer.instance.open(await _playables, index: i),
      onListItemPopupMenuItemSelected: (context, i, result) async {
        await playlistEntryPopupMenuHandle(
          context,
          widget.playlist,
          _entries[i],
          result,
        );
        // NOTE: The track could've been deleted, so we need to check & update the list.
        final entries = await MediaLibrary.instance.playlists.playlistEntries(widget.playlist);
        if (entries.length != _entries.length) {
          setState(() {
            _entries
              ..clear()
              ..addAll(entries);
          });
        }
      },
      mergeHeroAndListItems: true,
      actions: {
        Icons.play_arrow: (_) async => MediaPlayer.instance.open(await _playables),
        Icons.shuffle: (_) async => MediaPlayer.instance.open([...await _playables]..shuffle()),
        Icons.playlist_add: (_) async => MediaPlayer.instance.add(await _playables),
      },
      labels: {
        Icons.play_arrow: Localization.instance.PLAY_NOW,
        Icons.shuffle: Localization.instance.SHUFFLE,
        Icons.playlist_add: Localization.instance.ADD_TO_NOW_PLAYING,
      },
    );
  }
}
