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
 *  Copyright 2020-2021, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
 */

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/utils/dimensions.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:share_plus/share_plus.dart';

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
  double tileMargin: kTileMargin,
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
        new Container(
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
      new Container(
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

List<PopupMenuItem<int>> trackPopupMenuItems(BuildContext context) {
  return [
    PopupMenuItem<int>(
      padding: EdgeInsets.zero,
      value: 0,
      child: ListTile(
        leading: Icon(FluentIcons.delete_16_regular),
        title: Text(
          language.DELETE,
          style: Theme.of(context).textTheme.headline4,
        ),
      ),
    ),
    PopupMenuItem<int>(
      padding: EdgeInsets.zero,
      value: 1,
      child: ListTile(
        leading: Icon(FluentIcons.share_16_regular),
        title: Text(
          language.SHARE,
          style: Theme.of(context).textTheme.headline4,
        ),
      ),
    ),
    PopupMenuItem<int>(
      padding: EdgeInsets.zero,
      value: 2,
      child: ListTile(
        leading: Icon(FluentIcons.list_16_regular),
        title: Text(
          language.ADD_TO_PLAYLIST,
          style: Theme.of(context).textTheme.headline4,
        ),
      ),
    ),
    PopupMenuItem<int>(
      padding: EdgeInsets.zero,
      value: 3,
      child: ListTile(
        leading: Icon(FluentIcons.music_note_2_16_regular),
        title: Text(
          language.ADD_TO_NOW_PLAYING,
          style: Theme.of(context).textTheme.headline4,
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
          builder: (subContext) => FractionallyScaledWidget(
            child: AlertDialog(
              title: Text(
                language.COLLECTION_ALBUM_TRACK_DELETE_DIALOG_HEADER,
                style: Theme.of(subContext).textTheme.headline1,
              ),
              content: Text(
                language.COLLECTION_ALBUM_TRACK_DELETE_DIALOG_BODY,
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
          builder: (subContext) => FractionallyScaledWidget(
            child: AlertDialog(
              contentPadding: EdgeInsets.zero,
              actionsPadding: EdgeInsets.zero,
              title: Text(
                language.PLAYLIST_ADD_DIALOG_TITLE,
                style: Theme.of(subContext).textTheme.headline1,
              ),
              content: Container(
                height: 280,
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
                    Container(
                      height: 236,
                      width: 280,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: collection.playlists.length,
                        itemBuilder: (context, playlistIndex) {
                          return ListTile(
                            title: Text(
                              collection.playlists[playlistIndex].playlistName!,
                              style: Theme.of(context).textTheme.headline2,
                            ),
                            leading: Icon(
                              Icons.queue_music,
                              size: Theme.of(context).iconTheme.size,
                              color: Theme.of(context).iconTheme.color,
                            ),
                            onTap: () async {
                              await collection.playlistAddTrack(
                                collection.playlists[playlistIndex],
                                track,
                              );
                              Navigator.of(subContext).pop();
                            },
                          );
                        },
                      ),
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
