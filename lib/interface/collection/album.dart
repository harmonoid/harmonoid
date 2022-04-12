/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'dart:math';
import 'dart:ui';
import 'dart:async';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/models/media.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/utils/dimensions.dart';
import 'package:harmonoid/utils/rendering.dart';

class AlbumTab extends StatelessWidget {
  final controller = ScrollController();
  AlbumTab({
    Key? key,
  }) : super(key: key);

  Widget build(BuildContext context) {
    final elementsPerRow = (MediaQuery.of(context).size.width - tileMargin) ~/
        (kAlbumTileWidth + tileMargin);
    final double width = isMobile
        ? (MediaQuery.of(context).size.width -
                (elementsPerRow + 1) * tileMargin) /
            elementsPerRow
        : kAlbumTileWidth;
    final double height = isMobile
        ? width * kAlbumTileHeight / kAlbumTileWidth
        : kAlbumTileHeight;

    return Consumer<Collection>(
      builder: (context, collection, _) {
        if (collection.collectionSortType == CollectionSort.artist && isDesktop)
          return DesktopAlbumArtistTab();
        final data = tileGridListWidgetsWithScrollbarSupport(
          context: context,
          tileHeight: height,
          tileWidth: width,
          elementsPerRow: elementsPerRow,
          subHeader: null,
          leadingSubHeader: null,
          leadingWidget: null,
          widgetCount: Collection.instance.albums.length,
          builder: (BuildContext context, int index) => AlbumTile(
            height: height,
            width: width,
            album: Collection.instance.albums[index],
            key: ValueKey(Collection.instance.albums[index]),
          ),
        );
        return isDesktop
            ? Collection.instance.tracks.isNotEmpty
                ? CustomListViewBuilder(
                    padding: EdgeInsets.only(
                      top: tileMargin,
                    ),
                    itemCount: data.widgets.length,
                    itemExtents: List.generate(
                        data.widgets.length, (index) => height + tileMargin),
                    itemBuilder: (context, i) => data.widgets[i],
                  )
                : Center(
                    child: ExceptionWidget(
                      title: Language.instance.NO_COLLECTION_TITLE,
                      subtitle: Language.instance.NO_COLLECTION_SUBTITLE,
                    ),
                  )
            : Consumer<Collection>(
                builder: (context, collection, _) => collection
                        .tracks.isNotEmpty
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
                              (height + tileMargin);
                          final album = data
                              .data[index.clamp(
                            0,
                            data.data.length - 1,
                          )]
                              .first as Album;
                          switch (Collection.instance.collectionSortType) {
                            case CollectionSort.aToZ:
                              {
                                return Text(
                                  album.albumName[0].toUpperCase(),
                                  style: Theme.of(context).textTheme.headline1,
                                );
                              }
                            case CollectionSort.dateAdded:
                              {
                                return Text(
                                  '${album.timeAdded.label}',
                                  style: Theme.of(context).textTheme.headline4,
                                );
                              }
                            case CollectionSort.year:
                              {
                                return Text(
                                  album.year,
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
                          itemExtent: height + tileMargin,
                          padding: EdgeInsets.only(
                            top: MediaQuery.of(context).padding.top +
                                kMobileSearchBarHeight +
                                2 * tileMargin,
                          ),
                          children: data.widgets,
                        ),
                      )
                    : Center(
                        child: ExceptionWidget(
                          title: Language.instance.NO_COLLECTION_TITLE,
                          subtitle: Language.instance.NO_COLLECTION_SUBTITLE,
                        ),
                      ),
              );
      },
    );
  }
}

class DesktopAlbumArtistTab extends StatelessWidget {
  DesktopAlbumArtistTab({Key? key}) : super(key: key);

  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Consumer<Collection>(builder: (context, collection, _) {
      if (collection.tracks.isEmpty)
        return Center(
          child: ExceptionWidget(
            title: Language.instance.NO_COLLECTION_TITLE,
            subtitle: Language.instance.NO_COLLECTION_SUBTITLE,
          ),
        );
      final elementsPerRow =
          ((MediaQuery.of(context).size.width - 177.0) - tileMargin) ~/
              (kAlbumTileWidth + tileMargin);
      final double width = kAlbumTileWidth;
      final double height = kAlbumTileHeight;
      // Children of the right pane.
      List<Widget> children = [];
      List<double> itemExtents = [];
      Map<AlbumArtist, double> offsets = {};
      double last = -1 * (tileMargin + 12.0);
      // Grid generated for each iteration of album artist.
      List<Widget> widgets = [];
      if (collection.collectionOrderType == CollectionOrder.ascending) {
        for (final key in collection.albumArtists.keys) {
          offsets[key] =
              36.0 + (kAlbumTileHeight + tileMargin) * widgets.length + last;
          last = offsets[key]!;
          children.addAll(widgets);
          children.add(Container(
            margin: EdgeInsets.only(left: tileMargin),
            alignment: Alignment.topLeft,
            height: 36.0,
            child: Text(
              key.name,
              style: Theme.of(context).textTheme.headline1,
            ),
          ));
          itemExtents.addAll(List.generate(
            widgets.length,
            (_) => (kAlbumTileHeight + tileMargin),
          ));
          itemExtents.add(36.0);
          widgets = tileGridListWidgets(
            context: context,
            tileHeight: height,
            tileWidth: width,
            elementsPerRow: elementsPerRow,
            subHeader: null,
            leadingSubHeader: null,
            leadingWidget: null,
            widgetCount: collection.albumArtists[key]!.length,
            builder: (BuildContext context, int index) => AlbumTile(
              height: height,
              width: width,
              album: collection.albumArtists[key]![index],
              key: ValueKey(collection.albumArtists[key]![index]),
            ),
            mainAxisAlignment: MainAxisAlignment.start,
          );
        }
        children.addAll(tileGridListWidgets(
          context: context,
          tileHeight: height,
          tileWidth: width,
          elementsPerRow: elementsPerRow,
          subHeader: null,
          leadingSubHeader: null,
          leadingWidget: null,
          widgetCount: collection.albumArtists.values.last.length,
          builder: (BuildContext context, int index) => AlbumTile(
            height: height,
            width: width,
            album: collection.albumArtists.values.last[index],
            key: ValueKey(collection.albumArtists.values.last[index]),
          ),
          mainAxisAlignment: MainAxisAlignment.start,
        ));
        itemExtents.addAll(List.generate(
            widgets.length, (_) => (kAlbumTileHeight + tileMargin)));
      }
      if (collection.collectionOrderType == CollectionOrder.descending) {
        for (final key in collection.albumArtists.keys.toList().reversed) {
          offsets[key] =
              36.0 + (kAlbumTileHeight + tileMargin) * widgets.length + last;
          last = offsets[key]!;
          children.addAll(widgets);
          children.add(Container(
            margin: EdgeInsets.only(left: tileMargin),
            alignment: Alignment.topLeft,
            height: 36.0,
            child: Text(
              key.name,
              style: Theme.of(context).textTheme.headline1,
            ),
          ));
          itemExtents.addAll(List.generate(
              widgets.length, (_) => (kAlbumTileHeight + tileMargin)));
          itemExtents.add(36.0);
          widgets = tileGridListWidgets(
            context: context,
            tileHeight: height,
            tileWidth: width,
            elementsPerRow: elementsPerRow,
            subHeader: null,
            leadingSubHeader: null,
            leadingWidget: null,
            widgetCount: collection.albumArtists[key]!.length,
            builder: (BuildContext context, int index) => AlbumTile(
              height: height,
              width: width,
              album: collection.albumArtists[key]![index],
              key: ValueKey(collection.albumArtists[key]![index]),
            ),
            mainAxisAlignment: MainAxisAlignment.start,
          );
        }
        children.addAll(tileGridListWidgets(
          context: context,
          tileHeight: height,
          tileWidth: width,
          elementsPerRow: elementsPerRow,
          subHeader: null,
          leadingSubHeader: null,
          leadingWidget: null,
          widgetCount: collection.albumArtists.values.first.length,
          builder: (BuildContext context, int index) => AlbumTile(
            height: height,
            width: width,
            album: collection.albumArtists.values.first[index],
            key: ValueKey(collection.albumArtists.values.first[index]),
          ),
          mainAxisAlignment: MainAxisAlignment.start,
        ));
        itemExtents.addAll(List.generate(
            widgets.length, (_) => (kAlbumTileHeight + tileMargin)));
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 176.0,
            child: CustomListViewBuilder(
              padding: EdgeInsets.only(top: tileMargin / 2.0),
              itemCount: collection.albumArtists.keys.length,
              itemExtents: List.generate(
                  collection.albumArtists.keys.length, (_) => 28.0),
              itemBuilder: (context, i) => Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    scrollController.animateTo(
                      offsets[collection.collectionOrderType ==
                              CollectionOrder.ascending
                          ? collection.albumArtists.keys.elementAt(i)
                          : collection.albumArtists.keys.toList().elementAt(
                              collection.albumArtists.keys.length - i - 1)]!,
                      duration: Duration(milliseconds: 100),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    alignment: Alignment.centerLeft,
                    width: 156.0,
                    height: 28.0,
                    padding: EdgeInsets.only(
                      left: 12.0,
                      right: 8.0,
                    ),
                    child: Text(
                      collection.collectionOrderType ==
                              CollectionOrder.ascending
                          ? collection.albumArtists.keys
                              .elementAt(i)
                              .name
                              .overflow
                          : collection.albumArtists.keys
                              .toList()
                              .elementAt(
                                  collection.albumArtists.keys.length - i - 1)
                              .name
                              .overflow,
                      style: Theme.of(context).textTheme.headline4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ),
          ),
          VerticalDivider(
            width: 1.0,
          ),
          Expanded(
            child: CustomListViewBuilder(
              padding: EdgeInsets.only(
                top: tileMargin,
              ),
              controller: scrollController,
              itemCount: children.length,
              itemExtents: itemExtents,
              itemBuilder: (context, i) => children[i],
            ),
          ),
        ],
      );
    });
  }
}

class AlbumTile extends StatelessWidget {
  final double height;
  final double width;
  final Album album;

  const AlbumTile({
    Key? key,
    required this.album,
    required this.height,
    required this.width,
  }) : super(key: key);

  Widget build(BuildContext context) {
    Iterable<Color>? palette;

    return isDesktop
        ? Card(
            clipBehavior: Clip.antiAlias,
            elevation: 4.0,
            margin: EdgeInsets.zero,
            child: InkWell(
              onTap: () async {
                await precacheImage(getAlbumArt(album), context);
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
              child: Container(
                height: height,
                width: width,
                child: Column(
                  children: [
                    ClipRect(
                      child: ScaleOnHover(
                        child: Hero(
                          tag:
                              'album_art_${album.albumName}_${album.albumArtistName}',
                          child: ExtendedImage(
                            image: getAlbumArt(album, small: true),
                            fit: BoxFit.cover,
                            height: width,
                            width: width,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.0,
                        ),
                        width: width,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              album.albumName.overflow,
                              style: Theme.of(context).textTheme.headline2,
                              textAlign: TextAlign.left,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 2),
                              child: Text(
                                '${album.albumArtistName} • ${album.year}',
                                style: isDesktop
                                    ? Theme.of(context)
                                        .textTheme
                                        .headline3
                                        ?.copyWith(
                                          fontSize: 12.0,
                                        )
                                    : Theme.of(context).textTheme.headline3,
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
          )
        : OpenContainer(
            closedElevation: 4.0,
            closedColor: Theme.of(context).cardColor,
            openElevation: 0.0,
            openColor: Theme.of(context).scaffoldBackgroundColor,
            closedBuilder: (context, open) => InkWell(
              onTap: () async {
                if (palette == null) {
                  final result = await PaletteGenerator.fromImageProvider(
                      getAlbumArt(album, small: true));
                  palette = result.colors;
                }
                await precacheImage(getAlbumArt(album), context);
                open();
              },
              child: Container(
                height: height,
                width: width,
                child: Column(
                  children: [
                    Ink.image(
                      image: getAlbumArt(album),
                      fit: BoxFit.cover,
                      height: width,
                      width: width,
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.0,
                        ),
                        width: width,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              album.albumName.overflow,
                              style: Theme.of(context).textTheme.headline2,
                              textAlign: TextAlign.left,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 2),
                              child: Text(
                                '${album.albumArtistName} • ${album.year}',
                                style: isDesktop
                                    ? Theme.of(context)
                                        .textTheme
                                        .headline3
                                        ?.copyWith(
                                          fontSize: 12.0,
                                        )
                                    : Theme.of(context).textTheme.headline3,
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
            openBuilder: (context, _) => AlbumScreen(
              album: album,
              palette: palette,
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
  int? hovered;
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
            PaletteGenerator.fromImageProvider(
                    getAlbumArt(widget.album, small: true))
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
                                                    image: getAlbumArt(
                                                        widget.album),
                                                    constraints: BoxConstraints(
                                                      minWidth: 360.0,
                                                      minHeight: 360.0,
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  bottom: 0.0,
                                                  left: 0.0,
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.all(16.0),
                                                    child: ClipOval(
                                                      child: Container(
                                                        height: 36.0,
                                                        width: 36.0,
                                                        color: Colors.black54,
                                                        child: Material(
                                                          color: Colors
                                                              .transparent,
                                                          child: IconButton(
                                                            onPressed: () {
                                                              launch(
                                                                  'file:///${(getAlbumArt(widget.album) as FileImage).file.path}');
                                                            },
                                                            icon: Icon(
                                                              Icons.image,
                                                              size: 20.0,
                                                              color:
                                                                  Colors.white,
                                                            ),
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
                                                widget.album.albumName,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline1
                                                    ?.copyWith(fontSize: 24.0),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              SizedBox(height: 8.0),
                                              Text(
                                                '${Language.instance.ARTIST}: ${widget.album.albumArtistName}\n${Language.instance.YEAR}: ${widget.album.year}\n${Language.instance.TRACK}: ${widget.album.tracks.length}',
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
                                                  Playback.instance.open([
                                                    ...widget.album.tracks,
                                                    if (Configuration.instance
                                                        .automaticallyAddOtherSongsFromCollectionToNowPlaying)
                                                      ...[
                                                        ...Collection
                                                            .instance.tracks
                                                      ]..shuffle(),
                                                  ]);
                                                },
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
                                                onPressed: () {
                                                  Playback.instance.add(
                                                    widget.album.tracks,
                                                  );
                                                },
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
                                                    padding: EdgeInsets.only(
                                                        right: 8.0),
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
                                                        Language.instance.TRACK,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .headline2,
                                                      ),
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
                                                        Language
                                                            .instance.ARTIST,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .headline2,
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    width: 64.0,
                                                    height: 56.0,
                                                  ),
                                                ],
                                              ),
                                              Divider(height: 1.0),
                                            ] +
                                            (widget.album.tracks
                                                .asMap()
                                                .entries
                                                .map(
                                                  (track) => MouseRegion(
                                                    onEnter: (e) {
                                                      setState(() {
                                                        hovered = track.key;
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
                                                          track.value,
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
                                                          onTap: () {
                                                            Playback.instance
                                                                .open(
                                                              [
                                                                ...widget.album
                                                                    .tracks,
                                                                if (Configuration
                                                                    .instance
                                                                    .automaticallyAddOtherSongsFromCollectionToNowPlaying)
                                                                  ...[
                                                                    ...Collection
                                                                        .instance
                                                                        .tracks
                                                                  ]..shuffle(),
                                                              ],
                                                              index: track.key,
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
                                                                            .key
                                                                    ? IconButton(
                                                                        onPressed:
                                                                            () {
                                                                          Playback
                                                                              .instance
                                                                              .open(
                                                                            widget.album.tracks,
                                                                            index:
                                                                                track.key,
                                                                          );
                                                                        },
                                                                        icon: Icon(
                                                                            Icons.play_arrow),
                                                                        splashRadius:
                                                                            20.0,
                                                                      )
                                                                    : Text(
                                                                        '${track.value.trackNumber}',
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
                                                                    track.value
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
                                                                    track.value
                                                                        .trackArtistNames
                                                                        .join(
                                                                            ', '),
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
                                                                width: 64.0,
                                                                height: 56.0,
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                child:
                                                                    ContextMenuButton<
                                                                        int>(
                                                                  onSelected:
                                                                      (result) {
                                                                    trackPopupMenuHandle(
                                                                      context,
                                                                      track
                                                                          .value,
                                                                      result,
                                                                      recursivelyPopNavigatorOnDeleteIf: () => widget
                                                                          .album
                                                                          .tracks
                                                                          .isEmpty,
                                                                    );
                                                                  },
                                                                  color: Theme.of(
                                                                          context)
                                                                      .iconTheme
                                                                      .color,
                                                                  itemBuilder:
                                                                      (_) =>
                                                                          trackPopupMenuItems(
                                                                    context,
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
        : Scaffold(
            body: Stack(
              children: [
                CustomScrollView(
                  controller: controller,
                  slivers: [
                    SliverAppBar(
                      systemOverlayStyle: SystemUiOverlayStyle(
                        statusBarColor: (color?.computeLuminance() ?? 0.0) < 0.5
                            ? Colors.white12
                            : Colors.black12,
                        statusBarIconBrightness:
                            (color?.computeLuminance() ?? 0.0) < 0.5
                                ? Brightness.light
                                : Brightness.dark,
                      ),
                      expandedHeight: MediaQuery.of(context).size.width +
                          136.0 -
                          MediaQuery.of(context).padding.top,
                      pinned: true,
                      leading: IconButton(
                        onPressed: Navigator.of(context).maybePop,
                        icon: Icon(
                          Icons.arrow_back,
                          color: [
                            Colors.black,
                            Colors.white
                          ][(color?.computeLuminance() ?? 0.0) > 0.5 ? 0 : 1],
                        ),
                        iconSize: 24.0,
                        splashRadius: 20.0,
                      ),
                      forceElevated: true,
                      actions: [
                        // IconButton(
                        //   onPressed: () {},
                        //   icon: Icon(
                        //     Icons.favorite,
                        //   ),
                        //   iconSize: 24.0,
                        //   splashRadius: 20.0,
                        // ),
                        IconButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (subContext) => AlertDialog(
                                title: Text(
                                  Language.instance
                                      .COLLECTION_ALBUM_DELETE_DIALOG_HEADER,
                                  style:
                                      Theme.of(subContext).textTheme.headline1,
                                ),
                                content: Text(
                                  Language.instance
                                      .COLLECTION_ALBUM_DELETE_DIALOG_BODY
                                      .replaceAll(
                                    'NAME',
                                    widget.album.albumName,
                                  ),
                                  style:
                                      Theme.of(subContext).textTheme.headline3,
                                ),
                                actions: [
                                  MaterialButton(
                                    textColor: Theme.of(context).primaryColor,
                                    onPressed: () async {
                                      await Collection.instance
                                          .delete(widget.album);
                                      Navigator.of(subContext).pop();
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
                          },
                          icon: Icon(
                            Icons.delete,
                            color: [
                              Colors.black,
                              Colors.white
                            ][(color?.computeLuminance() ?? 0.0) > 0.5 ? 0 : 1],
                          ),
                          iconSize: 24.0,
                          splashRadius: 20.0,
                        ),
                      ],
                      title: TweenAnimationBuilder<double>(
                        tween: Tween<double>(
                          begin: 1.0,
                          end: detailsVisible ? 0.0 : 1.0,
                        ),
                        duration: Duration(milliseconds: 200),
                        builder: (context, value, _) => Opacity(
                          opacity: value,
                          child: Text(
                            widget.album.albumName.overflow,
                            style: Theme.of(context)
                                .textTheme
                                .headline1
                                ?.copyWith(
                                    color: [Colors.black, Colors.white][
                                        (color?.computeLuminance() ?? 0.0) > 0.5
                                            ? 0
                                            : 1]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      backgroundColor: color,
                      flexibleSpace: FlexibleSpaceBar(
                        background: Column(
                          children: [
                            ExtendedImage(
                              image: getAlbumArt(widget.album),
                              fit: BoxFit.cover,
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.width,
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
                                  color: color,
                                  height: 136.0,
                                  width: MediaQuery.of(context).size.width,
                                  padding: EdgeInsets.all(16.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.album.albumName.overflow,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline1
                                            ?.copyWith(
                                              color: [
                                                Colors.white,
                                                Colors.black
                                              ][(color?.computeLuminance() ??
                                                          0.0) >
                                                      0.5
                                                  ? 1
                                                  : 0],
                                              fontSize: 24.0,
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4.0),
                                      Text(
                                        widget.album.albumArtistName.overflow,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline1
                                            ?.copyWith(
                                              color: [
                                                Color(0xFFD9D9D9),
                                                Color(0xFF363636)
                                              ][(color?.computeLuminance() ??
                                                          0.0) >
                                                      0.5
                                                  ? 1
                                                  : 0],
                                              fontSize: 16.0,
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2.0),
                                      Text(
                                        '${widget.album.year}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline1
                                            ?.copyWith(
                                              color: [
                                                Color(0xFFD9D9D9),
                                                Color(0xFF363636)
                                              ][(color?.computeLuminance() ??
                                                          0.0) >
                                                      0.5
                                                  ? 1
                                                  : 0],
                                              fontSize: 16.0,
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
                            onTap: () => Playback.instance.open(
                              [
                                ...widget.album.tracks,
                                if (Configuration.instance
                                    .automaticallyAddOtherSongsFromCollectionToNowPlaying)
                                  ...[...Collection.instance.tracks]..shuffle(),
                              ],
                              index: i,
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
                                widget.album.tracks[i],
                                result,
                                recursivelyPopNavigatorOnDeleteIf: () =>
                                    widget.album.tracks.isEmpty,
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
                                          '${widget.album.tracks[i].trackNumber}',
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
                                              widget.album.tracks[i].trackName
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
                                              (widget.album.tracks[i]
                                                              .duration ??
                                                          Duration.zero)
                                                      .label +
                                                  ' • ' +
                                                  widget.album.tracks[i]
                                                      .trackArtistNames
                                                      .take(2)
                                                      .join(', '),
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
                                              widget.album.tracks[i],
                                              result,
                                              recursivelyPopNavigatorOnDeleteIf:
                                                  () => widget
                                                      .album.tracks.isEmpty,
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
                        childCount: widget.album.tracks.length,
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.only(
                        top: 12.0 +
                            (detailsLoaded
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
                        begin: 0.0, end: detailsVisible ? 1.0 : 0.0),
                    duration: Duration(milliseconds: 200),
                    builder: (context, value, _) => Transform.scale(
                      scale: value as double,
                      child: Transform.rotate(
                        angle: value * pi + pi,
                        child: FloatingActionButton(
                          heroTag: 'play_now',
                          backgroundColor: secondary,
                          foregroundColor: [Colors.white, Colors.black][
                              (secondary?.computeLuminance() ?? 0.0) > 0.5
                                  ? 1
                                  : 0],
                          child: Icon(Icons.play_arrow),
                          onPressed: () {
                            Playback.instance.open([
                              ...widget.album.tracks,
                              if (Configuration.instance
                                  .automaticallyAddOtherSongsFromCollectionToNowPlaying)
                                ...[...Collection.instance.tracks]..shuffle(),
                            ]);
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
                        begin: 0.0, end: detailsVisible ? 1.0 : 0.0),
                    duration: Duration(milliseconds: 200),
                    builder: (context, value, _) => Transform.scale(
                      scale: value as double,
                      child: Transform.rotate(
                        angle: value * pi + pi,
                        child: FloatingActionButton(
                          heroTag: 'shuffle',
                          backgroundColor: secondary,
                          foregroundColor: [Colors.white, Colors.black][
                              (secondary?.computeLuminance() ?? 0.0) > 0.5
                                  ? 1
                                  : 0],
                          child: Icon(Icons.shuffle),
                          onPressed: () {
                            Playback.instance.open(
                              [...widget.album.tracks]..shuffle(),
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
