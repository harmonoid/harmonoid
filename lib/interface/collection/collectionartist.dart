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

import 'dart:math';
import 'dart:ui';
import 'dart:async';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:harmonoid/interface/collection/collectionalbum.dart';
import 'package:provider/provider.dart';
import 'package:palette_generator/palette_generator.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/utils/dimensions.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/constants/language.dart';

class CollectionArtistTab extends StatelessWidget {
  Widget build(BuildContext context) {
    int elementsPerRow =
        (MediaQuery.of(context).size.width.normalized - kTileMargin) ~/
            (kArtistTileWidth + kTileMargin);

    return Consumer<Collection>(
      builder: (context, collection, _) => collection.tracks.isNotEmpty
          ? CustomListView(
              padding: EdgeInsets.only(top: kTileMargin),
              children: tileGridListWidgets(
                context: context,
                tileHeight: kArtistTileHeight,
                tileWidth: kArtistTileWidth,
                elementsPerRow: elementsPerRow,
                subHeader: null,
                leadingSubHeader: null,
                widgetCount: collection.artists.length,
                leadingWidget: Container(),
                builder: (BuildContext context, int index) =>
                    CollectionArtistTile(
                  height: kArtistTileHeight,
                  width: kArtistTileWidth,
                  artist: collection.artists[index],
                ),
              ),
            )
          : Center(
              child: ExceptionWidget(
                height: 256.0,
                width: 420.0,
                margin: EdgeInsets.zero,
                title: language.NO_COLLECTION_TITLE,
                subtitle: language.NO_COLLECTION_SUBTITLE,
              ),
            ),
    );
  }
}

class CollectionArtistTile extends StatelessWidget {
  final double height;
  final double width;
  final Artist artist;
  const CollectionArtistTile({
    Key? key,
    required this.height,
    required this.width,
    required this.artist,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kArtistTileHeight,
      width: kArtistTileWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Hero(
            tag: 'artist_art_${this.artist.artistName}',
            child: Card(
              clipBehavior: Clip.antiAlias,
              margin: EdgeInsets.zero,
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  kArtistTileWidth / 2.0,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipOval(
                    child: Image.file(
                      artist.tracks.last.albumArt,
                      height: kArtistTileWidth - 8.0,
                      width: kArtistTileWidth - 8.0,
                    ),
                  ),
                  Material(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        kArtistTileWidth / 2.0,
                      ),
                    ),
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    FadeThroughTransition(
                              animation: animation,
                              secondaryAnimation: secondaryAnimation,
                              child: CollectionArtist(
                                artist: artist,
                              ),
                            ),
                            transitionDuration: Duration(milliseconds: 400),
                            reverseTransitionDuration:
                                Duration(milliseconds: 400),
                          ),
                        );
                      },
                      child: Container(
                        height: kArtistTileWidth,
                        width: kArtistTileWidth,
                        padding: EdgeInsets.all(4.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Spacer(),
          Text(
            this.artist.artistName!,
            style: Theme.of(context).textTheme.headline2,
            textAlign: TextAlign.left,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class CollectionArtist extends StatefulWidget {
  final Artist artist;

  const CollectionArtist({Key? key, required this.artist}) : super(key: key);
  CollectionArtistState createState() => CollectionArtistState();
}

class CollectionArtistState extends State<CollectionArtist> {
  Color? color;
  Track? hovered;
  bool reactToSecondaryPress = false;

  @override
  void initState() {
    super.initState();
    Timer(
      Duration(milliseconds: 500),
      () {
        PaletteGenerator.fromImageProvider(
                FileImage(widget.artist.tracks.last.albumArt))
            .then((palette) {
          this.setState(() {
            this.color = palette.colors.first;
          });
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery.of(context).size.width > kDesktopAppBarHeight
        ? Scaffold(
            body: Container(
              height: MediaQuery.of(context).size.height,
              child: Stack(
                children: [
                  TweenAnimationBuilder(
                    tween: ColorTween(
                      begin: Theme.of(context).appBarTheme.backgroundColor,
                      end: this.color == null
                          ? Theme.of(context).appBarTheme.backgroundColor
                          : this.color!,
                    ),
                    curve: Curves.easeOut,
                    duration: Duration(
                      milliseconds: 400,
                    ),
                    builder: (context, color, _) => DesktopAppBar(
                      height: MediaQuery.of(context).size.height / 3,
                      elevation: 4.0,
                      color: color as Color? ?? Colors.transparent,
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height -
                        kDesktopNowPlayingBarHeight,
                    width: MediaQuery.of(context).size.width,
                    child: Container(
                      alignment: Alignment.center,
                      child: Container(
                        margin: EdgeInsets.only(top: 72.0),
                        constraints: BoxConstraints(
                          maxWidth: 1280.0,
                          maxHeight: 720.0,
                        ),
                        width: MediaQuery.of(context).size.width - 136.0,
                        height: MediaQuery.of(context).size.height - 192.0,
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 6,
                              child: Column(
                                children: [
                                  Expanded(
                                    child: LayoutBuilder(
                                        builder: (context, constraints) {
                                      var dimension = min(
                                        constraints.maxWidth,
                                        constraints.maxHeight,
                                      );
                                      return SizedBox.square(
                                        dimension: dimension,
                                        child: Container(
                                          height: dimension,
                                          width: dimension,
                                          margin: EdgeInsets.all(24.0),
                                          alignment: Alignment.center,
                                          child: Hero(
                                            tag:
                                                'artist_art_${this.widget.artist.artistName}',
                                            child: Card(
                                              clipBehavior: Clip.antiAlias,
                                              margin: EdgeInsets.zero,
                                              elevation: 4.0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  (dimension - 48.0) / 2.0,
                                                ),
                                              ),
                                              child: Container(
                                                padding: EdgeInsets.all(4.0),
                                                width: dimension - 48.0,
                                                height: dimension - 48.0,
                                                child: ClipOval(
                                                  child: Image.file(
                                                    widget.artist.tracks.last
                                                        .albumArt,
                                                    fit: BoxFit.cover,
                                                    height: dimension - 56.0,
                                                    width: dimension - 56.0,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                  if (widget.artist.albums.length > 1)
                                    Container(
                                      height:
                                          kAlbumTileHeight + 3 * kTileMargin,
                                      child: Card(
                                        clipBehavior: Clip.antiAlias,
                                        elevation: 4.0,
                                        child: Stack(
                                          alignment: Alignment.centerRight,
                                          children: [
                                            CustomListView(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 8.0),
                                              scrollDirection: Axis.horizontal,
                                              children: widget.artist.albums
                                                  .map(
                                                    (album) => Container(
                                                      alignment:
                                                          Alignment.center,
                                                      margin: EdgeInsets.only(
                                                        left: 8.0,
                                                        right: 8.0,
                                                        bottom: kTileMargin,
                                                      ),
                                                      height: kAlbumTileHeight,
                                                      width: kAlbumTileWidth,
                                                      child:
                                                          CollectionAlbumTile(
                                                        album: album,
                                                        height:
                                                            kAlbumTileHeight,
                                                        width: kAlbumTileWidth,
                                                      ),
                                                    ),
                                                  )
                                                  .toList(),
                                            ),
                                            Container(
                                              width: 72.0,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.white
                                                        .withOpacity(0.0),
                                                    Colors.white,
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 7,
                              child: Card(
                                clipBehavior: Clip.antiAlias,
                                elevation: 4.0,
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
                                                widget.artist.artistName ??
                                                    'Unknown Artist',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline1
                                                    ?.copyWith(fontSize: 24.0),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              SizedBox(height: 8.0),
                                              Text(
                                                '${language.TRACK}: ${widget.artist.tracks.length}\n${language.ALBUM}: ${widget.artist.albums.length}',
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
                                                        widget.artist.tracks,
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
                                                    widget.artist.tracks,
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
                                                        language.TRACK_SINGLE,
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
                                                        language.ALBUM_SINGLE,
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
                                            widget.artist.tracks
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
                                                        var result =
                                                            await showMenu(
                                                          elevation: 4.0,
                                                          context: context,
                                                          position: RelativeRect
                                                              .fromRect(
                                                            Offset(
                                                                    e.position
                                                                        .dx,
                                                                    e.position
                                                                        .dy) &
                                                                Size(228.0,
                                                                    320.0),
                                                            Rect.fromLTWH(
                                                              0,
                                                              0,
                                                              MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width
                                                                  .normalized,
                                                              MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height
                                                                  .normalized,
                                                            ),
                                                          ),
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
                                                                  .artist
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
                                                                  .artist.tracks
                                                                  .indexOf(
                                                                      track),
                                                              tracks: widget
                                                                  .artist
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
                                                                                widget.artist.tracks.indexOf(track),
                                                                            tracks:
                                                                                widget.artist.tracks,
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
                                                                    track.albumName ??
                                                                        'Unknown Album',
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
                            ),
                          ],
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
