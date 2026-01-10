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
import 'package:harmonoid/ui/media_library/media_library_menus.dart';
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
  final ValueNotifier<OrderResult> _entitiesNotifier = ValueNotifier(const OrderResult());
  final Debouncer _desktopColumnWidthsDebouncer = Debouncer();
  List<double> _desktopColumnWidths = Configuration.instance.desktopMediaLibraryFoldersScreenColumnWidths;

  @override
  void dispose() {
    super.dispose();
    _entitiesNotifier.dispose();
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
      return const SizedBox(
        height: kDesktopHeaderHeight,
        child: DesktopMediaLibraryHeader(key: ValueKey('')),
      );
    }
    if (isMobile) {
      return SizedBox(
        height: kMobileHeaderHeight,
        child: MobileMediaLibraryHeader(
          key: const ValueKey(''),
          leading: ValueListenableBuilder(
            valueListenable: _entitiesNotifier,
            builder: (context, data, _) => Text(switch ((data.directories.length, data.files.length)) {
              (0, 0) => '',
              (0, 1) => Localization.instance.ONE_FILE,
              (1, 0) => Localization.instance.ONE_FOLDER,
              (1, 1) => Localization.instance.ONE_FOLDER_AND_ONE_FILE,
              (_, 0) => Localization.instance.N_FOLDERS.replaceAll('"N"', data.directories.length.toString()),
              (0, _) => Localization.instance.N_FILES.replaceAll('"N"', data.files.length.toString()),
              (1, _) => Localization.instance.ONE_FOLDER_AND_N_FILES.replaceAll('"N"', data.files.length.toString()),
              (_, 1) => Localization.instance.N_FOLDERS_AND_ONE_FILE.replaceAll('"N"', data.directories.length.toString()),
              (_, _) => Localization.instance.M_FOLDERS_AND_N_FILES.replaceAll('"M"', data.directories.length.toString()).replaceAll('"N"', data.files.length.toString()),
            }),
          ),
        ),
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
        initialDirectories: FileSystemMediaLibrary.instance.directories.toList(),
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
        popupMenuBuilder: (context, file) {
          final track = _getTrack(mediaLibrary, file);
          if (track == null) return [];
          return TrackMenuProvider(context, track).getPopupMenuItems();
        },
        onItemPressed: (context, files, index) {
          if (Configuration.instance.mediaLibraryAddPlaylistToNowPlaying) {
            final playables = files.map((e) => e.toPlayable(mediaLibrary));
            MediaPlayer.instance.open(playables, index: index);
          } else {
            MediaPlayer.instance.open([files.elementAt(index).toPlayable(mediaLibrary)]);
          }
        },
        onPopupMenuItemSelected: (context, file, result) async {
          final track = _getTrack(mediaLibrary, file);
          if (track == null) return;
          await TrackMenuProvider(context, track).handlePopupMenuAction(result);
        },
        showItemSelection: isDesktop || mediaLibrarySelectedTracks.value.isNotEmpty,
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
        onLoaded: (data) {
          _entitiesNotifier.value = data;
        },
        onViewTypeChanged: fileExplorerNotifier.setViewType,
        onShowHiddenFilesChanged: fileExplorerNotifier.setShowHiddenFiles,
        sortKey: mediaLibrary.tracks.length,
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
        padding: mediaLibraryScrollViewBuilderPadding,
        headerHeight: isDesktop ? kDesktopHeaderHeight : kMobileHeaderHeight,
        desktopColumnWidths: _desktopColumnWidths,
        desktopOnColumnResize: (widths) {
          _desktopColumnWidthsDebouncer.run(() {
            Configuration.instance.set(desktopMediaLibraryFoldersScreenColumnWidths: widths);
          });
        },
      ),
    );
  }
}
