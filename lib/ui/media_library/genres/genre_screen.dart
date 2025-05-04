import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:media_library/media_library.dart' hide MediaLibrary;

import 'package:harmonoid/core/media_library.dart';
import 'package:harmonoid/core/media_player/media_player.dart';
import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/mappers/track.dart';
import 'package:harmonoid/ui/media_library/genres/constants.dart';
import 'package:harmonoid/ui/media_library/media_library_hyperlinks.dart';
import 'package:harmonoid/utils/constants.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/widgets.dart';

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
  String get _title => widget.genre.genre.isNotEmpty ? widget.genre.genre : kDefaultGenre;
  String get _subtitle => _tracks.length == 1 ? Localization.instance.ONE_TRACK : Localization.instance.N_TRACKS.replaceAll('"N"', _tracks.length.toString());

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
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  color: widget.color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                                ),
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
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: widget.color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                    ),
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
      listItemCount: _tracks.length,
      listItemDisplayIndex: true,
      listItemHeaders: [
        Text(Localization.instance.TRACK),
        Text(Localization.instance.ALBUM),
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
                  TextSpan(
                    text: _tracks[i].album.isEmpty ? kDefaultAlbum : _tracks[i].album,
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        navigateToAlbum(
                          context,
                          AlbumLookupKey(
                            album: _tracks[i].album,
                            albumArtist: _tracks[i].albumArtist,
                            year: _tracks[i].year,
                          ),
                        );
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
      mergeHeroAndListItems: true,
      actions: {
        Icons.play_arrow: (_) => MediaPlayer.instance.open(_tracks.map((e) => e.toPlayable()).toList()),
        Icons.shuffle: (_) => MediaPlayer.instance.open([..._tracks..shuffle()].map((e) => e.toPlayable()).toList()),
        Icons.playlist_add: (_) => MediaPlayer.instance.add(_tracks.map((e) => e.toPlayable()).toList()),
      },
      labels: {
        Icons.play_arrow: Localization.instance.PLAY_NOW,
        Icons.shuffle: Localization.instance.SHUFFLE,
        Icons.playlist_add: Localization.instance.ADD_TO_NOW_PLAYING,
      },
    );
  }
}
