/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';
import 'package:media_library/media_library.dart';
import 'package:extended_image/extended_image.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';

import 'package:harmonoid/utils/palette_generator.dart';
import 'package:harmonoid/interface/modern_layout/modern_collection/modern_album.dart';
import 'package:harmonoid/interface/modern_layout/modern_collection/modern_track.dart';
import 'package:harmonoid/interface/modern_layout/rendering_modern.dart';
import 'package:harmonoid/interface/modern_layout/utils_modern/broken_icons.dart';
import 'package:harmonoid/interface/modern_layout/utils_modern/widgets_modern.dart';
import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/state/mobile_now_playing_controller.dart';
import 'package:harmonoid/utils/dimensions.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/constants/language.dart';

class ArtistTabModern extends StatefulWidget {
  final List<Artist>? artistsList;
  ArtistTabModern({
    Key? key,
    this.artistsList,
  }) : super(key: key);

  @override
  _ArtistTabModernState createState() => _ArtistTabModernState();
}

class _ArtistTabModernState extends State<ArtistTabModern> {
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
          margin: tileMargin,
          elementsPerRow: helper.artistElementsPerRow,
          widgetCount: widget.artistsList?.length ?? collection.artists.length,
          builder: (BuildContext context, int index) => ArtistTileModern(
            width: helper.artistTileWidth,
            height: helper.artistTileHeight,
            artist: widget.artistsList?[index] ?? collection.artists[index],
            key: ValueKey(
                widget.artistsList?[index] ?? collection.artists[index]),
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
                                28.0 + tileMargin,
                              ] +
                              List.generate(
                                data.widgets.length,
                                (index) => helper.artistTileHeight + tileMargin,
                              ),
                          itemBuilder: (context, i) => i == 0
                              ? SortBarFixedHolder(
                                  child: SortBar(
                                    tab: 2,
                                    hover: hover,
                                    fixed: true,
                                  ),
                                )
                              : data.widgets[i - 1],
                        ),
                        SortBar(
                          tab: 2,
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
                          width: 120.0,
                          height: 32.0,
                        ),
                        labelTextBuilder: (offset) {
                          final perTileHeight = helper.artistElementsPerRow > 1
                              ? (helper.artistTileHeight + tileMargin)
                              : kArtistTileListViewHeight;
                          final index = (offset -
                                  (kMobileSearchBarHeightModern +
                                      2 * tileMargin +
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
                                      Theme.of(context).textTheme.displayLarge,
                                );
                              }
                            case ArtistsSort.dateAdded:
                              {
                                return Text(
                                  '${artist.timeAdded.label}',
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
                          itemExtent: helper.artistElementsPerRow > 1
                              ? (helper.artistTileHeight + tileMargin)
                              : kArtistTileListViewHeight,
                          padding: EdgeInsets.only(
                            top: MediaQuery.of(context).padding.top +
                                kMobileSearchBarHeightModern +
                                2 * tileMargin,
                            bottom: Configuration.instance.stickyMiniplayer
                                ? kMobileNowPlayingBarHeight
                                : kMobileBottomPaddingStickyMiniplayer,
                          ),
                          children: data.widgets,
                        ),
                      )
                    : Container(
                        // padding: EdgeInsets.only(
                        //   top: MediaQuery.of(context).padding.top +
                        //       kMobileSearchBarHeightModern +
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

class ArtistTileModern extends StatelessWidget {
  final double height;
  final double width;
  final Artist artist;
  final bool forceDefaultStyleOnMobile;
  final bool forceDisableOnePerRow;

  const ArtistTileModern({
    Key? key,
    required this.height,
    required this.width,
    required this.artist,
    this.forceDefaultStyleOnMobile = false,
    this.forceDisableOnePerRow = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final helper = DimensionsHelper(context);
    Iterable<Color>? palette;
    if (isMobile && forceDefaultStyleOnMobile) {
      return Material(
        color: Colors.transparent,
        child: OpenContainer(
          closedColor: Colors.transparent,
          closedElevation: 0.0,
          openColor: Colors.transparent,
          openElevation: 0.0,
          openBuilder: (context, close) => ArtistScreenModern(
            artist: artist,
            palette: palette,
          ),
          closedBuilder: (context, open) => SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // const Divider(
                //   height: 1.0,
                //   thickness: 1.0,
                //   indent: 76.0,
                // ),
                InkWell(
                  onTap: () async {
                    try {
                      if (palette == null) {
                        final result = await PaletteGenerator.fromImageProvider(
                            getAlbumArt(artist, small: true));
                        palette = result.colors;
                      }
                      await precacheImage(getAlbumArt(artist), context);
                      if (!Configuration.instance.stickyMiniplayer)
                        MobileNowPlayingController.instance.hide();
                    } catch (exception, stacktrace) {
                      debugPrint(exception.toString());
                      debugPrint(stacktrace.toString());
                    }
                    open();
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
                                    Theme.of(context).textTheme.displayMedium,
                              ),
                              const SizedBox(
                                height: 2.0,
                              ),
                              Text(
                                Language.instance.M_TRACKS_AND_N_ALBUMS
                                    .replaceAll('M', '${artist.tracks.length}')
                                    .replaceAll('N', '${artist.albums.length}'),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: Theme.of(context).textTheme.displaySmall,
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
    }
    return isDesktop
        ? Container(
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
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        FadeThroughTransition(
                                  animation: animation,
                                  secondaryAnimation: secondaryAnimation,
                                  child: ArtistScreenModern(
                                    artist: artist,
                                  ),
                                ),
                                transitionDuration: Duration(milliseconds: 300),
                                reverseTransitionDuration:
                                    Duration(milliseconds: 300),
                              ),
                            );
                            Timer(const Duration(milliseconds: 400), () {
                              Playback.instance
                                  .interceptPositionChangeRebuilds = false;
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
                  style: Theme.of(context).textTheme.displayMedium,
                  textAlign: TextAlign.left,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
              ],
            ),
          )
        : helper.artistElementsPerRow == 1 && !forceDisableOnePerRow
            ? Material(
                color: Colors.transparent,
                child: OpenContainer(
                  closedColor: Colors.transparent,
                  closedElevation: 0.0,
                  openColor: Colors.transparent,
                  openElevation: 0.0,
                  openBuilder: (context, close) => ArtistScreenModern(
                    artist: artist,
                    palette: palette,
                  ),
                  closedBuilder: (context, open) => SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // const Divider(
                        //   height: 1.0,
                        //   thickness: 1.0,
                        //   indent: 76.0,
                        // ),
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
                              if (!Configuration.instance.stickyMiniplayer)
                                MobileNowPlayingController.instance.hide();
                            } catch (exception, stacktrace) {
                              debugPrint(exception.toString());
                              debugPrint(stacktrace.toString());
                            }
                            open();
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
                                  elevation:
                                      Theme.of(context).cardTheme.elevation ??
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        artist.artistName.overflow,
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
                                        Language.instance.M_TRACKS_AND_N_ALBUMS
                                            .replaceAll(
                                                'M', '${artist.tracks.length}')
                                            .replaceAll(
                                                'N', '${artist.albums.length}'),
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
            : Material(
                color: Colors.transparent,
                child: Container(
                  height: height,
                  width: width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      OpenContainer(
                        closedElevation:
                            Theme.of(context).cardTheme.elevation ??
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
                        openBuilder: (context, close) => ArtistScreenModern(
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
                              child: Hero(
                                tag: 'artist_art_${artist.artistName}',
                                child: ClipOval(
                                  child: ExtendedImage(
                                    fit: BoxFit.cover,
                                    image: getAlbumArt(
                                      artist,
                                      small: true,
                                      cacheWidth: (width - 8.0) *
                                          MediaQuery.of(context)
                                              .devicePixelRatio ~/
                                          1,
                                    ),
                                    height: width - 8.0,
                                    width: width - 8.0,
                                  ),
                                ),
                              ),
                            ),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () async {
                                  try {
                                    if (palette == null) {
                                      final result = await PaletteGenerator
                                          .fromImageProvider(
                                              getAlbumArt(artist, small: true));
                                      palette = result.colors;
                                    }
                                    await precacheImage(
                                        getAlbumArt(artist), context);
                                    if (!Configuration
                                        .instance.stickyMiniplayer)
                                      MobileNowPlayingController.instance
                                          .hide();
                                  } catch (exception, stacktrace) {
                                    debugPrint(exception.toString());
                                    debugPrint(stacktrace.toString());
                                  }
                                  open();
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
                        style: Theme.of(context)
                            .textTheme
                            .displayMedium
                            ?.copyWith(
                              fontSize:
                                  helper.artistTileNormalDensity ? null : 14.0,
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

class ArtistScreenModern extends StatefulWidget {
  final Artist artist;
  final Iterable<Color>? palette;

  const ArtistScreenModern({
    Key? key,
    required this.artist,
    this.palette,
  }) : super(key: key);
  ArtistScreenModernState createState() => ArtistScreenModernState();
}

class ArtistScreenModernState extends State<ArtistScreenModern>
    with SingleTickerProviderStateMixin {
  Color? color;
  Color? secondary;
  int? hovered;
  bool reactToSecondaryPress = false;
  bool detailsVisible = false;
  bool detailsLoaded = false;
  ScrollController controller = ScrollController(initialScrollOffset: 116.0);
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
                    getAlbumArt(widget.artist, small: true))
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

  final brMultiplier = Configuration.instance.borderRadiusMultiplier;
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
          (first, second) =>
              first.albumName.compareTo(second.albumName) * 100000000 +
              first.discNumber.compareTo(second.discNumber) * 1000000 +
              first.trackNumber.compareTo(second.trackNumber) * 10000 +
              first.trackName.compareTo(second.trackName) * 100 +
              first.uri.toString().compareTo(second.uri.toString()),
        );
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Broken.arrow_left_2),
            ),
            actions: [
              IconButton(
                tooltip: Language.instance.ADD_TO_NOW_PLAYING,
                onPressed: () => Playback.instance.add(tracks),
                icon: Icon(Broken.play_cricle),
              ),
              MobileAppBarOverflowButtonModern(),
            ],
          ),
          body: NowPlayingBarScrollHideNotifier(
              child: Stack(
            children: [
              ListView(
                shrinkWrap: true,
                physics: BouncingScrollPhysics(),
                children: [
                  // Top Container holding image and info and buttons
                  Container(
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width / 2.8,
                    padding: EdgeInsets.all(24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Hero(
                          tag: 'artist_art_${widget.artist.artistName}',
                          child: ClipOval(
                            child: ExtendedImage(
                              fit: BoxFit.cover,
                              image: getAlbumArt(widget.artist),
                              height: MediaQuery.of(context).size.width / 2.8,
                              width: MediaQuery.of(context).size.width / 2.8,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 18.0,
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 18.0,
                              ),
                              Container(
                                padding: EdgeInsets.only(left: 14.0),
                                child: Text(
                                  widget.artist.artistName.overflow,
                                  style:
                                      Theme.of(context).textTheme.displayLarge,
                                ),
                              ),
                              const SizedBox(
                                height: 2.0,
                              ),
                              Container(
                                padding: EdgeInsets.only(left: 14.0),
                                child: Text(
                                  [
                                    Language.instance.N_TRACKS.replaceAll(
                                      'N',
                                      '${widget.artist.tracks.length}',
                                    ),
                                    getTotalTracksDurationFormatted(
                                        tracks: widget.artist.tracks.toList())
                                  ].join(' - '),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayMedium
                                      ?.copyWith(fontSize: 14),
                                ),
                              ),
                              const SizedBox(
                                height: 18.0,
                              ),
                              Row(
                                // mainAxisAlignment:
                                //     MainAxisAlignment.spaceEvenly,
                                children: [
                                  Spacer(),
                                  FittedBox(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Playback.instance.open(
                                          [...widget.artist.tracks]..shuffle(),
                                        );
                                      },
                                      child: Icon(Broken.shuffle),
                                    ),
                                  ),
                                  Spacer(),
                                  FittedBox(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Playback.instance.open(
                                          [
                                            ...widget.artist.tracks,
                                            if (Configuration
                                                .instance.seamlessPlayback)
                                              ...[...Collection.instance.tracks]
                                                ..shuffle()
                                          ],
                                        );
                                      },
                                      child: Row(
                                        children: [
                                          Icon(Broken.play),
                                          const SizedBox(
                                            width: 8.0,
                                          ),
                                          Text(Language.instance.PLAY_ALL),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    height: 175,
                    child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.artist.albums.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: EdgeInsets.only(left: 8.0, bottom: 8.0),
                          child: AlbumTileModern(
                            album: widget.artist.albums.toList()[index],
                            height: 120,
                            width: 120,
                            forceDefaultStyleOnMobile: false,
                            forceDisableOnePerRow: true,
                          ),
                        );
                      },
                    ),
                  ),
                  TrackTabModern(
                    tracks: tracks,
                  )
                ],
              ),
            ],
          )),
        );
      },
    );
  }
}
