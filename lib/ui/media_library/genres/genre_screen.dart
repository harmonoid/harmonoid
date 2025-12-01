import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/material.dart';
import 'package:media_library/media_library.dart' hide MediaLibrary;

import 'package:harmonoid/core/media_library.dart';
import 'package:harmonoid/core/media_player/media_player.dart';
import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/mappers/track.dart';
import 'package:harmonoid/ui/media_library/genres/constants.dart';
import 'package:harmonoid/ui/media_library/media_library_flags.dart';
import 'package:harmonoid/ui/media_library/media_library_menus.dart';
import 'package:harmonoid/utils/constants.dart';
import 'package:harmonoid/utils/rendering.dart';

class GenreScreen extends StatefulWidget {
  final Genre genre;
  final List<Track> tracks;
  final List<Color>? palette;
  GenreScreen({super.key, required this.genre, required this.tracks, this.palette});

  late final color = kGenreColors[genre.genre.hashCode % kGenreColors.length];

  @override
  State<GenreScreen> createState() => _GenreScreenState();
}

class _GenreScreenState extends State<GenreScreen> {
  late final _tracks = widget.tracks;
  TracksMenuProvider get _tracksMenuProvider => TracksMenuProvider(context, _tracks);
  String get _title => widget.genre.genre.isNotEmpty ? widget.genre.genre : kDefaultGenre;
  String get _subtitle => _tracks.length == 1 ? Localization.instance.ONE_TRACK : Localization.instance.N_TRACKS.replaceAll('"N"', _tracks.length.toString());

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
                tag: widget.genre,
                child: Card(
                  color: widget.color,
                  margin: EdgeInsets.zero,
                  elevation: Theme.of(context).cardTheme.elevation ?? kDefaultCardElevation,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        constraints: const BoxConstraints(
                          maxWidth: 360.0,
                          maxHeight: 360.0,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            _title,
                            maxLines: 3,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: widget.color.computeLuminance() > 0.5 ? Colors.black : Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }
        if (isMobile) {
          return Container(
            color: widget.color,
            width: double.infinity,
            height: double.infinity,
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _title,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: widget.color.computeLuminance() > 0.5 ? Colors.black : Colors.white),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        }
        throw UnimplementedError();
      },
      caption: kCaption,
      title: _title,
      subtitle: _subtitle,
      actions: {
        Icons.play_arrow: (_, _) => _tracksMenuProvider.play(),
        Icons.shuffle: (_, _) => _tracksMenuProvider.shuffle(),
        Icons.playlist_play: (_, _) => _tracksMenuProvider.playNext(),
        Icons.playlist_add_check: (_, _) => _tracksMenuProvider.addToNowPlaying(),
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
          columns: [Localization.instance.TRACK, Localization.instance.ALBUM],
          itemCount: _tracks.length,
          itemBuilder: (context, i) => ListItemData(
            key: ValueKey(i.toString()),
            children: [
              _tracks[i].toTitleTappableText(),
              _tracks[i].toAlbumTappableText(context),
            ],
          ),
          leadingBuilder: (context, i) => _tracks[i].trackNumber == 0 ? kDefaultTrackNumber : _tracks[i].trackNumber,
          popupMenuBuilder: (context, i) => TrackMenuProvider(context, _tracks[i]).getPopupMenuItems(),
          onItemPressed: (context, i) => MediaPlayer.instance.open(_tracks.map((e) => e.toPlayable()), index: i),
          onPopupMenuItemSelected: (context, i, result) async {
            await TrackMenuProvider(context, _tracks[i]).handlePopupMenuAction(
              result,
              recursivelyPopNavigatorOnDeleteIf: () => MediaLibrary.instance.tracksFromGenre(widget.genre).then((value) => value.isEmpty),
            );
            // NOTE: The track could've been deleted, so we need to check & update the list.
            final tracks = await MediaLibrary.instance.tracksFromGenre(widget.genre);
            if (tracks.length != _tracks.length) {
              setState(() {
                _tracks
                  ..clear()
                  ..addAll(tracks);
              });
            }
          },
          showItemSelection: isDesktop || mediaLibrarySelectedTracks.value.isNotEmpty,
          isItemSelected: (i) => mediaLibrarySelectedTracks.value.contains(_tracks[i]),
          onItemSelected: (context, i, value) {
            if (value) {
              mediaLibrarySelectedTracks.value = {...mediaLibrarySelectedTracks.value, _tracks[i]};
            } else {
              mediaLibrarySelectedTracks.value = mediaLibrarySelectedTracks.value.difference({_tracks[i]});
            }
          },
          itemSelectionChangeNotifier: mediaLibrarySelectedTracks,
        ),
      ],
    );
  }
}
