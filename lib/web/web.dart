/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:ytm_client/ytm_client.dart';
import 'package:window_plus/window_plus.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/utils/theme.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/constants.dart';
import 'package:harmonoid/interface/settings/settings.dart';
import 'package:harmonoid/interface/collection/playlist.dart';
import 'package:harmonoid/constants/language.dart';
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
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: WindowPlus.instance.captionHeight + kDesktopAppBarHeight,
              ),
              child: PageTransitionSwitcher(
                duration:
                    Theme.of(context).extension<AnimationDuration>()?.medium ??
                        Duration.zero,
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
              margin: EdgeInsets.only(top: WindowPlus.instance.captionHeight),
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
                      ].asMap().entries.map(
                        (tab) {
                          return InkWell(
                            borderRadius: BorderRadius.circular(4.0),
                            onTap: () {
                              if (_index == tab.key) return;
                              setState(() {
                                _index = tab.key;
                              });
                            },
                            child: Container(
                              height: 40.0,
                              padding: EdgeInsets.symmetric(horizontal: 4.0),
                              alignment: Alignment.center,
                              margin: EdgeInsets.symmetric(horizontal: 4.0),
                              child: Text(
                                tab.value.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: _index == tab.key
                                      ? FontWeight.w600
                                      : FontWeight.w300,
                                  color: _index == tab.key
                                      ? Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color
                                      : Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color,
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
                            MaterialRoute(
                              builder: (context) => Settings(),
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
                  const SizedBox(width: 16.0),
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
  bool shouldRefreshOnDidChangeDependencies = true;
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
    final elementsPerRow =
        (MediaQuery.of(context).size.width - tileMargin(context)) ~/
            (kLargeTileWidth + tileMargin(context));
    final double width = kLargeTileWidth;
    final double height = kLargeTileHeight;

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
                                (elementsPerRow - 1) * tileMargin(context))) /
                        2,
                    right: (MediaQuery.of(context).size.width -
                            (elementsPerRow * kLargeTileWidth +
                                (elementsPerRow - 1) * tileMargin(context))) /
                        2,
                    top: tileMargin(context),
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
                        child: const CircularProgressIndicator(),
                      ),
                    ),
                    firstPageProgressIndicatorBuilder: (_) => Center(
                      child: const CircularProgressIndicator(),
                    ),
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: elementsPerRow,
                    childAspectRatio: width / height,
                    mainAxisSpacing: tileMargin(context),
                    crossAxisSpacing: tileMargin(context),
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
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          DesktopAppBar(
            title: Language.instance.RESULTS_FOR_QUERY
                .replaceAll('QUERY', query.trim()),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                WebSearchBar(query: this.query),
                const SizedBox(width: 8.0),
                Material(
                  color: Colors.transparent,
                  child: Tooltip(
                    message: Language.instance.SETTING,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialRoute(
                            builder: (context) => Settings(),
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
              top: WindowPlus.instance.captionHeight + kDesktopAppBarHeight,
            ),
            child: CustomFutureBuilder<Map<String, List<Media>>>(
              future: future,
              loadingBuilder: (context) => Center(
                child: const CircularProgressIndicator(),
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
                      title:
                          Language.instance.COLLECTION_SEARCH_NO_RESULTS_TITLE,
                      subtitle: Language.instance.WEB_NO_RESULTS,
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
