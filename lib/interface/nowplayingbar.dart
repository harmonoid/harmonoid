import 'dart:math';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/core/lyrics.dart';
import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/interface/changenotifiers.dart';
import 'package:harmonoid/constants/language.dart';

const double HORIZONTAL_BREAKPOINT = 720.0;

class NowPlayingBar extends StatefulWidget {
  final void Function()? launch;
  NowPlayingBar({Key? key, this.launch}) : super(key: key);
  @override
  NowPlayingBarState createState() => NowPlayingBarState();
}

class NowPlayingBarState extends State<NowPlayingBar> {
  @override
  Widget build(BuildContext context) {
    if (HORIZONTAL_BREAKPOINT >= MediaQuery.of(context).size.width)
      return Consumer<NowPlayingController>(
        builder: (context, nowPlaying, _) => Consumer<NowPlayingBarController>(
          builder: (context, container, _) => AnimatedContainer(
            duration: Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            height: container.height,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withOpacity(0.10)
                : Colors.black.withOpacity(0.10),
            child: SingleChildScrollView(
              child: (nowPlaying.index != null &&
                      nowPlaying.tracks.length >
                          (nowPlaying.index ?? double.infinity) &&
                      0 <= (nowPlaying.index ?? double.infinity))
                  ? Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          widget.launch?.call();
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 2.0,
                              width: MediaQuery.of(context).size.width *
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
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withOpacity(0.10)
            : Colors.black.withOpacity(0.10),
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
                              MediaQuery.of(context).size.width)
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
                          child: Slider(
                            value:
                                nowPlaying.position.inMilliseconds.toDouble(),
                            onChanged: (value) {
                              Playback.seek(
                                Duration(
                                  milliseconds: value.toInt(),
                                ),
                              );
                            },
                            max: nowPlaying.duration.inMilliseconds.toDouble(),
                            min: 0.0,
                          ),
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
                          width: 96.0,
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
                  IconButton(
                    onPressed: (nowPlaying.index != null &&
                            nowPlaying.tracks.length >
                                (nowPlaying.index ?? double.infinity) &&
                            0 <= (nowPlaying.index ?? double.infinity))
                        ? () {
                            showDialog(
                              context: context,
                              builder: (context) => FractionallyScaledWidget(
                                child: SimpleDialog(
                                  backgroundColor: Theme.of(context)
                                      .appBarTheme
                                      .backgroundColor,
                                  title: Text(
                                    nowPlaying
                                        .tracks[nowPlaying.index!].trackName!,
                                  ),
                                  titlePadding: EdgeInsets.all(16.0),
                                  contentPadding: EdgeInsets.all(16.0),
                                  children: lyrics.current.isNotEmpty
                                      ? lyrics.current
                                          .map(
                                            (lyric) => Text(
                                              lyric.words,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline4,
                                            ),
                                          )
                                          .toList()
                                      : [
                                          Text(
                                            language!.STRING_LYRICS_NOT_FOUND,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline4,
                                          ),
                                        ],
                                ),
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
