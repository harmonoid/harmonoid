import 'dart:io';
import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/material.dart';
import 'package:media_library/media_library.dart' hide FileSystemMediaLibrary;
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:safe_local_storage/file_system.dart';

import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/core/filesystem_media_library.dart';
import 'package:harmonoid/core/media_player/media_player.dart';
import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/mappers/file.dart';
import 'package:harmonoid/mappers/track.dart';
import 'package:harmonoid/ui/media_library/folders/folders_no_items_banner.dart';
import 'package:harmonoid/ui/media_library/folders/state/file_explorer_notifier.dart';
import 'package:harmonoid/ui/media_library/media_library_flags.dart';
import 'package:harmonoid/utils/constants.dart';
import 'package:harmonoid/utils/debouncer.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/widgets.dart';

class FoldersScreen extends StatefulWidget {
  const FoldersScreen({super.key});

  @override
  State<FoldersScreen> createState() => _FoldersScreenState();
}

class _FoldersScreenState extends State<FoldersScreen> {
  final Debouncer _desktopColumnWidthsDebouncer = Debouncer();
  List<double> _desktopColumnWidths = Configuration.instance.desktopMediaLibraryFoldersScreenColumnWidths;

  @override
  void dispose() {
    super.dispose();
    _desktopColumnWidthsDebouncer.dispose();
  }

  Track? _getTrack(MediaLibrary mediaLibrary, FileSystemEntity entity) {
    if (entity is File && FileSystemMediaLibrary.instance.supportedFileTypes.contains(entity.extension)) {
      return mediaLibrary.lookupTrack(TrackLookupKey(uri: path.normalize(entity.path)));
    }
    return null;
  }

  Widget _buildHeader(BuildContext context) {
    if (isDesktop) {
      return Container(
        height: kDesktopHeaderHeight,
        margin: mediaLibraryScrollViewBuilderPadding,
        child: const DesktopMediaLibraryHeader(key: ValueKey('')),
      );
    }
    if (isMobile) {
      return Container(
        height: kMobileHeaderHeight,
        margin: mediaLibraryScrollViewBuilderPadding.copyWith(bottom: 0.0),
        child: const MobileMediaLibraryHeader(key: ValueKey('')),
      );
    }
    throw UnimplementedError();
  }

  Widget _buildEmpty(BuildContext context) {
    return const FoldersNoItemsBanner();
  }

  @override
  Widget build(BuildContext context) {
    final columns = [
      Localization.instance.TITLE,
      Localization.instance.ARTISTS,
      Localization.instance.ALBUM,
      Localization.instance.GENRES,
      Localization.instance.YEAR,
    ];

    final width = MediaQuery.sizeOf(context).width - 2 * ListItemTableState.kDesktopRowHeight;
    if (_desktopColumnWidths.length != columns.length) {
      _desktopColumnWidths = [width * 5 / 17, width * 4 / 17, width * 3 / 17, width * 3 / 17, width * 2 / 17];
    }

    return Consumer2<MediaLibrary, FileExplorerNotifier>(
      builder: (context, mediaLibrary, fileExplorerNotifier, _) => FileExplorer(
        viewType: fileExplorerNotifier.viewType,
        sortType: fileExplorerNotifier.sortType,
        sortAscending: fileExplorerNotifier.sortAscending,
        showHiddenFiles: fileExplorerNotifier.showHiddenFiles,
        initialLabel: '.',
        initialChildren: FileSystemMediaLibrary.instance.directories.toList(),
        columns: columns,
        headerBuilder: _buildHeader,
        emptyBuilder: _buildEmpty,
        itemBuilder: (context, entity) {
          final track = _getTrack(mediaLibrary, entity);
          if (track == null) return null;
          return ListItemData(
            key: ValueKey(entity.path),
            children:
                [track.toTitleTappableText()] +
                switch ((isDesktop, fileExplorerNotifier.viewType)) {
                  (true, FileExplorerViewType.list) => [track.toArtistsTappableText(context), track.toAlbumTappableText(context), track.toGenresTappableText(context), track.toYearTappableText()],
                  (false, FileExplorerViewType.list) => [track.toSubtitleTappableText()],
                  (_, FileExplorerViewType.grid) => [track.toFileExplorerGridSubtitle0TappableText(context), track.toFileExplorerGridSubtitle1TappableText(context)],
                },
          );
        },
        leadingBuilder: (context, entity) {
          final track = _getTrack(mediaLibrary, entity);
          if (track == null) return null;
          return Image(
            width: double.infinity,
            height: double.infinity,
            image: cover(
              uri: path.normalize(entity.path),
              cacheHeight: 96 * 2,
            ),
            fit: BoxFit.cover,
          );
        },
        onItemPressed: (context, files, index) {
          if (Configuration.instance.mediaLibraryAddPlaylistToNowPlaying) {
            final playables = files.map((e) => e.toPlayable(mediaLibrary));
            MediaPlayer.instance.open(playables, index: index);
          } else {
            MediaPlayer.instance.open([files[index].toPlayable(mediaLibrary)]);
          }
        },
        showItemSelection: true,
        isItemSelectionEnabled: (file) => _getTrack(mediaLibrary, file) != null,
        isItemSelected: (file) => mediaLibrarySelectedTracks.value.contains(_getTrack(mediaLibrary, file)),
        onItemSelected: (context, file, value) {
          final track = _getTrack(mediaLibrary, file);
          if (track == null) return;
          if (value) {
            mediaLibrarySelectedTracks.value = {...mediaLibrarySelectedTracks.value, track};
          } else {
            mediaLibrarySelectedTracks.value = mediaLibrarySelectedTracks.value.difference({track});
          }
        },
        itemSelectionChangeNotifier: mediaLibrarySelectedTracks,
        onViewTypeChanged: fileExplorerNotifier.setViewType,
        onShowHiddenFilesChanged: fileExplorerNotifier.setShowHiddenFiles,
        sortKey: mediaLibrary.current ?? 0,
        sortCallback: (entity) {
          final track = _getTrack(mediaLibrary, entity);
          if (track == null) return null;
          return switch (fileExplorerNotifier.sortType) {
            FileExplorerSortType.name => track.title,
            FileExplorerSortType.timestamp => track.timestamp,
          };
        },
        filterCallback: (entity) {
          if (entity is Directory) return true;
          return _getTrack(mediaLibrary, entity) != null;
        },
        desktopColumnWidths: _desktopColumnWidths,
        desktopOnColumnResize: (widths) {
          _desktopColumnWidthsDebouncer.run(() {
            Configuration.instance.set(desktopMediaLibraryFoldersScreenColumnWidths: widths);
          });
        },
        mobileHeaderHeight: mediaLibraryScrollViewBuilderPadding.top + kMobileHeaderHeight,
      ),
    );
  }
}
