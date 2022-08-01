/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/models/media.dart';
import 'package:harmonoid/utils/dimensions.dart';
import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/core/playback.dart';
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
              index: Collection.instance.tracks.indexOf(media),
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
                                                    top: desktopTitleBarHeight +
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
                                                elevation: 4.0,
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
                                                    top: desktopTitleBarHeight +
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
                                                elevation: 4.0,
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
  late VoidCallback listener;

  @override
  void initState() {
    super.initState();
    listener = () {
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
                width: kArtistTileWidth,
                height: kArtistTileHeight,
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
              index: Collection.instance.tracks.indexOf(media),
            ),
          );
        }
      }
      setState(() {});
    };
    widget.query.addListener(listener);
  }

  @override
  void dispose() {
    widget.query.removeListener(listener);
    super.dispose();
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
    return Card(
      elevation: 4.0,
      margin: EdgeInsets.zero,
      child: SizedBox(
        height: MediaQuery.of(context).size.height -
            kMobileSearchBarHeight -
            36.0 -
            MediaQuery.of(context).padding.vertical -
            MediaQuery.of(context).viewInsets.vertical,
        width: MediaQuery.of(context).size.width,
        child: albums.isNotEmpty || artists.isNotEmpty || tracks.isNotEmpty
            ? Consumer<Collection>(
                builder: (context, _, __) => CustomListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    if (albums.isNotEmpty)
                      Row(
                        children: [
                          SubHeader(Language.instance.ALBUM),
                          const Spacer(),
                          ShowAllButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => Scaffold(
                                    resizeToAvoidBottomInset: false,
                                    appBar: AppBar(
                                      title: Text(
                                        Language.instance.ALBUM,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline6,
                                      ),
                                    ),
                                    body: NowPlayingBarScrollHideNotifier(
                                      child: CustomListView(
                                        padding: EdgeInsets.symmetric(
                                            vertical: tileMargin),
                                        children: tileGridListWidgets(
                                          context: context,
                                          tileHeight: height,
                                          tileWidth: width,
                                          elementsPerRow:
                                              (MediaQuery.of(context)
                                                          .size
                                                          .width -
                                                      tileMargin) ~/
                                                  (kAlbumTileWidth +
                                                      tileMargin),
                                          subHeader: null,
                                          leadingSubHeader: null,
                                          widgetCount: this.albums.length ~/ 2,
                                          leadingWidget: Container(),
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
                          const SizedBox(
                            width: 20.0,
                          ),
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
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => Scaffold(
                                    resizeToAvoidBottomInset: false,
                                    appBar: AppBar(
                                      title: Text(
                                        Language.instance.ARTIST,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline6,
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
                                                  vertical: tileMargin),
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
                          const SizedBox(
                            width: 20.0,
                          ),
                        ],
                      ),
                    ...artists.take(4),
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
                    ...tracks,
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
