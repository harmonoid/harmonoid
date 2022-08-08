/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'dart:math';
import 'package:flutter/material.dart' hide Intent;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';
import 'package:ytm_client/ytm_client.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/core/intent.dart';
import 'package:harmonoid/core/hotkeys.dart';
import 'package:harmonoid/state/collection_refresh.dart';
import 'package:harmonoid/state/mobile_now_playing_controller.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/utils/dimensions.dart';
import 'package:harmonoid/utils/file_system.dart';
import 'package:harmonoid/interface/collection/album.dart';
import 'package:harmonoid/interface/collection/track.dart';
import 'package:harmonoid/interface/collection/artist.dart';
import 'package:harmonoid/interface/collection/playlist.dart';
import 'package:harmonoid/interface/collection/search.dart';
import 'package:harmonoid/interface/settings/settings.dart';
import 'package:harmonoid/interface/mini_now_playing_bar.dart';
import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/web/web.dart';

class CollectionScreen extends StatefulWidget {
  /// Used only on Android.
  /// Since a [PageView] is used for enabling horizontal swiping, it makes [BottomNavigationBar] from [Home] able to control the pages.
  /// It was necessary to use this to support Android's back button to jump back to previous tabs.
  ///
  final ValueNotifier<TabRoute> tabControllerNotifier;
  final FloatingSearchBarController floatingSearchBarController;
  const CollectionScreen({
    Key? key,
    required this.tabControllerNotifier,
    required this.floatingSearchBarController,
  }) : super(key: key);
  CollectionScreenState createState() => CollectionScreenState();
}

class CollectionScreenState extends State<CollectionScreen>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  final FocusNode node = FocusNode();
  final PageController pageController =
      PageController(initialPage: isMobile ? 2 : 0);
  final ValueNotifier<String> query = ValueNotifier<String>('');
  String queryStr = '';
  final ValueNotifier<int> index = ValueNotifier(isMobile ? 2 : 0);
  int currentIndex = isMobile ? 2 : 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    widget.tabControllerNotifier.addListener(() {
      if (index.value != widget.tabControllerNotifier.value.index) {
        pageController.animateToPage(
          widget.tabControllerNotifier.value.index,
          duration: Duration(milliseconds: 200),
          curve: Curves.easeInOut,
        );
      }
    });
    if (isMobile) {
      pageController.addListener(() {
        widget.floatingSearchBarController.show();
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!Collection.instance.collectionDirectories
          .map((e) => e.existsSync_())
          .reduce((value, element) => value = value ? element : false))
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showDialog(
            context: context,
            barrierDismissible: false,
            useRootNavigator: false,
            builder: (context) => FoldersNotFoundDialog(),
          );
        });
      Intent.instance.play();
    });
    HotKeyManager.instance.register(
      searchBarHotkey,
      keyDownHandler: (_) {
        node.requestFocus();
      },
    );
  }

  @override
  void dispose() {
    HotKeyManager.instance.unregister(searchBarHotkey);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return isDesktop
        ? Scaffold(
            resizeToAvoidBottomInset: false,
            floatingActionButton:
                index.value != 4 ? RefreshCollectionButton() : null,
            body: Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.only(
                    top: desktopTitleBarHeight + kDesktopAppBarHeight,
                  ),
                  child: Consumer<CollectionRefresh>(
                    builder: (context, refresh, __) => Stack(
                      alignment: Alignment.bottomLeft,
                      children: <Widget>[
                        if (Collection.instance.tracks.isNotEmpty &&
                            Configuration.instance.backgroundArtwork)
                          Positioned.fill(
                            child: Opacity(
                              opacity: 0.2,
                              child: Container(
                                alignment: Alignment.center,
                                child: Image.memory(
                                  visualAssets.collection,
                                  height: 512.0,
                                  width: 512.0,
                                  filterQuality: FilterQuality.high,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        PageTransitionSwitcher(
                          child: [
                            AlbumTab(),
                            TrackTab(),
                            ArtistTab(),
                            PlaylistTab(),
                            SearchTab(query: query),
                          ][index.value],
                          transitionBuilder:
                              (child, animation, secondaryAnimation) =>
                                  SharedAxisTransition(
                            animation: animation,
                            secondaryAnimation: secondaryAnimation,
                            transitionType: SharedAxisTransitionType.vertical,
                            child: child,
                            fillColor: Colors.transparent,
                          ),
                        ),
                        if (!refresh.isCompleted)
                          Positioned(
                            child: Card(
                              clipBehavior: Clip.antiAlias,
                              margin: EdgeInsets.all(16.0),
                              elevation: 4.0,
                              child: Container(
                                width: 328.0,
                                height: 56.0,
                                color: Theme.of(context).cardColor,
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    refresh.progress == null
                                        ? LinearProgressIndicator(
                                            value: null,
                                            valueColor: AlwaysStoppedAnimation(
                                              Theme.of(context).primaryColor,
                                            ),
                                            backgroundColor: Theme.of(context)
                                                .primaryColor
                                                .withOpacity(0.4),
                                          )
                                        : LinearProgressIndicator(
                                            value: (refresh.progress ?? 0) /
                                                refresh.total,
                                            valueColor: AlwaysStoppedAnimation(
                                              Theme.of(context).primaryColor,
                                            ),
                                            backgroundColor: Theme.of(context)
                                                .primaryColor
                                                .withOpacity(0.4),
                                          ),
                                    Expanded(
                                      child: Container(
                                        padding: EdgeInsets.all(12.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: 16.0,
                                            ),
                                            Icon(Icons.library_music),
                                            SizedBox(
                                              width: 16.0,
                                            ),
                                            Expanded(
                                              child: Text(
                                                refresh.progress == null
                                                    ? Language.instance
                                                        .DISCOVERING_FILES
                                                    : Language.instance
                                                        .SETTING_INDEXING_LINEAR_PROGRESS_INDICATOR
                                                        .replaceAll(
                                                            'NUMBER_STRING',
                                                            '${refresh.progress}')
                                                        .replaceAll(
                                                            'TOTAL_STRING',
                                                            '${refresh.total}'),
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.center,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline4,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 16.0,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            right: 0.0,
                            top: 0.0,
                          ),
                      ],
                    ),
                  ),
                ),
                Column(
                  children: [
                    DesktopTitleBar(),
                    ClipRect(
                      clipBehavior: Clip.antiAlias,
                      child: Container(
                        height: kDesktopAppBarHeight + 8.0,
                        padding: EdgeInsets.only(bottom: 8.0),
                        child: Material(
                          elevation: 4.0,
                          color: Theme.of(context).appBarTheme.backgroundColor,
                          child: Stack(
                            alignment: Alignment.centerLeft,
                            children: [
                              Positioned.fill(
                                child: Container(
                                  height: 44.0,
                                  padding: EdgeInsets.only(
                                    left: 16.0,
                                    right: 16.0,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Language.instance.ALBUM,
                                      Language.instance.TRACK,
                                      Language.instance.ARTIST,
                                      Language.instance.PLAYLIST,
                                    ].map(
                                      (tab) {
                                        final _index = [
                                          Language.instance.ALBUM,
                                          Language.instance.TRACK,
                                          Language.instance.ARTIST,
                                          Language.instance.PLAYLIST,
                                        ].indexOf(tab);
                                        return InkWell(
                                          borderRadius:
                                              BorderRadius.circular(4.0),
                                          onTap: () {
                                            if (index.value == _index) return;
                                            setState(() {
                                              index.value = _index;
                                            });
                                          },
                                          child: Container(
                                            height: 40.0,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 4.0),
                                            alignment: Alignment.center,
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 4.0),
                                            child: Text(
                                              tab.toUpperCase(),
                                              style: TextStyle(
                                                fontSize: 20.0,
                                                fontWeight:
                                                    index.value == _index
                                                        ? FontWeight.w600
                                                        : FontWeight.w300,
                                                color: (Theme.of(context)
                                                                .brightness ==
                                                            Brightness.dark
                                                        ? Colors.white
                                                        : Colors.black)
                                                    .withOpacity(
                                                        index.value == _index
                                                            ? 1.0
                                                            : 0.67),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ).toList(),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 0.0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: 40.0,
                                      width: 280.0,
                                      alignment: Alignment.center,
                                      margin: EdgeInsets.only(
                                          top: 0.0, bottom: 0.0),
                                      padding: EdgeInsets.only(top: 2.0),
                                      child: Focus(
                                        onFocusChange: (hasFocus) {
                                          if (hasFocus) {
                                            HotKeys.instance
                                                .disableSpaceHotKey();
                                          } else {
                                            HotKeys.instance
                                                .enableSpaceHotKey();
                                          }
                                        },
                                        child: TextField(
                                          focusNode: node,
                                          cursorWidth: 1.0,
                                          onChanged: (value) {
                                            queryStr = value;
                                          },
                                          onSubmitted: (value) {
                                            query.value = value;
                                            if (queryStr.isNotEmpty)
                                              setState(() {
                                                index.value = 4;
                                              });
                                            node.requestFocus();
                                          },
                                          cursorColor:
                                              Theme.of(context).brightness ==
                                                      Brightness.light
                                                  ? Color(0xFF212121)
                                                  : Colors.white,
                                          textAlignVertical:
                                              TextAlignVertical.bottom,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline4,
                                          decoration: inputDecoration(
                                            context,
                                            Language.instance
                                                .COLLECTION_SEARCH_WELCOME,
                                            trailingIcon: Transform.rotate(
                                              angle: pi / 2,
                                              child: Tooltip(
                                                message:
                                                    Language.instance.SEARCH,
                                                child: Icon(
                                                  Icons.search,
                                                  size: 20.0,
                                                  color: Theme.of(context)
                                                      .iconTheme
                                                      .color,
                                                ),
                                              ),
                                            ),
                                            trailingIconOnPressed: () {
                                              query.value = queryStr;
                                              if (queryStr.isNotEmpty)
                                                setState(() {
                                                  index.value = 4;
                                                });
                                              node.requestFocus();
                                            },
                                          ).copyWith(
                                            contentPadding: EdgeInsets.only(
                                              left: 10.0,
                                              bottom: 10.0,
                                              right: 10.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 12.0,
                                    ),
                                    PlayFileOrURLButton(),
                                    CollectionMoreButton(),
                                    Tooltip(
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
                                                secondaryAnimation:
                                                    secondaryAnimation,
                                                child: Settings(),
                                              ),
                                            ),
                                          );
                                        },
                                        borderRadius:
                                            BorderRadius.circular(20.0),
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
                                    SizedBox(
                                      width: 16.0,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        : AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
              statusBarColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black12
                  : Colors.white12,
              statusBarIconBrightness:
                  Theme.of(context).brightness == Brightness.dark
                      ? Brightness.light
                      : Brightness.dark,
            ),
            child: Consumer<CollectionRefresh>(
              builder: (context, refresh, _) => Scaffold(
                resizeToAvoidBottomInset: false,
                floatingActionButton: MiniNowPlayingBarRefreshCollectionButton(
                  key: MobileNowPlayingController.instance.fabKey,
                ),
                body: Stack(
                  fit: StackFit.expand,
                  children: [
                    FloatingSearchBar(
                      controller: widget.floatingSearchBarController,
                      automaticallyImplyBackButton: false,
                      hint: refresh.isCompleted
                          ? Language.instance.SEARCH_WELCOME
                          : Language.instance.COLLECTION_INDEXING_HINT,
                      progress: refresh.isCompleted
                          ? null
                          : refresh.total == 0
                              ? 1.0
                              : (refresh.progress ?? 0.0) / refresh.total,
                      transitionCurve: Curves.easeInOut,
                      width: MediaQuery.of(context).size.width - 2 * tileMargin,
                      height: kMobileSearchBarHeight,
                      margins: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top + tileMargin,
                      ),
                      onSubmitted: (query) {
                        if (index.value == 4) {
                          Navigator.of(context).push(PageRouteBuilder(
                              pageBuilder: (context, animation,
                                      secondaryAnimation) =>
                                  FadeThroughTransition(
                                      fillColor: Colors.transparent,
                                      animation: animation,
                                      secondaryAnimation: secondaryAnimation,
                                      child: FloatingSearchBarWebSearchScreen(
                                        query: query,
                                        future: YTMClient.search(query),
                                      ))));
                        }
                      },
                      accentColor: Theme.of(context).primaryColor,
                      onQueryChanged: (value) => query.value = value,
                      clearQueryOnClose: true,
                      transition: CircularFloatingSearchBarTransition(),
                      leadingActions: [
                        FloatingSearchBarAction(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.search,
                              size: 24.0,
                              color: Theme.of(context)
                                  .appBarTheme
                                  .iconTheme
                                  ?.color,
                            ),
                          ),
                          showIfOpened: false,
                        ),
                        FloatingSearchBarAction.back(
                          color: Theme.of(context).appBarTheme.iconTheme?.color,
                        ),
                      ],
                      actions: [
                        FloatingSearchBarAction(
                          showIfOpened: false,
                          showIfClosed: true,
                          child: MobileSortByButton(
                            value: index,
                          ),
                        ),
                        FloatingSearchBarAction(
                          showIfOpened: false,
                          showIfClosed: true,
                          child: CircularButton(
                            icon: Icon(
                              Icons.grid_on,
                              size: 20.0,
                              color: Theme.of(context)
                                  .appBarTheme
                                  .actionsIconTheme
                                  ?.color,
                            ),
                            onPressed: () {
                              final position = RelativeRect.fromRect(
                                Offset(
                                      MediaQuery.of(context).size.width -
                                          tileMargin -
                                          48.0,
                                      MediaQuery.of(context).padding.top +
                                          kMobileSearchBarHeight +
                                          2 * tileMargin,
                                    ) &
                                    Size(160.0, 160.0),
                                Rect.fromLTWH(
                                  0,
                                  0,
                                  MediaQuery.of(context).size.width,
                                  MediaQuery.of(context).size.height,
                                ),
                              );
                              showMenu<int>(
                                context: context,
                                position: position,
                                elevation: 4.0,
                                items: [
                                  CheckedPopupMenuItem(
                                    padding: EdgeInsets.zero,
                                    checked: Configuration
                                        .instance.mobileDenseAlbumTabLayout,
                                    value: 0,
                                    child: Text(
                                      Language
                                          .instance.ENABLE_DENSE_ALBUMS_LAYOUT,
                                    ),
                                  ),
                                  CheckedPopupMenuItem(
                                    padding: EdgeInsets.zero,
                                    checked: Configuration
                                        .instance.mobileDenseArtistTabLayout,
                                    value: 1,
                                    child: Text(
                                      Language
                                          .instance.ENABLE_DENSE_ARTISTS_LAYOUT,
                                    ),
                                  ),
                                  CheckedPopupMenuItem(
                                    padding: EdgeInsets.zero,
                                    checked: Configuration
                                        .instance.mobileGridArtistTabLayout,
                                    value: 2,
                                    child: Text(
                                      Language
                                          .instance.ENABLE_GRID_ARTISTS_LAYOUT,
                                    ),
                                  ),
                                ],
                              ).then((value) {
                                switch (value) {
                                  case 0:
                                    {
                                      Configuration.instance
                                          .save(
                                            mobileDenseAlbumTabLayout:
                                                !Configuration.instance
                                                    .mobileDenseAlbumTabLayout,
                                          )
                                          .then((_) => setState(() {}));
                                      break;
                                    }
                                  case 1:
                                    {
                                      Configuration.instance
                                          .save(
                                            mobileDenseArtistTabLayout:
                                                !Configuration.instance
                                                    .mobileDenseArtistTabLayout,
                                            mobileGridArtistTabLayout: true,
                                          )
                                          .then((_) => setState(() {}));
                                      break;
                                    }
                                  case 2:
                                    {
                                      Configuration.instance
                                          .save(
                                            mobileGridArtistTabLayout:
                                                !Configuration.instance
                                                    .mobileGridArtistTabLayout,
                                          )
                                          .then((_) => setState(() {}));
                                      break;
                                    }
                                }
                              });
                            },
                          ),
                        ),
                        FloatingSearchBarAction(
                          showIfOpened: false,
                          child: contextMenu(
                            context,
                            color: Theme.of(context)
                                .appBarTheme
                                .actionsIconTheme
                                ?.color,
                          ),
                        ),
                        FloatingSearchBarAction.searchToClear(
                          showIfClosed: false,
                          color: Theme.of(context)
                              .appBarTheme
                              .actionsIconTheme
                              ?.color,
                        ),
                      ],
                      builder: (context, transition) {
                        return index.value != 4
                            ? FloatingSearchBarSearchTab(query: query)
                            : FloatingSearchBarWebSearchTab(query: query);
                      },
                      body: FloatingSearchBarScrollNotifier(
                        child: Stack(
                          children: [
                            if (Collection.instance.tracks.isNotEmpty &&
                                Configuration.instance.backgroundArtwork)
                              Positioned.fill(
                                child: Opacity(
                                  opacity: 0.2,
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: Image.memory(
                                      visualAssets.collection,
                                      height: 512.0,
                                      width: 512.0,
                                      filterQuality: FilterQuality.high,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                            NotificationListener<ScrollNotification>(
                              onNotification:
                                  (ScrollNotification notification) {
                                if (notification.depth == 0 &&
                                    notification is ScrollEndNotification &&
                                    notification.metrics.axis ==
                                        Axis.horizontal) {
                                  index.value = currentIndex;
                                  widget.tabControllerNotifier.value = TabRoute(
                                      currentIndex, TabRouteSender.pageView);
                                }
                                return false;
                              },
                              child: PageView(
                                controller: pageController,
                                onPageChanged: (page) {
                                  currentIndex = page;
                                },
                                children: [
                                  PlaylistTab(),
                                  TrackTab(),
                                  AlbumTab(),
                                  ArtistTab(),
                                  WebTab(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
