/* 
 *  This file is part of Harmonoid (https://github.com/harmonoid/harmonoid).
 *  
 *  Harmonoid is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *  
 *  Harmonoid is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU General Public License for more details.
 *  
 *  You should have received a copy of the GNU General Public License
 *  along with Harmonoid. If not, see <https://www.gnu.org/licenses/>.
 * 
 *  Copyright 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
 */

import 'dart:io';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/utils/dimensions.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:share_plus/share_plus.dart';

final isDesktop = Platform.isWindows || Platform.isLinux || Platform.isMacOS;
final isMobile = Platform.isAndroid || Platform.isIOS;
final tileMargin = isDesktop ? kDesktopTileMargin : kMobileTileMargin;

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
            mainAxisAlignment: MainAxisAlignment.center,
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
          mainAxisAlignment: MainAxisAlignment.center,
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
        leading: Icon(isDesktop ? FluentIcons.delete_16_regular : Icons.delete),
        title: Text(
          language.DELETE,
          style: isDesktop ? Theme.of(context).textTheme.headline4 : null,
        ),
      ),
    ),
    PopupMenuItem<int>(
      padding: EdgeInsets.zero,
      value: 1,
      child: ListTile(
        leading: Icon(isDesktop ? FluentIcons.share_16_regular : Icons.share),
        title: Text(
          language.SHARE,
          style: isDesktop ? Theme.of(context).textTheme.headline4 : null,
        ),
      ),
    ),
    PopupMenuItem<int>(
      padding: EdgeInsets.zero,
      value: 2,
      child: ListTile(
        leading:
            Icon(isDesktop ? FluentIcons.list_16_regular : Icons.queue_music),
        title: Text(
          language.ADD_TO_PLAYLIST,
          style: isDesktop ? Theme.of(context).textTheme.headline4 : null,
        ),
      ),
    ),
    PopupMenuItem<int>(
      padding: EdgeInsets.zero,
      value: 3,
      child: ListTile(
        leading: Icon(
            isDesktop ? FluentIcons.music_note_2_16_regular : Icons.music_note),
        title: Text(
          language.ADD_TO_NOW_PLAYING,
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
              language.COLLECTION_TRACK_DELETE_DIALOG_HEADER,
              style: Theme.of(subContext).textTheme.headline1,
            ),
            content: Text(
              language.COLLECTION_TRACK_DELETE_DIALOG_BODY.replaceAll(
                'NAME',
                track.trackName!,
              ),
              style: Theme.of(subContext).textTheme.headline3,
            ),
            actions: [
              MaterialButton(
                textColor: Theme.of(context).primaryColor,
                onPressed: () async {
                  await collection.delete(track);
                  Navigator.of(subContext).pop();
                  if (recursivelyPopNavigatorOnDeleteIf != null) {
                    if (recursivelyPopNavigatorOnDeleteIf()) {
                      while (Navigator.of(context).canPop())
                        Navigator.of(context).pop();
                    }
                  }
                },
                child: Text(language.YES),
              ),
              MaterialButton(
                textColor: Theme.of(context).primaryColor,
                onPressed: Navigator.of(subContext).pop,
                child: Text(language.NO),
              ),
            ],
          ),
        );
        break;
      case 1:
        Share.shareFiles(
          [track.filePath!],
          subject: '${track.trackName} • ${track.albumName}',
        );
        break;
      case 2:
        showDialog(
          context: context,
          builder: (subContext) => AlertDialog(
            contentPadding: EdgeInsets.zero,
            actionsPadding: EdgeInsets.zero,
            title: Text(
              language.PLAYLIST_ADD_DIALOG_TITLE,
              style: Theme.of(subContext).textTheme.headline1?.copyWith(
                    fontSize: 20.0,
                  ),
            ),
            content: Container(
              width: MediaQuery.of(context).size.width > kHorizontalBreakpoint
                  ? 512.0
                  : 280.0,
              height: MediaQuery.of(context).size.width > kHorizontalBreakpoint
                  ? 480.0
                  : 280.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(24, 8, 0, 16),
                    child: Text(
                      language.PLAYLIST_ADD_DIALOG_BODY,
                      style: Theme.of(subContext).textTheme.headline3,
                    ),
                  ),
                  Divider(
                    height: 1.0,
                  ),
                  if (collection.playlists.isNotEmpty)
                    Container(
                      height: (MediaQuery.of(context).size.width >
                                  kHorizontalBreakpoint
                              ? 512.0
                              : 280.0) -
                          78.0,
                      width: MediaQuery.of(context).size.width >
                              kHorizontalBreakpoint
                          ? 512.0
                          : 280.0,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: collection.playlists.length,
                        itemBuilder: (context, index) => ListTile(
                          title: Text(
                            collection.playlists[index].playlistName!,
                            style: Theme.of(context).textTheme.headline4,
                          ),
                          leading: Icon(
                            Icons.queue_music,
                            size: Theme.of(context).iconTheme.size,
                            color: Theme.of(context).iconTheme.color,
                          ),
                          onTap: () async {
                            await collection.playlistAddTrack(
                              collection.playlists[index],
                              track,
                            );
                            Navigator.of(subContext).pop();
                          },
                        ),
                      ),
                    ),
                  if (collection.playlists.isEmpty)
                    Expanded(
                      child: Center(
                        child: Text(
                          'No playlists found.\nCreate some to see them there.',
                          style: Theme.of(context).textTheme.headline4,
                          textAlign: TextAlign.center,
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
                child: Text(language.CANCEL),
              ),
            ],
          ),
        );
        break;
      case 3:
        Playback.add(
          [
            track,
          ],
        );
        break;
    }
  }
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
}

extension DateTimeExtension on DateTime {
  get label =>
      '${day.toString().padLeft(2, '0')}-${month.toString().padLeft(2, '0')}-$year';
}
