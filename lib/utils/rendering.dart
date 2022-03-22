/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:animations/animations.dart';
import 'package:libmpv/libmpv.dart' hide Media;
import 'package:share_plus/share_plus.dart';
import 'package:extended_image/extended_image.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/models/media.dart';
import 'package:harmonoid/interface/collection/album.dart';
import 'package:harmonoid/utils/dimensions.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/utils/file_system.dart';
import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/interface/collection/playlist.dart';
import 'package:harmonoid_visual_assets/harmonoid_visual_assets.dart';

final isDesktop = Platform.isWindows || Platform.isLinux || Platform.isMacOS;
final isMobile = Platform.isAndroid || Platform.isIOS;
final desktopTitleBarHeight = Platform.isWindows ? 32.0 : 0.0;
final tileMargin = isDesktop ? kDesktopTileMargin : kMobileTileMargin;
final visualAssets = VisualAssets();

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
  MainAxisAlignment mainAxisAlignment: MainAxisAlignment.center,
}) {
  List<Widget> widgets = <Widget>[];
  widgets.addAll([
    if (leadingSubHeader != null) SubHeader(leadingSubHeader),
    if (leadingWidget != null) leadingWidget,
    if (subHeader != null) SubHeader(subHeader),
  ]);
  int rowIndex = 0;
  List<Widget> rowChildren = <Widget>[];
  for (int index = 0; index < widgetCount; index++) {
    rowChildren.add(
      Container(
        child: builder(context, index),
        margin: EdgeInsets.symmetric(
          horizontal: tileMargin / 2.0,
        ),
      ),
    );
    rowIndex++;
    if (rowIndex > elementsPerRow - 1) {
      widgets.add(
        Container(
          height: tileHeight + tileMargin,
          margin:
              EdgeInsets.only(left: tileMargin / 2.0, right: tileMargin / 2.0),
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
  if (widgetCount % elementsPerRow != 0) {
    rowChildren = <Widget>[];
    for (int index = widgetCount - (widgetCount % elementsPerRow);
        index < widgetCount;
        index++) {
      rowChildren.add(
        Container(
          child: builder(context, index),
          margin: EdgeInsets.symmetric(
            horizontal: tileMargin / 2.0,
          ),
        ),
      );
    }
    for (int index = 0;
        index < elementsPerRow - (widgetCount % elementsPerRow);
        index++) {
      rowChildren.add(
        Container(
          height: tileHeight + tileMargin,
          width: tileWidth,
          margin:
              EdgeInsets.only(left: tileMargin / 2.0, right: tileMargin / 2.0),
        ),
      );
    }
    widgets.add(
      Container(
        height: tileHeight + tileMargin,
        margin:
            EdgeInsets.only(left: tileMargin / 2.0, right: tileMargin / 2.0),
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
  required String? subHeader,
  required BuildContext context,
  required int widgetCount,
  required Widget Function(BuildContext context, int index) builder,
  required String? leadingSubHeader,
  required Widget? leadingWidget,
  required int elementsPerRow,
}) {
  final widgets = <Widget>[];
  final data = <List<dynamic>>[];
  widgets.addAll([
    if (leadingSubHeader != null) SubHeader(leadingSubHeader),
    if (leadingWidget != null) leadingWidget,
    if (subHeader != null) SubHeader(subHeader),
  ]);
  var rowIndex = 0;
  var rowChildren = <Widget>[];
  var rowData = <dynamic>[];
  for (int index = 0; index < widgetCount; index++) {
    final widget = builder(context, index);
    rowChildren.add(
      Container(
        child: widget,
        margin: EdgeInsets.symmetric(
          horizontal: tileMargin / 2.0,
        ),
      ),
    );
    rowData.add((widget.key as ValueKey).value);
    rowIndex++;
    if (rowIndex > elementsPerRow - 1) {
      widgets.add(
        Container(
          height: tileHeight + tileMargin,
          margin:
              EdgeInsets.only(left: tileMargin / 2.0, right: tileMargin / 2.0),
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
            horizontal: tileMargin / 2.0,
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
          height: tileHeight + tileMargin,
          width: tileWidth,
          margin:
              EdgeInsets.only(left: tileMargin / 2.0, right: tileMargin / 2.0),
        ),
      );
    }
    widgets.add(
      Container(
        height: tileHeight + tileMargin,
        margin:
            EdgeInsets.only(left: tileMargin / 2.0, right: tileMargin / 2.0),
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
  return TileGridListWidgetsData(
    widgets,
    data,
  );
}

List<PopupMenuItem<int>> trackPopupMenuItems(BuildContext context) {
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
        showDialog(
          context: context,
          builder: (subContext) => AlertDialog(
            title: Text(
              Language.instance.COLLECTION_TRACK_DELETE_DIALOG_HEADER,
              style: Theme.of(subContext).textTheme.headline1,
            ),
            content: Text(
              Language.instance.COLLECTION_TRACK_DELETE_DIALOG_BODY.replaceAll(
                'NAME',
                track.trackName,
              ),
              style: Theme.of(subContext).textTheme.headline3,
            ),
            actions: [
              MaterialButton(
                textColor: Theme.of(context).primaryColor,
                onPressed: () async {
                  await Collection.instance.delete(track);
                  Navigator.of(subContext).pop();
                  if (recursivelyPopNavigatorOnDeleteIf != null) {
                    if (recursivelyPopNavigatorOnDeleteIf()) {
                      while (Navigator.of(context).canPop())
                        Navigator.of(context).pop();
                    }
                  }
                },
                child: Text(Language.instance.YES),
              ),
              MaterialButton(
                textColor: Theme.of(context).primaryColor,
                onPressed: Navigator.of(subContext).pop,
                child: Text(Language.instance.NO),
              ),
            ],
          ),
        );
        break;
      case 1:
        Share.shareFiles(
          [track.uri.toString()],
          subject: '${track.trackName} • ${track.albumName}',
        );
        break;
      case 2:
        showDialog(
          context: context,
          builder: (subContext) => AlertDialog(
            contentPadding: EdgeInsets.zero,
            actionsPadding: EdgeInsets.zero,
            titlePadding: EdgeInsets.zero,
            content: Container(
              width: isDesktop ? 512.0 : 280.0,
              height: isDesktop ? 480.0 : 280.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(28, 20, 0, 0),
                    child: Text(
                      Language.instance.PLAYLIST_ADD_DIALOG_TITLE,
                      style: Theme.of(subContext).textTheme.headline1?.copyWith(
                            fontSize: 20.0,
                          ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(28, 2, 0, 16),
                    child: Text(
                      Language.instance.PLAYLIST_ADD_DIALOG_BODY,
                      style: Theme.of(subContext).textTheme.headline3,
                    ),
                  ),
                  Container(
                    height: (isDesktop ? 512.0 : 280.0) - 118.0,
                    width: isDesktop ? 512.0 : 280.0,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: Collection.instance.playlists.length,
                      itemBuilder: (context, i) => PlaylistTile(
                        playlist: Collection.instance.playlists[i],
                        onTap: () async {
                          await Collection.instance.playlistAddTrack(
                            Collection.instance.playlists[i],
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
              MaterialButton(
                textColor: Theme.of(context).primaryColor,
                onPressed: Navigator.of(subContext).pop,
                child: Text(Language.instance.CANCEL),
              ),
            ],
          ),
        );
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
            final result =
                await PaletteGenerator.fromImageProvider(getAlbumArt(album));
            palette = result.colors;
          }
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
          break;
        }
    }
  }
}

InputDecoration desktopInputDecoration(
  BuildContext context,
  String hintText, {
  Widget? trailingIcon,
  VoidCallback? trailingIconOnPressed,
}) {
  return InputDecoration(
    suffixIcon: Material(
      color: Colors.transparent,
      child: trailingIcon == null
          ? null
          : IconButton(
              splashRadius: 14.0,
              highlightColor: Colors.transparent,
              onPressed: trailingIconOnPressed,
              icon: trailingIcon,
              iconSize: 24.0,
            ),
    ),
    contentPadding:
        EdgeInsets.only(left: 10.0, bottom: trailingIcon == null ? 18.0 : 14.0),
    hintText: hintText,
    hintStyle: Theme.of(context).textTheme.headline3?.copyWith(
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.black.withOpacity(0.6)
              : Colors.white60,
        ),
    filled: true,
    fillColor: Theme.of(context).brightness == Brightness.light
        ? Colors.white
        : Color(0xFF202020),
    hoverColor: Theme.of(context).brightness == Brightness.light
        ? Colors.white
        : Color(0xFF202020),
    border: OutlineInputBorder(
      borderSide: BorderSide(
        color: Theme.of(context).dividerColor.withOpacity(0.32),
        width: 0.6,
      ),
      borderRadius: BorderRadius.zero,
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Theme.of(context).dividerColor.withOpacity(0.32),
        width: 0.6,
      ),
      borderRadius: BorderRadius.zero,
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Theme.of(context).dividerColor.withOpacity(0.32),
        width: 0.6,
      ),
      borderRadius: BorderRadius.zero,
    ),
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

extension StringExtension on String {
  get overflow => Characters(this)
      .replaceAll(Characters(''), Characters('\u{200B}'))
      .toString();

  get safePath => replaceAll(RegExp(r'[\\/:*?""<>| ]'), '');
}

extension DateTimeExtension on DateTime {
  get label =>
      '${day.toString().padLeft(2, '0')}-${month.toString().padLeft(2, '0')}-$year';
}

ImageProvider getAlbumArt(Media media, {bool small: false}) {
  final result = () {
    if (media is Track) {
      if (Plugins.isExternalMedia(media.uri)) {
        return ExtendedNetworkImageProvider(
          Plugins.artwork(media.uri, small: small),
          cache: true,
        );
      }
      final file = File(path.join(
        Collection.instance.albumArtDirectory.path,
        media.albumArtFileName,
      ));
      if (file.existsSync_()) {
        return ExtendedFileImageProvider(file);
      } else {
        final file = File(path.join(
          Collection.instance.albumArtDirectory.path,
          media.legacyAlbumArtFileName,
        ));
        if (file.existsSync_()) {
          return ExtendedFileImageProvider(file);
        } else {
          for (final name in kAlbumArtFileNames) {
            final file =
                File(path.join(path.basename(media.uri.toFilePath()), name));
            if (file.existsSync_()) {
              return ExtendedFileImageProvider(file);
            }
          }
        }
      }
    } else if (media is Album) {
      if (Plugins.isExternalMedia(media.tracks.first.uri)) {
        return ExtendedNetworkImageProvider(
          Plugins.artwork(
            media.tracks.first.uri,
            small: small,
          ),
          cache: true,
        );
      }
      final file = File(path.join(
        Collection.instance.albumArtDirectory.path,
        media.tracks.first.albumArtFileName,
      ));
      if (file.existsSync_()) {
        return ExtendedFileImageProvider(file);
      } else {
        final file = File(path.join(
          Collection.instance.albumArtDirectory.path,
          media.tracks.first.legacyAlbumArtFileName,
        ));
        if (file.existsSync_()) {
          return ExtendedFileImageProvider(file);
        } else {
          for (final name in kAlbumArtFileNames) {
            final file = File(path.join(
                path.basename(media.tracks.first.uri.toFilePath()), name));
            if (file.existsSync_()) {
              return ExtendedFileImageProvider(file);
            }
          }
        }
      }
    } else if (media is Artist) {
      if (Plugins.isExternalMedia(media.tracks.first.uri)) {
        return ExtendedNetworkImageProvider(
          Plugins.artwork(
            media.tracks.first.uri,
            small: small,
          ),
          cache: true,
        );
      }
      final file = File(path.join(
        Collection.instance.albumArtDirectory.path,
        media.tracks.first.albumArtFileName,
      ));
      if (file.existsSync_()) {
        return ExtendedFileImageProvider(file);
      } else {
        final file = File(path.join(
          Collection.instance.albumArtDirectory.path,
          media.tracks.first.legacyAlbumArtFileName,
        ));
        if (file.existsSync_()) {
          return ExtendedFileImageProvider(file);
        } else {
          for (final name in kAlbumArtFileNames) {
            final file = File(path.join(
                path.basename(media.tracks.first.uri.toFilePath()), name));
            if (file.existsSync_()) {
              return ExtendedFileImageProvider(file);
            }
          }
        }
      }
    }
    return ExtendedFileImageProvider(Collection.instance.unknownAlbumArt);
  }() as ImageProvider;
  if (small && result is ExtendedNetworkImageProvider) {
    return result;
  } else if (small) {
    return ResizeImage.resizeIfNeeded(200, 200, result);
  }
  return result;
}

extension DurationExtension on Duration {
  String get label {
    int minutes = inSeconds ~/ 60;
    String seconds = inSeconds - (minutes * 60) > 9
        ? '${inSeconds - (minutes * 60)}'
        : '0${inSeconds - (minutes * 60)}';
    return '$minutes:$seconds';
  }
}
