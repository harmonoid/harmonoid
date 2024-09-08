import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:media_library/media_library.dart' hide MediaLibrary;

import 'package:harmonoid/core/media_library.dart';
import 'package:harmonoid/core/media_player.dart';
import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/mappers/track.dart';
import 'package:harmonoid/ui/media_library/media_library_hyperlinks.dart';
import 'package:harmonoid/utils/constants.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/widgets.dart';

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
          '${Localization.instance.ARTIST}: ${widget.album.albumArtist.isEmpty ? kDefaultArtist : widget.album.albumArtist}',
          '${Localization.instance.YEAR}: ${widget.album.year == 0 ? kDefaultYear : widget.album.year}',
          '${Localization.instance.TRACKS}: ${_tracks.length}'
        ].join('\n')
      : [
          widget.album.albumArtist.isEmpty ? kDefaultArtist : widget.album.albumArtist,
          widget.album.year == 0 ? kDefaultYear : widget.album.year,
        ].join('\n');

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
                tag: widget.album,
                child: Card(
                  margin: EdgeInsets.zero,
                  color: Colors.white,
                  elevation: Theme.of(context).cardTheme.elevation ?? kDefaultCardElevation,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      clipBehavior: Clip.antiAlias,
                      borderRadius: Theme.of(context).cardTheme.shape is! RoundedRectangleBorder
                          ? BorderRadius.zero
                          : (Theme.of(context).cardTheme.shape as RoundedRectangleBorder).borderRadius.subtract(
                                const BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                              ),
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
      listItemCount: _tracks.length,
      listItemDisplayIndex: true,
      listItemHeaders: [
        Text(Localization.instance.TRACK),
        Text(Localization.instance.ARTISTS),
      ],
      listItemIndexBuilder: (context, i) => _tracks[i].trackNumber == 0 ? kDefaultTrackNumber : _tracks[i].trackNumber,
      listItemBuilder: (context, i) {
        if (isDesktop) {
          return [
            IgnorePointer(
              child: Text(
                _tracks[i].title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            HyperLink(
              text: TextSpan(
                children: [
                  for (final artist in (_tracks[i].artists.isEmpty ? {''} : _tracks[i].artists)) ...[
                    TextSpan(
                      text: artist.isEmpty ? kDefaultArtist : artist,
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          navigateToArtist(context, ArtistLookupKey(artist: artist));
                        },
                    ),
                    const TextSpan(
                      text: ', ',
                    ),
                  ]
                ]..removeLast(),
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
              (_tracks[i].artists.isEmpty ? {kDefaultArtist} : _tracks[i].artists).join(', '),
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
      mergeHeroAndListItems: true,
      actions: {
        Icons.play_arrow: (_) => MediaPlayer.instance.open(_tracks.map((e) => e.toPlayable()).toList()),
        Icons.shuffle: (_) => MediaPlayer.instance.open([..._tracks..shuffle()].map((e) => e.toPlayable()).toList()),
        Icons.playlist_add: (_) => MediaPlayer.instance.add(_tracks.map((e) => e.toPlayable()).toList()),
        Icons.delete: (_) {
          albumPopupMenuHandle(context, widget.album, 2);
        },
      },
      labels: {
        Icons.play_arrow: Localization.instance.PLAY_NOW,
        Icons.shuffle: Localization.instance.SHUFFLE,
        Icons.playlist_add: Localization.instance.ADD_TO_NOW_PLAYING,
        Icons.delete: Localization.instance.DELETE,
      },
    );
  }
}
