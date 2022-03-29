/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///
import 'dart:async';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ytm_client/ytm_client.dart';
import 'package:extended_image/extended_image.dart';
import 'package:palette_generator/palette_generator.dart';

import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/dimensions.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/models/media.dart' as media;
import 'package:harmonoid/web/track.dart';
import 'package:harmonoid/web/state/web.dart';

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
            await Future.wait([
              YTMClient.album(album),
              precacheImage(
                ExtendedNetworkImageProvider(
                  album.thumbnails.values.skip(3).first,
                ),
                context,
              ),
            ]);
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
                          album.albumName.overflow,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: Theme.of(context).textTheme.headline2,
                        ),
                        const SizedBox(
                          height: 2.0,
                        ),
                        Text(
                          [
                            Language.instance.ALBUM_SINGLE,
                            album.albumArtistName,
                            album.year
                          ].join(' • '),
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
  const AlbumScreen({
    Key? key,
    required this.album,
  }) : super(key: key);
  AlbumScreenState createState() => AlbumScreenState();
}

class AlbumScreenState extends State<AlbumScreen>
    with SingleTickerProviderStateMixin {
  Color? color;
  double elevation = 0.0;
  ScrollController controller = ScrollController(initialScrollOffset: 0.0);

  bool isDark(BuildContext context) =>
      (0.299 *
              (color?.red ??
                  (Theme.of(context).brightness == Brightness.dark
                      ? 0.0
                      : 255.0))) +
          (0.587 *
              (color?.green ??
                  (Theme.of(context).brightness == Brightness.dark
                      ? 0.0
                      : 255.0))) +
          (0.114 *
              (color?.blue ??
                  (Theme.of(context).brightness == Brightness.dark
                      ? 0.0
                      : 255.0))) <
      128.0;

  @override
  void initState() {
    super.initState();
    widget.album.tracks.sort(
        (first, second) => first.trackNumber.compareTo(second.trackNumber));
    if (isDesktop) {
      Timer(
        Duration(milliseconds: 300),
        () {
          PaletteGenerator.fromImageProvider(ExtendedNetworkImageProvider(
                  widget.album.thumbnails.values.first))
              .then((palette) {
            setState(() {
              color = palette.colors.first;
            });
          });
        },
      );
      controller.addListener(() {
        if (controller.offset.isZero) {
          setState(() {
            elevation = 0.0;
          });
        } else if (elevation == 0.0) {
          setState(() {
            elevation = 4.0;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isDesktop
        ? Scaffold(
            body: Container(
              height: MediaQuery.of(context).size.height,
              child: Stack(
                children: [
                  CustomListView(
                    controller: controller,
                    padding: EdgeInsets.only(
                        top: desktopTitleBarHeight + kDesktopAppBarHeight),
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
                          milliseconds: 300,
                        ),
                        builder: (context, color, _) => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Transform.translate(
                              offset: Offset(0, -8.0),
                              child: Material(
                                color: color as Color? ?? Colors.transparent,
                                elevation: 4.0,
                                borderRadius: BorderRadius.zero,
                                child: Container(
                                  height: 312.0,
                                  child: Row(
                                    children: [
                                      const SizedBox(width: 56.0),
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
                                                    height: 256.0,
                                                    width: 256.0,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 20.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                widget.album.albumName,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline1
                                                    ?.copyWith(
                                                      fontSize: 24.0,
                                                      color: isDark(context)
                                                          ? Colors.white
                                                          : Colors.black,
                                                    ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              SizedBox(height: 8.0),
                                              Text(
                                                '${widget.album.subtitle}\n${widget.album.secondSubtitle}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline3
                                                    ?.copyWith(
                                                      color: isDark(context)
                                                          ? Colors.white70
                                                          : Colors.black87,
                                                    ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              SizedBox(height: 8.0),
                                              Expanded(
                                                child: CustomListView(
                                                  padding: EdgeInsets.only(
                                                      right: 8.0),
                                                  children: [
                                                    if (widget.album.description
                                                        .isNotEmpty)
                                                      ReadMoreText(
                                                        '${widget.album.description}',
                                                        trimLines: 6,
                                                        trimMode: TrimMode.Line,
                                                        trimExpandedText:
                                                            Language
                                                                .instance.LESS,
                                                        trimCollapsedText:
                                                            Language
                                                                .instance.MORE,
                                                        colorClickableText:
                                                            Theme.of(context)
                                                                .primaryColor,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .headline3
                                                            ?.copyWith(
                                                              color: isDark(
                                                                      context)
                                                                  ? Colors
                                                                      .white70
                                                                  : Colors
                                                                      .black87,
                                                            ),
                                                      ),
                                                    const SizedBox(
                                                        height: 12.0),
                                                    ButtonBar(
                                                      buttonPadding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 8.0),
                                                      alignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        ElevatedButton.icon(
                                                          onPressed: () {
                                                            Web.instance.open(
                                                                widget.album
                                                                    .tracks);
                                                          },
                                                          style: ButtonStyle(
                                                            elevation:
                                                                MaterialStateProperty
                                                                    .all(0.0),
                                                            backgroundColor:
                                                                MaterialStateProperty
                                                                    .all(isDark(
                                                                            context)
                                                                        ? Colors
                                                                            .white
                                                                        : Colors
                                                                            .black87),
                                                            padding: MaterialStateProperty
                                                                .all(EdgeInsets
                                                                    .all(12.0)),
                                                          ),
                                                          icon: Icon(
                                                            Icons.play_arrow,
                                                            color: !isDark(
                                                                    context)
                                                                ? Colors.white
                                                                : Colors
                                                                    .black87,
                                                          ),
                                                          label: Text(
                                                            Language.instance
                                                                .PLAY_NOW
                                                                .toUpperCase(),
                                                            style: TextStyle(
                                                              fontSize: 12.0,
                                                              color: !isDark(
                                                                      context)
                                                                  ? Colors.white
                                                                  : Colors
                                                                      .black87,
                                                              letterSpacing:
                                                                  -0.1,
                                                            ),
                                                          ),
                                                        ),
                                                        OutlinedButton.icon(
                                                          onPressed: () {
                                                            Collection.instance
                                                                .playlistCreate(
                                                              media.Playlist(
                                                                id: widget
                                                                    .album
                                                                    .albumName
                                                                    .hashCode,
                                                                name: widget
                                                                    .album
                                                                    .albumName,
                                                              )..tracks.addAll(widget
                                                                  .album.tracks
                                                                  .map((e) => media
                                                                          .Track
                                                                      .fromWebTrack(
                                                                          e.toJson()))),
                                                            );
                                                          },
                                                          style: OutlinedButton
                                                              .styleFrom(
                                                            primary:
                                                                Colors.white,
                                                            side: BorderSide(
                                                                color: isDark(
                                                                        context)
                                                                    ? Colors
                                                                        .white
                                                                    : Colors
                                                                        .black87),
                                                            padding:
                                                                EdgeInsets.all(
                                                                    12.0),
                                                          ),
                                                          icon: Icon(
                                                            Icons.playlist_add,
                                                            color: isDark(
                                                                    context)
                                                                ? Colors.white
                                                                : Colors
                                                                    .black87,
                                                          ),
                                                          label: Text(
                                                            Language.instance
                                                                .SAVE_AS_PLAYLIST
                                                                .toUpperCase(),
                                                            style: TextStyle(
                                                              fontSize: 12.0,
                                                              color: isDark(
                                                                      context)
                                                                  ? Colors.white
                                                                  : Colors
                                                                      .black87,
                                                              letterSpacing:
                                                                  -0.1,
                                                            ),
                                                          ),
                                                        ),
                                                        OutlinedButton.icon(
                                                          onPressed: () {
                                                            launch(
                                                                'https://music.youtube.com/browse/${widget.album.id}');
                                                          },
                                                          style: OutlinedButton
                                                              .styleFrom(
                                                            primary:
                                                                Colors.white,
                                                            side: BorderSide(
                                                                color: isDark(
                                                                        context)
                                                                    ? Colors
                                                                        .white
                                                                    : Colors
                                                                        .black87),
                                                            padding:
                                                                EdgeInsets.all(
                                                                    12.0),
                                                          ),
                                                          icon: Icon(
                                                            Icons.open_in_new,
                                                            color: isDark(
                                                                    context)
                                                                ? Colors.white
                                                                : Colors
                                                                    .black87,
                                                          ),
                                                          label: Text(
                                                            Language.instance
                                                                .OPEN_IN_BROWSER
                                                                .toUpperCase(),
                                                            style: TextStyle(
                                                              fontSize: 12.0,
                                                              color: isDark(
                                                                      context)
                                                                  ? Colors.white
                                                                  : Colors
                                                                      .black87,
                                                              letterSpacing:
                                                                  -0.1,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 56.0),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            ...widget.album.tracks.map(
                              (e) => TrackTile(
                                track: e,
                                group: widget.album.tracks,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  TweenAnimationBuilder(
                    tween: ColorTween(
                      begin: Theme.of(context).appBarTheme.backgroundColor,
                      end: color == null
                          ? Theme.of(context).appBarTheme.backgroundColor
                          : color!,
                    ),
                    curve: Curves.easeOut,
                    duration: Duration(
                      milliseconds: 300,
                    ),
                    builder: (context, color, _) => DesktopAppBar(
                      elevation: elevation,
                      color: color as Color? ?? Colors.transparent,
                      title: elevation.isZero ? null : widget.album.albumName,
                    ),
                  ),
                ],
              ),
            ),
          )
        : Container();
  }
}
