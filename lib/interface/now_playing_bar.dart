/* 
 *  This file is part of Harmonoid (https://github.com/harmonoid/harmonoid).
 *  
 *  Harmonoid is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *  
 *  Harmonoid is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU General Public License for more details.
 *  
 *  You should have received a copy of the GNU General Public License
 *  along with Harmonoid. If not, see <https://www.gnu.org/licenses/>.
 * 
 *  Copyright 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
 */

import 'dart:math';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:harmonoid/state/now_playing_launcher.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/constants/language.dart';

class NowPlayingBar extends StatefulWidget {
  const NowPlayingBar({Key? key}) : super(key: key);

  NowPlayingBarState createState() => NowPlayingBarState();
}

class NowPlayingBarState extends State<NowPlayingBar>
    with TickerProviderStateMixin {
  late AnimationController playOrPause;
  late VoidCallback listener;

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
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(0.0),
                                    child: Image(
                                      image: Collection.instance.getAlbumArt(
                                          playback.tracks[playback.index]),
                                      height: 84.0,
                                      width: 84.0,
                                      fit: BoxFit.cover,
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
                                    playback.position.inMilliseconds <=
                                            playback.duration.inMilliseconds
                                        ? Container(
                                            width: 480.0,
                                            child: Slider(
                                              value: playback
                                                  .position.inMilliseconds
                                                  .toDouble(),
                                              onChanged: (value) {
                                                playback.seek(
                                                  Duration(
                                                    milliseconds: value.toInt(),
                                                  ),
                                                );
                                              },
                                              min: 0.0,
                                              max: playback
                                                  .duration.inMilliseconds
                                                  .toDouble(),
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
                                        thumbColor:
                                            Theme.of(context).primaryColor,
                                        activeTrackColor:
                                            Theme.of(context).primaryColor,
                                        inactiveTrackColor:
                                            Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? Colors.white.withOpacity(0.4)
                                                : Colors.black.withOpacity(0.2),
                                      ),
                                      child: Container(
                                        width: 84.0,
                                        child: Slider(
                                          value: playback.rate,
                                          onChanged: (value) {
                                            playback.setRate(value);
                                          },
                                          max: 2.0,
                                          min: 0.0,
                                        ),
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
                                        icon: Icon(
                                          Icons.shuffle,
                                        ),
                                      ),
                                    ],
                                  ),
                                  IconButton(
                                    onPressed: playback.previous,
                                    iconSize: 24.0,
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white.withOpacity(0.87)
                                        : Colors.black87,
                                    splashRadius: 18.0,
                                    icon: Icon(
                                      Icons.skip_previous,
                                    ),
                                  ),
                                  FloatingActionButton(
                                    onPressed: playback.playOrPause,
                                    elevation: 2.0,
                                    child: AnimatedIcon(
                                      icon: AnimatedIcons.play_pause,
                                      color: Colors.white,
                                      size: 32.0,
                                      progress: playOrPause,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: playback.next,
                                    iconSize: 24.0,
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white.withOpacity(0.87)
                                        : Colors.black87,
                                    splashRadius: 18.0,
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
                                          border: playback.playlistMode !=
                                                  PlaylistMode.none
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
                                          if (playback.playlistMode ==
                                              PlaylistMode.loop) {
                                            playback.setPlaylistMode(
                                              PlaylistMode.none,
                                            );
                                            return;
                                          }
                                          playback.setPlaylistMode(
                                            PlaylistMode.values[
                                                playback.playlistMode.index +
                                                    1],
                                          );
                                        },
                                        iconSize: 20.0,
                                        color: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white.withOpacity(0.87)
                                            : Colors.black87,
                                        splashRadius: 18.0,
                                        icon: Icon(
                                          playback.playlistMode ==
                                                  PlaylistMode.single
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
                                    icon: Icon(
                                      playback.volume == 0.0
                                          ? Icons.volume_off
                                          : Icons.volume_up,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 12.0,
                                  ),
                                  SliderTheme(
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
                                      thumbColor:
                                          Theme.of(context).primaryColor,
                                      activeTrackColor:
                                          Theme.of(context).primaryColor,
                                      inactiveTrackColor:
                                          Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white.withOpacity(0.4)
                                              : Colors.black.withOpacity(0.2),
                                    ),
                                    child: Container(
                                      width: 84.0,
                                      child: Slider(
                                        value: playback.volume,
                                        onChanged: (value) {
                                          playback.setVolume(value);
                                        },
                                        max: 100.0,
                                        min: 0.0,
                                      ),
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

extension on Duration {
  String get label {
    int minutes = inSeconds ~/ 60;
    String seconds = inSeconds - (minutes * 60) > 9
        ? '${inSeconds - (minutes * 60)}'
        : '0${inSeconds - (minutes * 60)}';
    return '$minutes:$seconds';
  }
}

class CustomTrackShape extends RoundedRectSliderTrackShape {
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight!;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}
