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
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';
import 'package:share_plus/share_plus.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/constants/language.dart';

class CollectionAlbumTab extends StatelessWidget {
  static const velocity = 60;

  Widget build(BuildContext context) {
    int elementsPerRow =
        MediaQuery.of(context).size.width.normalized ~/ (156 + 8);
    double tileWidth = (MediaQuery.of(context).size.width.normalized -
            16 -
            (elementsPerRow - 1) * 8) /
        elementsPerRow;
    double tileHeight = tileWidth * 246.0 / 156;

    return Consumer<Collection>(
      builder: (context, collection, _) => collection.tracks.isNotEmpty
          ? Container(
              child: CustomListView(
                children: tileGridListWidgets(
                  context: context,
                  tileHeight: tileHeight,
                  tileWidth: tileWidth,
                  elementsPerRow: elementsPerRow,
                  subHeader: language!.STRING_LOCAL_OTHER_SUBHEADER_ALBUM,
                  leadingSubHeader: language!.STRING_LOCAL_TOP_SUBHEADER_ALBUM,
                  widgetCount: collection.albums.length,
                  leadingWidget: LeadingCollectionAlbumTile(
                    height: tileWidth,
                  ),
                  builder: (BuildContext context, int index) =>
                      CollectionAlbumTile(
                    height: tileHeight,
                    width: tileWidth,
                    album: collection.albums[index],
                  ),
                ),
              ),
            )
          : Center(
              child: ExceptionWidget(
                height: 256.0,
                width: 420.0,
                margin: EdgeInsets.zero,
                title: language!.STRING_NO_COLLECTION_TITLE,
                subtitle: language!.STRING_NO_COLLECTION_SUBTITLE,
              ),
            ),
    );
  }
}

class CollectionAlbumTile extends StatelessWidget {
  final double? height;
  final double? width;
  final Album album;

  const CollectionAlbumTile({
    Key? key,
    required this.album,
    required this.height,
    required this.width,
  }) : super(key: key);

  Widget build(BuildContext context) {
    return Container(
      height: this.height! - 2.0,
      width: this.width! - 2.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(8.0),
        ),
        border:
            Border.all(color: Theme.of(context).dividerColor.withOpacity(0.12)),
        color: Theme.of(context).cardColor,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.all(
            Radius.circular(8.0),
          ),
          onTap: () {
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    FadeThroughTransition(
                  fillColor: Colors.transparent,
                  animation: animation,
                  secondaryAnimation: secondaryAnimation,
                  child: CollectionAlbum(
                    album: this.album,
                  ),
                ),
              ),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Hero(
                tag:
                    'album_art_${this.album.albumName}_${this.album.albumArtistName}',
                child: ClipRRect(
                  borderRadius: BorderRadius.all(
                    Radius.circular(8.0),
                  ),
                  child: Image.file(
                    this.album.albumArt,
                    fit: BoxFit.cover,
                    height: this.width! - 2.0,
                    width: this.width! - 2.0,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: 8, right: 8, bottom: 8),
                height: this.height! - this.width! - 2.0,
                width: this.width! - 2.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        this.album.albumName!,
                        style: Theme.of(context).textTheme.headline2,
                        textAlign: TextAlign.left,
                        maxLines: 2,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Text(
                        '${this.album.albumArtistName}\n(${this.album.year ?? 'Unknown Year'})',
                        style: Theme.of(context).textTheme.headline3,
                        maxLines: 2,
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LeadingCollectionAlbumTile extends StatelessWidget {
  final double height;

  const LeadingCollectionAlbumTile({Key? key, required this.height})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (Provider.of<Collection>(context, listen: false).lastAlbum == null)
      return Container();
    return Container(
      decoration: BoxDecoration(
        border:
            Border.all(color: Theme.of(context).dividerColor.withOpacity(0.12)),
        borderRadius: BorderRadius.circular(8.0),
      ),
      margin: EdgeInsets.only(left: 8, right: 8, bottom: 4.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    FadeThroughTransition(
                  fillColor: Colors.transparent,
                  animation: animation,
                  secondaryAnimation: secondaryAnimation,
                  child: CollectionAlbum(
                    album: Provider.of<Collection>(context, listen: false)
                        .lastAlbum!,
                  ),
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(8.0),
          child: Container(
            height: this.height - 2.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: Theme.of(context).cardColor,
            ),
            width: MediaQuery.of(context).size.width.normalized - 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image(
                    image: FileImage(
                        Provider.of<Collection>(context, listen: false)
                            .lastAlbum!
                            .albumArt),
                    fit: BoxFit.cover,
                    height: this.height - 2.0,
                    width: this.height - 2.0,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 8, right: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        Provider.of<Collection>(context, listen: false)
                            .lastAlbum!
                            .albumName!,
                        style: Theme.of(context).textTheme.headline1,
                        textAlign: TextAlign.start,
                        maxLines: 2,
                      ),
                      Text(
                        Provider.of<Collection>(context, listen: false)
                            .lastAlbum!
                            .albumArtistName!,
                        style: Theme.of(context).textTheme.headline3,
                        textAlign: TextAlign.start,
                        maxLines: 1,
                      ),
                      Text(
                        '(${Provider.of<Collection>(context, listen: false).lastAlbum!.year ?? 'Unknown Year'})',
                        style: Theme.of(context).textTheme.headline3,
                        textAlign: TextAlign.start,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CollectionAlbum extends StatelessWidget {
  final Album? album;
  const CollectionAlbum({Key? key, required this.album}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<Collection>(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
        ),
        height:
            MediaQuery.of(context).size.width.normalized > HORIZONTAL_BREAKPOINT
                ? MediaQuery.of(context).size.height.normalized
                : MediaQuery.of(context).size.width.normalized + 128.0,
        width: MediaQuery.of(context).size.width.normalized / 3,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                NavigatorPopButton(),
                SizedBox(
                  width: 24.0,
                ),
                Text(
                  language!.STRING_ALBUM_SINGLE,
                  style: Theme.of(context).textTheme.headline1,
                )
              ],
            ),
            Divider(
              height: 1.0,
              thickness: 1.0,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.center,
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: 256.0,
                            maxHeight: 256.0,
                          ),
                          child: Hero(
                            tag:
                                'album_art_${this.album!.albumName}_${this.album!.albumArtistName}',
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12.0),
                              child: Image.file(
                                this.album!.albumArt,
                                fit: BoxFit.contain,
                                alignment: Alignment.center,
                                filterQuality: FilterQuality.low,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 18.0),
                    Container(
                      margin: EdgeInsets.all(8.0),
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withOpacity(0.04)
                            : Colors.black.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Column(
                        children: [
                          Text(
                            this.album!.albumName!,
                            style: Theme.of(context).textTheme.headline1,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4.0),
                          Text(
                            '${this.album!.albumArtistName}\n(${this.album!.year ?? 'Unknown Year'})',
                            style: Theme.of(context).textTheme.headline3,
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 18.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              Theme.of(context).primaryColor,
                            ),
                          ),
                          onPressed: () {
                            Playback.play(
                              index: 0,
                              tracks: album!.tracks,
                            );
                          },
                          child: Text(
                            language!.STRING_PLAY_NOW,
                          ),
                        ),
                        SizedBox(
                          width: 12.0,
                        ),
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              Theme.of(context).primaryColor,
                            ),
                          ),
                          onPressed: () {
                            Playback.add(album!.tracks);
                          },
                          child: Text(
                            language!.STRING_ADD_TO_NOW_PLAYING,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      builder: (context, collection, child) => Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) => Container(
            height: MediaQuery.of(context).size.height.normalized,
            width: MediaQuery.of(context).size.width.normalized,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                constraints.maxWidth > HORIZONTAL_BREAKPOINT
                    ? child!
                    : Container(),
                Expanded(
                  child: CustomListView(
                    children: <Widget>[
                          constraints.maxWidth > HORIZONTAL_BREAKPOINT
                              ? Container()
                              : child!,
                          SubHeader(
                            language!.STRING_LOCAL_ALBUM_VIEW_TRACKS_SUBHEADER,
                          ),
                        ] +
                        (this.album!.tracks
                              ..sort((first, second) => (first.trackNumber ?? 1)
                                  .compareTo(second.trackNumber ?? 1)))
                            .map(
                              (Track track) => Container(
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                                child: new Material(
                                  color: Colors.transparent,
                                  child: new ListTile(
                                    onTap: () async {
                                      await Playback.play(
                                        index:
                                            this.album!.tracks.indexOf(track),
                                        tracks: this.album!.tracks,
                                      );
                                    },
                                    title: Text(
                                      track.trackName!,
                                      overflow: TextOverflow.fade,
                                      maxLines: 1,
                                      softWrap: false,
                                    ),
                                    subtitle: Text(
                                      (track.trackDuration != null
                                              ? (Duration(
                                                          milliseconds: track
                                                              .trackDuration!)
                                                      .label +
                                                  ' • ')
                                              : '0:00 • ') +
                                          track.trackArtistNames!.join(', '),
                                      overflow: TextOverflow.fade,
                                      maxLines: 1,
                                      softWrap: false,
                                    ),
                                    leading: CircleAvatar(
                                      child: Text('${track.trackNumber ?? 1}'),
                                      backgroundImage:
                                          FileImage(this.album!.albumArt),
                                    ),
                                    trailing: ContextMenuButton(
                                      color: Theme.of(context)
                                          .appBarTheme
                                          .backgroundColor,
                                      elevation: 0,
                                      onSelected: (dynamic index) {
                                        switch (index) {
                                          case 0:
                                            {
                                              showDialog(
                                                context: context,
                                                builder: (subContext) =>
                                                    FractionallyScaledWidget(
                                                  child: AlertDialog(
                                                    backgroundColor:
                                                        Theme.of(context)
                                                            .appBarTheme
                                                            .backgroundColor,
                                                    title: Text(
                                                      language!
                                                          .STRING_LOCAL_ALBUM_VIEW_TRACK_DELETE_DIALOG_HEADER,
                                                      style:
                                                          Theme.of(subContext)
                                                              .textTheme
                                                              .headline1,
                                                    ),
                                                    content: Text(
                                                      language!
                                                          .STRING_LOCAL_ALBUM_VIEW_TRACK_DELETE_DIALOG_BODY,
                                                      style:
                                                          Theme.of(subContext)
                                                              .textTheme
                                                              .headline5,
                                                    ),
                                                    actions: [
                                                      MaterialButton(
                                                        textColor:
                                                            Theme.of(context)
                                                                .primaryColor,
                                                        onPressed: () async {
                                                          Navigator.of(
                                                                  subContext)
                                                              .pop();
                                                          await collection
                                                              .delete(track);
                                                          if (album!
                                                              .tracks.isEmpty) {
                                                            while (Navigator.of(
                                                                    context)
                                                                .canPop())
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                          }
                                                        },
                                                        child: Text(language!
                                                            .STRING_YES),
                                                      ),
                                                      MaterialButton(
                                                        textColor:
                                                            Theme.of(context)
                                                                .primaryColor,
                                                        onPressed: Navigator.of(
                                                                subContext)
                                                            .pop,
                                                        child: Text(language!
                                                            .STRING_NO),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }
                                            break;
                                          case 1:
                                            {
                                              Share.shareFiles(
                                                [track.filePath!],
                                                subject:
                                                    '${track.trackName} - ${track.albumName}.',
                                              );
                                            }
                                            break;
                                          case 2:
                                            {
                                              showDialog(
                                                context: context,
                                                builder: (subContext) =>
                                                    FractionallyScaledWidget(
                                                  child: AlertDialog(
                                                    backgroundColor:
                                                        Theme.of(context)
                                                            .appBarTheme
                                                            .backgroundColor,
                                                    contentPadding:
                                                        EdgeInsets.zero,
                                                    actionsPadding:
                                                        EdgeInsets.zero,
                                                    title: Text(
                                                      language!
                                                          .STRING_PLAYLIST_ADD_DIALOG_TITLE,
                                                      style:
                                                          Theme.of(subContext)
                                                              .textTheme
                                                              .headline1,
                                                    ),
                                                    content: Container(
                                                      height: 280,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    left: 24,
                                                                    top: 8,
                                                                    bottom: 16),
                                                            child: Text(
                                                              language!
                                                                  .STRING_PLAYLIST_ADD_DIALOG_BODY,
                                                              style: Theme.of(
                                                                      subContext)
                                                                  .textTheme
                                                                  .headline3,
                                                            ),
                                                          ),
                                                          Container(
                                                            height: 236,
                                                            width: 280,
                                                            child: ListView
                                                                .builder(
                                                              shrinkWrap: true,
                                                              itemCount:
                                                                  collection
                                                                      .playlists
                                                                      .length,
                                                              itemBuilder: (BuildContext
                                                                          context,
                                                                      int playlistIndex) =>
                                                                  ListTile(
                                                                title: Text(
                                                                    collection
                                                                        .playlists[
                                                                            playlistIndex]
                                                                        .playlistName!,
                                                                    style: Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .headline4),
                                                                leading: Icon(
                                                                  Icons
                                                                      .queue_music,
                                                                  size: Theme.of(
                                                                          context)
                                                                      .iconTheme
                                                                      .size,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .iconTheme
                                                                      .color,
                                                                ),
                                                                onTap:
                                                                    () async {
                                                                  await collection
                                                                      .playlistAddTrack(
                                                                    collection
                                                                            .playlists[
                                                                        playlistIndex],
                                                                    track,
                                                                  );
                                                                  Navigator.of(
                                                                          subContext)
                                                                      .pop();
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    actions: [
                                                      MaterialButton(
                                                        textColor:
                                                            Theme.of(context)
                                                                .primaryColor,
                                                        onPressed: Navigator.of(
                                                                subContext)
                                                            .pop,
                                                        child: Text(language!
                                                            .STRING_CANCEL),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }
                                            break;
                                          case 3:
                                            Playback.add(
                                              [
                                                track,
                                              ],
                                            );
                                            break;
                                        }
                                      },
                                      icon: Icon(
                                        FluentIcons.more_vertical_20_regular,
                                        color:
                                            Theme.of(context).iconTheme.color,
                                        size: 20.0,
                                      ),
                                      tooltip: language!.STRING_OPTIONS,
                                      itemBuilder: (_) => <PopupMenuEntry>[
                                        PopupMenuItem(
                                          value: 0,
                                          child: Text(
                                            language!.STRING_DELETE,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline4,
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: 1,
                                          child: Text(
                                            language!.STRING_SHARE,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline4,
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: 2,
                                          child: Text(
                                            language!.STRING_ADD_TO_PLAYLIST,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline4,
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: 3,
                                          child: Text(
                                            language!.STRING_ADD_TO_NOW_PLAYING,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

extension on Duration {
  String get label {
    int minutes = inSeconds ~/ 60;
    String seconds = inSeconds - (minutes * 60) > 9
        ? '${inSeconds - (minutes * 60)}'
        : '0${inSeconds - (minutes * 60)}';
    return '$minutes:$seconds';
  }
}
