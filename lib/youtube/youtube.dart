import 'dart:math';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:substring_highlight/substring_highlight.dart';

import 'package:harmonoid/core/hotkeys.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/dimensions.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/youtube/track.dart';
import 'package:harmonoid/youtube/state/youtube.dart';
import 'package:youtube_music/youtube_music.dart';

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
    YouTube.instance.next();
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
                    onPressed: youtube.next,
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
              builder: (context, i) => TrackTile(
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
    final track = await YouTubeMusic.player(_query);
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
              future: YouTubeMusic.search(_query),
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
          optionsViewBuilder: (context, callback, _) => Container(
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
                      value = value.trim();

                      setState(() {
                        _highlightedSuggestionIndex = -1;
                        _query = value;
                      });

                      _suggestions = value.isEmpty
                          ? []
                          : await YouTubeMusic.music_get_search_suggestions(
                              value);

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
  final Future<Map<String, List<YouTubeMedia>>> future;

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
                    child: FutureBuilder<Map<String, List<YouTubeMedia>>>(
                      future: future,
                      builder: (context, asyncSnapshot) {
                        // fuck scalablity & organized code. imma insert widgets recklessly here.
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
                                      widgets.add(
                                        Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: () =>
                                                YouTube.instance.open(element),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Divider(
                                                  height: 1.0,
                                                  indent: 80.0,
                                                ),
                                                Container(
                                                  height: 64.0,
                                                  alignment: Alignment.center,
                                                  margin: const EdgeInsets
                                                      .symmetric(vertical: 4.0),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      const SizedBox(
                                                          width: 12.0),
                                                      ExtendedImage(
                                                        image: NetworkImage(
                                                          element.thumbnails
                                                              .values.first,
                                                        ),
                                                        height: 56.0,
                                                        width: 56.0,
                                                      ),
                                                      const SizedBox(
                                                          width: 12.0),
                                                      Expanded(
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              element.trackName
                                                                  .overflow,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxLines: 1,
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .headline2,
                                                            ),
                                                            const SizedBox(
                                                              height: 2.0,
                                                            ),
                                                            Text(
                                                              Language.instance
                                                                      .TRACK_SINGLE +
                                                                  ' • ' +
                                                                  element
                                                                      .albumName
                                                                      ?.overflow +
                                                                  ' • ' +
                                                                  element
                                                                      .albumArtistName
                                                                      ?.overflow +
                                                                  ' • ' +
                                                                  (element.duration
                                                                          ?.label ??
                                                                      ''),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxLines: 1,
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .headline3,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          width: 12.0),
                                                      Container(
                                                        width: 64.0,
                                                        height: 64.0,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    } else if (element is Artist) {
                                      widgets.add(
                                        Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: () {
                                              // TODO: Handle [Artist].
                                            },
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Divider(
                                                  height: 1.0,
                                                  indent: 80.0,
                                                ),
                                                Container(
                                                  height: 64.0,
                                                  alignment: Alignment.center,
                                                  margin: const EdgeInsets
                                                      .symmetric(vertical: 4.0),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      const SizedBox(
                                                          width: 12.0),
                                                      Card(
                                                        clipBehavior:
                                                            Clip.antiAlias,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      28.0),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  2.0),
                                                          child: ClipOval(
                                                            child:
                                                                ExtendedImage(
                                                              image:
                                                                  NetworkImage(
                                                                element
                                                                    .thumbnails
                                                                    .values
                                                                    .first,
                                                              ),
                                                              height: 52.0,
                                                              width: 52.0,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          width: 12.0),
                                                      Expanded(
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              element.artistName
                                                                  .overflow,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxLines: 1,
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .headline2,
                                                            ),
                                                            const SizedBox(
                                                              height: 2.0,
                                                            ),
                                                            Text(
                                                              Language.instance
                                                                      .ARTIST_SINGLE +
                                                                  ' • ' +
                                                                  element
                                                                      .subscribersCount,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxLines: 1,
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .headline3,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          width: 12.0),
                                                      Container(
                                                        width: 64.0,
                                                        height: 64.0,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    } else if (element is Video) {
                                      widgets.add(
                                        Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: () {
                                              // TODO: Handle [Video].
                                            },
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Divider(
                                                  height: 1.0,
                                                  indent: 80.0,
                                                ),
                                                Container(
                                                  height: 64.0,
                                                  alignment: Alignment.center,
                                                  margin: const EdgeInsets
                                                      .symmetric(vertical: 4.0),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      const SizedBox(
                                                          width: 12.0),
                                                      ExtendedImage(
                                                        image: NetworkImage(
                                                          element.thumbnails
                                                              .values.first,
                                                        ),
                                                        height: 56.0,
                                                        width: 56.0,
                                                      ),
                                                      const SizedBox(
                                                          width: 12.0),
                                                      Expanded(
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              element.videoName
                                                                  .overflow,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxLines: 1,
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .headline2,
                                                            ),
                                                            const SizedBox(
                                                              height: 2.0,
                                                            ),
                                                            Text(
                                                              Language.instance
                                                                      .VIDEO_SINGLE +
                                                                  ' • ' +
                                                                  element
                                                                      .channelName +
                                                                  ' • ' +
                                                                  (element.duration
                                                                          ?.label ??
                                                                      ''),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxLines: 1,
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .headline3,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          width: 12.0),
                                                      Container(
                                                        width: 64.0,
                                                        height: 64.0,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    } else if (element is Album) {
                                      widgets.add(
                                        Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: () {
                                              // TODO: Handle [Album].
                                            },
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Divider(
                                                  height: 1.0,
                                                  indent: 80.0,
                                                ),
                                                Container(
                                                  height: 64.0,
                                                  alignment: Alignment.center,
                                                  margin: const EdgeInsets
                                                      .symmetric(vertical: 4.0),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      const SizedBox(
                                                          width: 12.0),
                                                      ExtendedImage(
                                                        image: NetworkImage(
                                                          element.thumbnails
                                                              .values.first,
                                                        ),
                                                        height: 56.0,
                                                        width: 56.0,
                                                      ),
                                                      const SizedBox(
                                                          width: 12.0),
                                                      Expanded(
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              element.albumName
                                                                  ?.overflow,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxLines: 1,
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .headline2,
                                                            ),
                                                            const SizedBox(
                                                              height: 2.0,
                                                            ),
                                                            Text(
                                                              Language.instance
                                                                      .ALBUM_SINGLE +
                                                                  ' • ' +
                                                                  (element.albumArtistName ??
                                                                      '') +
                                                                  ' • ' +
                                                                  (element.year ??
                                                                      ''),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxLines: 1,
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .headline3,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          width: 12.0),
                                                      Container(
                                                        width: 64.0,
                                                        height: 64.0,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    } else if (element is Playlist) {
                                      widgets.add(
                                        Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: () {
                                              // TODO: Handle [Playlist].
                                            },
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Divider(
                                                  height: 1.0,
                                                  indent: 80.0,
                                                ),
                                                Container(
                                                  height: 64.0,
                                                  alignment: Alignment.center,
                                                  margin: const EdgeInsets
                                                      .symmetric(vertical: 4.0),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      const SizedBox(
                                                          width: 12.0),
                                                      ExtendedImage(
                                                        image: NetworkImage(
                                                          element.thumbnails
                                                              .values.first,
                                                        ),
                                                        height: 56.0,
                                                        width: 56.0,
                                                      ),
                                                      const SizedBox(
                                                          width: 12.0),
                                                      Expanded(
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              element.name
                                                                  .overflow,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxLines: 1,
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .headline2,
                                                            ),
                                                            const SizedBox(
                                                              height: 2.0,
                                                            ),
                                                            Text(
                                                              Language.instance
                                                                  .PLAYLIST_SINGLE,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxLines: 1,
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .headline3,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          width: 12.0),
                                                      Container(
                                                        width: 64.0,
                                                        height: 64.0,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
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
                                subtitle: Language.instance.YOUTUBE_NO_RESULTS,
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

extension on Duration {
  String get label {
    int minutes = inSeconds ~/ 60;
    String seconds = inSeconds - (minutes * 60) > 9
        ? '${inSeconds - (minutes * 60)}'
        : '0${inSeconds - (minutes * 60)}';
    return '$minutes:$seconds';
  }
}
