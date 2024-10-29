import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide ReorderableDragStartListener, Intent;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:media_library/media_library.dart' hide MediaLibrary;
import 'package:provider/provider.dart';

import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/core/intent.dart';
import 'package:harmonoid/core/media_library.dart';
import 'package:harmonoid/core/media_player.dart';
import 'package:harmonoid/extensions/global_key.dart';
import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/mappers/track.dart';
import 'package:harmonoid/state/now_playing_color_palette_notifier.dart';
import 'package:harmonoid/state/now_playing_mobile_notifier.dart';
import 'package:harmonoid/ui/router.dart';
import 'package:harmonoid/utils/constants.dart';
import 'package:harmonoid/utils/keyboard_shortcuts.dart';
import 'package:harmonoid/utils/rendering.dart';

class DesktopMediaLibraryHeader extends StatefulWidget {
  const DesktopMediaLibraryHeader({super.key});

  @override
  DesktopMediaLibraryHeaderState createState() => DesktopMediaLibraryHeaderState();
}

class DesktopMediaLibraryHeaderState extends State<DesktopMediaLibraryHeader> {
  bool hover0 = false;
  bool hover1 = false;

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.pathSegments.last;

    if (![kAlbumsPath, kTracksPath, kArtistsPath, kGenresPath].contains(path)) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 4.0),
        GestureDetector(
          onTap: () {
            MediaPlayer.instance.open(MediaLibrary.instance.tracks.map((e) => e.toPlayable()).toList());
          },
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => setState(() {
              hover0 = true;
            }),
            onExit: (_) => setState(() {
              hover0 = false;
            }),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.play_arrow,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(
                    width: 4.0,
                  ),
                  Text(
                    Localization.instance.PLAY_ALL,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          decoration: hover0 ? TextDecoration.underline : TextDecoration.none,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 4.0),
        GestureDetector(
          onTap: () {
            MediaPlayer.instance.open([...MediaLibrary.instance.tracks.map((e) => e.toPlayable())]..shuffle());
          },
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => setState(() {
              hover1 = true;
            }),
            onExit: (_) => setState(() {
              hover1 = false;
            }),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shuffle,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(
                    width: 4.0,
                  ),
                  Text(
                    Localization.instance.SHUFFLE,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          decoration: hover1 ? TextDecoration.underline : TextDecoration.none,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const Spacer(),
        const DesktopMediaLibrarySortButton(floating: false),
        SizedBox(width: margin),
      ],
    );
  }
}

// --------------------------------------------------

class DesktopMediaLibraryFloatingSortButton extends StatefulWidget {
  final ValueNotifier<bool> floatingNotifier;
  const DesktopMediaLibraryFloatingSortButton({
    super.key,
    required this.floatingNotifier,
  });

  @override
  State<DesktopMediaLibraryFloatingSortButton> createState() => DesktopMediaLibraryFloatingSortButtonState();
}

class DesktopMediaLibraryFloatingSortButtonState extends State<DesktopMediaLibraryFloatingSortButton> {
  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.pathSegments.last;

    if (![kAlbumsPath, /* kTracksPath, */ kArtistsPath, kGenresPath].contains(path)) {
      return const SizedBox.shrink();
    }

    return ValueListenableBuilder<bool>(
      valueListenable: widget.floatingNotifier,
      child: const DesktopMediaLibrarySortButton(floating: true),
      builder: (context, floating, child) => AnimatedPositioned(
        curve: Curves.easeInOut,
        duration: Theme.of(context).extension<AnimationDuration>()?.fast ?? Duration.zero,
        top: margin + captionHeight + kDesktopAppBarHeight + (floating ? 0.0 : -72.0),
        right: margin,
        child: Card(
          elevation: 4.0,
          margin: EdgeInsets.zero,
          color: Theme.of(context).appBarTheme.backgroundColor,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: child,
          ),
        ),
      ),
    );
  }
}

// --------------------------------------------------

class DesktopMediaLibrarySortButton extends StatefulWidget {
  final bool floating;

  const DesktopMediaLibrarySortButton({super.key, required this.floating});

  @override
  State<DesktopMediaLibrarySortButton> createState() => DesktopMediaLibrarySortButtonState();
}

class DesktopMediaLibrarySortButtonState extends State<DesktopMediaLibrarySortButton> {
  bool _hover0 = false;
  bool _hover1 = false;
  final GlobalKey _key0 = GlobalKey();
  final GlobalKey _key1 = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.pathSegments.last;
    return Consumer<MediaLibrary>(
      builder: (context, mediaLibrary, _) => Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 8.0),
          GestureDetector(
            key: _key0,
            onTap: () async {
              final value = await showMaterialMenu(
                elevation: 4.0,
                context: context,
                constraints: const BoxConstraints(maxWidth: double.infinity),
                position: RelativeRect.fromLTRB(
                  _key0.globalPaintBounds!.left - 8.0,
                  widget.floating ? (_key0.globalPaintBounds!.bottom + margin) : (_key1.globalPaintBounds!.bottom + margin - captionHeight - kDesktopAppBarHeight),
                  MediaQuery.of(context).size.width,
                  MediaQuery.of(context).size.height,
                ),
                items: {
                  kAlbumsPath: AlbumSortType.values
                      .map(
                        (e) => CheckedPopupMenuItem(
                          value: e,
                          checked: e == mediaLibrary.albumSortType,
                          child: Text(
                            {
                              AlbumSortType.album: Localization.instance.A_TO_Z,
                              AlbumSortType.timestamp: Localization.instance.DATE_ADDED,
                              AlbumSortType.year: Localization.instance.YEAR,
                              AlbumSortType.albumArtist: Localization.instance.ALBUM_ARTIST,
                            }[e]!,
                            style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
                          ),
                        ),
                      )
                      .toList(),
                  kTracksPath: TrackSortType.values
                      .map(
                        (e) => CheckedPopupMenuItem(
                          value: e,
                          checked: e == mediaLibrary.trackSortType,
                          child: Text(
                            {
                              TrackSortType.title: Localization.instance.A_TO_Z,
                              TrackSortType.timestamp: Localization.instance.DATE_ADDED,
                              TrackSortType.year: Localization.instance.YEAR,
                            }[e]!,
                            style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
                          ),
                        ),
                      )
                      .toList(),
                  kArtistsPath: ArtistSortType.values
                      .map(
                        (e) => CheckedPopupMenuItem(
                          value: e,
                          checked: e == mediaLibrary.artistSortType,
                          child: Text(
                            {
                              ArtistSortType.artist: Localization.instance.A_TO_Z,
                              ArtistSortType.timestamp: Localization.instance.DATE_ADDED,
                            }[e]!,
                            style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
                          ),
                        ),
                      )
                      .toList(),
                  kGenresPath: GenreSortType.values
                      .map(
                        (e) => CheckedPopupMenuItem(
                          value: e,
                          checked: e == mediaLibrary.genreSortType,
                          child: Text(
                            {
                              GenreSortType.genre: Localization.instance.A_TO_Z,
                              GenreSortType.timestamp: Localization.instance.DATE_ADDED,
                            }[e]!,
                            style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
                          ),
                        ),
                      )
                      .toList(),
                }[path]!,
              );
              if (value is AlbumSortType) {
                await mediaLibrary.populate(albumSortType: value);
                await Configuration.instance.set(mediaLibraryAlbumSortType: value);
              } else if (value is TrackSortType) {
                await mediaLibrary.populate(trackSortType: value);
                await Configuration.instance.set(mediaLibraryTrackSortType: value);
              } else if (value is ArtistSortType) {
                await mediaLibrary.populate(artistSortType: value);
                await Configuration.instance.set(mediaLibraryArtistSortType: value);
              } else if (value is GenreSortType) {
                await mediaLibrary.populate(genreSortType: value);
                await Configuration.instance.set(mediaLibraryGenreSortType: value);
              }
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              onEnter: (e) => setState(() => _hover0 = true),
              onExit: (e) => setState(() => _hover0 = false),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                height: 28.0,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(width: 4.0),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${Localization.instance.SORT_BY}: ',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          TextSpan(
                            text: {
                              kAlbumsPath: {
                                AlbumSortType.album: Localization.instance.A_TO_Z,
                                AlbumSortType.timestamp: Localization.instance.DATE_ADDED,
                                AlbumSortType.year: Localization.instance.YEAR,
                                AlbumSortType.albumArtist: Localization.instance.ALBUM_ARTIST,
                              }[mediaLibrary.albumSortType]!,
                              kTracksPath: {
                                TrackSortType.title: Localization.instance.A_TO_Z,
                                TrackSortType.timestamp: Localization.instance.DATE_ADDED,
                                TrackSortType.year: Localization.instance.YEAR,
                              }[mediaLibrary.trackSortType]!,
                              kArtistsPath: {
                                ArtistSortType.artist: Localization.instance.A_TO_Z,
                                ArtistSortType.timestamp: Localization.instance.DATE_ADDED,
                              }[mediaLibrary.artistSortType]!,
                              kGenresPath: {
                                GenreSortType.genre: Localization.instance.A_TO_Z,
                                GenreSortType.timestamp: Localization.instance.DATE_ADDED,
                              }[mediaLibrary.genreSortType]!,
                            }[path]!,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  decoration: _hover0 ? TextDecoration.underline : null,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4.0),
                    Icon(
                      Icons.expand_more,
                      color: Theme.of(context).colorScheme.primary,
                      size: 18.0,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 4.0),
          GestureDetector(
            key: _key1,
            onTap: () async {
              final value = await showMaterialMenu(
                elevation: 4.0,
                context: context,
                constraints: const BoxConstraints(maxWidth: double.infinity),
                position: RelativeRect.fromLTRB(
                  margin,
                  widget.floating ? (_key1.globalPaintBounds!.bottom + margin) : (_key1.globalPaintBounds!.bottom + margin - captionHeight - kDesktopAppBarHeight),
                  margin - 1.0,
                  MediaQuery.of(context).size.height,
                ),
                items: <PopupMenuEntry<bool>>[
                  CheckedPopupMenuItem<bool>(
                    checked: {
                      kAlbumsPath: mediaLibrary.albumSortAscending,
                      kTracksPath: mediaLibrary.trackSortAscending,
                      kArtistsPath: mediaLibrary.artistSortAscending,
                      kGenresPath: mediaLibrary.genreSortAscending,
                    }[path]!,
                    value: true,
                    child: Text(
                      Localization.instance.ASCENDING,
                      style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
                    ),
                  ),
                  CheckedPopupMenuItem<bool>(
                    checked: {
                      kAlbumsPath: !mediaLibrary.albumSortAscending,
                      kTracksPath: !mediaLibrary.trackSortAscending,
                      kArtistsPath: !mediaLibrary.artistSortAscending,
                      kGenresPath: !mediaLibrary.genreSortAscending,
                    }[path]!,
                    value: false,
                    child: Text(
                      Localization.instance.DESCENDING,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ],
              );
              if (value != null) {
                switch (path) {
                  case kAlbumsPath:
                    await mediaLibrary.populate(albumSortAscending: value);
                    await Configuration.instance.set(mediaLibraryAlbumSortAscending: value);
                    break;
                  case kTracksPath:
                    await mediaLibrary.populate(trackSortAscending: value);
                    await Configuration.instance.set(mediaLibraryTrackSortAscending: value);
                    break;
                  case kArtistsPath:
                    await mediaLibrary.populate(artistSortAscending: value);
                    await Configuration.instance.set(mediaLibraryArtistSortAscending: value);
                    break;
                  case kGenresPath:
                    await mediaLibrary.populate(genreSortAscending: value);
                    await Configuration.instance.set(mediaLibraryGenreSortAscending: value);
                    break;
                }
              }
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              onEnter: (e) => setState(() => _hover1 = true),
              onExit: (e) => setState(() => _hover1 = false),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                height: 28.0,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(width: 4.0),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${Localization.instance.ORDER}: ',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          TextSpan(
                            text: {
                              true: Localization.instance.ASCENDING,
                              false: Localization.instance.DESCENDING,
                            }[{
                              kAlbumsPath: mediaLibrary.albumSortAscending,
                              kTracksPath: mediaLibrary.trackSortAscending,
                              kArtistsPath: mediaLibrary.artistSortAscending,
                              kGenresPath: mediaLibrary.genreSortAscending,
                            }[path]!]!,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  decoration: _hover1 ? TextDecoration.underline : null,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4.0),
                    Icon(
                      Icons.expand_more,
                      color: Theme.of(context).colorScheme.primary,
                      size: 18.0,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8.0),
        ],
      ),
    );
  }
}

// --------------------------------------------------

class DesktopMediaLibraryRefreshIndicator extends StatelessWidget {
  const DesktopMediaLibraryRefreshIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MediaLibrary>(
      builder: (context, mediaLibrary, _) {
        if (!mediaLibrary.refreshing) {
          return const SizedBox.shrink();
        }
        return Card(
          elevation: kDefaultCardElevation,
          clipBehavior: Clip.antiAlias,
          margin: EdgeInsets.zero,
          child: Container(
            width: 328.0,
            height: 56.0,
            color: Theme.of(context).cardTheme.color,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                LinearProgressIndicator(
                  value: mediaLibrary.current == null ? null : (mediaLibrary.current ?? 0) / (mediaLibrary.total == 0 ? 1 : mediaLibrary.total),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(width: 16.0),
                        const Icon(Icons.library_music),
                        const SizedBox(width: 16.0),
                        Text(
                          mediaLibrary.current == null
                              ? Localization.instance.DISCOVERING_FILES
                              : Localization.instance.ADDED_M_OF_N_FILES
                                  .replaceAll('"M"', (mediaLibrary.current ?? 0).toString())
                                  .replaceAll('"N"', (mediaLibrary.total == 0 ? 1 : mediaLibrary.total).toString()),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(width: 16.0),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// --------------------------------------------------

class MobileMediaLibraryHeader extends StatelessWidget {
  const MobileMediaLibraryHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.pathSegments.last;
    return Container(
      height: kMobileHeaderHeight,
      padding: EdgeInsets.symmetric(horizontal: margin),
      alignment: Alignment.centerRight,
      child: Row(
        children: [
          const SizedBox(width: 8.0),
          if (path == kAlbumsPath)
            Text(Localization.instance.N_ALBUMS.replaceAll('"N"', MediaLibrary.instance.albums.length.toString()))
          else if (path == kTracksPath)
            Text(Localization.instance.N_TRACKS.replaceAll('"N"', MediaLibrary.instance.tracks.length.toString()))
          else if (path == kArtistsPath)
            Text(Localization.instance.N_ARTISTS.replaceAll('"N"', MediaLibrary.instance.artists.length.toString()))
          else if (path == kGenresPath)
            Text(Localization.instance.N_GENRES.replaceAll('"N"', MediaLibrary.instance.genres.length.toString())),
          const Spacer(),
          MobileMediaLibrarySortButton(path: path),
        ],
      ),
    );
  }
}

// --------------------------------------------------

class MobileMediaLibrarySortButton extends StatefulWidget {
  final String path;
  const MobileMediaLibrarySortButton({super.key, required this.path});

  @override
  State<MobileMediaLibrarySortButton> createState() => MobileMediaLibrarySortButtonState();
}

class MobileMediaLibrarySortButtonState extends State<MobileMediaLibrarySortButton> {
  Future<void> handle(dynamic value) async {
    if (value is AlbumSortType) {
      MediaLibrary.instance.populate(albumSortType: value);
      Configuration.instance.set(mediaLibraryAlbumSortType: value);
    } else if (value is TrackSortType) {
      MediaLibrary.instance.populate(trackSortType: value);
      Configuration.instance.set(mediaLibraryTrackSortType: value);
    } else if (value is ArtistSortType) {
      MediaLibrary.instance.populate(artistSortType: value);
      Configuration.instance.set(mediaLibraryArtistSortType: value);
    } else if (value is GenreSortType) {
      MediaLibrary.instance.populate(genreSortType: value);
      Configuration.instance.set(mediaLibraryGenreSortType: value);
    }
    if (value == true) {
      switch (widget.path) {
        case kAlbumsPath:
          await MediaLibrary.instance.populate(albumSortAscending: true);
          await Configuration.instance.set(mediaLibraryAlbumSortAscending: true);
          break;
        case kTracksPath:
          await MediaLibrary.instance.populate(trackSortAscending: true);
          await Configuration.instance.set(mediaLibraryTrackSortAscending: true);
          break;
        case kArtistsPath:
          await MediaLibrary.instance.populate(artistSortAscending: true);
          await Configuration.instance.set(mediaLibraryArtistSortAscending: true);
          break;
        case kGenresPath:
          await MediaLibrary.instance.populate(genreSortAscending: true);
          await Configuration.instance.set(mediaLibraryGenreSortAscending: true);
          break;
      }
    } else if (value == false) {
      switch (widget.path) {
        case kAlbumsPath:
          await MediaLibrary.instance.populate(albumSortAscending: false);
          await Configuration.instance.set(mediaLibraryAlbumSortAscending: false);
          break;
        case kTracksPath:
          await MediaLibrary.instance.populate(trackSortAscending: false);
          await Configuration.instance.set(mediaLibraryTrackSortAscending: false);
          break;
        case kArtistsPath:
          await MediaLibrary.instance.populate(artistSortAscending: false);
          await Configuration.instance.set(mediaLibraryArtistSortAscending: false);
          break;
        case kGenresPath:
          await MediaLibrary.instance.populate(genreSortAscending: false);
          await Configuration.instance.set(mediaLibraryGenreSortAscending: false);
          break;
      }
    }
    setStateCallback?.call(() {});
  }

  void Function(void Function())? setStateCallback;

  List<MobileMediaLibrarySortButtonPopupMenuItem> get sort => {
        kAlbumsPath: AlbumSortType.values
            .map(
              (e) => MobileMediaLibrarySortButtonPopupMenuItem(
                onTap: () => handle(e),
                checked: MediaLibrary.instance.albumSortType == e,
                value: e,
                padding: EdgeInsets.zero,
                child: Text(
                  {
                    AlbumSortType.album: Localization.instance.A_TO_Z,
                    AlbumSortType.timestamp: Localization.instance.DATE_ADDED,
                    AlbumSortType.year: Localization.instance.YEAR,
                    AlbumSortType.albumArtist: Localization.instance.ALBUM_ARTIST,
                  }[e]!,
                  style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
                ),
              ),
            )
            .toList(),
        kTracksPath: TrackSortType.values
            .map(
              (e) => MobileMediaLibrarySortButtonPopupMenuItem(
                onTap: () => handle(e),
                checked: MediaLibrary.instance.trackSortType == e,
                value: e,
                padding: EdgeInsets.zero,
                child: Text(
                  {
                    TrackSortType.title: Localization.instance.A_TO_Z,
                    TrackSortType.timestamp: Localization.instance.DATE_ADDED,
                    TrackSortType.year: Localization.instance.YEAR,
                  }[e]!,
                  style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
                ),
              ),
            )
            .toList(),
        kArtistsPath: ArtistSortType.values
            .map(
              (e) => MobileMediaLibrarySortButtonPopupMenuItem(
                onTap: () => handle(e),
                checked: MediaLibrary.instance.artistSortType == e,
                value: e,
                padding: EdgeInsets.zero,
                child: Text(
                  {
                    ArtistSortType.artist: Localization.instance.A_TO_Z,
                    ArtistSortType.timestamp: Localization.instance.DATE_ADDED,
                  }[e]!,
                  style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
                ),
              ),
            )
            .toList(),
        kGenresPath: GenreSortType.values
            .map(
              (e) => MobileMediaLibrarySortButtonPopupMenuItem(
                onTap: () => handle(e),
                checked: MediaLibrary.instance.genreSortType == e,
                value: e,
                padding: EdgeInsets.zero,
                child: Text(
                  {
                    GenreSortType.genre: Localization.instance.A_TO_Z,
                    GenreSortType.timestamp: Localization.instance.DATE_ADDED,
                  }[e]!,
                  style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
                ),
              ),
            )
            .toList(),
      }[widget.path]!;

  List<MobileMediaLibrarySortButtonPopupMenuItem> get order => [
        MobileMediaLibrarySortButtonPopupMenuItem(
          onTap: () => handle(true),
          checked: {
            kAlbumsPath: MediaLibrary.instance.albumSortAscending,
            kTracksPath: MediaLibrary.instance.trackSortAscending,
            kArtistsPath: MediaLibrary.instance.artistSortAscending,
            kGenresPath: MediaLibrary.instance.genreSortAscending,
          }[widget.path]!,
          value: true,
          padding: EdgeInsets.zero,
          child: Text(
            Localization.instance.ASCENDING,
            style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
          ),
        ),
        MobileMediaLibrarySortButtonPopupMenuItem(
          onTap: () => handle(false),
          checked: {
            kAlbumsPath: !MediaLibrary.instance.albumSortAscending,
            kTracksPath: !MediaLibrary.instance.trackSortAscending,
            kArtistsPath: !MediaLibrary.instance.artistSortAscending,
            kGenresPath: !MediaLibrary.instance.genreSortAscending,
          }[widget.path]!,
          value: false,
          padding: EdgeInsets.zero,
          child: Text(
            Localization.instance.DESCENDING,
            style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
          ),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: isMaterial2 ? BorderRadius.circular(4.0) : BorderRadius.circular(20.0),
      onTap: () async {
        await showModalBottomSheet(
          context: context,
          showDragHandle: isMaterial3OrGreater,
          isScrollControlled: true,
          elevation: kDefaultHeavyElevation,
          builder: (context) => StatefulBuilder(
            builder: (context, setState) {
              setStateCallback = setState;
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...sort,
                  const PopupMenuDivider(),
                  ...order,
                  if (!isDesktop && NowPlayingMobileNotifier.instance.restored) const SizedBox(height: kMobileNowPlayingBarHeight),
                ],
              );
            },
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Text(
              String.fromCharCode(order.firstWhere((e) => e.checked).value ? Icons.arrow_upward.codePoint : Icons.arrow_downward.codePoint),
              style: TextStyle(
                inherit: false,
                fontSize: 18.0,
                fontWeight: FontWeight.w700,
                fontFamily: Icons.arrow_downward.fontFamily,
                package: Icons.arrow_downward.fontPackage,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 10.0),
            Text(
              label((sort.firstWhere((e) => e.checked).child as Text).data.toString()),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(width: 4.0),
          ],
        ),
      ),
    );
  }
}

// --------------------------------------------------

class MobileMediaLibrarySortButtonPopupMenuItem<T> extends StatelessWidget {
  final T value;
  final bool checked;
  final VoidCallback onTap;
  final Widget child;
  final EdgeInsets? padding;

  const MobileMediaLibrarySortButtonPopupMenuItem({
    super.key,
    required this.value,
    this.checked = false,
    required this.onTap,
    required this.child,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: AnimatedOpacity(
        opacity: checked ? 1.0 : 0.0,
        curve: Curves.easeInOut,
        duration: Theme.of(context).extension<AnimationDuration>()?.fast ?? Duration.zero,
        child: const Icon(Icons.done),
      ),
      title: child,
    );
  }
}

// --------------------------------------------------

class ScaleOnHover extends StatefulWidget {
  final Widget child;
  const ScaleOnHover({super.key, required this.child});

  @override
  ScaleOnHoverState createState() => ScaleOnHoverState();
}

class ScaleOnHoverState extends State<ScaleOnHover> {
  double scale = 1.0;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (e) => setState(() => scale = 1.05),
      onExit: (e) => setState(() => scale = 1.00),
      child: AnimatedScale(
        scale: scale,
        duration: Theme.of(context).extension<AnimationDuration>()?.fast ?? Duration.zero,
        child: widget.child,
      ),
    );
  }
}

// --------------------------------------------------

class ContextMenuListener extends StatefulWidget {
  final Widget child;
  final void Function(RelativeRect position) onSecondaryPress;
  const ContextMenuListener({super.key, required this.child, required this.onSecondaryPress});

  @override
  State<ContextMenuListener> createState() => ContextMenuListenerState();
}

class ContextMenuListenerState extends State<ContextMenuListener> {
  bool _reactToSecondaryPress = false;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (e) {
        _reactToSecondaryPress = e.kind == PointerDeviceKind.mouse && e.buttons == kSecondaryMouseButton;
      },
      onPointerUp: (e) async {
        if (!_reactToSecondaryPress) {
          return;
        }
        final path = GoRouterState.of(context).uri.pathSegments.last;
        widget.onSecondaryPress(
          RelativeRect.fromLTRB(
            e.position.dx,
            e.position.dy - (![kAlbumsPath, kTracksPath, kArtistsPath, kGenresPath, kPlaylistsPath, kSearchPath].contains(path) ? 0.0 : captionHeight + kDesktopAppBarHeight),
            MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height,
          ),
        );
      },
      child: widget.child,
    );
  }
}

// --------------------------------------------------

class SubHeader extends StatelessWidget {
  final String text;
  final EdgeInsets? padding;
  final double height;

  const SubHeader(
    this.text, {
    super.key,
    this.padding,
    this.height = 56.0,
  });

  @override
  Widget build(BuildContext context) {
    final horizontal = isDesktop ? 24.0 : 16.0;
    final fontSize = isDesktop ? 16.0 : null;
    final TextStyle? style;
    if (isMaterial2 && isMobile) {
      style = Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: fontSize,
          );
    } else if (isMaterial2 && isDesktop) {
      style = Theme.of(context).textTheme.titleSmall?.copyWith(
            fontSize: fontSize,
          );
    } else {
      style = Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontSize: fontSize,
          );
    }
    return Container(
      alignment: Alignment.centerLeft,
      height: height,
      padding: padding ?? EdgeInsets.symmetric(horizontal: horizontal),
      child: Text(
        text,
        style: style,
      ),
    );
  }
}

// --------------------------------------------------

class MediaLibraryRefreshButton extends StatelessWidget {
  const MediaLibraryRefreshButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MediaLibrary>(
      builder: (context, mediaLibrary, _) => mediaLibrary.refreshing
          ? const SizedBox.shrink()
          : FloatingActionButton(
              heroTag: 'MediaLibraryRefreshButton',
              onPressed: mediaLibrary.refresh,
              child: const Icon(Icons.refresh),
            ),
    );
  }
}

// --------------------------------------------------

class MediaLibraryCreatePlaylistButton extends StatelessWidget {
  const MediaLibraryCreatePlaylistButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MediaLibrary>(
      builder: (context, mediaLibrary, _) => FloatingActionButton(
        heroTag: 'MediaLibraryCreatePlaylistButton',
        onPressed: () async {
          final result = await showInput(
            context,
            Localization.instance.CREATE_NEW_PLAYLIST,
            Localization.instance.PLAYLIST_CREATE_DIALOG_SUBTITLE,
            Localization.instance.CREATE,
            (value) {
              if (value?.isEmpty ?? true) {
                return '';
              }
              return null;
            },
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.words,
          );
          if (result.isNotEmpty) {
            await mediaLibrary.playlists.create(result);
          }
        },
        child: const Icon(Icons.edit),
      ),
    );
  }
}

// --------------------------------------------------

class HyperLink extends StatefulWidget {
  final TextSpan text;
  final TextStyle? style;
  const HyperLink({
    super.key,
    required this.text,
    required this.style,
  });

  @override
  State<HyperLink> createState() => HyperLinkState();
}

class HyperLinkState extends State<HyperLink> {
  String hover = '';

  @override
  Widget build(BuildContext context) {
    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: widget.style,
        children: widget.text.children!
            .map(
              (e) => TextSpan(
                text: (e as TextSpan).text,
                style: e.recognizer != null
                    ? widget.style?.copyWith(
                        decoration: hover == e.text! ? TextDecoration.underline : null,
                      )
                    : null,
                recognizer: e.recognizer,
                onEnter: (_) {
                  if (mounted) {
                    setState(() {
                      hover = e.text!;
                    });
                  }
                },
                onExit: (_) {
                  if (mounted) {
                    setState(() {
                      hover = '';
                    });
                  }
                },
              ),
            )
            .toList(),
      ),
    );
  }
}

// --------------------------------------------------

class MobileNavigationBar extends StatelessWidget {
  const MobileNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.pathSegments.last;
    final paths = [
      kAlbumsPath,
      kTracksPath,
      kArtistsPath,
      kGenresPath,
      kPlaylistsPath,
    ];
    final index = paths.indexOf(path);
    final displayLabels = {
          Localization.instance.ALBUMS,
          Localization.instance.TRACKS,
          Localization.instance.ARTISTS,
          Localization.instance.GENRES,
          Localization.instance.PLAYLISTS,
        }.map((e) => e.length).max <=
        10;
    return isMaterial3
        ? NavigationBar(
            selectedIndex: index,
            onDestinationSelected: (i) {
              if (index == i) return;
              context.push('/$kMediaLibraryPath/${paths[i]}');
              Configuration.instance.set(mediaLibraryPath: paths[i]);
              NowPlayingMobileNotifier.instance.restore();
            },
            labelBehavior: displayLabels ? NavigationDestinationLabelBehavior.alwaysShow : NavigationDestinationLabelBehavior.alwaysHide,
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.album),
                label: Localization.instance.ALBUMS,
              ),
              NavigationDestination(
                icon: const Icon(Icons.music_note),
                label: Localization.instance.TRACKS,
              ),
              NavigationDestination(
                icon: const Icon(Icons.person),
                label: Localization.instance.ARTISTS,
              ),
              NavigationDestination(
                icon: const Icon(Icons.piano),
                label: Localization.instance.GENRES,
              ),
              NavigationDestination(
                icon: const Icon(Icons.playlist_play),
                label: Localization.instance.PLAYLISTS,
              ),
            ],
          )
        : Consumer<NowPlayingColorPaletteNotifier>(
            builder: (context, nowPlayingColorPaletteNotifier, _) => TweenAnimationBuilder<Color?>(
              duration: Theme.of(context).extension<AnimationDuration>()?.medium ?? Duration.zero,
              tween: ColorTween(
                begin: Theme.of(context).colorScheme.primary,
                end: nowPlayingColorPaletteNotifier.palette?.first ?? Theme.of(context).colorScheme.primary,
              ),
              builder: (context, color, _) => Container(
                decoration: const BoxDecoration(
                  boxShadow: [
                    BoxShadow(color: Colors.black45, blurRadius: 8.0),
                  ],
                ),
                child: BottomNavigationBar(
                  currentIndex: index,
                  selectedItemColor: (color?.computeLuminance() ?? 0.0) < 0.5 ? null : Colors.black87,
                  unselectedItemColor: (color?.computeLuminance() ?? 0.0) < 0.5 ? null : Colors.black45,
                  type: BottomNavigationBarType.shifting,
                  onTap: (i) {
                    if (index == i) return;
                    context.push('/$kMediaLibraryPath/${paths[i]}');
                    Configuration.instance.set(mediaLibraryPath: paths[i]);
                    NowPlayingMobileNotifier.instance.restore();
                  },
                  items: [
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.album),
                      label: displayLabels ? Localization.instance.ALBUMS : null,
                      backgroundColor: color ?? Theme.of(context).colorScheme.primary,
                    ),
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.music_note),
                      label: displayLabels ? Localization.instance.TRACKS : null,
                      backgroundColor: color ?? Theme.of(context).colorScheme.primary,
                    ),
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.person),
                      label: displayLabels ? Localization.instance.ARTISTS : null,
                      backgroundColor: color ?? Theme.of(context).colorScheme.primary,
                    ),
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.piano),
                      label: displayLabels ? Localization.instance.GENRES : null,
                      backgroundColor: color ?? Theme.of(context).colorScheme.primary,
                    ),
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.playlist_play),
                      label: displayLabels ? Localization.instance.PLAYLISTS : null,
                      backgroundColor: color ?? Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}

// --------------------------------------------------

class ShowAllButton extends StatelessWidget {
  final void Function()? onPressed;
  const ShowAllButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(4.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8.0,
          vertical: 4.0,
        ),
        child: Row(
          children: [
            Icon(
              Icons.view_list,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(
              width: 4.0,
            ),
            Text(
              Localization.instance.SEE_ALL,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// --------------------------------------------------

class ScrollableSlider extends StatelessWidget {
  final double min;
  final double max;
  final bool enabled;
  final double value;
  final void Function(double) onChanged;
  final VoidCallback? onScrolledUp;
  final VoidCallback? onScrolledDown;

  const ScrollableSlider({
    super.key,
    this.min = 0.0,
    this.max = 1.0,
    this.enabled = true,
    required this.value,
    required this.onChanged,
    this.onScrolledUp,
    this.onScrolledDown,
  });

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: (event) {
        if (event is PointerScrollEvent) {
          if (event.scrollDelta.dy < 0) {
            onScrolledUp?.call();
          }
          if (event.scrollDelta.dy > 0) {
            onScrolledDown?.call();
          }
        }
      },
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackHeight: isMobile ? null : 2.0,
          trackShape: CustomTrackShape(),
          thumbShape: isMobile ? null : const RoundSliderThumbShape(enabledThumbRadius: 6.0, pressedElevation: 4.0, elevation: 2.0),
          overlayShape: isMobile ? null : const RoundSliderOverlayShape(overlayRadius: 12.0),
        ),
        child: Slider(
          value: value,
          onChanged: enabled ? onChanged : null,
          min: min,
          max: max,
        ),
      ),
    );
  }
}

// --------------------------------------------------

class CustomTrackShape extends RoundedRectSliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight!;
    final double trackLeft = offset.dx;
    final double trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}

// --------------------------------------------------

class DefaultTextField extends StatelessWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final double? cursorWidth;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final void Function()? onEditingComplete;
  final InputDecoration? decoration;
  final TextAlignVertical? textAlignVertical;
  final bool? autofocus;
  final bool? autocorrect;
  final bool? readOnly;
  final TextStyle? style;
  final TextInputType? keyboardType;
  final TextCapitalization? textCapitalization;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final ScrollPhysics? scrollPhysics;
  final TextAlign? textAlign;
  const DefaultTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.cursorWidth,
    this.onChanged,
    this.onSubmitted,
    this.onEditingComplete,
    this.decoration,
    this.textAlignVertical = TextAlignVertical.center,
    this.autofocus,
    this.autocorrect,
    this.readOnly,
    this.style,
    this.keyboardType,
    this.textCapitalization,
    this.textInputAction,
    this.inputFormatters,
    this.scrollPhysics,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return KeyboardShortcutsInterceptor(
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        cursorWidth: cursorWidth ?? 2.0,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        onEditingComplete: onEditingComplete,
        decoration: decoration,
        textAlignVertical: textAlignVertical,
        autofocus: autofocus ?? false,
        autocorrect: autocorrect ?? true,
        readOnly: readOnly ?? false,
        style: style,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization ?? TextCapitalization.none,
        textInputAction: textInputAction,
        inputFormatters: inputFormatters,
        scrollPhysics: scrollPhysics,
        textAlign: textAlign ?? TextAlign.start,
      ),
    );
  }
}

// --------------------------------------------------

class DefaultTextFormField extends StatelessWidget {
  final String? initialValue;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final double? cursorWidth;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final void Function()? onEditingComplete;
  final InputDecoration? decoration;
  final TextAlignVertical? textAlignVertical;
  final bool? autofocus;
  final bool? autocorrect;
  final bool? readOnly;
  final TextStyle? style;
  final TextInputType? keyboardType;
  final TextCapitalization? textCapitalization;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final ScrollPhysics? scrollPhysics;
  final TextAlign? textAlign;
  const DefaultTextFormField({
    super.key,
    this.initialValue,
    this.controller,
    this.focusNode,
    this.cursorWidth,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.onEditingComplete,
    this.decoration,
    this.textAlignVertical = TextAlignVertical.center,
    this.autofocus,
    this.autocorrect,
    this.readOnly,
    this.style,
    this.keyboardType,
    this.textCapitalization,
    this.textInputAction,
    this.inputFormatters,
    this.scrollPhysics,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return KeyboardShortcutsInterceptor(
      child: TextFormField(
        initialValue: initialValue,
        controller: controller,
        focusNode: focusNode,
        cursorWidth: cursorWidth ?? 2.0,
        validator: validator,
        onChanged: onChanged,
        onFieldSubmitted: onFieldSubmitted,
        onEditingComplete: onEditingComplete,
        decoration: decoration,
        textAlignVertical: textAlignVertical,
        autofocus: autofocus ?? false,
        autocorrect: autocorrect ?? true,
        readOnly: readOnly ?? false,
        style: style,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization ?? TextCapitalization.none,
        textInputAction: textInputAction,
        inputFormatters: inputFormatters,
        scrollPhysics: scrollPhysics,
        textAlign: textAlign ?? TextAlign.start,
      ),
    );
  }
}

// --------------------------------------------------

class NowPlayingBarScrollHideNotifier extends StatelessWidget {
  final Widget child;
  const NowPlayingBarScrollHideNotifier({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (isDesktop) {
      return child;
    } else {
      return NotificationListener<UserScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.axis == Axis.vertical &&
              [
                AxisDirection.up,
                AxisDirection.down,
              ].contains(notification.metrics.axisDirection)) {
            if (notification.direction == ScrollDirection.forward) {
              NowPlayingMobileNotifier.instance.show();
            } else if (notification.direction == ScrollDirection.reverse) {
              NowPlayingMobileNotifier.instance.hide();
            }
          }
          return true;
        },
        child: child,
      );
    }
  }
}

// --------------------------------------------------

class PlayFileOrURLButton extends StatelessWidget {
  const PlayFileOrURLButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: Localization.instance.OPEN_FILE_OR_URL,
      icon: const Icon(Icons.file_open),
      iconSize: 20.0,
      splashRadius: 18.0,
      color: Theme.of(context).appBarTheme.actionsIconTheme?.color,
      onPressed: () async {
        final result = await pickResource(context, Localization.instance.OPEN_FILE_OR_URL);
        if (result != null) {
          await Intent.instance.play(result);
        }
      },
    );
  }
}

// --------------------------------------------------

class ReadFileOrURLMetadataButton extends StatelessWidget {
  const ReadFileOrURLMetadataButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: Localization.instance.READ_METADATA,
      icon: const Icon(Icons.code),
      iconSize: 20.0,
      splashRadius: 18.0,
      color: Theme.of(context).appBarTheme.actionsIconTheme?.color,
      onPressed: () async {
        final result = await pickResource(context, Localization.instance.READ_METADATA);
        if (result != null) {
          context.push(Uri(path: '/$kFileInfoPath', queryParameters: {kFileInfoArgResource: result}).toString());
        }
      },
    );
  }
}

// --------------------------------------------------

class MobileGridSpanButton extends StatelessWidget {
  const MobileGridSpanButton({super.key});

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.pathSegments.last;
    if (![kAlbumsPath, kArtistsPath, kGenresPath].contains(path)) {
      return const SizedBox.shrink();
    }
    return IconButton(
      icon: const Icon(Icons.view_list_outlined),
      onPressed: () async {
        final String title;
        final int groupValue;
        Future<void> Function(int?) onChanged;
        switch (path) {
          case kAlbumsPath:
            title = Localization.instance.MOBILE_ALBUM_GRID_SIZE;
            groupValue = Configuration.instance.mobileAlbumGridSpan;
            onChanged = (value) => Configuration.instance.set(mobileAlbumGridSpan: value);
            break;
          case kArtistsPath:
            title = Localization.instance.MOBILE_ARTIST_GRID_SIZE;
            groupValue = Configuration.instance.mobileArtistGridSpan;
            onChanged = (value) => Configuration.instance.set(mobileArtistGridSpan: value);
            break;
          case kGenresPath:
            title = Localization.instance.MOBILE_GENRE_GRID_SIZE;
            groupValue = Configuration.instance.mobileGenreGridSpan;
            onChanged = (value) => Configuration.instance.set(mobileGenreGridSpan: value);
            break;
          default:
            throw UnimplementedError();
        }

        await showDialog(
          context: context,
          builder: (context) => SimpleDialog(
            title: Text(title),
            children: [
              for (int i = 0; i <= 4; i++)
                RadioListTile<int?>(
                  value: i,
                  groupValue: groupValue,
                  onChanged: (value) {
                    onChanged(value).then((_) => Navigator.of(context).pop()).then((_) => MediaLibrary.instance.notify());
                  },
                  title: Text(
                    i == 0 ? '#' : i.toString(),
                    style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// --------------------------------------------------

class MobileAppBarOverflowButton extends StatefulWidget {
  const MobileAppBarOverflowButton({super.key});

  @override
  State<MobileAppBarOverflowButton> createState() => MobileAppBarOverflowButtonState();
}

class MobileAppBarOverflowButtonState extends State<MobileAppBarOverflowButton> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.more_vert),
      onPressed: () async {
        Completer<int> completer = Completer<int>();
        await showModalBottomSheet(
          context: context,
          showDragHandle: isMaterial3OrGreater,
          isScrollControlled: true,
          elevation: kDefaultHeavyElevation,
          builder: (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                onTap: () {
                  completer.complete(0);
                  Navigator.of(context).maybePop();
                },
                leading: const Icon(Icons.play_arrow),
                title: Text(
                  Localization.instance.PLAY_ALL,
                  style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
                ),
              ),
              ListTile(
                onTap: () {
                  completer.complete(1);
                  Navigator.of(context).maybePop();
                },
                leading: const Icon(Icons.shuffle),
                title: Text(
                  Localization.instance.SHUFFLE,
                  style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
                ),
              ),
              ListTile(
                onTap: () {
                  completer.complete(2);
                  Navigator.of(context).maybePop();
                },
                leading: const Icon(Icons.file_open),
                title: Text(
                  Localization.instance.OPEN_FILE_OR_URL,
                  style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
                ),
              ),
              ListTile(
                onTap: () {
                  completer.complete(3);
                  Navigator.of(context).maybePop();
                },
                leading: const Icon(Icons.code),
                title: Text(
                  Localization.instance.READ_METADATA,
                  style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
                ),
              ),
              ListTile(
                onTap: () {
                  completer.complete(4);
                  Navigator.of(context).maybePop();
                },
                leading: const Icon(Icons.settings),
                title: Text(
                  Localization.instance.SETTINGS,
                  style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
                ),
              ),
              if (!isDesktop && NowPlayingMobileNotifier.instance.restored) const SizedBox(height: kMobileNowPlayingBarHeight),
            ],
          ),
        );
        completer.future.then((value) async {
          await Future.delayed(const Duration(milliseconds: 300));
          switch (value) {
            case 0:
              {
                await MediaPlayer.instance.open(MediaLibrary.instance.tracks.map((e) => e.toPlayable()).toList());
                break;
              }
            case 1:
              {
                MediaPlayer.instance.open([...MediaLibrary.instance.tracks.map((e) => e.toPlayable())]..shuffle());
                break;
              }
            case 2:
              {
                final result = await pickResource(context, Localization.instance.OPEN_FILE_OR_URL);
                if (result != null) {
                  await Intent.instance.play(result);
                }
                break;
              }
            case 3:
              {
                final result = await pickResource(context, Localization.instance.READ_METADATA);
                if (result != null) {
                  context.push(Uri(path: '/$kFileInfoPath', queryParameters: {kFileInfoArgResource: result}).toString());
                }
                break;
              }
            case 4:
              {
                await context.push('/$kSettingsPath');
                break;
              }
          }
        });
      },
    );
  }
}

// --------------------------------------------------

class StillGIF extends StatefulWidget {
  final ImageProvider image;
  final double width;
  final double height;

  const StillGIF({
    super.key,
    required this.image,
    required this.width,
    required this.height,
  });

  factory StillGIF.asset(
    String image, {
    Key? key,
    required double width,
    required double height,
  }) =>
      StillGIF(
        key: key,
        image: AssetImage(image),
        width: width,
        height: height,
      );

  factory StillGIF.file(
    String image, {
    Key? key,
    required double width,
    required double height,
  }) =>
      StillGIF(
        key: key,
        image: FileImage(File(image)),
        width: width,
        height: height,
      );

  factory StillGIF.network(
    String image, {
    Key? key,
    required double width,
    required double height,
  }) =>
      StillGIF(
        key: key,
        image: NetworkImage(image),
        width: width,
        height: height,
      );

  @override
  State<StillGIF> createState() => StillGIFState();
}

class StillGIFState extends State<StillGIF> {
  RawImage? image;

  @override
  void initState() {
    super.initState();
    draw();
  }

  Future<void> draw() async {
    await widget.image.evict();
    if (widget.image is NetworkImage) {
      final resolved = Uri.base.resolve((widget.image as NetworkImage).url);
      final request = await HttpClient().getUrl(resolved);
      final HttpClientResponse response = await request.close();
      final data = await consolidateHttpClientResponseBytes(response);
      final buffer = await ImmutableBuffer.fromUint8List(data);
      final codec = await PaintingBinding.instance.instantiateImageCodecWithSize(buffer);
      final frame = await codec.getNextFrame();
      setState(() {
        image = RawImage(
          image: frame.image.clone(),
          height: widget.height,
          width: widget.width,
          fit: BoxFit.cover,
        );
      });
    } else if (widget.image is AssetImage) {
      final buffer = await ImmutableBuffer.fromAsset(
        (widget.image as AssetImage).assetName,
      );
      final codec = await PaintingBinding.instance.instantiateImageCodecWithSize(buffer);
      final frame = await codec.getNextFrame();
      setState(() {
        image = RawImage(
          image: frame.image.clone(),
          height: widget.height,
          width: widget.width,
          fit: BoxFit.cover,
        );
      });
    } else if (widget.image is FileImage) {
      final data = await (widget.image as FileImage).file.readAsBytes();
      final buffer = await ImmutableBuffer.fromUint8List(data);
      final codec = await PaintingBinding.instance.instantiateImageCodecWithSize(buffer);
      final frame = await codec.getNextFrame();
      setState(() {
        image = RawImage(
          image: frame.image.clone(),
          height: widget.height,
          width: widget.width,
          fit: BoxFit.cover,
        );
      });
    }
  }

  @override
  void dispose() {
    widget.image.evict();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return image ??
        SizedBox(
          width: widget.width,
          height: widget.height,
        );
  }
}

// --------------------------------------------------

class ListItem extends StatefulWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  // https://github.com/flutter/flutter/issues/29549
  // https://stackoverflow.com/a/54113677/12825435

  const ListItem({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
  });

  @override
  State<ListItem> createState() => ListItemState();
}

class ListItemState extends State<ListItem> {
  final ValueNotifier<bool> isThreeLineNotifier = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isThreeLineNotifier,
      builder: (context, isThreeLine, _) {
        return ListTile(
          leading: widget.leading,
          trailing: widget.trailing,
          title: Text(
            widget.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).listTileTheme.titleTextStyle,
          ),
          subtitle: widget.subtitle == null
              ? null
              : Stack(
                  children: [
                    Positioned.fill(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final textSpan = TextSpan(
                            text: widget.subtitle,
                            style: Theme.of(context).listTileTheme.subtitleTextStyle,
                          );
                          final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
                          textPainter.layout(maxWidth: constraints.maxWidth);
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (textPainter.computeLineMetrics().length >= 2) {
                              isThreeLineNotifier.value = true;
                            } else {
                              isThreeLineNotifier.value = false;
                            }
                          });
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    Text(
                      widget.subtitle!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
          isThreeLine: isThreeLine,
          onTap: widget.onTap,
        );
      },
    );
  }
}

// --------------------------------------------------

class StatefulAnimatedIcon extends StatefulWidget {
  final bool dismissed;
  final AnimatedIconData icon;
  final double size;

  const StatefulAnimatedIcon({
    super.key,
    required this.dismissed,
    required this.icon,
    this.size = 24.0,
  });

  @override
  State<StatefulAnimatedIcon> createState() => StatefulAnimatedIconState();
}

class StatefulAnimatedIconState extends State<StatefulAnimatedIcon> with SingleTickerProviderStateMixin {
  late final AnimationController progress = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
    reverseDuration: const Duration(milliseconds: 200),
  );

  @override
  void initState() {
    super.initState();
    if (widget.dismissed) {
      progress.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(StatefulAnimatedIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dismissed != widget.dismissed) {
      if (widget.dismissed) {
        progress.forward();
      } else {
        progress.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedIcon(
      progress: progress,
      icon: widget.icon,
      size: widget.size,
    );
  }
}

// --------------------------------------------------

class StatefulPageViewBuilder extends StatefulWidget {
  final int index;
  final Widget Function(BuildContext, int) itemBuilder;
  final int? itemCount;
  final ScrollPhysics? physics;
  const StatefulPageViewBuilder({
    super.key,
    required this.index,
    required this.itemBuilder,
    this.itemCount,
    this.physics,
  });

  @override
  State<StatefulPageViewBuilder> createState() => StatefulPageViewBuilderState();
}

class StatefulPageViewBuilderState extends State<StatefulPageViewBuilder> {
  late final PageController controller = PageController(
    initialPage: widget.index,
    // https://github.com/flutter/flutter/issues/31191
    viewportFraction: 0.9999999999,
  );

  @override
  void didUpdateWidget(covariant StatefulPageViewBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      if ((oldWidget.index - widget.index).abs() > 5) {
        controller.jumpToPage(widget.index);
      } else {
        controller.animateToPage(
          widget.index,
          duration: Theme.of(context).extension<AnimationDuration>()?.slow ?? Duration.zero,
          curve: Curves.easeInOut,
        );
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: controller,
      physics: widget.physics,
      itemCount: widget.itemCount,
      itemBuilder: (context, index) => widget.itemBuilder(context, index),
    );
  }
}

// --------------------------------------------------

class SliverSpacer extends StatelessWidget {
  const SliverSpacer({super.key});

  Widget _buildDesktopLayout(BuildContext context) => const SizedBox(height: kDesktopSliverTileSpacerHeight);

  Widget _buildTabletLayout(BuildContext context) => throw UnimplementedError();

  Widget _buildMobileLayout(BuildContext context) => const SizedBox(height: kMobileSliverTileSpacerHeight);

  @override
  Widget build(BuildContext context) {
    if (isDesktop) {
      return _buildDesktopLayout(context);
    }
    if (isTablet) {
      return _buildTabletLayout(context);
    }
    if (isMobile) {
      return _buildMobileLayout(context);
    }
    throw UnimplementedError();
  }
}

// --------------------------------------------------

class MusicAnimation extends StatelessWidget {
  final Color? color;
  final double width;
  final double height;
  final int separatorFlex;

  const MusicAnimation({
    super.key,
    this.color,
    this.width = double.infinity,
    this.height = double.infinity,
    this.separatorFlex = 1,
  });

  @override
  Widget build(BuildContext context) {
    const durations = <int>[1000, 1250, 1500];

    return SizedBox(
      width: width,
      height: height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final duration in durations) ...[
            Expanded(
              flex: 4,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return _MusicAnimationComponent(
                    curve: Curves.bounceOut,
                    color: color ?? Theme.of(context).iconTheme.color ?? Theme.of(context).colorScheme.primary,
                    duration: Duration(milliseconds: duration),
                    height: constraints.maxHeight,
                  );
                },
              ),
            ),
            Spacer(flex: separatorFlex),
          ],
        ]..removeLast(),
      ),
    );
  }
}

class _MusicAnimationComponent extends StatefulWidget {
  final Curve curve;
  final Color color;
  final Duration duration;
  final double height;

  const _MusicAnimationComponent({
    required this.curve,
    required this.color,
    required this.duration,
    required this.height,
  });

  @override
  _MusicAnimationComponentState createState() => _MusicAnimationComponentState();
}

class _MusicAnimationComponentState extends State<_MusicAnimationComponent> with SingleTickerProviderStateMixin {
  late final AnimationController controller = AnimationController(duration: widget.duration, vsync: this);
  late final Animation<double> animation = Tween<double>(begin: 0.0, end: widget.height).animate(CurvedAnimation(parent: controller, curve: widget.curve));

  @override
  void initState() {
    super.initState();
    controller
      ..value = widget.height * Random().nextDouble() * 0.5
      ..repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) => Container(
        height: animation.value,
        color: widget.color,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }
}
