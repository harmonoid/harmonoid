import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/material.dart';
import 'package:media_library/media_library.dart';
import 'package:media_library/playlists/src/utils/constants.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/core/media_player/media_player.dart';
import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/mappers/playlist_entry.dart';
import 'package:harmonoid/models/playable.dart';
import 'package:harmonoid/ui/media_library/media_library_menus.dart';
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
  String get _title => switch (widget.playlist.name) {
    kLikedPlaylistName => Localization.instance.LIKED_SONGS,
    kHistoryPlaylistName => Localization.instance.HISTORY,
    _ => widget.playlist.name,
  };
  String get _subtitle => _entries.length == 1 ? Localization.instance.ONE_TRACK : Localization.instance.N_TRACKS.replaceAll('"N"', _entries.length.toString());

  Future<List<Playable>> get _playables async {
    final result = await Future.wait(_entries.map((e) => e.toPlayable()));
    return result.nonNulls.toList();
  }

  @override
  Widget build(BuildContext context) {
    return HeroContentScreen(
      mergeHeroAndContent: true,
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
      actions: {
        Icons.play_arrow: (_, _) async => MediaPlayer.instance.open(await _playables),
        Icons.shuffle: (_, _) async => MediaPlayer.instance.open(await _playables, shuffle: true),
        Icons.playlist_play: (_, _) async {
          final playables = await _playables;
          await MediaPlayer.instance.disablePlayerPlaylistUpdates();
          for (final entry in playables.reversed) {
            await MediaPlayer.instance.insert(MediaPlayer.instance.state.index, entry);
          }
          await MediaPlayer.instance.enablePlayerPlaylistUpdates();
        },
        Icons.playlist_add_check: (_, _) async {
          await MediaPlayer.instance.disablePlayerPlaylistUpdates();
          await MediaPlayer.instance.add(await _playables);
          await MediaPlayer.instance.enablePlayerPlaylistUpdates();
        },
      },
      labels: {
        Icons.play_arrow: Localization.instance.PLAY_NOW,
        Icons.shuffle: Localization.instance.SHUFFLE,
        Icons.playlist_play: Localization.instance.PLAY_NEXT,
        Icons.playlist_add_check: Localization.instance.ADD_TO_NOW_PLAYING,
      },
      tabs: [''],
      content: [
        ListItemTable(
          columns: [Localization.instance.TITLE],
          itemCount: _entries.length,
          itemBuilder: (context, i) => ListItemData(
            key: ValueKey(i.toString()),
            children: [
              TappableText(text: [TappableTextData(text: _entries[i].title)]),
            ],
          ),
          leadingBuilder: (context, i) => (i + 1).toString(),
          popupMenuBuilder: (context, i) => PlaylistEntryMenuProvider(context, widget.playlist, _entries[i]).getPopupMenuItems(),
          onItemPressed: (context, i) async => MediaPlayer.instance.open(await _playables, index: i),
          onPopupMenuItemSelected: (context, i, result) async {
            await PlaylistEntryMenuProvider(context, widget.playlist, _entries[i]).handlePopupMenuAction(result);
            // NOTE: The track could've been deleted, so we need to check & update the list.
            final entries = await context.read<MediaLibrary>().playlists.playlistEntries(widget.playlist);
            if (entries.length != _entries.length) {
              setState(() {
                _entries
                  ..clear()
                  ..addAll(entries);
              });
            }
          },
        ),
      ],
    );
  }
}
