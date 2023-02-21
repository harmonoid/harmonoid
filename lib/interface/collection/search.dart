/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_plus/window_plus.dart';
import 'package:media_library/media_library.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/utils/theme.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/constants.dart';
import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/interface/collection/album.dart';
import 'package:harmonoid/interface/collection/track.dart';
import 'package:harmonoid/interface/collection/artist.dart';

class SearchTab extends StatefulWidget {
  final ValueNotifier<String> query;
  SearchTab({Key? key, required this.query}) : super(key: key);
  SearchTabState createState() => SearchTabState();
}

class SearchTabState extends State<SearchTab> {
  List<Widget> albums = <Widget>[];
  List<Widget> tracks = <Widget>[];
  List<Widget> artists = <Widget>[];
  int index = 0;

  void listener() {
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
  }

  @override
  void initState() {
    super.initState();
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
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.manual,
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
                                    MaterialRoute(
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
                                                    top: tileMargin(context),
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
                                                                tileMargin(
                                                                    context)) ~/
                                                            (kAlbumTileWidth +
                                                                tileMargin(
                                                                    context)),
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
                                    MaterialRoute(
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
                                                    top: tileMargin(context),
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
                                                                tileMargin(
                                                                    context)) ~/
                                                            (kArtistTileWidth +
                                                                tileMargin(
                                                                    context)),
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

class FloatingSearchBarSearchTab extends StatefulWidget {
  final ValueNotifier<String> query;
  FloatingSearchBarSearchTab({
    Key? key,
    required this.query,
  }) : super(key: key);

  @override
  State<FloatingSearchBarSearchTab> createState() =>
      _FloatingSearchBarSearchTabState();
}

class _FloatingSearchBarSearchTabState
    extends State<FloatingSearchBarSearchTab> {
  List<Widget> albums = <Widget>[];
  List<Widget> tracks = <Widget>[];
  List<Widget> artists = <Widget>[];
  int index = 0;

  Future<void> listener() async {
    final elementsPerRow =
        (MediaQuery.of(context).size.width - tileMargin(context)) ~/
            (kAlbumTileWidth + tileMargin(context));
    final double width = (MediaQuery.of(context).size.width -
            (elementsPerRow + 1) * tileMargin(context)) /
        elementsPerRow;
    final double height = width * kAlbumTileHeight / kAlbumTileWidth;
    albums = <Widget>[];
    tracks = <Widget>[];
    artists = <Widget>[];
    final result = Collection.instance.search(widget.query.value);
    for (final media in result) {
      if (media is Album) {
        albums.addAll(
          [
            AlbumTile(
              width: width,
              height: height,
              album: media,
              forceDefaultStyleOnMobile: true,
            ),
            const SizedBox(
              width: 16.0,
            ),
          ],
        );
      }
      if (media is Artist) {
        artists.add(
          ArtistTile(
            width: -1,
            height: -1,
            artist: media,
            forceDefaultStyleOnMobile: true,
          ),
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

  @override
  Widget build(BuildContext context) {
    final elementsPerRow =
        (MediaQuery.of(context).size.width - tileMargin(context)) ~/
            (kAlbumTileWidth + tileMargin(context));
    final double width = isMobile
        ? (MediaQuery.of(context).size.width -
                (elementsPerRow + 1) * tileMargin(context)) /
            elementsPerRow
        : kAlbumTileWidth;
    final double height = isMobile
        ? width * kAlbumTileHeight / kAlbumTileWidth
        : kAlbumTileHeight;
    return Card(
      elevation: Theme.of(context).cardTheme.elevation ?? kDefaultCardElevation,
      margin: EdgeInsets.zero,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Container(
        width: MediaQuery.of(context).size.width,
        constraints: BoxConstraints(
          minHeight: (MediaQuery.of(context).size.height -
                  kMobileSearchBarHeight -
                  36.0 -
                  MediaQuery.of(context).padding.vertical -
                  MediaQuery.of(context).viewInsets.vertical)
              .clamp(480.0, (1 << 32) * 1.0),
        ),
        child: albums.isNotEmpty || artists.isNotEmpty || tracks.isNotEmpty
            ? Consumer<Collection>(
                builder: (context, _, __) => Column(
                  children: <Widget>[
                    if (albums.isNotEmpty)
                      Row(
                        children: [
                          SubHeader(Language.instance.ALBUM),
                          const Spacer(),
                          ShowAllButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialRoute(
                                  builder: (context) => Scaffold(
                                    resizeToAvoidBottomInset: false,
                                    appBar: AppBar(
                                      title: Text(
                                        Language.instance.ALBUM,
                                      ),
                                    ),
                                    body: NowPlayingBarScrollHideNotifier(
                                      child: CustomListView(
                                        padding: EdgeInsets.only(
                                          top: tileMargin(context),
                                        ),
                                        itemExtent:
                                            height + tileMargin(context),
                                        children: tileGridListWidgets(
                                          context: context,
                                          tileHeight: height,
                                          tileWidth: width,
                                          elementsPerRow:
                                              (MediaQuery.of(context)
                                                          .size
                                                          .width -
                                                      tileMargin(context)) ~/
                                                  (kAlbumTileWidth +
                                                      tileMargin(context)),
                                          leadingWidget: null,
                                          leadingSubHeader: null,
                                          subHeader: null,
                                          widgetCount: this.albums.length ~/ 2,
                                          builder: (BuildContext context,
                                                  int index) =>
                                              albums[2 * index],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 8.0),
                        ],
                      ),
                    if (albums.isNotEmpty)
                      Container(
                        height: height + 10.0,
                        width: MediaQuery.of(context).size.width,
                        child: ListView(
                          padding: EdgeInsets.only(
                            left: 16.0,
                            top: 2.0,
                            bottom: 8.0,
                          ),
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          children: albums.take(20).toList(),
                        ),
                      ),
                    if (artists.isNotEmpty)
                      Row(
                        children: [
                          SubHeader(Language.instance.ARTIST),
                          const Spacer(),
                          ShowAllButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialRoute(
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
                                            child: CustomListView(
                                              padding: EdgeInsets.symmetric(
                                                vertical: tileMargin(context),
                                              ),
                                              itemExtent:
                                                  kArtistTileListViewHeight,
                                              children: artists,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 8.0),
                        ],
                      ),
                    ...artists.take(8).toList(),
                    if (tracks.isNotEmpty)
                      Row(
                        children: [
                          SubHeader(Language.instance.TRACK),
                          const Spacer(),
                          ShowAllButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialRoute(
                                  builder: (context) => Scaffold(
                                    resizeToAvoidBottomInset: false,
                                    appBar: AppBar(
                                      title: Text(
                                        Language.instance.TRACK,
                                      ),
                                    ),
                                    body: Container(
                                      height:
                                          MediaQuery.of(context).size.height,
                                      child: Stack(
                                        children: [
                                          NowPlayingBarScrollHideNotifier(
                                            child: CustomListView(
                                              padding: EdgeInsets.symmetric(
                                                vertical: tileMargin(context),
                                              ),
                                              itemExtent:
                                                  kMobileTrackTileHeight,
                                              children: tracks,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 8.0),
                        ],
                      ),
                    ...tracks.take(4).toList(),
                  ],
                ),
              )
            : widget.query.value.isNotEmpty
                ? ExceptionWidget(
                    title: Language.instance.COLLECTION_SEARCH_NO_RESULTS_TITLE,
                    subtitle:
                        Language.instance.COLLECTION_SEARCH_NO_RESULTS_SUBTITLE,
                  )
                : ExceptionWidget(
                    title: Language.instance.COLLECTION_SEARCH_LABEL,
                    subtitle: Language.instance.COLLECTION_SEARCH_WELCOME,
                  ),
      ),
    );
  }
}
