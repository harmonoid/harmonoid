/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_plus/window_plus.dart';
import 'package:media_library/media_library.dart';

import 'package:harmonoid/interface/modern_layout/modern_collection/modern_album.dart';
import 'package:harmonoid/interface/modern_layout/modern_collection/modern_artist.dart';
import 'package:harmonoid/interface/modern_layout/modern_collection/modern_track.dart';
import 'package:harmonoid/interface/modern_layout/utils_modern/broken_icons.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/dimensions.dart';
import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/interface/collection/album.dart';
import 'package:harmonoid/interface/collection/track.dart';
import 'package:harmonoid/interface/collection/artist.dart';

class SearchTabModern extends StatefulWidget {
  final ValueNotifier<String> query;
  SearchTabModern({Key? key, required this.query}) : super(key: key);
  SearchTabModernState createState() => SearchTabModernState();
}

class SearchTabModernState extends State<SearchTabModern> {
  List<Widget> albums = <Widget>[];
  List<Widget> tracks = <Widget>[];
  List<Widget> artists = <Widget>[];
  int index = 0;
  late Future<void> Function() listener;

  @override
  void initState() {
    super.initState();
    listener = () async {
      albums = <Widget>[];
      tracks = <Widget>[];
      artists = <Widget>[];
      final result = Collection.instance.search(widget.query.value);
      for (final media in result) {
        if (media is Album) {
          albums.addAll(
            [
              AlbumTile(
                height: kAlbumTileHeight,
                width: kAlbumTileWidth,
                album: media,
              ),
              const SizedBox(
                width: 16.0,
              ),
            ],
          );
        }
        if (media is Artist) {
          artists.addAll(
            [
              ArtistTile(
                height: kArtistTileHeight,
                width: kArtistTileWidth,
                artist: media,
              ),
              const SizedBox(
                width: 16.0,
              ),
            ],
          );
        } else if (media is Track) {
          tracks.add(
            TrackTile(
              track: media,
              index: 0,
              group: [
                media,
              ],
            ),
          );
        }
      }
    };
    widget.query.addListener(listener);
    listener();
  }

  @override
  void dispose() {
    widget.query.removeListener(listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Collection>(
      builder: (context, collection, _) {
        listener();
        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: albums.isNotEmpty || artists.isNotEmpty || tracks.isNotEmpty
              ? CustomListView(
                  children: <Widget>[
                        if (albums.isNotEmpty)
                          Row(
                            children: [
                              SubHeader(Language.instance.ALBUM),
                              const Spacer(),
                              ShowAllButton(
                                onPressed: () {
                                  Playback.instance
                                      .interceptPositionChangeRebuilds = true;
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => Scaffold(
                                        resizeToAvoidBottomInset: false,
                                        body: Container(
                                          height: MediaQuery.of(context)
                                              .size
                                              .height,
                                          child: Stack(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    top: WindowPlus.instance
                                                            .captionHeight +
                                                        kDesktopAppBarHeight),
                                                child: CustomListView(
                                                  padding: EdgeInsets.only(
                                                    top: tileMargin,
                                                  ),
                                                  children: tileGridListWidgets(
                                                    context: context,
                                                    tileHeight:
                                                        kAlbumTileHeight,
                                                    tileWidth: kAlbumTileWidth,
                                                    elementsPerRow:
                                                        (MediaQuery.of(context)
                                                                    .size
                                                                    .width -
                                                                tileMargin) ~/
                                                            (kAlbumTileWidth +
                                                                tileMargin),
                                                    subHeader: null,
                                                    leadingSubHeader: null,
                                                    widgetCount:
                                                        this.albums.length ~/ 2,
                                                    leadingWidget: Container(),
                                                    builder:
                                                        (BuildContext context,
                                                                int index) =>
                                                            albums[2 * index],
                                                  ),
                                                ),
                                              ),
                                              DesktopAppBar(
                                                title: Language.instance.ALBUM,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                  Timer(const Duration(milliseconds: 400), () {
                                    Playback.instance
                                            .interceptPositionChangeRebuilds =
                                        false;
                                  });
                                },
                              ),
                              const SizedBox(
                                width: 20.0,
                              ),
                            ],
                          ),
                        if (albums.isNotEmpty)
                          Container(
                            height: kAlbumTileHeight + 10.0,
                            width: MediaQuery.of(context).size.width,
                            child: ListView(
                              padding: EdgeInsets.only(
                                left: 16.0,
                                top: 2.0,
                                bottom: 8.0,
                              ),
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              children: albums,
                            ),
                          ),
                        if (artists.isNotEmpty)
                          Row(
                            children: [
                              SubHeader(Language.instance.ARTIST),
                              const Spacer(),
                              ShowAllButton(
                                onPressed: () {
                                  Playback.instance
                                      .interceptPositionChangeRebuilds = true;
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => Scaffold(
                                        resizeToAvoidBottomInset: false,
                                        body: Container(
                                          height: MediaQuery.of(context)
                                              .size
                                              .height,
                                          child: Stack(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    top: WindowPlus.instance
                                                            .captionHeight +
                                                        kDesktopAppBarHeight),
                                                child: CustomListView(
                                                  padding: EdgeInsets.only(
                                                    top: tileMargin,
                                                  ),
                                                  children: tileGridListWidgets(
                                                    context: context,
                                                    tileHeight:
                                                        kArtistTileHeight,
                                                    tileWidth: kArtistTileWidth,
                                                    elementsPerRow:
                                                        (MediaQuery.of(context)
                                                                    .size
                                                                    .width -
                                                                tileMargin) ~/
                                                            (kArtistTileWidth +
                                                                tileMargin),
                                                    subHeader: null,
                                                    leadingSubHeader: null,
                                                    widgetCount:
                                                        this.artists.length ~/
                                                            2,
                                                    leadingWidget: Container(),
                                                    builder:
                                                        (BuildContext context,
                                                                int index) =>
                                                            artists[2 * index],
                                                  ),
                                                ),
                                              ),
                                              DesktopAppBar(
                                                title: Language.instance.ARTIST,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                  Timer(const Duration(milliseconds: 400), () {
                                    Playback.instance
                                            .interceptPositionChangeRebuilds =
                                        false;
                                  });
                                },
                              ),
                              const SizedBox(
                                width: 20.0,
                              ),
                            ],
                          ),
                        if (artists.isNotEmpty)
                          Container(
                            height: kArtistTileHeight + 10.0,
                            width: MediaQuery.of(context).size.width,
                            child: ListView(
                              padding: EdgeInsets.only(
                                left: 16.0,
                                top: 2.0,
                                bottom: 8.0,
                              ),
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              children: artists,
                            ),
                          ),
                        if (tracks.isNotEmpty)
                          Row(
                            children: [
                              SubHeader(Language.instance.TRACK),
                              const Spacer(),
                              const SizedBox(
                                width: 20.0,
                              ),
                            ],
                          ),
                      ] +
                      tracks,
                )
              : Center(
                  child: ExceptionWidget(
                    title: Language.instance.COLLECTION_SEARCH_NO_RESULTS_TITLE,
                    subtitle:
                        Language.instance.COLLECTION_SEARCH_NO_RESULTS_SUBTITLE,
                  ),
                ),
        );
      },
    );
  }
}

class FloatingSearchBarSearchTabModern extends StatefulWidget {
  final ValueNotifier<String> query;
  FloatingSearchBarSearchTabModern({
    Key? key,
    required this.query,
  }) : super(key: key);

  @override
  State<FloatingSearchBarSearchTabModern> createState() =>
      _FloatingSearchBarSearchTabModernState();
}

class _FloatingSearchBarSearchTabModernState
    extends State<FloatingSearchBarSearchTabModern> {
  List<Widget> albums = <Widget>[];
  List<Album> albumsOnly = <Album>[];
  List<Widget> tracks = <Widget>[];
  List<Track> tracksOnly = <Track>[];
  List<Widget> artists = <Widget>[];
  List<Artist> artistsOnly = <Artist>[];
  int index = 0;

  Future<void> listener() async {
    final elementsPerRow = (MediaQuery.of(context).size.width - tileMargin) ~/
        (kAlbumTileWidth + tileMargin);
    final double width = (MediaQuery.of(context).size.width -
            (elementsPerRow + 1) * tileMargin) /
        elementsPerRow;
    final double height = width * kAlbumTileHeight / kAlbumTileWidth;
    albums = <Widget>[];
    tracks = <Widget>[];
    tracksOnly = <Track>[];
    albumsOnly = <Album>[];
    artistsOnly = <Artist>[];
    artists = <Widget>[];
    final result = Collection.instance.search(widget.query.value);
    for (final media in result) {
      if (media is Album) {
        albumsOnly.add(media);
        albums.addAll(
          [
            AlbumTileModern(
              width: width / 1.3,
              height: height / 1.3,
              album: media,
              forceDefaultStyleOnMobile: false,
              forceDisableOnePerRow: true,
            ),
            const SizedBox(
              width: 16.0,
            ),
          ],
        );
      }
      if (media is Artist) {
        artistsOnly.add(media);
        artists.addAll(
          [
            ArtistTileModern(
              width: width / 2.4,
              height: height / 2.4,
              artist: media,
              forceDefaultStyleOnMobile: false,
              forceDisableOnePerRow: true,
            ),
            const SizedBox(
              width: 16.0,
            ),
          ],
        );
      } else if (media is Track) {
        tracksOnly.add(media);
        tracks.add(
          TrackTileModern(
            track: media,
            index: 0,
            group: [
              media,
            ],
            onPressed: () {
              trackTileOnPressed(media);
            },
          ),
        );
      }
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    widget.query.addListener(listener);
  }

  @override
  void dispose() {
    widget.query.removeListener(listener);
    super.dispose();
  }

  void _changeSearchPlayMode() {
    if (Configuration.instance.searchResultsPlayMode == 1) {
      Configuration.instance.save(searchResultsPlayMode: 2);
    } else if (Configuration.instance.searchResultsPlayMode == 2) {
      Configuration.instance.save(searchResultsPlayMode: 3);
    } else if (Configuration.instance.searchResultsPlayMode == 3) {
      Configuration.instance.save(searchResultsPlayMode: 4);
    } else if (Configuration.instance.searchResultsPlayMode == 4) {
      Configuration.instance.save(searchResultsPlayMode: 1);
    } else {
      Configuration.instance.save(searchResultsPlayMode: 1);
    }
  }

  String get searchPlayModeText {
    if (Configuration.instance.searchResultsPlayMode == 1) {
      return 'Play: Selected Track Only';
    } else if (Configuration.instance.searchResultsPlayMode == 2) {
      return 'Play: All Search Results';
    } else if (Configuration.instance.searchResultsPlayMode == 3) {
      return 'Play: Selected Track\'s Album';
    } else if (Configuration.instance.searchResultsPlayMode == 4) {
      return 'Play: Selected Track\'s Main Artist';
    }
    return '';
  }

  void trackTileOnPressed(Track track) {
    bool isTrackCurrentlyPlaying = Playback.instance.tracks.isNotEmpty &&
        Playback.instance.tracks[Playback.instance.index] ==
            tracksOnly[tracksOnly.indexOf(track)] &&
        Playback.instance.index == tracksOnly.indexOf(track);

    if (isTrackCurrentlyPlaying) {
      Playback.instance.playOrPause();
    } else if (Configuration.instance.searchResultsPlayMode == 1) {
      Playback.instance.open(
        [track],
        index: 0,
      );
    } else if (Configuration.instance.searchResultsPlayMode == 2) {
      Playback.instance.open(
        tracksOnly,
        index: tracksOnly.indexOf(track),
      );
    } else if (Configuration.instance.searchResultsPlayMode == 3) {
      late final Album album;
      for (final item in Collection.instance.albums) {
        if (item.albumName == track.albumName &&
            item.albumArtistName == track.albumArtistName) {
          album = item;
          break;
        }
      }
      Playback.instance.open(
        album.tracks.toList(),
        index: album.tracks.toList().indexOf(track),
      );

      // UNCOMMENT IF YOU WANT TO INSERT SELECTED TRACK AT THE FIRST INDEX
      insertTrackAtFirstIndexAndPlay(track, album.tracks.toList());
    } else if (Configuration.instance.searchResultsPlayMode == 4) {
      late final Artist artist;
      for (final item in Collection.instance.artists) {
        if (item.artistName == track.trackArtistNames[0]) {
          artist = item;
          break;
        }
      }
      Playback.instance.open(
        artist.tracks.toList(),
        index: artist.tracks.toList().indexOf(track),
      );
      insertTrackAtFirstIndexAndPlay(track, artist.tracks.toList());
    } else {
      Playback.instance.open(
        [track],
        index: 0,
      );
    }
  }

  void insertTrackAtFirstIndexAndPlay(Track track, List<Track> tracksList) {
    Playback.instance.tracks = [];
    Playback.instance.tracks.add(track);
    Playback.instance.tracks.addAll(tracksList);
    Playback.instance.notify();
    Playback.instance.open(Playback.instance.tracks, index: 0);
  }

  @override
  Widget build(BuildContext context) {
    final elementsPerRow = (MediaQuery.of(context).size.width - tileMargin) ~/
        (kAlbumTileWidth + tileMargin);
    final double width = isMobile
        ? (MediaQuery.of(context).size.width -
                (elementsPerRow + 1) * tileMargin) /
            elementsPerRow
        : kAlbumTileWidth;
    final double height = isMobile
        ? width * kAlbumTileHeight / kAlbumTileWidth
        : kAlbumTileHeight;
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
      child: Container(
        // elevation: Theme.of(context).cardTheme.elevation ?? kDefaultCardElevation,
        // margin: EdgeInsets.only(bottom: WidgetsBinding.instance.window.viewInsets.bottom > 0.0 ? kMobileNowPlayingBarHeight + 85 + kMobileBottomPaddingStickyMiniplayer * 2 : kMobileNowPlayingBarHeight + kMobileBottomPaddingStickyMiniplayer),
        margin: EdgeInsets.zero,
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SizedBox(
          // height: (MediaQuery.of(context).size.height - kMobileSearchBarHeightModern - 36.0 - MediaQuery.of(context).padding.vertical - MediaQuery.of(context).viewInsets.vertical).clamp(480.0, 1 << 32).toDouble() -

          // fixes bottom padding in search card, even when sticky miniplayer is disabled.
          // a check wether the keyboard is shown or not, please dont try to understand this part.
          // also the keyboard now wont hide on scroll, more convenient this way.

          // (Configuration.instance.stickyMiniplayer && !MobileNowPlayingController.instance.isHidden
          //     ? WidgetsBinding.instance.window.viewInsets.bottom > 0.0
          //         ? kMobileNowPlayingBarHeight
          //         : kMobileNowPlayingBarHeight + kBottomNavigationBarHeight
          //     : kBottomNavigationBarHeight + kMobileBottomPaddingStickyMiniplayer),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: albums.isNotEmpty ||
                  artists.isNotEmpty ||
                  tracksOnly.isNotEmpty
              ? Consumer<Collection>(
                  builder: (context, _, __) => ListView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.manual,
                    // padding: EdgeInsets.only(
                    //   // Card bottom Border radius is clipped if this was 0
                    //   bottom: kMobileNowPlayingBarHeight - 1,
                    // ),
                    shrinkWrap: true,
                    children: <Widget>[
                      if (albums.isNotEmpty)
                        Container(
                          margin: EdgeInsets.only(left: 6.0),
                          child: ListTile(
                            leading: Icon(
                              Broken.music_dashboard,
                              color: Color.alphaBlend(
                                  Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withAlpha(200),
                                  Theme.of(context).colorScheme.onBackground),
                            ),
                            title: Text(
                              Language.instance.ALBUM,
                              style: TextStyle(
                                color: Color.alphaBlend(
                                    Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withAlpha(100),
                                    Theme.of(context).colorScheme.onBackground),
                              ),
                            ),
                            trailing: TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => Scaffold(
                                      resizeToAvoidBottomInset: false,
                                      appBar: AppBar(
                                        title: Text(
                                          Language.instance.ALBUM,
                                        ),
                                      ),
                                      body: NowPlayingBarScrollHideNotifier(
                                        child: AlbumTabModern(
                                            albumsList: albumsOnly),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Broken.category,
                                    size: 20.0,
                                  ),
                                  SizedBox(
                                    width: 12.0,
                                  ),
                                  Text(Language.instance.SEE_ALL),
                                ],
                              ),
                            ),
                          ),
                        ),

                      if (albums.isNotEmpty)
                        Container(
                          height: height / 1.3 + 10.0,
                          width: MediaQuery.of(context).size.width,
                          child: ListView(
                            padding: EdgeInsets.only(
                              left: 16.0,
                              top: 2.0,
                              bottom: 8.0,
                            ),
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            children: albums,
                          ),
                        ),
                      if (artists.isNotEmpty)
                        Container(
                          margin: EdgeInsets.only(left: 6.0),
                          child: ListTile(
                            leading: Icon(
                              Broken.microphone,
                              color: Color.alphaBlend(
                                  Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withAlpha(200),
                                  Theme.of(context).colorScheme.onBackground),
                            ),
                            title: Text(
                              Language.instance.ARTIST,
                              style: TextStyle(
                                color: Color.alphaBlend(
                                    Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withAlpha(100),
                                    Theme.of(context).colorScheme.onBackground),
                              ),
                            ),
                            trailing: TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => Scaffold(
                                      resizeToAvoidBottomInset: false,
                                      appBar: AppBar(
                                        title: Text(
                                          Language.instance.ARTIST,
                                        ),
                                      ),
                                      body: Container(
                                        height:
                                            MediaQuery.of(context).size.height,
                                        child: Stack(
                                          children: [
                                            NowPlayingBarScrollHideNotifier(
                                              child: ArtistTabModern(
                                                  artistsList: artistsOnly),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Broken.category,
                                    size: 20.0,
                                  ),
                                  SizedBox(
                                    width: 12.0,
                                  ),
                                  Text(Language.instance.SEE_ALL),
                                ],
                              ),
                            ),
                          ),
                        ),

                      if (artists.isNotEmpty)
                        Container(
                          height: height / 2.4 + 10.0,
                          width: MediaQuery.of(context).size.width,
                          child: ListView(
                            padding: EdgeInsets.only(
                              left: 16.0,
                              top: 2.0,
                              bottom: 8.0,
                            ),
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            children: artists,
                          ),
                        ),
                      // ...artists.take(4),
                      if (tracksOnly.isNotEmpty)
                        Container(
                          margin: EdgeInsets.only(left: 6.0),
                          child: ListTile(
                            leading: Icon(
                              Broken.music_circle,
                              color: Color.alphaBlend(
                                  Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withAlpha(200),
                                  Theme.of(context).colorScheme.onBackground),
                            ),
                            title: Text(
                              Language.instance.TRACK,
                              style: TextStyle(
                                color: Color.alphaBlend(
                                    Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withAlpha(100),
                                    Theme.of(context).colorScheme.onBackground),
                              ),
                            ),
                            trailing: TextButton(
                              onPressed: () {
                                setState(() {
                                  _changeSearchPlayMode();
                                });
                              },
                              child: Text(searchPlayModeText),
                            ),
                          ),
                        ),
                      ...tracks,

                      // AnimationLimiter(
                      //   child: ListView.builder(
                      //     padding: EdgeInsets.only(
                      //         bottom: kMobileNowPlayingBarHeight),
                      //     controller: ScrollController(),
                      //     shrinkWrap: true,
                      //     itemCount: tracksOnly.length,
                      //     itemBuilder: (BuildContext context, int index) {
                      //       return AnimationConfiguration.staggeredList(
                      //         position: index,
                      //         delay: Duration(
                      //             milliseconds: tracksOnly.length < 20
                      //                 ? 50
                      //                 : 2000 ~/ tracksOnly.length),
                      //         child: SlideAnimation(
                      //           verticalOffset: 50,
                      //           duration: Duration(milliseconds: 1500),
                      //           curve: Curves.fastLinearToSlowEaseIn,
                      //           child: FadeInAnimation(
                      //             curve: Curves.fastLinearToSlowEaseIn,
                      //             duration: Duration(milliseconds: 1500),
                      //             child: TrackTileModern(
                      //               displayRemoveFromPlaylistItem: true,
                      //               track: tracksOnly[index],
                      //               index: index,
                      //               onPressed: () {
                      //                 trackTileOnPressed(tracksOnly[index]);
                      //               },
                      //             ),
                      //           ),
                      //         ),
                      //       );
                      //     },
                      //   ),
                      // ),
                      SizedBox(
                        height: kMobileNowPlayingBarHeight,
                      ),
                    ],
                  ),
                )
              : widget.query.value.isNotEmpty
                  ? ExceptionWidget(
                      title:
                          Language.instance.COLLECTION_SEARCH_NO_RESULTS_TITLE,
                      subtitle: Language
                          .instance.COLLECTION_SEARCH_NO_RESULTS_SUBTITLE,
                    )
                  : ExceptionWidget(
                      title: Language.instance.COLLECTION_SEARCH_LABEL,
                      subtitle: Language.instance.COLLECTION_SEARCH_WELCOME,
                    ),
        ),
      ),
    );
  }
}
