/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'dart:io';
import 'dart:ui';
import 'dart:math';
import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:media_library/media_library.dart';
import 'package:extended_image/extended_image.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/interface/collection/artist.dart';
import 'package:harmonoid/state/mobile_now_playing_controller.dart';
import 'package:harmonoid/utils/theme.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/dimensions.dart';
import 'package:harmonoid/utils/storage_retriever.dart';
import 'package:harmonoid/utils/palette_generator.dart';
import 'package:harmonoid/constants/language.dart';

class AlbumTab extends StatefulWidget {
  AlbumTab({
    Key? key,
  }) : super(key: key);

  @override
  _AlbumTabState createState() => _AlbumTabState();
}

class _AlbumTabState extends State<AlbumTab> {
  final ValueNotifier<bool> hover = ValueNotifier<bool>(false);
  final controller = ScrollController();

  @override
  void initState() {
    super.initState();
    controller.addListener(listener);
  }

  @override
  void dispose() {
    controller.removeListener(listener);
    controller.dispose();
    super.dispose();
  }

  void listener() {
    hover.value = !controller.offset.isZero;
  }

  Widget build(BuildContext context) {
    final helper = DimensionsHelper(context);
    return Consumer<Collection>(
      builder: (context, collection, _) {
        if (collection.albumsSort == AlbumsSort.artist && isDesktop)
          return DesktopAlbumArtistTab();
        final data = tileGridListWidgetsWithScrollbarSupport(
          context: context,
          tileWidth: helper.albumTileWidth,
          tileHeight: helper.albumTileHeight,
          elementsPerRow: helper.albumElementsPerRow,
          widgetCount: Collection.instance.albums.length,
          builder: (BuildContext context, int index) => AlbumTile(
            width: helper.albumTileWidth,
            height: helper.albumTileHeight,
            album: Collection.instance.albums[index],
            key: ValueKey(Collection.instance.albums[index]),
          ),
        );
        return isDesktop
            ? Collection.instance.albums.isNotEmpty
                ? Stack(
                    children: [
                      CustomListViewBuilder(
                        controller: controller,
                        itemCount: 1 + data.widgets.length,
                        itemExtents: [
                              28.0 + tileMargin,
                            ] +
                            List.generate(
                              data.widgets.length,
                              (index) => helper.albumTileHeight + tileMargin,
                            ),
                        itemBuilder: (context, i) => i == 0
                            ? SortBarFixedHolder(
                                child: SortBar(
                                  tab: 0,
                                  hover: hover,
                                  fixed: true,
                                ),
                              )
                            : data.widgets[i - 1],
                      ),
                      SortBar(
                        tab: 0,
                        hover: hover,
                        fixed: false,
                      ),
                    ],
                  )
                : Center(
                    child: ExceptionWidget(
                      title: Language.instance.NO_COLLECTION_TITLE,
                      subtitle: Language.instance.NO_COLLECTION_SUBTITLE,
                    ),
                  )
            : Consumer<Collection>(
                builder: (context, collection, _) => collection
                        .albums.isNotEmpty
                    ? DraggableScrollbar.semicircle(
                        heightScrollThumb: 56.0,
                        labelConstraints: BoxConstraints.tightFor(
                          width: 120.0,
                          height: 32.0,
                        ),
                        labelTextBuilder: (offset) {
                          final perTileHeight = helper.albumElementsPerRow > 1
                              ? (helper.albumTileHeight + tileMargin)
                              : kAlbumTileListViewHeight;
                          final index = (offset -
                                  (kMobileSearchBarHeight +
                                      2 * tileMargin +
                                      MediaQuery.of(context).padding.top)) ~/
                              perTileHeight;
                          final album = data
                              .data[index.clamp(
                            0,
                            data.data.length - 1,
                          )]
                              .first as Album;
                          switch (Collection.instance.albumsSort) {
                            case AlbumsSort.aToZ:
                              {
                                return Text(
                                  album.albumName[0].toUpperCase(),
                                  style:
                                      Theme.of(context).textTheme.displayLarge,
                                );
                              }
                            case AlbumsSort.dateAdded:
                              {
                                return Text(
                                  '${album.timeAdded.label}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium,
                                );
                              }
                            case AlbumsSort.year:
                              {
                                return Text(
                                  album.year,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium,
                                );
                              }
                            default:
                              return Text(
                                '',
                                style:
                                    Theme.of(context).textTheme.headlineMedium,
                              );
                          }
                        },
                        backgroundColor: Theme.of(context).cardTheme.color ??
                            Theme.of(context).cardColor,
                        controller: controller,
                        child: ListView(
                          controller: controller,
                          itemExtent: helper.albumElementsPerRow > 1
                              ? (helper.albumTileHeight + tileMargin)
                              : kAlbumTileListViewHeight,
                          padding: EdgeInsets.only(
                            top: MediaQuery.of(context).padding.top +
                                kMobileSearchBarHeight +
                                2 * tileMargin,
                          ),
                          children: data.widgets,
                        ),
                      )
                    : Container(
                        // padding: EdgeInsets.only(
                        //   top: MediaQuery.of(context).padding.top +
                        //       kMobileSearchBarHeight +
                        //       2 * tileMargin,
                        // ),
                        child: Center(
                          child: ExceptionWidget(
                            title: Language.instance.NO_COLLECTION_TITLE,
                            subtitle: Language.instance.NO_COLLECTION_SUBTITLE,
                          ),
                        ),
                      ),
              );
      },
    );
  }
}

class DesktopAlbumArtistTab extends StatefulWidget {
  DesktopAlbumArtistTab({Key? key}) : super(key: key);

  @override
  _DesktopAlbumArtistTabState createState() => _DesktopAlbumArtistTabState();
}

class _DesktopAlbumArtistTabState extends State<DesktopAlbumArtistTab> {
  final ValueNotifier<bool> hover = ValueNotifier<bool>(false);
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    scrollController.addListener(listener);
  }

  @override
  void dispose() {
    scrollController.removeListener(listener);
    scrollController.dispose();
    super.dispose();
  }

  void listener() {
    hover.value = !scrollController.offset.isZero;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Collection>(builder: (context, collection, _) {
      if (collection.albums.isEmpty)
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
      if (collection.albumsOrderType == OrderType.ascending) {
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
              style: Theme.of(context).textTheme.displayLarge,
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
            builder: (BuildContext context, int index) {
              final list = (collection.albumArtists[key]!.toList()
                ..sort((a, b) => a.albumName.compareTo(b.albumName)));
              return AlbumTile(
                height: height,
                width: width,
                album: list[index],
                key: ValueKey(list[index]),
              );
            },
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
          builder: (BuildContext context, int index) {
            final list = (collection.albumArtists.values.last.toList()
              ..sort((a, b) => a.albumName.compareTo(b.albumName)));
            return AlbumTile(
              height: height,
              width: width,
              album: list[index],
              key: ValueKey(list[index]),
            );
          },
          mainAxisAlignment: MainAxisAlignment.start,
        ));
        itemExtents.addAll(List.generate(
            widgets.length, (_) => (kAlbumTileHeight + tileMargin)));
      }
      if (collection.albumsOrderType == OrderType.descending) {
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
              style: Theme.of(context).textTheme.displayLarge,
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
            builder: (BuildContext context, int index) {
              final list = (collection.albumArtists[key]!.toList()
                ..sort((a, b) => a.albumName.compareTo(b.albumName)));
              return AlbumTile(
                height: height,
                width: width,
                album: list[index],
                key: ValueKey(list[index]),
              );
            },
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
          builder: (BuildContext context, int index) {
            final list = (collection.albumArtists.values.first.toList()
              ..sort((a, b) => a.albumName.compareTo(b.albumName)));
            return AlbumTile(
              height: height,
              width: width,
              album: list[index],
              key: ValueKey(list[index]),
            );
          },
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
                      offsets[collection.albumsOrderType == OrderType.ascending
                              ? collection.albumArtists.keys.elementAt(i)
                              : collection.albumArtists.keys.toList().elementAt(
                                  collection.albumArtists.keys.length -
                                      i -
                                      1)]! +
                          28.0,
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
                      collection.albumsOrderType == OrderType.ascending
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
                      style: Theme.of(context).textTheme.headlineMedium,
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
            child: Stack(
              children: [
                CustomListViewBuilder(
                  controller: scrollController,
                  itemCount: 1 + children.length,
                  itemExtents: [
                        28.0 + tileMargin,
                      ] +
                      itemExtents,
                  itemBuilder: (context, i) => i == 0
                      ? SortBarFixedHolder(
                          child: SortBar(
                            tab: 0,
                            hover: hover,
                            fixed: true,
                          ),
                        )
                      : children[i - 1],
                ),
                SortBar(
                  tab: 0,
                  hover: hover,
                  fixed: false,
                ),
              ],
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
  final bool forceDefaultStyleOnMobile;

  const AlbumTile({
    Key? key,
    required this.album,
    required this.height,
    required this.width,
    this.forceDefaultStyleOnMobile = false,
  }) : super(key: key);

  Future<void> action(BuildContext context) async {
    var result;
    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) => Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: albumPopupMenuItems(
            album,
            context,
          )
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
    await albumPopupMenuHandle(
      context,
      album,
      result,
    );
  }

  Widget build(BuildContext context) {
    final helper = DimensionsHelper(context);
    Iterable<Color>? palette;
    if (isMobile && forceDefaultStyleOnMobile) {
      return OpenContainer(
        closedColor:
            Theme.of(context).cardTheme.color ?? Theme.of(context).cardColor,
        closedElevation:
            Theme.of(context).cardTheme.elevation ?? kDefaultCardElevation,
        openElevation: 0.0,
        openColor: Theme.of(context).scaffoldBackgroundColor,
        closedBuilder: (context, open) => InkWell(
          onLongPress: () => action(context),
          onTap: () async {
            try {
              if (palette == null) {
                final result = await PaletteGenerator.fromImageProvider(
                  getAlbumArt(
                    album,
                    small: true,
                  ),
                );
                palette = result.colors;
              }
              await precacheImage(getAlbumArt(album), context);
              if (!Configuration.instance.stickyMiniplayer)
                MobileNowPlayingController.instance.hide();
            } catch (exception, stacktrace) {
              debugPrint(exception.toString());
              debugPrint(stacktrace.toString());
            }
            open();
          },
          child: Container(
            height: height,
            width: width,
            child: Column(
              children: [
                Ink.image(
                  image: getAlbumArt(
                    album,
                    small: true,
                    cacheWidth:
                        width * MediaQuery.of(context).devicePixelRatio ~/ 1,
                  ),
                  fit: BoxFit.cover,
                  height: width,
                  width: width,
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: helper.albumTileNormalDensity ? 12.0 : 8.0,
                    ),
                    width: width,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          album.albumName.overflow,
                          style: Theme.of(context)
                              .textTheme
                              .displayMedium
                              ?.copyWith(
                                fontSize: 18.0,
                                fontWeight: FontWeight.w700,
                              ),
                          textAlign: TextAlign.left,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Text(
                            [
                              if (!['', kUnknownArtist]
                                  .contains(album.albumArtistName))
                                album.albumArtistName,
                              if (!['', kUnknownYear].contains(album.year))
                                album.year,
                            ].join(' • '),
                            style: Theme.of(context).textTheme.displaySmall,
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
    return isDesktop
        ? Card(
            clipBehavior: Clip.antiAlias,
            elevation:
                Theme.of(context).cardTheme.elevation ?? kDefaultCardElevation,
            margin: EdgeInsets.zero,
            child: ContextMenuArea(
              onPressed: (e) async {
                final result = await showMenu(
                  context: context,
                  constraints: BoxConstraints(
                    maxWidth: double.infinity,
                  ),
                  position: RelativeRect.fromLTRB(
                    e.position.dx,
                    e.position.dy,
                    MediaQuery.of(context).size.width,
                    MediaQuery.of(context).size.width,
                  ),
                  items: albumPopupMenuItems(
                    album,
                    context,
                  ),
                );
                await albumPopupMenuHandle(
                  context,
                  album,
                  result,
                );
              },
              child: InkWell(
                onTap: () async {
                  Playback.instance.interceptPositionChangeRebuilds = true;
                  try {
                    await precacheImage(getAlbumArt(album), context);
                  } catch (exception, stacktrace) {
                    debugPrint(exception.toString());
                    debugPrint(stacktrace.toString());
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
                  Timer(const Duration(milliseconds: 400), () {
                    Playback.instance.interceptPositionChangeRebuilds = false;
                  });
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
                                style:
                                    Theme.of(context).textTheme.displayMedium,
                                textAlign: TextAlign.left,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 2),
                                child: Text(
                                  [
                                    if (!['', kUnknownArtist]
                                        .contains(album.albumArtistName))
                                      album.albumArtistName,
                                    if (!['', kUnknownYear]
                                        .contains(album.year))
                                      album.year,
                                  ].join(' • '),
                                  style: Theme.of(context)
                                      .textTheme
                                      .displaySmall
                                      ?.copyWith(
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
            ),
          )
        : helper.albumElementsPerRow == 1
            ? Material(
                color: Colors.transparent,
                child: OpenContainer(
                  closedColor: Colors.transparent,
                  closedElevation: 0.0,
                  openColor: Colors.transparent,
                  openElevation: 0.0,
                  openBuilder: (context, close) => AlbumScreen(
                    album: album,
                    palette: palette,
                  ),
                  closedBuilder: (context, open) => SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Divider(
                          height: 1.0,
                          thickness: 1.0,
                          indent: 76.0,
                        ),
                        InkWell(
                          onTap: () async {
                            try {
                              if (palette == null) {
                                final result =
                                    await PaletteGenerator.fromImageProvider(
                                        getAlbumArt(album, small: true));
                                palette = result.colors;
                              }
                              await precacheImage(getAlbumArt(album), context);
                              if (!Configuration.instance.stickyMiniplayer)
                                MobileNowPlayingController.instance.hide();
                            } catch (exception, stacktrace) {
                              debugPrint(exception.toString());
                              debugPrint(stacktrace.toString());
                            }
                            open();
                          },
                          onLongPress: () => action(context),
                          child: Container(
                            height: 64.0,
                            width: MediaQuery.of(context).size.width,
                            alignment: Alignment.center,
                            margin: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(width: 12.0),
                                Card(
                                  elevation:
                                      Theme.of(context).cardTheme.elevation ??
                                          kDefaultCardElevation,
                                  margin: EdgeInsets.zero,
                                  child: Padding(
                                    padding: EdgeInsets.all(2.0),
                                    child: ExtendedImage(
                                      image: getAlbumArt(album, small: true),
                                      height: 48.0,
                                      width: 48.0,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12.0),
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        album.albumName.overflow,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: Theme.of(context)
                                            .textTheme
                                            .displayMedium,
                                      ),
                                      const SizedBox(
                                        height: 2.0,
                                      ),
                                      Text(
                                        [
                                          if (!['', kUnknownArtist]
                                              .contains(album.albumArtistName))
                                            album.albumArtistName,
                                          if (!['', kUnknownYear]
                                              .contains(album.year))
                                            album.year,
                                        ].join(' • '),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: Theme.of(context)
                                            .textTheme
                                            .displaySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12.0),
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
                closedColor: Theme.of(context).cardTheme.color ??
                    Theme.of(context).cardColor,
                closedElevation: Theme.of(context).cardTheme.elevation ??
                    kDefaultCardElevation,
                openElevation: 0.0,
                openColor: Theme.of(context).scaffoldBackgroundColor,
                closedBuilder: (context, open) => InkWell(
                  onLongPress: () => action(context),
                  onTap: () async {
                    try {
                      if (palette == null) {
                        final result = await PaletteGenerator.fromImageProvider(
                          getAlbumArt(
                            album,
                            small: true,
                          ),
                        );
                        palette = result.colors;
                      }
                      await precacheImage(getAlbumArt(album), context);
                      if (!Configuration.instance.stickyMiniplayer)
                        MobileNowPlayingController.instance.hide();
                    } catch (exception, stacktrace) {
                      debugPrint(exception.toString());
                      debugPrint(stacktrace.toString());
                    }
                    open();
                  },
                  child: Container(
                    height: height,
                    width: width,
                    child: Column(
                      children: [
                        Ink.image(
                          image: getAlbumArt(
                            album,
                            small: true,
                            cacheWidth: width *
                                MediaQuery.of(context).devicePixelRatio ~/
                                1,
                          ),
                          fit: BoxFit.cover,
                          height: width,
                          width: width,
                        ),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal:
                                  helper.albumTileNormalDensity ? 12.0 : 8.0,
                            ),
                            width: width,
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  album.albumName.overflow,
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayMedium
                                      ?.copyWith(
                                        fontSize: helper.albumTileNormalDensity
                                            ? 18.0
                                            : 14.0,
                                        fontWeight:
                                            helper.albumTileNormalDensity
                                                ? FontWeight.w700
                                                : null,
                                      ),
                                  textAlign: TextAlign.left,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (helper.albumTileNormalDensity)
                                  Padding(
                                    padding: EdgeInsets.only(top: 2),
                                    child: Text(
                                      [
                                        if (!['', kUnknownArtist]
                                            .contains(album.albumArtistName))
                                          album.albumArtistName,
                                        if (!['', kUnknownYear]
                                            .contains(album.year))
                                          album.year,
                                      ].join(' • '),
                                      style: Theme.of(context)
                                          .textTheme
                                          .displaySmall,
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
  ScrollPhysics? physics = NeverScrollableScrollPhysics();

  @override
  void initState() {
    super.initState();
    if (isDesktop) {
      Timer(
        Duration(milliseconds: 300),
        () {
          if (widget.palette == null) {
            PaletteGenerator.fromImageProvider(
                    getAlbumArt(widget.album, small: true))
                .then((palette) {
              setState(() {
                if (palette.colors != null) {
                  color = palette.colors!.first;
                  secondary = palette.colors!.last;
                }
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
        controller
            .animateTo(
          0.0,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        )
            .then((_) {
          Timer(Duration(milliseconds: 50), () {
            setState(() {
              detailsLoaded = true;
              physics = null;
            });
          });
        });
      });
      if (widget.palette != null) {
        color = widget.palette?.first;
        secondary = widget.palette?.last;
      }
      controller.addListener(() {
        if (controller.offset < 36.0) {
          if (!detailsVisible) {
            setState(() {
              detailsVisible = true;
            });
          }
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
    const mobileSliverLabelHeight = 128.0;
    double mobileSliverContentHeight = MediaQuery.of(context).size.width;
    double mobileSliverExpandedHeight = mobileSliverContentHeight -
        MediaQuery.of(context).padding.top +
        mobileSliverLabelHeight;
    double mobileSliverFABYPos = mobileSliverContentHeight - 32.0;
    if (mobileSliverExpandedHeight >
        MediaQuery.of(context).size.height * 3 / 5) {
      mobileSliverExpandedHeight = MediaQuery.of(context).size.height * 3 / 5;
      mobileSliverContentHeight = mobileSliverExpandedHeight -
          mobileSliverLabelHeight +
          MediaQuery.of(context).padding.top;
      mobileSliverFABYPos = mobileSliverContentHeight - 32.0;
    }
    return Consumer<Collection>(
      builder: (context, value, child) {
        final tracks = widget.album.tracks.toList();
        tracks.sort(
          (first, second) =>
              first.discNumber.compareTo(second.discNumber) * 100000000 +
              first.trackNumber.compareTo(second.trackNumber) * 1000000 +
              first.trackName.compareTo(second.trackName) * 10000 +
              first.trackArtistNames
                      .join()
                      .compareTo(second.trackArtistNames.join()) *
                  100 +
              first.uri.toString().compareTo(second.uri.toString()),
        );
        return isDesktop
            ? Scaffold(
                body: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
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
                            elevation: Theme.of(context).cardTheme.elevation ??
                                kDefaultCardElevation,
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth: 12 / 6 * 720.0,
                                maxHeight: 720.0,
                              ),
                              width: MediaQuery.of(context).size.width - 136.0,
                              height:
                                  MediaQuery.of(context).size.height - 192.0,
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
                                                  ? Theme.of(context)
                                                      .dividerTheme
                                                      .color
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
                                                elevation: Theme.of(context)
                                                        .cardTheme
                                                        .elevation ??
                                                    kDefaultCardElevation,
                                                child: Stack(
                                                  alignment: Alignment.center,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.all(8.0),
                                                      child: ExtendedImage(
                                                        image: getAlbumArt(
                                                            widget.album),
                                                        constraints:
                                                            BoxConstraints(
                                                          minWidth: 360.0,
                                                          minHeight: 360.0,
                                                        ),
                                                      ),
                                                    ),
                                                    Positioned(
                                                      bottom: 0.0,
                                                      left: 0.0,
                                                      child: Padding(
                                                        padding: EdgeInsets.all(
                                                            16.0),
                                                        child: ClipOval(
                                                          child: Container(
                                                            height: 36.0,
                                                            width: 36.0,
                                                            color:
                                                                Colors.black54,
                                                            child: Material(
                                                              color: Colors
                                                                  .transparent,
                                                              child: IconButton(
                                                                onPressed: () {
                                                                  final resource =
                                                                      getAlbumArt(
                                                                              widget.album)
                                                                          as FileImage;
                                                                  // See: https://github.com/harmonoid/harmonoid/issues/322#issuecomment-1236133645
                                                                  // [Uri.parse] seems fail for some particular character sequences in the [File] path.
                                                                  // Thus, I'm launching direct [File] paths on Windows, which apparently seems to work.
                                                                  if (Platform
                                                                      .isWindows) {
                                                                    // ignore: deprecated_member_use
                                                                    launch(
                                                                      resource
                                                                          .file
                                                                          .path,
                                                                    );
                                                                  } else {
                                                                    // ignore: deprecated_member_use
                                                                    launch(
                                                                        'file://${resource.file.path}');
                                                                  }
                                                                },
                                                                icon: Icon(
                                                                  Icons.image,
                                                                  size: 20.0,
                                                                  color: Colors
                                                                      .white,
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
                                                        .displayLarge
                                                        ?.copyWith(
                                                            fontSize: 24.0),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  SizedBox(height: 8.0),
                                                  Text(
                                                    '${Language.instance.ARTIST}: ${widget.album.albumArtistName}\n${Language.instance.YEAR}: ${widget.album.year}\n${Language.instance.TRACK}: ${tracks.length}',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .displaySmall,
                                                    overflow:
                                                        TextOverflow.ellipsis,
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
                                                        ...tracks,
                                                        if (Configuration
                                                            .instance
                                                            .seamlessPlayback)
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
                                                    tooltip: Language
                                                        .instance.PLAY_NOW,
                                                  ),
                                                  SizedBox(
                                                    width: 8.0,
                                                  ),
                                                  FloatingActionButton(
                                                    heroTag: 'shuffle',
                                                    onPressed: () {
                                                      Playback.instance.open([
                                                        ...tracks,
                                                      ]..shuffle());
                                                    },
                                                    mini: true,
                                                    child: Icon(
                                                      Icons.shuffle,
                                                    ),
                                                    tooltip: Language
                                                        .instance.SHUFFLE,
                                                  ),
                                                  SizedBox(
                                                    width: 8.0,
                                                  ),
                                                  FloatingActionButton(
                                                    heroTag:
                                                        'add_to_now_playing',
                                                    onPressed: () {
                                                      Playback.instance.add(
                                                        tracks,
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
                                        const Divider(
                                          height: 1.0,
                                          thickness: 1.0,
                                        ),
                                        LayoutBuilder(
                                          builder: (context, constraints) =>
                                              Column(
                                            children: [
                                                  Row(
                                                    children: [
                                                      Container(
                                                        width: 64.0,
                                                        height: 56.0,
                                                        padding:
                                                            EdgeInsets.only(
                                                                right: 8.0),
                                                        alignment:
                                                            Alignment.center,
                                                        child: Text(
                                                          '#',
                                                          style: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .displayMedium,
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Container(
                                                          height: 56.0,
                                                          padding:
                                                              EdgeInsets.only(
                                                                  right: 8.0),
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Text(
                                                            Language
                                                                .instance.TRACK,
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .displayMedium,
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Container(
                                                          height: 56.0,
                                                          padding:
                                                              EdgeInsets.only(
                                                                  right: 8.0),
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Text(
                                                            Language.instance
                                                                .ARTIST,
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .displayMedium,
                                                          ),
                                                        ),
                                                      ),
                                                      Container(
                                                        width: 64.0,
                                                        height: 56.0,
                                                      ),
                                                    ],
                                                  ),
                                                  const Divider(
                                                    height: 1.0,
                                                    thickness: 1.0,
                                                  ),
                                                ] +
                                                (tracks
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
                                                          onPointerUp:
                                                              (e) async {
                                                            if (!reactToSecondaryPress)
                                                              return;
                                                            final result =
                                                                await showMenu(
                                                              context: context,
                                                              constraints:
                                                                  BoxConstraints(
                                                                maxWidth: double
                                                                    .infinity,
                                                              ),
                                                              position:
                                                                  RelativeRect
                                                                      .fromLTRB(
                                                                e.position.dx,
                                                                e.position.dy,
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                              ),
                                                              items:
                                                                  trackPopupMenuItems(
                                                                track.value,
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
                                                            color: Colors
                                                                .transparent,
                                                            child: InkWell(
                                                              onTap: () {
                                                                Playback
                                                                    .instance
                                                                    .open(
                                                                  [
                                                                    ...tracks,
                                                                    if (Configuration
                                                                        .instance
                                                                        .seamlessPlayback)
                                                                      ...[
                                                                        ...Collection
                                                                            .instance
                                                                            .tracks
                                                                      ]..shuffle(),
                                                                  ],
                                                                  index:
                                                                      track.key,
                                                                );
                                                              },
                                                              child: Row(
                                                                children: [
                                                                  Container(
                                                                    width: 64.0,
                                                                    height:
                                                                        48.0,
                                                                    padding: EdgeInsets.only(
                                                                        right:
                                                                            8.0),
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    child: hovered ==
                                                                            track.key
                                                                        ? IconButton(
                                                                            onPressed:
                                                                                () {
                                                                              Playback.instance.open(
                                                                                tracks,
                                                                                index: track.key,
                                                                              );
                                                                            },
                                                                            icon:
                                                                                Icon(Icons.play_arrow),
                                                                            splashRadius:
                                                                                20.0,
                                                                          )
                                                                        : Text(
                                                                            '${track.value.trackNumber}',
                                                                            style:
                                                                                Theme.of(context).textTheme.headlineMedium,
                                                                          ),
                                                                  ),
                                                                  Expanded(
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          48.0,
                                                                      padding: EdgeInsets.only(
                                                                          right:
                                                                              8.0),
                                                                      alignment:
                                                                          Alignment
                                                                              .centerLeft,
                                                                      child:
                                                                          Text(
                                                                        track
                                                                            .value
                                                                            .trackName,
                                                                        style: Theme.of(context)
                                                                            .textTheme
                                                                            .headlineMedium,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          48.0,
                                                                      padding: EdgeInsets.only(
                                                                          right:
                                                                              8.0),
                                                                      alignment:
                                                                          Alignment
                                                                              .centerLeft,
                                                                      child:
                                                                          () {
                                                                        final elements =
                                                                            <TextSpan>[];
                                                                        track
                                                                            .value
                                                                            .trackArtistNames
                                                                            .map(
                                                                          (e) =>
                                                                              TextSpan(
                                                                            text:
                                                                                e,
                                                                            recognizer: TapGestureRecognizer()
                                                                              ..onTap = () {
                                                                                Playback.instance.interceptPositionChangeRebuilds = true;
                                                                                Navigator.of(context).push(
                                                                                  PageRouteBuilder(
                                                                                    pageBuilder: ((context, animation, secondaryAnimation) => FadeThroughTransition(
                                                                                          animation: animation,
                                                                                          secondaryAnimation: secondaryAnimation,
                                                                                          child: ArtistScreen(
                                                                                            artist: Collection.instance.artistsSet.lookup(Artist(artistName: e))!,
                                                                                          ),
                                                                                        )),
                                                                                  ),
                                                                                );
                                                                                Timer(const Duration(milliseconds: 400), () {
                                                                                  Playback.instance.interceptPositionChangeRebuilds = false;
                                                                                });
                                                                              },
                                                                          ),
                                                                        )
                                                                            .forEach((element) {
                                                                          elements
                                                                              .add(element);
                                                                          elements
                                                                              .add(TextSpan(text: ', '));
                                                                        });
                                                                        elements
                                                                            .removeLast();
                                                                        return HyperLink(
                                                                          style: Theme.of(context)
                                                                              .textTheme
                                                                              .headlineMedium,
                                                                          text:
                                                                              TextSpan(
                                                                            children:
                                                                                elements,
                                                                          ),
                                                                        );
                                                                      }(),
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    width: 64.0,
                                                                    height:
                                                                        56.0,
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
                                                                        track
                                                                            .value,
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
                    NowPlayingBarScrollHideNotifier(
                      child: CustomScrollView(
                        controller: controller,
                        physics: physics,
                        slivers: [
                          SliverAppBar(
                            systemOverlayStyle: SystemUiOverlayStyle(
                              statusBarColor: Colors.transparent,
                              statusBarIconBrightness: detailsVisible
                                  ? Brightness.light
                                  : (color?.computeLuminance() ??
                                              (Theme.of(context).brightness ==
                                                      Brightness.dark
                                                  ? 0.0
                                                  : 1.0)) <
                                          0.5
                                      ? Brightness.light
                                      : Brightness.dark,
                            ),
                            expandedHeight: mobileSliverExpandedHeight,
                            pinned: true,
                            leading: IconButton(
                              onPressed: Navigator.of(context).maybePop,
                              icon: Icon(
                                Icons.arrow_back,
                                color: detailsVisible
                                    ? Theme.of(context)
                                        .extension<IconColors>()
                                        ?.appBarDarkIconColor
                                    : [
                                        Theme.of(context)
                                            .extension<IconColors>()
                                            ?.appBarLightIconColor,
                                        Theme.of(context)
                                            .extension<IconColors>()
                                            ?.appBarDarkIconColor,
                                      ][(color?.computeLuminance() ??
                                                (Theme.of(context).brightness ==
                                                        Brightness.dark
                                                    ? 0.0
                                                    : 1.0)) >
                                            0.5
                                        ? 0
                                        : 1],
                              ),
                              iconSize: 24.0,
                              splashRadius: 20.0,
                            ),
                            forceElevated: true,
                            actions: [
                              IconButton(
                                onPressed: () => Playback.instance.add(tracks),
                                tooltip: Language.instance.ADD_TO_NOW_PLAYING,
                                icon: Icon(
                                  Icons.queue_music,
                                  color: detailsVisible
                                      ? Theme.of(context)
                                          .extension<IconColors>()
                                          ?.appBarActionDarkIconColor
                                      : [
                                          Theme.of(context)
                                              .extension<IconColors>()
                                              ?.appBarActionLightIconColor,
                                          Theme.of(context)
                                              .extension<IconColors>()
                                              ?.appBarActionDarkIconColor,
                                        ][(color?.computeLuminance() ??
                                                  (Theme.of(context)
                                                              .brightness ==
                                                          Brightness.dark
                                                      ? 0.0
                                                      : 1.0)) >
                                              0.5
                                          ? 0
                                          : 1],
                                ),
                                iconSize: 24.0,
                                splashRadius: 20.0,
                              ),
                              IconButton(
                                onPressed: () async {
                                  final sdk = StorageRetriever.instance.version;
                                  if (Platform.isAndroid) {
                                    if (sdk <= 29) {
                                      // Android 10 or below need an [AlertDialog] for confirmation.
                                      await showDialog(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: Text(
                                            Language.instance
                                                .COLLECTION_ALBUM_DELETE_DIALOG_HEADER,
                                          ),
                                          content: Text(
                                            Language.instance
                                                .COLLECTION_ALBUM_DELETE_DIALOG_BODY
                                                .replaceAll(
                                              'NAME',
                                              widget.album.albumName,
                                            ),
                                            style: Theme.of(ctx)
                                                .textTheme
                                                .displaySmall,
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () async {
                                                await Collection.instance
                                                    .delete(widget.album);
                                                await Navigator.of(ctx)
                                                    .maybePop();
                                                await Navigator.of(context)
                                                    .maybePop();
                                              },
                                              child:
                                                  Text(Language.instance.YES),
                                            ),
                                            TextButton(
                                              onPressed:
                                                  Navigator.of(ctx).maybePop,
                                              child: Text(Language.instance.NO),
                                            ),
                                          ],
                                        ),
                                      );
                                    } else if (sdk > 29) {
                                      await Collection.instance
                                          .delete(widget.album);
                                      await Navigator.of(context).maybePop();
                                    }
                                  }
                                },
                                tooltip: Language.instance.DELETE,
                                icon: Icon(
                                  Icons.delete,
                                  color: detailsVisible
                                      ? Theme.of(context)
                                          .extension<IconColors>()
                                          ?.appBarActionDarkIconColor
                                      : [
                                          Theme.of(context)
                                              .extension<IconColors>()
                                              ?.appBarActionLightIconColor,
                                          Theme.of(context)
                                              .extension<IconColors>()
                                              ?.appBarActionDarkIconColor,
                                        ][(color?.computeLuminance() ??
                                                  (Theme.of(context)
                                                              .brightness ==
                                                          Brightness.dark
                                                      ? 0.0
                                                      : 1.0)) >
                                              0.5
                                          ? 0
                                          : 1],
                                ),
                                iconSize: 24.0,
                                splashRadius: 20.0,
                              ),
                              const SizedBox(width: 8.0),
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
                                      .titleLarge
                                      ?.copyWith(
                                        color: [
                                          Color(0xFF212121),
                                          Colors.white,
                                        ][(color?.computeLuminance() ??
                                                    (Theme.of(context)
                                                                .brightness ==
                                                            Brightness.dark
                                                        ? 0.0
                                                        : 1.0)) >
                                                0.5
                                            ? 0
                                            : 1],
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            backgroundColor: color,
                            flexibleSpace: Stack(
                              children: [
                                FlexibleSpaceBar(
                                  background: Column(
                                    children: [
                                      Stack(
                                        children: [
                                          ExtendedImage(
                                            image: getAlbumArt(widget.album),
                                            fit: BoxFit.cover,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            height: mobileSliverContentHeight,
                                          ),
                                          Positioned.fill(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.black26,
                                                    Colors.transparent,
                                                  ],
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  stops: [
                                                    0.0,
                                                    0.5,
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
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
                                            height: mobileSliverLabelHeight,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            padding: EdgeInsets.all(16.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  widget
                                                      .album.albumName.overflow,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleLarge
                                                      ?.copyWith(
                                                        color: [
                                                          Color(0xFF212121),
                                                          Colors.white,
                                                        ][(color?.computeLuminance() ??
                                                                    (Theme.of(context).brightness ==
                                                                            Brightness.dark
                                                                        ? 0.0
                                                                        : 1.0)) >
                                                                0.5
                                                            ? 0
                                                            : 1],
                                                        fontSize: 24.0,
                                                      ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                if (!['', kUnknownArtist]
                                                    .contains(widget.album
                                                        .albumArtistName)) ...[
                                                  const SizedBox(height: 4.0),
                                                  Text(
                                                    widget.album.albumArtistName
                                                        .overflow,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .displayMedium
                                                        ?.copyWith(
                                                          color: [
                                                            Color(0xFF363636),
                                                            Color(0xFFD9D9D9),
                                                          ][(color?.computeLuminance() ??
                                                                      (Theme.of(context).brightness ==
                                                                              Brightness.dark
                                                                          ? 0.0
                                                                          : 1.0)) >
                                                                  0.5
                                                              ? 0
                                                              : 1],
                                                          fontSize: 16.0,
                                                        ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                                if (!['', kUnknownYear]
                                                    .contains(
                                                        widget.album.year)) ...[
                                                  const SizedBox(height: 2.0),
                                                  Text(
                                                    '${widget.album.year}',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .displayMedium
                                                        ?.copyWith(
                                                          color: [
                                                            Color(0xFF363636),
                                                            Color(0xFFD9D9D9),
                                                          ][(color?.computeLuminance() ??
                                                                      (Theme.of(context).brightness ==
                                                                              Brightness.dark
                                                                          ? 0.0
                                                                          : 1.0)) >
                                                                  0.5
                                                              ? 0
                                                              : 1],
                                                          fontSize: 16.0,
                                                        ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  top: mobileSliverFABYPos,
                                  right: 16.0 + 64.0,
                                  child: TweenAnimationBuilder(
                                    curve: Curves.easeOut,
                                    tween: Tween<double>(
                                        begin: 0.0,
                                        end: detailsVisible ? 1.0 : 0.0),
                                    duration: Duration(milliseconds: 200),
                                    builder: (context, value, _) =>
                                        Transform.scale(
                                      scale: value as double,
                                      child: Transform.rotate(
                                        angle: value * pi + pi,
                                        child: FloatingActionButton(
                                          heroTag: 'play_now',
                                          backgroundColor: secondary,
                                          foregroundColor: [
                                            Colors.white,
                                            Color(0xFF212121)
                                          ][(secondary?.computeLuminance() ??
                                                      0.0) >
                                                  0.5
                                              ? 1
                                              : 0],
                                          child: Icon(Icons.play_arrow),
                                          onPressed: () {
                                            Playback.instance.open([
                                              ...tracks,
                                              if (Configuration
                                                  .instance.seamlessPlayback)
                                                ...[
                                                  ...Collection.instance.tracks
                                                ]..shuffle(),
                                            ]);
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: mobileSliverFABYPos,
                                  right: 16.0,
                                  child: TweenAnimationBuilder(
                                    curve: Curves.easeOut,
                                    tween: Tween<double>(
                                        begin: 0.0,
                                        end: detailsVisible ? 1.0 : 0.0),
                                    duration: Duration(milliseconds: 200),
                                    builder: (context, value, _) =>
                                        Transform.scale(
                                      scale: value as double,
                                      child: Transform.rotate(
                                        angle: value * pi + pi,
                                        child: FloatingActionButton(
                                          heroTag: 'shuffle',
                                          backgroundColor: secondary,
                                          foregroundColor: [
                                            Colors.white,
                                            Color(0xFF212121)
                                          ][(secondary?.computeLuminance() ??
                                                      0.0) >
                                                  0.5
                                              ? 1
                                              : 0],
                                          child: Icon(Icons.shuffle),
                                          onPressed: () {
                                            Playback.instance.open(
                                              [...tracks]..shuffle(),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
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
                                      ...tracks,
                                      if (Configuration
                                          .instance.seamlessPlayback)
                                        ...[...Collection.instance.tracks]
                                          ..shuffle(),
                                    ],
                                    index: i,
                                  ),
                                  onLongPress: () async {
                                    var result;
                                    await showModalBottomSheet(
                                      isScrollControlled: true,
                                      context: context,
                                      builder: (context) => Container(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: trackPopupMenuItems(
                                                  tracks[i], context)
                                              .map(
                                                (item) => PopupMenuItem(
                                                  child: item.child,
                                                  onTap: () =>
                                                      result = item.value,
                                                ),
                                              )
                                              .toList(),
                                        ),
                                      ),
                                    );
                                    await trackPopupMenuHandle(
                                      context,
                                      tracks[i],
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
                                        width:
                                            MediaQuery.of(context).size.width,
                                        alignment: Alignment.center,
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 4.0),
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
                                                '${tracks[i].trackNumber}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .displaySmall
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
                                                    tracks[i]
                                                        .trackName
                                                        .overflow,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .displayMedium,
                                                  ),
                                                  const SizedBox(
                                                    height: 2.0,
                                                  ),
                                                  Text(
                                                    [
                                                      tracks[i]
                                                              .duration
                                                              ?.label ??
                                                          Duration.zero.label,
                                                      if (!tracks[i]
                                                          .hasNoAvailableArtists)
                                                        tracks[i]
                                                            .trackArtistNames
                                                            .take(2)
                                                            .join(', '),
                                                    ].join(' • '),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .displaySmall,
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
                                                    isScrollControlled: true,
                                                    context: context,
                                                    builder: (context) =>
                                                        Container(
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children:
                                                            trackPopupMenuItems(
                                                                    tracks[i],
                                                                    context)
                                                                .map(
                                                                  (item) =>
                                                                      PopupMenuItem(
                                                                    child: item
                                                                        .child,
                                                                    onTap: () =>
                                                                        result =
                                                                            item.value,
                                                                  ),
                                                                )
                                                                .toList(),
                                                      ),
                                                    ),
                                                  );
                                                  await trackPopupMenuHandle(
                                                    context,
                                                    tracks[i],
                                                    result,
                                                    recursivelyPopNavigatorOnDeleteIf:
                                                        () => widget.album
                                                            .tracks.isEmpty,
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
                                        thickness: 1.0,
                                        indent: 80.0,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              childCount: tracks.length,
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
                    ),
                  ],
                ),
              );
      },
    );
  }
}
