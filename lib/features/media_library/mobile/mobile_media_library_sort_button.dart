import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/material.dart';
import 'package:media_library/media_library.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/features/media_library/folders/state/file_explorer_notifier.dart';
import 'package:harmonoid/features/media_library/mobile/mobile_media_library_sort_button_popup_menu_item.dart';
import 'package:harmonoid/routing/utils/constants.dart';
import 'package:harmonoid/utils/rendering.dart';

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
