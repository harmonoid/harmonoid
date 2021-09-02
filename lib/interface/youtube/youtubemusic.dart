import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:harmonoid/core/configuration.dart';

import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/youtubemusic.dart';
import 'package:harmonoid/interface/changenotifiers.dart';
import 'package:harmonoid/interface/youtube/youtubetile.dart';
import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:provider/provider.dart';

class YouTubeMusic extends StatefulWidget {
  const YouTubeMusic({Key? key}) : super(key: key);
  YouTubeMusicState createState() => YouTubeMusicState();
}

class YouTubeMusicState extends State<YouTubeMusic> {
  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    YouTubeState youtube = Provider.of<YouTubeState>(
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
    Provider.of<CurrentlyPlaying>(context, listen: false).isBuffering = true;
    await track.attachAudioStream();
    await Playback.play(
      index: 0,
      tracks: [
        track,
      ],
    );
    Provider.of<CurrentlyPlaying>(context, listen: false).isBuffering = false;
    await configuration.save(
      discoverRecent: [
        track.trackId!,
      ],
    );
  }

  TextEditingController controller = TextEditingController();
  Widget? result;
  @override
  Widget build(BuildContext context) {
    int elementsPerRow = MediaQuery.of(context).size.width ~/ (156 + 8);
    double tileWidth =
        (MediaQuery.of(context).size.width - 16 - (elementsPerRow - 1) * 8) /
            elementsPerRow;
    double tileHeight = tileWidth * 246.0 / 156;
    return Consumer<YouTubeState>(
      builder: (context, youtube, _) => Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.all(8.0),
            height: 56.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.black.withOpacity(0.08),
            ),
            width: MediaQuery.of(context).size.width - 16,
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
                              this.controller.clear();
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
                  child: TextField(
                    controller: this.controller,
                    autofocus: true,
                    cursorWidth: 1.0,
                    style: Theme.of(context).textTheme.headline4,
                    onSubmitted: (String query) async {
                      this.setState(() {
                        this.result = Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(
                              Theme.of(context).primaryColor,
                            ),
                          ),
                        );
                      });
                      ScrollController _controller = ScrollController();
                      List<Track> tracks = await YTM.search(query);
                      this.result = tracks.isNotEmpty
                          ? ListView(
                              controller: _controller,
                              children: tracks
                                  .map(
                                    (track) => ListTile(
                                      onTap: () => this.play(
                                        track,
                                      ),
                                      leading: CircleAvatar(
                                        backgroundImage: NetworkImage(
                                            track.networkAlbumArt!),
                                      ),
                                      title: Text(track.trackName!),
                                      subtitle: Text(
                                          track.trackArtistNames!.join(', ')),
                                      trailing: IconButton(
                                        onPressed: () => this.play(
                                          track,
                                        ),
                                        icon: Icon(
                                          FluentIcons.play_circle_20_regular,
                                          size: 20.0,
                                          color:
                                              Theme.of(context).iconTheme.color,
                                        ),
                                        iconSize:
                                            Theme.of(context).iconTheme.size!,
                                        splashRadius:
                                            Theme.of(context).iconTheme.size! -
                                                8,
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
                      Future.delayed(Duration(milliseconds: 200), () {
                        _controller
                          ..animateTo(
                            0.0,
                            duration: Duration(milliseconds: 50),
                            curve: Curves.easeInOut,
                          );
                      });
                    },
                    decoration: InputDecoration.collapsed(
                      hintText: language!.STRING_YOUTUBE_WELCOME,
                      hintStyle: Theme.of(context).textTheme.headline3,
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
                        ? ListView(
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
                                action: () => this.play(
                                  youtube.recommendations[index],
                                ),
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
                          width: MediaQuery.of(context).size.width,
                          child: child,
                        ))),
          ),
        ],
      ),
    );
  }
}
