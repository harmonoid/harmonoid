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
import 'dart:ui';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:harmonoid/interface/changenotifiers.dart';
import 'package:harmonoid/utils/dimensions.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';
import 'package:share_plus/share_plus.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/constants/language.dart';
import 'package:url_launcher/url_launcher.dart';

class CollectionAlbumTab extends StatelessWidget {
  Widget build(BuildContext context) {
    double tileWidth = 156.0;
    double tileHeight = 156.0 + 58.0;
    int elementsPerRow =
        (MediaQuery.of(context).size.width.normalized - 16.0) ~/
            (tileWidth + 16.0);

    return Consumer<Collection>(
      builder: (context, collection, _) => collection.tracks.isNotEmpty
          ? CustomListView(
              padding: EdgeInsets.only(top: 16.0),
              children: tileGridListWidgets(
                context: context,
                tileHeight: tileHeight,
                tileWidth: tileWidth,
                elementsPerRow: elementsPerRow,
                subHeader: null,
                leadingSubHeader: null,
                widgetCount: collection.albums.length,
                leadingWidget: Container(),
                builder: (BuildContext context, int index) =>
                    CollectionAlbumTile(
                  height: tileHeight,
                  width: tileWidth,
                  album: collection.albums[index],
                ),
              ),
            )
          : Center(
              child: ExceptionWidget(
                height: 284.0,
                width: 420.0,
                margin: EdgeInsets.zero,
                title: language.NO_COLLECTION_TITLE,
                subtitle: language.NO_COLLECTION_SUBTITLE,
              ),
            ),
    );
  }
}

class CollectionAlbumTile extends StatelessWidget {
  final double height;
  final double width;
  final Album album;

  const CollectionAlbumTile({
    Key? key,
    required this.album,
    required this.height,
    required this.width,
  }) : super(key: key);

  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 4.0,
      margin: EdgeInsets.zero,
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
                  album: this.album,
                ),
              ),
            ),
          );
        },
        child: Container(
          height: this.height,
          width: this.width,
          child: Column(
            children: [
              ClipRect(
                child: ScaleOnHover(
                  child: Hero(
                    tag:
                        'album_art_${this.album.albumName}_${this.album.albumArtistName}',
                    child: Image.file(
                      this.album.albumArt,
                      fit: BoxFit.cover,
                      height: this.width,
                      width: this.width,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.0,
                  ),
                  width: this.width,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        this.album.albumName!,
                        style: Theme.of(context).textTheme.headline2,
                        textAlign: TextAlign.left,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Text(
                          '${this.album.albumArtistName} ${this.album.year != null ? ' • ' : ''} ${this.album.year ?? ''}',
                          style:
                              Theme.of(context).textTheme.headline3?.copyWith(
                                    fontSize: 12.0,
                                  ),
                          maxLines: 1,
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CollectionAlbum extends StatefulWidget {
  final Album? album;
  const CollectionAlbum({Key? key, required this.album}) : super(key: key);
  CollectionAlbumState createState() => CollectionAlbumState();
}

class CollectionAlbumState extends State<CollectionAlbum> {
  Color? color;
  Track? hovered;
  bool reactToSecondaryPress = false;

  @override
  void initState() {
    super.initState();
    PaletteGenerator.fromImageProvider(FileImage(widget.album!.albumArt))
        .then((palette) {
      this.setState(() {
        this.color = palette.colors.first;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery.of(context).size.width > kDesktopAppBarHeight
        ? Scaffold(
            body: Container(
              height: MediaQuery.of(context).size.height,
              child: Stack(
                children: [
                  DesktopAppBar(
                    height: MediaQuery.of(context).size.height / 3,
                    elevation: 4.0,
                    color: this.color,
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height -
                        kDesktopNowPlayingBarHeight,
                    width: MediaQuery.of(context).size.width,
                    child: Container(
                      alignment: Alignment.center,
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        margin: EdgeInsets.only(top: 96.0),
                        elevation: 4.0,
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: 1280.0,
                            maxHeight: 720.0,
                          ),
                          width: MediaQuery.of(context).size.width - 136.0,
                          height: MediaQuery.of(context).size.height - 256.0,
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                flex: 6,
                                child: Hero(
                                  tag:
                                      'album_art_${widget.album!.albumName}_${widget.album!.albumArtistName}',
                                  child: Stack(
                                    alignment: Alignment.bottomLeft,
                                    children: [
                                      Positioned.fill(
                                        child: Image.file(
                                          widget.album!.albumArt,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: ClipOval(
                                          child: Container(
                                            height: 36.0,
                                            width: 36.0,
                                            color: Colors.black54,
                                            child: Material(
                                              color: Colors.transparent,
                                              child: IconButton(
                                                onPressed: () {
                                                  launch(
                                                      'file:///${widget.album?.albumArt.path}');
                                                },
                                                icon: Icon(
                                                  Icons.image,
                                                  size: 20.0,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 7,
                                child: CustomListView(
                                  children: [
                                    Stack(
                                      alignment: Alignment.bottomRight,
                                      children: [
                                        Container(
                                          height: 156.0,
                                          padding: EdgeInsets.all(16.0),
                                          alignment: Alignment.centerLeft,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                widget.album!.albumName!,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline1
                                                    ?.copyWith(fontSize: 24.0),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              SizedBox(height: 8.0),
                                              Text(
                                                '${language.ARTIST}: ${widget.album!.albumArtistName}\n${language.YEAR}: ${widget.album!.year ?? 'Unknown Year'}\n${language.TRACK}: ${widget.album!.tracks.length}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline3,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(12.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              FloatingActionButton(
                                                heroTag: 'play_now',
                                                onPressed: () {
                                                  Playback.play(
                                                    index: 0,
                                                    tracks:
                                                        widget.album!.tracks,
                                                  );
                                                },
                                                mini: true,
                                                child: Icon(
                                                  Icons.play_arrow,
                                                ),
                                                tooltip: language.PLAY_NOW,
                                              ),
                                              SizedBox(
                                                width: 8.0,
                                              ),
                                              FloatingActionButton(
                                                heroTag: 'add_to_now_playing',
                                                onPressed: () {
                                                  Playback.add(
                                                    widget.album!.tracks,
                                                  );
                                                },
                                                mini: true,
                                                child: Icon(
                                                  Icons.queue_music,
                                                ),
                                                tooltip:
                                                    language.ADD_TO_NOW_PLAYING,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Divider(
                                      height: 1.0,
                                    ),
                                    LayoutBuilder(
                                      builder: (context, constraints) => Column(
                                        children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    width: 64.0,
                                                    height: 56.0,
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      '#',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .headline2,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Container(
                                                      height: 56.0,
                                                      padding: EdgeInsets.only(
                                                          right: 8.0),
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Text(
                                                        language.TRACK,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .headline2,
                                                      ),
                                                    ),
                                                    flex: 3,
                                                  ),
                                                  Expanded(
                                                    child: Container(
                                                      height: 56.0,
                                                      padding: EdgeInsets.only(
                                                          right: 8.0),
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Text(
                                                        language.ARTIST,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .headline2,
                                                      ),
                                                    ),
                                                    flex: 2,
                                                  ),
                                                  Container(
                                                    width: 48.0,
                                                  ),
                                                ],
                                              ),
                                              Divider(height: 1.0),
                                            ] +
                                            (widget.album!.tracks
                                                  ..sort((first, second) =>
                                                      (first.trackNumber ?? 1)
                                                          .compareTo((second
                                                                  .trackNumber ??
                                                              1))))
                                                .map(
                                                  (track) => MouseRegion(
                                                    onEnter: (e) {
                                                      this.setState(() {
                                                        hovered = track;
                                                      });
                                                    },
                                                    onExit: (e) {
                                                      this.setState(() {
                                                        hovered = null;
                                                      });
                                                    },
                                                    child: Listener(
                                                      onPointerDown: (e) {
                                                        reactToSecondaryPress = e
                                                                    .kind ==
                                                                PointerDeviceKind
                                                                    .mouse &&
                                                            e.buttons ==
                                                                kSecondaryMouseButton;
                                                      },
                                                      onPointerUp: (e) async {
                                                        if (!reactToSecondaryPress)
                                                          return;
                                                        final RenderObject?
                                                            overlay =
                                                            Overlay.of(context)!
                                                                .context
                                                                .findRenderObject();
                                                        var result =
                                                            await showMenu(
                                                          elevation: 4.0,
                                                          context: context,
                                                          position: RelativeRect.fromRect(
                                                              Offset(
                                                                      e.position
                                                                          .dx,
                                                                      e.position
                                                                          .dy) &
                                                                  Size.zero,
                                                              overlay!
                                                                  .semanticBounds),
                                                          items:
                                                              trackPopupMenuItems(
                                                            context,
                                                          ),
                                                        );
                                                        await trackPopupMenuHandle(
                                                          context,
                                                          track,
                                                          result,
                                                          recursivelyPopNavigatorOnDeleteIf:
                                                              () => widget
                                                                  .album!
                                                                  .tracks
                                                                  .isEmpty,
                                                        );
                                                      },
                                                      child: Material(
                                                        color:
                                                            Colors.transparent,
                                                        child: InkWell(
                                                          onTap: () {
                                                            Playback.play(
                                                              index: widget
                                                                  .album!.tracks
                                                                  .indexOf(
                                                                      track),
                                                              tracks: widget
                                                                  .album!
                                                                  .tracks,
                                                            );
                                                          },
                                                          child: Row(
                                                            children: [
                                                              Container(
                                                                width: 64.0,
                                                                height: 48.0,
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        right:
                                                                            8.0),
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                child: hovered ==
                                                                        track
                                                                    ? IconButton(
                                                                        onPressed:
                                                                            () {
                                                                          Playback
                                                                              .play(
                                                                            index:
                                                                                widget.album!.tracks.indexOf(track),
                                                                            tracks:
                                                                                widget.album!.tracks,
                                                                          );
                                                                        },
                                                                        icon: Icon(
                                                                            Icons.play_arrow),
                                                                        splashRadius:
                                                                            20.0,
                                                                      )
                                                                    : Text(
                                                                        '${track.trackNumber ?? 1}',
                                                                        style: Theme.of(context)
                                                                            .textTheme
                                                                            .headline4,
                                                                      ),
                                                              ),
                                                              Expanded(
                                                                child:
                                                                    Container(
                                                                  height: 48.0,
                                                                  padding: EdgeInsets
                                                                      .only(
                                                                          right:
                                                                              8.0),
                                                                  alignment:
                                                                      Alignment
                                                                          .centerLeft,
                                                                  child: Text(
                                                                    track
                                                                        .trackName!,
                                                                    style: Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .headline4,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  ),
                                                                ),
                                                                flex: 3,
                                                              ),
                                                              Expanded(
                                                                child:
                                                                    Container(
                                                                  height: 48.0,
                                                                  padding: EdgeInsets
                                                                      .only(
                                                                          right:
                                                                              8.0),
                                                                  alignment:
                                                                      Alignment
                                                                          .centerLeft,
                                                                  child: Text(
                                                                    track.trackArtistNames
                                                                            ?.join(', ') ??
                                                                        'Unknown Artist',
                                                                    style: Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .headline4,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  ),
                                                                ),
                                                                flex: 2,
                                                              ),
                                                              Container(
                                                                width: 48.0,
                                                                child: Text(
                                                                  Duration(
                                                                          milliseconds:
                                                                              track.trackDuration ?? 0)
                                                                      .label,
                                                                  style: Theme.of(
                                                                          context)
                                                                      .textTheme
                                                                      .headline4,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
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
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        : Container();
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
