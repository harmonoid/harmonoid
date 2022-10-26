/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'dart:io';
import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:media_library/media_library.dart';
import 'package:media_engine/media_engine.dart' hide Media;
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:extended_image/extended_image.dart';
import 'package:filepicker_windows/filepicker_windows.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

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
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/utils/dimensions.dart';
import 'package:harmonoid/utils/file_system.dart';
import 'package:harmonoid/utils/windows_info.dart';
import 'package:harmonoid/utils/palette_generator.dart';
import 'package:harmonoid/utils/storage_retriever.dart';
import 'package:harmonoid/constants/language.dart';

export 'package:harmonoid/utils/extensions.dart';

// Only global variables throughout Harmonoid's source code.

const kPrimaryLightColor = Color(0xFF6200EA);
const kPrimaryDarkColor = Color(0xFF7C4DFF);

final isDesktop = Platform.isWindows || Platform.isLinux || Platform.isMacOS;
final isMobile = Platform.isAndroid || Platform.isIOS;
final desktopTitleBarHeight =
    WindowsInfo.instance.isWindows10OrGreater ? 32.0 : 0.0;
final tileMargin = isDesktop ? kDesktopTileMargin : kMobileTileMargin;
final HotKey searchBarHotkey = HotKey(
  KeyCode.keyF,
  modifiers: [KeyModifier.control],
  scope: HotKeyScope.inapp,
);
final message = Random().nextInt(100) == 50
    ? 'Yeah! You found the easter egg. 🥚'
    : DateTime.now().day > (25 - 7) &&
            DateTime.now().day <= 25 &&
            DateTime.now().month == 12
        ? 'Merry Christmas! ❄️'
        : DateTime.now().day == 1 && DateTime.now().month == 1
            ? 'Happy New Year! 🎈'
            : '';

// Remaining source code in this file consists of helper & utility methods used for rendering & handling some repeated tasks linked at multiple places.

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
  margin ??= tileMargin;
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
  margin ??= tileMargin;
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
    Track track, BuildContext context) {
  return [
    PopupMenuItem<int>(
      padding: EdgeInsets.zero,
      value: 0,
      child: ListTile(
        leading: Icon(
            Platform.isWindows ? FluentIcons.delete_16_regular : Icons.delete),
        title: Text(
          Language.instance.DELETE,
          style: isDesktop ? Theme.of(context).textTheme.headline4 : null,
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
            style: isDesktop ? Theme.of(context).textTheme.headline4 : null,
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
          style: isDesktop ? Theme.of(context).textTheme.headline4 : null,
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
          style: isDesktop ? Theme.of(context).textTheme.headline4 : null,
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
            style: isDesktop ? Theme.of(context).textTheme.headline4 : null,
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
          style: isDesktop ? Theme.of(context).textTheme.headline4 : null,
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
          style: isDesktop ? Theme.of(context).textTheme.headline4 : null,
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
          style: isDesktop ? Theme.of(context).textTheme.headline4 : null,
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
            style: isDesktop ? Theme.of(context).textTheme.headline4 : null,
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
            style: isDesktop ? Theme.of(context).textTheme.headline4 : null,
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
              style: Theme.of(ctx).textTheme.headline3,
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
                child: Text(Language.instance.YES),
              ),
              TextButton(
                onPressed: Navigator.of(ctx).pop,
                child: Text(Language.instance.NO),
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
          late final Album album;
          for (final item in Collection.instance.albums) {
            if (item.albumName == track.albumName && item.year == track.year) {
              album = item;
              break;
            }
          }
          if (isMobile) {
            final result = await PaletteGenerator.fromImageProvider(
              getAlbumArt(album, small: true),
            );
            palette = result.colors;
          }
          Playback.instance.interceptPositionChangeRebuilds = true;
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  FadeThroughTransition(
                animation: animation,
                secondaryAnimation: secondaryAnimation,
                child: AlbumScreen(
                  album: album,
                  palette: palette,
                ),
              ),
            ),
          );
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
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                FadeThroughTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              child: EditDetailsScreen(track: track),
            ),
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
                backgroundColor: Theme.of(context).cardColor,
                title: Text(
                  Language.instance.ERROR,
                ),
                content: Text(
                  Language.instance.CORRUPT_LRC_FILE,
                  style: Theme.of(context).textTheme.headline3,
                ),
                actions: [
                  TextButton(
                    onPressed: Navigator.of(context).pop,
                    child: Text(Language.instance.OK),
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
              Divider(
                height: 1.0,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: Navigator.of(subContext).pop,
            child: Text(Language.instance.CANCEL),
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
          elevation: 8.0,
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
    // Having a [suffixIcon] keeps the [TextField]'s content (label / text)
    // centered for some reason at all heights. So, this is a good solution.
    suffixIcon: Container(
      alignment: Alignment.center,
      height: 48.0,
      width: 48.0,
      child: trailingIcon == null
          ? null
          : Material(
              color: Colors.transparent,
              child: IconButton(
                splashRadius: 12.0,
                iconSize: 24.0,
                highlightColor: Colors.transparent,
                onPressed: trailingIconOnPressed,
                icon: trailingIcon,
              ),
            ),
    ),
    // No requirement for vertical padding/margin since [TextAlignVertical.center] is used now.
    contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
    hintText: hintText,
    hintStyle: isDesktop
        ? Theme.of(context).textTheme.headline3?.copyWith(
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.black54
                  : Colors.white60,
            )
        : null,
    filled: true,
    fillColor: fillColor ?? Theme.of(context).dividerColor.withOpacity(0.04),
    border: UnderlineInputBorder(
      borderSide: BorderSide(
        color: Theme.of(context).iconTheme.color!.withOpacity(0.4),
        width: 1.8,
      ),
    ),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(
        color: Theme.of(context).iconTheme.color!.withOpacity(0.4),
        width: 1.8,
      ),
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(
        color: Theme.of(context).primaryColor,
        width: 1.8,
      ),
    ),
    hintMaxLines: 1,
    errorMaxLines: 1,
    helperMaxLines: 1,
    errorStyle: TextStyle(height: 0.0),
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

Uri? validate(String text) {
  // Get rid of quotes.
  if (text.startsWith('"') && text.endsWith('"')) {
    text = text.substring(1, text.length - 1);
  }
  debugPrint(text);
  Uri? uri;
  if (uri == null) {
    try {
      if (FS.typeSync_(text) == FileSystemEntityType.file) {
        if (Platform.isWindows) {
          text = text.replaceAll('\\', '/');
        }
        uri = File(text).uri;
      }
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }
  }
  if (uri == null) {
    try {
      uri = Uri.parse(text);
      if (!(uri.isScheme('HTTP') ||
          uri.isScheme('HTTPS') ||
          uri.isScheme('FTP') ||
          uri.isScheme('RSTP') ||
          uri.isScheme('FILE'))) {
        uri = null;
      }
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }
  }
  return uri;
}

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
}) {
  bool fallback = false;
  try {
    fallback = Configuration.instance.lookupForFallbackAlbumArt;
  } catch (exception, stacktrace) {
    debugPrint(exception.toString());
    debugPrint(stacktrace.toString());
  }
  lookupForFallbackAlbumArt ??= fallback;
  ImageProvider? image;
  // Separately handle the web URLs.
  if (media is Track) {
    if (LibmpvPluginUtils.isSupported(media.uri)) {
      image = ExtendedNetworkImageProvider(
        LibmpvPluginUtils.thumbnail(
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
  // [ResizeImage.resizeIfNeeded] is only needed for local images.
  if (small && !(image is ExtendedNetworkImageProvider)) {
    return ResizeImage.resizeIfNeeded(null, cacheWidth ?? 200, image);
  } else {
    return image;
  }
}
