/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'dart:io';
import 'dart:convert' as convert;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:harmonoid/state/now_playing_scroll_hider.dart';
import 'package:path/path.dart' as path;
import 'package:animations/animations.dart';
import 'package:libmpv/libmpv.dart' hide Media;
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:extended_image/extended_image.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

import 'package:harmonoid/main.dart';
import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/models/media.dart';
import 'package:harmonoid/interface/collection/album.dart';
import 'package:harmonoid/utils/dimensions.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/utils/file_system.dart';
import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/interface/collection/playlist.dart';
import 'package:harmonoid/interface/settings/version.dart';
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
  MainAxisAlignment mainAxisAlignment = MainAxisAlignment.center,
  bool showIncompleteRow = true,
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
  if (widgetCount % elementsPerRow != 0 && showIncompleteRow) {
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
    if (!NowPlayingScrollHider.instance.isHidden)
      PopupMenuItem<int>(
        padding: EdgeInsets.zero,
        child: SizedBox(height: 64.0),
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
        showAddToPlaylistDialog(context, track);
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

Future<void> checkVersionAndShowUpdateSnackbar(BuildContext context) async {
  if (kDebugMode) return;
  final response = await http.get(
      Uri.parse('https://api.github.com/repos/harmonoid/harmonoid/releases'));
  final body = convert.jsonDecode(response.body);
  final releases =
      body.map((release) => Release.fromJson(release)).toList().cast<Release>();
  if (kVersion != releases.first.tagName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '🎉 ${Language.instance.UPDATE_AVAILABLE.replaceAll('VERSION', releases.first.tagName)}',
        ),
        action: SnackBarAction(
          label: Language.instance.DOWNLOAD_UPDATE,
          textColor: Theme.of(context).primaryColor,
          onPressed: () async {
            await launch(releases.first.htmlUrl);
            // Show snackbar again since [onPressed] seems to cause dismissal.
            checkVersionAndShowUpdateSnackbar(context);
          },
        ),
        elevation: 4.0,
        margin: EdgeInsets.only(
          bottom: 16.0 + kDesktopNowPlayingBarHeight,
          left: 16.0,
          right: 16.0,
        ),
        behavior: SnackBarBehavior.floating,
        dismissDirection: DismissDirection.none,
        duration: Duration(days: 1),
      ),
    );
  }
}

Future<void> showAddToPlaylistDialog(BuildContext context, Track track) {
  if (isDesktop) {
    return showDialog(
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
                child: CustomListViewBuilder(
                  itemExtents: List.generate(
                    Collection.instance.playlists.length,
                    (index) => 64.0 + 9.0,
                  ),
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
  } else {
    return showModalBottomSheet(
      context: context,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 1.0,
        expand: false,
        builder: (context, controller) => ListView.builder(
          padding: EdgeInsets.zero,
          controller: controller,
          shrinkWrap: true,
          itemCount: Collection.instance.playlists.length,
          itemBuilder: (context, i) {
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.transparent,
                child: Icon(
                  Icons.playlist_add,
                  color: Theme.of(context).iconTheme.color,
                ),
              ),
              title: Text(Collection.instance.playlists[i].name),
              subtitle: Text(
                Language.instance.N_TRACKS.replaceAll(
                  'N',
                  Collection.instance.playlists[i].tracks.length.toString(),
                ),
              ),
              onTap: () async {
                await Collection.instance.playlistAddTrack(
                  Collection.instance.playlists[i],
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
    contentPadding: isDesktop
        ? EdgeInsets.only(
            left: 10.0, bottom: trailingIcon == null ? 10.0 : 10.0)
        : null,
    hintText: hintText,
    hintStyle: isDesktop
        ? Theme.of(context).textTheme.headline3?.copyWith(
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.black.withOpacity(0.6)
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
      if (Plugins.isWebMedia(media.uri)) {
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
        try {
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
        } catch (_) {}
      }
    } else if (media is Album) {
      if (Plugins.isWebMedia(media.tracks.first.uri)) {
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
        try {
          final file = File(path.join(
            Collection.instance.albumArtDirectory.path,
            media.tracks.first.legacyAlbumArtFileName,
          ));
          print(file.path);
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
        } catch (_) {}
      }
    } else if (media is Artist) {
      if (Plugins.isWebMedia(media.tracks.first.uri)) {
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
        try {
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
        } catch (_) {}
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
