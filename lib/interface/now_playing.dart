/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright (C) 2022 The Harmonoid Authors (see AUTHORS.md for details).
/// Copyright (C) 2021-2022 Hitesh Kumar Saini <saini123hitesh@gmail.com>.
///
/// This program is free software: you can redistribute it and/or modify
/// it under the terms of the GNU Affero General Public License as
/// published by the Free Software Foundation, either version 3 of the
/// License, or (at your option) any later version.
///
/// This program is distributed in the hope that it will be useful,
/// but WITHOUT ANY WARRANTY; without even the implied warranty of
/// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
/// GNU Affero General Public License for more details.
///
/// You should have received a copy of the GNU Affero General Public License
/// along with this program.  If not, see <https://www.gnu.org/licenses/>.
///

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:harmonoid/models/media.dart';
import 'package:libmpv/libmpv.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:collection/collection.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/state/lyrics.dart';
import 'package:harmonoid/state/now_playing_launcher.dart';
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
  final ScrollController scrollController = ScrollController(
      initialScrollOffset:
          48.0 * (Playback.instance.index - 2).clamp(0, 9223372036854775807));
  double scale = 0.0;
  int index = Playback.instance.index;
  List<Track> tracks = Playback.instance.tracks;
  late VoidCallback listener;

  @override
  void initState() {
    super.initState();
    listener = () {
      if (!(const ListEquality().equals(tracks, Playback.instance.tracks))) {
        setState(() {
          tracks = Playback.instance.tracks;
        });
      }
      if (index != Playback.instance.index) {
        setState(() {
          index = Playback.instance.index;
        });
      }
    };
    Playback.instance.addListener(listener);
  }

  @override
  void dispose() {
    Playback.instance.removeListener(listener);
    super.dispose();
  }

  Widget build(BuildContext context) {
    return isDesktop
        ? Scaffold(
            body: Stack(
              children: [
                DesktopAppBar(
                  leading: NavigatorPopButton(
                    onTap: () {
                      NowPlayingLauncher.instance.maximized = false;
                    },
                  ),
                  title: Language.instance.NOW_PLAYING,
                ),
                Container(
                  margin: EdgeInsets.only(
                    top: desktopTitleBarHeight + kDesktopAppBarHeight,
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
                            child: MouseRegion(
                              onEnter: (e) => setState(() {
                                scale = 1.0;
                              }),
                              onExit: (e) => setState(() {
                                scale = 0.0;
                              }),
                              child: Card(
                                clipBehavior: Clip.antiAlias,
                                elevation: 8.0,
                                child: LayoutBuilder(
                                  builder: (context, constraints) => Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Image(
                                        image: Collection.instance
                                            .getAlbumArt(tracks[index]),
                                        fit: BoxFit.cover,
                                        height: min(constraints.maxHeight,
                                            constraints.maxWidth),
                                        width: min(constraints.maxHeight,
                                            constraints.maxWidth),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          AnimatedScale(
                                            scale: scale,
                                            duration:
                                                Duration(milliseconds: 100),
                                            curve: Curves.easeInOut,
                                            child: Material(
                                              color: Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(28.0),
                                              elevation: 4.0,
                                              child: InkWell(
                                                borderRadius:
                                                    BorderRadius.circular(28.0),
                                                onTap: () {
                                                  trackPopupMenuHandle(
                                                    context,
                                                    tracks[index],
                                                    2,
                                                  );
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            28.0),
                                                    color: Colors.black54,
                                                  ),
                                                  height: 56.0,
                                                  width: 56.0,
                                                  child: Icon(
                                                    Icons.add,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 12.0),
                                          if (Plugins.isExternalMedia(
                                              tracks[index].uri))
                                            AnimatedScale(
                                              scale: scale,
                                              duration:
                                                  Duration(milliseconds: 100),
                                              curve: Curves.easeInOut,
                                              child: Material(
                                                color: Colors.transparent,
                                                borderRadius:
                                                    BorderRadius.circular(28.0),
                                                elevation: 4.0,
                                                child: InkWell(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          28.0),
                                                  onTap: () {
                                                    launch(tracks[index]
                                                        .uri
                                                        .toString());
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              28.0),
                                                      color: Colors.black54,
                                                    ),
                                                    height: 56.0,
                                                    width: 56.0,
                                                    child: Icon(
                                                      Icons.launch,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
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
                                    CustomListViewBuilder(
                                      controller: scrollController,
                                      itemExtents: List.generate(
                                          tracks.length, (index) => 48.0),
                                      itemCount: tracks.length,
                                      itemBuilder: (context, index) => Material(
                                        color: this.index == index
                                            ? Theme.of(context)
                                                .dividerColor
                                                .withOpacity(0.12)
                                            : Colors.transparent,
                                        child: TrackTile(
                                          leading: this.index == index
                                              ? Icon(
                                                  Icons.play_arrow,
                                                  size: 24.0,
                                                )
                                              : Text(
                                                  '${index + 1}',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headline4,
                                                ),
                                          track: tracks[index],
                                          index: 0,
                                          onPressed: () {
                                            Playback.instance.jump(index);
                                          },
                                          disableContextMenu: true,
                                        ),
                                      ),
                                    ),
                                    Consumer<Lyrics>(
                                      builder: (context, lyrics, _) =>
                                          lyrics.current.isNotEmpty
                                              ? CustomListView(
                                                  shrinkWrap: true,
                                                  padding: EdgeInsets.all(16.0),
                                                  children: lyrics.current
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
        : Container();
  }
}
