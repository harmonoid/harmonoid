/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///
import 'dart:math';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:harmonoid/web/playlist.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:readmore/readmore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ytm_client/ytm_client.dart';
import 'package:extended_image/extended_image.dart';

import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/utils/dimensions.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/web/album.dart';
import 'package:harmonoid/web/state/web.dart';
import 'package:harmonoid/web/track.dart';
import 'package:harmonoid/web/video.dart';
import 'package:harmonoid/web/utils/dimensions.dart';

class WebArtistLargeTile extends StatelessWidget {
  final double height;
  final double width;
  final Artist artist;
  const WebArtistLargeTile({
    Key? key,
    required this.height,
    required this.width,
    required this.artist,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Card(
            clipBehavior: Clip.antiAlias,
            margin: EdgeInsets.zero,
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                width / 2.0,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Hero(
                  tag: 'artist_art_${artist.id}',
                  child: ClipOval(
                    child: ExtendedImage(
                      image: ExtendedNetworkImageProvider(
                          artist.thumbnails.values.first),
                      height: width - 8.0,
                      width: width - 8.0,
                    ),
                  ),
                ),
                Material(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      width / 2.0,
                    ),
                  ),
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      if (artist.data.isEmpty) {
                        await YTMClient.artist(artist);
                      }
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  FadeThroughTransition(
                            fillColor: Colors.transparent,
                            animation: animation,
                            secondaryAnimation: secondaryAnimation,
                            child: WebArtistScreen(
                              artist: artist,
                            ),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      height: width,
                      width: width,
                      padding: EdgeInsets.all(4.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Spacer(),
          Text(
            artist.artistName.overflow,
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

class WebArtistTile extends StatelessWidget {
  final Artist artist;

  const WebArtistTile({
    Key? key,
    required this.artist,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          if (artist.data.isEmpty) {
            await YTMClient.artist(artist);
          }
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  FadeThroughTransition(
                fillColor: Colors.transparent,
                animation: animation,
                secondaryAnimation: secondaryAnimation,
                child: WebArtistScreen(
                  artist: artist,
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
                  Hero(
                    tag: 'artist_art_${artist.id}',
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28.0),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(2.0),
                        child: artist.thumbnails.isNotEmpty
                            ? ClipOval(
                                child: ExtendedImage(
                                  image: NetworkImage(
                                    artist.thumbnails.values.first,
                                  ),
                                  height: 52.0,
                                  width: 52.0,
                                ),
                              )
                            : SizedBox.square(
                                dimension: 52.0,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          artist.artistName.overflow,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: Theme.of(context).textTheme.headline2,
                        ),
                        const SizedBox(
                          height: 2.0,
                        ),
                        Text(
                          artist.subscribersCount,
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

class WebArtistScreen extends StatefulWidget {
  final Artist artist;
  WebArtistScreen({
    Key? key,
    required this.artist,
  }) : super(key: key);

  @override
  State<WebArtistScreen> createState() => _WebArtistScreenState();
}

class _WebArtistScreenState extends State<WebArtistScreen> {
  Color? _color;

  @override
  void initState() {
    super.initState();
    PaletteGenerator.fromImageProvider(
      NetworkImage(widget.artist.thumbnails.values.first),
    ).then(
      (value) {
        setState(() {
          value.colors.forEach((element) {
            element.computeLuminance();
          });
        });
      },
    );
  }

  bool get _isDark =>
      (0.299 * (_color?.red ?? 256.0)) +
          (0.587 * (_color?.green ?? 256.0)) +
          (0.114 * (_color?.blue ?? 256.0)) <
      128.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          CustomListView(
            children: [
              ExtendedImage.network(
                widget.artist.coverUrl,
                fit: BoxFit.cover,
                width: MediaQuery.of(context).size.width,
                enableLoadState: true,
                enableMemoryCache: false,
                cache: true,
                loadStateChanged: (ExtendedImageState state) {
                  return Stack(
                    alignment: Alignment.topLeft,
                    children: [
                      Positioned.fill(
                        child:
                            state.extendedImageLoadState == LoadState.completed
                                ? TweenAnimationBuilder(
                                    tween: Tween<double>(begin: 0.0, end: 1.0),
                                    duration: const Duration(milliseconds: 800),
                                    child: state.completedWidget,
                                    builder: (context, value, child) => Opacity(
                                      opacity: value as double,
                                      child: state.completedWidget,
                                    ),
                                  )
                                : SizedBox.shrink(),
                      ),
                      Positioned.fill(
                        bottom: -12.0,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: [0.35, 0.95],
                              colors: [
                                Colors.transparent,
                                Theme.of(context).scaffoldBackgroundColor,
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: 20.0,
                          top: min(
                            480.0,
                            MediaQuery.of(context).size.height -
                                kDesktopNowPlayingBarHeight -
                                48.0 -
                                192.0,
                          ),
                          bottom: 20.0,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.artist.artistName.overflow,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline1
                                  ?.copyWith(
                                    fontSize: 48.0,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              widget.artist.subscribersCount
                                  .split(' • ')
                                  .last
                                  .trim(),
                              style: Theme.of(context).textTheme.headline3,
                            ),
                            const SizedBox(height: 2.0),
                            ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: 580.0),
                              child: ReadMoreText(
                                widget.artist.description,
                                trimLines: 4,
                                trimMode: TrimMode.Line,
                                trimExpandedText: Language.instance.LESS,
                                trimCollapsedText: Language.instance.MORE,
                                colorClickableText:
                                    Theme.of(context).primaryColor,
                                style: Theme.of(context).textTheme.headline3,
                                callback: (isTrimmed) {
                                  setState(() {});
                                },
                              ),
                            ),
                            const SizedBox(height: 12.0),
                            Row(
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Web.open(widget.artist.tracks);
                                  },
                                  style: ButtonStyle(
                                    elevation: MaterialStateProperty.all(0.0),
                                    backgroundColor: MaterialStateProperty.all(
                                        Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : Colors.black87),
                                    padding: MaterialStateProperty.all(
                                        EdgeInsets.all(12.0)),
                                  ),
                                  icon: Icon(
                                    Icons.shuffle,
                                    color: !(Theme.of(context).brightness ==
                                            Brightness.dark)
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                  label: Text(
                                    Language.instance.SHUFFLE.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 12.0,
                                      color: !(Theme.of(context).brightness ==
                                              Brightness.dark)
                                          ? Colors.white
                                          : Colors.black87,
                                      letterSpacing: -0.1,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8.0),
                                OutlinedButton.icon(
                                  onPressed: () {
                                    launch(
                                        'https://music.youtube.com/browse/${widget.artist.id}');
                                  },
                                  style: OutlinedButton.styleFrom(
                                    primary: Colors.white,
                                    side: BorderSide(
                                        color: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : Colors.black87),
                                    padding: EdgeInsets.all(12.0),
                                  ),
                                  icon: Icon(
                                    Icons.open_in_new,
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                  label: Text(
                                    Language.instance.OPEN_IN_BROWSER
                                        .toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 12.0,
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : Colors.black87,
                                      letterSpacing: -0.1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              ...widget.artist.data.entries.map(
                (e) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 16.0,
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 16.0),
                          Text(
                            e.key,
                            style: Theme.of(context).textTheme.headline1,
                          ),
                          Spacer(),
                          // if (e.value.browseId != null)
                          //   ShowAllButton(
                          //     onPressed: () {
                          //       // TODO: Handle [ShowAllButton].
                          //     },
                          //   ),
                        ],
                      ),
                    ),
                    if (e.value.elements.first is Track)
                      ...e.value.elements.map(
                        (f) => Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: WebTrackTile(
                            track: f as Track,
                          ),
                        ),
                      ),
                    if (e.value.elements.first is Album)
                      Container(
                        height: kAlbumTileHeight + 8.0,
                        child: HorizontalList(
                          padding: EdgeInsets.only(
                            left: 16.0,
                            right: 16.0,
                            bottom: 8.0,
                          ),
                          children: e.value.elements
                              .map(
                                (f) => Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 8.0),
                                  child: WebAlbumLargeTile(
                                    album: f as Album,
                                    width: kAlbumTileWidth,
                                    height: kAlbumTileHeight,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    if (e.value.elements.first is Video)
                      Container(
                        height: kLargeTileHeight + 8.0,
                        child: HorizontalList(
                          padding: EdgeInsets.only(
                            left: 16.0,
                            right: 16.0,
                            bottom: 8.0,
                          ),
                          children: e.value.elements
                              .map(
                                (f) => Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 8.0),
                                  child: WebVideoLargeTile(
                                    track: Track.fromWebVideo(f.toJson()),
                                    width: kLargeTileWidth,
                                    height: kLargeTileHeight,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    if (e.value.elements.first is Playlist)
                      Container(
                        height: kAlbumTileHeight + 8.0,
                        child: HorizontalList(
                          padding: EdgeInsets.only(
                            left: 16.0,
                            right: 16.0,
                            bottom: 8.0,
                          ),
                          children: e.value.elements
                              .map(
                                (f) => Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 8.0),
                                  child: WebPlaylistLargeTile(
                                    playlist: f as Playlist,
                                    width: kAlbumTileWidth,
                                    height: kAlbumTileHeight,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    if (e.value.elements.first is Artist)
                      Container(
                        height: kAlbumTileWidth + 28.0 + 8.0,
                        child: HorizontalList(
                          padding: EdgeInsets.only(
                            left: 16.0,
                            right: 16.0,
                            bottom: 8.0,
                          ),
                          children: e.value.elements
                              .map(
                                (f) => Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 8.0),
                                  child: WebArtistLargeTile(
                                    artist: f as Artist,
                                    width: kAlbumTileWidth,
                                    height: kAlbumTileWidth + 28.0,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    const SizedBox(height: 16.0),
                  ],
                ),
              ),
            ],
          ),
          DesktopAppBar(
            color: _isDark
                ? Colors.white.withOpacity(0.2)
                : Colors.black.withOpacity(0.2),
            elevation: 0.0,
          ),
        ],
      ),
    );
  }
}
