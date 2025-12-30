// ignore_for_file: depend_on_referenced_packages, invalid_use_of_protected_member

import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:collection/collection.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide CarouselView, CarouselController, ReorderableDragStartListener, Intent;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:identity/identity.dart';
import 'package:m3_expressive_shapes/rounded_polygon_border.dart';
import 'package:m3_expressive_shapes/shapes/material_shapes.dart';
import 'package:media_library/media_library.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/core/intent.dart';
import 'package:harmonoid/core/media_player/media_player.dart';
import 'package:harmonoid/extensions/build_context.dart';
import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/mappers/track.dart';
import 'package:harmonoid/state/now_playing_mobile_notifier.dart';
import 'package:harmonoid/ui/media_library/folders/state/file_explorer_notifier.dart';
import 'package:harmonoid/ui/now_playing/now_playing_bar.dart';
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
  @override
  Widget build(BuildContext context) {
    final path = context.location.split('/').last;

    if (![kAlbumsPath, kTracksPath, kArtistsPath, kGenresPath, kFoldersPath].contains(path)) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 16.0),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(4.0),
            onTap: () {
              MediaPlayer.instance.open(context.read<MediaLibrary>().tracks.map((e) => e.toPlayable()));
            },
            child: Container(
              height: 44.0,
              padding: const EdgeInsets.only(left: 2.0, right: 6.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.play_arrow,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 4.0),
                  Text(
                    Localization.instance.PLAY_ALL,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.primary),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 4.0),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(4.0),
            onTap: () {
              MediaPlayer.instance.open(context.read<MediaLibrary>().tracks.map((e) => e.toPlayable()), shuffle: true);
            },
            child: Container(
              height: 44.0,
              padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shuffle,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 4.0),
                  Text(
                    Localization.instance.SHUFFLE,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.primary),
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
    final path = context.location.split('/').last;

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
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
          child: child,
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
  final MenuController _sortMenuController = MenuController();
  final MenuController _orderMenuController = MenuController();

  EdgeInsetsGeometry get _inkWellPadding {
    return widget.floating ? EdgeInsets.zero : const EdgeInsets.symmetric(vertical: 8.0);
  }

  BorderRadius get _inkWellBorderRadius {
    return widget.floating ? BorderRadius.zero : BorderRadius.circular(4.0);
  }

  EdgeInsetsGeometry get _containerPadding {
    return const EdgeInsetsDirectional.only(start: 6.0, end: 4.0);
  }

  ButtonStyle get _menuItemStyle {
    return const ButtonStyle(padding: WidgetStatePropertyAll(EdgeInsets.only(left: 8.0, right: 20.0)));
  }

  Offset get _menuAnchorAlignmentOffset {
    return widget.floating ? const Offset(0.0, 8.0) : const Offset(0.0, -8.0);
  }

  Widget _buildLeadingIcon(bool selected) {
    return Icon(Icons.check, size: 20.0, color: selected ? null : Colors.transparent);
  }

  Widget _buildDirectionalityLtr(Widget child) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: child,
    );
  }

  Widget _buildDirectionalityRtl(Widget child) {
    if (widget.floating) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: child,
      );
    }
    return child;
  }

  @override
  Widget build(BuildContext context) {
    final path = context.location.split('/').last;
    return Consumer2<MediaLibrary, FileExplorerNotifier>(
      builder: (context, mediaLibrary, fileExplorerNotifier, _) => Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildDirectionalityLtr(
            MenuAnchor(
              controller: _sortMenuController,
              alignmentOffset: _menuAnchorAlignmentOffset,
              menuChildren: switch (path) {
                kAlbumsPath =>
                  AlbumSortType.values
                      .map(
                        (e) => MenuItemButton(
                          onPressed: () async {
                            await mediaLibrary.populate(albumSortType: e);
                            await Configuration.instance.set(mediaLibraryAlbumSortType: e);
                          },
                          style: _menuItemStyle,
                          leadingIcon: _buildLeadingIcon(mediaLibrary.albumSortType == e),
                          child: Text(
                            switch (e) {
                              AlbumSortType.album => Localization.instance.A_TO_Z,
                              AlbumSortType.timestamp => Localization.instance.DATE_ADDED,
                              AlbumSortType.year => Localization.instance.YEAR,
                              AlbumSortType.albumArtist => Localization.instance.ALBUM_ARTIST,
                            },
                            style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
                          ),
                        ),
                      )
                      .toList(),
                kTracksPath =>
                  TrackSortType.values
                      .map(
                        (e) => MenuItemButton(
                          onPressed: () async {
                            await mediaLibrary.populate(trackSortType: e);
                            await Configuration.instance.set(mediaLibraryTrackSortType: e);
                          },
                          style: _menuItemStyle,
                          leadingIcon: _buildLeadingIcon(mediaLibrary.trackSortType == e),
                          child: Text(
                            switch (e) {
                              TrackSortType.title => Localization.instance.A_TO_Z,
                              TrackSortType.timestamp => Localization.instance.DATE_ADDED,
                              TrackSortType.year => Localization.instance.YEAR,
                            },
                            style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
                          ),
                        ),
                      )
                      .toList(),
                kArtistsPath =>
                  ArtistSortType.values
                      .map(
                        (e) => MenuItemButton(
                          onPressed: () async {
                            await mediaLibrary.populate(artistSortType: e);
                            await Configuration.instance.set(mediaLibraryArtistSortType: e);
                          },
                          style: _menuItemStyle,
                          leadingIcon: _buildLeadingIcon(mediaLibrary.artistSortType == e),
                          child: Text(
                            switch (e) {
                              ArtistSortType.artist => Localization.instance.A_TO_Z,
                              ArtistSortType.timestamp => Localization.instance.DATE_ADDED,
                            },
                            style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
                          ),
                        ),
                      )
                      .toList(),
                kGenresPath =>
                  GenreSortType.values
                      .map(
                        (e) => MenuItemButton(
                          onPressed: () async {
                            await mediaLibrary.populate(genreSortType: e);
                            await Configuration.instance.set(mediaLibraryGenreSortType: e);
                          },
                          style: _menuItemStyle,
                          leadingIcon: _buildLeadingIcon(mediaLibrary.genreSortType == e),
                          child: Text(
                            switch (e) {
                              GenreSortType.genre => Localization.instance.A_TO_Z,
                              GenreSortType.timestamp => Localization.instance.DATE_ADDED,
                            },
                            style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
                          ),
                        ),
                      )
                      .toList(),
                kFoldersPath =>
                  FileExplorerSortType.values
                      .map(
                        (e) => MenuItemButton(
                          onPressed: () => fileExplorerNotifier.setSortType(e),
                          style: _menuItemStyle,
                          leadingIcon: _buildLeadingIcon(fileExplorerNotifier.sortType == e),
                          child: Text(
                            switch (e) {
                              FileExplorerSortType.name => Localization.instance.A_TO_Z,
                              FileExplorerSortType.timestamp => Localization.instance.DATE_ADDED,
                            },
                            style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
                          ),
                        ),
                      )
                      .toList(),
                _ => [],
              },
              child: Padding(
                padding: _inkWellPadding,
                child: InkWell(
                  borderRadius: _inkWellBorderRadius,
                  onTap: () {
                    if (_sortMenuController.isOpen) {
                      _sortMenuController.close();
                    } else {
                      _sortMenuController.open();
                    }
                  },
                  child: Container(
                    height: 44.0,
                    alignment: Alignment.center,
                    padding: _containerPadding,
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
                                text: switch (path) {
                                  kAlbumsPath => switch (mediaLibrary.albumSortType) {
                                    AlbumSortType.album => Localization.instance.A_TO_Z,
                                    AlbumSortType.timestamp => Localization.instance.DATE_ADDED,
                                    AlbumSortType.year => Localization.instance.YEAR,
                                    AlbumSortType.albumArtist => Localization.instance.ALBUM_ARTIST,
                                  },
                                  kTracksPath => switch (mediaLibrary.trackSortType) {
                                    TrackSortType.title => Localization.instance.A_TO_Z,
                                    TrackSortType.timestamp => Localization.instance.DATE_ADDED,
                                    TrackSortType.year => Localization.instance.YEAR,
                                  },
                                  kArtistsPath => switch (mediaLibrary.artistSortType) {
                                    ArtistSortType.artist => Localization.instance.A_TO_Z,
                                    ArtistSortType.timestamp => Localization.instance.DATE_ADDED,
                                  },
                                  kGenresPath => switch (mediaLibrary.genreSortType) {
                                    GenreSortType.genre => Localization.instance.A_TO_Z,
                                    GenreSortType.timestamp => Localization.instance.DATE_ADDED,
                                  },
                                  kFoldersPath => switch (fileExplorerNotifier.sortType) {
                                    FileExplorerSortType.name => Localization.instance.A_TO_Z,
                                    FileExplorerSortType.timestamp => Localization.instance.DATE_ADDED,
                                  },
                                  _ => '',
                                },
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.primary),
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
            ),
          ),
          const SizedBox(width: 4.0),
          _buildDirectionalityRtl(
            MenuAnchor(
              controller: _orderMenuController,
              alignmentOffset: _menuAnchorAlignmentOffset,
              menuChildren: [
                _buildDirectionalityLtr(
                  MenuItemButton(
                    onPressed: () async {
                      if (path == kFoldersPath) {
                        fileExplorerNotifier.setSortAscending(true);
                        return;
                      }

                      final albumSortAscending = path == kAlbumsPath ? true : null;
                      final trackSortAscending = path == kTracksPath ? true : null;
                      final artistSortAscending = path == kArtistsPath ? true : null;
                      final genreSortAscending = path == kGenresPath ? true : null;
                      await mediaLibrary.populate(
                        albumSortAscending: albumSortAscending,
                        trackSortAscending: trackSortAscending,
                        artistSortAscending: artistSortAscending,
                        genreSortAscending: genreSortAscending,
                      );
                      await Configuration.instance.set(
                        mediaLibraryAlbumSortAscending: albumSortAscending,
                        mediaLibraryTrackSortAscending: trackSortAscending,
                        mediaLibraryArtistSortAscending: artistSortAscending,
                        mediaLibraryGenreSortAscending: genreSortAscending,
                      );
                    },
                    style: _menuItemStyle,
                    leadingIcon: _buildLeadingIcon(
                      switch (path) {
                        kAlbumsPath => mediaLibrary.albumSortAscending,
                        kTracksPath => mediaLibrary.trackSortAscending,
                        kArtistsPath => mediaLibrary.artistSortAscending,
                        kGenresPath => mediaLibrary.genreSortAscending,
                        kFoldersPath => fileExplorerNotifier.sortAscending,
                        _ => false,
                      },
                    ),
                    child: Text(
                      Localization.instance.ASCENDING,
                      style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
                    ),
                  ),
                ),
                _buildDirectionalityLtr(
                  MenuItemButton(
                    onPressed: () async {
                      if (path == kFoldersPath) {
                        fileExplorerNotifier.setSortAscending(false);
                        return;
                      }

                      final albumSortAscending = path == kAlbumsPath ? false : null;
                      final trackSortAscending = path == kTracksPath ? false : null;
                      final artistSortAscending = path == kArtistsPath ? false : null;
                      final genreSortAscending = path == kGenresPath ? false : null;
                      await mediaLibrary.populate(
                        albumSortAscending: albumSortAscending,
                        trackSortAscending: trackSortAscending,
                        artistSortAscending: artistSortAscending,
                        genreSortAscending: genreSortAscending,
                      );
                      await Configuration.instance.set(
                        mediaLibraryAlbumSortAscending: albumSortAscending,
                        mediaLibraryTrackSortAscending: trackSortAscending,
                        mediaLibraryArtistSortAscending: artistSortAscending,
                        mediaLibraryGenreSortAscending: genreSortAscending,
                      );
                    },
                    style: _menuItemStyle,
                    leadingIcon: _buildLeadingIcon(
                      !switch (path) {
                        kAlbumsPath => mediaLibrary.albumSortAscending,
                        kTracksPath => mediaLibrary.trackSortAscending,
                        kArtistsPath => mediaLibrary.artistSortAscending,
                        kGenresPath => mediaLibrary.genreSortAscending,
                        kFoldersPath => fileExplorerNotifier.sortAscending,
                        _ => false,
                      },
                    ),
                    child: Text(
                      Localization.instance.DESCENDING,
                      style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
                    ),
                  ),
                ),
              ],
              child: Padding(
                padding: _inkWellPadding,
                child: InkWell(
                  borderRadius: _inkWellBorderRadius,
                  onTap: () {
                    if (_orderMenuController.isOpen) {
                      _orderMenuController.close();
                    } else {
                      _orderMenuController.open();
                    }
                  },
                  child: Container(
                    height: 44.0,
                    alignment: Alignment.center,
                    padding: _containerPadding,
                    child: _buildDirectionalityLtr(
                      Row(
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
                                  text:
                                      switch (path) {
                                        kAlbumsPath => mediaLibrary.albumSortAscending,
                                        kTracksPath => mediaLibrary.trackSortAscending,
                                        kArtistsPath => mediaLibrary.artistSortAscending,
                                        kGenresPath => mediaLibrary.genreSortAscending,
                                        kFoldersPath => fileExplorerNotifier.sortAscending,
                                        _ => false,
                                      }
                                      ? Localization.instance.ASCENDING
                                      : Localization.instance.DESCENDING,
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.primary),
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------

class MobileMediaLibraryHeader extends StatelessWidget {
  const MobileMediaLibraryHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final path = context.location.split('/').last;
    return Container(
      height: kMobileHeaderHeight,
      padding: EdgeInsets.symmetric(horizontal: margin),
      alignment: Alignment.centerRight,
      child: Consumer<MediaLibrary>(
        builder: (context, mediaLibrary, _) {
          return Row(
            children: [
              const SizedBox(width: 8.0),
              if (path == kAlbumsPath)
                Text(mediaLibrary.albums.length == 1 ? Localization.instance.ONE_ALBUM : Localization.instance.N_ALBUMS.replaceAll('"N"', mediaLibrary.albums.length.toString()))
              else if (path == kTracksPath)
                Text(mediaLibrary.albums.length == 1 ? Localization.instance.ONE_TRACK : Localization.instance.N_TRACKS.replaceAll('"N"', mediaLibrary.tracks.length.toString()))
              else if (path == kArtistsPath)
                Text(mediaLibrary.albums.length == 1 ? Localization.instance.ONE_ARTIST : Localization.instance.N_ARTISTS.replaceAll('"N"', mediaLibrary.artists.length.toString()))
              else if (path == kGenresPath)
                Text(mediaLibrary.albums.length == 1 ? Localization.instance.ONE_GENRE : Localization.instance.N_GENRES.replaceAll('"N"', mediaLibrary.genres.length.toString())),
              const Spacer(),
              MobileMediaLibrarySortButton(path: path),
            ],
          );
        },
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
  void Function(void Function())? _setStateCallback;
  late final MediaLibrary _mediaLibrary = context.read<MediaLibrary>();
  late final FileExplorerNotifier _fileExplorerNotifier = context.read<FileExplorerNotifier>();

  Future<void> _handle(dynamic value) async {
    if (value is AlbumSortType) {
      await _mediaLibrary.populate(albumSortType: value);
      await Configuration.instance.set(mediaLibraryAlbumSortType: value);
    } else if (value is TrackSortType) {
      await _mediaLibrary.populate(trackSortType: value);
      await Configuration.instance.set(mediaLibraryTrackSortType: value);
    } else if (value is ArtistSortType) {
      await _mediaLibrary.populate(artistSortType: value);
      await Configuration.instance.set(mediaLibraryArtistSortType: value);
    } else if (value is GenreSortType) {
      await _mediaLibrary.populate(genreSortType: value);
      await Configuration.instance.set(mediaLibraryGenreSortType: value);
    } else if (value is FileExplorerSortType) {
      _fileExplorerNotifier.setSortType(value);
    }
    if (value == true) {
      switch (widget.path) {
        case kAlbumsPath:
          await _mediaLibrary.populate(albumSortAscending: true);
          await Configuration.instance.set(mediaLibraryAlbumSortAscending: true);
          break;
        case kTracksPath:
          await _mediaLibrary.populate(trackSortAscending: true);
          await Configuration.instance.set(mediaLibraryTrackSortAscending: true);
          break;
        case kArtistsPath:
          await _mediaLibrary.populate(artistSortAscending: true);
          await Configuration.instance.set(mediaLibraryArtistSortAscending: true);
          break;
        case kGenresPath:
          await _mediaLibrary.populate(genreSortAscending: true);
          await Configuration.instance.set(mediaLibraryGenreSortAscending: true);
          break;
        case kFoldersPath:
          _fileExplorerNotifier.setSortAscending(true);
          break;
      }
    } else if (value == false) {
      switch (widget.path) {
        case kAlbumsPath:
          await _mediaLibrary.populate(albumSortAscending: false);
          await Configuration.instance.set(mediaLibraryAlbumSortAscending: false);
          break;
        case kTracksPath:
          await _mediaLibrary.populate(trackSortAscending: false);
          await Configuration.instance.set(mediaLibraryTrackSortAscending: false);
          break;
        case kArtistsPath:
          await _mediaLibrary.populate(artistSortAscending: false);
          await Configuration.instance.set(mediaLibraryArtistSortAscending: false);
          break;
        case kGenresPath:
          await _mediaLibrary.populate(genreSortAscending: false);
          await Configuration.instance.set(mediaLibraryGenreSortAscending: false);
          break;
        case kFoldersPath:
          _fileExplorerNotifier.setSortAscending(false);
          break;
      }
    }
    _setStateCallback?.call(() {});
  }

  List<MobileMediaLibrarySortButtonPopupMenuItem> get _sort => {
    kAlbumsPath: [AlbumSortType.album, AlbumSortType.timestamp, AlbumSortType.year]
        .map(
          (e) => MobileMediaLibrarySortButtonPopupMenuItem(
            onTap: () => _handle(e),
            checked: _mediaLibrary.albumSortType == e,
            value: e,
            padding: EdgeInsets.zero,
            child: Text(
              switch (e) {
                AlbumSortType.album => Localization.instance.A_TO_Z,
                AlbumSortType.timestamp => Localization.instance.DATE_ADDED,
                AlbumSortType.year => Localization.instance.YEAR,
                AlbumSortType.albumArtist => Localization.instance.ALBUM_ARTIST,
              },
              style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
            ),
          ),
        )
        .toList(),
    kTracksPath: TrackSortType.values
        .map(
          (e) => MobileMediaLibrarySortButtonPopupMenuItem(
            onTap: () => _handle(e),
            checked: _mediaLibrary.trackSortType == e,
            value: e,
            padding: EdgeInsets.zero,
            child: Text(
              switch (e) {
                TrackSortType.title => Localization.instance.A_TO_Z,
                TrackSortType.timestamp => Localization.instance.DATE_ADDED,
                TrackSortType.year => Localization.instance.YEAR,
              },
              style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
            ),
          ),
        )
        .toList(),
    kArtistsPath: ArtistSortType.values
        .map(
          (e) => MobileMediaLibrarySortButtonPopupMenuItem(
            onTap: () => _handle(e),
            checked: _mediaLibrary.artistSortType == e,
            value: e,
            padding: EdgeInsets.zero,
            child: Text(
              switch (e) {
                ArtistSortType.artist => Localization.instance.A_TO_Z,
                ArtistSortType.timestamp => Localization.instance.DATE_ADDED,
              },
              style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
            ),
          ),
        )
        .toList(),
    kGenresPath: GenreSortType.values
        .map(
          (e) => MobileMediaLibrarySortButtonPopupMenuItem(
            onTap: () => _handle(e),
            checked: _mediaLibrary.genreSortType == e,
            value: e,
            padding: EdgeInsets.zero,
            child: Text(
              switch (e) {
                GenreSortType.genre => Localization.instance.A_TO_Z,
                GenreSortType.timestamp => Localization.instance.DATE_ADDED,
              },
              style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
            ),
          ),
        )
        .toList(),
    kFoldersPath: FileExplorerSortType.values
        .map(
          (e) => MobileMediaLibrarySortButtonPopupMenuItem(
            onTap: () => _handle(e),
            checked: _fileExplorerNotifier.sortType == e,
            value: e,
            padding: EdgeInsets.zero,
            child: Text(
              switch (e) {
                FileExplorerSortType.name => Localization.instance.A_TO_Z,
                FileExplorerSortType.timestamp => Localization.instance.DATE_ADDED,
              },
              style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
            ),
          ),
        )
        .toList(),
  }[widget.path]!;

  List<MobileMediaLibrarySortButtonPopupMenuItem> get _order => [
    MobileMediaLibrarySortButtonPopupMenuItem(
      onTap: () => _handle(true),
      checked: switch (widget.path) {
        kAlbumsPath => _mediaLibrary.albumSortAscending,
        kTracksPath => _mediaLibrary.trackSortAscending,
        kArtistsPath => _mediaLibrary.artistSortAscending,
        kGenresPath => _mediaLibrary.genreSortAscending,
        kFoldersPath => _fileExplorerNotifier.sortAscending,
        _ => false,
      },
      value: true,
      padding: EdgeInsets.zero,
      child: Text(
        Localization.instance.ASCENDING,
        style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
      ),
    ),
    MobileMediaLibrarySortButtonPopupMenuItem(
      onTap: () => _handle(false),
      checked: switch (widget.path) {
        kAlbumsPath => !_mediaLibrary.albumSortAscending,
        kTracksPath => !_mediaLibrary.trackSortAscending,
        kArtistsPath => !_mediaLibrary.artistSortAscending,
        kGenresPath => !_mediaLibrary.genreSortAscending,
        kFoldersPath => !_fileExplorerNotifier.sortAscending,
        _ => false,
      },
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
          useRootNavigator: true,
          isScrollControlled: true,
          elevation: kDefaultHeavyElevation,
          builder: (context) => StatefulBuilder(
            builder: (context, setState) {
              _setStateCallback = setState;
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ..._sort,
                  const PopupMenuDivider(),
                  ..._order,
                  SizedBox(height: MediaQuery.of(context).padding.bottom),
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
              String.fromCharCode(_order.firstWhere((e) => e.checked).value ? Icons.arrow_upward.codePoint : Icons.arrow_downward.codePoint),
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
              label((_sort.firstWhere((e) => e.checked).child as Text).data.toString()),
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

class MobileNowPlayingBarScrollNotifier extends StatelessWidget {
  final Widget child;

  const MobileNowPlayingBarScrollNotifier({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (isDesktop) {
      return child;
    } else {
      return NotificationListener<UserScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.axis == Axis.vertical && (notification.metrics.axisDirection == AxisDirection.up || notification.metrics.axisDirection == AxisDirection.down)) {
            if (notification.direction == ScrollDirection.forward) {
              NowPlayingMobileNotifier.instance.showNowPlayingBar();
            } else if (notification.direction == ScrollDirection.reverse) {
              NowPlayingMobileNotifier.instance.hideNowPlayingBar();
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

class ScaleOnHover extends StatefulWidget {
  final Widget child;

  const ScaleOnHover({super.key, required this.child});

  @override
  ScaleOnHoverState createState() => ScaleOnHoverState();
}

class ScaleOnHoverState extends State<ScaleOnHover> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (e) => setState(() => _scale = 1.05),
      onExit: (e) => setState(() => _scale = 1.00),
      child: AnimatedScale(
        scale: _scale,
        duration: Theme.of(context).extension<AnimationDuration>()?.fast ?? Duration.zero,
        child: widget.child,
      ),
    );
  }
}

// --------------------------------------------------

final class HoverActionsData {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const HoverActionsData({
    required this.label,
    required this.icon,
    required this.onTap,
  });
}

class HoverActions extends StatefulWidget {
  final Widget child;
  final List<HoverActionsData> actions;
  const HoverActions({
    super.key,
    required this.child,
    required this.actions,
  });

  @override
  State<HoverActions> createState() => HoverActionsState();
}

class HoverActionsState extends State<HoverActions> {
  bool _hovered = isMobile;
  int? _hoveredAction;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: isMobile ? null : (e) => setState(() => _hovered = true),
      onExit: isMobile ? null : (e) => setState(() => _hovered = false),
      child: Stack(
        alignment: Alignment.center,
        children: [
          widget.child,
          AnimatedOpacity(
            opacity: _hovered ? 1.0 : 0.0,
            duration: Theme.of(context).extension<AnimationDuration>()?.medium ?? Duration.zero,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 8.0,
              children: widget.actions
                  .mapIndexed(
                    (i, e) => isMaterial2
                        ? FloatingActionButton.small(
                            onPressed: e.onTap,
                            tooltip: e.label,
                            child: Icon(e.icon),
                          )
                        : GestureDetector(
                            onTap: e.onTap,
                            onPanStart: (e) => setState(() => _hoveredAction = i),
                            onPanEnd: (e) => setState(() => _hoveredAction = null),
                            child: MouseRegion(
                              onEnter: (e) => setState(() => _hoveredAction = i),
                              onExit: (e) => setState(() => _hoveredAction = null),
                              child: AnimatedContainer(
                                curve: const ElasticOutCurve(0.85),
                                width: 48.0,
                                height: 48.0,
                                duration: Theme.of(context).extension<AnimationDuration>()?.medium ?? Duration.zero,
                                decoration: ShapeDecoration(
                                  color: Theme.of(context).colorScheme.primaryContainer,
                                  shape: RoundedPolygonBorder(polygon: _hoveredAction == i ? MaterialShapes.sunny : MaterialShapes.circle),
                                ),
                                child: Tooltip(
                                  message: e.label,
                                  child: Center(
                                    child: Icon(
                                      e.icon,
                                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------

class SubHeader extends StatelessWidget {
  final String text;
  final double? height;
  final EdgeInsets? padding;
  final Widget? leading;
  final Widget? trailing;

  const SubHeader(
    this.text, {
    super.key,
    this.height,
    this.padding,
    this.leading,
    this.trailing,
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
      height: height ?? 56.0,
      padding: padding ?? EdgeInsets.symmetric(horizontal: horizontal),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (leading != null) ...[
            IconTheme(
              data: IconTheme.of(context).copyWith(color: style?.color),
              child: leading!,
            ),
            const SizedBox(width: 8.0),
          ],
          Text(text, style: style),
          if (trailing != null) ...[
            const SizedBox(width: 8.0),
            trailing!,
          ],
        ],
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
              heroTag: 'media-library-refresh-button',
              tooltip: Localization.instance.REFRESH,
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
    return FloatingActionButton(
      heroTag: 'media-library-create-playlist-button',
      tooltip: Localization.instance.CREATE_NEW_PLAYLIST,
      onPressed: () => showCreatePlaylistDialog(context),
      child: const Icon(Icons.edit),
    );
  }
}

// --------------------------------------------------

class MobileNavigationBar extends StatelessWidget {
  const MobileNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final path = context.location.split('/').last;
    final paths = [
      kAlbumsPath,
      kTracksPath,
      kArtistsPath,
      kGenresPath,
      kFoldersPath,
      kPlaylistsPath,
    ];
    final index = paths.indexOf(path);
    final displayLabels =
        {
          Localization.instance.ALBUMS,
          Localization.instance.TRACKS,
          Localization.instance.ARTISTS,
          Localization.instance.GENRES,
          Localization.instance.FOLDERS,
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
              NowPlayingMobileNotifier.instance.showNowPlayingBar();
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
                icon: const Icon(Icons.folder),
                label: Localization.instance.FOLDERS,
              ),
              NavigationDestination(
                icon: const Icon(Icons.playlist_play),
                label: Localization.instance.PLAYLISTS,
              ),
            ],
          )
        : Container(
            decoration: const BoxDecoration(
              boxShadow: [
                BoxShadow(color: Colors.black45, blurRadius: 8.0),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: index,
              type: BottomNavigationBarType.shifting,
              onTap: (i) {
                if (index == i) return;
                context.push('/$kMediaLibraryPath/${paths[i]}');
                Configuration.instance.set(mediaLibraryPath: paths[i]);
                NowPlayingMobileNotifier.instance.showNowPlayingBar();
              },
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.album),
                  label: displayLabels ? Localization.instance.ALBUMS : null,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.music_note),
                  label: displayLabels ? Localization.instance.TRACKS : null,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.person),
                  label: displayLabels ? Localization.instance.ARTISTS : null,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.piano),
                  label: displayLabels ? Localization.instance.GENRES : null,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.folder),
                  label: displayLabels ? Localization.instance.FOLDERS : null,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.playlist_play),
                  label: displayLabels ? Localization.instance.PLAYLISTS : null,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
              ],
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
  final double? value;
  final List<double>? values;
  final double? interval;
  final double? stepSize;
  final bool showLabels;
  final void Function(dynamic)? onChanged;
  final VoidCallback? onScrolledUp;
  final VoidCallback? onScrolledDown;
  final LabelFormatterCallback? labelFormatterCallback;

  const ScrollableSlider({
    super.key,
    this.min = 0.0,
    double max = 1.0,
    this.value,
    this.values,
    this.interval,
    this.stepSize,
    this.showLabels = false,
    required this.onChanged,
    this.onScrolledUp,
    this.onScrolledDown,
    this.labelFormatterCallback,
  }) : max = min >= max ? 4294967296.0 /* 2^32 */ : max;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: onChanged == null ? SystemMouseCursors.none : SystemMouseCursors.click,
      child: Listener(
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
        child: () {
          if (value != null) {
            return SfSliderTheme(
              data: SfSliderThemeData(
                activeTrackHeight: 4.0,
                inactiveTrackHeight: 2.0,
                thumbRadius: 6.0,
                overlayRadius: 12.0,
                // Map colors from Slider (package:flutter) to SfSlider (package:syncfusion_flutter_sliders).
                thumbColor: SliderTheme.of(context).thumbColor,
                overlayColor: SliderTheme.of(context).overlayColor,
                activeTrackColor: SliderTheme.of(context).activeTrackColor,
                inactiveTrackColor: SliderTheme.of(context).inactiveTrackColor,
                disabledActiveTrackColor: SliderTheme.of(context).disabledActiveTrackColor,
              ),
              child: SfSlider(
                min: min,
                max: max,
                value: value,
                interval: interval,
                stepSize: stepSize,
                showLabels: showLabels,
                labelFormatterCallback: labelFormatterCallback,
                edgeLabelPlacement: EdgeLabelPlacement.inside,
                onChanged: onChanged == null ? null : (result) => onChanged?.call(result),
              ),
            );
          }
          if (values != null) {
            return SfRangeSliderTheme(
              data: SfRangeSliderThemeData(
                activeTrackHeight: 4.0,
                inactiveTrackHeight: 2.0,
                thumbRadius: 6.0,
                overlayRadius: 12.0,
                // Map colors from Slider (package:flutter) to SfSlider (package:syncfusion_flutter_sliders).
                thumbColor: SliderTheme.of(context).thumbColor,
                overlayColor: SliderTheme.of(context).overlayColor,
                activeTrackColor: SliderTheme.of(context).activeTrackColor,
                inactiveTrackColor: SliderTheme.of(context).inactiveTrackColor,
                disabledActiveTrackColor: SliderTheme.of(context).disabledActiveTrackColor,
              ),
              child: SfRangeSlider(
                min: min,
                max: max,
                values: SfRangeValues(values![0], values![1]),
                interval: interval,
                stepSize: stepSize,
                showLabels: showLabels,
                labelFormatterCallback: labelFormatterCallback,
                edgeLabelPlacement: EdgeLabelPlacement.inside,
                onChanged: onChanged == null ? null : (result) => onChanged?.call([result.start, result.end]),
              ),
            );
          }
          return const SizedBox.shrink();
        }(),
      ),
    );
  }
}

// --------------------------------------------------

class DefaultTextFormField extends StatelessWidget {
  final Object groupId;
  final TextEditingController? controller;
  final String? initialValue;
  final FocusNode? focusNode;
  final String? forceErrorText;
  final InputDecoration? decoration;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextDirection? textDirection;
  final TextAlign textAlign;
  final TextAlignVertical? textAlignVertical;
  final bool autofocus;
  final bool readOnly;
  final bool? showCursor;
  final String obscuringCharacter;
  final bool obscureText;
  final bool autocorrect;
  final SmartDashesType? smartDashesType;
  final SmartQuotesType? smartQuotesType;
  final bool enableSuggestions;
  final MaxLengthEnforcement? maxLengthEnforcement;
  final int? maxLines;
  final int? minLines;
  final bool expands;
  final int? maxLength;
  final void Function(String)? onChanged;
  final GestureTapCallback? onTap;
  final bool onTapAlwaysCalled;
  final TapRegionCallback? onTapOutside;
  final TapRegionUpCallback? onTapUpOutside;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onFieldSubmitted;
  final void Function(String?)? onSaved;
  final String? Function(String?)? validator;
  final FormFieldErrorBuilder? errorBuilder;
  final List<TextInputFormatter>? inputFormatters;
  final bool? enabled;
  final bool? ignorePointers;
  final double cursorWidth;
  final double? cursorHeight;
  final Radius? cursorRadius;
  final Color? cursorColor;
  final Color? cursorErrorColor;
  final Brightness? keyboardAppearance;
  final EdgeInsets scrollPadding;
  final bool? enableInteractiveSelection;
  final TextSelectionControls? selectionControls;
  final InputCounterWidgetBuilder? buildCounter;
  final ScrollPhysics? scrollPhysics;
  final Iterable<String>? autofillHints;
  final AutovalidateMode? autovalidateMode;
  final ScrollController? scrollController;
  final String? restorationId;
  final bool enableIMEPersonalizedLearning;
  final MouseCursor? mouseCursor;
  final EditableTextContextMenuBuilder? contextMenuBuilder;
  final SpellCheckConfiguration? spellCheckConfiguration;
  final TextMagnifierConfiguration? magnifierConfiguration;
  final UndoHistoryController? undoController;
  final AppPrivateCommandCallback? onAppPrivateCommand;
  final bool? cursorOpacityAnimates;
  final BoxHeightStyle selectionHeightStyle;
  final BoxWidthStyle selectionWidthStyle;
  final DragStartBehavior dragStartBehavior;
  final ContentInsertionConfiguration? contentInsertionConfiguration;
  final Clip clipBehavior;
  final bool stylusHandwritingEnabled;
  final bool canRequestFocus;

  const DefaultTextFormField({
    super.key,
    this.groupId = EditableText,
    this.controller,
    this.initialValue,
    this.focusNode,
    this.forceErrorText,
    this.decoration = const InputDecoration(),
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.style,
    this.strutStyle,
    this.textDirection,
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
    this.autofocus = false,
    this.readOnly = false,
    this.showCursor,
    this.obscuringCharacter = '•',
    this.obscureText = false,
    this.autocorrect = true,
    this.smartDashesType,
    this.smartQuotesType,
    this.enableSuggestions = true,
    this.maxLengthEnforcement,
    this.maxLines = 1,
    this.minLines,
    this.expands = false,
    this.maxLength,
    this.onChanged,
    this.onTap,
    this.onTapAlwaysCalled = false,
    this.onTapOutside,
    this.onTapUpOutside,
    this.onEditingComplete,
    this.onFieldSubmitted,
    this.onSaved,
    this.validator,
    this.errorBuilder,
    this.inputFormatters,
    this.enabled,
    this.ignorePointers,
    this.cursorWidth = 2.0,
    this.cursorHeight,
    this.cursorRadius,
    this.cursorColor,
    this.cursorErrorColor,
    this.keyboardAppearance,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.enableInteractiveSelection,
    this.selectionControls,
    this.buildCounter,
    this.scrollPhysics,
    this.autofillHints,
    this.autovalidateMode,
    this.scrollController,
    this.restorationId,
    this.enableIMEPersonalizedLearning = true,
    this.mouseCursor,
    this.contextMenuBuilder,
    this.spellCheckConfiguration,
    this.magnifierConfiguration,
    this.undoController,
    this.onAppPrivateCommand,
    this.cursorOpacityAnimates,
    this.selectionHeightStyle = BoxHeightStyle.tight,
    this.selectionWidthStyle = BoxWidthStyle.tight,
    this.dragStartBehavior = DragStartBehavior.start,
    this.contentInsertionConfiguration,
    this.clipBehavior = Clip.hardEdge,
    this.stylusHandwritingEnabled = EditableText.defaultStylusHandwritingEnabled,
    this.canRequestFocus = true,
  });

  @override
  Widget build(BuildContext context) {
    return KeyboardShortcutsInterceptor(
      child: TextFormField(
        groupId: groupId,
        controller: controller,
        initialValue: initialValue,
        focusNode: focusNode,
        forceErrorText: forceErrorText,
        decoration: decoration,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        textInputAction: textInputAction,
        style: style,
        strutStyle: strutStyle,
        textDirection: textDirection,
        textAlign: textAlign,
        textAlignVertical: textAlignVertical,
        autofocus: autofocus,
        readOnly: readOnly,
        showCursor: showCursor,
        obscuringCharacter: obscuringCharacter,
        obscureText: obscureText,
        autocorrect: autocorrect,
        smartDashesType: smartDashesType,
        smartQuotesType: smartQuotesType,
        enableSuggestions: enableSuggestions,
        maxLengthEnforcement: maxLengthEnforcement,
        maxLines: maxLines,
        minLines: minLines,
        expands: expands,
        maxLength: maxLength,
        onChanged: onChanged,
        onTap: onTap,
        onTapAlwaysCalled: onTapAlwaysCalled,
        onTapOutside: onTapOutside,
        onTapUpOutside: onTapUpOutside,
        onEditingComplete: onEditingComplete,
        onFieldSubmitted: onFieldSubmitted,
        onSaved: onSaved,
        validator: validator,
        errorBuilder: errorBuilder,
        inputFormatters: inputFormatters,
        enabled: enabled,
        ignorePointers: ignorePointers,
        cursorWidth: cursorWidth,
        cursorHeight: cursorHeight,
        cursorRadius: cursorRadius,
        cursorColor: cursorColor,
        cursorErrorColor: cursorErrorColor,
        keyboardAppearance: keyboardAppearance,
        scrollPadding: scrollPadding,
        enableInteractiveSelection: enableInteractiveSelection,
        selectionControls: selectionControls,
        buildCounter: buildCounter,
        scrollPhysics: scrollPhysics,
        autofillHints: autofillHints,
        autovalidateMode: autovalidateMode,
        scrollController: scrollController,
        restorationId: restorationId,
        enableIMEPersonalizedLearning: enableIMEPersonalizedLearning,
        mouseCursor: mouseCursor,
        contextMenuBuilder: contextMenuBuilder,
        spellCheckConfiguration: spellCheckConfiguration,
        magnifierConfiguration: magnifierConfiguration,
        undoController: undoController,
        onAppPrivateCommand: onAppPrivateCommand,
        cursorOpacityAnimates: cursorOpacityAnimates,
        selectionHeightStyle: selectionHeightStyle,
        selectionWidthStyle: selectionWidthStyle,
        dragStartBehavior: dragStartBehavior,
        contentInsertionConfiguration: contentInsertionConfiguration,
        clipBehavior: clipBehavior,
        stylusHandwritingEnabled: stylusHandwritingEnabled,
        canRequestFocus: canRequestFocus,
      ),
    );
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

class EditTagsButton extends StatelessWidget {
  const EditTagsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: Localization.instance.EDIT_TAGS,
      icon: const Icon(Icons.label),
      iconSize: 20.0,
      splashRadius: 18.0,
      color: Theme.of(context).appBarTheme.actionsIconTheme?.color,
      onPressed: () async {
        context.read<SubscriptionNotifier>().accessSubscriptionFeature(context, () async {
          final result = await pickFile(extensions: kDefaultSupportedFileTypes);
          if (result != null) {
            await context.push(Uri(path: '/$kTagEditorPath', queryParameters: {kTagEditorArgResource: result.path}).toString());
          }
        });
      },
    );
  }
}

// --------------------------------------------------

class MobileGridSpanButton extends StatelessWidget {
  const MobileGridSpanButton({super.key});

  @override
  Widget build(BuildContext context) {
    final path = context.location.split('/').last;
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
            groupValue = Configuration.instance.mobileMediaLibraryAlbumGridSpan;
            onChanged = (value) => Configuration.instance.set(mobileMediaLibraryAlbumGridSpan: value);
            break;
          case kArtistsPath:
            title = Localization.instance.MOBILE_ARTIST_GRID_SIZE;
            groupValue = Configuration.instance.mobileMediaLibraryArtistGridSpan;
            onChanged = (value) => Configuration.instance.set(mobileMediaLibraryArtistGridSpan: value);
            break;
          case kGenresPath:
            title = Localization.instance.MOBILE_GENRE_GRID_SIZE;
            groupValue = Configuration.instance.mobileMediaLibraryGenreGridSpan;
            onChanged = (value) => Configuration.instance.set(mobileMediaLibraryGenreGridSpan: value);
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
                    final mediaLibrary = context.read<MediaLibrary>();
                    onChanged(value).then((_) => Navigator.of(context).pop()).then((_) => mediaLibrary.notify());
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
        final mediaLibrary = context.read<MediaLibrary>();
        Completer<int> completer = Completer<int>();
        await showModalBottomSheet(
          context: context,
          showDragHandle: isMaterial3OrGreater,
          useRootNavigator: true,
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
                leading: const Icon(Icons.label),
                title: Text(
                  Localization.instance.EDIT_TAGS,
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
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        );
        completer.future.then((value) async {
          await Future.delayed(const Duration(milliseconds: 300));
          switch (value) {
            case 0:
              {
                await MediaPlayer.instance.open(mediaLibrary.tracks.map((e) => e.toPlayable()));
                break;
              }
            case 1:
              {
                MediaPlayer.instance.open(mediaLibrary.tracks.map((e) => e.toPlayable()), shuffle: true);
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
                context.read<SubscriptionNotifier>().accessSubscriptionFeature(context, () async {
                  final result = await pickFile(extensions: kDefaultSupportedFileTypes);
                  if (result != null) {
                    await context.push(Uri(path: '/$kTagEditorPath', queryParameters: {kTagEditorArgResource: result.path}).toString());
                  }
                });
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
  final Color? color;
  final Curve curve;
  final Duration duration;

  const StatefulAnimatedIcon({
    super.key,
    required this.dismissed,
    required this.icon,
    this.size = 24.0,
    this.color,
    this.curve = Curves.easeInOut,
    this.duration = const Duration(milliseconds: 200),
  });

  @override
  State<StatefulAnimatedIcon> createState() => StatefulAnimatedIconState();
}

class StatefulAnimatedIconState extends State<StatefulAnimatedIcon> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
    reverseDuration: widget.duration,
  );
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: widget.curve,
    reverseCurve: widget.curve,
  );

  @override
  void initState() {
    super.initState();
    if (widget.dismissed) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(StatefulAnimatedIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dismissed != widget.dismissed) {
      if (widget.dismissed) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedIcon(
      progress: _animation,
      icon: widget.icon,
      size: widget.size,
      color: widget.color,
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
  // https://github.com/flutter/flutter/issues/31191
  late final PageController _controller = PageController(
    initialPage: widget.index,
    viewportFraction: 0.9999999999,
  );

  @override
  void didUpdateWidget(covariant StatefulPageViewBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      final duration = Theme.of(context).extension<AnimationDuration>()?.medium ?? Duration.zero;
      if ((oldWidget.index - widget.index).abs() > 5 || duration == Duration.zero) {
        _controller.jumpToPage(widget.index);
      } else {
        _controller.animateToPage(
          widget.index,
          duration: duration,
          curve: Curves.easeInOut,
        );
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _controller,
      physics: widget.physics,
      itemCount: widget.itemCount,
      itemBuilder: (context, index) => widget.itemBuilder(context, index),
    );
  }
}

// --------------------------------------------------

class StatefulCarouselViewBuilder extends StatefulWidget {
  final int index;
  final Widget Function(BuildContext, int) itemBuilder;
  final int itemCount;
  final EdgeInsets padding;
  final List<int> flexWeights;
  final void Function(int)? onTap;

  const StatefulCarouselViewBuilder({
    super.key,
    required this.index,
    required this.itemBuilder,
    required this.itemCount,
    this.padding = const EdgeInsets.symmetric(horizontal: 4.0),
    required this.flexWeights,
    this.onTap,
  });

  @override
  State<StatefulCarouselViewBuilder> createState() => StatefulCarouselViewBuilderState();
}

class StatefulCarouselViewBuilderState extends State<StatefulCarouselViewBuilder> {
  late final CarouselController _controller = CarouselController(initialItem: widget.index);

  @override
  void didUpdateWidget(covariant StatefulCarouselViewBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      final duration = Theme.of(context).extension<AnimationDuration>()?.medium ?? Duration.zero;
      if ((oldWidget.index - widget.index).abs() > 5 || duration == Duration.zero) {
        _controller.jumpToItem(widget.index);
      } else {
        _controller.animateToItem(
          widget.index,
          duration: duration,
          curve: Curves.easeInOut,
        );
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CarouselView.weighted(
      padding: widget.padding,
      itemSnapping: true,
      controller: _controller,
      itemCount: widget.itemCount,
      itemBuilder: widget.itemBuilder,
      flexWeights: widget.flexWeights,
      onTap: widget.onTap,
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
  void dispose() {
    controller.dispose();
    super.dispose();
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
}

// --------------------------------------------------

class HoverOverlay extends StatefulWidget {
  final Size overlaySize;
  final WidgetBuilder overlayBuilder;
  final EdgeInsets overlayPadding;
  final Widget child;

  const HoverOverlay({
    super.key,
    required this.overlaySize,
    this.overlayPadding = const EdgeInsets.all(16.0),
    required this.overlayBuilder,
    required this.child,
  });

  @override
  State<HoverOverlay> createState() => HoverOverlayState();
}

class HoverOverlayState extends State<HoverOverlay> {
  OverlayEntry? _overlayEntry;
  Offset? _mousePosition;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _updateOverlayPosition(PointerEvent event) {
    _mousePosition = event.position;
    _overlayEntry?.markNeedsBuild();
  }

  void _showOverlay(BuildContext context) {
    _overlayEntry = OverlayEntry(
      builder: (context) {
        final screenSize = MediaQuery.sizeOf(context);
        final position = _mousePosition ?? Offset.zero;

        double screenWidth = screenSize.width;
        double screenHeight = screenSize.height;

        double left = position.dx;
        double top = position.dy;

        screenHeight -= kDesktopAppBarHeight + WindowPlus.instance.captionHeight + NowPlayingBar.height;
        top -= kDesktopAppBarHeight + WindowPlus.instance.captionHeight;

        if (left + widget.overlaySize.width + widget.overlayPadding.right > screenWidth) {
          left = left - widget.overlaySize.width;
        }
        if (screenWidth - (left + widget.overlaySize.width) < widget.overlayPadding.right) {
          left = screenWidth - widget.overlaySize.width - widget.overlayPadding.right;
        }

        if (top + widget.overlaySize.height + widget.overlayPadding.bottom > screenHeight) {
          top = top - widget.overlaySize.height;
        }
        if (screenHeight - (top + widget.overlaySize.height) < widget.overlayPadding.bottom) {
          top = screenHeight - widget.overlaySize.height - widget.overlayPadding.bottom;
        }

        left = left.clamp(widget.overlayPadding.left, screenWidth - widget.overlaySize.width);
        top = top.clamp(widget.overlayPadding.top, screenHeight - widget.overlaySize.height);

        return Positioned(
          left: left,
          top: top,
          width: widget.overlaySize.width,
          height: widget.overlaySize.height,
          child: widget.overlayBuilder(context),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) {
        _mousePosition = event.position;
        _showOverlay(context);
      },
      onExit: (_) {
        _removeOverlay();
      },
      onHover: (event) {
        _updateOverlayPosition(event);
      },
      child: widget.child,
    );
  }
}
