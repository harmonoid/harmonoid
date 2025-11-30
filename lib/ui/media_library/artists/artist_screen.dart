import 'package:adaptive_layouts/adaptive_layouts.dart';
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
import 'package:harmonoid/utils/constants.dart';
import 'package:harmonoid/utils/rendering.dart';

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

  Future<void> _refreshImage() async {
    await context.read<ArtistImageNotifier>().refreshFile(widget.artist);
  }

  @override
  Widget build(BuildContext context) {
    return HeroContentScreen(
      mergeHeroAndContent: false,
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
      actions: {
        Icons.play_arrow: (_, _) => MediaPlayer.instance.open(_tracks.map((e) => e.toPlayable())),
        Icons.shuffle: (_, _) => MediaPlayer.instance.open(_tracks.map((e) => e.toPlayable()), shuffle: true),
        Icons.playlist_add: (_, _) => MediaPlayer.instance.add(_tracks.map((e) => e.toPlayable())),
      },
      labels: {
        Icons.play_arrow: Localization.instance.PLAY_NOW,
        Icons.shuffle: Localization.instance.SHUFFLE,
        Icons.playlist_add: Localization.instance.ADD_TO_NOW_PLAYING,
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
          popupMenuBuilder: (context, i) => trackPopupMenuItems(context, _tracks[i]),
          onItemPressed: (context, i) => MediaPlayer.instance.open(_tracks.map((e) => e.toPlayable()), index: i),
          onPopupMenuItemSelected: (context, i, result) async {
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
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    if (!Configuration.instance.mediaLibraryArtistImages) {
      return const SizedBox.shrink();
    }
    return Row(
      spacing: 8.0,
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
        InkWell(
          onTap: _removeImage,
          borderRadius: BorderRadius.circular(32.0),
          child: Container(
            padding: const EdgeInsets.all(4.0),
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black26),
            child: const Icon(Icons.close, size: 16.0, color: Colors.white),
          ),
        ),
        InkWell(
          onTap: _refreshImage,
          borderRadius: BorderRadius.circular(32.0),
          child: Container(
            padding: const EdgeInsets.all(4.0),
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black26),
            child: const Icon(Icons.refresh, size: 16.0, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
