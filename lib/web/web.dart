/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animations/animations.dart';
import 'package:window_plus/window_plus.dart';
import 'package:ytm_client/ytm_client.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/dimensions.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/interface/settings/settings.dart';
import 'package:harmonoid/interface/collection/playlist.dart';
import 'package:harmonoid/web/artist.dart';
import 'package:harmonoid/web/track.dart';
import 'package:harmonoid/web/album.dart';
import 'package:harmonoid/web/video.dart';
import 'package:harmonoid/web/playlist.dart';
import 'package:harmonoid/web/utils/widgets.dart';
import 'package:harmonoid/web/utils/dimensions.dart';
import 'package:harmonoid/web/state/web.dart';

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
      child: isMobile
          ? FloatingSearchBarWebSearchScreen(
              query: '',
            )
          : Scaffold(
              resizeToAvoidBottomInset: false,
              body: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      top: WindowPlus.instance.captionHeight +
                          kDesktopAppBarHeight,
                    ),
                    child: PageTransitionSwitcher(
                      transitionBuilder:
                          (child, primaryAnimation, secondaryAnimation) =>
                              SharedAxisTransition(
                        fillColor: Colors.transparent,
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
                    margin:
                        EdgeInsets.only(top: WindowPlus.instance.captionHeight),
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
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 4.0),
                                    alignment: Alignment.center,
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 4.0),
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
                                            .withOpacity(
                                                _index == i ? 1.0 : 0.67),
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
                        if (isDesktop)
                          Material(
                            color: Colors.transparent,
                            child: Tooltip(
                              message: Language.instance.SETTING,
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation,
                                              secondaryAnimation) =>
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
                                    color: Theme.of(context)
                                        .appBarTheme
                                        .actionsIconTheme
                                        ?.color,
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
  bool shouldRefreshOnDidChangeDependencies =
      Configuration.instance.webRecent.isEmpty || isDesktop;
  final ScrollController _scrollController = ScrollController();
  final HashMap<String, Color> colorKeys = HashMap<String, Color>();

  @override
  void initState() {
    super.initState();
    Web.instance.refreshCallback = () {
      if (mounted) {
        setState(() {});
      }
    };
    Web.instance.pagingController.addPageRequestListener(fetchNextPage);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (shouldRefreshOnDidChangeDependencies) {
      Web.instance.pagingController.refresh();
      if (mounted) {
        setState(() {});
      }
      shouldRefreshOnDidChangeDependencies =
          Configuration.instance.webRecent.isEmpty;
    }
  }

  @override
  void dispose() {
    Web.instance.pagingController.removePageRequestListener(fetchNextPage);
    _scrollController.dispose();
    super.dispose();
  }

  void fetchNextPage(int pageKey) async {
    if (Configuration.instance.webRecent.isNotEmpty) {
      try {
        final items =
            await YTMClient.next(Configuration.instance.webRecent.first);
        Configuration.instance.save(
          webRecent: [items.last.id],
        );
        Web.instance.pagingController.appendPage(
          items.skip(1).toList(),
          pageKey + 1,
        );
      } catch (_) {
        fetchNextPage(pageKey);
      }
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
            elementsPerRow
        : kLargeTileWidth;
    final double height = isMobile
        ? width * kLargeTileHeight / kLargeTileWidth
        : kLargeTileHeight;

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        if (Configuration.instance.webRecent.isEmpty)
          Container(
            padding: EdgeInsets.only(
              top: isDesktop
                  ? 0.0
                  : MediaQuery.of(context).padding.top +
                      kMobileSearchBarHeight +
                      2 * tileMargin,
            ),
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
                child: RefreshIndicator(
                  displacement: MediaQuery.of(context).padding.top +
                      kMobileSearchBarHeight +
                      2 * tileMargin,
                  color: Theme.of(context).primaryColor,
                  onRefresh: () => Future.sync(
                    () => Web.instance.pagingController.refresh(),
                  ),
                  child: isDesktop
                      ? PagedGridView<int, Track>(
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
                          pagingController: Web.instance.pagingController,
                          builderDelegate: PagedChildBuilderDelegate<Track>(
                            itemBuilder: (context, item, pageKey) =>
                                item.thumbnails.containsKey(120)
                                    ? WebTrackLargeTile(
                                        height: height,
                                        width: width,
                                        track: item,
                                        colorKeys: colorKeys,
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
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: elementsPerRow,
                            childAspectRatio: width / height,
                            mainAxisSpacing: tileMargin,
                            crossAxisSpacing: tileMargin,
                          ),
                        )
                      : PagedListView(
                          pagingController: Web.instance.pagingController,
                          padding: EdgeInsets.only(
                            top: kMobileSearchBarHeight +
                                2 * tileMargin +
                                MediaQuery.of(context).padding.top,
                          ),
                          builderDelegate: PagedChildBuilderDelegate<Track>(
                            itemBuilder: (context, item, pageKey) => Padding(
                              padding: EdgeInsets.fromLTRB(
                                  tileMargin, 0, tileMargin, tileMargin),
                              child: item.thumbnails.containsKey(120)
                                  ? WebTrackLargeTile(
                                      height: 72.0,
                                      width: MediaQuery.of(context).size.width -
                                          2 * tileMargin,
                                      track: item,
                                      colorKeys: colorKeys,
                                    )
                                  : WebVideoLargeTile(
                                      height:
                                          (MediaQuery.of(context).size.width -
                                                  2 * tileMargin) *
                                              9 /
                                              16,
                                      width: MediaQuery.of(context).size.width -
                                          2 * tileMargin,
                                      track: item,
                                    ),
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
    return isDesktop
        ? Scaffold(
            resizeToAvoidBottomInset: false,
            body: Stack(
              children: [
                DesktopAppBar(
                  child: Row(
                    children: [
                      Text(
                        Language.instance.RESULTS_FOR_QUERY
                            .replaceAll('QUERY', query.trim()),
                        style: Theme.of(context).textTheme.displayLarge,
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
                                  pageBuilder: (context, animation,
                                          secondaryAnimation) =>
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
                                color: Theme.of(context)
                                    .appBarTheme
                                    .actionsIconTheme
                                    ?.color,
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
                    top: WindowPlus.instance.captionHeight +
                        kDesktopAppBarHeight,
                  ),
                  child: CustomFutureBuilder<Map<String, List<Media>>>(
                    future: future,
                    loadingBuilder: (context) => Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(
                          Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    builder: (context, data) {
                      if (data?.isNotEmpty ?? false) {
                        final widgets = <Widget>[];
                        data?.forEach(
                          (key, value) {
                            widgets.add(
                              Row(
                                children: [
                                  SubHeader(key),
                                  Spacer(),
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
                                  widgets
                                      .add(WebPlaylistTile(playlist: element));
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
                    },
                  ),
                ),
              ],
            ),
          )
        : CustomFutureBuilder<Map<String, List<Media>>>(
            future: future,
            loadingBuilder: (context) => Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(
                  Theme.of(context).primaryColor,
                ),
              ),
            ),
            builder: (context, data) {
              if (data?.isNotEmpty ?? false) {
                final widgets = <Widget>[];
                data?.forEach(
                  (key, value) {
                    widgets.add(
                      Row(
                        children: [
                          SubHeader(key),
                          Spacer(),
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
                    title: Language.instance.COLLECTION_SEARCH_NO_RESULTS_TITLE,
                    subtitle: Language.instance.WEB_NO_RESULTS,
                  ),
                );
              }
            },
          );
  }
}

class FloatingSearchBarWebSearchTab extends StatefulWidget {
  final ValueNotifier<String> query;
  FloatingSearchBarWebSearchTab({
    Key? key,
    required this.query,
  }) : super(key: key);

  @override
  State<FloatingSearchBarWebSearchTab> createState() =>
      _FloatingSearchBarWebSearchTabState();
}

class _FloatingSearchBarWebSearchTabState
    extends State<FloatingSearchBarWebSearchTab> {
  // List<String> result = [];

  @override
  void initState() {
    super.initState();
    // TODO (@alexmercerind): Broken.
    // widget.query.addListener(() {
    //   YTMClient.music_get_search_suggestions(widget.query.value).then((value) {
    //     setState(() {
    //       result = value;
    //     });
    //   });
    // });
  }

  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).scaffoldBackgroundColor,
      elevation: 4.0,
      margin: EdgeInsets.zero,
      child: SizedBox(
        height: (MediaQuery.of(context).size.height -
                kMobileSearchBarHeight -
                36.0 -
                MediaQuery.of(context).padding.vertical -
                MediaQuery.of(context).viewInsets.vertical)
            .clamp(480.0, 1 << 32)
            .toDouble(),
        width: MediaQuery.of(context).size.width,
        child: Center(
          child: ExceptionWidget(
            title: Language.instance.COLLECTION_SEARCH_LABEL,
            subtitle: Language.instance.COLLECTION_SEARCH_WELCOME,
          ),
        ),
      ),
    );
    // if (widget.query.value.isEmpty) {
    //   return Card(
    //     color: Theme.of(context).scaffoldBackgroundColor,
    //     elevation: 4.0,
    //     margin: EdgeInsets.zero,
    //     child: SizedBox(
    //       height: (MediaQuery.of(context).size.height -
    //               kMobileSearchBarHeight -
    //               36.0 -
    //               MediaQuery.of(context).padding.vertical -
    //               MediaQuery.of(context).viewInsets.vertical)
    //           .clamp(480.0, 1 << 32)
    //           .toDouble(),
    //       width: MediaQuery.of(context).size.width,
    //       child: Center(
    //         child: ExceptionWidget(
    //           title: Language.instance.COLLECTION_SEARCH_LABEL,
    //           subtitle: Language.instance.COLLECTION_SEARCH_WELCOME,
    //         ),
    //       ),
    //     ),
    //   );
    // }
    // if (result.isEmpty) {
    //   return Card(
    //     color: Theme.of(context).scaffoldBackgroundColor,
    //     elevation: 4.0,
    //     margin: EdgeInsets.zero,
    //     child: SizedBox(
    //       height: MediaQuery.of(context).size.height -
    //           kMobileSearchBarHeight -
    //           36.0 -
    //           MediaQuery.of(context).padding.vertical -
    //           MediaQuery.of(context).viewInsets.vertical,
    //       width: MediaQuery.of(context).size.width,
    //       child: Center(
    //         child: ExceptionWidget(
    //           title: Language.instance.COLLECTION_SEARCH_NO_RESULTS_TITLE,
    //           subtitle: Language.instance.WEB_NO_RESULTS,
    //         ),
    //       ),
    //     ),
    //   );
    // }
    // return Card(
    //   elevation: 4.0,
    //   margin: EdgeInsets.zero,
    //   child: SizedBox(
    //     width: MediaQuery.of(context).size.width,
    //     child: Column(
    //       children: result
    //           .map(
    //             (e) => ListTile(
    //               title: Text(
    //                 e.overflow,
    //                 maxLines: 1,
    //                 overflow: TextOverflow.ellipsis,
    //               ),
    //               onTap: () {
    //                 Navigator.of(context).push(
    //                   PageRouteBuilder(
    //                     pageBuilder: (context, animation, secondaryAnimation) =>
    //                         FadeThroughTransition(
    //                       fillColor: Colors.transparent,
    //                       animation: animation,
    //                       secondaryAnimation: secondaryAnimation,
    //                       child: FloatingSearchBarWebSearchScreen(
    //                         future: YTMClient.search(e),
    //                         query: e,
    //                       ),
    //                     ),
    //                   ),
    //                 );
    //               },
    //               leading: Icon(
    //                 Icons.search,
    //               ),
    //             ),
    //           )
    //           .toList(),
    //     ),
    //   ),
    // );
  }
}

class FloatingSearchBarWebSearchScreen extends StatefulWidget {
  final String? query;
  final Future<Map<String, List<Media>>>? future;

  FloatingSearchBarWebSearchScreen({
    Key? key,
    this.query,
    this.future,
  }) : super(key: key);

  @override
  State<FloatingSearchBarWebSearchScreen> createState() =>
      _FloatingSearchBarWebSearchScreenState();
}

class _FloatingSearchBarWebSearchScreenState
    extends State<FloatingSearchBarWebSearchScreen> {
  final FloatingSearchBarController floatingSearchBarController =
      FloatingSearchBarController();
  final FocusNode focusNode = FocusNode();
  final ValueNotifier<String> query = ValueNotifier<String>('');

  @override
  void initState() {
    super.initState();
    floatingSearchBarController.query = widget.query ?? '';
    if (widget.query == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        floatingSearchBarController.open();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.black12
            : Colors.white12,
        statusBarIconBrightness: Theme.of(context).brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: FloatingSearchBar(
          controller: floatingSearchBarController,
          automaticallyImplyBackButton: false,
          hint: Language.instance.SEARCH_WELCOME,
          transitionCurve: Curves.easeInOut,
          width: MediaQuery.of(context).size.width - 2 * tileMargin,
          height: kMobileSearchBarHeight,
          margins: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + tileMargin,
          ),
          onSubmitted: (query) {
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    FadeThroughTransition(
                  fillColor: Colors.transparent,
                  animation: animation,
                  secondaryAnimation: secondaryAnimation,
                  child: FloatingSearchBarWebSearchScreen(
                    query: query,
                    future: YTMClient.search(query),
                  ),
                ),
              ),
            );
          },
          textInputType: TextInputType.url,
          accentColor: Theme.of(context).primaryColor,
          onQueryChanged: (value) => query.value = value,
          clearQueryOnClose: false,
          transition: CircularFloatingSearchBarTransition(),
          leadingActions: [
            FloatingSearchBarAction(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.search, size: 24.0),
              ),
              showIfOpened: false,
            ),
            FloatingSearchBarAction.back(),
          ],
          actions: [
            FloatingSearchBarAction(
              showIfOpened: false,
              child: WebMobileAppBarOverflowButton(
                color: Theme.of(context).appBarTheme.actionsIconTheme?.color,
                withinScreen: false,
              ),
            ),
            FloatingSearchBarAction.searchToClear(
              showIfClosed: false,
            ),
          ],
          builder: (context, transition) {
            return FloatingSearchBarWebSearchTab(query: query);
          },
          body: widget.future == null
              ? FloatingSearchBarScrollNotifier(
                  child: NowPlayingBarScrollHideNotifier(
                    child: WebRecommendations(),
                  ),
                )
              : CustomFutureBuilder<Map<String, List<Media>>>(
                  future: widget.future,
                  loadingBuilder: (_) => Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  builder: (context, data) {
                    if (data?.isNotEmpty ?? false) {
                      final widgets = <Widget>[];
                      data?.forEach(
                        (key, value) {
                          widgets.add(
                            Row(
                              children: [
                                SubHeader(key),
                                Spacer(),
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
                      return FloatingSearchBarScrollNotifier(
                        child: NowPlayingBarScrollHideNotifier(
                          child: CustomListView(
                            padding: EdgeInsets.only(
                              top: MediaQuery.of(context).padding.top +
                                  kMobileSearchBarHeight +
                                  2 * tileMargin,
                            ),
                            shrinkWrap: true,
                            children: [
                              Center(
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: 840.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: widgets,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
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
                  },
                ),
        ),
      ),
    );
  }
}
