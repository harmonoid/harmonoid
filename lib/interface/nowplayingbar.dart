import 'dart:core';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/core/lyrics.dart';
import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/interface/changenotifiers.dart';

const double HORIZONTAL_BREAKPOINT = 720.0;

class NowPlayingBar extends StatelessWidget {
  const NowPlayingBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrentlyPlaying>(
      builder: (context, currentlyPlaying, _) => Container(
        height: 84.0,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withOpacity(0.08)
            : Colors.black.withOpacity(0.08),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: (currentlyPlaying.index != null &&
                      currentlyPlaying.tracks.length >
                          (currentlyPlaying.index ?? double.infinity) &&
                      0 <= (currentlyPlaying.index ?? double.infinity) &&
                      HORIZONTAL_BREAKPOINT < MediaQuery.of(context).size.width)
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 10.0,
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: currentlyPlaying
                                      .tracks[currentlyPlaying.index!]
                                      .networkAlbumArt ==
                                  null
                              ? Image.file(
                                  currentlyPlaying
                                      .tracks[currentlyPlaying.index!].albumArt,
                                  height: 64.0,
                                  width: 64.0,
                                )
                              : Image.network(
                                  currentlyPlaying
                                      .tracks[currentlyPlaying.index!]
                                      .networkAlbumArt!,
                                  height: 64.0,
                                  width: 64.0,
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
                                currentlyPlaying.tracks[currentlyPlaying.index!]
                                        .trackName ??
                                    '',
                                style: Theme.of(context).textTheme.headline1,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                currentlyPlaying.tracks[currentlyPlaying.index!]
                                        .trackArtistNames
                                        ?.join(', ') ??
                                    '',
                                style: Theme.of(context).textTheme.headline5,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '(${currentlyPlaying.tracks[currentlyPlaying.index!].year ?? 'Unknown Year'})',
                                style: Theme.of(context).textTheme.headline5,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Container(),
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
                            currentlyPlaying.position.label,
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
                          child: Slider(
                            value: currentlyPlaying.position.inMilliseconds
                                .toDouble(),
                            onChanged: (value) {
                              Playback.seek(
                                Duration(
                                  milliseconds: value.toInt(),
                                ),
                              );
                            },
                            max: currentlyPlaying.duration.inMilliseconds
                                .toDouble(),
                            min: 0.0,
                          ),
                        ),
                        SizedBox(
                          width: 12.0,
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 2.0),
                          child: Text(
                            currentlyPlaying.duration.label,
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
                  margin: EdgeInsets.only(top: 8.0, bottom: 28.0),
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
                            width: 96.0,
                            child: Slider(
                              value: currentlyPlaying.rate,
                              onChanged: (value) {
                                Playback.setRate(value);
                                currentlyPlaying.rate = player.rate;
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
                          currentlyPlaying.rate = player.rate;
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
                            currentlyPlaying.isPlaying
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
                      IconButton(
                        onPressed: () {
                          Playback.setVolume(
                            currentlyPlaying.volume > 0.0
                                ? 0.0
                                : currentlyPlaying.volumeBeforeMute,
                          );
                          currentlyPlaying.volume =
                              currentlyPlaying.volume > 0.0
                                  ? 0.0
                                  : currentlyPlaying.volumeBeforeMute;
                        },
                        iconSize: 20.0,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                        splashRadius: 18.0,
                        icon: Icon(
                          currentlyPlaying.volume == 0.0
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
                          width: 96.0,
                          child: Slider(
                            value: currentlyPlaying.volume,
                            onChanged: (value) {
                              Playback.setVolume(value);
                              currentlyPlaying.volume = value;
                              currentlyPlaying.volumeBeforeMute = value;
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
                  IconButton(
                    onPressed: (currentlyPlaying.index != null &&
                            currentlyPlaying.tracks.length >
                                (currentlyPlaying.index ?? double.infinity) &&
                            0 <= (currentlyPlaying.index ?? double.infinity))
                        ? () async {
                            await lyrics.fromName(
                                '${currentlyPlaying.tracks[currentlyPlaying.index!].trackName!} ${currentlyPlaying.tracks[currentlyPlaying.index!].albumArtistName!}');
                            showDialog(
                              context: context,
                              builder: (context) => SimpleDialog(
                                backgroundColor:
                                    Theme.of(context).appBarTheme.color,
                                title: Text(
                                  currentlyPlaying
                                      .tracks[currentlyPlaying.index!]
                                      .trackName!,
                                ),
                                titlePadding: EdgeInsets.all(16.0),
                                contentPadding: EdgeInsets.all(16.0),
                                children: lyrics.current
                                    .map(
                                      (lyric) => Text(
                                        lyric.words,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline4,
                                      ),
                                    )
                                    .toList(),
                              ),
                            );
                          }
                        : null,
                    iconSize: 24.0,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                    splashRadius: 18.0,
                    icon: Icon(
                      Icons.short_text,
                    ),
                  ),
                  // TODO: Maybe add now playing screen or any way to see currently playing songs.
                  // IconButton(
                  //   onPressed: () {},
                  //   iconSize: 24.0,
                  //   color: Theme.of(context).brightness == Brightness.dark
                  //       ? Colors.white
                  //       : Colors.black,
                  //   splashRadius: 18.0,
                  //   icon: Icon(
                  //     Icons.expand_more,
                  //   ),
                  // ),
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
