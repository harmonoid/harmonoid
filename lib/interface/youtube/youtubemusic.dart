import 'dart:io';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/rendering.dart';

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
              language!.STRING_YOUTUBE_NO_RESULTS,
            ),
          );
    this.setState(() {});
  }

  Widget? result;
  List<String> suggestions = [];
  @override
  Widget build(BuildContext context) {
    int elementsPerRow =
        (MediaQuery.of(context).size.width * (Platform.isLinux ? 0.75 : 1.0)) ~/
            (156 + 8);
    double tileWidth =
        ((MediaQuery.of(context).size.width * (Platform.isLinux ? 0.75 : 1.0)) -
                16 -
                (elementsPerRow - 1) * 8) /
            elementsPerRow;
    double tileHeight = tileWidth * 246.0 / 156;
    return Consumer<YouTubeStateController>(
      builder: (context, youtube, _) => Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: this.result == null
                      ? Container(
                          width: 56.0,
                          child: Icon(
                            FluentIcons.search_24_regular,
                            size: 24.0,
                          ),
                        )
                      : Padding(
                          padding: EdgeInsets.all(8.0),
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
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white.withOpacity(0.04)
                                    : Colors.black.withOpacity(0.04),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Icon(
                                FluentIcons.arrow_left_20_filled,
                                size: 20.0,
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
                      margin: EdgeInsets.only(right: 16.0),
                      width: (MediaQuery.of(context).size.width *
                              (Platform.isLinux ? 0.75 : 1.0)) -
                          16.0 -
                          56.0,
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
                                width: MediaQuery.of(context).size.width *
                                    (Platform.isLinux ? 0.75 : 1.0),
                                height: MediaQuery.of(context).size.height *
                                    (Platform.isLinux ? 0.75 : 1.0),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 4.0),
                              height: 236.0,
                              width: (MediaQuery.of(context).size.width *
                                      (Platform.isLinux ? 0.75 : 1.0)) -
                                  2 * 16.0 -
                                  56.0 -
                                  16.0,
                              child: Material(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Color(0xFF242424)
                                    : Color(0xFFFBFBFB),
                                elevation: 2.0,
                                child: Container(
                                  height: 236.0,
                                  width: (MediaQuery.of(context).size.width *
                                          (Platform.isLinux ? 0.75 : 1.0)) -
                                      2 * 16.0 -
                                      56.0 -
                                      16.0,
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
                                                .headline5
                                                ?.copyWith(
                                                    color: Theme.of(context)
                                                                .brightness ==
                                                            Brightness.dark
                                                        ? Colors.white
                                                        : Colors.black),
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
                        TextField(
                      autofocus: Platform.isWindows ||
                          Platform.isLinux ||
                          Platform.isMacOS,
                      controller: controller,
                      focusNode: node,
                      onChanged: (value) async {
                        if (value.isEmpty) {
                          this.suggestions = [];
                          this.setState(() {});
                          return;
                        }
                        this.suggestions = await YTM.suggestions(value);
                        this.setState(() {});
                      },
                      style: Theme.of(context).textTheme.headline4,
                      onSubmitted: (value) {
                        this.search(value);
                      },
                      cursorWidth: 1.0,
                      decoration: InputDecoration(
                        hintText: language!.STRING_YOUTUBE_WELCOME,
                        hintStyle: Theme.of(context).textTheme.headline3,
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.secondary,
                              width: 1.0),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).dividerColor,
                            width: 1.0,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.secondary,
                              width: 1.0),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 24.0,
                ),
              ],
            ),
          ),
          Expanded(
            child: PageTransitionSwitcher(
                child: this.result ??
                    (youtube.recommendations.isNotEmpty
                        ? CustomListView(
                            children: tileGridListWidgets(
                              context: context,
                              tileHeight: tileHeight,
                              tileWidth: tileWidth,
                              elementsPerRow: elementsPerRow,
                              subHeader: language!.STRING_RECOMMENDATIONS,
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
                                      title: language!.STRING_NO_INTERNET_TITLE,
                                      subtitle: language!
                                              .STRING_NO_INTERNET_SUBTITLE +
                                          '\n' +
                                          language!
                                              .STRING_YOUTUBE_INTERNET_ERROR,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(12.0),
                                      child: MaterialButton(
                                        color: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white.withOpacity(0.08)
                                            : Colors.black.withOpacity(0.08),
                                        elevation: 0.0,
                                        onPressed: () {
                                          youtube.updateRecommendations(
                                            Track(
                                              trackId: configuration
                                                  .discoverRecent!.first,
                                            ),
                                          );
                                        },
                                        child: Text(language!.STRING_REFRESH),
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
                          width: (MediaQuery.of(context).size.width *
                              (Platform.isLinux ? 0.75 : 1.0)),
                          child: child,
                        ))),
          ),
        ],
      ),
    );
  }
}
