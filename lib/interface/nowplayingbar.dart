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
 *  Copyright 2020-2021, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
 */

import 'dart:math';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/interface/changenotifiers.dart';

class NowPlayingBar extends StatelessWidget {
  final void Function()? launch;
  final void Function()? exit;
  NowPlayingBar({Key? key, this.launch, this.exit}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    if (HORIZONTAL_BREAKPOINT >= MediaQuery.of(context).size.width.normalized)
      return Consumer<NowPlayingController>(
        builder: (context, nowPlaying, _) => Consumer<NowPlayingBarController>(
          builder: (context, container, _) => AnimatedContainer(
            duration: Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            height: container.height,
            color: Theme.of(context).appBarTheme.backgroundColor,
            child: SingleChildScrollView(
              child: (nowPlaying.index != null &&
                      nowPlaying.tracks.length >
                          (nowPlaying.index ?? double.infinity) &&
                      0 <= (nowPlaying.index ?? double.infinity))
                  ? Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          this.launch?.call();
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 2.0,
                              width:
                                  MediaQuery.of(context).size.width.normalized *
                                      nowPlaying.position.inMilliseconds /
                                      nowPlaying.duration.inMilliseconds,
                              color: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Colors.black
                                  : Colors.white,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                nowPlaying.tracks[nowPlaying.index!]
                                            .networkAlbumArt !=
                                        null
                                    ? Image.network(
                                        nowPlaying.tracks[nowPlaying.index!]
                                            .networkAlbumArt!,
                                        height: 70.0,
                                        width: 70.0,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.file(
                                        nowPlaying
                                            .tracks[nowPlaying.index!].albumArt,
                                        height: 70.0,
                                        width: 70.0,
                                        fit: BoxFit.cover,
                                      ),
                                SizedBox(
                                  width: 12.0,
                                ),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        nowPlaying.tracks[nowPlaying.index!]
                                                .trackName ??
                                            '',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline1,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        nowPlaying.tracks[nowPlaying.index!]
                                                .trackArtistNames
                                                ?.join(', ') ??
                                            '',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline5,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        '(${nowPlaying.tracks[nowPlaying.index!].year ?? 'Unknown Year'})',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline5,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: Playback.back,
                                  iconSize: 24.0,
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.black,
                                  splashRadius: 18.0,
                                  icon: Icon(
                                    Icons.skip_previous,
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white.withOpacity(0.8)
                                          : Colors.black.withOpacity(0.8),
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(32.0),
                                  ),
                                  child: IconButton(
                                    onPressed: Playback.playOrPause,
                                    iconSize: 32.0,
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black,
                                    splashRadius: 24.0,
                                    icon: Icon(
                                      nowPlaying.isPlaying
                                          ? Icons.pause_rounded
                                          : Icons.play_arrow_rounded,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: Playback.next,
                                  iconSize: 24.0,
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.black,
                                  splashRadius: 18.0,
                                  icon: Icon(
                                    Icons.skip_next,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  : Container(),
            ),
          ),
        ),
      );
    return Consumer<NowPlayingController>(
      builder: (context, nowPlaying, _) => Container(
        height: 84.0,
        decoration: BoxDecoration(
          color: Theme.of(context).appBarTheme.backgroundColor,
          border: Border(
            top: BorderSide(
                color: Theme.of(context).dividerColor.withOpacity(0.12)),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: !nowPlaying.isBuffering
                  ? ((nowPlaying.index != null &&
                          nowPlaying.tracks.length >
                              (nowPlaying.index ?? double.infinity) &&
                          0 <= (nowPlaying.index ?? double.infinity) &&
                          HORIZONTAL_BREAKPOINT <
                              MediaQuery.of(context).size.width.normalized)
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 10.0,
                            ),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: nowPlaying.tracks[nowPlaying.index!]
                                          .networkAlbumArt ==
                                      null
                                  ? Image.file(
                                      nowPlaying
                                          .tracks[nowPlaying.index!].albumArt,
                                      height: 64.0,
                                      width: 64.0,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.network(
                                      nowPlaying.tracks[nowPlaying.index!]
                                          .networkAlbumArt!,
                                      height: 64.0,
                                      width: 64.0,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                            SizedBox(
                              width: 10.0,
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    nowPlaying.tracks[nowPlaying.index!]
                                            .trackName ??
                                        '',
                                    style:
                                        Theme.of(context).textTheme.headline1,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    nowPlaying.tracks[nowPlaying.index!]
                                            .trackArtistNames
                                            ?.join(', ') ??
                                        '',
                                    style:
                                        Theme.of(context).textTheme.headline5,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '(${nowPlaying.tracks[nowPlaying.index!].year ?? 'Unknown Year'})',
                                    style:
                                        Theme.of(context).textTheme.headline5,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : (nowPlaying.tracks.isEmpty
                          ? Container()
                          : Row(
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
                                    nowPlaying.state,
                                    style:
                                        Theme.of(context).textTheme.headline2,
                                  ),
                                ),
                              ],
                            )))
                  : Container(
                      alignment: Alignment.centerLeft,
                      child: Row(
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
                              nowPlaying.state,
                              style: Theme.of(context).textTheme.headline2,
                            ),
                          ),
                        ],
                      ),
                    ),
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
                      trackHeight: 4.0,
                      trackShape: CustomTrackShape(),
                      thumbShape: RoundSliderThumbShape(
                        enabledThumbRadius: 2.0,
                        pressedElevation: 0.0,
                        elevation: 0.0,
                      ),
                      overlayColor: Colors.transparent,
                      thumbColor: Theme.of(context).primaryColor,
                      activeTrackColor: Theme.of(context).primaryColor,
                      inactiveTrackColor:
                          Theme.of(context).brightness == Brightness.dark
                              ? Colors.white.withOpacity(0.4)
                              : Colors.black.withOpacity(0.4),
                    ),
                    child: Row(
                      children: [
                        Container(
                          margin: EdgeInsets.only(bottom: 2.0),
                          child: Text(
                            nowPlaying.position.label,
                            style: TextStyle(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 12.0,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 12.0,
                        ),
                        Container(
                          width: 480.0,
                          child: nowPlaying.position.inMilliseconds <=
                                  nowPlaying.duration.inMilliseconds
                              ? Slider(
                                  value: nowPlaying.position.inMilliseconds
                                      .toDouble(),
                                  onChanged: (value) {
                                    Playback.seek(
                                      Duration(
                                        milliseconds: value.toInt(),
                                      ),
                                    );
                                  },
                                  max: nowPlaying.duration.inMilliseconds
                                      .toDouble(),
                                  min: 0.0,
                                )
                              : Container(),
                        ),
                        SizedBox(
                          width: 12.0,
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 2.0),
                          child: Text(
                            nowPlaying.duration.label,
                            style: TextStyle(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 12.0,
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
                            trackHeight: 4.0,
                            trackShape: CustomTrackShape(),
                            thumbShape: RoundSliderThumbShape(
                              enabledThumbRadius: 2.0,
                              pressedElevation: 0.0,
                              elevation: 0.0,
                            ),
                            overlayColor: Colors.transparent,
                            thumbColor: Theme.of(context).primaryColor,
                            activeTrackColor: Theme.of(context).primaryColor,
                            inactiveTrackColor:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white.withOpacity(0.4)
                                    : Colors.black.withOpacity(0.4),
                          ),
                          child: Container(
                            width: 84.0,
                            child: Slider(
                              value: nowPlaying.rate,
                              onChanged: (value) {
                                Playback.setRate(value);
                                nowPlaying.rate = player.rate;
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
                          Playback.setRate(1.0);
                          nowPlaying.rate = player.rate;
                        },
                        iconSize: 20.0,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
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
                              borderRadius: BorderRadius.circular(20.0),
                              border: nowPlaying.isShuffling
                                  ? Border.all(
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : Colors.black,
                                    )
                                  : null,
                            ),
                          ),
                          IconButton(
                            onPressed: Playback.shuffle,
                            iconSize: 20.0,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                            splashRadius: 18.0,
                            icon: Icon(
                              Icons.shuffle,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: Playback.back,
                        iconSize: 24.0,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                        splashRadius: 18.0,
                        icon: Icon(
                          Icons.skip_previous,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white.withOpacity(0.8)
                                    : Colors.black.withOpacity(0.8),
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(32.0),
                        ),
                        child: IconButton(
                          onPressed: Playback.playOrPause,
                          iconSize: 32.0,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                          splashRadius: 24.0,
                          icon: Icon(
                            nowPlaying.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: Playback.next,
                        iconSize: 24.0,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
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
                              borderRadius: BorderRadius.circular(20.0),
                              border:
                                  nowPlaying.playlistMode != PlaylistMode.none
                                      ? Border.all(
                                          color: Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : Colors.black,
                                        )
                                      : null,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              if (nowPlaying.playlistMode ==
                                  PlaylistMode.loop) {
                                Playback.setPlaylistMode(
                                  PlaylistMode.none,
                                );
                                return;
                              }
                              Playback.setPlaylistMode(
                                PlaylistMode
                                    .values[nowPlaying.playlistMode.index + 1],
                              );
                            },
                            iconSize: 20.0,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                            splashRadius: 18.0,
                            icon: Icon(
                              nowPlaying.playlistMode == PlaylistMode.single
                                  ? Icons.repeat_one
                                  : Icons.repeat,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: Playback.toggleMute,
                        iconSize: 20.0,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                        splashRadius: 18.0,
                        icon: Icon(
                          nowPlaying.volume == 0.0
                              ? Icons.volume_off
                              : Icons.volume_up,
                        ),
                      ),
                      SizedBox(
                        width: 12.0,
                      ),
                      SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 4.0,
                          trackShape: CustomTrackShape(),
                          thumbShape: RoundSliderThumbShape(
                            enabledThumbRadius: 2.0,
                            pressedElevation: 0.0,
                            elevation: 0.0,
                          ),
                          overlayColor: Colors.transparent,
                          thumbColor: Theme.of(context).primaryColor,
                          activeTrackColor: Theme.of(context).primaryColor,
                          inactiveTrackColor:
                              Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white.withOpacity(0.4)
                                  : Colors.black.withOpacity(0.4),
                        ),
                        child: Container(
                          width: 84.0,
                          child: Slider(
                            value: nowPlaying.volume,
                            onChanged: (value) {
                              Playback.setVolume(value);
                              nowPlaying.volume = value;
                            },
                            max: 1.0,
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // IconButton(
                  //   onPressed: (nowPlaying.index != null &&
                  //           nowPlaying.tracks.length >
                  //               (nowPlaying.index ?? double.infinity) &&
                  //           0 <= (nowPlaying.index ?? double.infinity))
                  //       ? () {
                  //           showDialog(
                  //             context: context,
                  //             builder: (context) => FractionallyScaledWidget(
                  //               child: SimpleDialog(
                  //                 backgroundColor: Theme.of(context)
                  //                     .appBarTheme
                  //                     .backgroundColor,
                  //                 title: Text(
                  //                   nowPlaying
                  //                       .tracks[nowPlaying.index!].trackName!,
                  //                 ),
                  //                 titlePadding: EdgeInsets.all(16.0),
                  //                 contentPadding: EdgeInsets.all(16.0),
                  //                 children: lyrics.current.isNotEmpty
                  //                     ? lyrics.current
                  //                         .map(
                  //                           (lyric) => Text(
                  //                             lyric.words,
                  //                             style: Theme.of(context)
                  //                                 .textTheme
                  //                                 .headline4,
                  //                           ),
                  //                         )
                  //                         .toList()
                  //                     : [
                  //                         Text(
                  //                           language!.STRING_LYRICS_NOT_FOUND,
                  //                           style: Theme.of(context)
                  //                               .textTheme
                  //                               .headline4,
                  //                         ),
                  //                       ],
                  //               ),
                  //             ),
                  //           );
                  //         }
                  //       : null,
                  //   iconSize: 24.0,
                  //   color: Theme.of(context).brightness == Brightness.dark
                  //       ? Colors.white
                  //       : Colors.black,
                  //   splashRadius: 18.0,
                  //   icon: Icon(
                  //     Icons.short_text,
                  //   ),
                  // ),
                  Consumer<NowPlayingBarController>(
                    builder: (context, controller, _) => IconButton(
                      onPressed: controller.maximized
                          ? () {
                              this.exit?.call();
                            }
                          : () {
                              this.launch?.call();
                            },
                      iconSize: 24.0,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                      splashRadius: 18.0,
                      icon: Icon(
                        controller.maximized
                            ? Icons.expand_more
                            : Icons.expand_less,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 12.0,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
