import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:media_library/media_library.dart' hide MediaLibrary;
import 'package:provider/provider.dart';

import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/core/media_library.dart';
import 'package:harmonoid/core/media_player/media_player.dart';
import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/mappers/track.dart';
import 'package:harmonoid/ui/media_library/artists/artist_image.dart';
import 'package:harmonoid/ui/media_library/artists/state/artist_image_notifier.dart';
import 'package:harmonoid/ui/media_library/media_library_hyperlinks.dart';
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
  String get _title => widget.artist.artist.isEmpty ? kDefaultArtist : widget.artist.artist;
  String get _subtitle => _tracks.length == 1 ? Localization.instance.ONE_TRACK : Localization.instance.N_TRACKS.replaceAll('"N"', _tracks.length.toString());

  Future<void> _editImage() async {
    final file = await pickFile(extensions: kSupportedImageFormats);
    if (file != null) {
      await context.read<ArtistImageNotifier>().setFile(widget.artist, file);
    }
  }

  Future<void> _removeImage() async {
    await context.read<ArtistImageNotifier>().removeFile(widget.artist);
  }

  @override
  Widget build(BuildContext context) {
    return HeroListItemsScreen(
      palette: widget.palette,
      heroBuilder: (context) {
        if (isDesktop) {
          return Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Hero(
                  tag: widget.artist,
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: Card(
                      margin: EdgeInsets.zero,
                      shape: const CircleBorder(),
                      elevation: Theme.of(context).cardTheme.elevation ?? kDefaultCardElevation,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ClipOval(child: ArtistImage(artist: widget.artist)),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 0.0,
                  bottom: 0.0,
                  child: _buildActions(context),
                ),
              ],
            ),
          );
        }
        if (isMobile) {
          return Stack(
            children: [
              Positioned.fill(child: ArtistImage(artist: widget.artist)),
              Positioned(
                left: 20.0,
                bottom: 20.0,
                child: _buildActions(context),
              ),
            ],
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
        Icons.play_arrow: Localization.instance.PLAY_NOW,
        Icons.shuffle: Localization.instance.SHUFFLE,
        Icons.playlist_add: Localization.instance.ADD_TO_NOW_PLAYING,
      },
    );
  }

  Widget _buildActions(BuildContext context) {
    if (!Configuration.instance.mediaLibraryArtistImages) {
      return const SizedBox.shrink();
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: _editImage,
          borderRadius: BorderRadius.circular(32.0),
          child: Container(
            padding: const EdgeInsets.all(4.0),
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black26),
            child: const Icon(Icons.edit, size: 16.0, color: Colors.white),
          ),
        ),
        const SizedBox(width: 8.0),
        InkWell(
          onTap: _removeImage,
          borderRadius: BorderRadius.circular(32.0),
          child: Container(
            padding: const EdgeInsets.all(4.0),
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black26),
            child: const Icon(Icons.close, size: 16.0, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
