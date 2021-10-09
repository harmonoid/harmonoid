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

import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/lyrics.dart';
import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/interface/changenotifiers.dart';
import 'package:harmonoid/interface/nowplayingbar.dart';

class NowPlayingScreen extends StatefulWidget {
  const NowPlayingScreen({Key? key}) : super(key: key);

  NowPlayingState createState() => NowPlayingState();
}

class NowPlayingState extends State<NowPlayingScreen>
    with TickerProviderStateMixin {
  Widget build(BuildContext context) {
    return Consumer<NowPlayingController>(
      builder: (context, nowPlaying, _) => MediaQuery.of(context)
                  .size
                  .width
                  .normalized <
              HORIZONTAL_BREAKPOINT
          ? Scaffold(
              body: Stack(
                children: [
                  Image(
                    image: (nowPlaying.index == null
                        ? AssetImage('assets/images/default_album_art.jpg')
                        : (nowPlaying.tracks[nowPlaying.index!]
                                    .networkAlbumArt !=
                                null
                            ? NetworkImage(nowPlaying
                                .tracks[nowPlaying.index!].networkAlbumArt!)
                            : FileImage(nowPlaying.tracks[nowPlaying.index!]
                                .albumArt))) as ImageProvider<Object>,
                    height: MediaQuery.of(context).size.height.normalized,
                    width: MediaQuery.of(context).size.width.normalized,
                    fit: BoxFit.cover,
                  ),
                  BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 20.0,
                      sigmaY: 20.0,
                    ),
                    child: Container(
                      color: Theme.of(context)
                          .scaffoldBackgroundColor
                          .withOpacity(0.6),
                    ),
                  ),
                  ListView(
                    padding: EdgeInsets.only(top: 32.0),
                    children: [
                          Stack(
                            clipBehavior: Clip.antiAlias,
                            alignment: Alignment.bottomCenter,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12.0),
                                child: Image(
                                  image: (nowPlaying.index == null
                                      ? AssetImage(
                                          'assets/images/default_album_art.jpg')
                                      : (nowPlaying.tracks[nowPlaying.index!]
                                                  .networkAlbumArt !=
                                              null
                                          ? NetworkImage(nowPlaying
                                              .tracks[nowPlaying.index!]
                                              .networkAlbumArt!)
                                          : FileImage(nowPlaying
                                              .tracks[nowPlaying.index!]
                                              .albumArt))) as ImageProvider<
                                      Object>,
                                  height: MediaQuery.of(context)
                                          .size
                                          .width
                                          .normalized -
                                      64.0,
                                  width: MediaQuery.of(context)
                                          .size
                                          .width
                                          .normalized -
                                      64.0,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(bottom: 12.0),
                                child: Container(),
                              ),
                            ],
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 32.0),
                            width:
                                MediaQuery.of(context).size.width.normalized -
                                    64.0,
                            child: nowPlaying.index != null
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        nowPlaying.tracks[nowPlaying.index!]
                                                .trackName ??
                                            '',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline1
                                            ?.copyWith(
                                              fontSize: 28.0,
                                              fontWeight: FontWeight.w800,
                                            ),
                                        maxLines: 1,
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(
                                        height: 8.0,
                                      ),
                                      Text(
                                        nowPlaying.tracks[nowPlaying.index!]
                                                .trackArtistNames
                                                ?.join(', ') ??
                                            '',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline3,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(
                                        height: 2.0,
                                      ),
                                      Text(
                                        '(${nowPlaying.tracks[nowPlaying.index!].year ?? 'Unknown Year'})',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline3,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  )
                                : Container(),
                          ),
                          Divider(
                            height: 1.0,
                            thickness: 1.0,
                          ),
                          SizedBox(
                            height: 32.0,
                          ),
                          Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              Container(
                                padding: EdgeInsets.only(
                                  left: 18.0,
                                  right: 18.0,
                                  top: 18.0,
                                ),
                                height: 36.0,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: 48,
                                      alignment: Alignment.center,
                                      child: Text(
                                        nowPlaying.position.label,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline4,
                                      ),
                                    ),
                                    Container(
                                      width: 48,
                                      alignment: Alignment.center,
                                      child: Text(
                                        nowPlaying.duration.label,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                height: 36.0,
                                padding: EdgeInsets.only(
                                  left: 4.0,
                                  right: 4.0,
                                  bottom: 28.0,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    SizedBox(
                                      width: 24.0,
                                    ),
                                    Expanded(
                                      child: SliderTheme(
                                        child: Slider(
                                          value: nowPlaying
                                              .position.inMilliseconds
                                              .toDouble(),
                                          onChanged: (value) {
                                            Playback.seek(
                                              Duration(
                                                milliseconds: value.toInt(),
                                              ),
                                            );
                                          },
                                          max: nowPlaying
                                              .duration.inMilliseconds
                                              .toDouble(),
                                          min: 0.0,
                                        ),
                                        data: SliderThemeData(
                                          trackHeight: 3.0,
                                          trackShape: CustomTrackShape(),
                                          thumbShape: RoundSliderThumbShape(
                                            enabledThumbRadius: 8.0,
                                            pressedElevation: 8.0,
                                            elevation: 0.0,
                                          ),
                                          overlayColor: Colors.transparent,
                                          thumbColor:
                                              Theme.of(context).primaryColor,
                                          activeTrackColor:
                                              Theme.of(context).primaryColor,
                                          inactiveTrackColor: Theme.of(context)
                                                      .brightness ==
                                                  Brightness.dark
                                              ? Colors.white.withOpacity(0.4)
                                              : Colors.black.withOpacity(0.4),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 24.0,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 8.0,
                          ),
                          Material(
                            color: Colors.transparent,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 48.0,
                                    width: 48.0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(24.0),
                                        border: nowPlaying.isShuffling
                                            ? Border.all(
                                                color: Theme.of(context)
                                                            .brightness ==
                                                        Brightness.dark
                                                    ? Colors.white
                                                    : Colors.black,
                                              )
                                            : null,
                                      ),
                                      child: IconButton(
                                        onPressed: Playback.shuffle,
                                        iconSize: 24.0,
                                        color: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : Colors.black,
                                        splashRadius: 18.0,
                                        icon: Icon(
                                          Icons.shuffle,
                                        ),
                                      ),
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
                                      borderRadius: BorderRadius.circular(36.0),
                                    ),
                                    height: 72.0,
                                    width: 72.0,
                                    child: IconButton(
                                      onPressed: Playback.playOrPause,
                                      iconSize: 48.0,
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : Colors.black,
                                      splashRadius: 28.0,
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
                                  Container(
                                    height: 48.0,
                                    width: 48.0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(24.0),
                                        border: nowPlaying.playlistMode !=
                                                PlaylistMode.none
                                            ? Border.all(
                                                color: Theme.of(context)
                                                            .brightness ==
                                                        Brightness.dark
                                                    ? Colors.white
                                                    : Colors.black,
                                              )
                                            : null,
                                      ),
                                      child: IconButton(
                                        onPressed: () {
                                          if (nowPlaying.playlistMode ==
                                              PlaylistMode.loop) {
                                            Playback.setPlaylistMode(
                                              PlaylistMode.none,
                                            );
                                            return;
                                          }
                                          Playback.setPlaylistMode(
                                            PlaylistMode.values[
                                                nowPlaying.playlistMode.index +
                                                    1],
                                          );
                                        },
                                        iconSize: 24.0,
                                        color: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : Colors.black,
                                        splashRadius: 18.0,
                                        icon: Icon(
                                          nowPlaying.playlistMode ==
                                                  PlaylistMode.single
                                              ? Icons.repeat_one
                                              : Icons.repeat,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: 24.0, vertical: 16.0),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SubHeader(
                                  language!.STRING_LYRICS,
                                ),
                                Container(
                                  margin: EdgeInsets.only(
                                      left: 16.0, right: 16.0, bottom: 18.0),
                                  child: Text(
                                    nowPlaying.position.lyric,
                                    style:
                                        Theme.of(context).textTheme.headline4,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SubHeader(
                            language!.STRING_COMING_UP,
                          ),
                        ] +
                        segment
                            .map(
                              (track) => Material(
                                color: Colors.transparent,
                                child: ListTile(
                                  onTap: () {
                                    Playback.jump(segment.indexOf(track));
                                  },
                                  dense: false,
                                  leading: CircleAvatar(
                                    backgroundImage: track.networkAlbumArt !=
                                            null
                                        ? NetworkImage(track.networkAlbumArt!)
                                        : FileImage(track.albumArt)
                                            as ImageProvider<Object>?,
                                  ),
                                  title: Text(
                                    track.trackName!,
                                    overflow: TextOverflow.fade,
                                    maxLines: 1,
                                    softWrap: false,
                                  ),
                                  subtitle: Text(
                                    track.albumName! +
                                        ' • ' +
                                        (track.trackArtistNames!.length < 2
                                            ? track.trackArtistNames!.join(', ')
                                            : track.trackArtistNames!
                                                .sublist(0, 2)
                                                .join(', ')),
                                    overflow: TextOverflow.fade,
                                    maxLines: 1,
                                    softWrap: false,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                  Builder(
                    builder: (context){
                      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
                        //This is a fix to an issue where the WindowTitleBar doesn't show up.
                        return Positioned(child: SizedBox(), top: -40,);
                      }return SizedBox();
                    },
                  ),
                ],
              ),
            )
          : (!nowPlaying.isBuffering &&
                  nowPlaying.index != null &&
                  nowPlaying.tracks.length >
                      (nowPlaying.index ?? double.infinity) &&
                  0 <= (nowPlaying.index ?? double.negativeInfinity) &&
                  HORIZONTAL_BREAKPOINT <
                      MediaQuery.of(context).size.width.normalized
              ? Scaffold(
                  body: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        height: 56.0,
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white.withOpacity(0.10)
                              : Colors.black.withOpacity(0.10),
                          border: Border(
                            bottom: BorderSide(
                                color: Theme.of(context)
                                    .dividerColor
                                    .withOpacity(0.12)),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            NavigatorPopButton(
                              onTap: () {
                                Provider.of<NowPlayingBarController>(context,
                                        listen: false)
                                    .maximized = false;
                              },
                            ),
                            SizedBox(
                              width: 24.0,
                            ),
                            Text(
                              language!.STRING_NOW_PLAYING,
                              style: TextStyle(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.w600,
                                fontSize: 16.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                          color: Colors.transparent,
                          child: Row(
                            children: [
                              Container(
                                width: MediaQuery.of(context)
                                        .size
                                        .width
                                        .normalized /
                                    2,
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.all(48.0),
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(
                                            maxWidth: 512.0,
                                            maxHeight: 512.0,
                                          ),
                                          child: Image(
                                            image: (nowPlaying.index == null
                                                ? AssetImage(
                                                    'assets/images/default_album_art.jpg')
                                                : (nowPlaying
                                                            .tracks[nowPlaying
                                                                .index!]
                                                            .networkAlbumArt !=
                                                        null
                                                    ? NetworkImage(nowPlaying
                                                        .tracks[
                                                            nowPlaying.index!]
                                                        .networkAlbumArt!)
                                                    : FileImage(
                                                        nowPlaying
                                                            .tracks[nowPlaying
                                                                .index!]
                                                            .albumArt,
                                                      ))) as ImageProvider<
                                                Object>,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context)
                                        .size
                                        .width
                                        .normalized /
                                    2,
                                color: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.white.withOpacity(0.10)
                                    : Colors.black.withOpacity(0.10),
                                child: DefaultTabController(
                                  length: 2,
                                  child: Column(
                                    children: [
                                      Material(
                                        color: Colors.transparent,
                                        child: TabBar(
                                          unselectedLabelColor:
                                              Theme.of(context)
                                                  .textTheme
                                                  .headline1
                                                  ?.color,
                                          indicatorColor:
                                              Theme.of(context).brightness ==
                                                      Brightness.light
                                                  ? Colors.black
                                                  : Colors.white,
                                          labelColor:
                                              Theme.of(context).brightness ==
                                                      Brightness.light
                                                  ? Colors.black
                                                  : Colors.white,
                                          tabs: [
                                            Tab(
                                              text: language!.STRING_COMING_UP
                                                  .toUpperCase(),
                                            ),
                                            Tab(
                                              text: language!.STRING_LYRICS
                                                  .toUpperCase(),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: TabBarView(
                                          children: [
                                            CustomListView(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 16.0),
                                              children: segment
                                                  .map(
                                                    (track) => Material(
                                                      color: Colors.transparent,
                                                      child: ListTile(
                                                        onTap: () {
                                                          Playback.jump(
                                                              nowPlaying.tracks
                                                                  .indexOf(
                                                                      track));
                                                        },
                                                        dense: false,
                                                        leading: CircleAvatar(
                                                          backgroundImage: track
                                                                      .networkAlbumArt !=
                                                                  null
                                                              ? NetworkImage(track
                                                                  .networkAlbumArt!)
                                                              : FileImage(track
                                                                      .albumArt)
                                                                  as ImageProvider<
                                                                      Object>?,
                                                        ),
                                                        title: Text(
                                                          track.trackName!,
                                                          overflow:
                                                              TextOverflow.fade,
                                                          maxLines: 1,
                                                          softWrap: false,
                                                        ),
                                                        subtitle: Text(
                                                          track.albumName! +
                                                              ' • ' +
                                                              (track.trackArtistNames!
                                                                          .length <
                                                                      2
                                                                  ? track
                                                                      .trackArtistNames!
                                                                      .join(
                                                                          ', ')
                                                                  : track
                                                                      .trackArtistNames!
                                                                      .sublist(
                                                                          0, 2)
                                                                      .join(
                                                                          ', ')),
                                                          overflow:
                                                              TextOverflow.fade,
                                                          maxLines: 1,
                                                          softWrap: false,
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                  .toList(),
                                            ),
                                            CustomListView(
                                              shrinkWrap: true,
                                              padding: EdgeInsets.all(16.0),
                                              children: lyrics
                                                      .current.isNotEmpty
                                                  ? lyrics.current
                                                      .map(
                                                        (lyric) => Text(
                                                          lyric.words,
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .headline4,
                                                          textAlign:
                                                              TextAlign.start,
                                                        ),
                                                      )
                                                      .toList()
                                                  : [
                                                      Text(
                                                        language!
                                                            .STRING_LYRICS_NOT_FOUND,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .headline4,
                                                        textAlign:
                                                            TextAlign.start,
                                                      ),
                                                    ],
                                            ),
                                          ],
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
                    ],
                  ),
                )
              : Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(
                      Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                )),
    );
  }

  List<Track> get segment {
    if (nowPlaying.tracks.length == 0 ||
        (nowPlaying.index ?? -1) < 0 ||
        (nowPlaying.index ?? double.infinity) > nowPlaying.tracks.length)
      return [];
    return nowPlaying.tracks.length - nowPlaying.index! > 10
        ? nowPlaying.tracks.sublist(nowPlaying.index!, nowPlaying.index! + 10)
        : nowPlaying.tracks.sublist(nowPlaying.index!);
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

  String get lyric {
    if (lyrics.current.isEmpty) return language!.STRING_LYRICS_NOT_FOUND;
    for (var lyric in lyrics.current.reversed) {
      if (lyric.time ~/ 1000 <= inSeconds) {
        return lyric.words;
      }
    }
    return language!.STRING_LYRICS_NOT_FOUND;
  }
}
