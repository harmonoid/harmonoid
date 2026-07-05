import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/material.dart';
import 'package:media_library/media_library.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/extensions/build_context.dart';
import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/features/media_library/folders/state/file_explorer_notifier.dart';
import 'package:harmonoid/routing/utils/constants.dart';
import 'package:harmonoid/utils/rendering.dart';

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
