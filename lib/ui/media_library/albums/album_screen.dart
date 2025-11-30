import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/material.dart';
import 'package:media_library/media_library.dart' hide MediaLibrary;

import 'package:harmonoid/core/media_library.dart';
import 'package:harmonoid/core/media_player/media_player.dart';
import 'package:harmonoid/extensions/shape_border.dart';
import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/mappers/track.dart';
import 'package:harmonoid/utils/constants.dart';
import 'package:harmonoid/utils/rendering.dart';

class AlbumScreen extends StatefulWidget {
  final Album album;
  final List<Track> tracks;
  final List<Color>? palette;

  const AlbumScreen({super.key, required this.album, required this.tracks, this.palette});

  @override
  State<AlbumScreen> createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen> {
  late final _tracks = widget.tracks;

  String get _title => widget.album.album.isEmpty ? kDefaultAlbum : widget.album.album;

  String get _subtitle => isDesktop
      ? [
          widget.album.albumArtist.isEmpty ? kDefaultArtist : widget.album.albumArtist,
          '${widget.album.year == 0 ? kDefaultYear : widget.album.year}',
          _tracks.length == 1 ? Localization.instance.ONE_TRACK : Localization.instance.N_TRACKS.replaceAll('"N"', _tracks.length.toString()),
        ].join('\n')
      : [
          if (widget.album.albumArtist.isNotEmpty) widget.album.albumArtist,
          if (widget.album.year != 0) widget.album.year,
        ].join('\n');

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
                tag: widget.album,
                child: Card(
                  margin: EdgeInsets.zero,
                  color: Colors.white,
                  elevation: Theme.of(context).cardTheme.elevation ?? kDefaultCardElevation,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      clipBehavior: Clip.antiAlias,
                      borderRadius: Theme.of(context).cardTheme.shape?.subtractBorderRadius(BorderRadius.circular(8.0)) ?? BorderRadius.zero,
                      child: Image(
                        image: cover(item: widget.album),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }
        if (isMobile) {
          return Image(
            image: cover(item: widget.album),
            fit: BoxFit.cover,
          );
        }
        throw UnimplementedError();
      },
      caption: kCaption,
      title: _title,
      subtitle: _subtitle,
      actions: {
        Icons.play_arrow: (_, _) => MediaPlayer.instance.open(_tracks.map((e) => e.toPlayable())),
        Icons.shuffle: (_, _) => MediaPlayer.instance.open(_tracks.map((e) => e.toPlayable()), shuffle: true),
        Icons.playlist_add: (_, _) => MediaPlayer.instance.add(_tracks.map((e) => e.toPlayable())),
        Icons.delete: (_, _) => albumPopupMenuHandle(context, widget.album, 2),
      },
      labels: {
        Icons.play_arrow: Localization.instance.PLAY_NOW,
        Icons.shuffle: Localization.instance.SHUFFLE,
        Icons.playlist_add: Localization.instance.ADD_TO_NOW_PLAYING,
        Icons.delete: Localization.instance.DELETE,
      },
      tabs: [''],
      content: [
        ListItemTable(
          columns: [Localization.instance.TRACK, Localization.instance.ARTISTS],
          itemCount: _tracks.length,
          itemBuilder: (context, i) => ListItemData(
            key: ValueKey(i.toString()),
            children: [
              _tracks[i].toTitleTappableText(),
              _tracks[i].toArtistsTappableText(context),
            ],
          ),
          leadingBuilder: (context, i) => _tracks[i].trackNumber == 0 ? kDefaultTrackNumber : _tracks[i].trackNumber,
          popupMenuBuilder: (context, i) => trackPopupMenuItems(context, _tracks[i]),
          onItemPressed: (context, i) => MediaPlayer.instance.open(_tracks.map((e) => e.toPlayable()), index: i),
          onPopupMenuItemSelected: (context, i, result) async {
            await trackPopupMenuHandle(
              context,
              _tracks[i],
              result,
              recursivelyPopNavigatorOnDeleteIf: () => MediaLibrary.instance.tracksFromAlbum(widget.album).then((value) => value.isEmpty),
            );
            // NOTE: The track could've been deleted, so we need to check & update the list.
            final tracks = await MediaLibrary.instance.tracksFromAlbum(widget.album);
            if (tracks.length != _tracks.length) {
              setState(() {
                _tracks
                  ..clear()
                  ..addAll(tracks);
              });
            }
          },
        ),
      ],
    );
  }
}
