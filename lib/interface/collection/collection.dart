/* 
 *  This file is part of Harmonoid (https://github.com/harmonoid/harmonoid).
 *  
 *  Harmonoid is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *  
 *  Harmonoid is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU General Public License for more details.
 *  
 *  You should have received a copy of the GNU General Public License
 *  along with Harmonoid. If not, see <https://www.gnu.org/licenses/>.
 * 
 *  Copyright 2020-2021, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
 */

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/intent.dart';
import 'package:harmonoid/interface/collection/album.dart';
import 'package:harmonoid/interface/collection/track.dart';
import 'package:harmonoid/interface/collection/artist.dart';
import 'package:harmonoid/interface/collection/playlist.dart';
import 'package:harmonoid/interface/youtube/youtubemusic.dart';
import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/interface/change_notifiers.dart';
import 'package:harmonoid/interface/collection/search.dart';
import 'package:harmonoid/interface/settings/settings.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/core/hotkeys.dart';
import 'package:harmonoid/utils/dimensions.dart';

class CollectionScreen extends StatefulWidget {
  /// Used only on Android.
  /// Since a [PageView] is used for enabling horizontal swiping, it makes [BottomNavigationBar] from [Home] able to control the pages.
  /// It was necessary to use this to support Android's back button to jump back to previous tabs.
  ///
  final ValueNotifier<TabRoute> tabControllerNotifier;
  const CollectionScreen({
    Key? key,
    required this.tabControllerNotifier,
  }) : super(key: key);
  CollectionScreenState createState() => CollectionScreenState();
}

class CollectionScreenState extends State<CollectionScreen>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  final FocusNode node = FocusNode();
  final PageController pageController = PageController(
    initialPage: isMobile ? 2 : 0,
  );
  final FloatingSearchBarController floatingSearchBarController =
      FloatingSearchBarController();
  final ValueNotifier<String> query = ValueNotifier<String>('');
  int index = isMobile ? 2 : 0;
  String string = '';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    widget.tabControllerNotifier.addListener(() {
      if (this.index != widget.tabControllerNotifier.value.index) {
        this.pageController.animateToPage(
              widget.tabControllerNotifier.value.index,
              duration: Duration(milliseconds: 200),
              curve: Curves.easeInOut,
            );
      }
    });
    this.pageController.addListener(() {
      this.floatingSearchBarController.show();
    });
    intent.play();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return isDesktop
        ? Scaffold(
            resizeToAvoidBottomInset: false,
            floatingActionButton: index != 4 ? RefreshCollectionButton() : null,
            body: Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.only(
                    top: kDesktopTitleBarHeight + kDesktopAppBarHeight,
                  ),
                  child: Consumer<CollectionRefreshController>(
                    builder: (context, refresh, __) => Stack(
                      alignment: Alignment.bottomLeft,
                      children: <Widget>[
                        PageTransitionSwitcher(
                          child: [
                            AlbumTab(),
                            TrackTab(),
                            ArtistTab(),
                            CollectionPlaylistTab(),
                            YouTubeMusic(),
                            CollectionSearch(
                              query: query,
                            ),
                          ][this.index],
                          transitionBuilder:
                              (child, animation, secondaryAnimation) =>
                                  SharedAxisTransition(
                            animation: animation,
                            secondaryAnimation: secondaryAnimation,
                            transitionType: SharedAxisTransitionType.vertical,
                            fillColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            child: child,
                          ),
                        ),
                        if (refresh.progress != refresh.total)
                          Card(
                            clipBehavior: Clip.antiAlias,
                            margin: EdgeInsets.only(
                              top: 16.0,
                              bottom: 16.0,
                              left: 16.0,
                              right: 16.0,
                            ),
                            elevation: 4.0,
                            child: Container(
                              color: Theme.of(context).cardColor,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  LinearProgressIndicator(
                                    value: refresh.progress / refresh.total,
                                    valueColor: AlwaysStoppedAnimation(
                                      Theme.of(context).primaryColor,
                                    ),
                                    backgroundColor: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.4),
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(12.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 16.0,
                                        ),
                                        Text(
                                          '${refresh.progress}/${refresh.total}',
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline2,
                                        ),
                                        SizedBox(
                                          width: 16.0,
                                        ),
                                        Expanded(
                                          child: Text(
                                            language.COLLECTION_INDEXING_LABEL,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Container(
                                  height: 44.0,
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 16.0),
                                  child: ListView(
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    children: [
                                      language.ALBUM,
                                      language.TRACK,
                                      language.ARTIST,
                                      language.PLAYLIST,
                                      language.YOUTUBE,
                                    ].map(
                                      (tab) {
                                        final _index = [
                                          language.ALBUM,
                                          language.TRACK,
                                          language.ARTIST,
                                          language.PLAYLIST,
                                          language.YOUTUBE,
                                        ].indexOf(tab);
                                        return InkWell(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          onTap: () => this.setState(
                                              () => this.index = _index),
                                          child: Container(
                                            height: 40.0,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 4.0),
                                            alignment: Alignment.center,
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: Text(
                                              tab.toUpperCase(),
                                              style: TextStyle(
                                                fontSize: 20.0,
                                                fontWeight: this.index == _index
                                                    ? FontWeight.w600
                                                    : FontWeight.w300,
                                                color: (Theme.of(context)
                                                                .brightness ==
                                                            Brightness.dark
                                                        ? Colors.white
                                                        : Colors.black)
                                                    .withOpacity(
                                                        this.index == _index
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
                              Container(
                                height: 42.0,
                                width: 280.0,
                                alignment: Alignment.center,
                                margin: EdgeInsets.only(top: 0.0, bottom: 0.0),
                                padding: EdgeInsets.only(top: 2.0),
                                child: Focus(
                                  onFocusChange: (hasFocus) {
                                    if (hasFocus) {
                                      HotKeys.disableSpaceHotKey();
                                    } else {
                                      HotKeys.enableSpaceHotKey();
                                    }
                                  },
                                  child: TextField(
                                    focusNode: this.node,
                                    cursorWidth: 1.0,
                                    onChanged: (value) {
                                      string = value;
                                    },
                                    onSubmitted: (value) {
                                      query.value = value;
                                      if (string.isNotEmpty)
                                        this.setState(() {
                                          this.index = 5;
                                        });
                                      this.node.requestFocus();
                                    },
                                    cursorColor: Theme.of(context).brightness ==
                                            Brightness.light
                                        ? Colors.black
                                        : Colors.white,
                                    textAlignVertical: TextAlignVertical.bottom,
                                    style:
                                        Theme.of(context).textTheme.headline4,
                                    decoration: InputDecoration(
                                      suffixIcon: IconButton(
                                        splashColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        onPressed: () {
                                          query.value = string;
                                          if (string.isNotEmpty)
                                            this.setState(() {
                                              this.index = 5;
                                            });
                                          this.node.requestFocus();
                                        },
                                        icon: Transform.rotate(
                                          angle: pi / 2,
                                          child: Icon(
                                            Icons.search,
                                            size: 20.0,
                                            color: Theme.of(context)
                                                .iconTheme
                                                .color,
                                          ),
                                        ),
                                      ),
                                      contentPadding: EdgeInsets.only(
                                          left: 10.0, bottom: 14.0),
                                      hintText:
                                          language.COLLECTION_SEARCH_WELCOME,
                                      hintStyle: Theme.of(context)
                                          .textTheme
                                          .headline3
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                        .brightness ==
                                                    Brightness.light
                                                ? Colors.black.withOpacity(0.6)
                                                : Colors.white60,
                                          ),
                                      filled: true,
                                      fillColor: Theme.of(context).brightness ==
                                              Brightness.light
                                          ? Colors.white
                                          : Color(0xFF202020),
                                      hoverColor:
                                          Theme.of(context).brightness ==
                                                  Brightness.light
                                              ? Colors.white
                                              : Color(0xFF202020),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Theme.of(context)
                                              .dividerColor
                                              .withOpacity(0.32),
                                          width: 0.6,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Theme.of(context)
                                              .dividerColor
                                              .withOpacity(0.32),
                                          width: 0.6,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Theme.of(context)
                                              .dividerColor
                                              .withOpacity(0.32),
                                          width: 0.6,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 24.0,
                              ),
                              ContextMenuButton<dynamic>(
                                offset: Offset.fromDirection(pi / 2, 64.0),
                                icon: Icon(
                                  Icons.sort,
                                  size: 20.0,
                                ),
                                elevation: 4.0,
                                onSelected: (value) async {
                                  if (value is CollectionSort) {
                                    Provider.of<Collection>(context,
                                            listen: false)
                                        .sort(type: value);
                                    await configuration.save(
                                      collectionSortType: value,
                                    );
                                  } else if (value is CollectionOrder) {
                                    Provider.of<Collection>(context,
                                            listen: false)
                                        .order(type: value);
                                    await configuration.save(
                                      collectionOrderType: value,
                                    );
                                  }
                                },
                                itemBuilder: (context) => [
                                  CheckedPopupMenuItem(
                                    padding: EdgeInsets.zero,
                                    checked: collection.collectionSortType ==
                                        CollectionSort.aToZ,
                                    value: CollectionSort.aToZ,
                                    child: Text(
                                      language.A_TO_Z,
                                      style:
                                          Theme.of(context).textTheme.headline4,
                                    ),
                                  ),
                                  CheckedPopupMenuItem(
                                    padding: EdgeInsets.zero,
                                    checked: collection.collectionSortType ==
                                        CollectionSort.dateAdded,
                                    value: CollectionSort.dateAdded,
                                    child: Text(
                                      language.DATE_ADDED,
                                      style:
                                          Theme.of(context).textTheme.headline4,
                                    ),
                                  ),
                                  CheckedPopupMenuItem(
                                    padding: EdgeInsets.zero,
                                    checked: collection.collectionSortType ==
                                        CollectionSort.year,
                                    value: CollectionSort.year,
                                    child: Text(
                                      language.YEAR,
                                      style:
                                          Theme.of(context).textTheme.headline4,
                                    ),
                                  ),
                                  PopupMenuDivider(),
                                  CheckedPopupMenuItem(
                                    padding: EdgeInsets.zero,
                                    checked: collection.collectionOrderType ==
                                        CollectionOrder.ascending,
                                    value: CollectionOrder.ascending,
                                    child: Text(
                                      language.ASCENDING,
                                      style:
                                          Theme.of(context).textTheme.headline4,
                                    ),
                                  ),
                                  CheckedPopupMenuItem(
                                    padding: EdgeInsets.zero,
                                    checked: collection.collectionOrderType ==
                                        CollectionOrder.descending,
                                    value: CollectionOrder.descending,
                                    child: Text(
                                      language.DESCENDING,
                                      style:
                                          Theme.of(context).textTheme.headline4,
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
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
                              SizedBox(
                                width: 8.0,
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
            value: [
              SystemUiOverlayStyle.light,
              SystemUiOverlayStyle.dark,
            ][Theme.of(context).brightness.index],
            child: Consumer<CollectionRefreshController>(
              builder: (context, refresh, _) => Scaffold(
                resizeToAvoidBottomInset: false,
                body: Stack(
                  fit: StackFit.expand,
                  children: [
                    FloatingSearchBar(
                      controller: this.floatingSearchBarController,
                      hint: refresh.progress == refresh.total
                          ? language.SEARCH_WELCOME
                          : language.COLLECTION_INDEXING_HINT,
                      progress: refresh.progress == refresh.total
                          ? null
                          : refresh.progress / refresh.total,
                      transitionCurve: Curves.easeInOut,
                      width: MediaQuery.of(context).size.width - 2 * tileMargin,
                      height: kMobileSearchBarHeight,
                      margins: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top + tileMargin,
                      ),
                      accentColor: Theme.of(context).primaryColor,
                      onQueryChanged: (query) {},
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
                          child: CircularButton(
                            icon: const Icon(Icons.more_vert),
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
                                items: [
                                  PopupMenuItem(
                                    value: 0,
                                    child: ListTile(
                                      leading: Icon(Icons.sort),
                                      title: Text(language.SORT_BY),
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 1,
                                    child: ListTile(
                                      leading: Icon(Icons.settings),
                                      title: Text(language.SETTING),
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 2,
                                    child: ListTile(
                                      leading: Icon(Icons.info),
                                      title: Text(language.ABOUT_TITLE),
                                    ),
                                  ),
                                ],
                              ).then(
                                (value) async {
                                  switch (value) {
                                    case 0:
                                      {
                                        final value = await showMenu<dynamic>(
                                          context: context,
                                          position: position,
                                          items: [
                                            CheckedPopupMenuItem(
                                              padding: EdgeInsets.zero,
                                              checked: collection
                                                      .collectionSortType ==
                                                  CollectionSort.aToZ,
                                              value: CollectionSort.aToZ,
                                              child: Text(
                                                language.A_TO_Z,
                                              ),
                                            ),
                                            CheckedPopupMenuItem(
                                              padding: EdgeInsets.zero,
                                              checked: collection
                                                      .collectionSortType ==
                                                  CollectionSort.dateAdded,
                                              value: CollectionSort.dateAdded,
                                              child: Text(
                                                language.DATE_ADDED,
                                              ),
                                            ),
                                            CheckedPopupMenuItem(
                                              padding: EdgeInsets.zero,
                                              checked: collection
                                                      .collectionSortType ==
                                                  CollectionSort.year,
                                              value: CollectionSort.year,
                                              child: Text(
                                                language.YEAR,
                                              ),
                                            ),
                                            PopupMenuDivider(),
                                            CheckedPopupMenuItem(
                                              padding: EdgeInsets.zero,
                                              checked: collection
                                                      .collectionOrderType ==
                                                  CollectionOrder.ascending,
                                              value: CollectionOrder.ascending,
                                              child: Text(
                                                language.ASCENDING,
                                              ),
                                            ),
                                            CheckedPopupMenuItem(
                                              padding: EdgeInsets.zero,
                                              checked: collection
                                                      .collectionOrderType ==
                                                  CollectionOrder.descending,
                                              value: CollectionOrder.descending,
                                              child: Text(
                                                language.DESCENDING,
                                              ),
                                            ),
                                          ],
                                        );
                                        if (value is CollectionSort) {
                                          Provider.of<Collection>(context,
                                                  listen: false)
                                              .sort(type: value);
                                          await configuration.save(
                                            collectionSortType: value,
                                          );
                                          break;
                                        } else if (value is CollectionOrder) {
                                          Provider.of<Collection>(context,
                                                  listen: false)
                                              .order(type: value);
                                          await configuration.save(
                                            collectionOrderType: value,
                                          );
                                          break;
                                        }
                                      }
                                  }
                                },
                              );
                            },
                          ),
                        ),
                        FloatingSearchBarAction.searchToClear(
                          showIfClosed: false,
                        ),
                      ],
                      builder: (context, transition) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Material(
                            color: Colors.white,
                            elevation: 4.0,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: Colors.accents.map((color) {
                                return Container(height: 112, color: color);
                              }).toList(),
                            ),
                          ),
                        );
                      },
                      body: FloatingSearchBarScrollNotifier(
                        child: PageView(
                          controller: this.pageController,
                          onPageChanged: (page) {
                            if (this.index != page) {
                              this.index = page;
                              widget.tabControllerNotifier.value =
                                  TabRoute(page, TabRouteSender.pageView);
                            }
                          },
                          children: [
                            CollectionPlaylistTab(),
                            TrackTab(),
                            AlbumTab(),
                            ArtistTab(),
                            YouTubeMusic(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                bottomNavigationBar: isMobile
                    ? MobileBottomNavigationBar(
                        tabControllerNotifier: widget.tabControllerNotifier,
                      )
                    : null,
              ),
            ),
          );
  }
}
