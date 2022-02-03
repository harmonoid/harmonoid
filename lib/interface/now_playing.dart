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
import 'package:flutter/material.dart';
import 'package:harmonoid/state/lyrics.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/models/media.dart';
import 'package:harmonoid/utils/dimensions.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/interface/collection/track.dart';
import 'package:harmonoid/constants/language.dart';

class NowPlayingScreen extends StatefulWidget {
  const NowPlayingScreen({Key? key}) : super(key: key);

  NowPlayingState createState() => NowPlayingState();
}

class NowPlayingState extends State<NowPlayingScreen>
    with TickerProviderStateMixin {
  Widget build(BuildContext context) {
    return Consumer<Playback>(
      builder: (context, playback, _) => isDesktop
          ? Scaffold(
              body: Stack(
                children: [
                  DesktopAppBar(
                    leading: NavigatorPopButton(
                      onTap: () {},
                    ),
                    title: Language.instance.NOW_PLAYING,
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      top: kDesktopTitleBarHeight + kDesktopAppBarHeight,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Center(
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth: 640.0,
                                maxHeight: 640.0,
                              ),
                              padding: EdgeInsets.all(32.0),
                              child: Card(
                                clipBehavior: Clip.antiAlias,
                                elevation: 8.0,
                                child: LayoutBuilder(
                                  builder: (context, constraints) => Image(
                                    image: Collection.instance.getAlbumArt(
                                        playback.tracks[playback.index]),
                                    fit: BoxFit.cover,
                                    height: min(constraints.maxHeight,
                                        constraints.maxWidth),
                                    width: min(constraints.maxHeight,
                                        constraints.maxWidth),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        VerticalDivider(
                          width: 1.0,
                          thickness: 1.0,
                        ),
                        Expanded(
                          child: DefaultTabController(
                            length: 2,
                            child: Column(
                              children: [
                                Material(
                                  color: Colors.transparent,
                                  child: TabBar(
                                    unselectedLabelColor: Theme.of(context)
                                        .textTheme
                                        .headline1
                                        ?.color,
                                    labelStyle: Theme.of(context)
                                        .textTheme
                                        .headline4
                                        ?.copyWith(
                                            color:
                                                Theme.of(context).primaryColor),
                                    indicatorColor:
                                        Theme.of(context).primaryColor,
                                    labelColor: Theme.of(context).primaryColor,
                                    tabs: [
                                      Tab(
                                        text: Language.instance.COMING_UP
                                            .toUpperCase(),
                                      ),
                                      Tab(
                                        text: Language.instance.LYRICS
                                            .toUpperCase(),
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(
                                  thickness: 1.0,
                                  height: 1.0,
                                ),
                                Expanded(
                                  child: TabBarView(
                                    children: [
                                      CustomListView(
                                        children: segment.map((track) {
                                          final index = segment.indexOf(track);
                                          return Material(
                                            color: Colors.transparent,
                                            child: TrackTile(
                                              leading: Text(
                                                '${index + 1}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline4,
                                              ),
                                              track: track,
                                              index: 0,
                                              onPressed: () {
                                                playback.jump(index + 1);
                                              },
                                              disableContextMenu: true,
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                      Consumer<Lyrics>(
                                        builder: (context, lyrics, _) => lyrics
                                                .current.isNotEmpty
                                            ? CustomListView(
                                                shrinkWrap: true,
                                                padding: EdgeInsets.all(16.0),
                                                children: lyrics.current
                                                    .map(
                                                      (lyric) => Text(
                                                        lyric.words,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .headline4,
                                                        textAlign:
                                                            TextAlign.start,
                                                      ),
                                                    )
                                                    .toList(),
                                              )
                                            : Center(
                                                child: Text(
                                                  Language.instance
                                                      .LYRICS_NOT_FOUND,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headline4,
                                                  textAlign: TextAlign.start,
                                                ),
                                              ),
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
                ],
              ),
            )
          : Container(),
    );
  }

  List<Track> get segment {
    if (Playback.instance.tracks.isEmpty ||
        Playback.instance.index < 0 ||
        Playback.instance.index >= Playback.instance.tracks.length) return [];
    return Playback.instance.tracks
        .skip(Playback.instance.index)
        .take(20)
        .toList();
  }
}
