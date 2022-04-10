/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///
import 'dart:io';
import 'dart:math';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:ytm_client/ytm_client.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/dimensions.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/interface/settings/settings.dart';
import 'package:harmonoid/interface/collection/playlist.dart';
import 'package:harmonoid/web/utils/widgets.dart';
import 'package:harmonoid/web/artist.dart';
import 'package:harmonoid/web/track.dart';
import 'package:harmonoid/web/album.dart';
import 'package:harmonoid/web/video.dart';
import 'package:harmonoid/web/playlist.dart';
import 'package:harmonoid/web/utils/dimensions.dart';

class WebTab extends StatefulWidget {
  const WebTab({Key? key}) : super(key: key);
  WebTabState createState() => WebTabState();
}

class WebTabState extends State<WebTab> with AutomaticKeepAliveClientMixin {
  int _index = 0;
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return PageStorage(
      bucket: PageStorageBucket(),
      child: Scaffold(
        body: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: desktopTitleBarHeight + kDesktopAppBarHeight,
              ),
              child: PageTransitionSwitcher(
                transitionBuilder:
                    (child, primaryAnimation, secondaryAnimation) =>
                        SharedAxisTransition(
                  fillColor: Theme.of(context).scaffoldBackgroundColor,
                  animation: primaryAnimation,
                  secondaryAnimation: secondaryAnimation,
                  child: child,
                  transitionType: SharedAxisTransitionType.vertical,
                ),
                child: [
                  WebRecommendations(
                    key: PageStorageKey(0),
                  ),
                  PlaylistTab(),
                ][_index],
              ),
            ),
            DesktopAppBar(),
            Container(
              margin: EdgeInsets.only(top: desktopTitleBarHeight),
              alignment: Alignment.center,
              height: kDesktopAppBarHeight,
              child: Row(
                children: [
                  const SizedBox(width: 64.0),
                  Material(
                    color: Colors.transparent,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Language.instance.RECOMMENDATIONS,
                        Language.instance.PLAYLIST,
                      ].map(
                        (tab) {
                          final i = [
                            Language.instance.RECOMMENDATIONS,
                            Language.instance.PLAYLIST,
                          ].indexOf(tab);
                          return InkWell(
                            borderRadius: BorderRadius.circular(4.0),
                            onTap: () {
                              if (_index == i) return;
                              setState(() {
                                _index = i;
                              });
                            },
                            child: Container(
                              height: 40.0,
                              padding: EdgeInsets.symmetric(horizontal: 4.0),
                              alignment: Alignment.center,
                              margin: EdgeInsets.symmetric(horizontal: 4.0),
                              child: Text(
                                tab.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: _index == i
                                      ? FontWeight.w600
                                      : FontWeight.w300,
                                  color: (Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : Colors.black)
                                      .withOpacity(_index == i ? 1.0 : 0.67),
                                ),
                              ),
                            ),
                          );
                        },
                      ).toList(),
                    ),
                  ),
                  Spacer(),
                  WebSearchBar(),
                  SizedBox(
                    width: 8.0,
                  ),
                  Material(
                    color: Colors.transparent,
                    child: Tooltip(
                      message: Language.instance.SETTING,
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      FadeThroughTransition(
                                fillColor: Colors.transparent,
                                animation: animation,
                                secondaryAnimation: secondaryAnimation,
                                child: Settings(),
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(20.0),
                        child: Container(
                          height: 40.0,
                          width: 40.0,
                          child: Icon(
                            Icons.settings,
                            size: 20.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 16.0,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WebRecommendations extends StatefulWidget {
  WebRecommendations({Key? key}) : super(key: key);

  @override
  State<WebRecommendations> createState() => _WebRecommendationsState();
}

class _WebRecommendationsState extends State<WebRecommendations>
    with AutomaticKeepAliveClientMixin {
  PagingController<int, Track> _pagingController =
      PagingController<int, Track>(firstPageKey: 0);
  late ScrollController _scrollController = ScrollController();
  final int _velocity = 40;

  @override
  void initState() {
    super.initState();
    if (Platform.isWindows) {
      _scrollController.addListener(
        () {
          final scrollDirection =
              _scrollController.position.userScrollDirection;
          if (scrollDirection != ScrollDirection.idle) {
            var scrollEnd = _scrollController.offset +
                (scrollDirection == ScrollDirection.reverse
                    ? _velocity
                    : -_velocity);
            scrollEnd = min(_scrollController.position.maxScrollExtent,
                max(_scrollController.position.minScrollExtent, scrollEnd));
            _scrollController.jumpTo(scrollEnd);
          }
        },
      );
    }
    _pagingController.addPageRequestListener(fetchNextPage);
  }

  @override
  void dispose() {
    _pagingController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void fetchNextPage(int pageKey) async {
    try {
      final items =
          await YTMClient.next(Configuration.instance.webRecent.first);
      Configuration.instance.save(
        webRecent: [items.last.id],
      );
      _pagingController.appendPage(
        items.skip(1).toList(),
        pageKey + 1,
      );
    } catch (_) {
      fetchNextPage(pageKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final elementsPerRow = (MediaQuery.of(context).size.width - tileMargin) ~/
        (kLargeTileWidth + tileMargin);
    final double width = isMobile
        ? (MediaQuery.of(context).size.width -
                (elementsPerRow + 1) * tileMargin) /
            kLargeTileWidth
        : kLargeTileWidth;
    final double height = isMobile
        ? width * kLargeTileHeight / kLargeTileWidth
        : kLargeTileHeight;

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        if (Configuration.instance.webRecent.isEmpty)
          Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Center(
              child: ExceptionWidget(
                title: Language.instance.WEB_WELCOME_TITLE,
                subtitle: Language.instance.WEB_WELCOME_SUBTITLE,
              ),
            ),
          ),
        if (Configuration.instance.webRecent.isNotEmpty)
          Center(
            child: Container(
              alignment: Alignment.topCenter,
              width: MediaQuery.of(context).size.width,
              child: Center(
                child: PagedGridView<int, Track>(
                  scrollController: _scrollController,
                  padding: EdgeInsets.only(
                    left: (MediaQuery.of(context).size.width -
                            (elementsPerRow * kLargeTileWidth +
                                (elementsPerRow - 1) * tileMargin)) /
                        2,
                    right: (MediaQuery.of(context).size.width -
                            (elementsPerRow * kLargeTileWidth +
                                (elementsPerRow - 1) * tileMargin)) /
                        2,
                    top: tileMargin,
                  ),
                  showNewPageProgressIndicatorAsGridChild: false,
                  pagingController: _pagingController,
                  builderDelegate: PagedChildBuilderDelegate<Track>(
                    itemBuilder: (context, item, pageKey) =>
                        item.thumbnails.containsKey(120)
                            ? WebTrackLargeTile(
                                height: height,
                                width: width,
                                track: item,
                              )
                            : WebVideoLargeTile(
                                height: height,
                                width: width,
                                track: item,
                              ),
                    newPageProgressIndicatorBuilder: (_) => Container(
                      height: 96.0,
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(
                            Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                    firstPageProgressIndicatorBuilder: (_) => Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(
                          Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: elementsPerRow,
                    childAspectRatio: width / height,
                    mainAxisSpacing: tileMargin,
                    crossAxisSpacing: tileMargin,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class WebSearch extends StatelessWidget {
  final String query;
  final Future<Map<String, List<Media>>> future;

  const WebSearch({
    Key? key,
    required this.query,
    required this.future,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          DesktopAppBar(
            child: Row(
              children: [
                Text(
                  Language.instance.RESULTS_FOR_QUERY
                      .replaceAll('QUERY', query.trim()),
                  style: Theme.of(context).textTheme.headline1,
                ),
                Spacer(),
                WebSearchBar(query: this.query),
                SizedBox(
                  width: 8.0,
                ),
                Material(
                  color: Colors.transparent,
                  child: Tooltip(
                    message: Language.instance.SETTING,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    FadeThroughTransition(
                              fillColor: Colors.transparent,
                              animation: animation,
                              secondaryAnimation: secondaryAnimation,
                              child: Settings(),
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(20.0),
                      child: Container(
                        height: 40.0,
                        width: 40.0,
                        child: Icon(
                          Icons.settings,
                          size: 20.0,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 16.0,
                ),
              ],
            ),
          ),
          Container(
              margin: EdgeInsets.only(
                top: desktopTitleBarHeight + kDesktopAppBarHeight,
              ),
              child: FutureBuilder<Map<String, List<Media>>>(
                future: future,
                builder: (context, asyncSnapshot) {
                  if (asyncSnapshot.hasData) {
                    if (asyncSnapshot.data!.isNotEmpty) {
                      final widgets = <Widget>[];
                      asyncSnapshot.data!.forEach(
                        (key, value) {
                          widgets.add(
                            Row(
                              children: [
                                SubHeader(key),
                                Spacer(),
                                // if (!key.contains('Top result'))
                                //   ShowAllButton(
                                //     onPressed: () {
                                //       // TODO: Handle [ShowAllButton].
                                //     },
                                //   ),
                              ],
                            ),
                          );
                          value.forEach(
                            (element) {
                              if (element is Track) {
                                widgets.add(WebTrackTile(track: element));
                              } else if (element is Artist) {
                                widgets.add(WebArtistTile(artist: element));
                              } else if (element is Video) {
                                widgets.add(VideoTile(video: element));
                              } else if (element is Album) {
                                widgets.add(WebAlbumTile(album: element));
                              } else if (element is Playlist) {
                                widgets.add(WebPlaylistTile(playlist: element));
                              }
                            },
                          );
                        },
                      );
                      return CustomListView(
                        shrinkWrap: true,
                        children: [
                          Center(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: 840.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: widgets,
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Center(
                        child: ExceptionWidget(
                          title: Language
                              .instance.COLLECTION_SEARCH_NO_RESULTS_TITLE,
                          subtitle: Language.instance.WEB_NO_RESULTS,
                        ),
                      );
                    }
                  } else {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(
                          Theme.of(context).primaryColor,
                        ),
                      ),
                    );
                  }
                },
              )),
        ],
      ),
    );
  }
}
