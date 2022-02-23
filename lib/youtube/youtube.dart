import 'dart:math';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';

import 'package:harmonoid/core/hotkeys.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/models/media.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/dimensions.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/constants/language.dart';

import 'package:harmonoid/youtube/youtube_api.dart';
import 'package:harmonoid/youtube/youtube_tile.dart';
import 'package:harmonoid/youtube/state/youtube.dart';
import 'package:substring_highlight/substring_highlight.dart';

class YoutubeTab extends StatefulWidget {
  const YoutubeTab({Key? key}) : super(key: key);
  YoutubeTabState createState() => YoutubeTabState();
}

class YoutubeTabState extends State<YoutubeTab> {
  String _query = '';
  List<String> _suggestions = <String>[];
  int _highlightedSuggestionIndex = -1;
  TextEditingController _searchBarController = TextEditingController();

  @override
  void initState() {
    super.initState();
    YouTube.instance.fetchRecommendations();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => YouTube.instance,
      builder: (context, _) => PageTransitionSwitcher(
        child: Consumer<YouTube>(
          builder: (context, youtube, _) => Stack(
            alignment: Alignment.topCenter,
            children: [
              builder(context, youtube),
              if (areRecommendationsNotShowing) desktopSearchBar,
            ],
          ),
        ),
        transitionBuilder: (child, animation, secondaryAnimation) =>
            SharedAxisTransition(
          fillColor: Colors.transparent,
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.vertical,
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: child,
          ),
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

  Widget builder(BuildContext context, YouTube youtube) {
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
    if (Configuration.instance.discoverRecent.isEmpty) {
      return Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Center(
          child: ExceptionWidget(
            title: Language.instance.YOUTUBE_WELCOME_TITLE,
            subtitle: Language.instance.YOUTUBE_WELCOME_SUBTITLE,
          ),
        ),
      );
    } else {
      if (youtube.recommendations == null) {
        return Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(
              Theme.of(context).primaryColor,
            ),
          ),
        );
      } else if (youtube.exception) {
        return Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ExceptionWidget(
                  title: Language.instance.NO_INTERNET_TITLE,
                  subtitle: Language.instance.NO_INTERNET_SUBTITLE +
                      '\n' +
                      Language.instance.YOUTUBE_INTERNET_ERROR,
                ),
                Padding(
                  padding: EdgeInsets.all(12.0),
                  child: MaterialButton(
                    onPressed: youtube.fetchRecommendations,
                    child: Text(
                      Language.instance.REFRESH.toUpperCase(),
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        return CustomListView(
          children: [
            ...[
              Container(
                alignment: Alignment.center,
                child: desktopSearchBar,
              ),
              SizedBox(height: tileMargin),
            ],
            ...tileGridListWidgets(
              context: context,
              tileHeight: height,
              tileWidth: width,
              elementsPerRow: elementsPerRow,
              subHeader: null,
              leadingSubHeader: null,
              widgetCount: youtube.recommendations!.length,
              leadingWidget: Container(),
              builder: (context, i) => YoutubeTile(
                height: height,
                width: width,
                track: youtube.recommendations![i],
              ),
            ),
          ],
        );
      }
    }
  }

  Future<void> searchOrPlay(String _query) async {
    if (_query.isEmpty) return;
    final track = await YoutubeApi.getTrack(_query);
    if (track != null) {
      YouTube.instance.open(track);
    } else {
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              FadeThroughTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            child: YouTubeSearch(
              query: _query,
              future: YoutubeApi.search(_query),
            ),
          ),
        ),
      );
    }
  }

  Widget get desktopSearchBar => Padding(
        padding: EdgeInsets.only(
          top: tileMargin,
        ),
        child: Autocomplete<String>(
          optionsBuilder: (textEditingValue) =>
              textEditingValue.text.isEmpty ? [] : _suggestions,
          optionsViewBuilder: (context, callback, Iterable<String> values) =>
              Container(
            margin: EdgeInsets.zero,
            width: MediaQuery.of(context).size.width,
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
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                    ),
                  ),
                  Container(
                    height: 7 * 32.0,
                    width: 480.0,
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
                        itemCount: values.length,
                        itemBuilder: (BuildContext context, int index) {
                          final String option = values.elementAt(index);
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
                                textStyle:
                                    Theme.of(context).textTheme.headline3!,
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
                  width: 480.0,
                  child: TextField(
                    autofocus: isDesktop,
                    cursorWidth: 1.0,
                    focusNode: node,
                    controller: controller,
                    onChanged: (value) async {
                      setState(() {
                        _highlightedSuggestionIndex = -1;
                      });
                      _query = value;
                      if (value.isEmpty) {
                        _suggestions = [];
                        setState(() {});
                      } else {
                        _suggestions = await YoutubeApi.getSuggestions(value);
                      }
                      setState(() {});
                    },
                    onSubmitted: (value) {
                      searchOrPlay(value);
                    },
                    cursorColor:
                        Theme.of(context).brightness == Brightness.light
                            ? Colors.black
                            : Colors.white,
                    textAlignVertical: TextAlignVertical.bottom,
                    style: Theme.of(context).textTheme.headline4,
                    decoration: desktopInputDecoration(
                      context,
                      Language.instance.SEARCH,
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
        ),
      );

  bool get areRecommendationsNotShowing =>
      Configuration.instance.discoverRecent.isEmpty ||
      (Configuration.instance.discoverRecent.isNotEmpty &&
          (YouTube.instance.recommendations == null ||
              YouTube.instance.exception));
}

class YouTubeSearch extends StatelessWidget {
  final String query;
  final Future<List<Track>> future;

  const YouTubeSearch({
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
                    child: FutureBuilder<List<Track>>(
                      future: future,
                      builder: (context, asyncSnapshot) {
                        final elementsPerRow =
                            (MediaQuery.of(context).size.width - tileMargin) ~/
                                (kAlbumTileWidth + tileMargin);
                        if (asyncSnapshot.hasData) {
                          return asyncSnapshot.data!.isNotEmpty
                              ? CustomListView(
                                  padding: EdgeInsets.only(
                                    top: tileMargin,
                                  ),
                                  shrinkWrap: true,
                                  children: tileGridListWidgets(
                                    tileHeight: kAlbumTileHeight,
                                    tileWidth: kAlbumTileWidth,
                                    subHeader: null,
                                    leadingSubHeader: null,
                                    leadingWidget: null,
                                    context: context,
                                    widgetCount: asyncSnapshot.data!.length,
                                    builder: (context, i) => YoutubeTile(
                                      track: asyncSnapshot.data![i],
                                      height: kAlbumTileHeight,
                                      width: kAlbumTileWidth,
                                    ),
                                    elementsPerRow: elementsPerRow,
                                  ),
                                )
                              : Center(
                                  child: ExceptionWidget(
                                    title: Language.instance
                                        .COLLECTION_SEARCH_NO_RESULTS_TITLE,
                                    subtitle:
                                        Language.instance.YOUTUBE_NO_RESULTS,
                                  ),
                                );
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
