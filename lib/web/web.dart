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
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:ytm_client/ytm_client.dart';
import 'package:substring_highlight/substring_highlight.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'package:harmonoid/core/hotkeys.dart';
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
import 'package:harmonoid/web/state/web.dart';
import 'package:harmonoid/web/utils/dimensions.dart';

class WebTab extends StatefulWidget {
  const WebTab({Key? key}) : super(key: key);
  WebTabState createState() => WebTabState();
}

class WebTabState extends State<WebTab> with AutomaticKeepAliveClientMixin {
  int _index = 0;
  String _query = '';
  List<String> _suggestions = <String>[];
  int _highlightedSuggestionIndex = -1;
  TextEditingController _searchBarController = TextEditingController();

  Future<void> searchOrPlay(String value) async {
    if (value.isEmpty) return;
    final track = await YTMClient.player(value);
    if (track != null) {
      Web.open(track);
    } else {
      Configuration.instance.save(
        webSearchRecent:
            ([value] + Configuration.instance.webRecent).take(10).toList(),
      );
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              SharedAxisTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            transitionType: SharedAxisTransitionType.vertical,
            child: WebSearch(
              query: value,
              future: YTMClient.search(value),
            ),
          ),
        ),
      );
    }
  }

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
                  searchBar,
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

  void _updateHighlightSuggestionIndex(int newIndex) {
    if (newIndex < -1) newIndex++;
    setState(() {
      _highlightedSuggestionIndex =
          _suggestions.isEmpty ? -1 : newIndex % _suggestions.length;
    });
  }

  void _updateSearchFieldWithHighlightSuggestion(
      TextEditingController controller) {
    controller.text = _suggestions.elementAt(_highlightedSuggestionIndex);
    controller.selection =
        TextSelection.collapsed(offset: controller.text.length);
  }

  Widget get searchBar => Autocomplete<String>(
        optionsBuilder: (textEditingValue) =>
            textEditingValue.text.isEmpty ? [] : _suggestions,
        optionsViewBuilder: (context, callback, _) => Container(
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              Container(
                height: 7 * 32.0,
                width: 280.0,
                child: Material(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(4.0),
                    bottomRight: Radius.circular(4.0),
                  ),
                  elevation: 2.0,
                  child: ListView.builder(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.zero,
                    itemCount: _suggestions.length,
                    itemBuilder: (BuildContext context, int index) {
                      final String option = _suggestions.elementAt(index);
                      return InkWell(
                        onTap: () {
                          callback(option);
                          searchOrPlay(option);
                        },
                        child: Container(
                          color: _highlightedSuggestionIndex == index
                              ? Theme.of(context).focusColor
                              : null,
                          height: 32.0,
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.only(left: 10.0),
                          child: SubstringHighlight(
                            text: option,
                            term: _searchBarController.text,
                            textStyle: Theme.of(context).textTheme.headline3!,
                            textStyleHighlight: TextStyle(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        fieldViewBuilder: (context, controller, node, callback) {
          this._searchBarController = controller;
          return Focus(
            onFocusChange: (hasFocus) {
              if (!hasFocus) {
                HotKeys.instance.enableSpaceHotKey();
              }
            },
            onKey: (node, event) {
              var isArrowDownPressed =
                  event.isKeyPressed(LogicalKeyboardKey.arrowDown);

              if (isArrowDownPressed ||
                  event.isKeyPressed(LogicalKeyboardKey.arrowUp)) {
                _updateHighlightSuggestionIndex(isArrowDownPressed
                    ? _highlightedSuggestionIndex + 1
                    : _highlightedSuggestionIndex - 1);
                _updateSearchFieldWithHighlightSuggestion(controller);
              }

              return KeyEventResult.ignored;
            },
            child: Focus(
              onFocusChange: (hasFocus) {
                if (hasFocus) {
                  HotKeys.instance.disableSpaceHotKey();
                } else {
                  HotKeys.instance.enableSpaceHotKey();
                }
              },
              child: Container(
                height: 40.0,
                width: 280.0,
                padding: EdgeInsets.only(bottom: 1.0),
                child: TextField(
                  autofocus: isDesktop,
                  cursorWidth: 1.0,
                  focusNode: node,
                  controller: controller,
                  onChanged: (value) async {
                    value = value.trim();
                    setState(() {
                      _highlightedSuggestionIndex = -1;
                      _query = value;
                    });
                    _suggestions = value.isEmpty
                        ? []
                        : await YTMClient.music_get_search_suggestions(value);
                    setState(() {});
                  },
                  onSubmitted: (value) {
                    searchOrPlay(value);
                  },
                  cursorColor: Theme.of(context).brightness == Brightness.light
                      ? Colors.black
                      : Colors.white,
                  textAlignVertical: TextAlignVertical.bottom,
                  style: Theme.of(context).textTheme.headline4,
                  decoration: inputDecoration(
                    context,
                    Language.instance.COLLECTION_SEARCH_WELCOME,
                    trailingIcon: Transform.rotate(
                      angle: pi / 2,
                      child: Tooltip(
                        message: Language.instance.SEARCH,
                        child: Icon(
                          Icons.search,
                          size: 20.0,
                          color: Theme.of(context).iconTheme.color,
                        ),
                      ),
                    ),
                    trailingIconOnPressed: () {
                      searchOrPlay(_query);
                    },
                  ),
                ),
              ),
            ),
          );
        },
      );
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
    return isDesktop
        ? Scaffold(
            body: Stack(
              children: [
                DesktopAppBar(
                  title: Language.instance.RESULTS_FOR_QUERY
                      .replaceAll('QUERY', query.trim()),
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
                                      if (!key.contains('Top result'))
                                        ShowAllButton(
                                          onPressed: () {
                                            // TODO: Handle [ShowAllButton].
                                          },
                                        ),
                                    ],
                                  ),
                                );
                                value.forEach(
                                  (element) {
                                    if (element is Track) {
                                      widgets.add(WebTrackTile(track: element));
                                    } else if (element is Artist) {
                                      widgets
                                          .add(WebArtistTile(artist: element));
                                    } else if (element is Video) {
                                      widgets.add(VideoTile(video: element));
                                    } else if (element is Album) {
                                      widgets.add(WebAlbumTile(album: element));
                                    } else if (element is Playlist) {
                                      widgets.add(
                                          WebPlaylistTile(playlist: element));
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
                                    constraints:
                                        BoxConstraints(maxWidth: 840.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: widgets,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          } else {
                            return Center(
                              child: ExceptionWidget(
                                title: Language.instance
                                    .COLLECTION_SEARCH_NO_RESULTS_TITLE,
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
          )
        : Container();
  }
}
