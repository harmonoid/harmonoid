/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///
import 'dart:ui';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/interface/collection/track.dart';
import 'package:harmonoid/state/now_playing_color_palette.dart';
import 'package:harmonoid/utils/theme.dart';
import 'package:provider/provider.dart';
import 'package:miniplayer/miniplayer.dart';
import 'package:extended_image/extended_image.dart';

import 'package:harmonoid/core/playback.dart';
import 'package:media_library/media_library.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/dimensions.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/state/mobile_now_playing_controller.dart';

const kDetailsAreaHeight = 96.0;
const kControlsAreaHeight = 136.0;

class MiniNowPlayingBar extends StatefulWidget {
  MiniNowPlayingBar({Key? key}) : super(key: key);

  @override
  State<MiniNowPlayingBar> createState() => MiniNowPlayingBarState();
}

class MiniNowPlayingBarState extends State<MiniNowPlayingBar>
    with TickerProviderStateMixin {
  double _yOffset = 0.0;

  bool get isHidden => _yOffset != 0.0;

  void show() {
    if (Playback.instance.tracks.isEmpty) return;
    if (_yOffset != 0.0) {
      setState(() => _yOffset = 0.0);
    }
  }

  void hide() {
    if (_yOffset == 0.0) {
      setState(
        () => _yOffset = (kMobileNowPlayingBarHeight + 4.0) /
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
  late VoidCallback listener;
  int index = Playback.instance.index;
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
    _yOffset = (kMobileNowPlayingBarHeight + 4.0) /
        (window.physicalSize.height -
            window.padding.top -
            window.padding.bottom) *
        window.devicePixelRatio;
    playOrPause = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    listener = () async {
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
        try {
          await precacheImage(
            getAlbumArt(
              Playback.instance.tracks[index.clamp(
                0,
                Playback.instance.tracks.length,
              )],
            ),
            context,
          );
          // Precache adjacent album arts for smoother swipe transitions to the next/previous track.
          await Future.wait([
            precacheImage(
              getAlbumArt(
                Playback.instance.tracks[(index - 1).clamp(
                  0,
                  Playback.instance.tracks.length,
                )],
              ),
              context,
            ),
            precacheImage(
              getAlbumArt(
                Playback.instance.tracks[(index + 1).clamp(
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
        setState(() => index = Playback.instance.index);
      }
      final track = Playback.instance.tracks[Playback.instance.index];
      if (this.track != track ||
          comingUpTracks.length.compareTo(Playback.instance.tracks.length) !=
              0) {
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
    };
    Playback.instance.addListener(listener);
  }

  @override
  void dispose() {
    Playback.instance.removeListener(listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NowPlayingColorPalette>(
      builder: (context, colors, _) => AnimatedSlide(
        offset: Offset(0, _yOffset),
        duration: Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: TweenAnimationBuilder<Color?>(
          tween: ColorTween(
            begin: Theme.of(context).cardColor,
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
                            top: 48.0,
                            bottom: 24.0,
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
                                          [Theme.of(context).cardColor])
                                      .last,
                                  child: AnimatedIcon(
                                    progress: playOrPause,
                                    icon: AnimatedIcons.play_pause,
                                    color: (colors.palette ??
                                                [Theme.of(context).cardColor])
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
                          const SizedBox(height: 32.0),
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
                          height: height < MediaQuery.of(context).size.width
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
                                                    child: PageView(
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      controller:
                                                          pageController,
                                                      onPageChanged: (value) =>
                                                          Playback.instance
                                                              .jump(value),
                                                      children:
                                                          Playback
                                                              .instance.tracks
                                                              .map(
                                                                (e) => Stack(
                                                                  children: [
                                                                    SizedBox
                                                                        .square(
                                                                      child:
                                                                          ExtendedImage(
                                                                        image:
                                                                            getAlbumArt(e),
                                                                        width: MediaQuery.of(context)
                                                                            .size
                                                                            .width,
                                                                        height: MediaQuery.of(context).size.width + kDetailsAreaHeight + kControlsAreaHeight + kBottomNavigationBarHeight < MediaQuery.of(context).size.height
                                                                            ? MediaQuery.of(context)
                                                                                .size
                                                                                .width
                                                                            : MediaQuery.of(context).size.height -
                                                                                kDetailsAreaHeight -
                                                                                kControlsAreaHeight -
                                                                                kBottomNavigationBarHeight,
                                                                        fit: BoxFit
                                                                            .cover,
                                                                      ),
                                                                    ),
                                                                    TweenAnimationBuilder<
                                                                        double>(
                                                                      tween: Tween<
                                                                              double>(
                                                                          begin:
                                                                              0,
                                                                          end:
                                                                              1.0),
                                                                      child:
                                                                          Stack(
                                                                        children: [
                                                                          Container(
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              gradient: LinearGradient(
                                                                                colors: [
                                                                                  Colors.black38,
                                                                                  Colors.transparent,
                                                                                ],
                                                                                stops: [
                                                                                  0.0,
                                                                                  0.5,
                                                                                ],
                                                                                begin: Alignment.topCenter,
                                                                                end: Alignment.bottomCenter,
                                                                              ),
                                                                            ),
                                                                            height: MediaQuery.of(context).size.width + kDetailsAreaHeight + kControlsAreaHeight + kBottomNavigationBarHeight < MediaQuery.of(context).size.height
                                                                                ? MediaQuery.of(context).size.width
                                                                                : MediaQuery.of(context).size.height - kDetailsAreaHeight - kControlsAreaHeight - kBottomNavigationBarHeight,
                                                                            width:
                                                                                MediaQuery.of(context).size.width,
                                                                          ),
                                                                          Positioned
                                                                              .fill(
                                                                            child:
                                                                                Material(
                                                                              color: Colors.transparent,
                                                                              child: Row(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                                children: [
                                                                                  Container(
                                                                                    padding: EdgeInsets.only(
                                                                                      top: MediaQuery.of(context).padding.top + 8.0,
                                                                                      left: 8.0,
                                                                                      right: 8.0,
                                                                                      bottom: 8.0,
                                                                                    ),
                                                                                    child: IconButton(
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
                                                                                    padding: EdgeInsets.only(
                                                                                      top: MediaQuery.of(context).padding.top + 8.0,
                                                                                      left: 8.0,
                                                                                      right: 8.0,
                                                                                      bottom: 8.0,
                                                                                    ),
                                                                                    child: IconButton(
                                                                                      onPressed: () async {
                                                                                        final position = RelativeRect.fromRect(
                                                                                          Offset(
                                                                                                MediaQuery.of(context).size.width - tileMargin - 64.0,
                                                                                                MediaQuery.of(context).padding.top + 64.0,
                                                                                              ) &
                                                                                              Size(160.0, 160.0),
                                                                                          Rect.fromLTWH(
                                                                                            0,
                                                                                            0,
                                                                                            MediaQuery.of(context).size.width,
                                                                                            MediaQuery.of(context).size.height,
                                                                                          ),
                                                                                        );
                                                                                        final result = await showMenu<int>(
                                                                                          context: context,
                                                                                          position: position,
                                                                                          elevation: 4.0,
                                                                                          items: [
                                                                                            PopupMenuItem(
                                                                                              value: 0,
                                                                                              child: ListTile(
                                                                                                leading: Icon(Icons.file_open),
                                                                                                title: Text(Language.instance.OPEN_FILE_OR_URL),
                                                                                              ),
                                                                                            ),
                                                                                            PopupMenuItem(
                                                                                              value: 1,
                                                                                              child: ListTile(
                                                                                                leading: Icon(Icons.code),
                                                                                                title: Text(Language.instance.READ_METADATA),
                                                                                              ),
                                                                                            ),
                                                                                            PopupMenuItem(
                                                                                              value: 2,
                                                                                              child: ListTile(
                                                                                                leading: Icon(Icons.settings),
                                                                                                title: Text(Language.instance.SETTING),
                                                                                              ),
                                                                                            ),
                                                                                            PopupMenuItem(
                                                                                              value: 3,
                                                                                              child: ListTile(
                                                                                                leading: Icon(Icons.info),
                                                                                                title: Text(Language.instance.ABOUT_TITLE),
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        );
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
                                                                        opacity:
                                                                            value,
                                                                        child:
                                                                            child,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              )
                                                              .toList(),
                                                    ),
                                                  );
                                                }()
                                              : Consumer<Playback>(
                                                  builder:
                                                      (context, playback, _) =>
                                                          SizedBox.square(
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
                                        const SizedBox(width: 16.0),
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
                                              if (!Playback
                                                  .instance
                                                  .tracks[
                                                      Playback.instance.index]
                                                  .hasNoAvailableArtists)
                                                Opacity(
                                                  opacity: (1 - percentage * 5)
                                                      .clamp(0.0, 1.0),
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
                                            ],
                                          ),
                                        ),
                                      if (height < 200.0)
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
                                Language.instance.NOTHING_IN_QUEUE,
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
  MiniNowPlayingBarRefreshCollectionButton({Key? key}) : super(key: key);

  @override
  State<MiniNowPlayingBarRefreshCollectionButton> createState() =>
      MiniNowPlayingBarRefreshCollectionButtonState();
}

class MiniNowPlayingBarRefreshCollectionButtonState
    extends State<MiniNowPlayingBarRefreshCollectionButton> {
  double _yOffset = MobileNowPlayingController.instance.isHidden
      ? 0.0
      : kMobileNowPlayingBarHeight;

  void show() {
    if (Playback.instance.tracks.isEmpty) return;
    if (_yOffset == 0.0) {
      setState(() => _yOffset = kMobileNowPlayingBarHeight);
    }
  }

  void hide() {
    if (_yOffset != 0.0) {
      setState(() => _yOffset = 0.0);
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
                child: RefreshCollectionButton(
                  color: color as Color?,
                ),
              ),
            ),
          ),
          AnimatedContainer(
            height: _yOffset,
            duration: Duration(milliseconds: 200),
            curve: Curves.easeInOut,
          ),
        ],
      ),
    );
  }
}

extension on Color {
  bool get isDark => (0.299 * red) + (0.587 * green) + (0.114 * blue) < 128.0;
}
