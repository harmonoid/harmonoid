/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart' hide Intent, SearchBarThemeData;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';
import 'package:window_plus/window_plus.dart';
import 'package:safe_local_storage/safe_local_storage.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/core/intent.dart';
import 'package:harmonoid/state/collection_refresh.dart';
import 'package:harmonoid/state/mobile_now_playing_controller.dart';
import 'package:harmonoid/utils/theme.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/constants.dart';
import 'package:harmonoid/interface/home.dart';
import 'package:harmonoid/interface/collection/album.dart';
import 'package:harmonoid/interface/collection/track.dart';
import 'package:harmonoid/interface/collection/artist.dart';
import 'package:harmonoid/interface/collection/playlist.dart';
import 'package:harmonoid/interface/collection/search.dart';
import 'package:harmonoid/interface/settings/settings.dart';
import 'package:harmonoid/interface/mini_now_playing_bar.dart';
import 'package:harmonoid/interface/missing_directories_screen.dart';
import 'package:harmonoid/constants/language.dart';

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
      PageController(initialPage: Configuration.instance.libraryTab);
  final ValueNotifier<String> query = ValueNotifier<String>('');
  String queryStr = '';
  final ValueNotifier<int> index = ValueNotifier(
    Configuration.instance.libraryTab,
  );
  int currentIndex = Configuration.instance.libraryTab;

  @override
  bool get wantKeepAlive => true;

  FutureOr<void> saveCurrentTab() {
    // [index.value] at -1 is the [SearchTab] on desktop, which should not be saved in cache as a starting point for the next session.
    // It is only meant to be accessed via the search [CustomTextField].
    if (isDesktop && index.value == -1) {
      return Future.value();
    }
    if (index.value != Configuration.instance.libraryTab) {
      return Configuration.instance.save(libraryTab: index.value);
    }
  }

  @override
  void initState() {
    super.initState();
    widget.tabControllerNotifier.addListener(() {
      if (index.value != widget.tabControllerNotifier.value.index) {
        final duration =
            Theme.of(context).extension<AnimationDuration>()?.fast ??
                Duration.zero;
        if (duration == Duration.zero) {
          pageController.jumpToPage(widget.tabControllerNotifier.value.index);
        } else {
          pageController.animateToPage(
            widget.tabControllerNotifier.value.index,
            duration: duration,
            curve: Curves.easeInOut,
          );
        }
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
              MaterialRoute(
                builder: (context) => MissingDirectoriesScreen(),
              ),
            );
          }
        }
      },
    );
  }

  @override
  void dispose() {
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
                index.value != -1 ? RefreshCollectionButton() : null,
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
                          duration: Theme.of(context)
                                  .extension<AnimationDuration>()
                                  ?.medium ??
                              Duration.zero,
                          child: index.value == -1
                              ? SearchTab(query: query)
                              : [
                                  AlbumTab(),
                                  TrackTab(),
                                  ArtistTab(),
                                  PlaylistTab(),
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
                        if (!refresh.completed)
                          Positioned(
                            left: 0.0,
                            bottom: 0.0,
                            child: Card(
                              // NOTE: Force elevation.
                              elevation: kDefaultCardElevation,
                              clipBehavior: Clip.antiAlias,
                              margin: EdgeInsets.all(16.0),
                              child: Container(
                                width: 328.0,
                                height: 56.0,
                                color: Theme.of(context).cardTheme.color,
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    LinearProgressIndicator(
                                      value: refresh.progress == null
                                          ? null
                                          : (refresh.progress ?? 0) /
                                              refresh.total,
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
                                                          'COMPLETED',
                                                          refresh.progress
                                                              .toString(),
                                                        )
                                                        .replaceAll(
                                                          'TOTAL',
                                                          refresh.total
                                                              .toString(),
                                                        ),
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.center,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge,
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
                                ].asMap().entries.map(
                                  (tab) {
                                    return InkWell(
                                      borderRadius: BorderRadius.circular(4.0),
                                      onTap: () {
                                        if (index.value == tab.key) return;
                                        setState(() {
                                          index.value = tab.key;
                                        });
                                      },
                                      child: Container(
                                        height: 40.0,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4.0,
                                        ),
                                        alignment: Alignment.center,
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 4.0,
                                        ),
                                        child: Text(
                                          tab.value.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 20.0,
                                            fontWeight: index.value == tab.key
                                                ? FontWeight.w600
                                                : FontWeight.w300,
                                            color: index.value == tab.key
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
                                  child: CustomTextField(
                                    focusNode: node,
                                    cursorWidth: 1.0,
                                    onChanged: (value) {
                                      queryStr = value;
                                    },
                                    onSubmitted: (value) {
                                      query.value = value;
                                      if (queryStr.isNotEmpty)
                                        setState(() {
                                          index.value = -1;
                                        });
                                      node.requestFocus();
                                    },
                                    textAlignVertical: TextAlignVertical.center,
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
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
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                        ),
                                      ),
                                      trailingIconOnPressed: () {
                                        query.value = queryStr;
                                        if (queryStr.isNotEmpty)
                                          setState(() {
                                            index.value = -1;
                                          });
                                        node.requestFocus();
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12.0),
                                PlayFileOrURLButton(),
                                CollectionMoreButton(),
                                Tooltip(
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
        : AnnotatedRegion<SystemUiOverlayStyle>(
            value: Theme.of(context).appBarTheme.systemOverlayStyle ??
                SystemUiOverlayStyle(),
            child: Consumer<CollectionRefresh>(
              builder: (context, refresh, _) => Scaffold(
                resizeToAvoidBottomInset: false,
                floatingActionButton: ValueListenableBuilder(
                  valueListenable: index,
                  builder: (context, value, child) => AnimatedSwitcher(
                    duration: Theme.of(context)
                            .extension<AnimationDuration>()
                            ?.medium ??
                        Duration.zero,
                    reverseDuration: Theme.of(context)
                            .extension<AnimationDuration>()
                            ?.medium ??
                        Duration.zero,
                    switchInCurve: Curves.easeInOut,
                    switchOutCurve: Curves.easeInOut,
                    transitionBuilder: (child, value) => FadeTransition(
                      opacity: value,
                      child: child,
                    ),
                    child: MiniNowPlayingBarRefreshCollectionButton(
                      index: index,
                    ),
                  ),
                ),
                body: Stack(
                  fit: StackFit.expand,
                  children: [
                    FloatingSearchBar(
                      controller: widget.floatingSearchBarController,
                      automaticallyImplyBackButton: false,
                      hint: refresh.completed
                          ? Language.instance.SEARCH_WELCOME
                          : Language.instance.COLLECTION_INDEXING_HINT,
                      progress: refresh.completed
                          ? null
                          : refresh.progress == null
                              ? true
                              : refresh.total == 0
                                  ? 1.0
                                  : (refresh.progress ?? 0.0) / refresh.total,
                      transitionCurve: Curves.easeInOut,
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      margins: EdgeInsets.only(
                        top: tileMargin(context) +
                            MediaQuery.of(context).padding.top,
                      ),
                      height: kMobileSearchBarHeight,
                      width: MediaQuery.of(context).size.width -
                          (isMaterial3(context)
                              ? 4 * tileMargin(context)
                              : 2 * tileMargin(context)),
                      borderRadius: Theme.of(context)
                          .extension<SearchBarThemeData>()
                          ?.borderRadius,
                      accentColor: Theme.of(context)
                          .extension<SearchBarThemeData>()
                          ?.accentColor,
                      backgroundColor: Theme.of(context)
                          .extension<SearchBarThemeData>()
                          ?.backgroundColor,
                      shadowColor: Theme.of(context)
                          .extension<SearchBarThemeData>()
                          ?.shadowColor,
                      elevation: Theme.of(context)
                              .extension<SearchBarThemeData>()
                              ?.elevation ??
                          kDefaultCardElevation,
                      onQueryChanged: (value) => query.value = value,
                      clearQueryOnClose: true,
                      hintStyle: Theme.of(context)
                          .extension<SearchBarThemeData>()
                          ?.hintStyle,
                      queryStyle: Theme.of(context)
                          .extension<SearchBarThemeData>()
                          ?.queryStyle,
                      transitionDuration: Theme.of(context)
                              .extension<AnimationDuration>()
                              ?.medium ??
                          Duration.zero,
                      transition: CircularFloatingSearchBarTransition(
                        divider: const Divider(
                          height: 2.0,
                          thickness: 2.0,
                        ),
                      ),
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
                          // TODO(@alexmercerind): Genre support.
                          child: ValueListenableBuilder<int>(
                            valueListenable: index,
                            builder: (context, tab, child) => AnimatedOpacity(
                              duration: Theme.of(context)
                                      .extension<AnimationDuration>()
                                      ?.fast ??
                                  Duration.zero,
                              curve: Curves.easeInOut,
                              opacity: {
                                kAlbumTabIndex,
                                kArtistTabIndex,
                                kGenreTabIndex,
                              }.contains(tab)
                                  ? 1.0
                                  : 0.0,
                              child: CircularButton(
                                icon: Icon(
                                  Icons.view_list_outlined,
                                  color: Theme.of(context)
                                      .appBarTheme
                                      .actionsIconTheme
                                      ?.color,
                                ),
                                onPressed: () async {
                                  if (!{
                                    kAlbumTabIndex,
                                    kArtistTabIndex,
                                    kGenreTabIndex,
                                  }.contains(tab)) return;
                                  return showDialog(
                                    context: context,
                                    builder: (context) => SimpleDialog(
                                      title: Text(
                                        {
                                              kAlbumTabIndex: Language.instance
                                                  .MOBILE_ALBUM_GRID_SIZE,
                                              kArtistTabIndex: Language.instance
                                                  .MOBILE_ARTIST_GRID_SIZE,
                                            }[tab] ??
                                            '',
                                      ),
                                      children: [1, 2, 3, 4]
                                          .map(
                                            (e) => RadioListTile<int>(
                                              title: Text(e.toString()),
                                              groupValue: {
                                                    kAlbumTabIndex: Configuration
                                                        .instance
                                                        .mobileAlbumsGridSize,
                                                    kArtistTabIndex: Configuration
                                                        .instance
                                                        .mobileArtistsGridSize,
                                                  }[tab] ??
                                                  -1,
                                              onChanged: (e) async {
                                                if (e != null) {
                                                  if (tab == kAlbumTabIndex) {
                                                    if (e !=
                                                        Configuration.instance
                                                            .mobileAlbumsGridSize) {
                                                      await Configuration
                                                          .instance
                                                          .save(
                                                        mobileAlbumsGridSize: e,
                                                      );
                                                    }
                                                  }
                                                  if (tab == kArtistTabIndex) {
                                                    if (e !=
                                                        Configuration.instance
                                                            .mobileArtistsGridSize) {
                                                      await Configuration
                                                          .instance
                                                          .save(
                                                        mobileArtistsGridSize:
                                                            e,
                                                      );
                                                    }
                                                  }
                                                  Navigator.of(context)
                                                      .maybePop();
                                                  setState(() {});
                                                }
                                              },
                                              value: e,
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        FloatingSearchBarAction(
                          showIfOpened: false,
                          child: MobileAppBarOverflowButton(),
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
                        return FloatingSearchBarSearchTab(query: query);
                      },
                      body: FloatingSearchBarScrollNotifier(
                        child: NotificationListener<ScrollNotification>(
                          onNotification: (ScrollNotification notification) {
                            if (notification.depth == 0 &&
                                notification is ScrollEndNotification &&
                                notification.metrics.axis == Axis.horizontal) {
                              index.value = currentIndex;
                              widget.tabControllerNotifier.value = TabRoute(
                                  currentIndex, TabRouteSender.pageView);
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
                            },
                            children: [
                              AlbumTab(),
                              TrackTab(),
                              ArtistTab(),
                              PlaylistTab(),
                            ],
                          ),
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
