/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_plus/window_plus.dart';
import 'package:media_library/media_library.dart';
import 'package:extended_image/extended_image.dart';

import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/state/lyrics.dart';
import 'package:harmonoid/state/desktop_now_playing_controller.dart';
import 'package:harmonoid/utils/dimensions.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/interface/collection/track.dart';
import 'package:harmonoid/constants/language.dart';

/// LEGACY [Widget].
/// Usage of this screen may still be enabled from the "Miscellaneous" settings.

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
  Track? track;

  void listener() {
    if (Playback.instance.index < 0 ||
        Playback.instance.index >= Playback.instance.tracks.length) {
      return;
    }
    final current = Playback.instance.tracks[Playback.instance.index];
    if (track != current || tracks.length != Playback.instance.tracks.length) {
      setState(() {
        track = current;
        index = Playback.instance.index;
        tracks = Playback.instance.tracks;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    Playback.instance.addListener(listener);
  }

  @override
  void dispose() {
    Playback.instance.removeListener(listener);
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          DesktopAppBar(
            leading: NavigatorPopButton(
              onTap: DesktopNowPlayingController.instance.hide,
            ),
            title: Language.instance.NOW_PLAYING,
          ),
          Container(
            margin: EdgeInsets.only(
              top: WindowPlus.instance.captionHeight + kDesktopAppBarHeight,
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
                          elevation: kDefaultHeavyElevation,
                          child: LayoutBuilder(
                            builder: (context, constraints) => AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder: (child, animation) =>
                                  FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                              child: ExtendedImage(
                                key: Key(index.toString()),
                                image: getAlbumArt(tracks[index]),
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
                            unselectedLabelColor:
                                Theme.of(context).textTheme.displayLarge?.color,
                            labelStyle: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                    color: Theme.of(context).primaryColor),
                            indicatorColor: Theme.of(context).primaryColor,
                            labelColor: Theme.of(context).primaryColor,
                            tabs: [
                              Tab(
                                text: Language.instance.COMING_UP.toUpperCase(),
                              ),
                              Tab(
                                text: Language.instance.LYRICS.toUpperCase(),
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
                                itemBuilder: (context, i) => Material(
                                  color: index == i
                                      ? Theme.of(context)
                                          .dividerTheme
                                          .color
                                          ?.withOpacity(0.12)
                                      : Colors.transparent,
                                  child: TrackTile(
                                    leading: index == i
                                        ? Icon(
                                            Icons.play_arrow,
                                            size: 24.0,
                                          )
                                        : Text(
                                            '${i + 1}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineMedium,
                                          ),
                                    track: tracks[i],
                                    index: 0,
                                    onPressed: () {
                                      Playback.instance.play();
                                      Playback.instance.jump(i);
                                    },
                                    disableContextMenu: true,
                                  ),
                                ),
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
                                                    .headlineMedium,
                                                textAlign: TextAlign.start,
                                              ),
                                            )
                                            .toList(),
                                      )
                                    : Center(
                                        child: Text(
                                          Language.instance.LYRICS_NOT_FOUND,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineMedium,
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
    );
  }
}
