/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'dart:ui';
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';
import 'package:media_library/media_library.dart';
import 'package:extended_image/extended_image.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:known_extents_list_view_builder/known_extents_list_view_builder.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/interface/collection/album.dart';
import 'package:harmonoid/state/mobile_now_playing_controller.dart';
import 'package:harmonoid/utils/theme.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/utils/constants.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/palette_generator.dart';
import 'package:harmonoid/constants/language.dart';

class ArtistTab extends StatefulWidget {
  ArtistTab({
    Key? key,
  }) : super(key: key);

  @override
  _ArtistTabState createState() => _ArtistTabState();
}

class _ArtistTabState extends State<ArtistTab> {
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
        final data = tileGridListWidgetsWithScrollbarSupport(
          context: context,
          tileWidth: helper.artistTileWidth,
          tileHeight: helper.artistTileHeight,
          margin: tileMargin(context),
          elementsPerRow: helper.artistElementsPerRow,
          widgetCount: collection.artists.length,
          builder: (BuildContext context, int index) => ArtistTile(
            width: helper.artistTileWidth,
            height: helper.artistTileHeight,
            artist: collection.artists[index],
            key: ValueKey(collection.artists[index]),
          ),
        );
        return isDesktop
            ? collection.artists.isNotEmpty
                ? () {
                    return Stack(
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
                                    helper.artistTileHeight +
                                    tileMargin(context),
                              ),
                          itemBuilder: (context, i) => i == 0
                              ? SortBarFixedHolder(
                                  index: kArtistTabIndex,
                                  child: SortBar(
                                    tab: kArtistTabIndex,
                                    hover: hover,
                                    fixed: true,
                                  ),
                                )
                              : data.widgets[i - 1],
                        ),
                        SortBar(
                          tab: kArtistTabIndex,
                          hover: hover,
                          fixed: false,
                        ),
                      ],
                    );
                  }()
                : Center(
                    child: ExceptionWidget(
                      title: Language.instance.NO_COLLECTION_TITLE,
                      subtitle: Language.instance.NO_COLLECTION_SUBTITLE,
                    ),
                  )
            : Consumer<Collection>(
                builder: (context, collection, _) => collection
                        .artists.isNotEmpty
                    ? DraggableScrollbar.semicircle(
                        heightScrollThumb: 56.0,
                        labelConstraints: BoxConstraints.tightFor(
                          width: Collection.instance.artistsSort ==
                                  ArtistsSort.aToZ
                              ? 56.0
                              : 136.0,
                          height: Collection.instance.artistsSort ==
                                  ArtistsSort.aToZ
                              ? 56.0
                              : 32.0,
                        ),
                        labelTextBuilder: (offset) {
                          final perTileHeight = helper.artistElementsPerRow > 1
                              ? (helper.artistTileHeight + tileMargin(context))
                              : kArtistTileListViewHeight;
                          final index = (offset -
                                  (kMobileSearchBarHeight +
                                      56.0 +
                                      tileMargin(context) +
                                      MediaQuery.of(context).padding.top)) ~/
                              perTileHeight;
                          final artist = data
                              .data[index.clamp(
                            0,
                            data.data.length - 1,
                          )]
                              .first as Artist;
                          switch (collection.artistsSort) {
                            case ArtistsSort.aToZ:
                              {
                                return Text(
                                  artist.artistName[0].toUpperCase(),
                                  style:
                                      Theme.of(context).textTheme.headlineSmall,
                                );
                              }
                            case ArtistsSort.dateAdded:
                              {
                                return Text(
                                  '${artist.timeAdded.label}',
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
                              (e) => helper.artistElementsPerRow > 1
                                  ? (helper.artistTileHeight +
                                      tileMargin(context))
                                  : kArtistTileListViewHeight,
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
                                      '${Collection.instance.artists.length} ${Language.instance.ARTIST}',
                                    ),
                                    const Spacer(),
                                    MobileSortByButton(tab: kArtistTabIndex),
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

class ArtistTile extends StatelessWidget {
  final double height;
  final double width;
  final Artist artist;
  final bool forceDefaultStyleOnMobile;

  const ArtistTile({
    Key? key,
    required this.height,
    required this.width,
    required this.artist,
    this.forceDefaultStyleOnMobile = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final helper = DimensionsHelper(context);

    // Only for mobile:
    final artistElementsPerRow =
        forceDefaultStyleOnMobile ? 1 : helper.artistElementsPerRow;
    final artistTileNormalDensity =
        forceDefaultStyleOnMobile ? false : helper.artistTileNormalDensity;

    Iterable<Color>? palette;

    // Desktop
    if (isDesktop) {
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
              elevation: Theme.of(context).cardTheme.elevation ??
                  kDefaultCardElevation,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  width / 2.0,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Hero(
                    tag: 'artist_art_${artist.artistName}',
                    child: ClipOval(
                      child: ExtendedImage(
                        fit: BoxFit.cover,
                        image: getAlbumArt(artist, small: true),
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
                        Playback.instance.interceptPositionChangeRebuilds =
                            true;
                        try {
                          await precacheImage(getAlbumArt(artist), context);
                        } catch (exception, stacktrace) {
                          debugPrint(exception.toString());
                          debugPrint(stacktrace.toString());
                        }
                        Navigator.of(context).push(
                          MaterialRoute(
                            builder: (context) => ArtistScreen(
                              artist: artist,
                            ),
                          ),
                        );
                        Timer(const Duration(milliseconds: 400), () {
                          Playback.instance.interceptPositionChangeRebuilds =
                              false;
                        });
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
              style: Theme.of(context).textTheme.titleSmall,
              textAlign: TextAlign.left,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
          ],
        ),
      );
    }

    // Mobile
    switch (artistElementsPerRow) {
      case 1:
        return Material(
          color: Colors.transparent,
          child: OpenContainer(
            closedColor: Colors.transparent,
            closedElevation: 0.0,
            openColor: Colors.transparent,
            openElevation: 0.0,
            openBuilder: (context, close) => ArtistScreen(
              artist: artist,
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
                                  getAlbumArt(artist, small: true));
                          palette = result.colors;
                        }
                        await precacheImage(getAlbumArt(artist), context);
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
                            builder: (context) => ArtistScreen(
                              artist: artist,
                              palette: palette,
                            ),
                          ),
                        );
                      } else {
                        open();
                      }
                    },
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
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28.0),
                            ),
                            elevation: Theme.of(context).cardTheme.elevation ??
                                kDefaultCardElevation,
                            margin: EdgeInsets.zero,
                            child: Padding(
                              padding: EdgeInsets.all(2.0),
                              child: ClipOval(
                                child: ExtendedImage(
                                  fit: BoxFit.cover,
                                  image: getAlbumArt(artist, small: true),
                                  height: 48.0,
                                  width: 48.0,
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
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(
                                  height: 2.0,
                                ),
                                Text(
                                  Language.instance.M_TRACKS_AND_N_ALBUMS
                                      .replaceAll(
                                          'M', '${artist.tracks.length}')
                                      .replaceAll(
                                          'N', '${artist.albums.length}'),
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
        return Material(
          color: Colors.transparent,
          child: Container(
            height: height,
            width: width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                OpenContainer(
                  closedElevation: Theme.of(context).cardTheme.elevation ??
                      kDefaultCardElevation,
                  openElevation: 0.0,
                  closedColor: Theme.of(context).cardTheme.color ??
                      Theme.of(context).cardColor,
                  openColor: Theme.of(context).cardTheme.color ??
                      Theme.of(context).cardColor,
                  closedShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      width / 2.0,
                    ),
                  ),
                  openBuilder: (context, close) => ArtistScreen(
                    artist: artist,
                    palette: palette,
                  ),
                  closedBuilder: (context, open) => Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: width,
                        width: width,
                        color: Theme.of(context).cardTheme.color,
                        alignment: Alignment.center,
                        child: ClipOval(
                          child: ExtendedImage(
                            fit: BoxFit.cover,
                            image: getAlbumArt(
                              artist,
                              small: true,
                              cacheWidth: (width - 8.0) *
                                  MediaQuery.of(context).devicePixelRatio ~/
                                  1,
                            ),
                            height: width - 8.0,
                            width: width - 8.0,
                          ),
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () async {
                            try {
                              if (palette == null) {
                                final result =
                                    await PaletteGenerator.fromImageProvider(
                                        getAlbumArt(artist, small: true));
                                palette = result.colors;
                              }
                              await precacheImage(getAlbumArt(artist), context);
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
                                  builder: (context) => ArtistScreen(
                                    artist: artist,
                                    palette: palette,
                                  ),
                                ),
                              );
                            } else {
                              open();
                            }
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
                const Spacer(),
                Text(
                  artist.artistName.overflow,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: artistTileNormalDensity ? null : 14.0,
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
              ],
            ),
          ),
        );
    }
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

  static const double kMobileLayoutInitialScrollOffset = 128.0;

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
                  widget.artist,
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
    const mobileSliverLabelHeight = 108.0;
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
      builder: (context, collection, _) {
        final tracks = widget.artist.tracks.toList();
        tracks.sort(
          (first, second) {
            if (first.albumName != second.albumName) {
              return first.albumName.compareTo(second.albumName);
            }
            if (first.discNumber != second.discNumber) {
              return first.discNumber.compareTo(second.discNumber);
            }
            if (first.trackNumber != second.trackNumber) {
              return first.trackNumber.compareTo(second.trackNumber);
            }
            if (first.trackName != second.trackName) {
              return first.trackName.compareTo(second.trackName);
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
                          elevation: Theme.of(context).cardTheme.elevation ??
                              kDefaultCardElevation,
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
                                    flex: 6,
                                    child: LayoutBuilder(
                                      builder: (context, constraints) =>
                                          ClipRect(
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
                                                    'artist_art_${widget.artist.artistName}',
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    shape: BoxShape.circle,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        blurRadius: 8.0,
                                                        color: Colors.black26,
                                                        spreadRadius: 6.0,
                                                        offset: Offset(0, 6.0),
                                                      )
                                                    ],
                                                  ),
                                                  padding: EdgeInsets.all(8.0),
                                                  child: CircleAvatar(
                                                    radius: 240.0,
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    backgroundImage:
                                                        getAlbumArt(
                                                            widget.artist),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
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
                                                    widget.artist.artistName,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headlineSmall
                                                        ?.copyWith(
                                                            fontSize: 24.0),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  SizedBox(height: 8.0),
                                                  Text(
                                                    '${Language.instance.TRACK}: ${tracks.length}\n${Language.instance.ALBUM}: ${widget.artist.albums.length}',
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
                                                      Playback.instance.open(
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
                                                      );
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
                                                        tracks.toList(),
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
                                                            Language.instance
                                                                .TRACK_SINGLE,
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .titleSmall,
                                                          ),
                                                        ),
                                                        flex: 3,
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
                                                                .ALBUM_SINGLE,
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .titleSmall,
                                                          ),
                                                        ),
                                                        flex: 2,
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
                                                tracks
                                                    .toList()
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
                                                            var result =
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
                                                                      .artist
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
                                                                            ...([
                                                                              ...collection.tracks
                                                                            ]..shuffle())
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
                                                                                      [
                                                                                        ...tracks,
                                                                                        if (Configuration.instance.seamlessPlayback)
                                                                                          ...[
                                                                                            ...Collection.instance.tracks
                                                                                          ]..shuffle(),
                                                                                      ],
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
                                                                          flex:
                                                                              3,
                                                                        ),
                                                                        const Spacer(
                                                                          flex:
                                                                              2,
                                                                        ),
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
                                                                                recursivelyPopNavigatorOnDeleteIf: () => widget.artist.tracks.isEmpty,
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
                                                                    const Spacer(
                                                                      flex: 3,
                                                                    ),
                                                                    Expanded(
                                                                      child: Container(
                                                                          height: 48.0,
                                                                          padding: EdgeInsets.only(right: 8.0),
                                                                          alignment: Alignment.centerLeft,
                                                                          child: HyperLink(
                                                                            style:
                                                                                Theme.of(context).textTheme.bodyLarge,
                                                                            text:
                                                                                TextSpan(
                                                                              children: [
                                                                                TextSpan(
                                                                                  text: track.value.albumName,
                                                                                  recognizer: TapGestureRecognizer()
                                                                                    ..onTap = () {
                                                                                      final album = Collection.instance.albumsSet.lookup(
                                                                                        Album(
                                                                                          albumName: track.value.albumName,
                                                                                          year: track.value.year,
                                                                                          albumArtistName: track.value.albumArtistName,
                                                                                          albumHashCodeParameters: Collection.instance.albumHashCodeParameters,
                                                                                        ),
                                                                                      );
                                                                                      if (album != null) {
                                                                                        Playback.instance.interceptPositionChangeRebuilds = true;
                                                                                        Navigator.of(context).push(
                                                                                          MaterialRoute(
                                                                                            builder: (context) => AlbumScreen(
                                                                                              album: album,
                                                                                            ),
                                                                                          ),
                                                                                        );
                                                                                        Timer(const Duration(milliseconds: 400), () {
                                                                                          Playback.instance.interceptPositionChangeRebuilds = false;
                                                                                        });
                                                                                      }
                                                                                    },
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          )),
                                                                      flex: 2,
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
            : Scaffold(
                body: Stack(
                  children: [
                    NowPlayingBarScrollHideNotifier(
                      child: CustomScrollView(
                        physics: physics,
                        controller: controller,
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
                              const SizedBox(width: 8.0),
                            ],
                            forceElevated: true,
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
                                  widget.artist.artistName.overflow,
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
                                            image: getAlbumArt(widget.artist),
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
                                                  widget.artist.artistName
                                                      .overflow,
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
                                                const SizedBox(height: 4.0),
                                                Text(
                                                  Language.instance
                                                      .M_TRACKS_AND_N_ALBUMS
                                                      .replaceAll('M',
                                                          '${tracks.length}')
                                                      .replaceAll('N',
                                                          '${widget.artist.albums.length}'),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
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
                                                ),
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
                                              index: 0,
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
                              (context, i) {
                                void handler() async {
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
                                        widget.artist.tracks.isEmpty,
                                  );
                                }

                                return Material(
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
                                    onLongPress: handler,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          height: 64.0,
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
                                                      .bodyMedium
                                                      ?.copyWith(
                                                          fontSize: 18.0),
                                                ),
                                              ),
                                              const SizedBox(width: 12.0),
                                              Expanded(
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
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
                                                    const SizedBox(height: 2.0),
                                                    Text(
                                                      [
                                                        tracks[i]
                                                                .duration
                                                                ?.label ??
                                                            Duration.zero.label,
                                                        if (!tracks[i]
                                                            .albumNameNotPresent)
                                                          tracks[i].albumName,
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
                                                  onPressed: handler,
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
                                );
                              },
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
