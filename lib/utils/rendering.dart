/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'dart:io';
import 'dart:async';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:media_library/media_library.dart';
import 'package:extended_image/extended_image.dart';
import 'package:filepicker_windows/filepicker_windows.dart';
import 'package:safe_local_storage/safe_local_storage.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:external_media_provider/external_media_provider.dart';

import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/interface/home.dart';
import 'package:harmonoid/interface/collection/album.dart';
import 'package:harmonoid/interface/file_info_screen.dart';
import 'package:harmonoid/interface/collection/playlist.dart';
import 'package:harmonoid/interface/edit_details_screen.dart';
import 'package:harmonoid/interface/directory_picker_screen.dart';
import 'package:harmonoid/state/lyrics.dart';
import 'package:harmonoid/state/mobile_now_playing_controller.dart';
import 'package:harmonoid/utils/theme.dart';
import 'package:harmonoid/utils/widgets.dart';
export 'package:harmonoid/utils/extensions.dart';
import 'package:harmonoid/utils/constants.dart';
import 'package:harmonoid/utils/palette_generator.dart';
import 'package:harmonoid/utils/storage_retriever.dart';
import 'package:harmonoid/constants/language.dart';

// TODO(@alexmercerind): Clean-up global variables.

final isDesktop = Platform.isWindows || Platform.isLinux || Platform.isMacOS;
final isMobile = Platform.isAndroid || Platform.isIOS;

// Remaining source code in this file consists of helper & utility methods used for rendering & handling some repeated tasks linked at multiple places.

double tileMargin(BuildContext context) =>
    isDesktop ? k16tileMargin : k8tileMargin;

bool isMaterial3(BuildContext context) =>
    Theme.of(context).extension<MaterialStandard>()?.value == 3;

bool isMaterial2(BuildContext context) =>
    Theme.of(context).extension<MaterialStandard>()?.value == 2;

String label(BuildContext context, String value) =>
    // All button labels are uppercase in Material Design 2.
    isMaterial2(context) ? value.toUpperCase() : value;

double navigationBarHeight(BuildContext context) => isMaterial3(context)
    // Based on Material Design 3 specification.
    ? 80.0
    : kBottomNavigationBarHeight;

List<Widget> tileGridListWidgets({
  required double tileHeight,
  required double tileWidth,
  required String? subHeader,
  required BuildContext context,
  required int widgetCount,
  required Widget Function(BuildContext context, int index) builder,
  required String? leadingSubHeader,
  required Widget? leadingWidget,
  required int elementsPerRow,
  MainAxisAlignment mainAxisAlignment = MainAxisAlignment.center,
  bool showIncompleteRow = true,
  double? margin,
}) {
  List<Widget> widgets = <Widget>[];
  widgets.addAll([
    if (leadingSubHeader != null) SubHeader(leadingSubHeader),
    if (leadingWidget != null) leadingWidget,
    if (subHeader != null) SubHeader(subHeader),
  ]);
  int rowIndex = 0;
  List<Widget> rowChildren = <Widget>[];
  margin ??= tileMargin(context);
  for (int index = 0; index < widgetCount; index++) {
    rowChildren.add(
      Container(
        child: builder(context, index),
        margin: EdgeInsets.symmetric(
          horizontal: margin / 2.0,
        ),
      ),
    );
    rowIndex++;
    if (rowIndex > elementsPerRow - 1) {
      widgets.add(
        Container(
          height: tileHeight + margin,
          margin: EdgeInsets.only(left: margin / 2.0, right: margin / 2.0),
          alignment: Alignment.topCenter,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: mainAxisAlignment,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: rowChildren,
          ),
        ),
      );
      rowIndex = 0;
      rowChildren = <Widget>[];
    }
  }
  if (elementsPerRow != 0) {
    if (widgetCount % elementsPerRow != 0 && showIncompleteRow) {
      rowChildren = <Widget>[];
      for (int index = widgetCount - (widgetCount % elementsPerRow);
          index < widgetCount;
          index++) {
        rowChildren.add(
          Container(
            child: builder(context, index),
            margin: EdgeInsets.symmetric(
              horizontal: margin / 2.0,
            ),
          ),
        );
      }
      for (int index = 0;
          index < elementsPerRow - (widgetCount % elementsPerRow);
          index++) {
        rowChildren.add(
          Container(
            height: tileHeight + margin,
            width: tileWidth,
            margin: EdgeInsets.only(left: margin / 2.0, right: margin / 2.0),
          ),
        );
      }
      widgets.add(
        Container(
          height: tileHeight + margin,
          margin: EdgeInsets.only(left: margin / 2.0, right: margin / 2.0),
          alignment: Alignment.topCenter,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: mainAxisAlignment,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: rowChildren,
          ),
        ),
      );
    }
  }
  return widgets;
}

class TileGridListWidgetsData {
  /// Actual List of [Widget]s to render inside a [ListView].
  final List<Widget> widgets;

  /// Structurized data returned by the passed builder's [ValueKey].
  final List<List<dynamic>> data;

  const TileGridListWidgetsData(this.widgets, this.data);
}

TileGridListWidgetsData tileGridListWidgetsWithScrollbarSupport({
  required double tileHeight,
  required double tileWidth,
  required BuildContext context,
  required int widgetCount,
  required Widget Function(BuildContext context, int index) builder,
  required int elementsPerRow,
  double? margin,
}) {
  if (elementsPerRow == 1) {
    final children = List.generate(
      widgetCount,
      (i) => builder(
        context,
        i,
      ),
    );
    return TileGridListWidgetsData(
      children,
      children.map((e) => [(e.key as ValueKey).value]).toList(),
    );
  }
  final widgets = <Widget>[];
  final data = <List<dynamic>>[];
  var rowIndex = 0;
  var rowChildren = <Widget>[];
  var rowData = <dynamic>[];
  margin ??= tileMargin(context);
  for (int index = 0; index < widgetCount; index++) {
    final widget = builder(context, index);
    rowChildren.add(
      Container(
        child: widget,
        margin: EdgeInsets.symmetric(
          horizontal: margin / 2.0,
        ),
      ),
    );
    rowData.add((widget.key as ValueKey).value);
    rowIndex++;
    if (rowIndex > elementsPerRow - 1) {
      widgets.add(
        Container(
          height: tileHeight + margin,
          margin: EdgeInsets.only(left: margin / 2.0, right: margin / 2.0),
          alignment: Alignment.topCenter,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: rowChildren,
          ),
        ),
      );
      data.add(rowData);
      rowIndex = 0;
      rowChildren = <Widget>[];
      rowData = <dynamic>[];
    }
  }
  if (elementsPerRow != 0) {
    if (widgetCount % elementsPerRow != 0) {
      rowChildren = <Widget>[];
      for (int index = widgetCount - (widgetCount % elementsPerRow);
          index < widgetCount;
          index++) {
        final widget = builder(context, index);
        rowChildren.add(
          Container(
            child: widget,
            margin: EdgeInsets.symmetric(
              horizontal: margin / 2.0,
            ),
          ),
        );
        rowData.add((widget.key as ValueKey).value);
      }
      for (int index = 0;
          index < elementsPerRow - (widgetCount % elementsPerRow);
          index++) {
        rowChildren.add(
          Container(
            height: tileHeight + margin,
            width: tileWidth,
            margin: EdgeInsets.only(left: margin / 2.0, right: margin / 2.0),
          ),
        );
      }
      widgets.add(
        Container(
          height: tileHeight + margin,
          margin: EdgeInsets.only(left: margin / 2.0, right: margin / 2.0),
          alignment: Alignment.topCenter,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: rowChildren,
          ),
        ),
      );
      data.add(rowData);
    }
  }
  return TileGridListWidgetsData(
    widgets,
    data,
  );
}

List<PopupMenuItem<int>> trackPopupMenuItems(
  Track track,
  BuildContext context,
) {
  return [
    PopupMenuItem<int>(
      padding: EdgeInsets.zero,
      value: 0,
      child: ListTile(
        leading: Icon(
            Platform.isWindows ? FluentIcons.delete_16_regular : Icons.delete),
        title: Text(
          Language.instance.DELETE,
          style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
        ),
      ),
    ),
    if (Platform.isAndroid || Platform.isIOS)
      PopupMenuItem<int>(
        padding: EdgeInsets.zero,
        value: 1,
        child: ListTile(
          leading: Icon(
              Platform.isWindows ? FluentIcons.share_16_regular : Icons.share),
          title: Text(
            Language.instance.SHARE,
            style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
          ),
        ),
      ),
    PopupMenuItem<int>(
      padding: EdgeInsets.zero,
      value: 3,
      child: ListTile(
        leading: Icon(Platform.isWindows
            ? FluentIcons.music_note_2_16_regular
            : Icons.music_note),
        title: Text(
          Language.instance.ADD_TO_NOW_PLAYING,
          style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
        ),
      ),
    ),
    PopupMenuItem<int>(
      padding: EdgeInsets.zero,
      value: 2,
      child: ListTile(
        leading: Icon(Platform.isWindows
            ? FluentIcons.list_16_regular
            : Icons.queue_music),
        title: Text(
          Language.instance.ADD_TO_PLAYLIST,
          style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
        ),
      ),
    ),
    // TODO: Add Android support.
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS)
      PopupMenuItem<int>(
        padding: EdgeInsets.zero,
        value: 5,
        child: ListTile(
          leading: Icon(Platform.isWindows
              ? FluentIcons.folder_24_regular
              : Icons.folder),
          title: Text(
            Language.instance.SHOW_IN_FILE_MANAGER,
            style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
          ),
        ),
      ),
    PopupMenuItem<int>(
      padding: EdgeInsets.zero,
      value: 6,
      child: ListTile(
        leading:
            Icon(Platform.isWindows ? FluentIcons.edit_24_regular : Icons.edit),
        title: Text(
          Language.instance.EDIT_DETAILS,
          style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
        ),
      ),
    ),
    PopupMenuItem<int>(
      padding: EdgeInsets.zero,
      value: 4,
      child: ListTile(
        leading: Icon(
            Platform.isWindows ? FluentIcons.album_24_regular : Icons.album),
        title: Text(
          Language.instance.SHOW_ALBUM,
          style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
        ),
      ),
    ),
    PopupMenuItem<int>(
      padding: EdgeInsets.zero,
      value: 7,
      child: ListTile(
        leading:
            Icon(Platform.isWindows ? FluentIcons.info_24_regular : Icons.info),
        title: Text(
          Language.instance.FILE_INFORMATION,
          style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
        ),
      ),
    ),
    if (Lyrics.instance.hasLRCFile(track))
      PopupMenuItem<int>(
        padding: EdgeInsets.zero,
        value: 9,
        child: ListTile(
          leading: Icon(
            Platform.isWindows
                ? FluentIcons.clear_formatting_24_regular
                : Icons.clear,
          ),
          title: Text(
            Language.instance.CLEAR_LRC_FILE,
            style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
          ),
        ),
      )
    else
      PopupMenuItem<int>(
        padding: EdgeInsets.zero,
        value: 8,
        child: ListTile(
          leading: Icon(
            Platform.isWindows ? FluentIcons.text_font_24_regular : Icons.abc,
          ),
          title: Text(
            Language.instance.SET_LRC_FILE,
            style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
          ),
        ),
      ),
    if (!isDesktop && !MobileNowPlayingController.instance.isHidden)
      PopupMenuItem<int>(
        padding: EdgeInsets.zero,
        child: SizedBox(height: kMobileNowPlayingBarHeight),
      ),
  ];
}

List<PopupMenuItem<int>> albumPopupMenuItems(
  Album album,
  BuildContext context,
) {
  return [
    PopupMenuItem<int>(
      padding: EdgeInsets.zero,
      value: 0,
      child: ListTile(
        leading: Icon(
          Platform.isWindows ? FluentIcons.play_24_regular : Icons.play_circle,
        ),
        title: Text(
          Language.instance.PLAY,
          style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
        ),
      ),
    ),
    PopupMenuItem<int>(
      padding: EdgeInsets.zero,
      value: 1,
      child: ListTile(
        leading: Icon(
          Platform.isWindows
              ? FluentIcons.arrow_shuffle_24_regular
              : Icons.shuffle,
        ),
        title: Text(
          Language.instance.SHUFFLE,
          style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
        ),
      ),
    ),
    PopupMenuItem<int>(
      padding: EdgeInsets.zero,
      value: 2,
      child: ListTile(
        leading: Icon(
          Platform.isWindows ? FluentIcons.delete_16_regular : Icons.delete,
        ),
        title: Text(
          Language.instance.DELETE,
          style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
        ),
      ),
    ),
    PopupMenuItem<int>(
      padding: EdgeInsets.zero,
      value: 3,
      child: ListTile(
        leading: Icon(
          Platform.isWindows
              ? FluentIcons.music_note_2_16_regular
              : Icons.queue_music,
        ),
        title: Text(
          Language.instance.ADD_TO_NOW_PLAYING,
          style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
        ),
      ),
    ),
    if (!isDesktop && !MobileNowPlayingController.instance.isHidden)
      PopupMenuItem<int>(
        padding: EdgeInsets.zero,
        child: SizedBox(height: kMobileNowPlayingBarHeight),
      ),
  ];
}

Future<void> trackPopupMenuHandle(
  BuildContext context,
  Track track,
  int? result, {
  bool Function()? recursivelyPopNavigatorOnDeleteIf,
}) async {
  if (result != null) {
    switch (result) {
      case 0:
        if (Platform.isAndroid) {
          final sdk = StorageRetriever.instance.version;
          if (sdk >= 30) {
            // No [AlertDialog] required for confirmation.
            // Android 11 or higher (API level 30) will ask for permissions from the user before deletion.
            await Collection.instance.delete(track);
            if (recursivelyPopNavigatorOnDeleteIf != null) {
              if (recursivelyPopNavigatorOnDeleteIf()) {
                while (Navigator.of(context).canPop()) {
                  await Navigator.of(context).maybePop();
                }
                if (floatingSearchBarController.isOpen) {
                  floatingSearchBarController.close();
                }
              }
            }
            return;
          }
        }
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(
              Language.instance.COLLECTION_TRACK_DELETE_DIALOG_HEADER,
            ),
            content: Text(
              Language.instance.COLLECTION_TRACK_DELETE_DIALOG_BODY.replaceAll(
                'NAME',
                track.trackName,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  await Collection.instance.delete(track);
                  await Navigator.of(ctx).maybePop();
                  if (recursivelyPopNavigatorOnDeleteIf != null) {
                    if (recursivelyPopNavigatorOnDeleteIf()) {
                      while (Navigator.of(context).canPop()) {
                        await Navigator.of(context).maybePop();
                      }
                      if (floatingSearchBarController.isOpen) {
                        floatingSearchBarController.close();
                      }
                    }
                  }
                },
                child: Text(
                  label(
                    context,
                    Language.instance.YES,
                  ),
                ),
              ),
              TextButton(
                onPressed: Navigator.of(ctx).pop,
                child: Text(
                  label(
                    context,
                    Language.instance.NO,
                  ),
                ),
              ),
            ],
          ),
        );
        break;
      case 1:
        if (track.uri.isScheme('FILE')) {
          await Share.shareFiles(
            [track.uri.toFilePath()],
            subject: '${track.trackName} • ${[
              '',
              kUnknownArtist,
            ].contains(track.albumArtistName) ? track.trackArtistNames.take(2).join(', ') : track.albumArtistName}',
          );
        } else {
          await Share.share(
            '${track.trackName} • ${[
              '',
              kUnknownArtist,
            ].contains(track.albumArtistName) ? track.trackArtistNames.take(2).join(', ') : track.albumArtistName} • ${track.uri.toString()}',
          );
        }
        break;
      case 2:
        await showAddToPlaylistDialog(context, track);
        break;
      case 3:
        Playback.instance.add([track]);
        break;
      case 4:
        {
          Iterable<Color>? palette;
          final album = Collection.instance.albumsSet.lookup(
            Album(
              albumName: track.albumName,
              year: track.year,
              albumArtistName: track.albumArtistName,
              albumHashCodeParameters:
                  Configuration.instance.albumHashCodeParameters,
            ),
          );
          if (album != null) {
            if (isMobile) {
              final result = await PaletteGenerator.fromImageProvider(
                getAlbumArt(album, small: true),
              );
              palette = result.colors;
            }
            await precacheImage(getAlbumArt(album), context);
            Playback.instance.interceptPositionChangeRebuilds = true;
            Navigator.of(context).push(
              MaterialRoute(
                builder: (context) => AlbumScreen(
                  album: album,
                  palette: palette,
                ),
              ),
            );
          }
          Timer(
            const Duration(milliseconds: 400),
            () {
              Playback.instance.interceptPositionChangeRebuilds = false;
            },
          );
          break;
        }
      case 5:
        File(track.uri.toFilePath()).explore_();
        break;
      case 6:
        await Navigator.of(context).push(
          MaterialRoute(
            builder: (context) => EditDetailsScreen(track: track),
          ),
        );
        break;
      case 7:
        await FileInfoScreen.show(
          context,
          uri: track.uri,
        );
        break;
      case 8:
        final file = await pickFile(
          label: 'LRC',
          // Compatiblitity issues with Android 5.0. SDK 21.
          extensions: Platform.isAndroid ? null : ['lrc'],
        );
        if (file != null) {
          final added = await Lyrics.instance.addLRCFile(
            track,
            file,
          );
          if (!added) {
            await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: Theme.of(context).cardTheme.color,
                title: Text(
                  Language.instance.ERROR,
                ),
                content: Text(Language.instance.CORRUPT_LRC_FILE),
                actions: [
                  TextButton(
                    onPressed: Navigator.of(context).pop,
                    child: Text(
                      label(
                        context,
                        Language.instance.OK,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        }
        break;
      case 9:
        Lyrics.instance.removeLRCFile(track);
        break;
    }
  }
}

Future<void> albumPopupMenuHandle(
  BuildContext context,
  Album album,
  int? result,
) async {
  final tracks = album.tracks.toList();
  tracks.sort(
    (first, second) =>
        first.discNumber.compareTo(second.discNumber) * 100000000 +
        first.trackNumber.compareTo(second.trackNumber) * 1000000 +
        first.trackName.compareTo(second.trackName) * 10000 +
        first.trackArtistNames
                .join()
                .compareTo(second.trackArtistNames.join()) *
            100 +
        first.uri.toString().compareTo(second.uri.toString()),
  );
  if (result != null) {
    switch (result) {
      case 0:
        await Playback.instance.open(tracks);
        break;
      case 1:
        tracks.shuffle();
        await Playback.instance.open(tracks);
        break;
      case 2:
        if (Platform.isAndroid) {
          final sdk = StorageRetriever.instance.version;
          if (sdk >= 30) {
            // No [AlertDialog] required for confirmation.
            // Android 11 or higher (API level 30) will ask for permissions from the user before deletion.
            await Collection.instance.delete(album);
            while (Navigator.of(context).canPop()) {
              await Navigator.of(context).maybePop();
            }
            if (floatingSearchBarController.isOpen) {
              floatingSearchBarController.close();
            }
            return;
          }
        }
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(
              Language.instance.COLLECTION_ALBUM_DELETE_DIALOG_HEADER,
            ),
            content: Text(
              Language.instance.COLLECTION_ALBUM_DELETE_DIALOG_BODY.replaceAll(
                'NAME',
                album.albumName,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  await Collection.instance.delete(album);
                  await Navigator.of(ctx).maybePop();
                  while (Navigator.of(context).canPop()) {
                    await Navigator.of(context).maybePop();
                  }
                  if (floatingSearchBarController.isOpen) {
                    floatingSearchBarController.close();
                  }
                },
                child: Text(
                  label(
                    context,
                    Language.instance.YES,
                  ),
                ),
              ),
              TextButton(
                onPressed: Navigator.of(ctx).pop,
                child: Text(
                  label(
                    context,
                    Language.instance.NO,
                  ),
                ),
              ),
            ],
          ),
        );
        break;
      case 3:
        await Playback.instance.add(tracks);
        break;
    }
  }
}

Future<File?> pickFile({
  required String label,
  List<String>? extensions,
}) async {
  String? path;
  if (Platform.isWindows) {
    OpenFilePicker picker = OpenFilePicker()
      ..filterSpecification = {
        if (extensions != null) ...{
          label: extensions.map((e) => '*.${e.toLowerCase()}').join(';'),
        },
        Language.instance.ALL_FILES: '*',
      }
      // Choosing first [extensions] extension as default.
      ..defaultFilterIndex = 0
      ..defaultExtension = extensions?.first.toLowerCase();
    path = picker.getFile()?.path;
  } else if (Platform.isLinux) {
    final result = await openFile(
      acceptedTypeGroups: [
        XTypeGroup(
          label: label,
          // Case sensitive paths on GNU/Linux.
          extensions: [
            if (extensions != null) ...[
              ...extensions.map((e) => e.toLowerCase()).toList(),
              ...extensions.map((e) => e.toUpperCase()).toList(),
            ],
          ].toSet().toList(),
        ),
        XTypeGroup(
          label: Language.instance.ALL_FILES,
        ),
      ],
    );
    path = result?.path;
  }
  // Using `package:file_picker` on other platforms.
  else {
    final result = await FilePicker.platform.pickFiles(
      // Case sensitive paths on Android.
      allowedExtensions: extensions == null
          ? null
          : [
              ...extensions.map((e) => e.toLowerCase()).toList(),
              ...extensions.map((e) => e.toUpperCase()).toList(),
            ].toSet().toList(),
      // Needed for [allowedExtensions].
      type: extensions == null ? FileType.any : FileType.custom,
    );
    if ((result?.count ?? 0) > 0) {
      path = result?.files.first.path;
    }
  }
  return path == null ? null : File(path);
}

/// Prompts the user to select a folder.
///
/// [useNativePicker] only works on Android.
/// Modern Android SDK 30+ are strictier about file access & enforce Scoped Storage.
/// This means that native file picker cannot pick the root phone or SD card directory & the downloads folder.
///
/// To address this issue with directory selection for file indexing, a custom file picker is used, which is entirely Flutter based.
///
Future<Directory?> pickDirectory({
  bool useNativePicker = false,
}) async {
  Directory? directory;
  if (Platform.isWindows) {
    final picker = DirectoryPicker();
    directory = picker.getDirectory();
  } else if (Platform.isLinux) {
    final path = await getDirectoryPath();
    if (path != null) {
      directory = Directory(path);
    }
  }
  // Using `package:file_picker` on other platforms.
  else {
    if (useNativePicker) {
      final path = await FilePicker.platform.getDirectoryPath();
      if (path != null) {
        directory = Directory(path);
      }
    } else {
      return showGeneralDialog(
        context: navigatorKey.currentContext!,
        useRootNavigator: true,
        barrierDismissible: false,
        barrierColor: Colors.transparent,
        pageBuilder: (context, animation, secondaryAnimation) =>
            DirectoryPickerScreen(),
      );
    }
  }
  return directory;
}

Future<void> showAddToPlaylistDialog(
  BuildContext context,
  Track track, {
  bool elevated = false,
}) {
  final playlists = Collection.instance.playlists.toList();
  if (isDesktop) {
    return showDialog(
      context: context,
      builder: (subContext) => AlertDialog(
        contentPadding: EdgeInsets.only(top: 20.0),
        title: Text(Language.instance.PLAYLIST_ADD_DIALOG_TITLE),
        content: Container(
          height: 480.0,
          width: 512.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Divider(
                height: 1.0,
              ),
              Expanded(
                child: CustomListViewBuilder(
                  itemExtents: List.generate(
                    playlists.length,
                    (index) => 64.0 + 9.0,
                  ),
                  shrinkWrap: true,
                  itemCount: playlists.length,
                  itemBuilder: (context, i) => PlaylistTile(
                    playlist: playlists[i],
                    onTap: () async {
                      await Collection.instance.playlistAddTrack(
                        playlists[i],
                        track,
                      );
                      Navigator.of(subContext).pop();
                    },
                  ),
                ),
              ),
              const Divider(height: 1.0),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: Navigator.of(subContext).pop,
            child: Text(
              label(
                context,
                Language.instance.CANCEL,
              ),
            ),
          ),
        ],
      ),
    );
  } else {
    if (elevated) {
      return showModalBottomSheet(
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        context: context,
        builder: (context) => Card(
          margin: EdgeInsets.only(
            left: 8.0,
            right: 8.0,
            bottom: kBottomNavigationBarHeight + 8.0,
          ),
          elevation: kDefaultHeavyElevation,
          child: DraggableScrollableSheet(
            initialChildSize: 0.6,
            maxChildSize: 0.8,
            expand: false,
            builder: (context, controller) => ListView.builder(
              padding: EdgeInsets.zero,
              controller: controller,
              shrinkWrap: true,
              itemCount: playlists.length,
              itemBuilder: (context, i) {
                return PlaylistTile(
                  playlist: playlists[i],
                  onTap: () async {
                    await Collection.instance.playlistAddTrack(
                      playlists[i],
                      track,
                    );
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        ),
      );
    }
    return showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, controller) => ListView.builder(
          padding: EdgeInsets.zero,
          controller: controller,
          shrinkWrap: true,
          itemCount: playlists.length,
          itemBuilder: (context, i) {
            return PlaylistTile(
              playlist: playlists[i],
              onTap: () async {
                await Collection.instance.playlistAddTrack(
                  playlists[i],
                  track,
                );
                Navigator.of(context).pop();
              },
            );
          },
        ),
      ),
    );
  }
}

InputDecoration inputDecoration(
  BuildContext context,
  String hintText, {
  Widget? trailingIcon,
  VoidCallback? trailingIconOnPressed,
  Color? fillColor,
}) {
  return InputDecoration(
    // Having a [suffixIcon] keeps the [CustomTextField]'s content (label / text)
    // centered for some reason at all heights. So, this is a good solution.
    suffixIcon: trailingIcon == null
        ? const SizedBox(height: 48.0)
        : Container(
            alignment: Alignment.center,
            height: 48.0,
            width: 48.0,
            child: Material(
              color: Colors.transparent,
              child: IconButton(
                splashRadius: 8.0,
                iconSize: 24.0,
                highlightColor: Colors.transparent,
                onPressed: trailingIconOnPressed,
                icon: trailingIcon,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
    suffixIconConstraints: trailingIcon == null
        ? const BoxConstraints(
            minHeight: 48.0,
            minWidth: 0.0,
          )
        : null,
    // No requirement for vertical padding/margin since [TextAlignVertical.center] is used now.
    contentPadding: EdgeInsets.only(
      left: 12.0,
      right: 12.0,
      // [bottom] padding is needed since Flutter v3.7.x.
      bottom: Platform.isWindows || Platform.isLinux || Platform.isMacOS
          ? 8.0
          : 2.0,
    ),
    hintText: hintText,
    filled: true,
    fillColor: fillColor ?? Theme.of(context).colorScheme.surfaceVariant,
    border: UnderlineInputBorder(
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        width: 1.8,
      ),
    ),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        width: 1.8,
      ),
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.primary,
        width: 1.8,
      ),
    ),
    hintMaxLines: 1,
    errorMaxLines: 1,
    helperMaxLines: 1,
    errorStyle: const TextStyle(height: 0.0),
  );
}

InputDecoration mobileUnderlinedInputDecoration(
    BuildContext context, String hintText) {
  return InputDecoration(
    hintText: hintText,
    border: OutlineInputBorder(
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        width: 1.8,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        width: 1.8,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.primary,
        width: 1.8,
      ),
    ),
    hintMaxLines: 1,
    errorMaxLines: 1,
    helperMaxLines: 1,
    errorStyle: const TextStyle(height: 0.0),
  );
}

class TabRoute {
  final int index;
  final TabRouteSender sender;
  const TabRoute(
    this.index,
    this.sender,
  );
}

enum TabRouteSender {
  pageView,
  bottomNavigationBar,
  systemNavigationBackButton,
}

/// Caches the resolved album arts once requested by [getAlbumArt].
/// This prevents redundant I/O operations.
HashMap<Media, ImageProvider> resolvedAlbumArts =
    HashMap<Media, ImageProvider>();

/// Fetches the album art of a given [Media] either local or online.
///
/// Passing [small] as `true` will result in a smaller sized image, which may be useful
/// for performance reasons e.g. generating palette using `package:palette_generator`
/// or rendering, especially on desktop platforms.
///
/// Automatically falls back to the default album art from Harmonoid's assets.
///
ImageProvider getAlbumArt(
  Media media, {
  int? cacheWidth,
  bool small = false,
  bool? lookupForFallbackAlbumArt,
  List<String>? fallbackAlbumArtFileNames,
}) {
  bool _lookupForFallbackAlbumArt = false;
  try {
    _lookupForFallbackAlbumArt =
        Configuration.instance.lookupForFallbackAlbumArt;
  } catch (exception, stacktrace) {
    debugPrint(exception.toString());
    debugPrint(stacktrace.toString());
  }
  lookupForFallbackAlbumArt ??= _lookupForFallbackAlbumArt;

  List<String> _fallbackAlbumArtFileNames = kDefaultFallbackAlbumArtFileNames;
  try {
    _fallbackAlbumArtFileNames =
        Configuration.instance.fallbackAlbumArtFileNames;
  } catch (exception, stacktrace) {
    debugPrint(exception.toString());
    debugPrint(stacktrace.toString());
  }
  fallbackAlbumArtFileNames ??= _fallbackAlbumArtFileNames;

  // Result.
  ImageProvider? image;

  // Already resolved by previous [getAlbumArt] calls.
  if (resolvedAlbumArts.containsKey(media)) {
    image = resolvedAlbumArts[media]!;
  }
  // Fresh request.
  else {
    // Separately handle the web URLs.
    if (media is Track) {
      if (ExternalMedia.supported(media.uri)) {
        image = ExtendedNetworkImageProvider(
          ExternalMedia.thumbnail(
            media.uri,
            small: small,
          ).toString(),
          cache: true,
        );
      } else if (!media.uri.isScheme('FILE')) {
        // Album arts are not supported for online [Media] URLs.
        image = ExtendedFileImageProvider(Collection.instance.unknownAlbumArt);
      }
    }
    if (image == null) {
      // The passed [media] wasn't a web entity, fetch album art for the locally stored media.
      // Automatically checks for fallback album arts e.g. `Folder.jpg` or `cover.jpg` etc.
      final file = Collection.instance.getAlbumArt(
        media,
        lookupForFallbackAlbumArt: lookupForFallbackAlbumArt,
        fallbackAlbumArtFileNames: fallbackAlbumArtFileNames,
      );
      if (file != null) {
        // An album art is found.
        image = ExtendedFileImageProvider(file);
      }
    }
    if (image == null) {
      // No album art found, use the default album art.
      image = ExtendedFileImageProvider(Collection.instance.unknownAlbumArt);
    }
    // Cache the resolved album art.
    resolvedAlbumArts[media] = image;
  }

  // [ResizeImage.resizeIfNeeded] is only needed for local images.
  if (small && !(image is ExtendedNetworkImageProvider)) {
    return ResizeImage.resizeIfNeeded(null, cacheWidth ?? 200, image);
  } else {
    return image;
  }
}
