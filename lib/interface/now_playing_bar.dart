/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'dart:math';
import 'dart:core';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/state/desktop_now_playing_controller.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/models/media.dart';
import 'package:harmonoid/utils/dimensions.dart';

class NowPlayingBar extends StatefulWidget {
  const NowPlayingBar({Key? key}) : super(key: key);

  NowPlayingBarState createState() => NowPlayingBarState();
}

class NowPlayingBarState extends State<NowPlayingBar>
    with TickerProviderStateMixin {
  late AnimationController playOrPause;
  late VoidCallback listener;
  Iterable<Color>? palette;
  List<Widget> fills = [];
  Track? track;
  bool isShuffling = Playback.instance.isShuffling;
  bool showAlbumArtButton = false;

  @override
  void initState() {
    super.initState();
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
      if (!Configuration.instance.dynamicNowPlayingBarColoring ||
          Playback.instance.index < 0 ||
          Playback.instance.index >= Playback.instance.tracks.length) {
        return;
      }
      final track = Playback.instance.tracks[Playback.instance.index];
      if (this.track != track) {
        this.track = track;
        // Shuffling seems to scramble `palette_generator` stuff, so avoiding it explicitly.
        if (isShuffling == Playback.instance.isShuffling) {
          final result = await PaletteGenerator.fromImageProvider(
              getAlbumArt(track, small: true));
          palette = result.colors;
          fills.add(
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0.0, end: 40.0),
              duration: Duration(milliseconds: 800),
              onEnd: () {
                if (fills.length > 2) {
                  fills.removeAt(0);
                }
              },
              child: Container(
                height: kDesktopNowPlayingBarHeight,
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.center,
                child: ClipRect(
                  child: Container(
                    height: kDesktopNowPlayingBarHeight,
                    width: kDesktopNowPlayingBarHeight,
                    decoration: BoxDecoration(
                      color: palette == null
                          ? Theme.of(context).cardColor
                          : palette!.first.withOpacity(1.0),
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
        }
        isShuffling = Playback.instance.isShuffling;
      }
    };
    Playback.instance.addListener(listener);
  }

  @override
  void dispose() {
    Playback.instance.removeListener(listener);
    super.dispose();
  }

  double getPlaybackDuration(Playback playback) =>
      playback.duration.inMilliseconds.toDouble();

  double getPlaybackPosition(Playback playback) {
    var duration = getPlaybackDuration(playback);
    var position = playback.position.inMilliseconds.toDouble();
    if (position > duration) return duration;
    if (duration < 0 || position < 0) return 0;
    return position;
  }

  @override
  Widget build(BuildContext context) {
    return isDesktop
        ? Consumer<Playback>(
            builder: (context, playback, _) => ClipRect(
              clipBehavior: Clip.antiAlias,
              child: Container(
                padding: EdgeInsets.only(top: 8.0),
                child: Material(
                  clipBehavior: Clip.antiAlias,
                  color: Colors.transparent,
                  elevation: 12.0,
                  child: Stack(
                    children: [
                      ...fills,
                      if (fills.isEmpty)
                        Container(
                          height: kDesktopNowPlayingBarHeight,
                          width: MediaQuery.of(context).size.width,
                          alignment: Alignment.center,
                          color: Theme.of(context).cardColor,
                        ),
                      Material(
                        clipBehavior: Clip.antiAlias,
                        color: Colors.transparent,
                        child: Container(
                          height: 84.0,
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: () {
                                  if (playback.isBuffering) {
                                    return Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: 24.0,
                                        ),
                                        Container(
                                          height: 24.0,
                                          width: 24.0,
                                          child: CircularProgressIndicator(
                                            valueColor: AlwaysStoppedAnimation(
                                              Theme.of(context).primaryColor,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 24.0,
                                        ),
                                        Expanded(
                                          child: Text(
                                            Language.instance.BUFFERING,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline2,
                                          ),
                                        ),
                                      ],
                                    );
                                  } else if (playback.tracks.isEmpty ||
                                      playback.tracks.length <=
                                              playback.index &&
                                          0 > playback.index) {
                                    return Container();
                                  } else {
                                    return Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        MouseRegion(
                                          onEnter: (e) {
                                            setState(() {
                                              showAlbumArtButton = true;
                                            });
                                          },
                                          onExit: (e) {
                                            setState(() {
                                              showAlbumArtButton = false;
                                            });
                                          },
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(0.0),
                                                child: AnimatedSwitcher(
                                                  duration: const Duration(
                                                      milliseconds: 300),
                                                  transitionBuilder:
                                                      (child, animation) =>
                                                          FadeTransition(
                                                    opacity: animation,
                                                    child: child,
                                                  ),
                                                  child: ExtendedImage(
                                                    key: Key(playback.index
                                                        .toString()),
                                                    image: getAlbumArt(
                                                      playback.tracks[
                                                          playback.index.clamp(
                                                              0,
                                                              playback.tracks
                                                                      .length -
                                                                  1)],
                                                      small: true,
                                                    ),
                                                    height: 84.0,
                                                    width: 84.0,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              TweenAnimationBuilder(
                                                tween: Tween<double>(
                                                  begin: 0.0,
                                                  end: showAlbumArtButton
                                                      ? 1.0
                                                      : 0.0,
                                                ),
                                                duration:
                                                    Duration(milliseconds: 100),
                                                curve: Curves.easeInOut,
                                                child: Material(
                                                  color: Colors.transparent,
                                                  child: InkWell(
                                                    onTap: () {
                                                      DesktopNowPlayingController
                                                          .instance
                                                          .maximize();
                                                    },
                                                    child: Container(
                                                      color: Colors.black38,
                                                      height: 84.0,
                                                      width: 84.0,
                                                      child: Icon(
                                                        Icons.image,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                builder:
                                                    (context, value, child) =>
                                                        Opacity(
                                                  opacity: value as double,
                                                  child: child,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10.0,
                                        ),
                                        Expanded(
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
                                                    .headline1
                                                    ?.copyWith(
                                                      color:
                                                          (palette ??
                                                                      [
                                                                        Theme.of(context)
                                                                            .cardColor
                                                                      ])
                                                                  .first
                                                                  .isDark
                                                              ? Colors.white
                                                              : Colors.black,
                                                    ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                playback
                                                    .tracks[playback.index
                                                        .clamp(
                                                            0,
                                                            playback.tracks
                                                                    .length -
                                                                1)]
                                                    .trackArtistNames
                                                    .take(2)
                                                    .join(', ')
                                                    .overflow,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline3
                                                    ?.copyWith(
                                                      color:
                                                          (palette ??
                                                                      [
                                                                        Theme.of(context)
                                                                            .cardColor
                                                                      ])
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
                                        SizedBox(
                                          width: 10.0,
                                        ),
                                      ],
                                    );
                                  }
                                }(),
                              ),
                              Stack(
                                alignment: Alignment.bottomCenter,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(
                                      top: 54.0,
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(bottom: 2.0),
                                          child: Text(
                                            playback.position.label,
                                            style: TextStyle(
                                              color: (palette ??
                                                          [
                                                            Theme.of(context)
                                                                .cardColor
                                                          ])
                                                      .first
                                                      .isDark
                                                  ? Colors.white
                                                  : Colors.black,
                                              fontSize: 14.0,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 12.0,
                                        ),
                                        getPlaybackPosition(playback) <=
                                                getPlaybackDuration(playback)
                                            ? Container(
                                                width: 480.0,
                                                child: ScrollableSlider(
                                                  min: 0.0,
                                                  max: getPlaybackDuration(
                                                      playback),
                                                  value: getPlaybackPosition(
                                                      playback),
                                                  color: palette?.last,
                                                  secondaryColor:
                                                      palette?.first,
                                                  onChanged: (value) {
                                                    playback.seek(
                                                      Duration(
                                                        milliseconds:
                                                            value.toInt(),
                                                      ),
                                                    );
                                                  },
                                                  onScrolledUp: () {
                                                    if (Playback.instance
                                                            .position >=
                                                        Playback.instance
                                                            .duration) return;
                                                    playback.seek(
                                                      playback.position +
                                                          Duration(seconds: 10),
                                                    );
                                                  },
                                                  onScrolledDown: () {
                                                    if (Playback.instance
                                                            .position <=
                                                        Duration.zero) return;
                                                    playback.seek(
                                                      playback.position -
                                                          Duration(seconds: 10),
                                                    );
                                                  },
                                                ),
                                              )
                                            : Container(),
                                        SizedBox(
                                          width: 12.0,
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(bottom: 2.0),
                                          child: Text(
                                            playback.duration.label,
                                            style: TextStyle(
                                              color: (palette ??
                                                          [
                                                            Theme.of(context)
                                                                .cardColor
                                                          ])
                                                      .first
                                                      .isDark
                                                  ? Colors.white
                                                  : Colors.black,
                                              fontSize: 14.0,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    margin:
                                        EdgeInsets.only(top: 8.0, bottom: 26.0),
                                    child: Row(
                                      children: [
                                        Transform.rotate(
                                          angle: pi,
                                          child: Container(
                                            width: 84.0,
                                            child: ScrollableSlider(
                                              min: 0.0,
                                              max: 2.0,
                                              value: playback.rate,
                                              color: palette?.last,
                                              secondaryColor: palette?.first,
                                              onScrolledUp: () {
                                                playback.setRate(
                                                  (playback.rate + 0.05)
                                                      .clamp(0.0, 2.0),
                                                );
                                              },
                                              onScrolledDown: () {
                                                playback.setRate(
                                                  (playback.rate - 0.05)
                                                      .clamp(0.0, 2.0),
                                                );
                                              },
                                              onChanged: (value) {
                                                playback.setRate(value);
                                              },
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 12.0,
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            playback.setRate(1.0);
                                          },
                                          iconSize: 20.0,
                                          color: (palette ??
                                                      [
                                                        Theme.of(context)
                                                            .cardColor
                                                      ])
                                                  .first
                                                  .isDark
                                              ? Colors.white.withOpacity(0.87)
                                              : Colors.black87,
                                          splashRadius: 18.0,
                                          tooltip: Language.instance.SPEED,
                                          icon: Icon(
                                            Icons.speed,
                                          ),
                                        ),
                                        Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Container(
                                              height: 32.0,
                                              width: 32.0,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
                                                border: playback.isShuffling
                                                    ? Border.all(
                                                        width: 1.6,
                                                        color: (palette ??
                                                                    [
                                                                      Theme.of(
                                                                              context)
                                                                          .cardColor
                                                                    ])
                                                                .first
                                                                .isDark
                                                            ? Colors.white
                                                                .withOpacity(
                                                                    0.87)
                                                            : Colors.black87,
                                                      )
                                                    : null,
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: playback.toggleShuffle,
                                              iconSize: 20.0,
                                              color: (palette ??
                                                          [
                                                            Theme.of(context)
                                                                .cardColor
                                                          ])
                                                      .first
                                                      .isDark
                                                  ? Colors.white
                                                      .withOpacity(0.87)
                                                  : Colors.black87,
                                              splashRadius: 18.0,
                                              tooltip:
                                                  Language.instance.SHUFFLE,
                                              icon: Icon(
                                                Icons.shuffle,
                                              ),
                                            ),
                                          ],
                                        ),
                                        IconButton(
                                          onPressed: playback.isFirstTrack
                                              ? null
                                              : playback.previous,
                                          disabledColor: (palette ??
                                                      [
                                                        Theme.of(context)
                                                            .cardColor
                                                      ])
                                                  .first
                                                  .isDark
                                              ? Colors.white.withOpacity(0.45)
                                              : Colors.black45,
                                          iconSize: 24.0,
                                          color: (palette ??
                                                      [
                                                        Theme.of(context)
                                                            .cardColor
                                                      ])
                                                  .first
                                                  .isDark
                                              ? Colors.white.withOpacity(0.87)
                                              : Colors.black87,
                                          splashRadius: 18.0,
                                          tooltip: Language.instance.PREVIOUS,
                                          mouseCursor: SystemMouseCursors.click,
                                          icon: Icon(
                                            Icons.skip_previous,
                                          ),
                                        ),
                                        FloatingActionButton(
                                          foregroundColor: (palette ??
                                                      [
                                                        Theme.of(context)
                                                            .primaryColor
                                                      ])
                                                  .last
                                                  .isDark
                                              ? Colors.white
                                              : Color(0xFF212121),
                                          backgroundColor: (palette ??
                                                  [
                                                    Theme.of(context)
                                                        .primaryColor
                                                  ])
                                              .last,
                                          onPressed: playback.playOrPause,
                                          elevation: 2.0,
                                          tooltip: playback.isPlaying
                                              ? Language.instance.PAUSE
                                              : Language.instance.PLAY,
                                          child: AnimatedIcon(
                                            icon: AnimatedIcons.play_pause,
                                            size: 32.0,
                                            progress: playOrPause,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: playback.isLastTrack
                                              ? null
                                              : playback.next,
                                          iconSize: 24.0,
                                          disabledColor: (palette ??
                                                      [
                                                        Theme.of(context)
                                                            .cardColor
                                                      ])
                                                  .first
                                                  .isDark
                                              ? Colors.white.withOpacity(0.45)
                                              : Colors.black45,
                                          color: (palette ??
                                                      [
                                                        Theme.of(context)
                                                            .cardColor
                                                      ])
                                                  .first
                                                  .isDark
                                              ? Colors.white.withOpacity(0.87)
                                              : Colors.black87,
                                          splashRadius: 18.0,
                                          tooltip: Language.instance.NEXT,
                                          mouseCursor: SystemMouseCursors.click,
                                          icon: Icon(
                                            Icons.skip_next,
                                          ),
                                        ),
                                        Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Container(
                                              height: 32.0,
                                              width: 32.0,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
                                                border:
                                                    playback.playlistLoopMode !=
                                                            PlaylistLoopMode
                                                                .none
                                                        ? Border.all(
                                                            width: 1.6,
                                                            color: (palette ??
                                                                        [
                                                                          Theme.of(context)
                                                                              .cardColor
                                                                        ])
                                                                    .first
                                                                    .isDark
                                                                ? Colors.white
                                                                    .withOpacity(
                                                                        0.87)
                                                                : Colors
                                                                    .black87,
                                                          )
                                                        : null,
                                              ),
                                            ),
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
                                                      playback.playlistLoopMode
                                                              .index +
                                                          1],
                                                );
                                              },
                                              tooltip: Language.instance.REPEAT,
                                              iconSize: 20.0,
                                              color: (palette ??
                                                          [
                                                            Theme.of(context)
                                                                .cardColor
                                                          ])
                                                      .first
                                                      .isDark
                                                  ? Colors.white
                                                      .withOpacity(0.87)
                                                  : Colors.black87,
                                              splashRadius: 18.0,
                                              icon: Icon(
                                                playback.playlistLoopMode ==
                                                        PlaylistLoopMode.single
                                                    ? Icons.repeat_one
                                                    : Icons.repeat,
                                              ),
                                            ),
                                          ],
                                        ),
                                        IconButton(
                                          onPressed: playback.toggleMute,
                                          iconSize: 20.0,
                                          color: (palette ??
                                                      [
                                                        Theme.of(context)
                                                            .cardColor
                                                      ])
                                                  .first
                                                  .isDark
                                              ? Colors.white.withOpacity(0.87)
                                              : Colors.black87,
                                          splashRadius: 18.0,
                                          tooltip: playback.isMuted
                                              ? Language.instance.UNMUTE
                                              : Language.instance.MUTE,
                                          icon: Icon(
                                            playback.volume == 0.0
                                                ? Icons.volume_off
                                                : Icons.volume_up,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 12.0,
                                        ),
                                        Container(
                                          width: 84.0,
                                          child: ScrollableSlider(
                                            min: 0,
                                            max: 100.0,
                                            value: playback.volume,
                                            color: palette?.last,
                                            secondaryColor: palette?.first,
                                            onScrolledUp: () {
                                              playback.setVolume(
                                                (playback.volume + 5.0)
                                                    .clamp(0.0, 100.0),
                                              );
                                            },
                                            onScrolledDown: () {
                                              playback.setVolume(
                                                (playback.volume - 5.0)
                                                    .clamp(0.0, 100.0),
                                              );
                                            },
                                            onChanged: (value) {
                                              playback.setVolume(value);
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Expanded(
                                child: Consumer<DesktopNowPlayingController>(
                                  builder: (context,
                                          desktopNowPlayingController, _) =>
                                      Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        onPressed: playback.tracks.isEmpty
                                            ? null
                                            : desktopNowPlayingController
                                                .toggle,
                                        iconSize: 24.0,
                                        color: (palette ??
                                                    [
                                                      Theme.of(context)
                                                          .cardColor
                                                    ])
                                                .first
                                                .isDark
                                            ? Colors.white
                                            : Color(0xFF212121),
                                        splashRadius: 18.0,
                                        tooltip: playback.tracks.isEmpty
                                            ? ''
                                            : desktopNowPlayingController
                                                    .isHidden
                                                ? Language.instance.NOW_PLAYING
                                                : Language
                                                    .instance.EXIT_NOW_PLAYING,
                                        icon: Icon(
                                          desktopNowPlayingController.isHidden
                                              ? Icons.expand_less
                                              : Icons.expand_more,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 12.0,
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
          )
        : Container();
  }
}

extension on Color {
  bool get isDark => (0.299 * red) + (0.587 * green) + (0.114 * blue) < 128.0;
}
