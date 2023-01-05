/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///
import 'dart:math';
import 'dart:ui';
import 'dart:async';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:harmonoid/interface/modern_layout/rendering_modern.dart';
import 'package:harmonoid/interface/modern_layout/utils_modern/broken_icons.dart';
import 'package:harmonoid/interface/modern_layout/utils_modern/widgets_modern.dart';
import 'package:harmonoid/interface/modern_layout/waveform_widget.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:media_engine/media_engine.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:media_library/media_library.dart';
import 'package:drop_shadow/drop_shadow.dart';
import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter_lyric/lyrics_reader.dart';
import 'package:flutter_lyric/lyrics_reader_model.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/utils/theme.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/dimensions.dart';
import 'package:harmonoid/utils/mini_player.dart';
import 'package:harmonoid/utils/sliding_up_panel.dart';
import 'package:harmonoid/state/lyrics.dart';
import 'package:harmonoid/state/now_playing_color_palette.dart';
import 'package:harmonoid/state/mobile_now_playing_controller.dart';
import 'package:harmonoid/interface/now_playing_bar.dart';
import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/web/utils/widgets.dart';
import 'package:harmonoid/interface/modern_layout/modern_collection/modern_track.dart';

const kDetailsAreaHeight = 100.0;

class MiniNowPlayingBar extends StatefulWidget {
  MiniNowPlayingBar({Key? key}) : super(key: key);

  @override
  State<MiniNowPlayingBar> createState() => MiniNowPlayingBarState();
}

class MiniNowPlayingBarState extends State<MiniNowPlayingBar> with TickerProviderStateMixin {
  double _y = 0.0;

  bool get isHidden => _y != 0.0;

  // TODO (@alexmercerind): De-couple from [BuildContext].

  void show() {
    if (Playback.instance.tracks.isEmpty) return;
    if (_y != 0.0) {
      setState(() => _y = 0.0);
    }
  }

  void hide() {
    if (_y == 0.0) {
      setState(
        () => _y = (kMobileNowPlayingBarHeight + 4.0) / (MediaQuery.of(context).size.height - MediaQuery.of(context).padding.vertical),
      );
    }
  }

  void maximize() {
    controller.animateToHeight(state: MiniPlayerPanelState.MAX);
  }

  void restore() {
    controller.animateToHeight(state: MiniPlayerPanelState.MIN);
  }

  late AnimationController playOrPause;
  int index = Playback.instance.index;
  int currentPage = Playback.instance.index;
  Track? track;

  List<Widget> more = [];
  List<Widget> tracks = [];
  List<Track> moreMain = [];
  List<Widget> tracksSkipped = [];
  bool showAlbumArtButton = false;
  PageController pageController = PageController(initialPage: Playback.instance.index);
  MiniplayerController controller = MiniplayerController();
  PanelController slidingUpPanelController = PanelController();
  ValueNotifier<bool> minimizedPlaylist = ValueNotifier<bool>(true);
  List<Widget> fills = [];
  Color? color;
  Timer? timer;
  Widget? playlistPanel;

  bool isPlayPauseButtonHighlighted = false;

  @override
  void initState() {
    super.initState();
    _y = (kMobileNowPlayingBarHeight + 4.0) / (window.physicalSize.height - window.padding.top / window.devicePixelRatio + 16.0 - window.padding.bottom) * window.devicePixelRatio;
    playOrPause = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    Playback.instance.addListener(listener);
    NowPlayingColorPalette.instance.addListener(colorPaletteListener);
  }

  @override
  void dispose() {
    Playback.instance.removeListener(listener);
    NowPlayingColorPalette.instance.removeListener(colorPaletteListener);
    super.dispose();
  }

  void colorPaletteListener() {
    if (!Configuration.instance.mobileEnableNowPlayingScreenRippleEffect || Configuration.instance.isModernLayout) {
      color = Theme.of(context).scaffoldBackgroundColor;
      setState(() {});
    } else {
      final ms = ((1000 * (400 / MediaQuery.of(context).size.width)) ~/ 1);
      final color = NowPlayingColorPalette.instance.palette?.first.withOpacity(1.0);
      if (color == this.color) {
        return;
      }
      if (timer?.isActive ?? true) {
        timer?.cancel();
      }
      timer = Timer(
        Duration(milliseconds: ms + 100),
        () async {
          setState(() {
            this.color = color;
          });
          await Future.delayed(const Duration(milliseconds: 100));
          setState(() {
            debugPrint(
              '[MiniNowPlayingBar] Freed ${fills.length} [Color] [TweenAnimationBuilder] fill(s).',
            );
            fills.clear();
          });
        },
      );
      setState(() {
        fills.add(
          TweenAnimationBuilder(
            tween: Tween<double>(
              begin: 0.0,
              end: 2 * MediaQuery.of(context).size.width / 4.0,
            ),
            duration: Duration(
              milliseconds: ms,
            ),
            curve: Curves.easeInOut,
            child: Container(
              height: kDesktopNowPlayingBarHeight,
              width: MediaQuery.of(context).size.width,
              alignment: Alignment.center,
              child: ClipRect(
                child: Container(
                  height: 4.0,
                  width: 4.0,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            builder: (context, value, child) => Transform.scale(
              scale: value as double,
              child: child,
            ),
          ),
        );
      });
    }
  }

  bool get isVolumeSliderVisible {
    final vh = MediaQuery.of(context).size.height;
    final vw = MediaQuery.of(context).size.width;
    // Enabled in Settings.
    return Configuration.instance.mobileDisplayVolumeSliderDirectlyOnNowPlayingScreen &&
        // Has enough room on screen. Referring to taller 20:9 (?) devices with larger resolution.
        // Bottom sheet's height compared with certain threshold, here `256.0`.
        (vh - (vw + kDetailsAreaHeight + 128.0)) >= 128.0;
  }

  double get bottomSheetMinHeight => isVolumeSliderVisible ? 172.0 : 128.0;

  Future<void> listener() async {
    if (Playback.instance.isPlaying) {
      playOrPause.forward();
    } else {
      playOrPause.reverse();
    }
    if (Playback.instance.index < 0 || Playback.instance.index >= Playback.instance.tracks.length || Playback.instance.tracks.isEmpty) {
      return;
    }
    if (index != Playback.instance.index) {
      if (pageController.hasClients) {
        pageController.animateToPage(
          Playback.instance.index,
          duration: Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      } else {
        pageController = PageController(
          initialPage: Playback.instance.index,
        );
      }
      setState(() {
        index = Playback.instance.index;
        currentPage = Playback.instance.index;
      });
      try {
        // Precache adjacent album arts for smoother swipe transitions to the next/previous track.
        await Future.wait([
          precacheImage(
            getAlbumArt(
              Playback.instance.tracks[Playback.instance.index - 1],
            ),
            context,
          ),
          precacheImage(
            getAlbumArt(
              Playback.instance.tracks[Playback.instance.index + 1],
            ),
            context,
          ),
        ]);
      } catch (exception, stacktrace) {
        debugPrint(exception.toString());
        debugPrint(stacktrace.toString());
      }
    }
    final track = Playback.instance.tracks[Playback.instance.index];
    final update = this.track != track || tracks.length.compareTo(Playback.instance.tracks.length) != 0;
    if (update) {
      this.track = track;
      // NOTE: Do not depend on [BuildContext] here.
      // Container(
      //   height: 32.0,
      //   width: 22.0,
      //   alignment: Alignment.center,
      //   child: MiniMusicVisualizer(
      //     color: Theme.of(context).textTheme.displaySmall?.color,
      //     width: 2,
      //     height: 15,
      //   ),
      // );
      tracks = Playback.instance.tracks
          .asMap()
          .entries
          .map(
            (e) => Builder(
              key: ValueKey(e.key),
              builder: (context) => Dismissible(
                key: UniqueKey(),
                onDismissed: (direction) {
                  setState(() {
                    Playback.instance.removeAt(e.key);
                  });
                },
                child: TrackTileModern(
                  displayRightDragHandler: true,
                  track: e.value,
                  index: e.key,
                  disableContextMenu: true,
                  disableSeparator: true,
                  onPressed: () {
                    if (e.value == track) {
                      Playback.instance.playOrPause();
                    } else {
                      Playback.instance.jump(e.key);
                    }
                  },
                  leading: e.key == Playback.instance.index
                      ? Stack(
                          children: [
                            CustomTrackThumbnailModern(
                              scale: 1,
                              borderRadius: 8,
                              blur: 2,
                              media: e.value,
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: CustomSmallBlurryBoxModern(
                                height: Configuration.instance.trackListTileHeight * 0.3,
                                child: MiniMusicVisualizer(
                                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black54,
                                  width: 2,
                                  height: 15,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Stack(
                          children: [
                            CustomTrackThumbnailModern(
                              scale: 1,
                              borderRadius: 8,
                              blur: 2,
                              media: e.value,
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: BlurryContainer(
                                height: Configuration.instance.trackListTileHeight * 0.3,
                                padding: EdgeInsets.symmetric(horizontal: 6),
                                blur: Configuration.instance.enableBlurEffect ? 5 : 0,
                                borderRadius: BorderRadius.circular(6 * Configuration.instance.borderRadiusMultiplier),
                                color: Configuration.instance.enableBlurEffect
                                    ? Theme.of(context).brightness == Brightness.dark
                                        ? Colors.black12
                                        : Colors.white24
                                    : Theme.of(context).brightness == Brightness.dark
                                        ? Colors.black54
                                        : Colors.white70,
                                child: Center(
                                  child: Text(
                                    '${e.key - Playback.instance.index <= 0 ? '' : '+'}${e.key - Playback.instance.index}',
                                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                          fontSize: Configuration.instance.trackListTileHeight * 0.18,
                                          color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black54,
                                        ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                  title: Text(
                    e.value.trackName,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: e.key < Playback.instance.index ? Theme.of(context).textTheme.displaySmall?.color : null,
                        ),
                  ),
                  subtitle: Text(
                    e.value.trackArtistNames.take(1).join(', '),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                ),
              ),
            ),
          )
          .toList();

      if (minimizedPlaylist.value || more.isEmpty) {
        final shuffle = [
          ...Collection.instance.tracks,
        ]..shuffle();
        moreMain = shuffle.take(10).toList();
        more = moreMain
            .map(
              (e) => Builder(
                key: ValueKey(e.uri),
                builder: (context) => TrackTileModern(
                  displayRightDragHandler: true,
                  track: e,
                  index: 0,
                  group: [e] + shuffle,
                  disableContextMenu: true,
                  disableSeparator: true,
                ),
              ),
            )
            .toList();
      }

      tracksSkipped = tracks.skip(Playback.instance.index + 1).take(20).toList();
    }
  }

  double topAreaArrowAndNumber = 50.0;

  double get pageViewHeight {
    final double settingHeight = Configuration.instance.nowPlayingImageContainerHeight;
    final double screenWidth = MediaQuery.of(context).size.width;
    if (settingHeight > screenWidth) {
      return screenWidth;
    }
    return settingHeight;
  }

  double get queueSheetMaxHeight {
    final double settingHeight = Configuration.instance.queueSheetMaxHeight;
    final double screenHeight = MediaQuery.of(context).size.height;
    if (settingHeight > screenHeight) {
      return screenHeight;
    }
    return settingHeight;
  }

  @override
  Widget build(BuildContext context) {
    // NowPlayingColorPalette colors = NowPlayingColorPalette.instance;

    return AnimatedSlide(
      offset: Offset(0, _y),
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Miniplayer(
        duration: Duration(milliseconds: 500),
        curve: Curves.easeOutQuart,
        controller: controller,
        borderRadiusValues: [8 * Configuration.instance.borderRadiusMultiplier, 8 * Configuration.instance.borderRadiusMultiplier, 0, 0],
        elevation: Theme.of(context).appBarTheme.elevation ?? 16,
        minHeight: kMobileNowPlayingBarHeight,
        maxHeight: MediaQuery.of(context).size.height,
        tapToCollapse: false,
        builder: (height, percentage) {
          if (percentage < 1.0) {
            try {
              minimizedPlaylist.value = true;
            } catch (exception, stacktrace) {
              debugPrint(exception.toString());
              debugPrint(stacktrace.toString());
            }
            try {
              slidingUpPanelController.close();
            } catch (exception, stacktrace) {
              debugPrint(exception.toString());
              debugPrint(stacktrace.toString());
            }
          }
          try {
            WidgetsBinding.instance.addPostFrameCallback(
              (_) {
                MobileNowPlayingController.instance.bottomNavigationBar.value = (1.0 - (percentage * 1.4).clamp(0.0, 1.0)) * kBottomNavigationBarHeight;
              },
            );
          } catch (exception, stacktrace) {
            debugPrint(exception.toString());
            debugPrint(stacktrace.toString());
          }
          Widget playOrPauseButtonModern = GestureDetector(
            onTapDown: (value) {
              setState(() {
                isPlayPauseButtonHighlighted = true;
              });
            },
            onTapUp: (value) {
              setState(() {
                isPlayPauseButtonHighlighted = false;
              });
            },
            onTapCancel: () {
              setState(() {
                isPlayPauseButtonHighlighted = !isPlayPauseButtonHighlighted;
              });
            },
            child: AnimatedContainer(
              height: percentage > 0.5 ? 64.0 : null,
              width: percentage > 0.5 ? 64.0 : null,
              duration: Duration(milliseconds: 400),
              decoration: BoxDecoration(
                  color: isPlayPauseButtonHighlighted ? Color.alphaBlend(NowPlayingColorPalette.instance.modernColor.withAlpha(233), Colors.white) : NowPlayingColorPalette.instance.modernColor,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      NowPlayingColorPalette.instance.modernColor,
                      Color.alphaBlend(NowPlayingColorPalette.instance.modernColor.withAlpha(200), Colors.grey),
                    ],
                    stops: [0, 0.7],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: NowPlayingColorPalette.instance.modernColor,
                      blurRadius: 8.0,
                      spreadRadius: isPlayPauseButtonHighlighted ? 3.0 : 1.0,
                      offset: Offset(0, 2),
                    ),
                  ]
                  // borderRadius: BorderRadius
                  //       .circular(Configuration
                  //               .instance
                  //               .borderRadiusMultiplier *
                  //           12),
                  ),
              child: IconButton(
                highlightColor: Colors.transparent,
                onPressed: () {
                  setState(() {
                    Playback.instance.playOrPause();
                  });
                },
                icon: Consumer<Playback>(
                  builder: (context, playback, _) => AnimatedSwitcher(
                    duration: Duration(milliseconds: 100),
                    child: playback.isPlaying
                        ? Icon(
                            Broken.pause,
                            size: percentage > 0.5 ? 30.0 : 26.0,
                            color: Color.fromARGB(200, 233, 233, 233),
                            key: Key("pauseicon"),
                          )
                        : Icon(
                            Broken.play,
                            size: percentage > 0.5 ? 30.0 : 26.0,
                            color: Color.fromARGB(200, 233, 233, 233),
                            key: Key("playicon"),
                          ),
                  ),
                ),
              ),
            ),
          );
          return () {
            if (Playback.instance.tracks.isEmpty) return const SizedBox.shrink();
            return Stack(
              alignment: Alignment.topCenter,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height,
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: ListView(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    children: [
                      SizedBox(
                        height: percentage * topAreaArrowAndNumber,
                      ),
                      Container(
                        height: percentage == 1.0
                            ? pageViewHeight
                            : height < pageViewHeight
                                ? height
                                : height >= pageViewHeight
                                    ? pageViewHeight
                                    : null,
                        child: Stack(
                          children: [
                            if (percentage < 1.0)
                              Opacity(
                                opacity: 1 - percentage,
                                child: Consumer<Playback>(
                                  builder: (context, playback, _) => Container(
                                    alignment: Alignment.centerLeft,
                                    height: height,
                                    decoration: BoxDecoration(color: NowPlayingColorPalette.instance.modernColor.withAlpha(100), boxShadow: [
                                      BoxShadow(
                                        color: NowPlayingColorPalette.instance.modernColor.withAlpha(100),
                                        blurRadius: 8.0,
                                        spreadRadius: 1.0,
                                        offset: Offset(8, 0),
                                      ),
                                    ]),
                                    width: playback.duration == Duration.zero ? 0.0 : (playback.position.inMilliseconds / playback.duration.inMilliseconds * MediaQuery.of(context).size.width),
                                  ),
                                ),
                              ),
                            Positioned.fill(
                              child: Material(
                                color: Colors.transparent,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Stack(
                                      alignment: Alignment.topLeft,
                                      children: [
                                        if (percentage == 1.0)
                                          Container(
                                            color: Colors.black,
                                            width: MediaQuery.of(context).size.width,
                                            height: pageViewHeight,
                                          ),
                                        percentage == 1.0
                                            ? () {
                                                if (pageController.initialPage != Playback.instance.index) {
                                                  pageController = PageController(
                                                    initialPage: Playback.instance.index,
                                                  );
                                                }
                                                return Opacity(
                                                  opacity: percentage,
                                                  child: Container(
                                                    height: MediaQuery.of(context).size.width,
                                                    width: MediaQuery.of(context).size.width,
                                                    child: NotificationListener<ScrollNotification>(
                                                      onNotification: (ScrollNotification notification) {
                                                        if (notification.depth == 0 && notification is ScrollEndNotification && notification.metrics.axis == Axis.horizontal) {
                                                          Playback.instance.jump(currentPage);
                                                        }
                                                        return false;
                                                      },
                                                      // child: Container(
                                                      //   color: Theme.of(context)
                                                      //       .scaffoldBackgroundColor,
                                                      //   child: CarouselSlider(
                                                      //     items: Playback
                                                      //         .instance.tracks
                                                      //         .map((i) {
                                                      //       return Builder(
                                                      //         builder:
                                                      //             (BuildContext
                                                      //                 context) {
                                                      //           return Stack(
                                                      //             children: [
                                                      //               Center(
                                                      //                 child:
                                                      //                     Container(
                                                      //                   padding:
                                                      //                       EdgeInsets.all(4.0 +
                                                      //                           8.0 * percentage),
                                                      //                   width: MediaQuery.of(context)
                                                      //                       .size
                                                      //                       .width,
                                                      //                   height: MediaQuery.of(context)
                                                      //                       .size
                                                      //                       .width,
                                                      //                   child:
                                                      //                       Center(
                                                      //                     child:
                                                      //                         ClipRRect(
                                                      //                       borderRadius:
                                                      //                           BorderRadius.circular((6 + 6 * percentage) * Configuration.instance.borderRadiusMultiplier),
                                                      //                       child:
                                                      //                           DropShadow(
                                                      //                         borderRadius: (6 + 6 * percentage) * Configuration.instance.borderRadiusMultiplier,
                                                      //                         blurRadius: 1 + percentage * 2,
                                                      //                         spread: 1,
                                                      //                         offset: Offset(0, 1),
                                                      //                         child: ExtendedImage(
                                                      //                           image: Image(image: getAlbumArt(i)).image,
                                                      //                           fit: BoxFit.cover,
                                                      //                           width: Configuration.instance.forceSquaredTrackThumbnail ? MediaQuery.of(context).size.width : null,
                                                      //                           height: Configuration.instance.forceSquaredTrackThumbnail ? MediaQuery.of(context).size.width : null,
                                                      //                           enableLoadState: true,
                                                      //                           handleLoadingProgress: true,
                                                      //                           loadStateChanged: (state) {
                                                      //                             switch (state.extendedImageLoadState) {
                                                      //                               case LoadState.failed:
                                                      //                                 {
                                                      //                                   if (LibmpvPluginUtils.isSupported(i.uri)) {
                                                      //                                     // Show [getAlbumArt] with smaller size in-case of a load failure.
                                                      //                                     return ExtendedImage(image: Image(image: getAlbumArt(i, small: true)).image, fit: BoxFit.cover, width: Configuration.instance.forceSquaredTrackThumbnail ? MediaQuery.of(context).size.width : null, height: Configuration.instance.forceSquaredTrackThumbnail ? MediaQuery.of(context).size.width : null);
                                                      //                                   }
                                                      //                                   return state.completedWidget;
                                                      //                                 }
                                                      //                               default:
                                                      //                                 return state.completedWidget;
                                                      //                             }
                                                      //                           },
                                                      //                         ),
                                                      //                       ),
                                                      //                     ),
                                                      //                   ),
                                                      //                 ),
                                                      //               ),
                                                      //             ],
                                                      //           );
                                                      //         },
                                                      //       );
                                                      //     }).toList(),
                                                      //     options:
                                                      //         CarouselOptions(
                                                      //       // aspectRatio: 1 / 1,
                                                      //       height:
                                                      //           pageViewHeight,
                                                      //       enlargeStrategy:
                                                      //           CenterPageEnlargeStrategy
                                                      //               .zoom,
                                                      //       // viewportFraction: 0.7,
                                                      //       initialPage:
                                                      //           Playback
                                                      //               .instance
                                                      //               .index,
                                                      //       enableInfiniteScroll:
                                                      //           false,
                                                      //       scrollPhysics:
                                                      //           CustomPageViewScrollPhysics(),
                                                      //       enlargeCenterPage:
                                                      //           true,
                                                      //       animateToClosest:
                                                      //           false,
                                                      //       enlargeFactor: 0.3,
                                                      //       onPageChanged:
                                                      //           (index,
                                                      //               reason) {
                                                      //         currentPage =
                                                      //             index;
                                                      //       },
                                                      //       scrollDirection:
                                                      //           Axis.horizontal,
                                                      //     ),
                                                      //   ),
                                                      // ),
                                                      child: PageView.builder(
                                                        physics: CustomPageViewScrollPhysics(),
                                                        scrollDirection: Axis.horizontal,
                                                        controller: pageController,
                                                        onPageChanged: (page) {
                                                          currentPage = page;
                                                        },
                                                        itemCount: Playback.instance.tracks.length,
                                                        itemBuilder: (context, i) => Container(
                                                          color: Theme.of(context).scaffoldBackgroundColor,
                                                          child: Stack(
                                                            children: [
                                                              Center(
                                                                child: Container(
                                                                  padding: EdgeInsets.all(4.0 + 8.0 * percentage),
                                                                  width: MediaQuery.of(context).size.width,
                                                                  height: MediaQuery.of(context).size.width,
                                                                  child: Center(
                                                                    child: ClipRRect(
                                                                      borderRadius: BorderRadius.circular((6 + 6 * percentage) * Configuration.instance.borderRadiusMultiplier),
                                                                      child: DropShadow(
                                                                        borderRadius: (6 + 6 * percentage) * Configuration.instance.borderRadiusMultiplier,
                                                                        blurRadius: 1 + percentage * 2,
                                                                        spread: 1,
                                                                        offset: Offset(0, 1),
                                                                        child: ExtendedImage(
                                                                          image: Image(image: getAlbumArt(Playback.instance.tracks[i])).image,
                                                                          fit: BoxFit.cover,
                                                                          width: Configuration.instance.forceSquaredTrackThumbnail ? MediaQuery.of(context).size.width : null,
                                                                          height: Configuration.instance.forceSquaredTrackThumbnail ? MediaQuery.of(context).size.width : null,
                                                                          enableLoadState: true,
                                                                          handleLoadingProgress: true,
                                                                          loadStateChanged: (state) {
                                                                            switch (state.extendedImageLoadState) {
                                                                              case LoadState.failed:
                                                                                {
                                                                                  if (LibmpvPluginUtils.isSupported(Playback.instance.tracks[i].uri)) {
                                                                                    // Show [getAlbumArt] with smaller size in-case of a load failure.
                                                                                    return ExtendedImage(
                                                                                        image: Image(image: getAlbumArt(Playback.instance.tracks[i], small: true)).image,
                                                                                        fit: BoxFit.cover,
                                                                                        width: Configuration.instance.forceSquaredTrackThumbnail ? MediaQuery.of(context).size.width : null,
                                                                                        height: Configuration.instance.forceSquaredTrackThumbnail ? MediaQuery.of(context).size.width : null);
                                                                                  }
                                                                                  return state.completedWidget;
                                                                                }
                                                                              default:
                                                                                return state.completedWidget;
                                                                            }
                                                                          },
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
                                                  ),
                                                );
                                              }()
                                            : Playback.instance.index < 0 || Playback.instance.index >= Playback.instance.tracks.length || Playback.instance.tracks.isEmpty
                                                ? const SizedBox(
                                                    width: 62.0,
                                                  )
                                                : Consumer<Playback>(
                                                    builder: (context, playback, _) => SizedBox(
                                                      child: Center(
                                                        child: ClipRRect(
                                                          borderRadius: BorderRadius.circular((6 + 6 * percentage) * Configuration.instance.borderRadiusMultiplier),
                                                          child: Container(
                                                            alignment: Alignment.center,
                                                            padding: EdgeInsets.all(4.0 + 8.0 * percentage),
                                                            constraints: BoxConstraints(maxHeight: pageViewHeight, maxWidth: (percentage == 0 ? 84.0 : (84 * (1 - percentage))) + MediaQuery.of(context).size.width * percentage),
                                                            child: DropShadow(
                                                              borderRadius: (6 + 6 * percentage) * Configuration.instance.borderRadiusMultiplier,
                                                              blurRadius: 1 + percentage * 2,
                                                              spread: 1,
                                                              offset: Offset(0, 1),
                                                              child: ExtendedImage(
                                                                image: Image(image: getAlbumArt(playback.tracks.length < 1 ? playback.tracks[0] : playback.tracks[playback.index])).image,
                                                                fit: BoxFit.cover,
                                                                width: Configuration.instance.forceSquaredTrackThumbnail && percentage > 0.1 ? MediaQuery.of(context).size.width * percentage : null,
                                                                height: Configuration.instance.forceSquaredTrackThumbnail && percentage > 0.1 ? MediaQuery.of(context).size.width * percentage : null,
                                                                enableLoadState: true,
                                                                handleLoadingProgress: true,
                                                                loadStateChanged: (state) {
                                                                  switch (state.extendedImageLoadState) {
                                                                    case LoadState.failed:
                                                                      {
                                                                        if (LibmpvPluginUtils.isSupported(Playback.instance.tracks[playback.index].uri)) {
                                                                          // Show [getAlbumArt] with smaller size in-case of a load failure.
                                                                          return ExtendedImage(
                                                                              image: Image(image: getAlbumArt(Playback.instance.tracks[playback.index], small: true)).image,
                                                                              fit: BoxFit.cover,
                                                                              width: Configuration.instance.forceSquaredTrackThumbnail ? MediaQuery.of(context).size.width : null,
                                                                              height: Configuration.instance.forceSquaredTrackThumbnail ? MediaQuery.of(context).size.width : null);
                                                                        }
                                                                        return state.completedWidget;
                                                                      }
                                                                    default:
                                                                      return state.completedWidget;
                                                                  }
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                      ],
                                    ),
                                    if (percentage < 1.0)
                                      () {
                                        if (Playback.instance.index < 0 || Playback.instance.index >= Playback.instance.tracks.length || Playback.instance.tracks.isEmpty) {
                                          return const SizedBox.shrink();
                                        }
                                        return Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Opacity(
                                                opacity: (1 - percentage * 5).clamp(0.0, 1.0),
                                                child: Padding(
                                                  padding: EdgeInsets.only(left: 16.0),
                                                  child: Text(
                                                    Playback.instance.tracks[Playback.instance.index].trackName.overflow,
                                                    style: Theme.of(context).textTheme.displayMedium!.copyWith(fontSize: 15, fontWeight: FontWeight.w700),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ),
                                              if (!Playback.instance.tracks[Playback.instance.index].hasNoAvailableArtists)
                                                Opacity(
                                                  opacity: (1 - percentage * 5).clamp(0.0, 1.0),
                                                  child: Padding(
                                                    padding: EdgeInsets.only(left: 16.0),
                                                    child: Text(
                                                      Playback.instance.tracks[Playback.instance.index].trackArtistNames.take(2).join(', ').overflow,
                                                      style: Theme.of(context).textTheme.displaySmall,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        );
                                      }(),
                                    if (height < MediaQuery.of(context).size.width - 64.0)
                                      Align(
                                        alignment: Alignment.center,
                                        child: SizedBox(
                                          width: 120,
                                          child: FittedBox(
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                IconButton(
                                                  onPressed: Playback.instance.previous,
                                                  icon: Icon(
                                                    Broken.previous,
                                                  ),
                                                ),
                                                playOrPauseButtonModern,
                                                IconButton(
                                                  onPressed: Playback.instance.next,
                                                  icon: Icon(
                                                    Broken.next,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (height >= MediaQuery.of(context).size.width)
                        Container(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          child: ClipRect(
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                Positioned(
                                  top: kDetailsAreaHeight + 48.0,
                                  child: Stack(
                                    alignment: Alignment.bottomCenter,
                                    children: [
                                      ...fills,
                                    ],
                                  ),
                                ),
                                Consumer<Playback>(builder: (context, playback, _) {
                                  if (playback.index < 0 || playback.index >= playback.tracks.length || playback.tracks.isEmpty) {
                                    return const SizedBox.shrink();
                                  }
                                  return Container(
                                    width: MediaQuery.of(context).size.width,
                                    // color: Colors.black,
                                    height: MediaQuery.of(context).size.height - pageViewHeight - topAreaArrowAndNumber - Configuration.instance.queueSheetMinHeight,
                                    alignment: Alignment.center,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Spacer(),
                                        // main container holding track info and menu icon
                                        Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Container(
                                              width: MediaQuery.of(context).size.width,
                                              margin: EdgeInsets.symmetric(horizontal: 32.0),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    [
                                                      if (!playback.tracks[playback.index].hasNoAvailableArtists) playback.tracks[playback.index].trackArtistNames.take(2).join(', ').overflow,
                                                    ].join(' • '),
                                                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                                          color: Theme.of(context).colorScheme.onBackground.withAlpha(233),
                                                          fontSize: 21.0,
                                                        ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 4.0),
                                                  Text(
                                                    playback.tracks[playback.index.clamp(0, playback.tracks.length - 1)].trackName.overflow,
                                                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                                          color: Color.alphaBlend(
                                                            Theme.of(context).colorScheme.onBackground.withAlpha(100),
                                                            NowPlayingColorPalette.instance.modernColor,
                                                          ),
                                                        ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 4.0),
                                                  Text(
                                                    [
                                                      if (!playback.tracks[playback.index].hasNoAvailableAlbum) playback.tracks[playback.index].albumName,
                                                    ].join(' • '),
                                                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                                          color: Theme.of(context).colorScheme.onBackground.withAlpha(180),
                                                        ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Positioned(
                                              right: 0,
                                              child: IconButton(
                                                iconSize: 22.0,
                                                onPressed: !isDesktop
                                                    ? () => showTrackDialog(context, Playback.instance.tracks[Playback.instance.index])
                                                    : () async {
                                                        final track = Playback.instance.tracks[Playback.instance.index];
                                                        int? result;
                                                        await showModalBottomSheet(
                                                          isScrollControlled: true,
                                                          backgroundColor: Colors.transparent,
                                                          context: context,
                                                          builder: (context) => Card(
                                                            margin: EdgeInsets.only(
                                                              left: 8.0,
                                                              right: 8.0,
                                                              bottom: 8.0,
                                                            ),
                                                            clipBehavior: Clip.antiAlias,
                                                            elevation: kDefaultHeavyElevation,
                                                            child: Container(
                                                              child: Column(
                                                                mainAxisSize: MainAxisSize.min,
                                                                children: [
                                                                  // PopupMenuItem(
                                                                  //   onTap: () => result = 0,
                                                                  //   value: 0,
                                                                  //   child: ListTile(
                                                                  //     leading: Icon(Icons.equalizer),
                                                                  //     title: Text(Language.instance.CONTROL_PANEL),
                                                                  //   ),
                                                                  // ),
                                                                  if (LibmpvPluginUtils.isSupported(track.uri))
                                                                    PopupMenuItem(
                                                                      onTap: () => result = 1,
                                                                      value: 1,
                                                                      child: ListTile(
                                                                        leading: Icon(Icons.link),
                                                                        title: Text(Language.instance.COPY_LINK),
                                                                      ),
                                                                    ),
                                                                  if (LibmpvPluginUtils.isSupported(track.uri))
                                                                    PopupMenuItem(
                                                                      onTap: () => result = 2,
                                                                      value: 2,
                                                                      child: ListTile(
                                                                        leading: Icon(Icons.open_in_new),
                                                                        title: Text(Language.instance.OPEN_IN_BROWSER),
                                                                      ),
                                                                    ),
                                                                  PopupMenuItem(
                                                                    onTap: () => result = 3,
                                                                    value: 3,
                                                                    child: ListTile(
                                                                      leading: Icon(Icons.playlist_add),
                                                                      title: Text(Language.instance.ADD_TO_PLAYLIST),
                                                                    ),
                                                                  ),
                                                                  PopupMenuItem(
                                                                    onTap: () => result = 5,
                                                                    value: 5,
                                                                    child: ListTile(
                                                                      leading: Icon(Icons.share),
                                                                      title: Text(Language.instance.SHARE),
                                                                    ),
                                                                  ),
                                                                  // if (Lyrics.instance.current.length > 1)
                                                                  //   PopupMenuItem(
                                                                  //     onTap: () => result = 4,
                                                                  //     value: 4,
                                                                  //     child: ListTile(
                                                                  //       leading: Icon(Icons.text_format),
                                                                  //       title: Text(Language.instance.SHOW_LYRICS),
                                                                  //     ),
                                                                  //   ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                        switch (result) {
                                                          // case 0:
                                                          //   {
                                                          //     await Future.delayed(const Duration(milliseconds: 200));
                                                          //     await showDialog(
                                                          //       context: context,
                                                          //       builder: (context) => AlertDialog(
                                                          //         contentPadding: EdgeInsets.zero,
                                                          //         content: ControlPanel(
                                                          //           onPop: () {},
                                                          //         ),
                                                          //       ),
                                                          //     );
                                                          //     break;
                                                          //   }
                                                          case 1:
                                                            {
                                                              Clipboard.setData(ClipboardData(text: track.uri.toString()));
                                                              break;
                                                            }
                                                          case 2:
                                                            {
                                                              launchUrl(
                                                                track.uri,
                                                                mode: LaunchMode.externalApplication,
                                                              );
                                                              break;
                                                            }
                                                          case 3:
                                                            {
                                                              await showAddToPlaylistDialog(
                                                                context,
                                                                track,
                                                                elevated: false,
                                                              );
                                                              break;
                                                            }
                                                          // case 4:
                                                          //   {
                                                          //     await showGeneralDialog(
                                                          //       useRootNavigator: false,
                                                          //       context: context,
                                                          //       pageBuilder: (context, animation, secondaryAnimation) {
                                                          //         return LyricsScreen();
                                                          //       },
                                                          //     );
                                                          //     break;
                                                          //   }
                                                          case 5:
                                                            {
                                                              if (track.uri.isScheme('FILE')) {
                                                                Share.shareFiles(
                                                                  [track.uri.toFilePath()],
                                                                  subject: '${track.trackName} • ${[
                                                                    '',
                                                                    kUnknownArtist,
                                                                  ].contains(track.albumArtistName) ? track.trackArtistNames.take(2).join(', ') : track.albumArtistName}',
                                                                );
                                                              } else {
                                                                Share.share(
                                                                  '${track.trackName} • ${[
                                                                    '',
                                                                    kUnknownArtist,
                                                                  ].contains(track.albumArtistName) ? track.trackArtistNames.take(2).join(', ') : track.albumArtistName} • ${track.uri.toString()}',
                                                                );
                                                              }
                                                              break;
                                                            }
                                                          default:
                                                            break;
                                                        }
                                                      },
                                                color: Theme.of(context).extension<IconColors>()?.appBarDarkIconColor,
                                                icon: RotatedBox(
                                                  quarterTurns: 1,
                                                  child: Icon(Broken.more),
                                                ),
                                                splashRadius: 24.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Spacer(),
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 32.0),
                                          child: Stack(
                                            alignment: Alignment.centerRight,
                                            children: [
                                              Consumer<Playback>(
                                                builder: (context, playback, _) {
                                                  return WaveformComponent(
                                                    duration: 2000,
                                                    color: Theme.of(context).colorScheme.onBackground.withAlpha(150),
                                                    curve: Curves.easeInOutQuart,
                                                    boxMaxWidth: MediaQuery.of(context).size.width,
                                                    boxMaxHeight: 55,
                                                  );
                                                },
                                              ),
                                              Consumer<Playback>(
                                                builder: (context, playback, _) => Container(
                                                  height: 55,
                                                  decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor.withAlpha(100), boxShadow: [
                                                    BoxShadow(
                                                      color: Theme.of(context).scaffoldBackgroundColor.withAlpha(100),
                                                      blurRadius: 8.0,
                                                      spreadRadius: 3.0,
                                                    ),
                                                  ]),
                                                  width: playback.duration == Duration.zero
                                                      ? MediaQuery.of(context).size.width
                                                      : (MediaQuery.of(context).size.width - 64) - (playback.position.inMilliseconds / playback.duration.inMilliseconds * (MediaQuery.of(context).size.width - 64)),
                                                ),
                                              ),
                                              Opacity(
                                                opacity: 0.0,
                                                child: ScrollableSlider(
                                                  min: 0.0,
                                                  max: playback.duration.inMilliseconds.toDouble(),
                                                  value: playback.position.inMilliseconds.clamp(0, playback.duration.inMilliseconds.toDouble()).toDouble(),
                                                  color: Color.alphaBlend(NowPlayingColorPalette.instance.modernColor.withAlpha(120), Theme.of(context).colorScheme.onBackground),
                                                  secondaryColor: Theme.of(context).colorScheme.surface,
                                                  onChanged: (value) {
                                                    playback.seek(
                                                      seekAndPlay: playback.isPlaying,
                                                      Duration(
                                                        milliseconds: value.toInt(),
                                                      ),
                                                    );
                                                  },
                                                  onScrolledUp: () {
                                                    if (playback.position >= playback.duration) return;
                                                    playback.seek(
                                                      seekAndPlay: playback.isPlaying,
                                                      playback.position + Duration(seconds: 10),
                                                    );
                                                  },
                                                  onScrolledDown: () {
                                                    if (playback.position <= Duration.zero) return;
                                                    playback.seek(
                                                      seekAndPlay: playback.isPlaying,
                                                      playback.position - Duration(seconds: 10),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        Spacer(),
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 32.0),
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  SizedBox(
                                                    child: IconButton(
                                                      onPressed: Playback.instance.previous,
                                                      icon: Icon(
                                                        Broken.previous,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 18.0),
                                                  playOrPauseButtonModern,
                                                  const SizedBox(width: 18.0),
                                                  IconButton(
                                                    onPressed: Playback.instance.next,
                                                    icon: Icon(
                                                      Broken.next,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Positioned(
                                                left: 0,
                                                child: Text(
                                                  playback.position.label,
                                                  style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 12),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Positioned(
                                                right: 0,
                                                child: Text(
                                                  playback.duration.label,
                                                  style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 12),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Spacer(),
                                        if (isVolumeSliderVisible)
                                          Container(
                                            alignment: Alignment.topCenter,
                                            width: MediaQuery.of(context).size.width,
                                            padding: EdgeInsets.symmetric(horizontal: 38.0),
                                            child: Row(
                                              children: [
                                                IconButton(
                                                  icon: Icon(
                                                    Broken.volume_low_1,
                                                  ),
                                                  onPressed: () {
                                                    playback.setVolume(
                                                      (playback.volume - 5.0).clamp(
                                                        0.0,
                                                        100.0,
                                                      ),
                                                    );
                                                  },
                                                  color: Theme.of(context).colorScheme.onBackground.withAlpha(200),
                                                ),
                                                const SizedBox(
                                                  width: 16.0,
                                                ),
                                                Consumer<Playback>(
                                                  builder: (context, playback, _) => Expanded(
                                                    child: ScrollableSlider(
                                                      min: 0.0,
                                                      max: 100.0,
                                                      value: playback.volume.clamp(0.0, 100.0),
                                                      color: NowPlayingColorPalette.instance.modernColor,
                                                      secondaryColor: Theme.of(context).colorScheme.surface,
                                                      onChanged: (value) {
                                                        playback.setVolume(
                                                          value,
                                                        );
                                                        playback.updateFadeVolume();
                                                      },
                                                      onScrolledUp: () {
                                                        playback.setVolume(
                                                          (playback.volume + 5.0).clamp(
                                                            0.0,
                                                            100.0,
                                                          ),
                                                        );
                                                      },
                                                      onScrolledDown: () {
                                                        playback.setVolume(
                                                          (playback.volume - 5.0).clamp(
                                                            0.0,
                                                            100.0,
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 16.0,
                                                ),
                                                IconButton(
                                                  icon: Icon(
                                                    Broken.volume_high,
                                                  ),
                                                  onPressed: () {
                                                    playback.setVolume(
                                                      (playback.volume + 5.0).clamp(
                                                        0.0,
                                                        200.0,
                                                      ),
                                                    );
                                                  },
                                                  color: Theme.of(context).colorScheme.onBackground.withAlpha(200),
                                                ),
                                              ],
                                            ),
                                          ),
                                        Spacer(),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            IconButton(
                                              iconSize: 20.0,
                                              highlightColor: Colors.transparent,
                                              onPressed: () {
                                                if (playback.playlistLoopMode == PlaylistLoopMode.loop) {
                                                  playback.setPlaylistLoopMode(
                                                    PlaylistLoopMode.none,
                                                  );
                                                  return;
                                                }
                                                playback.setPlaylistLoopMode(
                                                  PlaylistLoopMode.values[playback.playlistLoopMode.index + 1],
                                                );
                                              },
                                              // iconSize: playback.playlistLoopMode == PlaylistLoopMode.none || playback.playlistLoopMode == PlaylistLoopMode.loop ? 18.0 : 20.0,
                                              color: (playback.playlistLoopMode != PlaylistLoopMode.none)
                                                  ? Color.alphaBlend(NowPlayingColorPalette.instance.modernColor.withAlpha(180), Theme.of(context).colorScheme.onBackground)
                                                  : Theme.of(context).colorScheme.onBackground.withAlpha(180),
                                              icon: Icon(
                                                playback.playlistLoopMode == PlaylistLoopMode.single ? Broken.repeate_one : Broken.repeat,
                                              ),
                                            ),
                                            Consumer<Collection>(
                                              builder: (context, collection, _) => (Playback.instance.index < 0 || Playback.instance.index >= Playback.instance.tracks.length || Playback.instance.tracks.isEmpty)
                                                  ? const SizedBox.shrink()
                                                  : IconButton(
                                                      iconSize: 20.0,
                                                      highlightColor: Colors.transparent,
                                                      onPressed: () {
                                                        if (collection.likedSongsPlaylist.tracks.contains(Playback.instance.tracks[Playback.instance.index])) {
                                                          collection.playlistRemoveTrack(
                                                            collection.likedSongsPlaylist,
                                                            Playback.instance.tracks[Playback.instance.index],
                                                          );
                                                        } else {
                                                          collection.playlistAddTrack(
                                                            collection.likedSongsPlaylist,
                                                            Playback.instance.tracks[Playback.instance.index],
                                                          );
                                                        }
                                                      },
                                                      icon: collection.likedSongsPlaylist.tracks.contains(Playback.instance.tracks[Playback.instance.index])
                                                          ? Icon(Broken.heart_tick, color: Color.alphaBlend(NowPlayingColorPalette.instance.modernColor.withAlpha(180), Theme.of(context).colorScheme.onBackground))
                                                          : Icon(Broken.heart, color: Theme.of(context).colorScheme.onBackground.withAlpha(180)),
                                                      splashRadius: 24.0,
                                                    ),
                                            ),
                                            IconButton(
                                              iconSize: 20.0,
                                              highlightColor: Colors.transparent,
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) => AlertDialog(
                                                    contentPadding: EdgeInsets.zero,
                                                    content: ControlPanel(
                                                      onPop: () {},
                                                    ),
                                                  ),
                                                );
                                              },
                                              icon: Icon(
                                                Broken.sound,
                                                color: Theme.of(context).colorScheme.onBackground.withAlpha(180),
                                              ),
                                              tooltip: Language.instance.CONTROL_PANEL,
                                              color: Theme.of(context).extension<IconColors>()?.appBarDarkIconColor,
                                              splashRadius: 24.0,
                                            ),
                                            IconButton(
                                              iconSize: 19.0,
                                              highlightColor: Colors.transparent,
                                              onPressed: () async {
                                                await showGeneralDialog(
                                                  useRootNavigator: false,
                                                  context: context,
                                                  pageBuilder: (context, animation, secondaryAnimation) {
                                                    return LyricsScreen();
                                                  },
                                                );
                                              },
                                              icon: Icon(
                                                Broken.message_text,
                                                color: Theme.of(context).colorScheme.onBackground.withAlpha(180),
                                              ),
                                              tooltip: Language.instance.SHOW_LYRICS,
                                              color: Theme.of(context).extension<IconColors>()?.appBarDarkIconColor,
                                            ),
                                            IconButton(
                                              highlightColor: Colors.transparent,
                                              onPressed: playback.toggleShuffle,
                                              iconSize: 20.0,
                                              color: playback.isShuffling ? Color.alphaBlend(NowPlayingColorPalette.instance.modernColor.withAlpha(180), Theme.of(context).colorScheme.onBackground) : Theme.of(context).colorScheme.onBackground.withAlpha(180),
                                              icon: Icon(
                                                Broken.shuffle,
                                              ),
                                            ),
                                          ],
                                        ),
                                        // const SizedBox(height: 2.0),
                                        if (Configuration.instance.displayAudioFormat && playback.tracks[playback.index].uri.isScheme('FILE'))
                                          AnimatedSwitcher(
                                            duration: Duration(milliseconds: 400),
                                            child: playback.androidAudioFormat.label.isNotEmpty
                                                ? Text(
                                                    playback.androidAudioFormat.label,
                                                    maxLines: 1,
                                                    key: Key("audioformat"),
                                                    overflow: TextOverflow.ellipsis,
                                                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                                          color: Theme.of(context).colorScheme.onBackground.withAlpha(180),
                                                        ),
                                                  )
                                                : Text(
                                                    '',
                                                    maxLines: 1,
                                                    key: Key("noaudioformat"),
                                                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                                          color: Theme.of(context).colorScheme.onBackground.withAlpha(180),
                                                        ),
                                                  ),
                                          ),
                                        const SizedBox(height: 4.0),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).viewPadding.top * percentage,
                  left: 10,
                  height: 20 * percentage,
                  child: Opacity(
                    opacity: percentage / 3,
                    child: IconButton(
                      iconSize: 20.0,
                      padding: EdgeInsets.all(0),
                      highlightColor: Colors.transparent,
                      onPressed: () {
                        controller.animateToHeight(
                          state: MiniPlayerPanelState.MIN,
                        );
                      },
                      color: Theme.of(context).colorScheme.onBackground,
                      icon: Icon(Broken.arrow_down_2),
                    ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).viewPadding.top * percentage,
                  height: 20 * percentage,
                  child: Opacity(
                    opacity: percentage / 3,
                    child: Text(
                      "${Playback.instance.index + 1}/${Playback.instance.tracks.length}",
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 12 * percentage, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                if ((MediaQuery.of(context).size.width + kDetailsAreaHeight + bottomSheetMinHeight) < MediaQuery.of(context).size.height)
                  () {
                    // Only cause re-draw or updates to [SlidingUpPanel], when it is maximized.
                    // It is quite expensive process & lag is very apparent.
                    if (playlistPanel == null || percentage == 1.0) {
                      playlistPanel = SizedBox(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (percentage < 1.0)
                              Expanded(
                                child: SizedBox(
                                  height: MediaQuery.of(context).size.width + kDetailsAreaHeight + bottomSheetMinHeight,
                                ),
                              ),

                            // if (false)
                            //   Flexible(
                            //     child: Stack(
                            //       children: [
                            //         Sheet(
                            //           controller: sheetController,
                            //           initialExtent: 200,
                            //           minExtent: 100,
                            //           maxExtent: 400, fit: SheetFit.expand,
                            //           // resizable: true,
                            //           child: AnimatedList(
                            //             shrinkWrap: true,
                            //             // physics: ClampingScrollPhysics(),
                            //             // controller: ScrollController(),
                            //             initialItemCount: tracks.length,
                            //             itemBuilder: (context, index, animation) {
                            //               return tracks[index];
                            //             },
                            //           ),
                            //         ),
                            //       ],
                            //     ),
                            //   ),
                            // if (false)
                            //   Flexible(
                            //     child: DraggableScrollableSheet(
                            //       minChildSize: 0.1,
                            //       initialChildSize: 0.2,
                            //       maxChildSize: 0.5,
                            //       snap: true,
                            //       builder: (context, scrollController) {
                            //         return ListView(
                            //           controller: scrollController,
                            //           children: [
                            //             Container(
                            //               width: 60,
                            //               height: 5,
                            //               margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 2.3, vertical: 8.0),
                            //               decoration: BoxDecoration(color: Theme.of(context).colorScheme.onBackground, borderRadius: BorderRadius.circular(20 * Configuration.instance.borderRadiusMultiplier)),
                            //             ),
                            //             Container(
                            //               clipBehavior: Clip.antiAlias,
                            //               decoration: BoxDecoration(color: Theme.of(context).colorScheme.background, borderRadius: BorderRadius.circular(20 * Configuration.instance.borderRadiusMultiplier)),
                            //               child: AnimatedList(
                            //                 shrinkWrap: true,
                            //                 physics: ClampingScrollPhysics(),
                            //                 controller: ScrollController(),
                            //                 initialItemCount: tracks.length,
                            //                 itemBuilder: (context, index, animation) {
                            //                   return tracks[index];
                            //                 },
                            //               ),
                            //             )
                            //           ],
                            //         );
                            //       },
                            //     ),
                            //   ),

                            // Flexible(
                            //   child: DraggableScrollableSheet(
                            //     initialChildSize: 0.30,
                            //     minChildSize: 0.15,
                            //     snap: true,
                            //     maxChildSize: 0.7,
                            //     builder: (BuildContext context, ScrollController scrollController) {
                            //       return AnimatedList(
                            //         controller: scrollController,
                            //         initialItemCount: tracks.length,
                            //         itemBuilder: (context, index, animation) {
                            //           return tracks[index];
                            //         },
                            //       );
                            //     },
                            //   ),
                            // ),

                            // Container(
                            //   color: Colors.red,
                            //   width: 300,
                            //   height: 100,
                            //   child: GestureDetector(
                            //     onPanEnd: (details) {
                            //       if (details.velocity.pixelsPerSecond.dy < 0) {
                            //         setState(() {
                            //           showBarModalBottomSheet(
                            //             bounce: true,
                            //             expand: false,
                            //             enableDrag: true,
                            //             isDismissible: true,
                            //             duration: Duration(seconds: 3),
                            //             context: context,
                            //             backgroundColor: Theme.of(context)
                            //                 .colorScheme
                            //                 .background,
                            //             builder: (context) =>
                            //                 SingleChildScrollView(
                            //                     controller:
                            //                         ModalScrollController.of(
                            //                             context),
                            //                     child: Column(
                            //                       children: tracks,
                            //                     )),
                            //           );
                            //         });
                            //       } else if (details
                            //               .velocity.pixelsPerSecond.dy >
                            //           0) {
                            //         setState(() {});
                            //       }
                            //     },
                            //   ),
                            // ),
                            // if (false)

                            () {
                              final vh = MediaQuery.of(context).size.height;
                              final vw = MediaQuery.of(context).size.width;
                              final pt = window.padding.top / window.devicePixelRatio + 16.0;
                              final min = vh - (vw + kDetailsAreaHeight + bottomSheetMinHeight);
                              final max = vh - (kToolbarHeight + pt);

                              return SlidingUpPanel(
                                controller: slidingUpPanelController,
                                minHeight: Configuration.instance.queueSheetMinHeight,
                                maxHeight: queueSheetMaxHeight,
                                renderPanelSheet: true,
                                backdropEnabled: true,
                                backdropTapClosesPanel: true,
                                panelSnapping: true,
                                backdropOpacity: 0.0,
                                color: Theme.of(context).scaffoldBackgroundColor,
                                margin: EdgeInsets.only(
                                  left: 0.0,
                                  right: 0.0,
                                ),
                                onPanelOpened: () => minimizedPlaylist.value = false,
                                onPanelClosed: () => minimizedPlaylist.value = true,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(24.0 * Configuration.instance.borderRadiusMultiplier),
                                  topRight: Radius.circular(24.0 * Configuration.instance.borderRadiusMultiplier),
                                ),
                                collapsed: () {
                                  return Container(
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).brightness == Brightness.light ? Color.fromARGB(255, 248, 248, 248) : Color.fromARGB(255, 19, 19, 19),
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(24.0 * Configuration.instance.borderRadiusMultiplier),
                                        topRight: Radius.circular(24.0 * Configuration.instance.borderRadiusMultiplier),
                                      ),
                                    ),
                                    child: Container(
                                      margin: EdgeInsets.only(
                                        top: 1.0,
                                        left: 1.0,
                                        right: 1.0,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).brightness == Brightness.light ? Color.fromARGB(255, 248, 248, 248) : Color.fromARGB(255, 19, 19, 19),
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(24.0 * Configuration.instance.borderRadiusMultiplier),
                                          topRight: Radius.circular(24.0 * Configuration.instance.borderRadiusMultiplier),
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Material(
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(14.0),
                                              topRight: Radius.circular(14.0),
                                            ),
                                            child: Container(
                                              height: 32.0,
                                              alignment: Alignment.center,
                                              child: Container(
                                                width: 48.0,
                                                height: 4.0,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(
                                                    2.0,
                                                  ),
                                                  color: Theme.of(context).dividerTheme.color?.withOpacity(0.54),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Divider(
                                            height: 1.0,
                                            thickness: 1.0,
                                          ),
                                          Expanded(
                                            child: ReorderableListView.builder(
                                              physics: NeverScrollableScrollPhysics(),
                                              onReorder: (int oldIndex, int newIndex) {
                                                // if the reorder done within tracks list
                                                if (oldIndex < tracks.length) {
                                                  setState(() {
                                                    if (newIndex > oldIndex) {
                                                      newIndex -= 1;
                                                    }
                                                    final item = Playback.instance.tracks[oldIndex];
                                                    Playback.instance.removeAt(oldIndex);

                                                    Playback.instance.insertAt([item], newIndex);
                                                  });
                                                } else {
                                                  setState(() {
                                                    if (newIndex > oldIndex) {
                                                      newIndex -= 1;
                                                    }

                                                    if (newIndex > tracks.length) {
                                                      final item = moreMain.removeAt(oldIndex - tracks.length - 1);
                                                      moreMain.insert(newIndex - tracks.length - 1, item);
                                                    } else {
                                                      // final item2 = moreMain
                                                      //     .removeAt(oldIndex -
                                                      //         tracks.length);
                                                      Playback.instance.tracks.insert(newIndex, moreMain.elementAt(oldIndex - tracks.length - 1));
                                                    }
                                                    Playback.instance.notify();

                                                    // adds the currently playing track to the end of list then removes it
                                                    // to force update the queue

                                                    Playback.instance.add([track as Track]);
                                                    Playback.instance.tracks.removeAt(tracks.length - 1);
                                                    Playback.instance.notify();
                                                  });
                                                }
                                              },
                                              padding: EdgeInsets.zero,
                                              itemCount: tracksSkipped.length + 1 + more.length,
                                              itemBuilder: (context, i) {
                                                i++;
                                                if (i == tracksSkipped.length + 1) {
                                                  return Padding(
                                                    key: ValueKey("more2"),
                                                    padding: EdgeInsets.only(
                                                      left: 62.0,
                                                    ),
                                                    child: SubHeader(
                                                      Language.instance.MORE,
                                                    ),
                                                  );
                                                } else if (i <= tracksSkipped.length) {
                                                  return tracksSkipped[i - 1];
                                                } else if (i > tracksSkipped.length + 1) {
                                                  return more[i - tracksSkipped.length - 2];
                                                }
                                                return const SizedBox.shrink();
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }(),
                                panelBuilder: (controller) {
                                  return Container(
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).brightness == Brightness.light ? Color.fromARGB(255, 248, 248, 248) : Color.fromARGB(255, 19, 19, 19),
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(24.0 * Configuration.instance.borderRadiusMultiplier),
                                        topRight: Radius.circular(24.0 * Configuration.instance.borderRadiusMultiplier),
                                      ),
                                    ),
                                    child: Container(
                                      margin: EdgeInsets.only(
                                        top: 1.0,
                                        left: 1.0,
                                        right: 1.0,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).brightness == Brightness.light ? Color.fromARGB(255, 248, 248, 248) : Color.fromARGB(255, 19, 19, 19),
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(24.0 * Configuration.instance.borderRadiusMultiplier),
                                          topRight: Radius.circular(24.0 * Configuration.instance.borderRadiusMultiplier),
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Material(
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(24.0 * Configuration.instance.borderRadiusMultiplier),
                                              topRight: Radius.circular(24.0 * Configuration.instance.borderRadiusMultiplier),
                                            ),
                                            child: Stack(
                                              children: [
                                                Container(
                                                  height: 36.0,
                                                  alignment: Alignment.center,
                                                  child: Container(
                                                    width: 36.0,
                                                    height: 4.0,
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(
                                                        2.0,
                                                      ),
                                                      color: Theme.of(context).colorScheme.onBackground,
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  right: 8.0,
                                                  child: Container(
                                                    height: 36.0,
                                                    child: TextButton(
                                                      onPressed: () {
                                                        showAddToPlaylistDialogModern(context, Playback.instance.tracks);
                                                      },
                                                      child: Text(Language.instance.ADD_TO_PLAYLIST),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          Divider(
                                            height: 1.0,
                                            thickness: 1.0,
                                          ),
                                          Expanded(
                                            child: ReorderableListView.builder(
                                              scrollController: controller,
                                              onReorder: (int oldIndex, int newIndex) {
                                                if (oldIndex == Playback.instance.index) {
                                                  setState(() {
                                                    if (newIndex > oldIndex) {
                                                      newIndex -= 1;
                                                    }
                                                    final item = Playback.instance.tracks[oldIndex];
                                                    final currentPosition = Playback.instance.position;
                                                    final isPlaying = Playback.instance.isPlaying;
                                                    // Playback.instance
                                                    //     .removeAndInsertAt([item],
                                                    //         oldIndex, newIndex);
                                                    // Playback.instance.index =
                                                    //     newIndex;
                                                    // Playback.instance
                                                    //     .seek(currentPosition);

                                                    // List<Track>
                                                    //     allTracksExceptCurrent =
                                                    //     [];

                                                    // allTracksExceptCurrent =
                                                    //     Playback.instance.tracks
                                                    //             .sublist(
                                                    //                 0, oldIndex)
                                                    //             .toList() +
                                                    //         Playback
                                                    //             .instance.tracks
                                                    //             .sublist(
                                                    //                 oldIndex + 1,
                                                    //                 Playback
                                                    //                     .instance
                                                    //                     .tracks
                                                    //                     .length)
                                                    //             .toList();

                                                    // Playback.instance
                                                    //     .removeRange(0, oldIndex)
                                                    //     .then((value) => Playback
                                                    //         .instance
                                                    //         .removeRange(
                                                    //             oldIndex,
                                                    //             Playback
                                                    //                 .instance
                                                    //                 .tracks
                                                    //                 .length))
                                                    //     .then((value) => Playback
                                                    //         .instance
                                                    //         .insertAt(
                                                    //             allTracksExceptCurrent
                                                    //                 .getRange(
                                                    //                     0, newIndex)
                                                    //                 .toList(),
                                                    //             0))
                                                    //     .then((value) =>
                                                    //         Playback.instance.insertAt(
                                                    //             allTracksExceptCurrent
                                                    //                 .getRange(newIndex, allTracksExceptCurrent.length)
                                                    //                 .toList(),
                                                    //             Playback.instance.index + 1))
                                                    //     .then((value) => print(Playback.instance.tracks.length));

                                                    // Playback.instance.insertAt(
                                                    //     allTracksExceptCurrent
                                                    //         .getRange(0, newIndex)
                                                    //         .toList(),
                                                    //     -1);
                                                    // Playback.instance.insertAt(
                                                    //     allTracksExceptCurrent
                                                    //         .getRange(
                                                    //             newIndex,
                                                    //             allTracksExceptCurrent
                                                    //                     .length +
                                                    //                 1)
                                                    //         .toList(),
                                                    //     Playback.instance.index +
                                                    //         1);
                                                    Playback.instance
                                                        .removeAndInsertAt([item], oldIndex, newIndex)
                                                        .then((value) => Playback.instance.jump(newIndex))
                                                        .then((value) => Playback.instance.seek(currentPosition))
                                                        .then((value) => !isPlaying ? Playback.instance.pause() : null);

                                                    // adds the currently playing track to the end of list then removes it
                                                    // to force update the queue

                                                    Playback.instance.add([track as Track]);
                                                    Playback.instance.tracks.removeAt(tracks.length - 1);
                                                    Playback.instance.notify();
                                                  });
                                                } else if (oldIndex < tracks.length) {
                                                  setState(() {
                                                    if (newIndex > oldIndex) {
                                                      newIndex -= 1;
                                                    }
                                                    final item = Playback.instance.tracks[oldIndex];
                                                    Playback.instance.removeAndInsertAt([item], oldIndex, newIndex);
                                                  });
                                                } else {
                                                  setState(() {
                                                    if (newIndex > oldIndex) {
                                                      newIndex -= 1;
                                                    }

                                                    if (newIndex > tracks.length) {
                                                      final item = moreMain.removeAt(oldIndex - tracks.length - 1);
                                                      moreMain.insert(newIndex - tracks.length - 1, item);
                                                    } else {
                                                      // final item2 = moreMain
                                                      //     .removeAt(oldIndex -
                                                      //         tracks.length);
                                                      Playback.instance.tracks.insert(newIndex, moreMain.elementAt(oldIndex - tracks.length - 1));
                                                    }
                                                    Playback.instance.notify();
                                                  });
                                                }
                                                // adds the currently playing track to the end of list then removes it
                                                // to force update the queue

                                                Playback.instance.add([track as Track]);
                                                Playback.instance.tracks.removeAt(tracks.length - 1);
                                                Playback.instance.notify();
                                              },
                                              physics: null,
                                              padding: EdgeInsets.zero,
                                              // scrollController: controller,
                                              itemCount: tracks.length + 1 + more.length,
                                              itemBuilder: (context, i) {
                                                i++;
                                                if (i == tracks.length + 1) {
                                                  return Padding(
                                                    key: ValueKey("more"),
                                                    padding: EdgeInsets.only(
                                                      left: 62.0,
                                                    ),
                                                    child: SubHeader(
                                                      Language.instance.MORE,
                                                    ),
                                                  );
                                                } else if (i <= tracks.length) {
                                                  return tracks[i - 1];
                                                } else if (i > tracks.length + 1) {
                                                  return more[i - tracks.length - 2];
                                                }
                                                return const SizedBox.shrink();
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            }(),
                          ],
                        ),
                      );
                    }
                    return playlistPanel!;
                  }()
              ],
            );
          }();
        },
      ),
    );
  }
}

class MiniNowPlayingBarRefreshCollectionButton extends StatefulWidget {
  final ValueNotifier<int> index;
  MiniNowPlayingBarRefreshCollectionButton({
    Key? key,
    required this.index,
  }) : super(key: key);

  @override
  State<MiniNowPlayingBarRefreshCollectionButton> createState() => MiniNowPlayingBarRefreshCollectionButtonState();
}

class MiniNowPlayingBarRefreshCollectionButtonState extends State<MiniNowPlayingBarRefreshCollectionButton> {
  bool refreshFAB = true;

  @override
  void initState() {
    super.initState();
    widget.index.addListener(listener);
  }

  @override
  void dispose() {
    widget.index.removeListener(listener);
    super.dispose();
  }

  void listener() {
    if (refreshFAB && widget.index.value == 0) {
      refreshFAB = false;
      setState((() {}));
    } else if (!refreshFAB && widget.index.value != 0) {
      refreshFAB = true;
      setState((() {}));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ValueListenableBuilder<Iterable<Color>?>(
            valueListenable: MobileNowPlayingController.instance.palette,
            builder: (context, value, _) => TweenAnimationBuilder(
              duration: Duration(milliseconds: 400),
              tween: ColorTween(
                begin: Theme.of(context).primaryColor,
                end: value?.first ?? Theme.of(context).primaryColor,
              ),
              builder: (context, color, _) => Container(
                child: widget.index.value == 3
                    ? SpeedDial(
                        icon: Broken.add,
                        activeIcon: Broken.close_circle,
                        spacing: 8.0,
                        heroTag: 'create-playlist-fab',
                        animationCurve: Curves.easeInOut,
                        animationDuration: const Duration(milliseconds: 200),
                        children: [
                          SpeedDialChild(
                            child: const Icon(Broken.document_download),
                            label: Language.instance.IMPORT,
                            visible: true,
                            onTap: () {
                              showModalBottomSheet(
                                isScrollControlled: true,
                                constraints: BoxConstraints(
                                  maxHeight: double.infinity,
                                ),
                                context: context,
                                elevation: kDefaultHeavyElevation,
                                useRootNavigator: true,
                                builder: (context) => StatefulBuilder(
                                  builder: (context, setState) {
                                    return PlaylistImportBottomSheet();
                                  },
                                ),
                              );
                            },
                          ),
                          SpeedDialChild(
                            child: const Icon(Broken.edit),
                            label: Language.instance.CREATE,
                            visible: true,
                            onTap: () async {
                              String text = '';
                              await showModalBottomSheet(
                                isScrollControlled: true,
                                context: context,
                                elevation: kDefaultHeavyElevation,
                                useRootNavigator: true,
                                builder: (context) => StatefulBuilder(
                                  builder: (context, setState) {
                                    return Container(
                                      margin: EdgeInsets.only(
                                        bottom: MediaQuery.of(context).viewInsets.bottom - MediaQuery.of(context).padding.bottom,
                                      ),
                                      padding: EdgeInsets.all(8.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          const SizedBox(height: 4.0),
                                          TextField(
                                            textCapitalization: TextCapitalization.words,
                                            textInputAction: TextInputAction.done,
                                            autofocus: true,
                                            onChanged: (value) => text = value,
                                            onSubmitted: (String value) async {
                                              if (value.isNotEmpty) {
                                                FocusScope.of(context).unfocus();
                                                await Collection.instance.playlistCreateFromName(value);
                                                Navigator.of(context).maybePop();
                                              }
                                            },
                                            decoration: InputDecoration(
                                              contentPadding: EdgeInsets.fromLTRB(
                                                12,
                                                30,
                                                12,
                                                6,
                                              ),
                                              hintText: Language.instance.PLAYLISTS_TEXT_FIELD_LABEL,
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Theme.of(context).iconTheme.color!.withOpacity(0.4),
                                                  width: 1.8,
                                                ),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Theme.of(context).iconTheme.color!.withOpacity(0.4),
                                                  width: 1.8,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Theme.of(context).primaryColor,
                                                  width: 1.8,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 4.0),
                                          ElevatedButton(
                                            onPressed: () async {
                                              if (text.isNotEmpty) {
                                                FocusScope.of(context).unfocus();
                                                await Collection.instance.playlistCreateFromName(
                                                  text,
                                                );
                                                Navigator.of(context).maybePop();
                                              }
                                            },
                                            style: ButtonStyle(
                                              backgroundColor: MaterialStateProperty.all(
                                                Theme.of(context).primaryColor,
                                              ),
                                            ),
                                            child: Text(
                                              Language.instance.CREATE.toUpperCase(),
                                              style: const TextStyle(
                                                letterSpacing: 2.0,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                      )
                    : RefreshCollectionButton(
                        color: color as Color?,
                      ),
              ),
            ),
          ),
          // Position FABs above [MiniNowPlayingBar].
          ValueListenableBuilder<double>(
            valueListenable: MobileNowPlayingController.instance.fabOffset,
            builder: (context, value, child) => AnimatedContainer(
              height: value,
              duration: Duration(milliseconds: 200),
              curve: Curves.easeInOut,
            ),
          ),
        ],
      ),
    );
  }
}

class MiniMusicVisualizer extends StatelessWidget {
  const MiniMusicVisualizer({
    Key? key,
    this.color,
    this.width,
    this.height,
  }) : super(key: key);
  final Color? color;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final List<int> duration = [900, 800, 700, 600, 500, 400];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List<Widget>.generate(
        3,
        (index) => VisualComponent(
          curve: Curves.bounceIn,
          duration: duration[index % 5],
          color: color ?? Theme.of(context).colorScheme.secondary,
          width: width,
          height: height,
        ),
      ),
    );
  }
}

class VisualComponent extends StatefulWidget {
  const VisualComponent({
    Key? key,
    required this.duration,
    required this.color,
    required this.curve,
    this.width,
    this.height,
  }) : super(key: key);

  final int duration;
  final Color color;
  final Curve curve;
  final double? width;
  final double? height;

  @override
  _VisualComponentState createState() => _VisualComponentState();
}

class _VisualComponentState extends State<VisualComponent> with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController controller;
  late double width;
  late double height;

  @override
  void initState() {
    super.initState();
    width = widget.width ?? 4;
    height = widget.height ?? 15;
    animate();
  }

  void animate() {
    controller = AnimationController(
      duration: Duration(milliseconds: widget.duration),
      vsync: this,
    );
    animation = Tween<double>(begin: 2, end: height).animate(
      CurvedAnimation(
        parent: controller,
        curve: widget.curve,
      ),
    );
    controller.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Align(
        alignment: Alignment.center,
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, _) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: Playback.instance.isPlaying ? animation.value : 2,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5 * Configuration.instance.borderRadiusMultiplier),
              color: widget.color,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.stop();
    controller.reset();
    controller.dispose();
    super.dispose();
  }
}

class LyricsScreen extends StatefulWidget {
  LyricsScreen({Key? key}) : super(key: key);

  @override
  State<LyricsScreen> createState() => _LyricsScreenState();
}

class _LyricsScreenState extends State<LyricsScreen> {
  int current = Playback.instance.position.inSeconds;

  void listener() {
    if (Playback.instance.position.inSeconds != current && Lyrics.instance.currentLyricsAveragedMap.containsKey(Playback.instance.position.inSeconds)) {
      setState(() {
        current = Playback.instance.position.inSeconds;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    Playback.instance.addListener(listener);
  }

  dispose() {
    Playback.instance.removeListener(listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NowPlayingColorPalette>(
      builder: (context, palette, _) => TweenAnimationBuilder<Color?>(
        tween: ColorTween(
          begin: palette.palette?.first ?? Theme.of(context).scaffoldBackgroundColor,
          end: palette.palette?.first ?? Theme.of(context).scaffoldBackgroundColor,
        ),
        duration: Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        builder: (context, value, _) => AnimatedContainer(
          color: value,
          duration: Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          alignment: Alignment.center,
          child: Consumer<Lyrics>(
            builder: (context, lyrics, _) => () {
              if (Lyrics.instance.current.length > 1) {
                return TweenAnimationBuilder<double>(
                  tween: Tween<double>(
                    begin: 0.0,
                    end: (Lyrics.instance.current.length > 1 && Configuration.instance.lyricsVisible) ? 1.0 : 0.0,
                  ),
                  duration: Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  builder: (context, opacity, _) => Opacity(
                    opacity: opacity,
                    child: ShaderMask(
                      shaderCallback: (Rect rect) {
                        return LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black,
                            Colors.transparent,
                            Colors.black,
                          ],
                          stops: [0.1, 0.5, 0.9],
                        ).createShader(rect);
                      },
                      blendMode: BlendMode.dstOut,
                      child: LyricsReader(
                        padding: EdgeInsets.all(tileMargin * 2),
                        model: LyricsReaderModel()
                          ..lyrics = Lyrics.instance.current.asMap().entries.map((e) {
                            return LyricsLineModel()
                              ..mainText = e.value.words
                              ..startTime = e.value.time ~/ 1000
                              ..endTime = e.key + 1 < Lyrics.instance.current.length ? Lyrics.instance.current[e.key + 1].time ~/ 1000 : 1 << 32;
                          }).toList(),
                        position: current,
                        lyricUi: () {
                          final colors = palette.palette ?? [Theme.of(context).cardTheme.color ?? Theme.of(context).cardColor];
                          return LyricsStyle(
                            color: colors.first.isDark ? Colors.white : Colors.black,
                            primary: colors.first != Theme.of(context).cardTheme.color
                                ? colors.first.isDark
                                    ? Colors.white
                                    : Colors.black
                                : (palette.palette ?? [Theme.of(context).primaryColor]).last,
                          );
                        }(),
                        playing: true,
                      ),
                    ),
                  ),
                );
              } else {
                return SizedBox.shrink();
              }
            }(),
          ),
        ),
      ),
    );
  }
}

extension on Color {
  bool get isDark => (0.299 * red) + (0.587 * green) + (0.114 * blue) < 128.0;
}

class LyricsStyle extends LyricUI {
  Color color;
  Color primary;
  double defaultSize;
  double defaultExtSize;
  double otherMainSize;
  double bias;
  double lineGap;
  double inlineGap;
  LyricAlign lyricAlign;
  LyricBaseLine lyricBaseLine;
  bool highlight;

  LyricsStyle({
    this.color = Colors.white,
    this.primary = Colors.white,
    this.defaultSize = 48.0,
    this.defaultExtSize = 24.0,
    this.otherMainSize = 24.0,
    this.bias = 0.5,
    this.lineGap = 25,
    this.inlineGap = 25,
    this.lyricAlign = LyricAlign.LEFT,
    this.lyricBaseLine = LyricBaseLine.MAIN_CENTER,
    this.highlight = false,
  });

  @override
  TextStyle getPlayingExtTextStyle() => TextStyle(
        color: color,
        fontSize: defaultExtSize,
        height: 1.2,
      );

  @override
  TextStyle getOtherExtTextStyle() => TextStyle(
        color: color,
        fontSize: defaultExtSize,
        height: 1.2,
      );

  @override
  TextStyle getOtherMainTextStyle() => TextStyle(
        color: color,
        fontSize: otherMainSize,
        height: 1.2,
      );

  @override
  TextStyle getPlayingMainTextStyle() => TextStyle(
        color: primary,
        fontSize: defaultSize,
        fontWeight: FontWeight.w700,
        height: 1.2,
      );

  @override
  double getInlineSpace() => inlineGap;

  @override
  double getLineSpace() => lineGap;

  @override
  double getPlayingLineBias() => bias;

  @override
  LyricAlign getLyricHorizontalAlign() => lyricAlign;

  @override
  LyricBaseLine getBiasBaseLine() => lyricBaseLine;

  @override
  bool enableHighlight() => highlight;
}
