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
  String _query = '';
  List<String> _suggestions = <String>[];
  int _highlightedSuggestionIndex = -1;
  TextEditingController _searchBarController = TextEditingController();
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
  bool get wantKeepAlive => true;

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
    return Scaffold(
      body: Stack(
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
            Padding(
              padding: EdgeInsets.only(
                top: desktopTitleBarHeight + kDesktopAppBarHeight,
              ),
              child: Center(
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
                                ? TrackLargeTile(
                                    height: height,
                                    width: width,
                                    track: item,
                                  )
                                : VideoLargeTile(
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
            ),
          DesktopAppBar(),
          Container(
            margin: EdgeInsets.only(top: desktopTitleBarHeight),
            alignment: Alignment.center,
            height: kDesktopAppBarHeight,
            child: Row(
              children: [
                const SizedBox(width: 64.0),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Language.instance.RECOMMENDATIONS,
                    Language.instance.PLAYLIST,
                  ].map(
                    (tab) {
                      final _index = [
                        Language.instance.RECOMMENDATIONS,
                        Language.instance.PLAYLIST,
                      ].indexOf(tab);
                      return InkWell(
                        borderRadius: BorderRadius.circular(4.0),
                        onTap: () => setState(() {}),
                        child: Container(
                          height: 40.0,
                          padding: EdgeInsets.symmetric(horizontal: 4.0),
                          alignment: Alignment.center,
                          margin: EdgeInsets.symmetric(horizontal: 4.0),
                          child: Text(
                            tab.toUpperCase(),
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: 0 == _index
                                  ? FontWeight.w600
                                  : FontWeight.w300,
                              color: (Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.black)
                                  .withOpacity(0 == _index ? 1.0 : 0.67),
                            ),
                          ),
                        ),
                      );
                    },
                  ).toList(),
                ),
                Spacer(),
                searchBar,
                const SizedBox(width: 32.0),
              ],
            ),
          ),
        ],
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

  Future<void> searchOrPlay(String _query) async {
    if (_query.isEmpty) return;
    final track = await YTMClient.player(_query);
    if (track != null) {
      Web.instance.open(track);
    } else {
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              FadeThroughTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            child: WebSearch(
              query: _query,
              future: YTMClient.search(_query),
            ),
          ),
        ),
      );
    }
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
                                      widgets.add(TrackTile(track: element));
                                    } else if (element is Artist) {
                                      widgets.add(ArtistTile(artist: element));
                                    } else if (element is Video) {
                                      widgets.add(VideoTile(video: element));
                                    } else if (element is Album) {
                                      widgets.add(AlbumTile(album: element));
                                    } else if (element is Playlist) {
                                      widgets
                                          .add(PlaylistTile(playlist: element));
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
