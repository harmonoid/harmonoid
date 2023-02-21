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
import 'package:known_extents_list_view_builder/known_extents_list_view_builder.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/interface/collection/artist.dart';
import 'package:harmonoid/state/mobile_now_playing_controller.dart';
import 'package:harmonoid/utils/theme.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/constants.dart';
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
                              28.0 + tileMargin(context),
                            ] +
                            List.generate(
                              data.widgets.length,
                              (index) =>
                                  helper.albumTileHeight + tileMargin(context),
                            ),
                        itemBuilder: (context, i) => i == 0
                            ? SortBarFixedHolder(
                                index: kAlbumTabIndex,
                                child: SortBar(
                                  tab: kAlbumTabIndex,
                                  hover: hover,
                                  fixed: true,
                                ),
                              )
                            : data.widgets[i - 1],
                      ),
                      SortBar(
                        tab: kAlbumTabIndex,
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
                          width:
                              Collection.instance.albumsSort == AlbumsSort.aToZ
                                  ? 56.0
                                  : 136.0,
                          height:
                              Collection.instance.albumsSort == AlbumsSort.aToZ
                                  ? 56.0
                                  : 32.0,
                        ),
                        labelTextBuilder: (offset) {
                          final perTileHeight = helper.albumElementsPerRow > 1
                              ? (helper.albumTileHeight + tileMargin(context))
                              : kAlbumTileListViewHeight;
                          final index = (offset -
                                  (kMobileSearchBarHeight +
                                      56.0 +
                                      tileMargin(context) +
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
                                      Theme.of(context).textTheme.headlineSmall,
                                );
                              }
                            case AlbumsSort.dateAdded:
                              {
                                return Text(
                                  '${album.timeAdded.label}',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                );
                              }
                            case AlbumsSort.year:
                              {
                                return Text(
                                  album.year,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                );
                              }
                            default:
                              return Text(
                                '',
                                style: Theme.of(context).textTheme.bodyLarge,
                              );
                          }
                        },
                        backgroundColor: Theme.of(context).cardTheme.color ??
                            Theme.of(context).cardColor,
                        controller: controller,
                        child: KnownExtentsListView.builder(
                          controller: controller,
                          itemExtents: [
                            56.0,
                            ...data.widgets.map(
                              (e) => helper.albumElementsPerRow > 1
                                  ? (helper.albumTileHeight +
                                      tileMargin(context))
                                  : kAlbumTileListViewHeight,
                            ),
                          ],
                          padding: EdgeInsets.only(
                            top: MediaQuery.of(context).padding.top +
                                kMobileSearchBarHeight +
                                tileMargin(context),
                          ),
                          itemCount: 1 + data.widgets.length,
                          itemBuilder: (context, i) {
                            if (i == 0) {
                              return Container(
                                height: 56.0,
                                padding: EdgeInsets.symmetric(
                                  horizontal: tileMargin(context),
                                ),
                                alignment: Alignment.centerRight,
                                child: Row(
                                  children: [
                                    const SizedBox(width: 8.0),
                                    Text(
                                      '${Collection.instance.albums.length} ${Language.instance.ALBUM}',
                                    ),
                                    const Spacer(),
                                    MobileSortByButton(tab: kAlbumTabIndex),
                                  ],
                                ),
                              );
                            }
                            return data.widgets[i - 1];
                          },
                        ),
                      )
                    : Container(
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top,
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
          ((MediaQuery.of(context).size.width - 177.0) - tileMargin(context)) ~/
              (kAlbumTileWidth + tileMargin(context));
      final double width = kAlbumTileWidth;
      final double height = kAlbumTileHeight;
      // Children of the right pane.
      List<Widget> children = [];
      List<double> itemExtents = [];
      Map<AlbumArtist, double> offsets = {};
      double last = -1 * (tileMargin(context) + 12.0);
      // Grid generated for each iteration of album artist.
      List<Widget> widgets = [];
      if (collection.albumsOrderType == OrderType.ascending) {
        for (final key in collection.albumArtists.keys) {
          offsets[key] = 36.0 +
              (kAlbumTileHeight + tileMargin(context)) * widgets.length +
              last;
          last = offsets[key]!;
          children.addAll(widgets);
          children.add(Container(
            margin: EdgeInsets.only(left: tileMargin(context)),
            alignment: Alignment.topLeft,
            height: 36.0,
            child: Text(
              key.name,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ));
          itemExtents.addAll(List.generate(
            widgets.length,
            (_) => (kAlbumTileHeight + tileMargin(context)),
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
            widgets.length, (_) => (kAlbumTileHeight + tileMargin(context))));
      }
      if (collection.albumsOrderType == OrderType.descending) {
        for (final key in collection.albumArtists.keys.toList().reversed) {
          offsets[key] = 36.0 +
              (kAlbumTileHeight + tileMargin(context)) * widgets.length +
              last;
          last = offsets[key]!;
          children.addAll(widgets);
          children.add(Container(
            margin: EdgeInsets.only(left: tileMargin(context)),
            alignment: Alignment.topLeft,
            height: 36.0,
            child: Text(
              key.name,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ));
          itemExtents.addAll(
            List.generate(
              widgets.length,
              (_) => (kAlbumTileHeight + tileMargin(context)),
            ),
          );
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
            widgets.length, (_) => (kAlbumTileHeight + tileMargin(context))));
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 176.0,
            child: CustomListViewBuilder(
              padding: EdgeInsets.only(top: tileMargin(context) / 2.0),
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
                      // MUST BE GREATER THAN 0 OTHERWISE IT WILL NOT SCROLL.
                      duration: const Duration(milliseconds: 100),
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
                      style: Theme.of(context).textTheme.bodyLarge,
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
                        28.0 + tileMargin(context),
                      ] +
                      itemExtents,
                  itemBuilder: (context, i) => i == 0
                      ? SortBarFixedHolder(
                          index: kAlbumTabIndex,
                          child: SortBar(
                            tab: kAlbumTabIndex,
                            hover: hover,
                            fixed: true,
                          ),
                        )
                      : children[i - 1],
                ),
                SortBar(
                  tab: kAlbumTabIndex,
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

    // Only for mobile:
    final albumElementsPerRow =
        forceDefaultStyleOnMobile ? 2 : helper.albumElementsPerRow;
    final albumTileNormalDensity =
        forceDefaultStyleOnMobile ? true : helper.albumTileNormalDensity;

    Iterable<Color>? palette;

    // Desktop
    if (isDesktop) {
      return Card(
        clipBehavior: Clip.antiAlias,
        elevation:
            Theme.of(context).cardTheme.elevation ?? kDefaultCardElevation,
        margin: EdgeInsets.zero,
        child: ContextMenuArea(
          onPressed: (e) async {
            final result = await showCustomMenu(
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
                MaterialRoute(
                  builder: (context) => AlbumScreen(album: album),
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
                            'album_art_${album.albumName}_${album.albumArtistName}_${album.year}',
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
                            style: Theme.of(context).textTheme.titleSmall,
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
                              style: Theme.of(context).textTheme.bodySmall,
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
      );
    }

    // Mobile
    switch (albumElementsPerRow) {
      case 1:
        return Material(
          color: Colors.transparent,
          child: OpenContainer(
            closedShape: Theme.of(context).cardTheme.shape ??
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
            transitionDuration:
                Theme.of(context).extension<AnimationDuration>()?.medium ??
                    Duration.zero,
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
                        MobileNowPlayingController.instance.hide();
                      } catch (exception, stacktrace) {
                        debugPrint(exception.toString());
                        debugPrint(stacktrace.toString());
                      }
                      if (Theme.of(context)
                              .extension<AnimationDuration>()
                              ?.medium ==
                          Duration.zero) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => AlbumScreen(
                              album: album,
                              palette: palette,
                            ),
                          ),
                        );
                      } else {
                        open();
                      }
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
                            // EXCEPTION IN DESIGN.
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            elevation: Theme.of(context).cardTheme.elevation ??
                                kDefaultCardElevation,
                            margin: EdgeInsets.zero,
                            child: Padding(
                              padding: EdgeInsets.all(2.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4.0),
                                child: ExtendedImage(
                                  image: getAlbumArt(album, small: true),
                                  height: 48.0,
                                  width: 48.0,
                                  borderRadius: BorderRadius.circular(4.0),
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
                                  album.albumName.overflow,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 2.0),
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
                                  style: Theme.of(context).textTheme.bodyMedium,
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
        );
      default:
        return OpenContainer(
          closedShape: Theme.of(context).cardTheme.shape ??
              RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
          transitionDuration:
              Theme.of(context).extension<AnimationDuration>()?.medium ??
                  Duration.zero,
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
                MobileNowPlayingController.instance.hide();
              } catch (exception, stacktrace) {
                debugPrint(exception.toString());
                debugPrint(stacktrace.toString());
              }
              if (Theme.of(context).extension<AnimationDuration>()?.medium ==
                  Duration.zero) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AlbumScreen(
                      album: album,
                      palette: palette,
                    ),
                  ),
                );
              } else {
                open();
              }
            },
            child: Container(
              height: height,
              width: width,
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: () {
                      if (Theme.of(context).cardTheme.shape
                          is RoundedRectangleBorder) {
                        return (Theme.of(context).cardTheme.shape
                                as RoundedRectangleBorder)
                            .borderRadius;
                      }
                    }(),
                    child: Image(
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
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: albumTileNormalDensity ? 12.0 : 8.0,
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
                                .titleMedium
                                ?.copyWith(
                                  fontSize:
                                      albumTileNormalDensity ? 18.0 : 14.0,
                                  fontWeight: albumTileNormalDensity
                                      ? FontWeight.w700
                                      : FontWeight.normal,
                                ),
                            textAlign: TextAlign.left,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (albumTileNormalDensity)
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
                                style: Theme.of(context).textTheme.bodyMedium,
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
  ScrollPhysics? physics = NeverScrollableScrollPhysics();

  ScrollController get controller {
    final duration = MaterialRoute.animationDuration?.medium ?? Duration.zero;
    return duration > Duration.zero ? sc0 : sc1;
  }

  final sc0 =
      ScrollController(initialScrollOffset: kMobileLayoutInitialScrollOffset);
  final sc1 = ScrollController(initialScrollOffset: 0.0);

  static const double kMobileLayoutInitialScrollOffset = 136.0;

  @override
  void initState() {
    super.initState();
    final duration = MaterialRoute.animationDuration?.medium ?? Duration.zero;

    // [ScrollController] is only needed on mobile for animation.
    if (isMobile) {
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

    // No animation, assign values at mount.
    if (duration == Duration.zero) {
      color = widget.palette?.first;
      secondary = widget.palette?.last;
      detailsVisible = true;
      detailsLoaded = true;
    }
    // Animation, assign values with some delay or animate with [ScrollController].
    else {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (isDesktop) {
          Future.delayed(duration, () async {
            try {
              final palette = await PaletteGenerator.fromImageProvider(
                getAlbumArt(
                  widget.album,
                  small: true,
                ),
              );
              setState(() {
                color = palette.colors?.first;
                secondary = palette.colors?.last;
              });
            } catch (exception, stacktrace) {
              debugPrint(exception.toString());
              debugPrint(stacktrace.toString());
            }
          });
        }
        if (isMobile) {
          setState(() {
            color = widget.palette?.first;
            secondary = widget.palette?.last;
          });
          await Future.delayed(const Duration(milliseconds: 100));
          await controller.animateTo(
            0.0,
            duration: duration,
            curve: Curves.easeInOut,
          );
          await Future.delayed(const Duration(milliseconds: 100));
          setState(() {
            detailsLoaded = true;
            physics = null;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    sc0.dispose();
    sc1.dispose();
    super.dispose();
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
          (first, second) {
            if (first.discNumber != second.discNumber) {
              return first.discNumber.compareTo(second.discNumber);
            }
            if (first.trackNumber != second.trackNumber) {
              return first.trackNumber.compareTo(second.trackNumber);
            }
            if (first.trackName != second.trackName) {
              return first.trackName.compareTo(second.trackName);
            }
            if (first.trackArtistNames.join(' ') !=
                second.trackArtistNames.join(' ')) {
              return first.trackArtistNames
                  .join(' ')
                  .compareTo(second.trackArtistNames.join(' '));
            }
            return first.uri.toString().compareTo(second.uri.toString());
          },
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
                        duration: Theme.of(context)
                                .extension<AnimationDuration>()
                                ?.medium ??
                            Duration.zero,
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
                                            duration: Theme.of(context)
                                                    .extension<
                                                        AnimationDuration>()
                                                    ?.slow ??
                                                Duration.zero,
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
                                                  'album_art_${widget.album.albumName}_${widget.album.albumArtistName}_${widget.album.year}',
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
                                                        .headlineSmall,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  SizedBox(height: 8.0),
                                                  Text(
                                                    '${Language.instance.ARTIST}: ${widget.album.albumArtistName}\n${Language.instance.YEAR}: ${widget.album.year}\n${Language.instance.TRACK}: ${tracks.length}',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium,
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
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .titleSmall,
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
                                                                .titleSmall,
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
                                                                .titleSmall,
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
                                                                await showCustomMenu(
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
                                                            child: Stack(
                                                              children: [
                                                                Positioned.fill(
                                                                  child:
                                                                      InkWell(
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
                                                                              ...Collection.instance.tracks
                                                                            ]..shuffle(),
                                                                        ],
                                                                        index: track
                                                                            .key,
                                                                      );
                                                                    },
                                                                    child: Row(
                                                                      children: [
                                                                        Container(
                                                                          width:
                                                                              64.0,
                                                                          height:
                                                                              56.0,
                                                                          padding:
                                                                              EdgeInsets.only(right: 8.0),
                                                                          alignment:
                                                                              Alignment.center,
                                                                          child: hovered == track.key
                                                                              ? IconButton(
                                                                                  onPressed: () {
                                                                                    Playback.instance.open(
                                                                                      tracks,
                                                                                      index: track.key,
                                                                                    );
                                                                                  },
                                                                                  icon: Icon(Icons.play_arrow),
                                                                                  splashRadius: 20.0,
                                                                                )
                                                                              : Text(
                                                                                  '${track.value.trackNumber}',
                                                                                  style: Theme.of(context).textTheme.bodyLarge,
                                                                                ),
                                                                        ),
                                                                        Expanded(
                                                                          child:
                                                                              Container(
                                                                            height:
                                                                                56.0,
                                                                            padding:
                                                                                EdgeInsets.only(right: 8.0),
                                                                            alignment:
                                                                                Alignment.centerLeft,
                                                                            child:
                                                                                Text(
                                                                              track.value.trackName,
                                                                              style: Theme.of(context).textTheme.bodyLarge,
                                                                              overflow: TextOverflow.ellipsis,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        const Spacer(),
                                                                        Container(
                                                                          width:
                                                                              64.0,
                                                                          height:
                                                                              56.0,
                                                                          alignment:
                                                                              Alignment.center,
                                                                          child:
                                                                              CustomPopupMenuButton<int>(
                                                                            onSelected:
                                                                                (result) {
                                                                              trackPopupMenuHandle(
                                                                                context,
                                                                                track.value,
                                                                                result,
                                                                                recursivelyPopNavigatorOnDeleteIf: () => widget.album.tracks.isEmpty,
                                                                              );
                                                                            },
                                                                            itemBuilder: (_) =>
                                                                                trackPopupMenuItems(
                                                                              track.value,
                                                                              context,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    const SizedBox(
                                                                      width:
                                                                          64.0,
                                                                      height:
                                                                          56.0,
                                                                    ),
                                                                    const Spacer(),
                                                                    Expanded(
                                                                      child:
                                                                          Container(
                                                                        height:
                                                                            56.0,
                                                                        padding:
                                                                            EdgeInsets.only(right: 8.0),
                                                                        alignment:
                                                                            Alignment.centerLeft,
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
                                                                              text: e,
                                                                              recognizer: TapGestureRecognizer()
                                                                                ..onTap = () {
                                                                                  final artist = Collection.instance.artistsSet.lookup(Artist(artistName: e));
                                                                                  if (artist != null) {
                                                                                    Playback.instance.interceptPositionChangeRebuilds = true;
                                                                                    Navigator.of(context).push(
                                                                                      MaterialRoute(
                                                                                        builder: (context) => ArtistScreen(
                                                                                          artist: artist,
                                                                                        ),
                                                                                      ),
                                                                                    );
                                                                                    Timer(const Duration(milliseconds: 400), () {
                                                                                      Playback.instance.interceptPositionChangeRebuilds = false;
                                                                                    });
                                                                                  }
                                                                                },
                                                                            ),
                                                                          )
                                                                              .forEach((element) {
                                                                            elements.add(element);
                                                                            elements.add(TextSpan(text: ', '));
                                                                          });
                                                                          elements
                                                                              .removeLast();
                                                                          return HyperLink(
                                                                            style:
                                                                                Theme.of(context).textTheme.bodyLarge,
                                                                            text:
                                                                                TextSpan(
                                                                              children: elements,
                                                                            ),
                                                                          );
                                                                        }(),
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      width:
                                                                          64.0,
                                                                      height:
                                                                          56.0,
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
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
                                        ?.appBarDark
                                    : [
                                        Theme.of(context)
                                            .extension<IconColors>()
                                            ?.appBarLight,
                                        Theme.of(context)
                                            .extension<IconColors>()
                                            ?.appBarDark,
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
                                          ?.appBarActionDark
                                      : [
                                          Theme.of(context)
                                              .extension<IconColors>()
                                              ?.appBarActionLight,
                                          Theme.of(context)
                                              .extension<IconColors>()
                                              ?.appBarActionDark,
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
                                              child: Text(
                                                label(
                                                  context,
                                                  Language.instance.YES,
                                                ),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed:
                                                  Navigator.of(ctx).maybePop,
                                              child: Text(
                                                label(
                                                  context,
                                                  Language.instance.NO,
                                                ),
                                              ),
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
                                          ?.appBarActionDark
                                      : [
                                          Theme.of(context)
                                              .extension<IconColors>()
                                              ?.appBarActionLight,
                                          Theme.of(context)
                                              .extension<IconColors>()
                                              ?.appBarActionDark,
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
                              duration: Theme.of(context)
                                      .extension<AnimationDuration>()
                                      ?.fast ??
                                  Duration.zero,
                              builder: (context, value, _) => Opacity(
                                opacity: value,
                                child: Text(
                                  widget.album.albumName.overflow,
                                  style: TextStyle(
                                    color: [
                                      Theme.of(context)
                                          .extension<TextColors>()
                                          ?.lightPrimary,
                                      Theme.of(context)
                                          .extension<TextColors>()
                                          ?.darkPrimary,
                                    ][(color?.computeLuminance() ??
                                                (Theme.of(context).brightness ==
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
                                        duration: Theme.of(context)
                                                .extension<AnimationDuration>()
                                                ?.fast ??
                                            Duration.zero,
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
                                                      .headlineSmall
                                                      ?.copyWith(
                                                        color: [
                                                          Theme.of(context)
                                                              .extension<
                                                                  TextColors>()
                                                              ?.lightPrimary,
                                                          Theme.of(context)
                                                              .extension<
                                                                  TextColors>()
                                                              ?.darkPrimary,
                                                        ][(color?.computeLuminance() ??
                                                                    (Theme.of(context).brightness ==
                                                                            Brightness.dark
                                                                        ? 0.0
                                                                        : 1.0)) >
                                                                0.5
                                                            ? 0
                                                            : 1],
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
                                                        .bodyMedium
                                                        ?.copyWith(
                                                          color: [
                                                            Theme.of(context)
                                                                .extension<
                                                                    TextColors>()
                                                                ?.lightSecondary,
                                                            Theme.of(context)
                                                                .extension<
                                                                    TextColors>()
                                                                ?.darkSecondary,
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
                                                        .bodyMedium
                                                        ?.copyWith(
                                                          color: [
                                                            Theme.of(context)
                                                                .extension<
                                                                    TextColors>()
                                                                ?.lightSecondary,
                                                            Theme.of(context)
                                                                .extension<
                                                                    TextColors>()
                                                                ?.darkSecondary,
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
                                    duration: Theme.of(context)
                                            .extension<AnimationDuration>()
                                            ?.fast ??
                                        Duration.zero,
                                    builder: (context, value, _) =>
                                        Transform.scale(
                                      scale: value as double,
                                      child: Transform.rotate(
                                        angle: value * pi + pi,
                                        child: FloatingActionButton(
                                          heroTag: 'play_now',
                                          backgroundColor: secondary,
                                          foregroundColor: const [
                                            kFABDarkForegroundColor,
                                            kFABLightForegroundColor,
                                          ][((secondary ??
                                                              Theme.of(context)
                                                                  .floatingActionButtonTheme
                                                                  .backgroundColor)
                                                          ?.computeLuminance() ??
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
                                    duration: Theme.of(context)
                                            .extension<AnimationDuration>()
                                            ?.fast ??
                                        Duration.zero,
                                    builder: (context, value, _) =>
                                        Transform.scale(
                                      scale: value as double,
                                      child: Transform.rotate(
                                        angle: value * pi + pi,
                                        child: FloatingActionButton(
                                          heroTag: 'shuffle',
                                          backgroundColor: secondary,
                                          foregroundColor: const [
                                            kFABDarkForegroundColor,
                                            kFABLightForegroundColor,
                                          ][((secondary ??
                                                              Theme.of(context)
                                                                  .floatingActionButtonTheme
                                                                  .backgroundColor)
                                                          ?.computeLuminance() ??
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
                                          vertical: 4.0,
                                        ),
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
                                                    .bodyMedium
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
                                                        .titleMedium,
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
                                                          .trackArtistNamesNotPresent)
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
                                                        .bodyMedium,
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
