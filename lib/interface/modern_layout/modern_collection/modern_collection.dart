/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart' hide Intent;
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';
import 'package:window_plus/window_plus.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:safe_local_storage/safe_local_storage.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:searchbar_animation/searchbar_animation.dart';

import 'package:harmonoid/interface/modern_layout/settings_modern/settings_modern.dart';
import 'package:harmonoid/interface/modern_layout/utils_modern/broken_icons.dart';
import 'package:harmonoid/interface/modern_layout/utils_modern/widgets_modern.dart';
import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/core/intent.dart';
import 'package:harmonoid/core/hotkeys.dart';
import 'package:harmonoid/state/collection_refresh.dart';
import 'package:harmonoid/state/mobile_now_playing_controller.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/utils/dimensions.dart';
import 'package:harmonoid/interface/home.dart';
import 'package:harmonoid/interface/missing_directories_screen.dart';
import 'package:harmonoid/interface/modern_layout/modern_collection/modern_album.dart';
import 'package:harmonoid/interface/modern_layout/modern_collection/modern_track.dart';
import 'package:harmonoid/interface/modern_layout/modern_collection/modern_artist.dart';
import 'package:harmonoid/interface/modern_layout/modern_collection/modern_playlist.dart';
import 'package:harmonoid/interface/modern_layout/modern_collection/modern_search.dart';
import 'package:harmonoid/constants/language.dart';

class CollectionScreenModern extends StatefulWidget {
  /// Used only on Android.
  /// Since a [PageView] is used for enabling horizontal swiping, it makes [BottomNavigationBar] from [Home] able to control the pages.
  /// It was necessary to use this to support Android's back button to jump back to previous tabs.
  ///
  final ValueNotifier<TabRoute> tabControllerNotifier;
  final FloatingSearchBarController floatingSearchBarController;
  const CollectionScreenModern({
    Key? key,
    required this.tabControllerNotifier,
    required this.floatingSearchBarController,
  }) : super(key: key);
  CollectionScreenModernState createState() => CollectionScreenModernState();
}

class CollectionScreenModernState extends State<CollectionScreenModern>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  final FocusNode node = FocusNode();
  final PageController pageController =
      PageController(initialPage: Configuration.instance.libraryTab);
  final ValueNotifier<String> query = ValueNotifier<String>('');
  String queryStr = '';
  final ValueNotifier<int> index = ValueNotifier(
    Configuration.instance.libraryTab,
  );
  int currentIndex = Configuration.instance.libraryTab;
  TextEditingController searchTextEditingController = TextEditingController();
  late bool showSearchCard;
  @override
  bool get wantKeepAlive => true;

  FutureOr<void> saveCurrentTab() {
    // [index.value] at 4 is the [SearchTab] on desktop, which should not be saved in cache as a starting point for the next session.
    // It is only meant to be accessed via the search [TextField].
    if (isDesktop && index.value == 4) {
      return Future.value();
    }
    if (index.value != Configuration.instance.libraryTab) {
      return Configuration.instance.save(libraryTab: index.value);
    }
  }

  @override
  void initState() {
    super.initState();
    showSearchCard = false;
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
    index.addListener(saveCurrentTab);
    index.addListener(MobileNowPlayingController.instance.show);
    // Check if any directories in the [Collection.instance.collectionDirectories]
    // have been deleted or gone missing due to some external reason.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        // Attempt to play the [File] opened by the user via the [Intent]
        // e.g. file manager etc. Loads previously loaded playlist if no
        // new [File] is opened. Also see: [HomeState.didChangeDependencies].
        // This call is only responsible for starting the first time
        // playback, if a fresh instance of Harmonoid was started with
        // a new intent by the user.
        // For the intents that are received during the runtime of Harmonoid
        // or while Harmonoid is in the background, see
        // [HomeState.didChangeDependencies].
        try {
          await Intent.instance.play();
        } catch (exception, stacktrace) {
          debugPrint(exception.toString());
          debugPrint(stacktrace.toString());
        }
        bool success = true;
        for (final directory in Collection.instance.collectionDirectories) {
          if (!await directory.exists_()) {
            success = false;
            break;
          }
        }
        if (!success) {
          // Show error screen to the user, requesting the resolution of the missing directories.
          // This will prevent user from using Harmonoid until the missing directories are resolved.
          final context = navigatorKey.currentContext;
          if (context != null) {
            await Navigator.of(
              context,
              rootNavigator: true,
            ).push(
              MaterialPageRoute(
                builder: (context) => MissingDirectoriesScreen(),
              ),
            );
          }
        }
      },
    );
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
    index.removeListener(saveCurrentTab);
    index.removeListener(MobileNowPlayingController.instance.show);
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
                    top: WindowPlus.instance.captionHeight +
                        kDesktopAppBarHeight,
                  ),
                  child: Consumer<CollectionRefresh>(
                    builder: (context, refresh, __) => Stack(
                      alignment: Alignment.bottomLeft,
                      children: <Widget>[
                        PageTransitionSwitcher(
                          child: [
                            AlbumTabModern(),
                            TrackTabModern(),
                            ArtistTabModern(),
                            PlaylistTabModern(),
                            SearchTabModern(query: query),
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
                            left: 0.0,
                            bottom: 0.0,
                            child: Card(
                              clipBehavior: Clip.antiAlias,
                              margin: EdgeInsets.all(16.0),
                              elevation: Theme.of(context).cardTheme.elevation,
                              child: Container(
                                width: 328.0,
                                height: 56.0,
                                color: Theme.of(context).cardTheme.color,
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
                                                    .headlineMedium,
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
                          ),
                      ],
                    ),
                  ),
                ),
                ClipRect(
                  clipBehavior: Clip.antiAlias,
                  child: Container(
                    height: kDesktopAppBarHeight +
                        WindowPlus.instance.captionHeight +
                        8.0,
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: Material(
                      elevation: Theme.of(context).appBarTheme.elevation ??
                          kDefaultAppBarElevation,
                      color: Theme.of(context).appBarTheme.backgroundColor,
                      child: Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          Positioned(
                            top: 0.0,
                            left: 0.0,
                            right: 0.0,
                            child: DesktopCaptionBar(),
                          ),
                          Positioned.fill(
                            top: WindowPlus.instance.captionHeight,
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
                                      borderRadius: BorderRadius.circular(4.0),
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
                                            fontWeight: index.value == _index
                                                ? FontWeight.w600
                                                : FontWeight.w300,
                                            color:
                                                (Theme.of(context).brightness ==
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
                          Positioned.fill(
                            top: WindowPlus.instance.captionHeight,
                            right: 0.0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  height: 40.0,
                                  width: 320.0,
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.only(
                                    top: 0.0,
                                    bottom: 0.0,
                                  ),
                                  padding: EdgeInsets.only(top: 2.0),
                                  child: Focus(
                                    onFocusChange: (hasFocus) {
                                      if (hasFocus) {
                                        HotKeys.instance.disableSpaceHotKey();
                                      } else {
                                        HotKeys.instance.enableSpaceHotKey();
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
                                      textAlignVertical:
                                          TextAlignVertical.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium,
                                      decoration: inputDecoration(
                                        context,
                                        Language
                                            .instance.COLLECTION_SEARCH_WELCOME,
                                        trailingIcon: Transform.rotate(
                                          angle: pi / 2,
                                          child: Tooltip(
                                            message: Language.instance.SEARCH,
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
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 12.0,
                                ),
                                PlayFileOrURLButton(),
                                // TweenAnimationBuilder<double>(
                                //   tween: Tween<double>(
                                //     begin: 0.0,
                                //     end: index.value == 3 ? 0.0 : 1.0,
                                //   ),
                                //   duration: Duration(milliseconds: 200),
                                //   child: CollectionSortButton(
                                //     tab: index.value,
                                //   ),
                                //   builder: (context, value, child) =>
                                //       Opacity(
                                //     opacity: value,
                                //     child:
                                //         value == 0.0 ? Container() : child,
                                //   ),
                                // ),
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
                                            child: SettingsModern(),
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
          )
        : Consumer<CollectionRefresh>(
            builder: (context, refresh, _) => Scaffold(
              resizeToAvoidBottomInset: true,
              // floatingActionButton: ValueListenableBuilder(
              //   valueListenable: index,
              //   builder: (context, value, child) => AnimatedSwitcher(
              //     duration: const Duration(milliseconds: 200),
              //     reverseDuration: const Duration(milliseconds: 200),
              //     switchInCurve: Curves.easeInOut,
              //     switchOutCurve: Curves.easeInOut,
              //     transitionBuilder: (child, value) => FadeTransition(
              //       opacity: value,
              //       child: child,
              //     ),
              //     child: MiniNowPlayingBarRefreshCollectionButton(
              //       index: index,
              //     ),
              //   ),
              // ),
              drawer: Drawer(
                width: 200,
              ),
              appBar: AppBar(
                elevation: 1,
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(4.0),
                  child: MobileIndexingProgressIndicatorModern(),
                ),
                titleSpacing: 0,
                title: SearchBarAnimation(
                  isSearchBoxOnRightSide: true,
                  textAlignToRight: false,
                  textEditingController: searchTextEditingController,
                  durationInMilliSeconds: 300,
                  enableKeyboardFocus: true,
                  isOriginalAnimation: false,
                  onPressButton: (isOpen) {
                    setState(() {
                      showSearchCard = isOpen;
                      searchTextEditingController.clear();
                      query.value = '';
                    });
                  },
                  onChanged: (String value) {
                    setState(() {
                      if (!showSearchCard) {
                        showSearchCard = true;
                      }
                      query.value = value;
                    });
                  },
                  buttonColour: Colors.transparent,
                  buttonShadowColour: Theme.of(context).colorScheme.surface,
                  hintTextColour: Theme.of(context).colorScheme.onSurface,
                  searchBoxColour: Theme.of(context).colorScheme.background,
                  enteredTextStyle: Theme.of(context).textTheme.displayMedium,
                  cursorColour: Theme.of(context).colorScheme.onBackground,
                  buttonBorderColour: Colors.black45,
                  hintText: refresh.isCompleted
                      ? Language.instance.SEARCH_WELCOME
                      : Language.instance.COLLECTION_INDEXING_HINT,
                  buttonWidget: Icon(
                    Broken.search_normal,
                    color:
                        Theme.of(context).appBarTheme.actionsIconTheme?.color,
                  ),
                  secondaryButtonWidget: Icon(
                    Broken.search_status_1,
                    color:
                        Theme.of(context).appBarTheme.actionsIconTheme?.color,
                  ),
                  trailingWidget: GestureDetector(
                    onTap: () {
                      searchTextEditingController.clear();
                      query.value = '';
                    },
                    child: Icon(
                      Broken.close_circle,
                      color:
                          Theme.of(context).appBarTheme.actionsIconTheme?.color,
                    ),
                  ),
                ),
                actions: [
                  if (!showSearchCard)
                    MobileSortByButton(
                      value: index,
                      icon: Broken.filter,
                      topPadding: kToolbarHeight +
                          MediaQuery.of(context).padding.top +
                          kMobileTileMargin * 2,
                    ),
                  if (!showSearchCard)
                    CircularButton(
                      icon: Icon(
                        Broken.grid_1,
                        size: 20.0,
                        color: Theme.of(context)
                            .appBarTheme
                            .actionsIconTheme
                            ?.color,
                      ),
                      onPressed: () async {
                        final position = RelativeRect.fromRect(
                          Offset(
                                MediaQuery.of(context).size.width -
                                    tileMargin -
                                    48.0,
                                MediaQuery.of(context).padding.top +
                                    kToolbarHeight +
                                    2 * tileMargin,
                              ) &
                              Size(228.0, 320.0),
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
                          elevation: Theme.of(context).popupMenuTheme.elevation,
                          constraints: BoxConstraints(
                            maxWidth: double.infinity,
                          ),
                          items: [
                            PopupMenuItem(
                              padding: EdgeInsets.zero,
                              value: 0,
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.transparent,
                                  child: Text(
                                    Configuration.instance.mobileAlbumsGridSize
                                        .toString(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .displaySmall
                                        ?.copyWith(
                                          fontSize: 18.0,
                                        ),
                                  ),
                                ),
                                title: Text(
                                  Language.instance.MOBILE_ALBUM_GRID_SIZE,
                                ),
                              ),
                            ),
                            PopupMenuItem(
                              padding: EdgeInsets.zero,
                              value: 1,
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.transparent,
                                  child: Text(
                                    Configuration.instance.mobileArtistsGridSize
                                        .toString(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .displaySmall
                                        ?.copyWith(
                                          fontSize: 18.0,
                                        ),
                                  ),
                                ),
                                title: Text(
                                  Language.instance.MOBILE_ARTIST_GRID_SIZE,
                                ),
                              ),
                            ),
                          ],
                        ).then((value) async {
                          switch (value) {
                            case 0:
                              {
                                int result =
                                    Configuration.instance.mobileAlbumsGridSize;
                                await showDialog(
                                  context: context,
                                  builder: (context) => StatefulBuilder(
                                    builder: (context, setState) =>
                                        SimpleDialog(
                                      title: Text(
                                        Language
                                            .instance.MOBILE_ALBUM_GRID_SIZE,
                                      ),
                                      children: [1, 2, 3, 4]
                                          .map(
                                            (e) => RadioListTile<int>(
                                              activeColor: Theme.of(context)
                                                  .colorScheme
                                                  .secondary,
                                              title: Text(e.toString()),
                                              groupValue: result,
                                              onChanged: (e) {
                                                if (e != null) {
                                                  result = e;
                                                  Navigator.of(context)
                                                      .maybePop();
                                                }
                                              },
                                              value: e,
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ),
                                );
                                if (result !=
                                    Configuration
                                        .instance.mobileAlbumsGridSize) {
                                  await Configuration.instance.save(
                                    mobileAlbumsGridSize: result,
                                  );
                                  setState(() {});
                                }
                                break;
                              }
                            case 1:
                              {
                                int result = Configuration
                                    .instance.mobileArtistsGridSize;
                                await showDialog(
                                  context: context,
                                  builder: (context) => StatefulBuilder(
                                    builder: (context, setState) =>
                                        SimpleDialog(
                                      title: Text(
                                        Language
                                            .instance.MOBILE_ARTIST_GRID_SIZE,
                                      ),
                                      children: [1, 2, 3, 4]
                                          .map(
                                            (e) => RadioListTile<int>(
                                              activeColor: Theme.of(context)
                                                  .colorScheme
                                                  .secondary,
                                              title: Text(e.toString()),
                                              groupValue: result,
                                              onChanged: (e) {
                                                if (e != null) {
                                                  result = e;
                                                  Navigator.of(context)
                                                      .maybePop();
                                                }
                                              },
                                              value: e,
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ),
                                );
                                if (result !=
                                    Configuration
                                        .instance.mobileArtistsGridSize) {
                                  await Configuration.instance.save(
                                    mobileArtistsGridSize: result,
                                  );
                                  setState(() {});
                                }
                                break;
                              }
                          }
                        });
                      },
                    ),
                  PopupMainMenuModern()
                ],
              ),
              body: Stack(
                fit: StackFit.expand,
                children: [
                  FloatingSearchBarScrollNotifier(
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification notification) {
                        if (notification.depth == 0 &&
                            notification is ScrollEndNotification &&
                            notification.metrics.axis == Axis.horizontal) {
                          index.value = currentIndex;
                          widget.tabControllerNotifier.value =
                              TabRoute(currentIndex, TabRouteSender.pageView);
                        }
                        return false;
                      },
                      child: PageView(
                        physics: Collection.instance.tracks.isEmpty
                            ? const NeverScrollableScrollPhysics()
                            : null,
                        controller: pageController,
                        onPageChanged: (page) {
                          currentIndex = page;
                          setState(() {
                            showSearchCard = false;
                            // searchTextEditingController.clear();
                            // query.value = '';
                          });
                        },
                        children: [
                          AlbumTabModern(),
                          TrackTabModern(),
                          ArtistTabModern(),
                          PlaylistTabModern(),
                        ],
                      ),
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: Duration(milliseconds: 200),
                    child: showSearchCard
                        ? FloatingSearchBarSearchTabModern(
                            query: query,
                            key: Key("searchbar"),
                          )
                        : null,
                  ),
                ],
              ),
            ),
          );
  }
}
