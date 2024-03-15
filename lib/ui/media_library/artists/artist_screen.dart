import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:media_library/media_library.dart' hide MediaLibrary;

import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/core/media_library.dart';
import 'package:harmonoid/core/media_player.dart';
import 'package:harmonoid/mappers/track.dart';
import 'package:harmonoid/utils/constants.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/widgets.dart';

class ArtistScreen extends StatefulWidget {
  final Artist artist;
  final List<Track> tracks;
  final List<Color>? palette;
  const ArtistScreen({super.key, required this.artist, required this.tracks, this.palette});

  @override
  State<ArtistScreen> createState() => _ArtistScreenState();
}

class _ArtistScreenState extends State<ArtistScreen> {
  late final _tracks = widget.tracks;
  late final String _title = widget.artist.artist.isEmpty ? kDefaultArtist : widget.artist.artist;
  late final String _subtitle = isDesktop ? '${Language.instance.TRACKS}: ${_tracks.length}' : Language.instance.N_TRACKS.replaceAll('"N"', _tracks.length.toString());

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
                tag: widget.artist,
                child: Card(
                  color: Colors.white,
                  margin: EdgeInsets.zero,
                  shape: const CircleBorder(),
                  elevation: Theme.of(context).cardTheme.elevation ?? kDefaultCardElevation,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipOval(
                      clipBehavior: Clip.antiAlias,
                      child: Image(
                        image: cover(item: widget.artist),
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
            image: cover(item: widget.artist),
            fit: BoxFit.cover,
          );
        }
        throw UnimplementedError();
      },
      caption: kCaption,
      title: _title,
      subtitle: _subtitle,
      listItemCount: _tracks.length,
      listItemDisplayIndex: true,
      listItemHeaders: [
        Text(Language.instance.TRACK),
        Text(Language.instance.ALBUM),
      ],
      listItemIndexBuilder: (context, i) => _tracks[i].trackNumber == 0 ? kDefaultTrackNumber : _tracks[i].trackNumber,
      listItemBuilder: (context, i) {
        if (isDesktop) {
          return [
            Text(
              _tracks[i].title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            HyperLink(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: _tracks[i].album.isEmpty ? kDefaultAlbum : _tracks[i].album,
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        // TODO:
                      },
                  ),
                ],
              ),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ];
        }
        if (isMobile) {
          return [
            Text(
              _tracks[i].title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              _tracks[i].album.isEmpty ? kDefaultAlbum : _tracks[i].album,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ];
        }
        throw UnimplementedError();
      },
      listItemPopupMenuBuilder: (context, i) => trackPopupMenuItems(context, _tracks[i]),
      onListItemPressed: (context, i) => MediaPlayer.instance.open(_tracks.map((e) => e.toPlayable()).toList(), index: i),
      onListItemPopupMenuItemSelected: (context, i, result) async {
        await trackPopupMenuHandle(
          context,
          _tracks[i],
          result,
          recursivelyPopNavigatorOnDeleteIf: () => MediaLibrary.instance.tracksFromArtist(widget.artist).then((value) => value.isEmpty),
        );
        // NOTE: The track could've been deleted, so we need to check & update the list.
        final tracks = await MediaLibrary.instance.tracksFromArtist(widget.artist);
        if (tracks.length != _tracks.length) {
          setState(() {
            _tracks
              ..clear()
              ..addAll(tracks);
          });
        }
      },
      mergeHeroAndListItems: false,
      actions: {
        Icons.play_arrow: (_) => MediaPlayer.instance.open(_tracks.map((e) => e.toPlayable()).toList()),
        Icons.shuffle: (_) => MediaPlayer.instance.open([..._tracks..shuffle()].map((e) => e.toPlayable()).toList()),
        Icons.playlist_add: (_) => MediaPlayer.instance.add(_tracks.map((e) => e.toPlayable()).toList()),
      },
      labels: {
        Icons.play_arrow: Language.instance.PLAY,
        Icons.shuffle: Language.instance.SHUFFLE,
        Icons.playlist_add: Language.instance.ADD_TO_NOW_PLAYING,
      },
    );
  }
}
