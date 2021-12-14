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
import 'dart:math';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:harmonoid/core/hotkeys.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:provider/provider.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/youtubemusic.dart';
import 'package:harmonoid/interface/changenotifiers.dart';
import 'package:harmonoid/interface/youtube/youtubetile.dart';
import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/utils/utils.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/core/configuration.dart';

class YouTubeMusic extends StatefulWidget {
  const YouTubeMusic({Key? key}) : super(key: key);
  YouTubeMusicState createState() => YouTubeMusicState();
}

class YouTubeMusicState extends State<YouTubeMusic> {
  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    YouTubeStateController youtube = Provider.of<YouTubeStateController>(
      context,
      listen: false,
    );
    if (youtube.recommendation != configuration.discoverRecent!.first ||
        youtube.recommendations.isEmpty ||
        youtube.exception) {
      youtube.updateRecommendations(
        Track(
          trackId: configuration.discoverRecent!.first,
        ),
      );
    }
  }

  Future<void> play(Track track) async {
    nowPlaying.isBuffering = true;
    await track.attachAudioStream();
    if (track.filePath != null) {
      await Playback.play(
        index: 0,
        tracks: [
          track,
        ],
      );
      nowPlaying.isBuffering = false;
      Provider.of<YouTubeStateController>(
        context,
        listen: false,
      ).updateRecommendations(
        track,
      );
    }
  }

  void search(String query) async {
    try {
      Track? track = await YTM.identify(query);
      if (track != null) {
        this.play(track);
        return;
      }
    } catch (exception) {
      Utils.handleInvalidLink();
      return;
    }
    this.setState(() {
      this.result = Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(
            Theme.of(context).primaryColor,
          ),
        ),
      );
    });
    List<Track> tracks = await YTM.search(query);
    this.result = tracks.isNotEmpty
        ? CustomListView(
            children: tracks
                .map(
                  (track) => Material(
                    color: Colors.transparent,
                    child: ListTile(
                      onTap: () {
                        HotKeys.enableSpaceHotKey();
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    FadeThroughTransition(
                              fillColor: Colors.transparent,
                              animation: animation,
                              secondaryAnimation: secondaryAnimation,
                              child: YouTube(
                                track: track,
                              ),
                            ),
                          ),
                        );
                      },
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(track.networkAlbumArt!),
                      ),
                      title: Text(
                        track.trackName!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        track.trackArtistNames!.join(', ') +
                            ' • ${track.albumName}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                )
                .toList(),
          )
        : Center(
            child: Text(
              language.YOUTUBE_NO_RESULTS,
            ),
          );
    this.setState(() {});
  }

  Widget? result;
  List<String> suggestions = [];
  String query = '';

  @override
  Widget build(BuildContext context) {
    int elementsPerRow = MediaQuery.of(context).size.width.normalized ~/ 172.0;
    double tileWidth =
        MediaQuery.of(context).size.width.normalized / elementsPerRow;
    double tileHeight = tileWidth * 212.0 / 172.0;
    return Consumer<YouTubeStateController>(
      builder: (context, youtube, _) => Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            margin:
                EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: this.result == null
                      ? SizedBox(
                          width: 56.0,
                        )
                      : Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                this.setState(
                                  () => this.result = null,
                                );
                              },
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              child: Container(
                                height: 40.0,
                                width: 40.0,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Icon(
                                  FluentIcons.arrow_left_32_regular,
                                  size: 20.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                ),
                Expanded(
                  child: Autocomplete<String>(
                    optionsBuilder: (query) {
                      if (query.text.isEmpty) return [];
                      return this.suggestions;
                    },
                    optionsViewBuilder:
                        (context, callback, Iterable<String> values) =>
                            Container(
                      margin: EdgeInsets.only(right: 4 * 16.0 + 2 * 56.0 - 8.0),
                      width: MediaQuery.of(context).size.width.normalized -
                          4 * 16.0 -
                          2 * 56.0 -
                          8.0,
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Stack(
                          children: [
                            GestureDetector(
                              onTap: () {
                                callback('');
                              },
                              child: Container(
                                color: Colors.transparent,
                                width: MediaQuery.of(context)
                                    .size
                                    .width
                                    .normalized,
                                height: MediaQuery.of(context)
                                    .size
                                    .height
                                    .normalized,
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 4.0),
                              height: 236.0,
                              // width:
                              //     MediaQuery.of(context).size.width.normalized -
                              //         2 * 16.0 -
                              //         56.0 -
                              //         16.0,
                              child: Material(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Color(0xFF242424)
                                    : Color(0xFFFBFBFB),
                                elevation: 2.0,
                                child: Container(
                                  height: 236.0,
                                  // width: MediaQuery.of(context)
                                  //         .size
                                  //         .width
                                  //         .normalized -
                                  //     2 * 16.0 -
                                  //     56.0 -
                                  //     16.0,
                                  child: ListView.builder(
                                    keyboardDismissBehavior:
                                        ScrollViewKeyboardDismissBehavior
                                            .onDrag,
                                    padding: EdgeInsets.zero,
                                    itemCount: values.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      final String option =
                                          values.elementAt(index);
                                      return InkWell(
                                        onTap: () {
                                          callback(option);
                                          this.search(option);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Text(
                                            option,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline5,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    fieldViewBuilder: (context, controller, node, callback) =>
                        Focus(
                      onFocusChange: (hasFocus) {
                        if (!hasFocus) {
                          HotKeys.enableSpaceHotKey();
                        }
                      },
                      child: Focus(
                          onFocusChange: (hasFocus) {
                            if (hasFocus) {
                              HotKeys.disableSpaceHotKey();
                            } else {
                              HotKeys.enableSpaceHotKey();
                            }
                          },
                          child: Container(
                            height: 44.0,
                            child: TextField(
                              autofocus: Platform.isWindows ||
                                  Platform.isLinux ||
                                  Platform.isMacOS,
                              cursorWidth: 1.0,
                              focusNode: node,
                              controller: controller,
                              onChanged: (value) async {
                                query = value;
                                if (query.isEmpty) {
                                  this.suggestions = [];
                                  this.setState(() {});
                                  return;
                                }
                                this.suggestions = await YTM.suggestions(query);
                                this.setState(() {});
                              },
                              onSubmitted: (value) {
                                this.search(value);
                              },
                              cursorColor: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Colors.black
                                  : Colors.white,
                              textAlignVertical: TextAlignVertical.bottom,
                              style: Theme.of(context).textTheme.headline4,
                              decoration: InputDecoration(
                                suffixIcon: IconButton(
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  onPressed: () async {
                                    if (query.isEmpty) {
                                      this.suggestions = [];
                                      this.setState(() {});
                                      return;
                                    }
                                    this.suggestions =
                                        await YTM.suggestions(query);
                                    this.setState(() {});
                                  },
                                  icon: Transform.rotate(
                                    angle: pi / 2,
                                    child: Icon(
                                      FluentIcons.search_12_regular,
                                      size: 17.0,
                                      color: Theme.of(context).brightness ==
                                              Brightness.light
                                          ? Colors.black87
                                          : Colors.white.withOpacity(0.87),
                                    ),
                                  ),
                                ),
                                contentPadding:
                                    EdgeInsets.only(left: 10.0, bottom: 16.0),
                                hintText: language.YOUTUBE_WELCOME,
                                hintStyle: Theme.of(context)
                                    .textTheme
                                    .headline3
                                    ?.copyWith(
                                      color: Theme.of(context).brightness ==
                                              Brightness.light
                                          ? Colors.black.withOpacity(0.6)
                                          : Colors.white60,
                                    ),
                                filled: true,
                                fillColor: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.white
                                    : Color(0xFF202020),
                                hoverColor: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.white
                                    : Color(0xFF202020),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .dividerColor
                                        .withOpacity(0.32),
                                    width: 0.6,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .dividerColor
                                        .withOpacity(0.32),
                                    width: 0.6,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .dividerColor
                                        .withOpacity(0.32),
                                    width: 0.6,
                                  ),
                                ),
                              ),
                            ),
                          )),
                    ),
                  ),
                ),
                SizedBox(
                  width: 56.0 + 16.0,
                )
              ],
            ),
          ),
          Expanded(
            child: PageTransitionSwitcher(
              child: this.result ??
                  (youtube.recommendations.isNotEmpty
                      ? CustomListView(
                          padding: EdgeInsets.only(top: 8.0),
                          children: <Widget>[
                                Container(
                                  padding: EdgeInsets.only(left: 24.0),
                                  height: 56.0,
                                  child: Text(
                                    language.RECOMMENDATIONS,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline2
                                        ?.copyWith(fontSize: 24.0),
                                  ),
                                ),
                              ] +
                              tileGridListWidgets(
                                context: context,
                                tileHeight: tileHeight,
                                tileWidth: tileWidth,
                                elementsPerRow: elementsPerRow,
                                subHeader: null,
                                leadingSubHeader: null,
                                widgetCount: youtube.recommendations.length,
                                leadingWidget: Container(),
                                builder: (BuildContext context, int index) =>
                                    YouTubeTile(
                                  height: tileHeight,
                                  width: tileWidth,
                                  track: youtube.recommendations[index],
                                ),
                              ),
                        )
                      : (youtube.exception
                          ? Center(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ExceptionWidget(
                                    width: 420.0,
                                    margin: EdgeInsets.zero,
                                    title: language.NO_INTERNET_TITLE,
                                    subtitle: language.NO_INTERNET_SUBTITLE +
                                        '\n' +
                                        language.YOUTUBE_INTERNET_ERROR,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: MaterialButton(
                                      onPressed: () {
                                        youtube.updateRecommendations(
                                          Track(
                                            trackId: configuration
                                                .discoverRecent!.first,
                                          ),
                                        );
                                      },
                                      child: Text(
                                        language.REFRESH,
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(
                                  Theme.of(context).primaryColor,
                                ),
                              ),
                            ))),
              transitionBuilder: (child, animation, secondaryAnimation) =>
                  SharedAxisTransition(
                fillColor: Colors.transparent,
                animation: animation,
                secondaryAnimation: secondaryAnimation,
                transitionType: SharedAxisTransitionType.vertical,
                child: Container(
                  width: MediaQuery.of(context).size.width.normalized,
                  child: child,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
