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
import 'package:provider/provider.dart';

import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/state/now_playing_launcher.dart';

class NowPlayingBar extends StatefulWidget {
  const NowPlayingBar({Key? key}) : super(key: key);

  NowPlayingBarState createState() => NowPlayingBarState();
}

class NowPlayingBarState extends State<NowPlayingBar>
    with TickerProviderStateMixin {
  late AnimationController playOrPause;
  late VoidCallback listener;
  bool showAlbumArtButton = false;

  @override
  void initState() {
    super.initState();
    playOrPause = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    listener = () {
      if (Playback.instance.isPlaying) {
        playOrPause.forward();
      } else {
        playOrPause.reverse();
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
                  elevation: 12.0,
                  color: Theme.of(context).appBarTheme.backgroundColor,
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
                                crossAxisAlignment: CrossAxisAlignment.center,
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
                                      style:
                                          Theme.of(context).textTheme.headline2,
                                    ),
                                  ),
                                ],
                              );
                            } else if (playback.tracks.isEmpty ||
                                playback.tracks.length <= playback.index &&
                                    0 > playback.index) {
                              return Container();
                            } else {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
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
                                              key: Key(
                                                  playback.index.toString()),
                                              image: getAlbumArt(
                                                playback.tracks[playback.index],
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
                                            end: showAlbumArtButton ? 1.0 : 0.0,
                                          ),
                                          duration: Duration(milliseconds: 100),
                                          curve: Curves.easeInOut,
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              onTap: () {
                                                NowPlayingLauncher
                                                    .instance.maximized = true;
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
                                          builder: (context, value, child) =>
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
                                          playback.tracks[playback.index]
                                              .trackName.overflow,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline1,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          playback.tracks[playback.index]
                                              .trackArtistNames
                                              .take(2)
                                              .join(', ')
                                              .overflow,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline3,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
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
                              child: SliderTheme(
                                data: SliderThemeData(
                                  trackHeight: 2.0,
                                  trackShape: CustomTrackShape(),
                                  thumbShape: RoundSliderThumbShape(
                                    enabledThumbRadius: 6.0,
                                    pressedElevation: 4.0,
                                    elevation: 2.0,
                                  ),
                                  overlayShape: RoundSliderOverlayShape(
                                      overlayRadius: 12.0),
                                  overlayColor: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.4),
                                  thumbColor: Theme.of(context).primaryColor,
                                  activeTrackColor:
                                      Theme.of(context).primaryColor,
                                  inactiveTrackColor:
                                      Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white.withOpacity(0.4)
                                          : Colors.black.withOpacity(0.2),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(bottom: 2.0),
                                      child: Text(
                                        playback.position.label,
                                        style: TextStyle(
                                          color: Theme.of(context).brightness ==
                                                  Brightness.dark
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
                                              max:
                                                  getPlaybackDuration(playback),
                                              value:
                                                  getPlaybackPosition(playback),
                                              onChanged: (value) {
                                                playback.seek(
                                                  Duration(
                                                    milliseconds: value.toInt(),
                                                  ),
                                                );
                                              },
                                              onScrolledUp: () {
                                                if (Playback
                                                        .instance.position >=
                                                    Playback.instance.duration)
                                                  return;
                                                playback.seek(
                                                  playback.position +
                                                      Duration(seconds: 10),
                                                );
                                              },
                                              onScrolledDown: () {
                                                if (Playback
                                                        .instance.position <=
                                                    Duration.zero) return;
                                                playback.seek(
                                                  playback.position -
                                                      Duration(seconds: 10),
                                                );
                                              },
                                            ))
                                        : Container(),
                                    SizedBox(
                                      width: 12.0,
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(bottom: 2.0),
                                      child: Text(
                                        playback.duration.label,
                                        style: TextStyle(
                                          color: Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : Colors.black,
                                          fontSize: 14.0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 8.0, bottom: 26.0),
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
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
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
                                                  color: Theme.of(context)
                                                              .brightness ==
                                                          Brightness.dark
                                                      ? Colors.white
                                                          .withOpacity(0.87)
                                                      : Colors.black87,
                                                )
                                              : null,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: playback.toggleShuffle,
                                        iconSize: 20.0,
                                        color: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white.withOpacity(0.87)
                                            : Colors.black87,
                                        splashRadius: 18.0,
                                        tooltip: Language.instance.SHUFFLE,
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
                                    iconSize: 24.0,
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
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
                                    onPressed: playback.playOrPause,
                                    elevation: 2.0,
                                    tooltip: playback.isPlaying
                                        ? Language.instance.PAUSE
                                        : Language.instance.PLAY,
                                    child: AnimatedIcon(
                                      icon: AnimatedIcons.play_pause,
                                      color: Colors.white,
                                      size: 32.0,
                                      progress: playOrPause,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: playback.isLastTrack
                                        ? null
                                        : playback.next,
                                    iconSize: 24.0,
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
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
                                          border: playback.playlistLoopMode !=
                                                  PlaylistLoopMode.none
                                              ? Border.all(
                                                  color: Theme.of(context)
                                                              .brightness ==
                                                          Brightness.dark
                                                      ? Colors.white
                                                          .withOpacity(0.87)
                                                      : Colors.black87,
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
                                            PlaylistLoopMode.values[playback
                                                    .playlistLoopMode.index +
                                                1],
                                          );
                                        },
                                        tooltip: Language.instance.REPEAT,
                                        iconSize: 20.0,
                                        color: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white.withOpacity(0.87)
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
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
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
                          child: Consumer<NowPlayingLauncher>(
                            builder: (context, nowPlayingLauncher, _) => Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: playback.tracks.isEmpty
                                      ? null
                                      : nowPlayingLauncher.toggle,
                                  iconSize: 24.0,
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.black,
                                  splashRadius: 18.0,
                                  tooltip: playback.tracks.isEmpty
                                      ? ''
                                      : nowPlayingLauncher.maximized
                                          ? Language.instance.EXIT_NOW_PLAYING
                                          : Language.instance.NOW_PLAYING,
                                  icon: Icon(
                                    nowPlayingLauncher.maximized
                                        ? Icons.expand_more
                                        : Icons.expand_less,
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
              ),
            ),
          )
        : Container();
  }
}
