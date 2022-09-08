/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:miniplayer/miniplayer.dart';
import 'package:collection/collection.dart';
import 'package:share_plus/share_plus.dart';
import 'package:media_engine/media_engine.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:media_library/media_library.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter_lyric/lyrics_reader.dart';
import 'package:flutter_lyric/lyrics_reader_model.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/dimensions.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/utils/theme.dart';
import 'package:harmonoid/interface/now_playing_bar.dart';
import 'package:harmonoid/interface/collection/track.dart';
import 'package:harmonoid/state/lyrics.dart';
import 'package:harmonoid/state/now_playing_color_palette.dart';
import 'package:harmonoid/state/mobile_now_playing_controller.dart';
import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/web/utils/widgets.dart';

const kDetailsAreaHeight = 92.0;
const kControlsAreaHeight = 124.0;

class MiniNowPlayingBar extends StatefulWidget {
  MiniNowPlayingBar({Key? key}) : super(key: key);

  @override
  State<MiniNowPlayingBar> createState() => MiniNowPlayingBarState();
}

class MiniNowPlayingBarState extends State<MiniNowPlayingBar>
    with TickerProviderStateMixin {
  double _y = 0.0;

  bool get isHidden => _y != 0.0;

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
    controller.animateToHeight(state: PanelState.MAX);
  }

  void restore() {
    controller.animateToHeight(state: PanelState.MIN);
  }

  late AnimationController playOrPause;
  int index = Playback.instance.index;
  int currentPage = Playback.instance.index;
  Track? track;
  Iterable<Widget> comingUpTracks = [];
  bool showAlbumArtButton = false;
  ScrollPhysics? physics = NeverScrollableScrollPhysics();
  PageController pageController = PageController(
    initialPage: Playback.instance.index,
  );
  final MiniplayerController controller = MiniplayerController();

  @override
  void initState() {
    super.initState();
    _y = (kMobileNowPlayingBarHeight + 4.0) /
        (window.physicalSize.height -
            window.padding.top -
            window.padding.bottom) *
        window.devicePixelRatio;
    playOrPause = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    Playback.instance.addListener(listener);
  }

  @override
  void dispose() {
    Playback.instance.removeListener(listener);
    super.dispose();
  }

  Future<void> listener() async {
    if (Playback.instance.isPlaying) {
      playOrPause.forward();
    } else {
      playOrPause.reverse();
    }
    if (Playback.instance.index < 0 ||
        Playback.instance.index >= Playback.instance.tracks.length) {
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
        Future.wait([
          precacheImage(
            getAlbumArt(
              Playback.instance.tracks[(Playback.instance.index - 1).clamp(
                0,
                Playback.instance.tracks.length,
              )],
            ),
            context,
          ),
          precacheImage(
            getAlbumArt(
              Playback.instance.tracks[(Playback.instance.index + 1).clamp(
                0,
                Playback.instance.tracks.length,
              )],
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
    if (this.track != track ||
        comingUpTracks.length.compareTo(Playback.instance.tracks.length) != 0) {
      this.track = track;
      comingUpTracks = Playback.instance.tracks
          .skip(Playback.instance.index + 1)
          .toList()
          .asMap()
          .entries
          .map((e) => TrackTile(
                track: e.value,
                index: e.key,
                disableContextMenu: true,
                leading: Container(
                  height: 56.0,
                  width: 56.0,
                  alignment: Alignment.center,
                  child: Text(
                    '${e.key + Playback.instance.index + 1}',
                    style: Theme.of(context)
                        .textTheme
                        .headline3
                        ?.copyWith(fontSize: 18.0),
                  ),
                ),
                onPressed: () {
                  Playback.instance.jump(Playback.instance.index + e.key + 1);
                },
              ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NowPlayingColorPalette>(
      builder: (context, colors, _) => AnimatedSlide(
        offset: Offset(0, _y),
        duration: Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: TweenAnimationBuilder<Color?>(
          tween: ColorTween(
            begin: colors.palette?.first ?? Theme.of(context).cardColor,
            end: colors.palette?.first ?? Theme.of(context).cardColor,
          ),
          duration: Duration(milliseconds: 400),
          child: Stack(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Consumer<Playback>(
                  builder: (context, playback, _) => Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: kDetailsAreaHeight,
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        color: Colors.transparent,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              playback
                                  .tracks[playback.index
                                      .clamp(0, playback.tracks.length - 1)]
                                  .trackName
                                  .overflow,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6
                                  ?.copyWith(
                                    color: (colors.palette ??
                                                [Theme.of(context).cardColor])
                                            .first
                                            .isDark
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: 24.0,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              [
                                if (!const ListEquality().equals(
                                        playback
                                            .tracks[playback.index.clamp(
                                                0, playback.tracks.length - 1)]
                                            .trackArtistNames
                                            .take(1)
                                            .toList(),
                                        [kUnknownArtist]) &&
                                    playback
                                        .tracks[playback.index.clamp(
                                            0, playback.tracks.length - 1)]
                                        .trackArtistNames
                                        .join('')
                                        .trim()
                                        .isNotEmpty)
                                  playback
                                      .tracks[playback.index
                                          .clamp(0, playback.tracks.length - 1)]
                                      .trackArtistNames
                                      .take(2)
                                      .join(', ')
                                      .overflow,
                                if (playback
                                            .tracks[playback.index.clamp(
                                                0, playback.tracks.length - 1)]
                                            .albumName !=
                                        kUnknownAlbum &&
                                    playback
                                        .tracks[playback.index.clamp(
                                            0, playback.tracks.length - 1)]
                                        .albumName
                                        .isNotEmpty)
                                  playback
                                      .tracks[playback.index
                                          .clamp(0, playback.tracks.length - 1)]
                                      .albumName
                                      .overflow,
                              ].join(' • '),
                              style: Theme.of(context)
                                  .textTheme
                                  .headline3
                                  ?.copyWith(
                                    color: (colors.palette ??
                                                [Theme.of(context).cardColor])
                                            .first
                                            .isDark
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: kControlsAreaHeight,
                        color: Colors.white24,
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: 44.0,
                            bottom: 16.0 + 8.0,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              const SizedBox(width: 12.0),
                              IconButton(
                                onPressed: () {
                                  if (playback.playlistLoopMode ==
                                      PlaylistLoopMode.loop) {
                                    playback.setPlaylistLoopMode(
                                      PlaylistLoopMode.none,
                                    );
                                    return;
                                  }
                                  playback.setPlaylistLoopMode(
                                    PlaylistLoopMode.values[
                                        playback.playlistLoopMode.index + 1],
                                  );
                                },
                                iconSize: 24.0,
                                color: (playback.playlistLoopMode !=
                                        PlaylistLoopMode.none)
                                    ? (colors.palette ??
                                                [Theme.of(context).cardColor])
                                            .first
                                            .isDark
                                        ? Color.lerp(
                                            Colors.black, Colors.white, 0.87)
                                        : Color.lerp(
                                            Colors.white, Colors.black, 0.87)
                                    : (colors.palette ??
                                                [Theme.of(context).cardColor])
                                            .first
                                            .isDark
                                        ? Color.lerp(
                                            Colors.black, Colors.white, 0.54)
                                        : Color.lerp(
                                            Colors.white, Colors.black, 0.54),
                                splashRadius: 24.0,
                                icon: Icon(
                                  playback.playlistLoopMode ==
                                          PlaylistLoopMode.single
                                      ? Icons.repeat_one
                                      : Icons.repeat,
                                ),
                              ),
                              Spacer(),
                              Container(
                                width: 48.0,
                                child: IconButton(
                                  onPressed: Playback.instance.previous,
                                  icon: Icon(
                                    Icons.skip_previous,
                                    color: (colors.palette ??
                                                [Theme.of(context).cardColor])
                                            .first
                                            .isDark
                                        ? Color.lerp(
                                            Colors.black, Colors.white, 0.87)
                                        : Color.lerp(
                                            Colors.white, Colors.black, 0.87),
                                    size: 28.0,
                                  ),
                                  splashRadius: 28.0,
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              Container(
                                width: 72.0,
                                child: FloatingActionButton(
                                  onPressed: Playback.instance.isPlaying
                                      ? Playback.instance.pause
                                      : Playback.instance.play,
                                  backgroundColor: (colors.palette ??
                                          [Theme.of(context).primaryColor])
                                      .last,
                                  child: AnimatedIcon(
                                    progress: playOrPause,
                                    icon: AnimatedIcons.play_pause,
                                    color: (colors.palette ??
                                                [
                                                  Theme.of(context).primaryColor
                                                ])
                                            .last
                                            .isDark
                                        ? Colors.white
                                        : Colors.black,
                                    size: 32.0,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              Container(
                                width: 48.0,
                                child: IconButton(
                                  onPressed: Playback.instance.next,
                                  icon: Icon(
                                    Icons.skip_next,
                                    color: (colors.palette ??
                                                [Theme.of(context).cardColor])
                                            .first
                                            .isDark
                                        ? Color.lerp(
                                            Colors.black, Colors.white, 0.87)
                                        : Color.lerp(
                                            Colors.white, Colors.black, 0.87),
                                    size: 28.0,
                                  ),
                                  splashRadius: 28.0,
                                ),
                              ),
                              Spacer(),
                              IconButton(
                                onPressed: playback.toggleShuffle,
                                iconSize: 24.0,
                                color: playback.isShuffling
                                    ? (colors.palette ??
                                                [Theme.of(context).cardColor])
                                            .first
                                            .isDark
                                        ? Color.lerp(
                                            Colors.black, Colors.white, 0.87)
                                        : Color.lerp(
                                            Colors.white, Colors.black, 0.87)
                                    : (colors.palette ??
                                                [Theme.of(context).cardColor])
                                            .first
                                            .isDark
                                        ? Color.lerp(
                                            Colors.black, Colors.white, 0.54)
                                        : Color.lerp(
                                            Colors.white, Colors.black, 0.54),
                                splashRadius: 24.0,
                                icon: Icon(
                                  Icons.shuffle,
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
              Consumer<Playback>(
                builder: (context, playback, _) => Positioned(
                  left: 0.0,
                  right: 0.0,
                  top: kDetailsAreaHeight - 12.0,
                  child: Column(
                    children: [
                      ScrollableSlider(
                        min: 0.0,
                        max: playback.duration.inMilliseconds.toDouble(),
                        value: playback.position.inMilliseconds
                            .clamp(
                                0, playback.duration.inMilliseconds.toDouble())
                            .toDouble(),
                        color: colors.palette?.last,
                        secondaryColor: colors.palette?.first,
                        onChanged: (value) {
                          playback.seek(
                            Duration(
                              milliseconds: value.toInt(),
                            ),
                          );
                        },
                        onScrolledUp: () {
                          if (playback.position >= playback.duration) return;
                          playback.seek(
                            playback.position + Duration(seconds: 10),
                          );
                        },
                        onScrolledDown: () {
                          if (playback.position <= Duration.zero) return;
                          playback.seek(
                            playback.position - Duration(seconds: 10),
                          );
                        },
                      ),
                      const SizedBox(height: 4.0),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24.0),
                          const SizedBox(width: 16.0),
                          Text(
                            playback.position.label,
                            style: Theme.of(context)
                                .textTheme
                                .headline3
                                ?.copyWith(
                                  color: (colors.palette ??
                                              [Theme.of(context).primaryColor])
                                          .first
                                          .isDark
                                      ? Colors.white
                                      : Colors.black,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Spacer(),
                          Text(
                            playback.duration.label,
                            style: Theme.of(context)
                                .textTheme
                                .headline3
                                ?.copyWith(
                                  color: (colors.palette ??
                                              [Theme.of(context).primaryColor])
                                          .first
                                          .isDark
                                      ? Colors.white
                                      : Colors.black,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(width: 16.0),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          builder: (context, color, child) => Miniplayer(
            controller: controller,
            elevation: 8.0,
            minHeight: kMobileNowPlayingBarHeight,
            maxHeight: MediaQuery.of(context).size.height,
            tapToCollapse: false,
            builder: (height, percentage) {
              try {
                final hidden = percentage > 0.8;
                if (MobileNowPlayingController
                        .instance.bottomNavigationBar.value !=
                    hidden) {
                  WidgetsBinding.instance.addPostFrameCallback(
                    (_) {
                      MobileNowPlayingController
                          .instance.bottomNavigationBar.value = hidden;
                    },
                  );
                }
              } catch (exception, stacktrace) {
                debugPrint(exception.toString());
                debugPrint(stacktrace.toString());
              }
              physics = percentage == 0 ? NeverScrollableScrollPhysics() : null;
              return () {
                if (Playback.instance.tracks.isEmpty) return Container();
                return Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: AnnotatedRegion<SystemUiOverlayStyle>(
                    value: SystemUiOverlayStyle(
                      statusBarColor: Colors.transparent,
                      statusBarIconBrightness: Brightness.light,
                      systemNavigationBarIconBrightness: Brightness.light,
                    ),
                    child: ListView(
                      shrinkWrap: false,
                      padding: EdgeInsets.zero,
                      physics: physics,
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
                                      Theme.of(context).primaryColor),
                              backgroundColor: (colors.palette?.last ??
                                      Theme.of(context).primaryColor)
                                  .withOpacity(0.2),
                            ),
                          ),
                        Container(
                          height: percentage == 1.0
                              ? MediaQuery.of(context).size.width +
                                          kDetailsAreaHeight +
                                          kControlsAreaHeight <
                                      MediaQuery.of(context).size.height
                                  ? MediaQuery.of(context).size.width
                                  : MediaQuery.of(context).size.height -
                                      kDetailsAreaHeight -
                                      kControlsAreaHeight
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
                                        (colors.palette?.last ??
                                                Theme.of(context).primaryColor)
                                            .withOpacity(0.2)),
                                    backgroundColor:
                                        Theme.of(context).cardColor,
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
                                                                    height: MediaQuery.of(context).size.width +
                                                                                kDetailsAreaHeight +
                                                                                kControlsAreaHeight <
                                                                            MediaQuery.of(context)
                                                                                .size
                                                                                .height
                                                                        ? MediaQuery.of(context)
                                                                            .size
                                                                            .width
                                                                        : MediaQuery.of(context).size.height -
                                                                            kDetailsAreaHeight -
                                                                            kControlsAreaHeight,
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
                                                                              right: 8.0,
                                                                              bottom: 8.0,
                                                                            ),
                                                                            child:
                                                                                IconButton(
                                                                              onPressed: () {
                                                                                controller.animateToHeight(
                                                                                  state: PanelState.MIN,
                                                                                );
                                                                              },
                                                                              color: Theme.of(context).extension<IconColors>()?.appBarDarkIconColor,
                                                                              icon: Icon(Icons.close),
                                                                              splashRadius: 24.0,
                                                                            ),
                                                                          ),
                                                                          const Spacer(),
                                                                          Container(
                                                                            padding:
                                                                                EdgeInsets.only(
                                                                              top: MediaQuery.of(context).padding.top + 8.0,
                                                                              right: 8.0,
                                                                              bottom: 8.0,
                                                                            ),
                                                                            child:
                                                                                Consumer<Collection>(
                                                                              builder: (context, collection, _) => IconButton(
                                                                                onPressed: collection.likedSongsPlaylist.tracks.contains(Playback.instance.tracks[Playback.instance.index.clamp(0, Playback.instance.tracks.length)])
                                                                                    ? () {
                                                                                        collection.playlistRemoveTrack(
                                                                                          collection.likedSongsPlaylist,
                                                                                          Playback.instance.tracks[Playback.instance.index.clamp(0, Playback.instance.tracks.length)],
                                                                                        );
                                                                                      }
                                                                                    : () {
                                                                                        collection.playlistAddTrack(
                                                                                          collection.likedSongsPlaylist,
                                                                                          Playback.instance.tracks[Playback.instance.index.clamp(0, Playback.instance.tracks.length)],
                                                                                        );
                                                                                      },
                                                                                icon: Icon(
                                                                                  collection.likedSongsPlaylist.tracks.contains(Playback.instance.tracks[Playback.instance.index.clamp(0, Playback.instance.tracks.length)]) ? Icons.thumb_up : Icons.thumb_up_outlined,
                                                                                ),
                                                                                color: Theme.of(context).extension<IconColors>()?.appBarDarkIconColor,
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
                                                                                final track = Playback.instance.tracks[Playback.instance.index.clamp(0, Playback.instance.tracks.length)];

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
                                                                                    elevation: 8.0,
                                                                                    child: Container(
                                                                                      child: Column(
                                                                                        mainAxisSize: MainAxisSize.min,
                                                                                        children: [
                                                                                          PopupMenuItem(
                                                                                            onTap: () => result = 0,
                                                                                            value: 0,
                                                                                            child: ListTile(
                                                                                              leading: Icon(Icons.equalizer),
                                                                                              title: Text(Language.instance.CONTROL_PANEL),
                                                                                            ),
                                                                                          ),
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
                                                                                          if (Lyrics.instance.current.length > 1)
                                                                                            PopupMenuItem(
                                                                                              onTap: () => result = 4,
                                                                                              value: 4,
                                                                                              child: ListTile(
                                                                                                leading: Icon(Icons.text_format),
                                                                                                title: Text(Language.instance.SHOW_LYRICS),
                                                                                              ),
                                                                                            ),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                );
                                                                                switch (result) {
                                                                                  case 0:
                                                                                    {
                                                                                      await Future.delayed(const Duration(milliseconds: 200));
                                                                                      await showDialog(
                                                                                        context: context,
                                                                                        builder: (context) => AlertDialog(
                                                                                          contentPadding: EdgeInsets.zero,
                                                                                          content: ControlPanel(
                                                                                            onPop: () {},
                                                                                          ),
                                                                                        ),
                                                                                      );
                                                                                      break;
                                                                                    }
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
                                                                                  case 4:
                                                                                    {
                                                                                      await showGeneralDialog(
                                                                                        useRootNavigator: false,
                                                                                        context: context,
                                                                                        pageBuilder: (context, animation, secondaryAnimation) {
                                                                                          return LyricsScreen();
                                                                                        },
                                                                                      );
                                                                                      break;
                                                                                    }
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
                                                                              color: Theme.of(context).extension<IconColors>()?.appBarDarkIconColor,
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
                                                              duration:
                                                                  Duration(
                                                                milliseconds:
                                                                    400,
                                                              ),
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
                                              : Consumer<Playback>(
                                                  builder:
                                                      (context, playback, _) =>
                                                          SizedBox(
                                                    child: ExtendedImage(
                                                      image: getAlbumArt(playback
                                                              .tracks[
                                                          playback.index.clamp(
                                                              0,
                                                              playback.tracks
                                                                  .length)]),
                                                      constraints:
                                                          BoxConstraints(
                                                        maxWidth: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        maxHeight:
                                                            MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width,
                                                      ),
                                                      width: percentage == 1.0
                                                          ? MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width
                                                          : height - 2.0,
                                                      height: percentage == 1.0
                                                          ? MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width
                                                          : height - 2.0,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                        ],
                                      ),
                                      if (percentage < 1.0)
                                        Expanded(
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
                                                        .headline2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ),
                                              if (!Playback
                                                  .instance
                                                  .tracks[
                                                      Playback.instance.index]
                                                  .hasNoAvailableArtists)
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
                                                          .trackArtistNames
                                                          .take(2)
                                                          .join(', ')
                                                          .overflow,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .headline3,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      if (height <
                                          MediaQuery.of(context).size.width -
                                              64.0)
                                        Opacity(
                                          opacity: (1 - percentage * 5)
                                              .clamp(0.0, 1.0),
                                          child: Container(
                                            height: 64.0,
                                            width: 64.0,
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
                          Material(
                            elevation: 4.0,
                            color: color ?? Theme.of(context).primaryColor,
                            child: child,
                          ),
                        if (height >= MediaQuery.of(context).size.width &&
                            comingUpTracks.length >= 1)
                          SubHeader(
                            Language.instance.COMING_UP,
                          ),
                        if (height >= MediaQuery.of(context).size.width &&
                            comingUpTracks.length < 1)
                          Container(
                            height: 72.0,
                            child: Center(
                              child: Text(
                                message.isNotEmpty
                                    ? message
                                    : Language.instance.NOTHING_IN_QUEUE,
                                style: Theme.of(context)
                                    .textTheme
                                    .headline3
                                    ?.copyWith(fontSize: 16.0),
                              ),
                            ),
                          ),
                        if (height >= MediaQuery.of(context).size.width)
                          ...comingUpTracks,
                      ],
                    ),
                  ),
                );
              }();
            },
          ),
        ),
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
  double _y = MobileNowPlayingController.instance.isHidden
      ? 0.0
      : kMobileNowPlayingBarHeight;

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

  void show() {
    if (Playback.instance.tracks.isEmpty) return;
    if (_y == 0.0) {
      setState(() => _y = kMobileNowPlayingBarHeight);
    }
  }

  void hide() {
    if (_y != 0.0) {
      setState(() => _y = 0.0);
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
                child: widget.index.value == 0
                    ? SpeedDial(
                        icon: Icons.add,
                        activeIcon: Icons.close,
                        spacing: 8.0,
                        heroTag: 'create-playlist-fab',
                        elevation: 8.0,
                        animationCurve: Curves.easeInOut,
                        animationDuration: const Duration(milliseconds: 200),
                        children: [
                          SpeedDialChild(
                            child: const Icon(Icons.downloading),
                            label: Language.instance.IMPORT,
                            visible: true,
                            onTap: () {
                              showModalBottomSheet(
                                isScrollControlled: true,
                                constraints: BoxConstraints(
                                  maxHeight: double.infinity,
                                ),
                                context: context,
                                elevation: 8.0,
                                useRootNavigator: true,
                                backgroundColor: Theme.of(context).cardColor,
                                builder: (context) => StatefulBuilder(
                                  builder: (context, setState) {
                                    return PlaylistImportBottomSheet();
                                  },
                                ),
                              );
                            },
                          ),
                          SpeedDialChild(
                            child: const Icon(Icons.edit),
                            label: Language.instance.CREATE,
                            visible: true,
                            onTap: () async {
                              String text = '';
                              await showModalBottomSheet(
                                isScrollControlled: true,
                                context: context,
                                elevation: 8.0,
                                useRootNavigator: true,
                                backgroundColor: Theme.of(context).cardColor,
                                builder: (context) => StatefulBuilder(
                                  builder: (context, setState) {
                                    return Container(
                                      margin: EdgeInsets.only(
                                        bottom: MediaQuery.of(context)
                                                .viewInsets
                                                .bottom -
                                            MediaQuery.of(context)
                                                .padding
                                                .bottom,
                                      ),
                                      padding: EdgeInsets.all(8.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          const SizedBox(height: 4.0),
                                          TextField(
                                            textCapitalization:
                                                TextCapitalization.words,
                                            textInputAction:
                                                TextInputAction.done,
                                            autofocus: true,
                                            onChanged: (value) => text = value,
                                            onSubmitted: (String value) async {
                                              if (value.isNotEmpty) {
                                                FocusScope.of(context)
                                                    .unfocus();
                                                await Collection.instance
                                                    .playlistCreateFromName(
                                                        value);
                                                Navigator.of(context)
                                                    .maybePop();
                                              }
                                            },
                                            decoration: InputDecoration(
                                              contentPadding:
                                                  EdgeInsets.fromLTRB(
                                                12,
                                                30,
                                                12,
                                                6,
                                              ),
                                              hintText: Language.instance
                                                  .PLAYLISTS_TEXT_FIELD_LABEL,
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Theme.of(context)
                                                      .iconTheme
                                                      .color!
                                                      .withOpacity(0.4),
                                                  width: 1.8,
                                                ),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Theme.of(context)
                                                      .iconTheme
                                                      .color!
                                                      .withOpacity(0.4),
                                                  width: 1.8,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  width: 1.8,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 4.0),
                                          ElevatedButton(
                                            onPressed: () async {
                                              if (text.isNotEmpty) {
                                                FocusScope.of(context)
                                                    .unfocus();
                                                await Collection.instance
                                                    .playlistCreateFromName(
                                                  text,
                                                );
                                                Navigator.of(context)
                                                    .maybePop();
                                              }
                                            },
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all(
                                                Theme.of(context).primaryColor,
                                              ),
                                            ),
                                            child: Text(
                                              Language.instance.CREATE
                                                  .toUpperCase(),
                                              style:
                                                  TextStyle(letterSpacing: 2.0),
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
          AnimatedContainer(
            height: _y,
            duration: Duration(milliseconds: 200),
            curve: Curves.easeInOut,
          ),
        ],
      ),
    );
  }
}

class LyricsScreen extends StatefulWidget {
  LyricsScreen({Key? key}) : super(key: key);

  @override
  State<LyricsScreen> createState() => _LyricsScreenState();
}

class _LyricsScreenState extends State<LyricsScreen> {
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
                    end: (Lyrics.instance.current.length > 1 &&
                            Configuration.instance.lyricsVisible)
                        ? 1.0
                        : 0.0,
                  ),
                  duration: Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  builder: (context, opacity, _) => Opacity(
                    opacity: opacity,
                    child: Consumer<Playback>(
                      builder: (context, playback, _) => ShaderMask(
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
                            ..lyrics = Lyrics.instance.current
                                .asMap()
                                .entries
                                .map((e) {
                              return LyricsLineModel()
                                ..mainText = e.value.words
                                ..startTime = e.value.time
                                ..endTime = e.key + 1 <
                                        Lyrics.instance.current.length
                                    ? Lyrics.instance.current[e.key + 1].time
                                    : 1 << 32;
                            }).toList(),
                          position: playback.position.inMilliseconds,
                          lyricUi: () {
                            final colors = palette.palette ??
                                [Theme.of(context).cardColor];
                            return LyricsStyle(
                              color: colors.first.isDark
                                  ? Colors.white
                                  : Colors.black,
                              primary:
                                  colors.first != Theme.of(context).cardColor
                                      ? colors.first.isDark
                                          ? Colors.white
                                          : Colors.black
                                      : (palette.palette ??
                                              [Theme.of(context).primaryColor])
                                          .last,
                            );
                          }(),
                          playing: true,
                        ),
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
