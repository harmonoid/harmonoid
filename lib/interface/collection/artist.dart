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

import 'dart:ui';
import 'dart:async';
import 'dart:math';
import 'package:animations/animations.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:palette_generator/palette_generator.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/utils/dimensions.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/constants/language.dart';

class ArtistTab extends StatelessWidget {
  final controller = ScrollController();

  Widget build(BuildContext context) {
    final elementsPerRow = (MediaQuery.of(context).size.width - tileMargin) ~/
        (kDesktopArtistTileWidth + tileMargin);

    return Consumer<Collection>(
      builder: (context, collection, _) {
        final data = tileGridListWidgetsWithScrollbarSupport(
          context: context,
          tileHeight: kDesktopArtistTileHeight,
          tileWidth: kDesktopArtistTileWidth,
          elementsPerRow: elementsPerRow,
          subHeader: null,
          leadingSubHeader: null,
          leadingWidget: null,
          widgetCount: collection.artists.length,
          builder: (BuildContext context, int index) => ArtistTile(
            height: kDesktopArtistTileHeight,
            width: kDesktopArtistTileWidth,
            artist: collection.artists[index],
            key: ValueKey(collection.artists[index]),
          ),
        );
        return isDesktop
            ? collection.tracks.isNotEmpty
                ? CustomListView(
                    padding: EdgeInsets.only(top: tileMargin),
                    children: tileGridListWidgets(
                      context: context,
                      tileHeight: kDesktopArtistTileHeight,
                      tileWidth: kDesktopArtistTileWidth,
                      elementsPerRow: elementsPerRow,
                      subHeader: null,
                      leadingSubHeader: null,
                      widgetCount: collection.artists.length,
                      leadingWidget: Container(),
                      builder: (BuildContext context, int index) => ArtistTile(
                        height: kDesktopArtistTileHeight,
                        width: kDesktopArtistTileWidth,
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
                  )
            : Consumer<Collection>(
                builder: (context, collection, _) => collection
                        .artists.isNotEmpty
                    ? DraggableScrollbar.semicircle(
                        heightScrollThumb: 56.0,
                        labelConstraints: BoxConstraints.tightFor(
                          width: 120.0,
                          height: 32.0,
                        ),
                        labelTextBuilder: (offset) {
                          final index = (offset -
                                  (kMobileSearchBarHeight +
                                      2 * tileMargin +
                                      MediaQuery.of(context).padding.top)) ~/
                              kMobileTrackTileHeight;
                          final artist = collection.artists[index.clamp(
                            0,
                            collection.tracks.length - 1,
                          )];
                          switch (collection.collectionSortType) {
                            case CollectionSort.aToZ:
                              {
                                return Text(
                                  artist.artistName![0].toUpperCase(),
                                  style: Theme.of(context).textTheme.headline1,
                                );
                              }
                            case CollectionSort.dateAdded:
                              {
                                return Text(
                                  '${DateTime.fromMillisecondsSinceEpoch(artist.tracks.last.timeAdded!).label}',
                                  style: Theme.of(context).textTheme.headline4,
                                );
                              }
                            case CollectionSort.year:
                              {
                                return Text(
                                  '${artist.tracks.last.year ?? 'Unknown Year'}',
                                  style: Theme.of(context).textTheme.headline4,
                                );
                              }
                            default:
                              return Text(
                                '',
                                style: Theme.of(context).textTheme.headline4,
                              );
                          }
                        },
                        backgroundColor: Theme.of(context).cardColor,
                        controller: controller,
                        child: ListView(
                          controller: controller,
                          itemExtent: kMobileArtistTileHeight,
                          padding: EdgeInsets.only(
                            top: MediaQuery.of(context).padding.top +
                                kMobileSearchBarHeight +
                                2 * tileMargin,
                          ),
                          children: collection.artists
                              .map(
                                (artist) => ArtistTile(
                                  height: -1,
                                  width: -1,
                                  artist: artist,
                                ),
                              )
                              .toList(),
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
      },
    );
  }
}

class ArtistTile extends StatelessWidget {
  final double height;
  final double width;
  final Artist artist;
  const ArtistTile({
    Key? key,
    required this.height,
    required this.width,
    required this.artist,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Iterable<Color>? palette;

    return isDesktop
        ? Container(
            height: height,
            width: width,
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
                        width / 2.0,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipOval(
                          child: Image.file(
                            artist.tracks.last.albumArt,
                            height: width - 8.0,
                            width: width - 8.0,
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
                            onTap: () {
                              Navigator.of(context).push(
                                PageRouteBuilder(
                                  pageBuilder: (context, animation,
                                          secondaryAnimation) =>
                                      FadeThroughTransition(
                                    animation: animation,
                                    secondaryAnimation: secondaryAnimation,
                                    child: ArtistScreen(
                                      artist: artist,
                                    ),
                                  ),
                                  transitionDuration:
                                      Duration(milliseconds: 300),
                                  reverseTransitionDuration:
                                      Duration(milliseconds: 300),
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
          )
        : Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                if (palette == null) {
                  final result = await PaletteGenerator.fromImageProvider(
                      FileImage(this.artist.tracks.last.albumArt));
                  palette = result.colors;
                }
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        FadeThroughTransition(
                      animation: animation,
                      secondaryAnimation: secondaryAnimation,
                      child: ArtistScreen(
                        artist: artist,
                        palette: palette,
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
                        Hero(
                          tag: 'artist_art_${this.artist.artistName}',
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28.0),
                            ),
                            elevation: 4.0,
                            margin: EdgeInsets.zero,
                            child: Padding(
                              padding: EdgeInsets.all(2.0),
                              child: ClipOval(
                                child: Image.file(
                                  this.artist.tracks.last.albumArt,
                                  height: 48.0,
                                  width: 48.0,
                                  cacheHeight: 140,
                                  cacheWidth: 140,
                                ),
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
                                this.artist.artistName!.overflow,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: Theme.of(context).textTheme.headline2,
                              ),
                              const SizedBox(
                                height: 2.0,
                              ),
                              Text(
                                language.M_TRACKS_AND_N_ALBUMS
                                    .replaceAll(
                                        'M', '${this.artist.tracks.length}')
                                    .replaceAll(
                                        'N', '${this.artist.albums.length}'),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: Theme.of(context).textTheme.headline3,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12.0),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}

class ArtistScreen extends StatefulWidget {
  final Artist artist;
  final Iterable<Color>? palette;

  const ArtistScreen({
    Key? key,
    required this.artist,
    this.palette,
  }) : super(key: key);
  ArtistScreenState createState() => ArtistScreenState();
}

class ArtistScreenState extends State<ArtistScreen>
    with SingleTickerProviderStateMixin {
  Color? color;
  Color? secondary;
  Track? hovered;
  bool reactToSecondaryPress = false;
  bool detailsVisible = false;
  bool detailsLoaded = false;
  ScrollController controller = ScrollController(initialScrollOffset: 96.0);

  @override
  void initState() {
    super.initState();
    if (isDesktop) {
      Timer(
        Duration(milliseconds: 300),
        () {
          if (widget.palette == null) {
            PaletteGenerator.fromImageProvider(
                    FileImage(widget.artist.tracks.last.albumArt))
                .then((palette) {
              this.setState(() {
                this.color = palette.colors.first;
                this.secondary = palette.colors.last;
                this.detailsVisible = true;
              });
            });
          } else {
            this.setState(() {
              this.detailsVisible = true;
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
            this.setState(() {
              this.detailsLoaded = true;
            });
          });
        });
      });
      if (widget.palette != null) {
        this.color = widget.palette?.first;
        this.secondary = widget.palette?.last;
      }
      this.controller.addListener(() {
        if (this.controller.offset == 0.0) {
          this.setState(() {
            this.detailsVisible = true;
          });
        } else if (this.detailsVisible) {
          this.setState(() {
            this.detailsVisible = false;
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
                                          borderRadius: BorderRadius.circular(
                                            (dimension - 48.0) / 2.0,
                                          ),
                                        ),
                                        child: Container(
                                          padding: EdgeInsets.all(4.0),
                                          width: dimension - 48.0,
                                          height: dimension - 48.0,
                                          child: ClipOval(
                                            child: Image.file(
                                              widget
                                                  .artist.tracks.last.albumArt,
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
                                                    tracks: widget
                                                            .artist.tracks +
                                                        ([...collection.tracks]
                                                          ..shuffle()),
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
                                                                      .tracks +
                                                                  ([
                                                                    ...collection
                                                                        .tracks
                                                                  ]..shuffle()),
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
        : Scaffold(
            body: Stack(
              children: [
                CustomScrollView(
                  controller: this.controller,
                  slivers: [
                    SliverAppBar(
                      expandedHeight: MediaQuery.of(context).size.width +
                          96.0 -
                          MediaQuery.of(context).padding.top,
                      pinned: true,
                      leading: IconButton(
                        onPressed: Navigator.of(context).maybePop,
                        icon: Icon(
                          Icons.arrow_back,
                        ),
                        iconSize: 24.0,
                        splashRadius: 20.0,
                      ),
                      forceElevated: true,
                      // actions: [
                      //  IconButton(
                      //    onPressed: () {},
                      //    icon: Icon(
                      //      Icons.favorite,
                      //    ),
                      //     iconSize: 24.0,
                      //     splashRadius: 20.0,
                      //   ),
                      // ],
                      title: TweenAnimationBuilder<double>(
                        tween: Tween<double>(
                          begin: 1.0,
                          end: detailsVisible ? 0.0 : 1.0,
                        ),
                        duration: Duration(milliseconds: 200),
                        builder: (context, value, _) => Opacity(
                          opacity: value,
                          child: Text(
                            language.ARTIST_SINGLE,
                            style: Theme.of(context)
                                .textTheme
                                .headline1
                                ?.copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                      backgroundColor: this.color,
                      flexibleSpace: FlexibleSpaceBar(
                        background: Column(
                          children: [
                            Container(
                              height: MediaQuery.of(context).size.width,
                              width: MediaQuery.of(context).size.width,
                              child: LayoutBuilder(
                                builder: (context, constraints) => Hero(
                                  tag: 'artist_art_${widget.artist.artistName}',
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(min(
                                              constraints.maxHeight,
                                              constraints.maxWidth) -
                                          28.0),
                                    ),
                                    elevation: 4.0,
                                    margin: EdgeInsets.all(
                                      56.0,
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(4.0),
                                      child: ClipOval(
                                        child: Image.file(
                                          widget.artist.tracks.last.albumArt,
                                          height: min(constraints.maxHeight,
                                                  constraints.maxWidth) -
                                              64.0,
                                          width: min(constraints.maxHeight,
                                                  constraints.maxWidth) -
                                              64.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            TweenAnimationBuilder<double>(
                              tween: Tween<double>(
                                begin: 1.0,
                                end: detailsVisible ? 1.0 : 0.0,
                              ),
                              duration: Duration(milliseconds: 200),
                              builder: (context, value, _) => Opacity(
                                opacity: value,
                                child: Container(
                                  color: this.color,
                                  height: 96.0,
                                  width: MediaQuery.of(context).size.width,
                                  padding: EdgeInsets.all(16.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.artist.artistName!.overflow,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline1
                                            ?.copyWith(
                                              color: [
                                                Colors.white,
                                                Colors.black
                                              ][(this.color?.computeLuminance() ??
                                                          0.0) >
                                                      0.5
                                                  ? 1
                                                  : 0],
                                              fontSize: 24.0,
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
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
                    SliverPadding(
                      padding: EdgeInsets.only(
                        top: 12.0,
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) => Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => Playback.play(
                              index: i,
                              tracks: widget.artist.tracks +
                                  ([...collection.tracks]..shuffle()),
                            ),
                            onLongPress: () async {
                              var result;
                              await showModalBottomSheet(
                                context: context,
                                builder: (context) => Container(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: trackPopupMenuItems(context)
                                        .map(
                                          (item) => PopupMenuItem(
                                            child: item.child,
                                            onTap: () => result = item.value,
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ),
                              );
                              await trackPopupMenuHandle(
                                context,
                                widget.artist.tracks[i],
                                result,
                                recursivelyPopNavigatorOnDeleteIf: () =>
                                    widget.artist.tracks.isEmpty,
                              );
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 64.0,
                                  alignment: Alignment.center,
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const SizedBox(width: 12.0),
                                      Container(
                                        height: 56.0,
                                        width: 56.0,
                                        alignment: Alignment.center,
                                        child: Text(
                                          '${widget.artist.tracks[i].trackNumber ?? 1}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline3
                                              ?.copyWith(fontSize: 18.0),
                                        ),
                                      ),
                                      const SizedBox(width: 12.0),
                                      Expanded(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              widget.artist.tracks[i].trackName!
                                                  .overflow,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline2,
                                            ),
                                            const SizedBox(
                                              height: 2.0,
                                            ),
                                            Text(
                                              Duration(
                                                    milliseconds: widget
                                                            .artist
                                                            .tracks[i]
                                                            .trackDuration ??
                                                        0,
                                                  ).label +
                                                  ' • ' +
                                                  widget.artist.tracks[i]
                                                      .albumName!,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline3,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12.0),
                                      Container(
                                        width: 64.0,
                                        height: 64.0,
                                        alignment: Alignment.center,
                                        child: IconButton(
                                          onPressed: () async {
                                            var result;
                                            await showModalBottomSheet(
                                              context: context,
                                              builder: (context) => Container(
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: trackPopupMenuItems(
                                                          context)
                                                      .map(
                                                        (item) => PopupMenuItem(
                                                          child: item.child,
                                                          onTap: () => result =
                                                              item.value,
                                                        ),
                                                      )
                                                      .toList(),
                                                ),
                                              ),
                                            );
                                            await trackPopupMenuHandle(
                                              context,
                                              widget.artist.tracks[i],
                                              result,
                                              recursivelyPopNavigatorOnDeleteIf:
                                                  () => widget
                                                      .artist.tracks.isEmpty,
                                            );
                                          },
                                          icon: Icon(
                                            Icons.more_vert,
                                          ),
                                          iconSize: 24.0,
                                          splashRadius: 20.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(
                                  height: 1.0,
                                  indent: 80.0,
                                ),
                              ],
                            ),
                          ),
                        ),
                        childCount: widget.artist.tracks.length,
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.only(
                        top: 12.0 +
                            (this.detailsLoaded
                                ? 0.0
                                : MediaQuery.of(context).size.height),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: MediaQuery.of(context).size.width +
                      MediaQuery.of(context).padding.top -
                      64.0,
                  right: 16.0 + 64.0,
                  child: TweenAnimationBuilder(
                    curve: Curves.easeOut,
                    tween: Tween<double>(
                        begin: 0.0, end: this.detailsVisible ? 1.0 : 0.0),
                    duration: Duration(milliseconds: 200),
                    builder: (context, value, _) => Transform.scale(
                      scale: value as double,
                      child: Transform.rotate(
                        angle: value * pi + pi,
                        child: FloatingActionButton(
                          heroTag: 'play_now',
                          backgroundColor: this.secondary,
                          foregroundColor: [Colors.white, Colors.black][
                              (this.secondary?.computeLuminance() ?? 0.0) > 0.5
                                  ? 1
                                  : 0],
                          child: Icon(Icons.play_arrow),
                          onPressed: () {
                            Playback.play(
                              index: 0,
                              tracks: widget.artist.tracks +
                                  ([...collection.tracks]..shuffle()),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.width +
                      MediaQuery.of(context).padding.top -
                      64.0,
                  right: 16.0,
                  child: TweenAnimationBuilder(
                    curve: Curves.easeOut,
                    tween: Tween<double>(
                        begin: 0.0, end: this.detailsVisible ? 1.0 : 0.0),
                    duration: Duration(milliseconds: 200),
                    builder: (context, value, _) => Transform.scale(
                      scale: value as double,
                      child: Transform.rotate(
                        angle: value * pi + pi,
                        child: FloatingActionButton(
                          heroTag: 'shuffle',
                          backgroundColor: this.secondary,
                          foregroundColor: [Colors.white, Colors.black][
                              (this.secondary?.computeLuminance() ?? 0.0) > 0.5
                                  ? 1
                                  : 0],
                          child: Icon(Icons.shuffle),
                          onPressed: () {
                            Playback.play(
                              index: 0,
                              tracks: [...widget.artist.tracks]..shuffle(),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
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
