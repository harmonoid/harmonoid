/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///
import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:media_library/media_library.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter_lyric/lyrics_reader.dart';
import 'package:flutter_lyric/lyrics_reader_model.dart';
import 'package:external_media_provider/external_media_provider.dart';

import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/utils/theme.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/constants.dart';
import 'package:harmonoid/utils/mini_player.dart';
import 'package:harmonoid/utils/sliding_up_panel.dart';
import 'package:harmonoid/state/lyrics.dart';
import 'package:harmonoid/state/now_playing_color_palette.dart';
import 'package:harmonoid/state/mobile_now_playing_controller.dart';
import 'package:harmonoid/interface/now_playing_bar.dart';
import 'package:harmonoid/interface/collection/track.dart';
import 'package:harmonoid/constants/language.dart';

const kDetailsAreaHeight = 100.0;

class MiniNowPlayingBar extends StatefulWidget {
  MiniNowPlayingBar({Key? key}) : super(key: key);

  @override
  State<MiniNowPlayingBar> createState() => MiniNowPlayingBarState();
}

class MiniNowPlayingBarState extends State<MiniNowPlayingBar>
    with TickerProviderStateMixin {
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
        () => _y = (kMobileNowPlayingBarHeight + 4.0) /
            (MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.vertical),
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
  List<Widget> tracksSkipped = [];
  bool showAlbumArtButton = false;
  PageController pageController =
      PageController(initialPage: Playback.instance.index);
  MiniplayerController controller = MiniplayerController();
  PanelController slidingUpPanelController = PanelController();
  ValueNotifier<bool> minimizedPlaylist = ValueNotifier<bool>(true);
  List<Widget> fills = [];
  Color? color;
  Timer? timer;
  Widget? playlistPanel;

  @override
  void initState() {
    super.initState();
    _y = (kMobileNowPlayingBarHeight + 4.0) /
        (window.physicalSize.height -
            window.padding.top / window.devicePixelRatio +
            16.0 -
            window.padding.bottom) *
        window.devicePixelRatio;
    playOrPause = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
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
    if (!Configuration.instance.mobileEnableNowPlayingScreenRippleEffect) {
      color = Theme.of(context).scaffoldBackgroundColor;
      setState(() {});
    } else {
      final color = NowPlayingColorPalette.instance.palette == null
          ? Theme.of(context).cardTheme.color
          : NowPlayingColorPalette.instance.palette?.first.withOpacity(1.0);
      if (Theme.of(context).extension<AnimationDuration>()?.fast ==
          Duration.zero) {
        setState(() => this.color = color);
      } else {
        final ms = ((1000 * (400 / MediaQuery.of(context).size.width)) ~/ 1);
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
              duration: Duration(milliseconds: ms),
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
  }

  bool get isVolumeSliderVisible {
    final vh = MediaQuery.of(context).size.height;
    final vw = MediaQuery.of(context).size.width;
    // Enabled in Settings.
    return Configuration
            .instance.mobileDisplayVolumeSliderDirectlyOnNowPlayingScreen &&
        // Has enough room on screen. Referring to taller 20:9 (?) devices with larger resolution.
        // Bottom sheet's height compared with certain threshold, here `256.0`.
        (vh - (vw + kDetailsAreaHeight + 128.0)) >= 128.0;
  }

  double get bottomSheetMinHeight => isVolumeSliderVisible ? 172.0 : 128.0;

  Future<void> listener() async {
    if (Playback.instance.playing) {
      playOrPause.forward();
    } else {
      playOrPause.reverse();
    }
    if (Playback.instance.index < 0 ||
        Playback.instance.index >= Playback.instance.tracks.length ||
        Playback.instance.tracks.isEmpty) {
      return;
    }
    if (index != Playback.instance.index) {
      if (pageController.hasClients) {
        pageController.animateToPage(
          Playback.instance.index,
          duration: Theme.of(context).extension<AnimationDuration>()?.medium ??
              Duration.zero,
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
    final update = this.track != track ||
        tracks.length.compareTo(Playback.instance.tracks.length) != 0;
    if (update) {
      this.track = track;
      // NOTE: Do not depend on [BuildContext] here.
      tracks = Playback.instance.tracks
          .asMap()
          .entries
          .map(
            (e) => Builder(
              builder: (context) => TrackTile(
                track: e.value,
                index: e.key,
                disableContextMenu: true,
                disableSeparator: true,
                onPressed: () {
                  Playback.instance.jump(e.key);
                },
                leading: Container(
                  height: 56.0,
                  width: 56.0,
                  alignment: Alignment.center,
                  child: e.key == Playback.instance.index
                      ? Container(
                          height: 32.0,
                          width: 28.0,
                          alignment: Alignment.center,
                          child: MiniMusicVisualizer(
                            color: Theme.of(context).iconTheme.color,
                            width: 6,
                            height: 15,
                          ),
                        )
                      : Text(
                          '${e.key - Playback.instance.index <= 0 ? '' : '+'}${e.key - Playback.instance.index}',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: 18.0,
                                  ),
                        ),
                ),
                title: Text(
                  e.value.trackName,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: e.key < Playback.instance.index
                            ? Theme.of(context).textTheme.bodyMedium?.color
                            : null,
                      ),
                ),
                subtitle: Text(
                  e.value.trackArtistNames.take(1).join(', '),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          )
          .toList();
      if (minimizedPlaylist.value || more.isEmpty) {
        final shuffle = [
          ...Collection.instance.tracks,
        ]..shuffle();
        more = shuffle
            .take(10)
            .map(
              (e) => Builder(
                builder: (context) => TrackTile(
                  track: e,
                  index: 0,
                  group: [e] + shuffle,
                  disableContextMenu: true,
                  disableSeparator: true,
                  leading: Container(
                    height: 56.0,
                    width: 56.0,
                    alignment: Alignment.center,
                    child: Icon(Icons.music_note_outlined),
                  ),
                  title: Text(
                    e.trackName,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Text(
                    e.trackArtistNames.take(1).join(', '),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            )
            .toList();
      }
      tracksSkipped =
          tracks.skip(Playback.instance.index + 1).take(20).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    NowPlayingColorPalette colors = NowPlayingColorPalette.instance;
    // If [Configuration.instance.mobileEnableNowPlayingScreenRippleEffect] is enabled, then
    // just use the color from palette & set the [color] attribute accordingly.
    // Else, remove the existingly set palette color & fallback to [Theme.of(context).scaffoldBackgroundColor].
    if (!Configuration.instance.mobileEnableNowPlayingScreenRippleEffect) {
      color = Theme.of(context).scaffoldBackgroundColor;
      colors = NowPlayingColorPalette()
        ..palette = [
          Theme.of(context).scaffoldBackgroundColor,
          if (colors.palette?.last != null)
            colors.palette!.last
          else
            Theme.of(context).colorScheme.primary,
        ];
    } else if ([
      null,
      Theme.of(context).scaffoldBackgroundColor,
    ].contains(color)) {
      color = colors.palette?.first.withOpacity(1.0);
    }

    return AnimatedSlide(
      offset: Offset(0, _y),
      duration: Theme.of(context).extension<AnimationDuration>()?.fast ??
          Duration.zero,
      curve: Curves.easeInOut,
      child: Miniplayer(
        controller: controller,
        elevation:
            Theme.of(context).appBarTheme.elevation ?? kDefaultAppBarElevation,
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
                MobileNowPlayingController.instance.bottomNavigationBar.value =
                    (1.0 - (percentage * 1.4).clamp(0.0, 1.0));
              },
            );
          } catch (exception, stacktrace) {
            debugPrint(exception.toString());
            debugPrint(stacktrace.toString());
          }
          return () {
            if (Playback.instance.tracks.isEmpty)
              return const SizedBox.shrink();
            return Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height,
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: AnnotatedRegion<SystemUiOverlayStyle>(
                    value: SystemUiOverlayStyle(
                      statusBarColor: Colors.transparent,
                      statusBarIconBrightness: Brightness.light,
                      systemNavigationBarIconBrightness: Brightness.light,
                    ),
                    child: ListView(
                      shrinkWrap: false,
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      children: [
                        if (percentage < 0.8)
                          Consumer<Playback>(
                            builder: (context, playback, _) =>
                                LinearProgressIndicator(
                              value: playback.duration == Duration.zero
                                  ? 0.0
                                  : playback.position.inMilliseconds /
                                      playback.duration.inMilliseconds,
                              minHeight: 2.0,
                              valueColor: AlwaysStoppedAnimation(
                                colors.palette?.last ??
                                    Theme.of(context).colorScheme.primary,
                              ),
                              backgroundColor:
                                  colors.palette?.last.withOpacity(0.2) ??
                                      Colors.transparent,
                            ),
                          ),
                        Container(
                          height: percentage == 1.0
                              ? MediaQuery.of(context).size.width
                              : height < MediaQuery.of(context).size.width
                                  ? height - 2.0
                                  : height >= MediaQuery.of(context).size.width
                                      ? MediaQuery.of(context).size.width
                                      : null,
                          child: Stack(
                            children: [
                              if (percentage < 0.8)
                                Consumer<Playback>(
                                  builder: (context, playback, _) =>
                                      LinearProgressIndicator(
                                    value: playback.duration == Duration.zero
                                        ? 0.0
                                        : playback.position.inMilliseconds /
                                            playback.duration.inMilliseconds,
                                    minHeight: height - 2.0,
                                    valueColor: AlwaysStoppedAnimation(
                                      colors.palette?.last.withOpacity(0.2) ??
                                          Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withOpacity(0.2),
                                    ),
                                    backgroundColor:
                                        Theme.of(context).cardTheme.color,
                                  ),
                                ),
                              Positioned.fill(
                                child: Material(
                                  color: Colors.transparent,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Stack(
                                        alignment: Alignment.topLeft,
                                        children: [
                                          if (percentage == 1.0)
                                            Container(
                                              color: Colors.black,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              height: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                            ),
                                          percentage == 1.0
                                              ? () {
                                                  if (pageController
                                                          .initialPage !=
                                                      Playback.instance.index) {
                                                    pageController =
                                                        PageController(
                                                      initialPage: Playback
                                                          .instance.index,
                                                    );
                                                  }
                                                  return Container(
                                                    height:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    child: NotificationListener<
                                                        ScrollNotification>(
                                                      onNotification:
                                                          (ScrollNotification
                                                              notification) {
                                                        if (notification
                                                                    .depth ==
                                                                0 &&
                                                            notification
                                                                is ScrollEndNotification &&
                                                            notification.metrics
                                                                    .axis ==
                                                                Axis.horizontal) {
                                                          Playback.instance
                                                              .jump(
                                                                  currentPage);
                                                        }
                                                        return false;
                                                      },
                                                      child: PageView.builder(
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        controller:
                                                            pageController,
                                                        onPageChanged: (page) {
                                                          currentPage = page;
                                                        },
                                                        itemCount: Playback
                                                            .instance
                                                            .tracks
                                                            .length,
                                                        itemBuilder:
                                                            (context, i) =>
                                                                Stack(
                                                          children: [
                                                            SizedBox(
                                                              child:
                                                                  ExtendedImage(
                                                                image: getAlbumArt(
                                                                    Playback
                                                                        .instance
                                                                        .tracks[i]),
                                                                width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                                height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                                fit: BoxFit
                                                                    .cover,
                                                                enableLoadState:
                                                                    true,
                                                                handleLoadingProgress:
                                                                    true,
                                                                loadStateChanged:
                                                                    (state) {
                                                                  switch (state
                                                                      .extendedImageLoadState) {
                                                                    case LoadState
                                                                          .failed:
                                                                      {
                                                                        if (ExternalMedia.supported(Playback
                                                                            .instance
                                                                            .tracks[i]
                                                                            .uri)) {
                                                                          // Show [getAlbumArt] with smaller size in-case of a load failure.
                                                                          return ExtendedImage(
                                                                            image:
                                                                                getAlbumArt(
                                                                              Playback.instance.tracks[i],
                                                                              small: true,
                                                                            ),
                                                                            width:
                                                                                MediaQuery.of(context).size.width,
                                                                            height:
                                                                                MediaQuery.of(context).size.width,
                                                                            fit:
                                                                                BoxFit.cover,
                                                                          );
                                                                        }
                                                                        return state
                                                                            .completedWidget;
                                                                      }
                                                                    default:
                                                                      return state
                                                                          .completedWidget;
                                                                  }
                                                                },
                                                              ),
                                                            ),
                                                            TweenAnimationBuilder<
                                                                double>(
                                                              tween:
                                                                  Tween<double>(
                                                                      begin: 0,
                                                                      end: 1.0),
                                                              child: Stack(
                                                                children: [
                                                                  Container(
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      gradient:
                                                                          LinearGradient(
                                                                        colors: [
                                                                          Colors
                                                                              .black38,
                                                                          Colors
                                                                              .transparent,
                                                                        ],
                                                                        stops: [
                                                                          0.0,
                                                                          0.5,
                                                                        ],
                                                                        begin: Alignment
                                                                            .topCenter,
                                                                        end: Alignment
                                                                            .bottomCenter,
                                                                      ),
                                                                    ),
                                                                    height: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width,
                                                                    width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width,
                                                                  ),
                                                                  Positioned
                                                                      .fill(
                                                                    child:
                                                                        Material(
                                                                      color: Colors
                                                                          .transparent,
                                                                      child:
                                                                          Row(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.start,
                                                                        children: [
                                                                          Container(
                                                                            padding:
                                                                                EdgeInsets.only(
                                                                              top: MediaQuery.of(context).padding.top + 8.0,
                                                                              left: 8.0,
                                                                              bottom: 8.0,
                                                                            ),
                                                                            child:
                                                                                IconButton(
                                                                              onPressed: () {
                                                                                controller.animateToHeight(
                                                                                  state: MiniPlayerPanelState.MIN,
                                                                                );
                                                                              },
                                                                              color: Theme.of(context).extension<IconColors>()?.appBarDark,
                                                                              icon: Icon(Icons.close),
                                                                              splashRadius: 24.0,
                                                                            ),
                                                                          ),
                                                                          const Spacer(),
                                                                          Container(
                                                                            padding:
                                                                                EdgeInsets.only(
                                                                              top: MediaQuery.of(context).padding.top + 8.0,
                                                                              bottom: 8.0,
                                                                            ),
                                                                            child:
                                                                                IconButton(
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
                                                                                Icons.text_format,
                                                                              ),
                                                                              tooltip: Language.instance.SHOW_LYRICS,
                                                                              color: Theme.of(context).extension<IconColors>()?.appBarDark,
                                                                              splashRadius: 24.0,
                                                                            ),
                                                                          ),
                                                                          Container(
                                                                            padding:
                                                                                EdgeInsets.only(
                                                                              top: MediaQuery.of(context).padding.top + 8.0,
                                                                              bottom: 8.0,
                                                                            ),
                                                                            child:
                                                                                IconButton(
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
                                                                                Icons.equalizer_outlined,
                                                                              ),
                                                                              tooltip: Language.instance.CONTROL_PANEL,
                                                                              color: Theme.of(context).extension<IconColors>()?.appBarDark,
                                                                              splashRadius: 24.0,
                                                                            ),
                                                                          ),
                                                                          Container(
                                                                            padding:
                                                                                EdgeInsets.only(
                                                                              top: MediaQuery.of(context).padding.top + 8.0,
                                                                              bottom: 8.0,
                                                                            ),
                                                                            child:
                                                                                Consumer<Collection>(
                                                                              builder: (context, collection, _) => (Playback.instance.index < 0 || Playback.instance.index >= Playback.instance.tracks.length || Playback.instance.tracks.isEmpty)
                                                                                  ? const SizedBox.shrink()
                                                                                  : IconButton(
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
                                                                                      icon: Icon(
                                                                                        () {
                                                                                          try {
                                                                                            return collection.likedSongsPlaylist.tracks.contains(Playback.instance.tracks[Playback.instance.index]) ? Icons.favorite : Icons.favorite_border;
                                                                                          } catch (exception, stacktrace) {
                                                                                            print(exception);
                                                                                            print(stacktrace);
                                                                                            return Icons.favorite_border;
                                                                                          }
                                                                                        }(),
                                                                                      ),
                                                                                      color: Theme.of(context).extension<IconColors>()?.appBarDark,
                                                                                      splashRadius: 24.0,
                                                                                    ),
                                                                            ),
                                                                          ),
                                                                          Container(
                                                                            padding:
                                                                                EdgeInsets.only(
                                                                              top: MediaQuery.of(context).padding.top + 8.0,
                                                                              right: 8.0,
                                                                              bottom: 8.0,
                                                                            ),
                                                                            child:
                                                                                IconButton(
                                                                              onPressed: () async {
                                                                                final track = Playback.instance.tracks[Playback.instance.index];
                                                                                int? result;
                                                                                await showModalBottomSheet(
                                                                                  isScrollControlled: true,
                                                                                  elevation: 0,
                                                                                  backgroundColor: Colors.transparent,
                                                                                  context: context,
                                                                                  builder: (context) => Card(
                                                                                    margin: EdgeInsets.only(
                                                                                      left: 8.0,
                                                                                      right: 8.0,
                                                                                      bottom: 8.0,
                                                                                    ),
                                                                                    clipBehavior: Clip.antiAlias,
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
                                                                                          if (ExternalMedia.supported(track.uri))
                                                                                            PopupMenuItem(
                                                                                              onTap: () => result = 1,
                                                                                              value: 1,
                                                                                              child: ListTile(
                                                                                                leading: Icon(Icons.link),
                                                                                                title: Text(Language.instance.COPY_LINK),
                                                                                              ),
                                                                                            ),
                                                                                          if (ExternalMedia.supported(track.uri))
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
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                );
                                                                                switch (result) {
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
                                                                                          [
                                                                                            track.uri.toFilePath()
                                                                                          ],
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
                                                                              color: Theme.of(context).extension<IconColors>()?.appBarDark,
                                                                              icon: Icon(Icons.more_vert),
                                                                              splashRadius: 24.0,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              duration: Theme.of(
                                                                          context)
                                                                      .extension<
                                                                          AnimationDuration>()
                                                                      ?.medium ??
                                                                  Duration.zero,
                                                              builder: (
                                                                context,
                                                                value,
                                                                child,
                                                              ) =>
                                                                  Opacity(
                                                                opacity: value,
                                                                child: child,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }()
                                              : Playback.instance.index < 0 ||
                                                      Playback.instance.index >=
                                                          Playback.instance
                                                              .tracks.length ||
                                                      Playback.instance.tracks
                                                          .isEmpty
                                                  ? const SizedBox.shrink()
                                                  : Consumer<Playback>(
                                                      builder: (context,
                                                              playback, _) =>
                                                          SizedBox(
                                                        child: ExtendedImage(
                                                          image: getAlbumArt(
                                                              playback.tracks[
                                                                  playback
                                                                      .index]),
                                                          constraints:
                                                              BoxConstraints(
                                                            maxWidth:
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                            maxHeight:
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                          ),
                                                          width: percentage ==
                                                                  1.0
                                                              ? MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width
                                                              : height - 2.0,
                                                          height: percentage ==
                                                                  1.0
                                                              ? MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width
                                                              : height - 2.0,
                                                          fit: BoxFit.cover,
                                                          enableLoadState: true,
                                                          handleLoadingProgress:
                                                              true,
                                                          loadStateChanged:
                                                              (state) {
                                                            switch (state
                                                                .extendedImageLoadState) {
                                                              case LoadState
                                                                    .failed:
                                                                {
                                                                  if (ExternalMedia.supported(playback
                                                                      .tracks[playback
                                                                          .index]
                                                                      .uri)) {
                                                                    // Show [getAlbumArt] with smaller size in-case of a load failure.
                                                                    return ExtendedImage(
                                                                      image:
                                                                          getAlbumArt(
                                                                        playback
                                                                            .tracks[playback.index],
                                                                        small:
                                                                            true,
                                                                      ),
                                                                      width: percentage ==
                                                                              1.0
                                                                          ? MediaQuery.of(context)
                                                                              .size
                                                                              .width
                                                                          : height -
                                                                              2.0,
                                                                      height: percentage ==
                                                                              1.0
                                                                          ? MediaQuery.of(context)
                                                                              .size
                                                                              .width
                                                                          : height -
                                                                              2.0,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    );
                                                                  }
                                                                  return state
                                                                      .completedWidget;
                                                                }
                                                              default:
                                                                return state
                                                                    .completedWidget;
                                                            }
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                        ],
                                      ),
                                      if (percentage < 1.0)
                                        () {
                                          if (Playback.instance.index < 0 ||
                                              Playback.instance.index >=
                                                  Playback
                                                      .instance.tracks.length ||
                                              Playback
                                                  .instance.tracks.isEmpty) {
                                            return const SizedBox.shrink();
                                          }
                                          return Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Opacity(
                                                  opacity: (1 - percentage * 5)
                                                      .clamp(0.0, 1.0),
                                                  child: Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 16.0),
                                                    child: Text(
                                                      Playback
                                                          .instance
                                                          .tracks[Playback
                                                              .instance.index]
                                                          .trackName
                                                          .overflow,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleMedium,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 2.0),
                                                if (!Playback
                                                    .instance
                                                    .tracks[
                                                        Playback.instance.index]
                                                    .trackArtistNamesNotPresent)
                                                  Opacity(
                                                    opacity:
                                                        (1 - percentage * 5)
                                                            .clamp(0.0, 1.0),
                                                    child: Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 16.0),
                                                      child: Text(
                                                        Playback
                                                            .instance
                                                            .tracks[Playback
                                                                .instance.index]
                                                            .trackArtistNames
                                                            .take(2)
                                                            .join(', ')
                                                            .overflow,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodySmall,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          );
                                        }(),
                                      if (height <
                                          MediaQuery.of(context).size.width -
                                              64.0)
                                        Opacity(
                                          opacity: (1 - percentage * 5)
                                              .clamp(0.0, 1.0),
                                          child: Container(
                                            height: 64.0,
                                            width: 64.0,
                                            alignment: Alignment.center,
                                            child: IconButton(
                                              onPressed:
                                                  Playback.instance.playOrPause,
                                              icon: AnimatedIcon(
                                                progress: playOrPause,
                                                icon: AnimatedIcons.play_pause,
                                              ),
                                              splashRadius: 24.0,
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
                        if (height >= MediaQuery.of(context).size.width)
                          Container(
                            color:
                                this.color ?? Theme.of(context).cardTheme.color,
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
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height,
                                    width: MediaQuery.of(context).size.width,
                                    child: Consumer<Playback>(
                                        builder: (context, playback, _) {
                                      if (playback.index < 0 ||
                                          playback.index >=
                                              playback.tracks.length ||
                                          playback.tracks.isEmpty) {
                                        return const SizedBox.shrink();
                                      }
                                      return Column(
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            height: kDetailsAreaHeight,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 16.0),
                                            color: Colors.transparent,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  playback
                                                      .tracks[playback.index
                                                          .clamp(
                                                              0,
                                                              playback.tracks
                                                                      .length -
                                                                  1)]
                                                      .trackName
                                                      .overflow,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headlineSmall
                                                      ?.copyWith(
                                                        color: (colors.palette ??
                                                                        [
                                                                          Theme.of(context).cardTheme.color ??
                                                                              Theme.of(context).cardColor
                                                                        ])
                                                                    .first
                                                                    .computeLuminance() <
                                                                0.5
                                                            ? Theme.of(context)
                                                                .extension<
                                                                    TextColors>()
                                                                ?.darkPrimary
                                                            : Theme.of(context)
                                                                .extension<
                                                                    TextColors>()
                                                                ?.lightPrimary,
                                                        fontSize: 24.0,
                                                      ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4.0),
                                                Text(
                                                  [
                                                    if (!playback
                                                        .tracks[playback.index]
                                                        .trackArtistNamesNotPresent)
                                                      playback
                                                          .tracks[
                                                              playback.index]
                                                          .trackArtistNames
                                                          .take(2)
                                                          .join(', '),
                                                    if (!playback
                                                        .tracks[playback.index]
                                                        .albumNameNotPresent)
                                                      playback
                                                          .tracks[
                                                              playback.index]
                                                          .albumName,
                                                  ].join(' • '),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(
                                                        color: (colors.palette ??
                                                                        [
                                                                          Theme.of(context).cardTheme.color ??
                                                                              Theme.of(context).cardColor
                                                                        ])
                                                                    .first
                                                                    .computeLuminance() <
                                                                0.5
                                                            ? Theme.of(context)
                                                                .extension<
                                                                    TextColors>()
                                                                ?.darkSecondary
                                                            : Theme.of(context)
                                                                .extension<
                                                                    TextColors>()
                                                                ?.lightSecondary,
                                                      ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4.0),
                                                if (Configuration.instance
                                                        .displayAudioFormat &&
                                                    playback
                                                        .tracks[playback.index]
                                                        .uri
                                                        .isScheme('FILE'))
                                                  Text(
                                                    playback.androidAudioFormat
                                                        .label,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style:
                                                        Theme.of(context)
                                                            .textTheme
                                                            .bodyMedium
                                                            ?.copyWith(
                                                              color: (colors.palette ??
                                                                              [
                                                                                Theme.of(context).cardTheme.color ?? Theme.of(context).cardColor
                                                                              ])
                                                                          .first
                                                                          .computeLuminance() <
                                                                      0.5
                                                                  ? Theme.of(
                                                                          context)
                                                                      .extension<
                                                                          TextColors>()
                                                                      ?.darkSecondary
                                                                  : Theme.of(
                                                                          context)
                                                                      .extension<
                                                                          TextColors>()
                                                                      ?.lightSecondary,
                                                            ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Material(
                                              color: Colors.transparent,
                                              child: Container(
                                                alignment: Alignment.topCenter,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                color: Configuration.instance
                                                        .mobileEnableNowPlayingScreenRippleEffect
                                                    ? Colors.white24
                                                    : Colors.transparent,
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                    top: 44.0,
                                                    bottom: 16.0 + 8.0,
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        children: [
                                                          const SizedBox(
                                                              width: 20.0),
                                                          IconButton(
                                                            onPressed: () {
                                                              if (playback
                                                                      .playlistLoopMode ==
                                                                  PlaylistLoopMode
                                                                      .loop) {
                                                                playback
                                                                    .setPlaylistLoopMode(
                                                                  PlaylistLoopMode
                                                                      .none,
                                                                );
                                                                return;
                                                              }
                                                              playback
                                                                  .setPlaylistLoopMode(
                                                                PlaylistLoopMode
                                                                    .values[playback
                                                                        .playlistLoopMode
                                                                        .index +
                                                                    1],
                                                              );
                                                            },
                                                            iconSize: 24.0,
                                                            color: (playback
                                                                        .playlistLoopMode !=
                                                                    PlaylistLoopMode
                                                                        .none)
                                                                ? (colors.palette ??
                                                                                [
                                                                                  Theme.of(context).cardTheme.color ?? Theme.of(context).cardColor
                                                                                ])
                                                                            .first
                                                                            .computeLuminance() <
                                                                        0.5
                                                                    ? Color.lerp(
                                                                        Colors
                                                                            .black,
                                                                        Colors
                                                                            .white,
                                                                        0.87)
                                                                    : Color.lerp(
                                                                        Colors
                                                                            .white,
                                                                        Colors
                                                                            .black,
                                                                        0.87)
                                                                : (colors.palette ??
                                                                                [
                                                                                  Theme.of(context).cardTheme.color ?? Theme.of(context).cardColor
                                                                                ])
                                                                            .first
                                                                            .computeLuminance() <
                                                                        0.5
                                                                    ? Color.lerp(
                                                                        Colors
                                                                            .black,
                                                                        Colors
                                                                            .white,
                                                                        0.54)
                                                                    : Color.lerp(
                                                                        Colors
                                                                            .white,
                                                                        Colors
                                                                            .black,
                                                                        0.54),
                                                            splashRadius: 24.0,
                                                            icon: Icon(
                                                              playback.playlistLoopMode ==
                                                                      PlaylistLoopMode
                                                                          .single
                                                                  ? Icons
                                                                      .repeat_one
                                                                  : Icons
                                                                      .repeat,
                                                            ),
                                                          ),
                                                          Spacer(),
                                                          Container(
                                                            width: 48.0,
                                                            child: IconButton(
                                                              onPressed:
                                                                  Playback
                                                                      .instance
                                                                      .previous,
                                                              icon: Icon(
                                                                Icons
                                                                    .skip_previous,
                                                                color: (colors.palette ??
                                                                                [
                                                                                  Theme.of(context).cardTheme.color ?? Theme.of(context).cardColor
                                                                                ])
                                                                            .first
                                                                            .computeLuminance() <
                                                                        0.5
                                                                    ? Color.lerp(
                                                                        Colors
                                                                            .black,
                                                                        Colors
                                                                            .white,
                                                                        0.87)
                                                                    : Color.lerp(
                                                                        Colors
                                                                            .white,
                                                                        Colors
                                                                            .black,
                                                                        0.87),
                                                                size: 28.0,
                                                              ),
                                                              splashRadius:
                                                                  28.0,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 8.0),
                                                          Container(
                                                            width: 72.0,
                                                            child:
                                                                FloatingActionButton(
                                                              onPressed: Playback
                                                                      .instance
                                                                      .playing
                                                                  ? Playback
                                                                      .instance
                                                                      .pause
                                                                  : Playback
                                                                      .instance
                                                                      .play,
                                                              backgroundColor:
                                                                  (colors.palette?.cast<
                                                                              Color?>() ??
                                                                          [
                                                                            Theme.of(context).floatingActionButtonTheme.backgroundColor
                                                                          ])
                                                                      .last,
                                                              child:
                                                                  AnimatedIcon(
                                                                progress:
                                                                    playOrPause,
                                                                icon: AnimatedIcons
                                                                    .play_pause,
                                                                color: (colors.palette ??
                                                                                [
                                                                                  Theme.of(context).colorScheme.primary
                                                                                ])
                                                                            .last
                                                                            .computeLuminance() <
                                                                        0.5
                                                                    ? Colors
                                                                        .white
                                                                    : Colors
                                                                        .black,
                                                                size: 32.0,
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 8.0),
                                                          Container(
                                                            width: 48.0,
                                                            child: IconButton(
                                                              onPressed:
                                                                  Playback
                                                                      .instance
                                                                      .next,
                                                              icon: Icon(
                                                                Icons.skip_next,
                                                                color: (colors.palette ??
                                                                                [
                                                                                  Theme.of(context).cardTheme.color ?? Theme.of(context).cardColor
                                                                                ])
                                                                            .first
                                                                            .computeLuminance() <
                                                                        0.5
                                                                    ? Color.lerp(
                                                                        Colors
                                                                            .black,
                                                                        Colors
                                                                            .white,
                                                                        0.87)
                                                                    : Color.lerp(
                                                                        Colors
                                                                            .white,
                                                                        Colors
                                                                            .black,
                                                                        0.87),
                                                                size: 28.0,
                                                              ),
                                                              splashRadius:
                                                                  28.0,
                                                            ),
                                                          ),
                                                          Spacer(),
                                                          IconButton(
                                                            onPressed: playback
                                                                .toggleShuffle,
                                                            iconSize: 24.0,
                                                            color: playback
                                                                    .shuffling
                                                                ? (colors.palette ??
                                                                                [
                                                                                  Theme.of(context).cardTheme.color ?? Theme.of(context).cardColor
                                                                                ])
                                                                            .first
                                                                            .computeLuminance() <
                                                                        0.5
                                                                    ? Color.lerp(
                                                                        Colors
                                                                            .black,
                                                                        Colors
                                                                            .white,
                                                                        0.87)
                                                                    : Color.lerp(
                                                                        Colors
                                                                            .white,
                                                                        Colors
                                                                            .black,
                                                                        0.87)
                                                                : (colors.palette ??
                                                                                [
                                                                                  Theme.of(context).cardTheme.color ?? Theme.of(context).cardColor
                                                                                ])
                                                                            .first
                                                                            .computeLuminance() <
                                                                        0.5
                                                                    ? Color.lerp(
                                                                        Colors
                                                                            .black,
                                                                        Colors
                                                                            .white,
                                                                        0.54)
                                                                    : Color.lerp(
                                                                        Colors
                                                                            .white,
                                                                        Colors
                                                                            .black,
                                                                        0.54),
                                                            splashRadius: 24.0,
                                                            icon: Icon(
                                                              Icons.shuffle,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 20.0),
                                                        ],
                                                      ),
                                                      if (isVolumeSliderVisible)
                                                        const SizedBox(
                                                          height: 8.0,
                                                        ),
                                                      if (isVolumeSliderVisible)
                                                        Row(
                                                          children: [
                                                            const SizedBox(
                                                              width: 48.0,
                                                            ),
                                                            IconButton(
                                                              icon: Icon(
                                                                Icons
                                                                    .volume_down,
                                                              ),
                                                              onPressed: () {
                                                                playback
                                                                    .setVolume(
                                                                  (playback.volume -
                                                                          5.0)
                                                                      .clamp(
                                                                    0.0,
                                                                    100.0,
                                                                  ),
                                                                );
                                                              },
                                                              color: (colors.palette ??
                                                                              [
                                                                                Theme.of(context).cardTheme.color ?? Theme.of(context).cardColor
                                                                              ])
                                                                          .first
                                                                          .computeLuminance() <
                                                                      0.5
                                                                  ? Color.lerp(
                                                                      Colors
                                                                          .black,
                                                                      Colors
                                                                          .white,
                                                                      0.87)
                                                                  : Color.lerp(
                                                                      Colors
                                                                          .white,
                                                                      Colors
                                                                          .black,
                                                                      0.87),
                                                            ),
                                                            const SizedBox(
                                                              width: 16.0,
                                                            ),
                                                            Consumer<Playback>(
                                                              builder: (context,
                                                                      playback,
                                                                      _) =>
                                                                  Expanded(
                                                                child:
                                                                    ScrollableSlider(
                                                                  min: 0.0,
                                                                  max: 100.0,
                                                                  value: playback
                                                                      .volume
                                                                      .clamp(
                                                                          0.0,
                                                                          100.0),
                                                                  color: colors
                                                                      .palette
                                                                      ?.last,
                                                                  secondaryColor:
                                                                      colors
                                                                          .palette
                                                                          ?.first,
                                                                  onChanged:
                                                                      (value) {
                                                                    playback
                                                                        .setVolume(
                                                                      value,
                                                                    );
                                                                  },
                                                                  onScrolledUp:
                                                                      () {
                                                                    playback
                                                                        .setVolume(
                                                                      (playback.volume +
                                                                              5.0)
                                                                          .clamp(
                                                                        0.0,
                                                                        100.0,
                                                                      ),
                                                                    );
                                                                  },
                                                                  onScrolledDown:
                                                                      () {
                                                                    playback
                                                                        .setVolume(
                                                                      (playback.volume -
                                                                              5.0)
                                                                          .clamp(
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
                                                                Icons.volume_up,
                                                              ),
                                                              onPressed: () {
                                                                playback
                                                                    .setVolume(
                                                                  (playback.volume +
                                                                          5.0)
                                                                      .clamp(
                                                                    0.0,
                                                                    100.0,
                                                                  ),
                                                                );
                                                              },
                                                              color: (colors.palette ??
                                                                              [
                                                                                Theme.of(context).cardTheme.color ?? Theme.of(context).cardColor
                                                                              ])
                                                                          .first
                                                                          .computeLuminance() <
                                                                      0.5
                                                                  ? Color.lerp(
                                                                      Colors
                                                                          .black,
                                                                      Colors
                                                                          .white,
                                                                      0.87)
                                                                  : Color.lerp(
                                                                      Colors
                                                                          .white,
                                                                      Colors
                                                                          .black,
                                                                      0.87),
                                                            ),
                                                            const SizedBox(
                                                              width: 48.0,
                                                            ),
                                                          ],
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }),
                                  ),
                                  Consumer<Playback>(
                                    builder: (context, playback, _) =>
                                        Positioned(
                                      left: 0.0,
                                      right: 0.0,
                                      top: kDetailsAreaHeight - 12.0,
                                      child: Column(
                                        children: [
                                          ScrollableSlider(
                                            min: 0.0,
                                            max: playback
                                                .duration.inMilliseconds
                                                .toDouble(),
                                            value: playback
                                                .position.inMilliseconds
                                                .clamp(
                                                    0,
                                                    playback
                                                        .duration.inMilliseconds
                                                        .toDouble())
                                                .toDouble(),
                                            color: colors.palette?.last,
                                            secondaryColor:
                                                colors.palette?.first,
                                            onChanged: (value) {
                                              playback.seek(
                                                Duration(
                                                  milliseconds: value.toInt(),
                                                ),
                                              );
                                            },
                                            onScrolledUp: () {
                                              if (playback.position >=
                                                  playback.duration) return;
                                              playback.seek(
                                                playback.position +
                                                    Duration(seconds: 10),
                                              );
                                            },
                                            onScrolledDown: () {
                                              if (playback.position <=
                                                  Duration.zero) return;
                                              playback.seek(
                                                playback.position -
                                                    Duration(seconds: 10),
                                              );
                                            },
                                          ),
                                          const SizedBox(height: 4.0),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(height: 24.0),
                                              const SizedBox(width: 18.0),
                                              Text(
                                                playback.position.label,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge
                                                    ?.copyWith(
                                                      color: (colors.palette ??
                                                                      [
                                                                        Theme.of(context).cardTheme.color ??
                                                                            Theme.of(context).cardColor
                                                                      ])
                                                                  .first
                                                                  .computeLuminance() <
                                                              0.5
                                                          ? Theme.of(context)
                                                              .extension<
                                                                  TextColors>()
                                                              ?.darkPrimary
                                                          : Theme.of(context)
                                                              .extension<
                                                                  TextColors>()
                                                              ?.lightPrimary,
                                                    ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Spacer(),
                                              Text(
                                                playback.duration.label,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge
                                                    ?.copyWith(
                                                      color: (colors.palette ??
                                                                      [
                                                                        Theme.of(context).cardTheme.color ??
                                                                            Theme.of(context).cardColor
                                                                      ])
                                                                  .first
                                                                  .computeLuminance() <
                                                              0.5
                                                          ? Theme.of(context)
                                                              .extension<
                                                                  TextColors>()
                                                              ?.darkPrimary
                                                          : Theme.of(context)
                                                              .extension<
                                                                  TextColors>()
                                                              ?.lightPrimary,
                                                    ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(width: 18.0),
                                            ],
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
                if ((MediaQuery.of(context).size.width +
                        kDetailsAreaHeight +
                        bottomSheetMinHeight) <
                    MediaQuery.of(context).size.height)
                  () {
                    // Only cause re-draw or updates to [SlidingUpPanel], when it is maximized.
                    // It is quite expensive process & lag is very apparent.
                    if (playlistPanel == null || percentage == 1.0) {
                      playlistPanel = SizedBox(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (percentage < 1.0)
                              Expanded(
                                child: SizedBox(
                                  height: MediaQuery.of(context).size.width +
                                      kDetailsAreaHeight +
                                      bottomSheetMinHeight,
                                ),
                              ),
                            ScrollConfiguration(
                              behavior: NoOverscrollGlowBehavior(),
                              child: () {
                                final vh = MediaQuery.of(context).size.height;
                                final vw = MediaQuery.of(context).size.width;
                                final pt = window.padding.top /
                                        window.devicePixelRatio +
                                    16.0;
                                final min = vh -
                                    (vw +
                                        kDetailsAreaHeight +
                                        bottomSheetMinHeight);
                                final max = vh - (kToolbarHeight + pt);
                                return SlidingUpPanel(
                                  controller: slidingUpPanelController,
                                  minHeight: min,
                                  maxHeight: max,
                                  renderPanelSheet: true,
                                  backdropEnabled: true,
                                  backdropTapClosesPanel: true,
                                  panelSnapping: true,
                                  backdropOpacity: 0.0,
                                  color: Theme.of(context).cardTheme.color ??
                                      Theme.of(context).cardColor,
                                  margin: const EdgeInsets.only(
                                    left: 16.0,
                                    right: 16.0,
                                  ),
                                  onPanelOpened: () =>
                                      minimizedPlaylist.value = false,
                                  onPanelClosed: () =>
                                      minimizedPlaylist.value = true,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(4.0),
                                    topRight: Radius.circular(4.0),
                                  ),
                                  collapsed: () {
                                    final child = Column(
                                      children: [
                                        Material(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(4.0),
                                            topRight: Radius.circular(4.0),
                                          ),
                                          child: Container(
                                            height: 32.0,
                                            alignment: Alignment.center,
                                            child: Container(
                                              width: 48.0,
                                              height: 4.0,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  2.0,
                                                ),
                                                color: Theme.of(context)
                                                    .dividerTheme
                                                    .color
                                                    ?.withOpacity(0.54),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Divider(
                                          height: 1.0,
                                          thickness: 1.0,
                                        ),
                                        Expanded(
                                          child: CustomListViewSeparated(
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            padding: EdgeInsets.zero,
                                            itemCount: tracksSkipped.length +
                                                1 +
                                                more.length,
                                            itemExtents: List.generate(
                                                  tracksSkipped.length,
                                                  (i) => 72.0,
                                                ) +
                                                [56.0] +
                                                List.generate(
                                                  more.length,
                                                  (i) => 72.0,
                                                ),
                                            separatorExtent: 1.0,
                                            itemBuilder: (context, i) {
                                              i++;
                                              if (i ==
                                                  tracksSkipped.length + 1) {
                                                return Padding(
                                                  padding: EdgeInsets.only(
                                                    left: 62.0,
                                                  ),
                                                  child: SubHeader(
                                                    Language.instance.MORE,
                                                  ),
                                                );
                                              } else if (i <=
                                                  tracksSkipped.length) {
                                                return tracksSkipped[i - 1];
                                              } else if (i >
                                                  tracksSkipped.length + 1) {
                                                return more[i -
                                                    tracksSkipped.length -
                                                    2];
                                              }
                                              return const SizedBox.shrink();
                                            },
                                            separatorBuilder: (context, i) =>
                                                Divider(
                                              height: 1.0,
                                              thickness: 1.0,
                                              indent: 78.0,
                                              endIndent: 8.0,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                    return Configuration.instance
                                            .mobileEnableNowPlayingScreenRippleEffect
                                        ? Container(
                                            clipBehavior: Clip.antiAlias,
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .cardTheme
                                                  .color,
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(4.0),
                                                topRight: Radius.circular(4.0),
                                              ),
                                            ),
                                            child: child,
                                          )
                                        : Container(
                                            clipBehavior: Clip.antiAlias,
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.light
                                                  ? Color.lerp(Colors.white,
                                                      Colors.black, 0.12)
                                                  : Color.lerp(Colors.black,
                                                      Colors.white, 0.24),
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(4.0),
                                                topRight: Radius.circular(4.0),
                                              ),
                                            ),
                                            child: Container(
                                              margin: EdgeInsets.only(
                                                top: 1.0,
                                                left: 1.0,
                                                right: 1.0,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .scaffoldBackgroundColor,
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(4.0),
                                                  topRight:
                                                      Radius.circular(4.0),
                                                ),
                                              ),
                                              child: child,
                                            ),
                                          );
                                  }(),
                                  panelBuilder: (controller) {
                                    final child = Column(
                                      children: [
                                        Material(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(4.0),
                                            topRight: Radius.circular(4.0),
                                          ),
                                          child: Container(
                                            height: 32.0,
                                            alignment: Alignment.center,
                                            child: Container(
                                              width: 48.0,
                                              height: 4.0,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  2.0,
                                                ),
                                                color: Theme.of(context)
                                                    .dividerTheme
                                                    .color
                                                    ?.withOpacity(0.54),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Divider(
                                          height: 1.0,
                                          thickness: 1.0,
                                        ),
                                        Expanded(
                                          child: CustomListViewSeparated(
                                            physics: null,
                                            padding: EdgeInsets.zero,
                                            controller: controller,
                                            itemCount:
                                                tracks.length + 1 + more.length,
                                            itemExtents: List.generate(
                                                  tracks.length,
                                                  (i) => 72.0,
                                                ) +
                                                [56.0] +
                                                List.generate(
                                                  more.length,
                                                  (i) => 72.0,
                                                ),
                                            separatorExtent: 1.0,
                                            itemBuilder: (context, i) {
                                              i++;
                                              if (i == tracks.length + 1) {
                                                return Padding(
                                                  padding: EdgeInsets.only(
                                                    left: 62.0,
                                                  ),
                                                  child: SubHeader(
                                                    Language.instance.MORE,
                                                  ),
                                                );
                                              } else if (i <= tracks.length) {
                                                return tracks[i - 1];
                                              } else if (i >
                                                  tracks.length + 1) {
                                                return more[
                                                    i - tracks.length - 2];
                                              }
                                              return const SizedBox.shrink();
                                            },
                                            separatorBuilder: (context, i) =>
                                                Divider(
                                              height: 1.0,
                                              thickness: 1.0,
                                              indent: 78.0,
                                              endIndent: 8.0,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                    return Configuration.instance
                                            .mobileEnableNowPlayingScreenRippleEffect
                                        ? child
                                        : Container(
                                            clipBehavior: Clip.antiAlias,
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.light
                                                  ? Color.lerp(Colors.white,
                                                      Colors.black, 0.12)
                                                  : Color.lerp(Colors.black,
                                                      Colors.white, 0.24),
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(4.0),
                                                topRight: Radius.circular(4.0),
                                              ),
                                            ),
                                            child: Container(
                                              margin: EdgeInsets.only(
                                                top: 1.0,
                                                left: 1.0,
                                                right: 1.0,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .scaffoldBackgroundColor,
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(4.0),
                                                  topRight:
                                                      Radius.circular(4.0),
                                                ),
                                              ),
                                              child: child,
                                            ),
                                          );
                                  },
                                );
                              }(),
                            ),
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
  State<MiniNowPlayingBarRefreshCollectionButton> createState() =>
      MiniNowPlayingBarRefreshCollectionButtonState();
}

class MiniNowPlayingBarRefreshCollectionButtonState
    extends State<MiniNowPlayingBarRefreshCollectionButton> {
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
              duration:
                  Theme.of(context).extension<AnimationDuration>()?.medium ??
                      Duration.zero,
              tween: ColorTween(
                begin:
                    Theme.of(context).floatingActionButtonTheme.backgroundColor,
                end: value?.first ??
                    Theme.of(context).floatingActionButtonTheme.backgroundColor,
              ),
              builder: (context, color, _) => Container(
                child: widget.index.value == 3
                    ? FloatingActionButton(
                        tooltip: Language.instance.CREATE,
                        child: const Icon(Icons.edit),
                        backgroundColor: color as Color?,
                        onPressed: () async {
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
                                    bottom: MediaQuery.of(context)
                                            .viewInsets
                                            .bottom -
                                        MediaQuery.of(context).padding.bottom,
                                  ),
                                  padding: EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      const SizedBox(height: 4.0),
                                      CustomTextField(
                                        textCapitalization:
                                            TextCapitalization.words,
                                        textInputAction: TextInputAction.done,
                                        autofocus: true,
                                        onChanged: (value) => text = value,
                                        onSubmitted: (String value) async {
                                          if (value.isNotEmpty) {
                                            FocusScope.of(context).unfocus();
                                            await Collection.instance
                                                .playlistCreateFromName(value);
                                            Navigator.of(context).maybePop();
                                          }
                                        },
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                              fontSize: 16.0,
                                            ),
                                        decoration:
                                            mobileUnderlinedInputDecoration(
                                          context,
                                          Language.instance
                                              .PLAYLISTS_TEXT_FIELD_LABEL,
                                        ),
                                      ),
                                      const SizedBox(height: 4.0),
                                      ElevatedButton(
                                        onPressed: () async {
                                          if (text.isNotEmpty) {
                                            FocusScope.of(context).unfocus();
                                            await Collection.instance
                                                .playlistCreateFromName(
                                              text,
                                            );
                                            Navigator.of(context).maybePop();
                                          }
                                        },
                                        child: Text(
                                          label(
                                            context,
                                            Language.instance.CREATE,
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
              duration:
                  Theme.of(context).extension<AnimationDuration>()?.fast ??
                      Duration.zero,
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
    final List<int> duration = [
      900,
      800,
      700,
      600,
      500,
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List<Widget>.generate(
        3,
        (index) => VisualComponent(
          curve: Curves.bounceOut,
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

class _VisualComponentState extends State<VisualComponent>
    with SingleTickerProviderStateMixin {
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
        alignment: Alignment.bottomCenter,
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, _) => Container(
            height: animation.value,
            decoration: BoxDecoration(
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
    if (Playback.instance.position.inSeconds != current &&
        Lyrics.instance.currentLyricsAveragedMap
            .containsKey(Playback.instance.position.inSeconds)) {
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
          begin: palette.palette?.first ??
              Theme.of(context).scaffoldBackgroundColor,
          end: palette.palette?.first ??
              Theme.of(context).scaffoldBackgroundColor,
        ),
        duration: Theme.of(context).extension<AnimationDuration>()?.medium ??
            Duration.zero,
        curve: Curves.easeInOut,
        builder: (context, value, _) => AnimatedContainer(
          color: value,
          duration: Theme.of(context).extension<AnimationDuration>()?.medium ??
              Duration.zero,
          curve: Curves.easeInOut,
          alignment: Alignment.center,
          child: Consumer<Lyrics>(
            builder: (context, lyrics, _) => () {
              if (Lyrics.instance.current.length > 1) {
                return TweenAnimationBuilder<double>(
                  tween: Tween<double>(
                    begin: 0.0,
                    end: (Lyrics.instance.current.length > 1 &&
                            Configuration.instance.lyricsVisible)
                        ? 1.0
                        : 0.0,
                  ),
                  duration:
                      Theme.of(context).extension<AnimationDuration>()?.fast ??
                          Duration.zero,
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
                        padding: EdgeInsets.all(tileMargin(context) * 2),
                        model: LyricsReaderModel()
                          ..lyrics =
                              Lyrics.instance.current.asMap().entries.map((e) {
                            return LyricsLineModel()
                              ..mainText = e.value.words
                              ..startTime = e.value.time ~/ 1000
                              ..endTime = e.key + 1 <
                                      Lyrics.instance.current.length
                                  ? Lyrics.instance.current[e.key + 1].time ~/
                                      1000
                                  : 1 << 32;
                          }).toList(),
                        position: current,
                        lyricUi: () {
                          final colors = palette.palette ??
                              [
                                Theme.of(context).cardTheme.color ??
                                    Theme.of(context).cardColor
                              ];
                          return LyricsStyle(
                            color: colors.first.computeLuminance() < 0.5
                                ? Colors.white
                                : Colors.black,
                            primary: colors.first !=
                                    Theme.of(context).cardTheme.color
                                ? colors.first.computeLuminance() < 0.5
                                    ? Colors.white
                                    : Colors.black
                                : (palette.palette ??
                                        [Theme.of(context).colorScheme.primary])
                                    .last,
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
        fontWeight: FontWeight.w600,
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
