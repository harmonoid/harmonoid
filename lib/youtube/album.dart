/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///
import 'dart:async';
import 'package:animations/animations.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:youtube_music/youtube_music.dart';
import 'package:extended_image/extended_image.dart';
import 'package:palette_generator/palette_generator.dart';

import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/dimensions.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/models/media.dart' as media;

class AlbumTile extends StatelessWidget {
  final Album album;
  const AlbumTile({
    Key? key,
    required this.album,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          if (album.tracks.isEmpty) {
            final result = await Future.wait([
              YouTubeMusic.album(album.id),
              precacheImage(
                ExtendedNetworkImageProvider(
                  album.thumbnails.values.skip(3).first,
                ),
                context,
              ),
            ]);
            (result.first as Album)
                .tracks
                .toList()
                .asMap()
                .forEach((i, element) {
              element.trackNumber = i + 1;
            });
            album.subtitle = (result.first as Album).subtitle;
            album.secondSubtitle = (result.first as Album).secondSubtitle;
            album.description = (result.first as Album).description;
            album.tracks.addAll((result.first as Album).tracks);
          }
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  FadeThroughTransition(
                fillColor: Colors.transparent,
                animation: animation,
                secondaryAnimation: secondaryAnimation,
                child: AlbumScreen(
                  album: album,
                ),
              ),
              transitionDuration: Duration(milliseconds: 300),
              reverseTransitionDuration: Duration(milliseconds: 300),
            ),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Divider(
              height: 1.0,
              indent: 80.0,
            ),
            Container(
              height: 64.0,
              alignment: Alignment.center,
              margin: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 12.0),
                  ExtendedImage(
                    image: NetworkImage(
                      album.thumbnails.values.first,
                    ),
                    height: 56.0,
                    width: 56.0,
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          album.albumName?.overflow,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: Theme.of(context).textTheme.headline2,
                        ),
                        const SizedBox(
                          height: 2.0,
                        ),
                        Text(
                          Language.instance.ALBUM_SINGLE +
                              ' • ' +
                              (album.albumArtistName ?? '') +
                              ' • ' +
                              (album.year ?? ''),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: Theme.of(context).textTheme.headline3,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Container(
                    width: 64.0,
                    height: 64.0,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AlbumScreen extends StatefulWidget {
  final Album album;
  final Iterable<Color>? palette;
  const AlbumScreen({
    Key? key,
    required this.album,
    this.palette,
  }) : super(key: key);
  AlbumScreenState createState() => AlbumScreenState();
}

class AlbumScreenState extends State<AlbumScreen>
    with SingleTickerProviderStateMixin {
  Color? color;
  Color? secondary;
  Track? hovered;
  bool reactToSecondaryPress = false;
  bool detailsVisible = false;
  bool detailsLoaded = false;
  ScrollController controller = ScrollController(initialScrollOffset: 136.0);

  @override
  void initState() {
    super.initState();
    widget.album.tracks.sort(
        (first, second) => first.trackNumber.compareTo(second.trackNumber));
    if (isDesktop) {
      Timer(
        Duration(milliseconds: 300),
        () {
          if (widget.palette == null) {
            PaletteGenerator.fromImageProvider(ExtendedNetworkImageProvider(
                    widget.album.thumbnails.values.first))
                .then((palette) {
              setState(() {
                color = palette.colors.first;
                secondary = palette.colors.last;
                detailsVisible = true;
              });
            });
          } else {
            setState(() {
              detailsVisible = true;
            });
          }
        },
      );
    }
    if (isMobile) {
      Timer(Duration(milliseconds: 100), () {
        this
            .controller
            .animateTo(
              0.0,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            )
            .then((_) {
          Timer(Duration(milliseconds: 50), () {
            setState(() {
              detailsLoaded = true;
            });
          });
        });
      });
      if (widget.palette != null) {
        color = widget.palette?.first;
        secondary = widget.palette?.last;
      }
      controller.addListener(() {
        if (controller.offset == 0.0) {
          setState(() {
            detailsVisible = true;
          });
        } else if (detailsVisible) {
          setState(() {
            detailsVisible = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return isDesktop
        ? Scaffold(
            body: Container(
              height: MediaQuery.of(context).size.height,
              child: Stack(
                children: [
                  TweenAnimationBuilder(
                    tween: ColorTween(
                      begin: Theme.of(context).appBarTheme.backgroundColor,
                      end: color == null
                          ? Theme.of(context).appBarTheme.backgroundColor
                          : color!,
                    ),
                    curve: Curves.easeOut,
                    duration: Duration(
                      milliseconds: 400,
                    ),
                    builder: (context, color, _) => DesktopAppBar(
                      height: MediaQuery.of(context).size.height / 2,
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
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        margin: EdgeInsets.only(top: 96.0, bottom: 4.0),
                        elevation: 4.0,
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: 12 / 6 * 720.0,
                            maxHeight: 720.0,
                          ),
                          width: MediaQuery.of(context).size.width - 136.0,
                          height: MediaQuery.of(context).size.height - 192.0,
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                flex: 5,
                                child: ClipRect(
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      TweenAnimationBuilder(
                                        tween: ColorTween(
                                          begin: Theme.of(context)
                                              .appBarTheme
                                              .backgroundColor,
                                          end: color == null
                                              ? Theme.of(context).dividerColor
                                              : secondary!,
                                        ),
                                        curve: Curves.easeOut,
                                        duration: Duration(
                                          milliseconds: 600,
                                        ),
                                        builder: (context, color, _) =>
                                            Positioned.fill(
                                          child: Container(
                                            color: color as Color?,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(20.0),
                                        child: Hero(
                                          tag:
                                              'album_art_${widget.album.albumName}_${widget.album.albumArtistName}',
                                          child: Card(
                                            color: Colors.white,
                                            elevation: 4.0,
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: ExtendedImage(
                                                    image:
                                                        ExtendedNetworkImageProvider(
                                                      widget.album.thumbnails
                                                          .values
                                                          .skip(3)
                                                          .first,
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
                                                widget.album.albumName ?? '',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline1
                                                    ?.copyWith(fontSize: 24.0),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              SizedBox(height: 8.0),
                                              Text(
                                                '${widget.album.subtitle}\n${widget.album.secondSubtitle}\n${widget.album.description}',
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
                                                onPressed: () {},
                                                mini: true,
                                                child: Icon(
                                                  Icons.play_arrow,
                                                ),
                                                tooltip:
                                                    Language.instance.PLAY_NOW,
                                              ),
                                              SizedBox(
                                                width: 8.0,
                                              ),
                                              FloatingActionButton(
                                                heroTag: 'add_to_now_playing',
                                                onPressed: () {},
                                                mini: true,
                                                child: Icon(
                                                  Icons.queue_music,
                                                ),
                                                tooltip: Language.instance
                                                    .ADD_TO_NOW_PLAYING,
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
                                                        Language.instance
                                                            .TRACK_SINGLE,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .headline2,
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    width: 56.0,
                                                    height: 56.0,
                                                  ),
                                                ],
                                              ),
                                              Divider(height: 1.0),
                                            ] +
                                            (widget.album.tracks
                                                .map(
                                                  (track) => MouseRegion(
                                                    onEnter: (e) {
                                                      setState(() {
                                                        hovered = track;
                                                      });
                                                    },
                                                    onExit: (e) {
                                                      setState(() {
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
                                                                  .width,
                                                              MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height,
                                                            ),
                                                          ),
                                                          items:
                                                              trackPopupMenuItems(
                                                            context,
                                                          ),
                                                        );
                                                        await trackPopupMenuHandle(
                                                          context,
                                                          media.Track
                                                              .fromYouTubeMusicTrack(
                                                                  track),
                                                          result,
                                                          recursivelyPopNavigatorOnDeleteIf:
                                                              () => widget
                                                                  .album
                                                                  .tracks
                                                                  .isEmpty,
                                                        );
                                                      },
                                                      child: Material(
                                                        color:
                                                            Colors.transparent,
                                                        child: InkWell(
                                                          onTap: () {},
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
                                                                            () {},
                                                                        icon: Icon(
                                                                            Icons.play_arrow),
                                                                        splashRadius:
                                                                            20.0,
                                                                      )
                                                                    : Text(
                                                                        '${track.trackNumber}',
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
                                                                        .trackName,
                                                                    style: Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .headline4,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  ),
                                                                ),
                                                              ),
                                                              Container(
                                                                width: 72.0,
                                                                child:
                                                                    Container(
                                                                  height: 48.0,
                                                                  padding: EdgeInsets
                                                                      .only(
                                                                          right:
                                                                              8.0),
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  child: Text(
                                                                    track.duration
                                                                            ?.label ??
                                                                        '',
                                                                    style: Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .headline4,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                                .toList()),
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
        // TODO: Handle mobile layouts.
        : Container();
  }
}
