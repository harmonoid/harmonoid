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

import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:drop_shadow/drop_shadow.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:media_library/media_library.dart';
import 'package:extended_image/extended_image.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';

import 'package:harmonoid/interface/modern_layout/modern_collection/modern_track.dart';
import 'package:harmonoid/interface/modern_layout/rendering_modern.dart';
import 'package:harmonoid/interface/modern_layout/utils_modern/broken_icons.dart';
import 'package:harmonoid/interface/modern_layout/utils_modern/widgets_modern.dart';
import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/interface/collection/artist.dart';
import 'package:harmonoid/state/mobile_now_playing_controller.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/dimensions.dart';
import 'package:harmonoid/utils/storage_retriever.dart';
import 'package:harmonoid/utils/palette_generator.dart';
import 'package:harmonoid/constants/language.dart';

class AlbumTabModern extends StatefulWidget {
  final List<Album>? albumsList;
  AlbumTabModern({
    Key? key,
    this.albumsList,
  }) : super(key: key);

  @override
  _AlbumTabModernState createState() => _AlbumTabModernState();
}

class _AlbumTabModernState extends State<AlbumTabModern> {
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
    double dynamicHeightForStaggeredGV = helper.albumElementsPerRow == 4
        ? helper.albumTileHeight * 1.1
        : helper.albumElementsPerRow == 3
            ? helper.albumTileHeight * 1.05
            : helper.albumTileHeight;
    double modernkMobileTileMargin = kMobileTileMargin * 0.6;
    return Consumer<Collection>(
      builder: (context, collection, _) {
        if (collection.albumsSort == AlbumsSort.artist && isDesktop)
          return DesktopAlbumArtistTabModern();

        final data = tileGridListWidgetsWithScrollbarSupport(
          context: context,
          tileWidth: helper.albumTileWidth,
          tileHeight: helper.albumTileHeight,
          elementsPerRow: helper.albumElementsPerRow,
          widgetCount: Collection.instance.albums.length,
          builder: (BuildContext context, int index) => AlbumTileModern(
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
                              ? Configuration.instance.useAlbumStaggeredGridView
                                  ? (controller.position.maxScrollExtent /
                                          (((Collection.instance.albums.length +
                                                  (helper.albumElementsPerRow ==
                                                          2
                                                      ? 1
                                                      : helper.albumElementsPerRow ==
                                                              3
                                                          ? -2
                                                          : -6)) /
                                              helper.albumElementsPerRow))) +
                                      tileMargin
                                  : (dynamicHeightForStaggeredGV + tileMargin)
                              : Configuration.instance.albumListTileHeight +
                                  kMobileTileMargin;
                          final index = (offset -
                                  (kMobileSearchBarHeightModern +
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
                                  '${getDateFormatted(album.year)}',
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
                        child: MasonryGridView.builder(
                          controller: controller,
                          padding: EdgeInsets.only(
                              top: MediaQuery.of(context).padding.top +
                                  kMobileSearchBarHeightModern +
                                  2 * tileMargin,
                              bottom: Configuration.instance.stickyMiniplayer &&
                                      !MobileNowPlayingController
                                          .instance.isHidden
                                  ? kMobileNowPlayingBarHeight +
                                      kMobileBottomPaddingStickyMiniplayer
                                  : kMobileBottomPaddingStickyMiniplayer,
                              left: modernkMobileTileMargin,
                              right: modernkMobileTileMargin),
                          shrinkWrap: true,
                          mainAxisSpacing: kMobileTileMargin,
                          crossAxisSpacing: modernkMobileTileMargin,
                          itemBuilder: (BuildContext context, int index) =>
                              AlbumTileModern(
                            width: helper.albumTileWidth,
                            height: dynamicHeightForStaggeredGV,
                            album: widget.albumsList?[index] ??
                                collection.albums[index],
                            key: ValueKey(widget.albumsList?[index] ??
                                collection.albums[index]),
                          ),
                          itemCount: widget.albumsList?.length ??
                              collection.albums.length,
                          gridDelegate:
                              SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: helper.albumElementsPerRow),
                        )
                        // : ListView(
                        //     controller: controller,
                        //     itemExtent: helper.albumElementsPerRow > 1
                        //         ? (helper.albumTileHeight + tileMargin)
                        //         : Configuration
                        //             .instance.albumListTileHeight,
                        //     padding: EdgeInsets.only(
                        //       top: MediaQuery.of(context).padding.top +
                        //           kMobileSearchBarHeightModern +
                        //           2 * tileMargin,
                        //     ),
                        //     children: data.widgets,
                        //   ),

                        //   tileGridListWidgetsWithScrollbarSupport(
                        //   context: context,
                        //   tileWidth: helper.albumTileWidth,
                        //   tileHeight: helper.albumTileHeight,
                        //   elementsPerRow: helper.albumElementsPerRow,
                        //   widgetCount: Collection.instance.albums.length,
                        //   builder: (BuildContext context, int index) => AlbumTileModern(
                        //     width: helper.albumTileWidth,
                        //     height: helper.albumTileHeight,
                        //     album: Collection.instance.albums[index],
                        //     key: ValueKey(Collection.instance.albums[index]),
                        //   ),
                        // )
                        )
                    : Container(
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top +
                              kMobileSearchBarHeightModern +
                              2 * tileMargin,
                        ),
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

class DesktopAlbumArtistTabModern extends StatefulWidget {
  DesktopAlbumArtistTabModern({Key? key}) : super(key: key);

  @override
  _DesktopAlbumArtistTabModernState createState() =>
      _DesktopAlbumArtistTabModernState();
}

class _DesktopAlbumArtistTabModernState
    extends State<DesktopAlbumArtistTabModern> {
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
              return AlbumTileModern(
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
            return AlbumTileModern(
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
              return AlbumTileModern(
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
            return AlbumTileModern(
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
              padding: EdgeInsets.only(
                top: tileMargin / 2.0,
              ),
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

class AlbumTileModern extends StatelessWidget {
  final double height;
  final double width;
  final Album album;
  final bool forceDefaultStyleOnMobile;
  final bool forceDisableOnePerRow;
  final bool? forceDisableStaggered;

  const AlbumTileModern({
    Key? key,
    required this.album,
    required this.height,
    required this.width,
    this.forceDefaultStyleOnMobile = false,
    this.forceDisableOnePerRow = false,
    this.forceDisableStaggered,
  }) : super(key: key);

  // Future<void> action(BuildContext context) async {
  //   var result;
  //   await showModalBottomSheet(
  //     isScrollControlled: true,
  //     context: context,
  //     builder: (context) => Container(
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: albumPopupMenuItemsModern(
  //           album,
  //           context,
  //         )
  //             .map(
  //               (item) => PopupMenuItem(
  //                 child: item.child,
  //                 onTap: () => result = item.value,
  //               ),
  //             )
  //             .toList(),
  //       ),
  //     ),
  //   );
  //   await albumPopupMenuHandleModern(
  //     context,
  //     album,
  //     result,
  //   );
  // }

  Widget build(BuildContext context) {
    final helper = DimensionsHelper(context);
    Iterable<Color>? palette;
    final tracks = album.tracks.toList();

    String formattedTotalAlbumDuration =
        getTotalTracksDurationFormatted(tracks: album.tracks.toList());

    Widget columnHavingAlbumInfo = Container(
      padding: EdgeInsets.symmetric(
        horizontal: helper.albumTileNormalDensity ? 12.0 : 8.0,
      ),
      height: helper.albumElementsPerRow == 4
          ? height * 0.34
          : helper.albumElementsPerRow == 3
              ? height * 0.28
              : height * 0.22,

      // height: Configuration.instance.useAlbumStaggeredGridView
      //     ? Configuration.instance.albumCardTopRightDate &&
      //             ['', kUnknownArtist].contains(album.albumArtistName)
      //         ? helper.albumElementsPerRow == 4
      //             ? height * 0.34
      //             : helper.albumElementsPerRow == 3
      //                 ? height * 0.28
      //                 : height * 0.22
      //         : height * 0.28
      //     : null,
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            album.albumName.overflow,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontSize: width * 0.095,
                  fontWeight:
                      helper.albumTileNormalDensity ? FontWeight.w600 : null,
                ),
            textAlign: TextAlign.left,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (helper.albumTileNormalDensity)
            Padding(
              padding: const EdgeInsets.only(top: 0.0),
              child: Configuration.instance.albumCardTopRightDate ||
                      !['', kUnknownYear].contains(album.year)
                  ? (!['', kUnknownArtist].contains(album.albumArtistName))
                      ? Text(
                          album.albumArtistName,
                          style: Theme.of(context).textTheme.displaySmall,
                          maxLines: 1,
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                        )
                      : SizedBox()
                  : Text(
                      [
                        if (!['', kUnknownArtist]
                            .contains(album.albumArtistName))
                          album.albumArtistName,
                        if (!['', kUnknownYear].contains(album.year))
                          '${getDateFormatted(album.year)}',
                      ].join(' • '),
                      style: Theme.of(context).textTheme.displaySmall,
                      maxLines: 1,
                      textAlign: TextAlign.left,
                      overflow: TextOverflow.ellipsis,
                    ),
            ),
          FittedBox(
            child: Padding(
              padding: const EdgeInsets.only(top: 2.0, bottom: 2.0),
              child: Text(
                [
                  formattedTotalAlbumDuration,
                  '${tracks.length} Track${tracks.length == 1 ? "" : "s"}'
                ].join(' • '),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: Theme.of(context)
                    .textTheme
                    .displaySmall
                    ?.copyWith(fontSize: width * 0.08),
              ),
            ),
          ),
        ],
      ),
    );
    if (isMobile && forceDefaultStyleOnMobile) {
      return OpenContainer(
        closedColor:
            Theme.of(context).cardTheme.color ?? Theme.of(context).cardColor,
        closedElevation:
            Theme.of(context).cardTheme.elevation ?? kDefaultCardElevation,
        openElevation: 0.0,
        openColor: Theme.of(context).scaffoldBackgroundColor,
        closedBuilder: (context, open) => InkWell(
          onLongPress: () => showAlbumDialog(context, album),
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
                                '${getDateFormatted(album.year)}',
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
        openBuilder: (context, _) => AlbumScreenModern(
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
                        child: AlbumScreenModern(
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
                                      '${getDateFormatted(album.year)}',
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
        : helper.albumElementsPerRow == 1 && !forceDisableOnePerRow
            ? Material(
                borderRadius: BorderRadius.circular(
                    Configuration.instance.albumListTileHeight *
                        0.2 *
                        Configuration.instance.borderRadiusMultiplier),
                color: Theme.of(context).cardTheme.color?.withAlpha(140),
                child: OpenContainer(
                  closedColor: Colors.transparent,
                  closedElevation: 0.0,
                  openColor: Colors.transparent,
                  openElevation: 0.0,
                  openBuilder: (context, close) => AlbumScreenModern(
                    album: album,
                    palette: palette,
                  ),
                  closedBuilder: (context, open) => SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Divider(
                          height: 0.0,
                          thickness: 5.0,
                          indent: 0.0,
                          color: Colors.transparent,
                        ),
                        InkWell(
                          customBorder: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(Configuration
                                    .instance.albumListTileHeight *
                                0.2 *
                                Configuration.instance.borderRadiusMultiplier),
                          ),
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
                          onLongPress: () => showAlbumDialog(context, album),
                          child: Container(
                            height: Configuration.instance.albumListTileHeight,
                            width: MediaQuery.of(context).size.width,
                            alignment: Alignment.center,
                            margin: const EdgeInsets.symmetric(vertical: 0.0),
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(width: 12.0),
                                Padding(
                                  padding: EdgeInsets.all(2.0),
                                  child: SizedBox(
                                    width: Configuration
                                        .instance.albumThumbnailSizeinList,
                                    height: Configuration
                                        .instance.albumThumbnailSizeinList,
                                    child: Center(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10 *
                                            Configuration.instance
                                                .borderRadiusMultiplier),
                                        child: DropShadow(
                                          borderRadius: 10 *
                                              Configuration.instance
                                                  .borderRadiusMultiplier,
                                          blurRadius: Configuration
                                                  .instance.enableGlowEffect
                                              ? 2
                                              : 0,
                                          spread: Configuration
                                                  .instance.enableGlowEffect
                                              ? 0.8
                                              : 0,
                                          offset: Offset(0, 1),
                                          child: ExtendedImage(
                                            image: Image(
                                                    image: getAlbumArt(album,
                                                        small: true))
                                                .image,
                                            fit: BoxFit.cover,
                                            width: Configuration.instance
                                                    .forceSquaredAlbumThumbnail
                                                ? MediaQuery.of(context)
                                                    .size
                                                    .width
                                                : null,
                                            height: Configuration.instance
                                                    .forceSquaredAlbumThumbnail
                                                ? MediaQuery.of(context)
                                                    .size
                                                    .width
                                                : null,
                                          ),
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
                                      if (!['', kUnknownArtist]
                                          .contains(album.albumArtistName))
                                        Text(
                                          album.albumArtistName,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: Theme.of(context)
                                              .textTheme
                                              .displaySmall,
                                        ),
                                      Text(
                                        [
                                          if (!['', kUnknownYear]
                                              .contains(album.year))
                                            '${getDateFormatted(album.year)}',
                                          '${tracks.length} Track${tracks.length == 1 ? "" : "s"}',
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
                                Text(
                                  formattedTotalAlbumDuration,
                                  style:
                                      Theme.of(context).textTheme.displaySmall,
                                ),
                                const SizedBox(width: 12.0),
                                Container(
                                  width: 24,
                                  height: 24,
                                  margin: EdgeInsets.all(2),
                                  alignment: Alignment.center,
                                  child: RotatedBox(
                                    quarterTurns: 1,
                                    child: Icon(
                                      Broken.more,
                                      size: 20,
                                    ),
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
                closedShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        12 * Configuration.instance.borderRadiusMultiplier)),
                closedColor: Theme.of(context).cardTheme.color ??
                    Theme.of(context).cardColor,
                closedElevation: Theme.of(context).cardTheme.elevation ??
                    kDefaultCardElevation,
                openElevation: 0.0,
                openColor: Theme.of(context).scaffoldBackgroundColor,
                closedBuilder: (context, open) => InkWell(
                  onLongPress: () => showAlbumDialog(context, album),
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
                    height: Configuration.instance.useAlbumStaggeredGridView
                        ? null
                        : height,
                    width: width,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12 *
                            Configuration.instance.borderRadiusMultiplier)),
                    child: Stack(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(12 *
                                        Configuration
                                            .instance.borderRadiusMultiplier),
                                    bottom: Radius.circular(8.0 *
                                        Configuration
                                            .instance.borderRadiusMultiplier)),
                                child: DropShadow(
                                  borderRadius: 8 *
                                      Configuration
                                          .instance.borderRadiusMultiplier,
                                  blurRadius:
                                      Configuration.instance.enableGlowEffect
                                          ? 2
                                          : 0,
                                  spread:
                                      Configuration.instance.enableGlowEffect
                                          ? 0.8
                                          : 0,
                                  offset: Offset(0, 1),
                                  child: Stack(
                                    children: [
                                      ExtendedImage(
                                        image: Image(
                                            image: getAlbumArt(
                                          album,
                                          small: true,
                                          cacheWidth: width *
                                              MediaQuery.of(context)
                                                  .devicePixelRatio ~/
                                              1,
                                        )).image,
                                        fit: BoxFit.cover,
                                        width: width,
                                        height: Configuration.instance
                                                .useAlbumStaggeredGridView
                                            ? null
                                            : width,
                                      ),
                                      if (Configuration
                                              .instance.albumCardTopRightDate &&
                                          !['', kUnknownYear]
                                              .contains(album.year))
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child: BlurryContainer(
                                            // width: width * 0.5,
                                            height: helper
                                                        .albumElementsPerRow ==
                                                    4
                                                ? height * 0.13
                                                : helper.albumElementsPerRow ==
                                                        3
                                                    ? height * 0.12
                                                    : null,
                                            blur: Configuration
                                                    .instance.enableBlurEffect
                                                ? 3
                                                : 0,
                                            color: Configuration
                                                    .instance.enableBlurEffect
                                                ? Theme.of(context)
                                                    .cardColor
                                                    .withAlpha(60)
                                                : Theme.of(context)
                                                    .cardColor
                                                    .withAlpha(160),
                                            padding: EdgeInsets.all(4),
                                            borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(10 *
                                                  Configuration.instance
                                                      .borderRadiusMultiplier),
                                              topRight: Radius.circular(8 *
                                                  Configuration.instance
                                                      .borderRadiusMultiplier),
                                              bottomRight: Radius.circular(1 *
                                                  Configuration.instance
                                                      .borderRadiusMultiplier),
                                              topLeft: Radius.circular(1 *
                                                  Configuration.instance
                                                      .borderRadiusMultiplier),
                                            ),
                                            child: FittedBox(
                                              child: Text(
                                                '${getDateFormatted(album.year)}',
                                              ),
                                            ),
                                          ),
                                        ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: SmallPlayAllButton(
                                          width: 10 + width * 0.1,
                                          height: 10 + width * 0.1,
                                          onTap: () {
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
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Configuration.instance.useAlbumStaggeredGridView
                                ? columnHavingAlbumInfo
                                : Expanded(child: columnHavingAlbumInfo),
                          ],
                        ),
                        Positioned(
                            bottom: 2,
                            right: 2,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8.0 *
                                  Configuration
                                      .instance.borderRadiusMultiplier),
                              onTap: () => showAlbumDialog(context, album),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0 *
                                    Configuration
                                        .instance.borderRadiusMultiplier),
                                child: BackdropFilter(
                                  filter:
                                      Configuration.instance.enableBlurEffect
                                          ? ImageFilter.blur(
                                              sigmaX: 2.5, sigmaY: 2.5)
                                          : ImageFilter.blur(),
                                  child: Container(
                                    margin: EdgeInsets.all(width * 0.02),
                                    alignment: Alignment.center,
                                    child: RotatedBox(
                                      quarterTurns: 1,
                                      child: Icon(
                                        Broken.more,
                                        size: 10 + width * 0.05,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
                openBuilder: (context, _) => AlbumScreenModern(
                  album: album,
                  palette: palette,
                ),
              );
  }
}

class AlbumScreenModern extends StatefulWidget {
  final Album album;
  final Iterable<Color>? palette;
  const AlbumScreenModern({
    Key? key,
    required this.album,
    this.palette,
  }) : super(key: key);
  AlbumScreenModernState createState() => AlbumScreenModernState();
}

class AlbumScreenModernState extends State<AlbumScreenModern>
    with SingleTickerProviderStateMixin {
  Color? color;
  Color? secondary;
  int? hovered;
  bool reactToSecondaryPress = false;
  bool detailsVisible = false;
  bool detailsLoaded = false;
  ScrollController controller = ScrollController(initialScrollOffset: -100);
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
        if (controller.offset < 48.0) {
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
    int totalAlbumDuration = getTotalTracksDuration(
        album: widget.album, tracks: widget.album.tracks.toList());
    List<String> artistsInsideTheAlbum = getArtistsInsideAlbum(
        album: widget.album, tracks: widget.album.tracks.toList());
    String formattedTotalAlbumDuration =
        getTotalTracksDurationFormatted(tracks: widget.album.tracks.toList());
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
                                                    '${Language.instance.ARTIST}: ${widget.album.albumArtistName}\n${Language.instance.YEAR}: ${getDateFormatted(widget.album.year)}\n${Language.instance.TRACK}: ${tracks.length}',
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
                extendBodyBehindAppBar: true,
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  toolbarHeight: 70,
                  titleSpacing: 0,
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
                  leading: IconButton(
                    onPressed: Navigator.of(context).maybePop,
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Color.alphaBlend(
                          Theme.of(context).brightness == Brightness.light
                              ? Colors.black.withAlpha(80)
                              : Colors.white.withAlpha(80),
                          secondary!.withAlpha(222)),
                    ),
                    iconSize: 24.0,
                    splashRadius: 20.0,
                  ),
                  title: TweenAnimationBuilder<int>(
                    tween: Tween<int>(
                      begin: 2,
                      end: detailsVisible ? 2 : 1,
                    ),
                    duration: Duration(milliseconds: 0),
                    builder: (context, value, _) => Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          [
                            "${widget.album.albumName.overflow}",
                            if (!['', kUnknownArtist]
                                .contains(widget.album.albumArtistName))
                              "${widget.album.albumArtistName.overflow}",
                          ].join(" • "),
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Color.alphaBlend(
                                        Theme.of(context).brightness ==
                                                Brightness.light
                                            ? Colors.black.withAlpha(80)
                                            : Colors.white.withAlpha(80),
                                        secondary!.withAlpha(222)),
                                    fontSize: 24,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          "${artistsInsideTheAlbum.take(10).join(" | ")}",
                          style:
                              Theme.of(context).textTheme.bodySmall!.copyWith(
                                    color: Color.alphaBlend(
                                        Theme.of(context).brightness ==
                                                Brightness.light
                                            ? Colors.black.withAlpha(110)
                                            : Colors.white.withAlpha(110),
                                        secondary!.withAlpha(80)),
                                  ),
                          maxLines: value,
                        )
                      ],
                    ),
                  ),
                  actions: [
                    IconButton(
                      onPressed: () => Playback.instance.add(tracks),
                      tooltip: Language.instance.ADD_TO_NOW_PLAYING,
                      icon: Icon(
                        Icons.queue_music,
                        color: Color.alphaBlend(
                            Theme.of(context).brightness == Brightness.light
                                ? Colors.black.withAlpha(80)
                                : Colors.white.withAlpha(80),
                            secondary!.withAlpha(222)),
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
                                  style: Theme.of(ctx).textTheme.displaySmall,
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () async {
                                      await Collection.instance
                                          .delete(widget.album);
                                      await Navigator.of(ctx).maybePop();
                                      await Navigator.of(context).maybePop();
                                    },
                                    child: Text(Language.instance.YES),
                                  ),
                                  TextButton(
                                    onPressed: Navigator.of(ctx).maybePop,
                                    child: Text(Language.instance.NO),
                                  ),
                                ],
                              ),
                            );
                          } else if (sdk > 29) {
                            await Collection.instance.delete(widget.album);
                            await Navigator.of(context).maybePop();
                          }
                        }
                      },
                      tooltip: Language.instance.DELETE,
                      icon: Icon(
                        Icons.delete,
                        color: Color.alphaBlend(
                            Theme.of(context).brightness == Brightness.light
                                ? Colors.black.withAlpha(80)
                                : Colors.white.withAlpha(80),
                            secondary!.withAlpha(222)),
                        // color: detailsVisible
                        //     ? Theme.of(context)
                        //         .extension<IconColors>()
                        //         ?.appBarActionDarkIconColor
                        //     : [
                        //         Theme.of(context)
                        //             .extension<IconColors>()
                        //             ?.appBarActionLightIconColor,
                        //         Theme.of(context)
                        //             .extension<IconColors>()
                        //             ?.appBarActionDarkIconColor,
                        //       ][(color?.computeLuminance() ??
                        //                 (Theme.of(context).brightness ==
                        //                         Brightness.dark
                        //                     ? 0.0
                        //                     : 1.0)) >
                        //             0.5
                        //         ? 0
                        //         : 1],
                      ),
                      iconSize: 24.0,
                      splashRadius: 20.0,
                    ),
                    const SizedBox(width: 8.0),
                  ],
                ),
                body: Stack(
                  children: [
                    TrackTabModern(
                      tracks: widget.album.tracks.toList(),
                      // onTrackTilePressed: () {
                      //   Playback.instance.open(tracks, index: );
                      // },
                      padding: EdgeInsets.only(
                          top: 300, bottom: kMobileNowPlayingBarHeight),
                    ),
                    Visibility(
                      visible: true,
                      child: Positioned(
                        top: 0,
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(25 *
                                      Configuration
                                          .instance.borderRadiusMultiplier),
                                  bottomRight: Radius.circular(25 *
                                      Configuration
                                          .instance.borderRadiusMultiplier)),
                              child: BackdropFilter(
                                filter: Configuration.instance.enableBlurEffect
                                    ? ImageFilter.blur(
                                        sigmaX: 15.0, sigmaY: 15.0)
                                    : ImageFilter.blur(),
                                child: Column(
                                  children: [
                                    TweenAnimationBuilder<double>(
                                      tween: Tween<double>(
                                        begin:
                                            MediaQuery.of(context).size.height /
                                                2.2,
                                        end: detailsVisible
                                            ? MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                2
                                            : MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                2.8,
                                      ),
                                      duration: Duration(milliseconds: 200),
                                      builder: (context, value, _) => Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height: value,
                                        decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                stops: [
                                              0.6,
                                              if (!Configuration
                                                  .instance.enableBlurEffect)
                                                0.92,
                                              1
                                            ],
                                                colors: [
                                              Theme.of(context).brightness ==
                                                      Brightness.light
                                                  ? Color.fromARGB(
                                                      255, 230, 230, 230)
                                                  : Color.fromARGB(
                                                      255, 11, 11, 11),
                                              if (!Configuration
                                                  .instance.enableBlurEffect)
                                                Theme.of(context).brightness ==
                                                        Brightness.light
                                                    ? Color.fromARGB(
                                                        255, 230, 230, 230)
                                                    : Color.fromARGB(
                                                        255, 11, 11, 11),
                                              Theme.of(context).brightness ==
                                                      Brightness.light
                                                  ? Color.fromARGB(
                                                      0, 230, 230, 230)
                                                  : Color.fromARGB(
                                                      0, 11, 11, 11),
                                            ])),
                                        child: Container(
                                          decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  stops: [
                                                0.6,
                                                0.9
                                              ],
                                                  colors: [
                                                color!.withAlpha(70),
                                                Colors.transparent
                                              ])),
                                          child: FittedBox(
                                            child: Column(
                                              children: [
                                                SizedBox(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height /
                                                      12,
                                                ),
                                                TweenAnimationBuilder<double>(
                                                  tween: Tween<double>(
                                                    begin:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height /
                                                            3,
                                                    end: detailsVisible
                                                        ? MediaQuery.of(context)
                                                                .size
                                                                .height /
                                                            2.8
                                                        : MediaQuery.of(context)
                                                                .size
                                                                .height /
                                                            4.4,
                                                  ),
                                                  duration: Duration(
                                                      milliseconds: 200),
                                                  builder:
                                                      (context, value, _) =>
                                                          Container(
                                                    height: value, //here
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,

                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        SizedBox(),
                                                        TweenAnimationBuilder<
                                                            double>(
                                                          tween: Tween<double>(
                                                            begin: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height /
                                                                3,
                                                            end: detailsVisible
                                                                ? MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .height /
                                                                    2.8
                                                                : MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .height /
                                                                    4.4,
                                                          ),
                                                          duration: Duration(
                                                              milliseconds:
                                                                  200),
                                                          builder: (context,
                                                                  value, _) =>
                                                              SizedBox(
                                                            width: Configuration
                                                                    .instance
                                                                    .forceSquaredAlbumThumbnail
                                                                ? value
                                                                : MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    1.5,
                                                            height: Configuration
                                                                    .instance
                                                                    .forceSquaredAlbumThumbnail
                                                                ? value
                                                                : MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .height /
                                                                    3,
                                                            child: Center(
                                                              child: ClipRRect(
                                                                borderRadius: BorderRadius.circular(12 *
                                                                    Configuration
                                                                        .instance
                                                                        .borderRadiusMultiplier),
                                                                child:
                                                                    DropShadow(
                                                                  borderRadius: 12 *
                                                                      Configuration
                                                                          .instance
                                                                          .borderRadiusMultiplier,
                                                                  blurRadius: Configuration
                                                                          .instance
                                                                          .enableGlowEffect
                                                                      ? 5
                                                                      : 0,
                                                                  spread: Configuration
                                                                          .instance
                                                                          .enableGlowEffect
                                                                      ? 1
                                                                      : 0,
                                                                  offset:
                                                                      Offset(
                                                                          0, 2),
                                                                  child: Hero(
                                                                    tag:
                                                                        'album_art_${widget.album.albumName}_${widget.album.albumArtistName}',
                                                                    child:
                                                                        ExtendedImage(
                                                                      image: Image(
                                                                              image: getAlbumArt(widget.album))
                                                                          .image,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      width: Configuration
                                                                              .instance
                                                                              .forceSquaredAlbumThumbnail
                                                                          ? MediaQuery.of(context).size.width /
                                                                              1.5
                                                                          : null,
                                                                      height: Configuration
                                                                              .instance
                                                                              .forceSquaredAlbumThumbnail
                                                                          ? MediaQuery.of(context).size.height /
                                                                              3
                                                                          : null,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Flexible(
                                                          child: Container(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    right: 8),
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              children: [
                                                                if (![
                                                                  '',
                                                                  kUnknownYear
                                                                ].contains(widget
                                                                    .album
                                                                    .year)) ...[
                                                                  TweenAnimationBuilder<
                                                                      double>(
                                                                    tween: Tween<
                                                                        double>(
                                                                      begin:
                                                                          32.0,
                                                                      end: detailsVisible
                                                                          ? 32.0
                                                                          : 2.0,
                                                                    ),
                                                                    duration: Duration(
                                                                        milliseconds:
                                                                            200),
                                                                    builder: (context,
                                                                            value,
                                                                            _) =>
                                                                        SizedBox(
                                                                            height:
                                                                                value),
                                                                  ),
                                                                  Chip(
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(12 *
                                                                                Configuration.instance.borderRadiusMultiplier)),
                                                                    backgroundColor: Color.alphaBlend(
                                                                        Colors
                                                                            .black
                                                                            .withAlpha(
                                                                                80),
                                                                        color!.withAlpha(
                                                                            180)),
                                                                    label:
                                                                        FittedBox(
                                                                      child:
                                                                          Text(
                                                                        '${getDateFormatted(widget.album.year)}',
                                                                        style: Theme.of(context)
                                                                            .textTheme
                                                                            .titleLarge
                                                                            ?.copyWith(
                                                                              color: Color.alphaBlend(Colors.white.withAlpha(100), secondary!.withAlpha(180)),
                                                                              fontSize: 16,
                                                                            ),
                                                                        maxLines:
                                                                            1,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                                TweenAnimationBuilder<
                                                                    double>(
                                                                  tween: Tween<
                                                                      double>(
                                                                    begin: 32.0,
                                                                    end: detailsVisible
                                                                        ? 40.0
                                                                        : 0.0,
                                                                  ),
                                                                  duration: Duration(
                                                                      milliseconds:
                                                                          200),
                                                                  builder: (context,
                                                                          value,
                                                                          _) =>
                                                                      SizedBox(
                                                                          height:
                                                                              value),
                                                                ),
                                                                Chip(
                                                                  shape: RoundedRectangleBorder(
                                                                      borderRadius: BorderRadius.circular(12 *
                                                                          Configuration
                                                                              .instance
                                                                              .borderRadiusMultiplier)),
                                                                  backgroundColor: Color.alphaBlend(
                                                                      Colors
                                                                          .black
                                                                          .withAlpha(
                                                                              80),
                                                                      color!.withAlpha(
                                                                          180)),
                                                                  label:
                                                                      FittedBox(
                                                                    child: Text(
                                                                      // just small handling so that large numbers wont make album artwork smaller
                                                                      "${tracks.length.toString()} ${tracks.length >= 10000 ? "\n" : ""}Track${tracks.length == 1 ? "" : "s"}",
                                                                      style: Theme.of(
                                                                              context)
                                                                          .textTheme
                                                                          .titleLarge
                                                                          ?.copyWith(
                                                                            color:
                                                                                Color.alphaBlend(Colors.white.withAlpha(100), secondary!.withAlpha(180)),
                                                                            fontSize:
                                                                                16,
                                                                          ),
                                                                      maxLines:
                                                                          2,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                    ),
                                                                  ),
                                                                ),
                                                                Chip(
                                                                  shape: RoundedRectangleBorder(
                                                                      borderRadius: BorderRadius.circular(12 *
                                                                          Configuration
                                                                              .instance
                                                                              .borderRadiusMultiplier)),
                                                                  backgroundColor: Color.alphaBlend(
                                                                      Colors
                                                                          .black
                                                                          .withAlpha(
                                                                              80),
                                                                      color!.withAlpha(
                                                                          180)),
                                                                  label:
                                                                      FittedBox(
                                                                    child: Text(
                                                                      formattedTotalAlbumDuration,
                                                                      style: Theme.of(
                                                                              context)
                                                                          .textTheme
                                                                          .titleLarge
                                                                          ?.copyWith(
                                                                            color:
                                                                                Color.alphaBlend(Colors.white.withAlpha(100), secondary!.withAlpha(180)),
                                                                            fontSize:
                                                                                16,
                                                                          ),
                                                                      maxLines:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: 20,
                                                                ),
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
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              transform:
                                  Matrix4.translationValues(0.0, -20.0, 0.0),
                              // height: 200,
                              // color: Colors.blue,
                              width: MediaQuery.of(context).size.width,
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  TweenAnimationBuilder(
                                    curve: Curves.easeOut,
                                    tween: Tween<double>(
                                        begin: 0.5,
                                        end: detailsVisible ? 1.0 : 1),
                                    duration: Duration(milliseconds: 280),
                                    builder: (context, value, _) =>
                                        Transform.scale(
                                      scale: value as double,
                                      child: Transform.rotate(
                                        angle: value * pi + pi,
                                        child: Hero(
                                          tag: 'shuffle',
                                          child: Container(
                                            height: 37.0,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12 *
                                                        Configuration.instance
                                                            .borderRadiusMultiplier),
                                                color: Color.alphaBlend(
                                                  Theme.of(context)
                                                              .brightness ==
                                                          Brightness.light
                                                      ? Colors.black
                                                          .withAlpha(20)
                                                      : Colors.white
                                                          .withAlpha(20),
                                                  color!.withAlpha(240),
                                                ),
                                                boxShadow: Configuration
                                                        .instance
                                                        .enableGlowEffect
                                                    ? [
                                                        Theme.of(context)
                                                                    .brightness ==
                                                                Brightness.dark
                                                            ? BoxShadow(
                                                                blurRadius: 12,
                                                                spreadRadius: 1,
                                                                offset: Offset(
                                                                    0, 2),
                                                                color: Color.alphaBlend(
                                                                    Colors.white
                                                                        .withAlpha(
                                                                            5),
                                                                    color!.withAlpha(
                                                                        200)),
                                                              )
                                                            : BoxShadow(
                                                                blurRadius: 8,
                                                                spreadRadius: 1,
                                                                offset: Offset(
                                                                    0, 3),
                                                                color: Color.alphaBlend(
                                                                    Colors.black
                                                                        .withAlpha(
                                                                            40),
                                                                    color!.withAlpha(
                                                                        200)),
                                                              )
                                                      ]
                                                    : null),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12 *
                                                      Configuration.instance
                                                          .borderRadiusMultiplier),
                                              child: BackdropFilter(
                                                filter: ImageFilter.blur(
                                                    sigmaX: 15.0, sigmaY: 15.0),
                                                child: ElevatedButton(
                                                  style: ButtonStyle(
                                                    shape: MaterialStateProperty
                                                        .all<
                                                            RoundedRectangleBorder>(
                                                      RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(0),
                                                        // side: BorderSide(
                                                        //     color: Colors.red),
                                                      ),
                                                    ),
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .all(Colors
                                                                .transparent),
                                                    elevation:
                                                        MaterialStateProperty
                                                            .all(0),
                                                    shadowColor:
                                                        MaterialStateProperty
                                                            .all(color),
                                                    foregroundColor:
                                                        MaterialStateProperty
                                                            .all([
                                                      Colors.white,
                                                      Color(0xFF212121)
                                                    ][(color?.computeLuminance() ??
                                                                        0.0) >
                                                                    0.5
                                                                ? 1
                                                                : 0]),
                                                  ),
                                                  child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        Icon(Icons.shuffle),
                                                        Text(Language
                                                            .instance.SHUFFLE)
                                                      ]),
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
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  TweenAnimationBuilder(
                                    curve: Curves.easeOut,
                                    tween: Tween<double>(
                                        begin: 0.5,
                                        end: detailsVisible ? 1.0 : 1),
                                    duration: Duration(milliseconds: 280),
                                    builder: (context, value, _) =>
                                        Transform.scale(
                                      scale: value as double,
                                      child: Transform.rotate(
                                        angle: value * pi + pi,
                                        child: Hero(
                                          tag: 'play_now',
                                          child: Container(
                                            height: 37.0,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12 *
                                                        Configuration.instance
                                                            .borderRadiusMultiplier),
                                                color: Color.alphaBlend(
                                                  Theme.of(context)
                                                              .brightness ==
                                                          Brightness.light
                                                      ? Colors.black
                                                          .withAlpha(20)
                                                      : Colors.white
                                                          .withAlpha(20),
                                                  color!.withAlpha(240),
                                                ),
                                                boxShadow: Configuration
                                                        .instance
                                                        .enableGlowEffect
                                                    ? [
                                                        Theme.of(context)
                                                                    .brightness ==
                                                                Brightness.dark
                                                            ? BoxShadow(
                                                                blurRadius: 12,
                                                                spreadRadius: 1,
                                                                offset: Offset(
                                                                    0, 2),
                                                                color: Color.alphaBlend(
                                                                    Colors.white
                                                                        .withAlpha(
                                                                            5),
                                                                    color!.withAlpha(
                                                                        200)),
                                                              )
                                                            : BoxShadow(
                                                                blurRadius: 8,
                                                                spreadRadius: 1,
                                                                offset: Offset(
                                                                    0, 3),
                                                                color: Color.alphaBlend(
                                                                    Colors.black
                                                                        .withAlpha(
                                                                            40),
                                                                    color!.withAlpha(
                                                                        200)),
                                                              )
                                                      ]
                                                    : null),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12 *
                                                      Configuration.instance
                                                          .borderRadiusMultiplier),
                                              child: BackdropFilter(
                                                filter: ImageFilter.blur(
                                                    sigmaX: 15.0, sigmaY: 15.0),
                                                child: ElevatedButton(
                                                  style: ButtonStyle(
                                                    shape: MaterialStateProperty
                                                        .all<
                                                            RoundedRectangleBorder>(
                                                      RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(0),
                                                        // side: BorderSide(
                                                        //     color: Colors.red),
                                                      ),
                                                    ),
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .all(Colors
                                                                .transparent),
                                                    elevation:
                                                        MaterialStateProperty
                                                            .all(0),
                                                    shadowColor:
                                                        MaterialStateProperty
                                                            .all(color),
                                                    foregroundColor:
                                                        MaterialStateProperty
                                                            .all([
                                                      Colors.white,
                                                      Color(0xFF212121)
                                                    ][(color?.computeLuminance() ??
                                                                        0.0) >
                                                                    0.5
                                                                ? 1
                                                                : 0]),
                                                  ),
                                                  child: Row(children: [
                                                    Icon(Icons.play_arrow),
                                                    Text(Language
                                                        .instance.PLAY_ALL)
                                                  ]),
                                                  onPressed: () {
                                                    Playback.instance.open([
                                                      ...tracks,
                                                      if (Configuration.instance
                                                          .seamlessPlayback)
                                                        ...[
                                                          ...Collection
                                                              .instance.tracks
                                                        ]..shuffle(),
                                                    ]);
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
      },
    );
  }
}

   // SliverList(
                          //   delegate: SliverChildBuilderDelegate(
                          //     (context, i) {
                          //       return Material(
                          //         // color: Color.fromARGB(255, 18, 18, 18),
                          //         color: Theme.of(context).brightness == Brightness.light ? Color.fromARGB(255, 248, 248, 248) : Color.fromARGB(255, 18, 18, 18),
                          //         child: InkWell(
                          //           onTap: () => Playback.instance.open(
                          //             [
                          //               ...tracks,
                          //               if (Configuration.instance.seamlessPlayback) ...[...Collection.instance.tracks]..shuffle(),
                          //             ],
                          //             index: i,
                          //           ),
                          //           onLongPress: () => showTrackDialog(context, tracks[i]),
                          //           child: Column(
                          //             mainAxisAlignment: MainAxisAlignment.center,
                          //             children: [
                          //               Container(
                          //                 height: Configuration.instance.trackListTileHeight,
                          //                 width: MediaQuery.of(context).size.width,
                          //                 alignment: Alignment.center,
                          //                 margin: const EdgeInsets.only(bottom: 4.0),
                          //                 padding: const EdgeInsets.symmetric(vertical: 4.0),
                          //                 child: Row(
                          //                   crossAxisAlignment: CrossAxisAlignment.center,
                          //                   children: [
                          //                     const SizedBox(width: 12.0),
                          //                     Configuration.instance.displayTrackNumberinAlbumPage
                          //                         ? Stack(
                          //                             children: [
                          //                               CustomTrackThumbnailModern(scale: 1, borderRadius: 8, blur: 2, media: tracks[i]),
                          //                               Positioned(
                          //                                 right: 0,
                          //                                 bottom: 0,
                          //                                 child: BlurryContainer(
                          //                                   blur: Configuration.instance.enableBlurEffect ? 2 : 0,
                          //                                   height: 20.0,
                          //                                   padding: EdgeInsets.symmetric(horizontal: 6),
                          //                                   borderRadius: BorderRadius.circular(6 * Configuration.instance.borderRadiusMultiplier),
                          //                                   color: Configuration.instance.enableBlurEffect
                          //                                       ? Theme.of(context).brightness == Brightness.dark
                          //                                           ? Colors.black12
                          //                                           : Colors.white24
                          //                                       : Theme.of(context).brightness == Brightness.dark
                          //                                           ? Colors.black54
                          //                                           : Colors.white70,
                          //                                   child: Center(
                          //                                     child: Text(
                          //                                       '${tracks[i].trackNumber}',
                          //                                       style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          //                                             fontSize: 14.0,
                          //                                             color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black54,
                          //                                           ),
                          //                                     ),
                          //                                   ),
                          //                                 ),
                          //                               ),
                          //                             ],
                          //                           )
                          //                         : CustomTrackThumbnailModern(scale: 1, borderRadius: 8, blur: 2, media: tracks[i]),
                          //                     const SizedBox(width: 12.0),
                          //                     Expanded(
                          //                       child: Column(
                          //                         mainAxisSize: MainAxisSize.max,
                          //                         mainAxisAlignment: MainAxisAlignment.center,
                          //                         crossAxisAlignment: CrossAxisAlignment.start,
                          //                         children: [
                          //                           Text(
                          //                             tracks[i].trackName.overflow,
                          //                             overflow: TextOverflow.ellipsis,
                          //                             maxLines: 1,
                          //                             style: Theme.of(context).textTheme.displayMedium,
                          //                           ),
                          //                           const SizedBox(
                          //                             height: 2.0,
                          //                           ),
                          //                           Text(
                          //                             [
                          //                               if (!tracks[i].hasNoAvailableArtists) tracks[i].trackArtistNames.take(1).join(', '),
                          //                             ].join(' • '),
                          //                             overflow: TextOverflow.ellipsis,
                          //                             maxLines: 1,
                          //                             style: Theme.of(context).textTheme.displaySmall,
                          //                           ),
                          //                         ],
                          //                       ),
                          //                     ),
                          //                     const SizedBox(width: 12.0),
                          //                     Text(
                          //                       tracks[i].duration?.label ?? Duration.zero.label,
                          //                       overflow: TextOverflow.ellipsis,
                          //                       maxLines: 1,
                          //                       style: Theme.of(context).textTheme.displaySmall,
                          //                     ),
                          //                     Container(
                          //                       width: 46.0,
                          //                       height: 46.0,
                          //                       alignment: Alignment.center,
                          //                       child: IconButton(
                          //                         onPressed: () => showTrackDialog(context, tracks[i]),
                          //                         icon: Icon(
                          //                           Icons.more_vert,
                          //                         ),
                          //                         iconSize: 24.0,
                          //                         splashRadius: 20.0,
                          //                       ),
                          //                     ),
                          //                   ],
                          //                 ),
                          //               ),
                          //               Divider(
                          //                 height: 1.0,
                          //                 thickness: 5.0,
                          //                 indent: 0.0,
                          //                 // color: Color.fromARGB(255, 12, 12, 12),
                          //                 color: Theme.of(context).brightness == Brightness.light ? Color.fromARGB(255, 232, 232, 232) : Color.fromARGB(255, 13, 13, 13),
                          //               ),
                          //             ],
                          //           ),
                          //         ),
                          //       );
                          //     },
                          //     childCount: tracks.length,
                          //   ),
                          // ),