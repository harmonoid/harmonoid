/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'dart:math';
// ignore: unnecessary_import
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart'
    hide ReorderableDragStartListener, Intent;
import 'package:flutter/foundation.dart';
import 'package:animations/animations.dart';
import 'package:harmonoid/core/playback.dart';
import 'package:media_library/media_library.dart';
import 'package:external_path/external_path.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:known_extents_list_view_builder/known_extents_list_view_builder.dart';

import 'package:harmonoid/core/intent.dart';
import 'package:harmonoid/core/hotkeys.dart';
import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/utils/file_system.dart';
import 'package:harmonoid/utils/dimensions.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/theme.dart';
import 'package:harmonoid/utils/windows_info.dart';
import 'package:harmonoid/state/collection_refresh.dart';
import 'package:harmonoid/state/mobile_now_playing_controller.dart';
import 'package:harmonoid/interface/file_info_screen.dart';
import 'package:harmonoid/interface/settings/settings.dart';
import 'package:harmonoid/interface/settings/about.dart';
import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/web/web.dart';

class CustomListView extends StatefulWidget {
  final ScrollController? controller;
  final double? cacheExtent;
  final List<Widget> children;
  final Axis? scrollDirection;
  final bool? shrinkWrap;
  final EdgeInsets? padding;
  final double? itemExtent;
  final ScrollViewKeyboardDismissBehavior? keyboardDismissBehavior;

  CustomListView({
    required this.children,
    this.controller,
    this.scrollDirection,
    this.shrinkWrap,
    this.padding,
    this.itemExtent,
    this.cacheExtent,
    this.keyboardDismissBehavior,
  });

  @override
  _CustomListViewState createState() => _CustomListViewState();
}

class _CustomListViewState extends State<CustomListView> {
  late final ScrollController controller;

  @override
  void initState() {
    super.initState();
    controller = widget.controller ?? ScrollController();
    // TODO: MUST BE REMOVED BEFORE Flutter 3.1.0.
    if (Platform.isWindows) {
      controller.addListener(
        () {
          final scrollDirection = controller.position.userScrollDirection;
          if (scrollDirection != ScrollDirection.idle) {
            var scrollEnd = controller.offset +
                (scrollDirection == ScrollDirection.reverse
                    ? kWindowsScrollDelta
                    : -kWindowsScrollDelta);
            scrollEnd = math.min(controller.position.maxScrollExtent,
                math.max(controller.position.minScrollExtent, scrollEnd));
            controller.jumpTo(scrollEnd);
          }
        },
      );
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      cacheExtent: widget.cacheExtent,
      keyboardDismissBehavior: widget.keyboardDismissBehavior ??
          ScrollViewKeyboardDismissBehavior.onDrag,
      padding: widget.padding ?? EdgeInsets.zero,
      controller: controller,
      scrollDirection: widget.scrollDirection ?? Axis.vertical,
      shrinkWrap: widget.shrinkWrap ?? false,
      children: widget.children,
      itemExtent: widget.itemExtent,
    );
  }
}

class CustomListViewBuilder extends StatefulWidget {
  final ScrollController? controller;
  final int velocity = 40;
  final int itemCount;
  final List<double> itemExtents;
  final Widget Function(BuildContext, int) itemBuilder;
  final Axis? scrollDirection;
  final bool? shrinkWrap;
  final EdgeInsets? padding;

  CustomListViewBuilder({
    required this.itemCount,
    required this.itemExtents,
    required this.itemBuilder,
    this.controller,
    this.scrollDirection,
    this.shrinkWrap,
    this.padding,
  });

  @override
  _CustomListViewBuilderState createState() => _CustomListViewBuilderState();
}

class _CustomListViewBuilderState extends State<CustomListViewBuilder> {
  late final ScrollController controller;

  @override
  void initState() {
    super.initState();
    controller = widget.controller ?? ScrollController();
    // TODO: MUST BE REMOVED BEFORE Flutter 3.1.0.
    if (Platform.isWindows) {
      controller.addListener(
        () {
          final scrollDirection = controller.position.userScrollDirection;
          if (scrollDirection != ScrollDirection.idle) {
            var scrollEnd = controller.offset +
                (scrollDirection == ScrollDirection.reverse
                    ? kWindowsScrollDelta
                    : -kWindowsScrollDelta);
            scrollEnd = math.min(controller.position.maxScrollExtent,
                math.max(controller.position.minScrollExtent, scrollEnd));
            controller.jumpTo(scrollEnd);
          }
        },
      );
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KnownExtentsListView.builder(
      controller: controller,
      itemExtents: widget.itemExtents,
      itemCount: widget.itemCount,
      itemBuilder: widget.itemBuilder,
      padding: widget.padding,
    );
  }
}

class CustomSingleChildScrollView extends StatefulWidget {
  final ScrollController? controller;
  final Widget child;
  CustomSingleChildScrollView({
    Key? key,
    this.controller,
    required this.child,
  }) : super(key: key);

  @override
  State<CustomSingleChildScrollView> createState() =>
      _CustomSingleChildScrollViewState();
}

class _CustomSingleChildScrollViewState
    extends State<CustomSingleChildScrollView> {
  late final ScrollController controller;

  @override
  void initState() {
    super.initState();
    controller = widget.controller ?? ScrollController();
    // TODO: MUST BE REMOVED BEFORE Flutter 3.1.0.
    if (Platform.isWindows) {
      controller.addListener(
        () {
          final scrollDirection = controller.position.userScrollDirection;
          if (scrollDirection != ScrollDirection.idle) {
            var scrollEnd = controller.offset +
                (scrollDirection == ScrollDirection.reverse
                    ? kWindowsScrollDelta
                    : -kWindowsScrollDelta);
            scrollEnd = math.min(controller.position.maxScrollExtent,
                math.max(controller.position.minScrollExtent, scrollEnd));
            controller.jumpTo(scrollEnd);
          }
        },
      );
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: controller,
      child: widget.child,
    );
  }
}

class CustomFutureBuilder<T> extends StatefulWidget {
  final Future<T>? future;
  final Widget Function(BuildContext) loadingBuilder;
  final Widget Function(BuildContext, T?) builder;
  CustomFutureBuilder({
    Key? key,
    required this.future,
    required this.loadingBuilder,
    required this.builder,
  }) : super(key: key);

  @override
  State<CustomFutureBuilder<T>> createState() => _CustomFutureBuilderState();
}

class _CustomFutureBuilderState<T> extends State<CustomFutureBuilder<T>> {
  T? data;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.future?.then((value) {
        setState(() {
          data = value;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return data == null
        ? widget.loadingBuilder(context)
        : widget.builder(context, data);
  }
}

class SortBarFixedHolder extends StatelessWidget {
  final Widget child;
  const SortBarFixedHolder({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(width: tileMargin),
        Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(4.0),
          child: InkWell(
            onTap: () {
              Playback.instance.open(
                [...Collection.instance.tracks]..shuffle(),
              );
            },
            borderRadius: BorderRadius.circular(4.0),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 6.0,
                vertical: 2.0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shuffle,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(
                    width: 4.0,
                  ),
                  Text(
                    Language.instance.SHUFFLE,
                    style: Theme.of(context).textTheme.headline3?.copyWith(
                          color: Theme.of(context).primaryColor,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: tileMargin),
        if (Random().nextInt(400) == 50)
          Text(
            'Yeah! You found the easter egg. 🥚',
            style: Theme.of(context).textTheme.headline3,
          )
        else if (DateTime.now().day == 25 && DateTime.now().month == 12)
          Text(
            'Merry Christmas! ❄️',
            style: Theme.of(context).textTheme.headline3,
          )
        else if (DateTime.now().day == 1 && DateTime.now().month == 1)
          Text(
            'Happy New Year! 🎈',
            style: Theme.of(context).textTheme.headline3,
          ),
        Spacer(),
        child,
      ],
    );
  }
}

class SortBar extends StatefulWidget {
  final int tab;
  final bool fixed;
  final ValueNotifier<bool> hover;
  SortBar({
    Key? key,
    required this.tab,
    required this.fixed,
    required this.hover,
  }) : super(key: key);

  @override
  State<SortBar> createState() => _SortBarState();
}

class _SortBarState extends State<SortBar> {
  bool _hover0 = false;
  bool _hover1 = false;
  final GlobalKey _key0 = GlobalKey();
  final GlobalKey _key1 = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final tab = widget.tab;
    final child = Consumer<Collection>(
      builder: (context, collection, _) => Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 8.0),
          MouseRegion(
            onEnter: (e) => setState(() => _hover0 = true),
            onExit: (e) => setState(() => _hover0 = false),
            child: InkWell(
              key: _key0,
              borderRadius: BorderRadius.circular(4.0),
              onTap: () async {
                final value = await showMenu(
                  elevation: 4.0,
                  context: context,
                  position: RelativeRect.fromLTRB(
                    _key0.globalPaintBounds!.left - (widget.fixed ? 0.0 : 8.0),
                    _key0.globalPaintBounds!.bottom +
                        tileMargin / (widget.fixed ? 2.0 : 1.0),
                    MediaQuery.of(context).size.width,
                    MediaQuery.of(context).size.height,
                  ),
                  items: <PopupMenuEntry>[
                    ...{
                      0: <PopupMenuItem>[
                        CheckedPopupMenuItem(
                          checked:
                              Collection.instance.albumsSort == AlbumsSort.aToZ,
                          value: AlbumsSort.aToZ,
                          padding: EdgeInsets.zero,
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            title: Text(
                              Language.instance.A_TO_Z,
                              style: Theme.of(context).textTheme.headline4,
                            ),
                          ),
                        ),
                        CheckedPopupMenuItem(
                          checked: Collection.instance.albumsSort ==
                              AlbumsSort.dateAdded,
                          value: AlbumsSort.dateAdded,
                          padding: EdgeInsets.zero,
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            title: Text(
                              Language.instance.DATE_ADDED,
                              style: Theme.of(context).textTheme.headline4,
                            ),
                          ),
                        ),
                        CheckedPopupMenuItem(
                          checked:
                              Collection.instance.albumsSort == AlbumsSort.year,
                          value: AlbumsSort.year,
                          padding: EdgeInsets.zero,
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            title: Text(
                              Language.instance.YEAR,
                              style: Theme.of(context).textTheme.headline4,
                            ),
                          ),
                        ),
                        CheckedPopupMenuItem(
                          checked: Collection.instance.albumsSort ==
                              AlbumsSort.artist,
                          value: AlbumsSort.artist,
                          padding: EdgeInsets.zero,
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            title: Text(
                              Language.instance.ARTIST,
                              style: Theme.of(context).textTheme.headline4,
                            ),
                          ),
                        ),
                      ],
                      1: <PopupMenuItem>[
                        CheckedPopupMenuItem(
                          checked:
                              Collection.instance.tracksSort == TracksSort.aToZ,
                          value: TracksSort.aToZ,
                          padding: EdgeInsets.zero,
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            title: Text(
                              Language.instance.A_TO_Z,
                              style: Theme.of(context).textTheme.headline4,
                            ),
                          ),
                        ),
                        CheckedPopupMenuItem(
                          checked: Collection.instance.tracksSort ==
                              TracksSort.dateAdded,
                          value: TracksSort.dateAdded,
                          padding: EdgeInsets.zero,
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            title: Text(
                              Language.instance.DATE_ADDED,
                              style: Theme.of(context).textTheme.headline4,
                            ),
                          ),
                        ),
                        CheckedPopupMenuItem(
                          checked:
                              Collection.instance.tracksSort == TracksSort.year,
                          value: TracksSort.year,
                          padding: EdgeInsets.zero,
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            title: Text(
                              Language.instance.YEAR,
                              style: Theme.of(context).textTheme.headline4,
                            ),
                          ),
                        ),
                      ],
                      2: <PopupMenuItem>[
                        CheckedPopupMenuItem(
                          checked: Collection.instance.artistsSort ==
                              ArtistsSort.aToZ,
                          value: ArtistsSort.aToZ,
                          padding: EdgeInsets.zero,
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            title: Text(
                              Language.instance.A_TO_Z,
                              style: Theme.of(context).textTheme.headline4,
                            ),
                          ),
                        ),
                        CheckedPopupMenuItem(
                          checked: Collection.instance.artistsSort ==
                              ArtistsSort.dateAdded,
                          value: ArtistsSort.dateAdded,
                          padding: EdgeInsets.zero,
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            title: Text(
                              Language.instance.DATE_ADDED,
                              style: Theme.of(context).textTheme.headline4,
                            ),
                          ),
                        ),
                      ],
                      3: <PopupMenuItem>[
                        CheckedPopupMenuItem(
                          checked:
                              Collection.instance.genresSort == GenresSort.aToZ,
                          value: GenresSort.aToZ,
                          padding: EdgeInsets.zero,
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            title: Text(
                              Language.instance.A_TO_Z,
                              style: Theme.of(context).textTheme.headline4,
                            ),
                          ),
                        ),
                        CheckedPopupMenuItem(
                          checked: Collection.instance.genresSort ==
                              GenresSort.dateAdded,
                          value: GenresSort.dateAdded,
                          padding: EdgeInsets.zero,
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            title: Text(
                              Language.instance.DATE_ADDED,
                              style: Theme.of(context).textTheme.headline4,
                            ),
                          ),
                        ),
                      ],
                    }[tab]!,
                  ],
                );
                if (value is AlbumsSort) {
                  await Collection.instance.sort(albumsSort: value);
                  await Configuration.instance.save(albumsSort: value);
                }
                if (value is TracksSort) {
                  await Collection.instance.sort(tracksSort: value);
                  await Configuration.instance.save(tracksSort: value);
                }
                if (value is ArtistsSort) {
                  await Collection.instance.sort(artistsSort: value);
                  await Configuration.instance.save(artistsSort: value);
                }
                if (value is GenresSort) {
                  await Collection.instance.sort(genresSort: value);
                  await Configuration.instance.save(genresSort: value);
                }
              },
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 2.0),
                height: 28.0,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(width: 4.0),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${Language.instance.SORT_BY}: ',
                            style: Theme.of(context).textTheme.headline4,
                          ),
                          TextSpan(
                            text: {
                              0: {
                                AlbumsSort.aToZ: Language.instance.A_TO_Z,
                                AlbumsSort.dateAdded:
                                    Language.instance.DATE_ADDED,
                                AlbumsSort.year: Language.instance.YEAR,
                                AlbumsSort.artist: Language.instance.ARTIST,
                              }[collection.albumsSort]!,
                              1: {
                                TracksSort.aToZ: Language.instance.A_TO_Z,
                                TracksSort.dateAdded:
                                    Language.instance.DATE_ADDED,
                                TracksSort.year: Language.instance.YEAR,
                              }[collection.tracksSort]!,
                              2: {
                                ArtistsSort.aToZ: Language.instance.A_TO_Z,
                                ArtistsSort.dateAdded:
                                    Language.instance.DATE_ADDED,
                              }[collection.artistsSort]!,
                              3: {
                                GenresSort.aToZ: Language.instance.A_TO_Z,
                                GenresSort.dateAdded:
                                    Language.instance.DATE_ADDED,
                              }[collection.genresSort]!,
                            }[tab]!,
                            style: Theme.of(context)
                                .textTheme
                                .headline4
                                ?.copyWith(
                                  color: Theme.of(context).primaryColor,
                                  decoration:
                                      _hover0 ? TextDecoration.underline : null,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4.0),
                    Icon(
                      Icons.expand_more,
                      size: 18.0,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 4.0),
          MouseRegion(
            onEnter: (e) => setState(() => _hover1 = true),
            onExit: (e) => setState(() => _hover1 = false),
            child: InkWell(
              key: _key1,
              borderRadius: BorderRadius.circular(4.0),
              onTap: () async {
                final value = await showMenu(
                  elevation: 4.0,
                  context: context,
                  position: RelativeRect.fromLTRB(
                    MediaQuery.of(context).size.width,
                    _key1.globalPaintBounds!.bottom +
                        tileMargin / (widget.fixed ? 2.0 : 1.0),
                    tileMargin + (widget.fixed ? 8.0 : 0.0),
                    0.0,
                  ),
                  items: <PopupMenuEntry>[
                    CheckedPopupMenuItem(
                      checked: {
                        0: Collection.instance.albumsOrderType ==
                            OrderType.ascending,
                        1: Collection.instance.tracksOrderType ==
                            OrderType.ascending,
                        2: Collection.instance.artistsOrderType ==
                            OrderType.ascending,
                        3: Collection.instance.genresOrderType ==
                            OrderType.ascending,
                      }[tab]!,
                      value: OrderType.ascending,
                      padding: EdgeInsets.zero,
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: Text(
                          Language.instance.ASCENDING,
                          style: Theme.of(context).textTheme.headline4,
                        ),
                      ),
                    ),
                    CheckedPopupMenuItem(
                      checked: {
                        0: Collection.instance.albumsOrderType ==
                            OrderType.descending,
                        1: Collection.instance.tracksOrderType ==
                            OrderType.descending,
                        2: Collection.instance.artistsOrderType ==
                            OrderType.descending,
                        3: Collection.instance.genresOrderType ==
                            OrderType.descending,
                      }[tab]!,
                      value: OrderType.descending,
                      padding: EdgeInsets.zero,
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: Text(
                          Language.instance.DESCENDING,
                          style: Theme.of(context).textTheme.headline4,
                        ),
                      ),
                    ),
                  ],
                );
                if (value is OrderType) {
                  switch (tab) {
                    case 0:
                      {
                        await Collection.instance.sort(albumsOrderType: value);
                        await Configuration.instance
                            .save(albumsOrderType: value);
                        break;
                      }
                    case 1:
                      {
                        await Collection.instance.sort(tracksOrderType: value);
                        await Configuration.instance
                            .save(tracksOrderType: value);
                        break;
                      }
                    case 2:
                      {
                        await Collection.instance.sort(artistsOrderType: value);
                        await Configuration.instance
                            .save(artistsOrderType: value);
                        break;
                      }
                    case 3:
                      {
                        await Collection.instance.sort(genresOrderType: value);
                        await Configuration.instance
                            .save(genresOrderType: value);
                        break;
                      }
                  }
                }
              },
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 2.0),
                height: 28.0,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(width: 4.0),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${Language.instance.ORDER}: ',
                            style: Theme.of(context).textTheme.headline4,
                          ),
                          TextSpan(
                            text: {
                              0: {
                                OrderType.ascending:
                                    Language.instance.ASCENDING,
                                OrderType.descending:
                                    Language.instance.DESCENDING,
                              }[collection.albumsOrderType]!,
                              1: {
                                OrderType.ascending:
                                    Language.instance.ASCENDING,
                                OrderType.descending:
                                    Language.instance.DESCENDING,
                              }[collection.tracksOrderType]!,
                              2: {
                                OrderType.ascending:
                                    Language.instance.ASCENDING,
                                OrderType.descending:
                                    Language.instance.DESCENDING,
                              }[collection.artistsOrderType]!,
                              3: {
                                OrderType.ascending:
                                    Language.instance.ASCENDING,
                                OrderType.descending:
                                    Language.instance.DESCENDING,
                              }[collection.genresOrderType]!,
                            }[tab]!,
                            style: Theme.of(context)
                                .textTheme
                                .headline4
                                ?.copyWith(
                                  color: Theme.of(context).primaryColor,
                                  decoration:
                                      _hover1 ? TextDecoration.underline : null,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4.0),
                    Icon(
                      Icons.expand_more,
                      size: 18.0,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8.0),
        ],
      ),
    );
    return widget.fixed
        ? ValueListenableBuilder<bool>(
            valueListenable: widget.hover,
            child: child,
            builder: (context, hover, child) => Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(right: tileMargin),
              child: child,
            ),
          )
        : ValueListenableBuilder<bool>(
            valueListenable: widget.hover,
            child: child,
            builder: (context, hover, child) => AnimatedPositioned(
              curve: Curves.easeInOut,
              duration: const Duration(milliseconds: 200),
              top: hover
                  ? widget.tab == 1
                      ? 28.0
                      : 0
                  : -64.0,
              right: tileMargin,
              child: Card(
                color: Theme.of(context).appBarTheme.backgroundColor,
                margin: EdgeInsets.only(top: tileMargin),
                elevation: 4.0,
                child: Container(
                  padding: EdgeInsets.only(
                    top: 8.0,
                    bottom: 8.0,
                  ),
                  child: child,
                ),
              ),
            ),
          );
  }
}

class ScaleOnHover extends StatefulWidget {
  final Widget child;
  ScaleOnHover({required this.child});

  @override
  _ScaleOnHoverState createState() => _ScaleOnHoverState();
}

class _ScaleOnHoverState extends State<ScaleOnHover> {
  double scale = 1.0;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (e) => setState(() {
        scale = 1.05;
      }),
      onExit: (e) => setState(() {
        scale = 1.00;
      }),
      child: TweenAnimationBuilder(
        duration: const Duration(milliseconds: 100),
        tween: Tween<double>(begin: 1.0, end: scale),
        builder: (BuildContext context, double value, _) {
          return Transform.scale(scale: value, child: widget.child);
        },
      ),
    );
  }
}

class SubHeader extends StatelessWidget {
  final String? text;
  final TextStyle? style;

  const SubHeader(this.text, {this.style, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return text != null
        ? isDesktop
            ? Container(
                alignment: Alignment.centerLeft,
                height: 56.0,
                padding: EdgeInsets.fromLTRB(24.0, 0, 0, 0),
                child: Text(
                  text!,
                  style: style ?? Theme.of(context).textTheme.headline1,
                ),
              )
            : Container(
                alignment: Alignment.centerLeft,
                height: 56.0,
                padding: EdgeInsets.fromLTRB(16.0, 0, 0, 0),
                child: Text(
                  text!.toUpperCase(),
                  style: style ??
                      Theme.of(context).textTheme.overline?.copyWith(
                            color: Theme.of(context).textTheme.headline3?.color,
                            fontSize: 12.0,
                            fontWeight: FontWeight.w600,
                          ),
                ),
              )
        : Container();
  }
}

class NavigatorPopButton extends StatelessWidget {
  final Color? color;
  final void Function()? onTap;
  NavigatorPopButton({Key? key, this.onTap, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap != null ? onTap : Navigator.of(context).pop,
          borderRadius: BorderRadius.circular(20.0),
          child: Container(
            height: 40.0,
            width: 40.0,
            child: Icon(
              Icons.arrow_back,
              size: 20.0,
              color: color ?? Theme.of(context).appBarTheme.iconTheme?.color,
            ),
          ),
        ),
      ),
    );
  }
}

class DesktopAppBar extends StatelessWidget {
  final String? title;
  final Widget? child;
  final Color? color;
  final Widget? leading;
  final double? height;
  final double? elevation;

  const DesktopAppBar({
    Key? key,
    this.title,
    this.child,
    this.color,
    this.leading,
    this.height,
    this.elevation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DesktopTitleBar(
          color: color,
        ),
        ClipRect(
          child: ClipRect(
            clipBehavior: Clip.antiAlias,
            child: Container(
              height: (height ?? kDesktopAppBarHeight) + 8.0,
              alignment: Alignment.topLeft,
              padding: EdgeInsets.only(bottom: 8.0),
              child: Material(
                animationDuration: Duration.zero,
                elevation: elevation ?? 4.0,
                color: color ?? Theme.of(context).appBarTheme.backgroundColor,
                child: Container(
                  height: double.infinity,
                  alignment: Alignment.topLeft,
                  child: Container(
                    height: kDesktopAppBarHeight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        leading ??
                            NavigatorPopButton(
                              color: color != null
                                  ? isDark
                                      ? Theme.of(context)
                                          .extension<IconColors>()
                                          ?.appBarDarkIconColor
                                      : Theme.of(context)
                                          .extension<IconColors>()
                                          ?.appBarLightIconColor
                                  : null,
                            ),
                        SizedBox(
                          width: 16.0,
                        ),
                        if (title != null)
                          Text(
                            title!,
                            style:
                                Theme.of(context).textTheme.headline1?.copyWith(
                                    color: color != null
                                        ? isDark
                                            ? Colors.white
                                            : Colors.black
                                        : null),
                          ),
                        if (child != null)
                          Container(
                            width: MediaQuery.of(context).size.width - 72.0,
                            child: child!,
                          ),
                      ],
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

  bool get isDark =>
      (0.299 * (color?.red ?? 256.0)) +
          (0.587 * (color?.green ?? 256.0)) +
          (0.114 * (color?.blue ?? 256.0)) <
      128.0;
}

class RefreshCollectionButton extends StatefulWidget {
  final Color? color;
  RefreshCollectionButton({
    Key? key,
    this.color,
  }) : super(key: key);

  @override
  _RefreshCollectionButtonState createState() =>
      _RefreshCollectionButtonState();
}

class _RefreshCollectionButtonState extends State<RefreshCollectionButton> {
  bool lock = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<CollectionRefresh>(
      builder: (context, refresh, _) => refresh.progress == refresh.total
          ? FloatingActionButton(
              elevation: 8.0,
              heroTag: 'collection_refresh_button',
              backgroundColor:
                  widget.color ?? Theme.of(context).colorScheme.secondary,
              child: Icon(
                Icons.refresh,
                color: widget.color?.isDark ?? true
                    ? Colors.white
                    : Colors.black87,
              ),
              onPressed: () {
                if (lock) return;
                lock = true;
                Collection.instance.refresh(
                    onProgress: (progress, total, isCompleted) {
                  CollectionRefresh.instance.set(progress, total);
                  if (isCompleted) {
                    setState(() {
                      lock = false;
                    });
                  }
                });
              },
            )
          : Container(),
    );
  }
}

class HyperLink extends StatefulWidget {
  final TextSpan text;
  final TextStyle? style;
  HyperLink({
    Key? key,
    required this.text,
    required this.style,
  }) : super(key: key);

  @override
  State<HyperLink> createState() => _HyperLinkState();
}

class _HyperLinkState extends State<HyperLink> {
  String hover = '\0';
  @override
  Widget build(BuildContext context) {
    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: widget.style,
        children: widget.text.children!
            .map(
              (e) => TextSpan(
                text: (e as TextSpan).text?.overflow,
                style: e.recognizer != null
                    ? widget.style?.copyWith(
                        decoration:
                            hover == e.text! ? TextDecoration.underline : null,
                      )
                    : null,
                recognizer: e.recognizer,
                onEnter: (_) {
                  if (mounted) {
                    setState(() {
                      hover = e.text!;
                    });
                  }
                },
                onExit: (_) {
                  if (mounted) {
                    setState(() {
                      hover = '\0';
                    });
                  }
                },
              ),
            )
            .toList(),
      ),
    );
  }
}

/// This piece of code is pure garbage.
/// There aren't likely going to be any changes to this in future, so it's not worth it to make it better.
/// But, since it's not much ground-breakingly tough to understand, I'm not going to fix it.
class ExceptionWidget extends StatelessWidget {
  final String? title;
  final String? subtitle;

  const ExceptionWidget({
    Key? key,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final iconSize = isDesktop ? 196.0 : 244.0;
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 4.0,
      ),
      width: 480.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Transform.scale(
            scale: title == Language.instance.NO_COLLECTION_TITLE
                ? 1.4
                : title == Language.instance.COLLECTION_SEARCH_LABEL
                    ? 1.0
                    : 1.2,
            child: Image.memory(
              {
                Language.instance.NO_COLLECTION_TITLE: visualAssets.collection,
                Language.instance.NO_INTERNET_TITLE: visualAssets.collection,
                Language.instance.COLLECTION_SEARCH_NO_RESULTS_TITLE:
                    visualAssets.searchPage,
                Language.instance.WEB_WELCOME_TITLE: visualAssets.searchNotes,
                Language.instance.COLLECTION_SEARCH_LABEL:
                    visualAssets.searchPage,
              }[title]!,
              height: iconSize,
              width: iconSize,
              filterQuality: FilterQuality.high,
              fit: BoxFit.contain,
            ),
          ),
          Text(
            title!,
            style: Theme.of(context).textTheme.headline1?.copyWith(
                  fontSize: 20.0,
                  fontWeight: isDesktop ? null : FontWeight.normal,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 8.0,
          ),
          Text(
            subtitle!,
            style: Theme.of(context).textTheme.headline3,
            textAlign: TextAlign.center,
          ),
          if (title == Language.instance.NO_COLLECTION_TITLE) ...[
            const SizedBox(
              height: 4.0,
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        FadeThroughTransition(
                      fillColor: Colors.transparent,
                      animation: animation,
                      secondaryAnimation: secondaryAnimation,
                      child: Settings(),
                    ),
                  ),
                );
              },
              child: Text(
                Language.instance.GO_TO_SETTINGS,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }
}

class ClosedTile extends StatelessWidget {
  final String? title;
  final String? subtitle;
  const ClosedTile({
    Key? key,
    required this.open,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  final Function open;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: 8.0,
        right: 8.0,
        top: 12.0,
      ),
      child: ListTile(
        title: Text(
          title!,
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 24.0,
          ),
        ),
        subtitle: Text(
          subtitle!,
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withOpacity(0.8)
                : Colors.black.withOpacity(0.8),
            fontSize: 14.0,
          ),
        ),
        onTap: open as void Function()?,
      ),
    );
  }
}

class ContextMenuButton<T> extends StatefulWidget {
  const ContextMenuButton({
    Key? key,
    required this.itemBuilder,
    this.initialValue,
    this.onSelected,
    this.onCanceled,
    this.tooltip,
    this.elevation,
    this.padding = const EdgeInsets.all(8.0),
    this.child,
    this.icon,
    this.iconSize,
    this.offset = Offset.zero,
    this.enabled = true,
    this.shape,
    this.color,
    this.enableFeedback,
    this.highlightColor,
    this.splashColor,
    this.hoverColor,
  })  : assert(
          !(child != null && icon != null),
          'You can only pass [child] or [icon], not both.',
        ),
        super(key: key);

  final PopupMenuItemBuilder<T> itemBuilder;

  final T? initialValue;

  final PopupMenuItemSelected<T>? onSelected;

  final PopupMenuCanceled? onCanceled;

  final String? tooltip;

  final double? elevation;

  final EdgeInsetsGeometry padding;

  final Widget? child;

  final Widget? icon;

  final Offset offset;

  final bool enabled;

  final ShapeBorder? shape;

  final Color? color;

  final bool? enableFeedback;

  final double? iconSize;

  final Color? highlightColor;

  final Color? splashColor;

  final Color? hoverColor;

  @override
  ContextMenuButtonState<T> createState() => ContextMenuButtonState<T>();
}

class ContextMenuButtonState<T> extends State<ContextMenuButton<T>> {
  void showButtonMenu() {
    final RenderBox button = context.findRenderObject()! as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject()! as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(widget.offset, ancestor: overlay),
        button.localToGlobal(
            button.size.bottomRight(Offset.zero) + widget.offset,
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );
    final List<PopupMenuEntry<T>> items = widget.itemBuilder(context);

    if (items.isNotEmpty) {
      showMenu<T?>(
        context: context,
        elevation: 4.0,
        items: items,
        initialValue: widget.initialValue,
        position: position,
        shape: widget.shape ??
            RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(4.0),
              ),
            ),
        color: Theme.of(context).popupMenuTheme.color,
      ).then<void>((T? newValue) {
        if (!mounted) return null;
        if (newValue == null) {
          widget.onCanceled?.call();
          return null;
        }
        widget.onSelected?.call(newValue);
      });
    }
  }

  bool get _canRequestFocus {
    final NavigationMode mode = MediaQuery.maybeOf(context)?.navigationMode ??
        NavigationMode.traditional;
    switch (mode) {
      case NavigationMode.traditional:
        return widget.enabled;
      case NavigationMode.directional:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool enableFeedback = widget.enableFeedback ??
        PopupMenuTheme.of(context).enableFeedback ??
        true;

    assert(debugCheckHasMaterialLocalizations(context));

    if (widget.child != null)
      return Tooltip(
        message:
            widget.tooltip ?? MaterialLocalizations.of(context).showMenuTooltip,
        child: InkWell(
          highlightColor: widget.highlightColor,
          splashColor: widget.splashColor,
          hoverColor: widget.hoverColor,
          onTap: widget.enabled ? showButtonMenu : null,
          canRequestFocus: _canRequestFocus,
          child: widget.child,
          enableFeedback: enableFeedback,
        ),
      );

    return IconButton(
      onPressed: widget.enabled ? showButtonMenu : null,
      icon: widget.icon ??
          Icon(
            Icons.more_vert,
            size: 20.0,
            color: Theme.of(context).iconTheme.color,
          ),
      splashRadius: 20.0,
    );
  }
}

class DesktopTitleBar extends StatelessWidget {
  final hideMaximizeAndRestoreButton;
  final Color? color;
  const DesktopTitleBar({
    Key? key,
    this.color,
    this.hideMaximizeAndRestoreButton = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid || Platform.isIOS)
      return Container(
        height: MediaQuery.of(context).padding.top,
        color: color ?? Theme.of(context).appBarTheme.backgroundColor,
      );
    return WindowsInfo.instance.isWindows10OrGreater
        ? Container(
            width: MediaQuery.of(context).size.width,
            height: desktopTitleBarHeight,
            color: color ?? Theme.of(context).appBarTheme.backgroundColor,
            alignment: Alignment.topCenter,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: MoveWindow(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 14.0,
                        ),
                        Text(
                          'Harmonoid Music',
                          style: TextStyle(
                            color: (color == null
                                    ? Theme.of(context).brightness ==
                                        Brightness.dark
                                    : isDark)
                                ? Colors.white
                                : Colors.black,
                            fontSize: 12.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                MinimizeWindowButton(
                  colors: windowButtonColors(context),
                ),
                if (!hideMaximizeAndRestoreButton)
                  appWindow.isMaximized
                      ? RestoreWindowButton(
                          colors: windowButtonColors(context),
                        )
                      : MaximizeWindowButton(
                          colors: windowButtonColors(context),
                        ),
                CloseWindowButton(
                  colors: windowButtonColors(context)
                    ..mouseOver = Color(0xFFC42B1C)
                    ..mouseDown = Color(0xFFC83F31)
                    ..iconMouseOver = Colors.white
                    ..iconMouseDown = Colors.white,
                ),
              ],
            ),
          )
        : Container();
  }

  bool get isDark =>
      (0.299 * (color?.red ?? 256.0)) +
          (0.587 * (color?.green ?? 256.0)) +
          (0.114 * (color?.blue ?? 256.0)) <
      128.0;

  WindowButtonColors windowButtonColors(BuildContext context) =>
      WindowButtonColors(
        iconNormal: (color == null
                ? Theme.of(context).brightness == Brightness.dark
                : isDark)
            ? Colors.white
            : Colors.black,
        iconMouseDown: (color == null
                ? Theme.of(context).brightness == Brightness.dark
                : isDark)
            ? Colors.white
            : Colors.black,
        iconMouseOver: (color == null
                ? Theme.of(context).brightness == Brightness.dark
                : isDark)
            ? Colors.white
            : Colors.black,
        normal: Colors.transparent,
        mouseOver: (color == null
                ? Theme.of(context).brightness == Brightness.dark
                : isDark)
            ? Colors.white.withOpacity(0.04)
            : Colors.black.withOpacity(0.04),
        mouseDown: (color == null
                ? Theme.of(context).brightness == Brightness.dark
                : isDark)
            ? Colors.white.withOpacity(0.04)
            : Colors.black.withOpacity(0.04),
      );
}

class MobileBottomNavigationBar extends StatefulWidget {
  final ValueNotifier<TabRoute> tabControllerNotifier;
  MobileBottomNavigationBar({
    Key? key,
    required this.tabControllerNotifier,
  }) : super(key: key);

  @override
  State<MobileBottomNavigationBar> createState() =>
      _MobileBottomNavigationBarState();
}

class _MobileBottomNavigationBarState extends State<MobileBottomNavigationBar> {
  late int _index;

  @override
  void initState() {
    super.initState();
    widget.tabControllerNotifier.addListener(onChange);
    _index = widget.tabControllerNotifier.value.index;
  }

  void onChange() {
    if (_index != widget.tabControllerNotifier.value.index) {
      setState(() {
        _index = widget.tabControllerNotifier.value.index;
      });
    }
  }

  @override
  void dispose() {
    widget.tabControllerNotifier.removeListener(onChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Iterable<Color>?>(
      valueListenable: MobileNowPlayingController.instance.palette,
      builder: (context, value, _) => TweenAnimationBuilder<Color?>(
        duration: Duration(milliseconds: 400),
        tween: ColorTween(
          begin: Theme.of(context).primaryColor,
          end: value?.first ?? Theme.of(context).primaryColor,
        ),
        builder: (context, color, _) => Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(color: Colors.black45, blurRadius: 8.0),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _index,
            selectedItemColor: color?.isDark ?? true ? null : Colors.black87,
            unselectedItemColor: color?.isDark ?? true ? null : Colors.black45,
            type: BottomNavigationBarType.shifting,
            onTap: (index) {
              MobileNowPlayingController.instance.restore();
              if (index != _index) {
                widget.tabControllerNotifier.value =
                    TabRoute(index, TabRouteSender.bottomNavigationBar);
              }
              setState(() {
                _index = index;
              });
            },
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.playlist_play),
                label: Language.instance.PLAYLIST,
                backgroundColor: color ?? Theme.of(context).primaryColor,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.music_note),
                label: Language.instance.TRACK,
                backgroundColor: color ?? Theme.of(context).primaryColor,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.album),
                label: Language.instance.ALBUM,
                backgroundColor: color ?? Theme.of(context).primaryColor,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: Language.instance.ARTIST,
                backgroundColor: color ?? Theme.of(context).primaryColor,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.wifi_tethering_rounded),
                label: Language.instance.STREAM,
                backgroundColor: color ?? Theme.of(context).primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DoNotGCCleanThisWidgetFromMemory extends StatefulWidget {
  final Widget child;
  DoNotGCCleanThisWidgetFromMemory(this.child, {Key? key}) : super(key: key);

  @override
  State<DoNotGCCleanThisWidgetFromMemory> createState() =>
      _DoNotGCCleanThisWidgetFromMemoryState();
}

class _DoNotGCCleanThisWidgetFromMemoryState
    extends State<DoNotGCCleanThisWidgetFromMemory>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  bool wantKeepAlive = true;
}

class ShowAllButton extends StatelessWidget {
  final void Function()? onPressed;
  const ShowAllButton({Key? key, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(4.0),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4.0),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 6.0,
            vertical: 2.0,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.view_list,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(
                width: 4.0,
              ),
              Text(
                Language.instance.SEE_ALL,
                style: Theme.of(context).textTheme.headline3?.copyWith(
                      color: Theme.of(context).primaryColor,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension GlobalKeyExtension on GlobalKey {
  Rect? get globalPaintBounds {
    final renderObject = currentContext?.findRenderObject();
    final translation = renderObject?.getTransformTo(null).getTranslation();
    if (translation != null && renderObject?.paintBounds != null) {
      final offset = Offset(translation.x, translation.y);
      return renderObject!.paintBounds.shift(offset);
    } else {
      return null;
    }
  }
}

class ScrollableSlider extends StatelessWidget {
  final double min;
  final double max;
  final double value;
  final Color? color;
  final Color? secondaryColor;
  final VoidCallback onScrolledUp;
  final VoidCallback onScrolledDown;
  final void Function(double) onChanged;
  final bool inferSliderInactiveTrackColor;
  final bool mobile;

  const ScrollableSlider({
    Key? key,
    required this.min,
    required this.max,
    required this.value,
    this.color,
    this.secondaryColor,
    required this.onScrolledUp,
    required this.onScrolledDown,
    required this.onChanged,
    this.inferSliderInactiveTrackColor: true,
    this.mobile: false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: (event) {
        if (event is PointerScrollEvent) {
          if (event.scrollDelta.dy < 0) {
            onScrolledUp();
          }
          if (event.scrollDelta.dy > 0) {
            onScrolledDown();
          }
        }
      },
      child: SliderTheme(
        data: SliderThemeData(
          trackHeight: (mobile && isMobile) ? null : 2.0,
          trackShape: CustomTrackShape(),
          thumbShape: (mobile && isMobile)
              ? null
              : RoundSliderThumbShape(
                  enabledThumbRadius: 6.0,
                  pressedElevation: 4.0,
                  elevation: 2.0,
                ),
          overlayShape: (mobile && isMobile)
              ? null
              : RoundSliderOverlayShape(overlayRadius: 12.0),
          overlayColor:
              (color ?? Theme.of(context).primaryColor).withOpacity(0.4),
          thumbColor: (color ?? Theme.of(context).primaryColor),
          activeTrackColor: (color ?? Theme.of(context).primaryColor),
          inactiveTrackColor: (mobile && isMobile)
              ? Theme.of(context).primaryColor.withOpacity(0.2)
              : inferSliderInactiveTrackColor
                  ? ((secondaryColor != null
                          ? secondaryColor?.isDark
                          : Theme.of(context).brightness == Brightness.dark)!
                      ? Colors.white.withOpacity(0.4)
                      : Colors.black.withOpacity(0.2))
                  : Colors.white.withOpacity(0.4),
        ),
        child: Slider(
          value: value,
          onChanged: onChanged,
          min: min,
          max: max,
        ),
      ),
    );
  }
}

class CustomTrackShape extends RoundedRectSliderTrackShape {
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight!;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}

class HorizontalList extends StatefulWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  HorizontalList({
    Key? key,
    required this.children,
    this.padding,
  }) : super(key: key);

  @override
  State<HorizontalList> createState() => _HorizontalListState();
}

class _HorizontalListState extends State<HorizontalList> {
  final ScrollController controller = ScrollController();

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  double get extentBefore {
    return controller.hasClients ? controller.position.extentBefore : 0.0;
  }

  double get extentAfter {
    return controller.hasClients ? controller.position.extentAfter : 1.0;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) => Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            child: ListView(
              controller: controller,
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              padding: widget.padding,
              children: widget.children,
            ),
          ),
          if (extentAfter != 0)
            Positioned(
              child: Container(
                height: c.maxHeight,
                child: Center(
                  child: FloatingActionButton(
                    mini: true,
                    heroTag: ValueKey(math.Random().nextInt(1 << 32)),
                    onPressed: () {
                      controller.animateTo(
                        controller.offset +
                            MediaQuery.of(context).size.width / 2,
                        duration: Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Icon(Icons.arrow_forward),
                  ),
                ),
              ),
              right: isDesktop ? 32.0 : tileMargin,
            ),
          if (extentBefore != 0)
            Positioned(
              child: Container(
                height: c.maxHeight,
                child: Center(
                  child: FloatingActionButton(
                    mini: true,
                    heroTag: ValueKey(math.Random().nextInt(1 << 32)),
                    onPressed: () {
                      controller.animateTo(
                        controller.offset -
                            MediaQuery.of(context).size.width / 2,
                        duration: Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Icon(Icons.arrow_back),
                  ),
                ),
              ),
              left: isDesktop ? 32.0 : tileMargin,
            ),
        ],
      ),
    );
  }
}

class CollectionSortButton extends StatelessWidget {
  final int tab;
  const CollectionSortButton({
    Key? key,
    required this.tab,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: Language.instance.SORT,
      child: ContextMenuButton<dynamic>(
        offset: Offset.fromDirection(pi / 2, 64.0),
        icon: Icon(
          Icons.sort_by_alpha,
          size: 20.0,
        ),
        elevation: 8.0,
        onSelected: (value) async {
          if (value is AlbumsSort) {
            await Collection.instance.sort(albumsSort: value);
            await Configuration.instance.save(albumsSort: value);
          }
          if (value is TracksSort) {
            await Collection.instance.sort(tracksSort: value);
            await Configuration.instance.save(tracksSort: value);
          }
          if (value is ArtistsSort) {
            await Collection.instance.sort(artistsSort: value);
            await Configuration.instance.save(artistsSort: value);
          }
          if (value is GenresSort) {
            await Collection.instance.sort(genresSort: value);
            await Configuration.instance.save(genresSort: value);
          }
          if (value is OrderType) {
            switch (tab) {
              case 0:
                {
                  await Collection.instance.sort(albumsOrderType: value);
                  await Configuration.instance.save(albumsOrderType: value);
                  break;
                }
              case 1:
                {
                  await Collection.instance.sort(tracksOrderType: value);
                  await Configuration.instance.save(tracksOrderType: value);
                  break;
                }
              case 2:
                {
                  await Collection.instance.sort(artistsOrderType: value);
                  await Configuration.instance.save(artistsOrderType: value);
                  break;
                }
              case 3:
                {
                  await Collection.instance.sort(genresOrderType: value);
                  await Configuration.instance.save(genresOrderType: value);
                  break;
                }
            }
          }
        },
        itemBuilder: (context) => [
          ...{
            0: <PopupMenuItem>[
              CheckedPopupMenuItem(
                checked: Collection.instance.albumsSort == AlbumsSort.aToZ,
                value: AlbumsSort.aToZ,
                padding: EdgeInsets.zero,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(
                    Language.instance.A_TO_Z,
                    style: Theme.of(context).textTheme.headline4,
                  ),
                ),
              ),
              CheckedPopupMenuItem(
                checked: Collection.instance.albumsSort == AlbumsSort.dateAdded,
                value: AlbumsSort.dateAdded,
                padding: EdgeInsets.zero,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(
                    Language.instance.DATE_ADDED,
                    style: Theme.of(context).textTheme.headline4,
                  ),
                ),
              ),
              CheckedPopupMenuItem(
                checked: Collection.instance.albumsSort == AlbumsSort.year,
                value: AlbumsSort.year,
                padding: EdgeInsets.zero,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(
                    Language.instance.YEAR,
                    style: Theme.of(context).textTheme.headline4,
                  ),
                ),
              ),
              CheckedPopupMenuItem(
                checked: Collection.instance.albumsSort == AlbumsSort.artist,
                value: AlbumsSort.artist,
                padding: EdgeInsets.zero,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(
                    Language.instance.ARTIST,
                    style: Theme.of(context).textTheme.headline4,
                  ),
                ),
              ),
            ],
            1: <PopupMenuItem>[
              CheckedPopupMenuItem(
                checked: Collection.instance.tracksSort == TracksSort.aToZ,
                value: TracksSort.aToZ,
                padding: EdgeInsets.zero,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(
                    Language.instance.A_TO_Z,
                    style: Theme.of(context).textTheme.headline4,
                  ),
                ),
              ),
              CheckedPopupMenuItem(
                checked: Collection.instance.tracksSort == TracksSort.dateAdded,
                value: TracksSort.dateAdded,
                padding: EdgeInsets.zero,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(
                    Language.instance.DATE_ADDED,
                    style: Theme.of(context).textTheme.headline4,
                  ),
                ),
              ),
              CheckedPopupMenuItem(
                checked: Collection.instance.tracksSort == TracksSort.year,
                value: TracksSort.year,
                padding: EdgeInsets.zero,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(
                    Language.instance.YEAR,
                    style: Theme.of(context).textTheme.headline4,
                  ),
                ),
              ),
            ],
            2: <PopupMenuItem>[
              CheckedPopupMenuItem(
                checked: Collection.instance.artistsSort == ArtistsSort.aToZ,
                value: ArtistsSort.aToZ,
                padding: EdgeInsets.zero,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(
                    Language.instance.A_TO_Z,
                    style: Theme.of(context).textTheme.headline4,
                  ),
                ),
              ),
              CheckedPopupMenuItem(
                checked:
                    Collection.instance.artistsSort == ArtistsSort.dateAdded,
                value: ArtistsSort.dateAdded,
                padding: EdgeInsets.zero,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(
                    Language.instance.DATE_ADDED,
                    style: Theme.of(context).textTheme.headline4,
                  ),
                ),
              ),
            ],
            3: <PopupMenuItem>[
              CheckedPopupMenuItem(
                checked: Collection.instance.genresSort == GenresSort.aToZ,
                value: GenresSort.aToZ,
                padding: EdgeInsets.zero,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(
                    Language.instance.A_TO_Z,
                    style: Theme.of(context).textTheme.headline4,
                  ),
                ),
              ),
              CheckedPopupMenuItem(
                checked: Collection.instance.genresSort == GenresSort.dateAdded,
                value: GenresSort.dateAdded,
                padding: EdgeInsets.zero,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(
                    Language.instance.DATE_ADDED,
                    style: Theme.of(context).textTheme.headline4,
                  ),
                ),
              ),
            ],
          }[tab]!,
          PopupMenuDivider(),
          ...[
            CheckedPopupMenuItem(
              checked: {
                0: Collection.instance.albumsOrderType == OrderType.ascending,
                1: Collection.instance.tracksOrderType == OrderType.ascending,
                2: Collection.instance.artistsOrderType == OrderType.ascending,
                3: Collection.instance.genresOrderType == OrderType.ascending,
              }[tab]!,
              value: OrderType.ascending,
              padding: EdgeInsets.zero,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: Text(
                  Language.instance.ASCENDING,
                  style: Theme.of(context).textTheme.headline4,
                ),
              ),
            ),
            CheckedPopupMenuItem(
              checked: {
                0: Collection.instance.albumsOrderType == OrderType.descending,
                1: Collection.instance.tracksOrderType == OrderType.descending,
                2: Collection.instance.artistsOrderType == OrderType.descending,
                3: Collection.instance.genresOrderType == OrderType.descending,
              }[tab]!,
              value: OrderType.descending,
              padding: EdgeInsets.zero,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: Text(
                  Language.instance.DESCENDING,
                  style: Theme.of(context).textTheme.headline4,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class CorrectedSwitchListTile extends StatelessWidget {
  final bool value;
  final void Function(bool) onChanged;
  final String title;
  final String subtitle;
  CorrectedSwitchListTile({
    Key? key,
    required this.value,
    required this.onChanged,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      title: Text(
        isDesktop ? subtitle : title,
        style: isDesktop ? Theme.of(context).textTheme.headline4 : null,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onChanged: (value) {
        onChanged.call(value);
      },
    );
  }
}

class CorrectedListTile extends StatelessWidget {
  final void Function()? onTap;
  final IconData? iconData;
  final String title;
  final String? subtitle;
  final double? height;
  CorrectedListTile({
    Key? key,
    this.iconData,
    required this.title,
    this.subtitle,
    this.onTap,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: height ?? 88.0,
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.only(left: 16.0),
        child: Row(
          crossAxisAlignment: subtitle == null
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          children: [
            if (iconData != null)
              Container(
                margin: EdgeInsets.only(
                    top: subtitle == null ? 0.0 : 16.0, right: 16.0),
                width: 40.0,
                height: 40.0,
                child: Icon(iconData),
              ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.subtitle1,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null) const SizedBox(height: 4.0),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodyText2?.copyWith(
                            color: Theme.of(context).textTheme.headline3?.color,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            const SizedBox(width: 16.0),
          ],
        ),
      ),
    );
  }
}

class MobileSortByButton extends StatefulWidget {
  final ValueNotifier<int> value;
  MobileSortByButton({
    Key? key,
    required this.value,
  }) : super(key: key);

  @override
  State<MobileSortByButton> createState() => _MobileSortByButtonState();
}

class _MobileSortByButtonState extends State<MobileSortByButton> {
  late int index;
  late final VoidCallback listener;

  @override
  void initState() {
    super.initState();
    index = widget.value.value;
    listener = () => setState(() {
          index = widget.value.value;
        });
    widget.value.addListener(listener);
  }

  @override
  void dispose() {
    widget.value.removeListener(listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Indices are different on mobile.
    final tab = {
      // [PlaylistTab]
      0: -1,
      1: 1,
      2: 0,
      3: 2,
      4: 4,
    }[index]!;
    return AnimatedOpacity(
      opacity: [1, 2, 3].contains(index) ? 1.0 : 0.0,
      duration: Duration(milliseconds: 50),
      child: CircularButton(
        icon: Icon(
          Icons.sort_by_alpha,
          color: Theme.of(context).appBarTheme.actionsIconTheme?.color,
        ),
        onPressed: () async {
          if (index == 4) return;
          final position = RelativeRect.fromRect(
            Offset(
                  MediaQuery.of(context).size.width - tileMargin - 48.0,
                  MediaQuery.of(context).padding.top +
                      kMobileSearchBarHeight +
                      2 * tileMargin,
                ) &
                Size(240.0, 240.0),
            Rect.fromLTWH(
              0,
              0,
              MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height,
            ),
          );
          final value = await showMenu<dynamic>(
            context: context,
            position: position,
            elevation: 4.0,
            items: [
              ...{
                0: <PopupMenuItem>[
                  CheckedPopupMenuItem(
                    checked: Collection.instance.albumsSort == AlbumsSort.aToZ,
                    value: AlbumsSort.aToZ,
                    padding: EdgeInsets.zero,
                    child: Text(
                      Language.instance.A_TO_Z,
                    ),
                  ),
                  CheckedPopupMenuItem(
                    checked:
                        Collection.instance.albumsSort == AlbumsSort.dateAdded,
                    value: AlbumsSort.dateAdded,
                    padding: EdgeInsets.zero,
                    child: Text(
                      Language.instance.DATE_ADDED,
                    ),
                  ),
                  CheckedPopupMenuItem(
                    checked: Collection.instance.albumsSort == AlbumsSort.year,
                    value: AlbumsSort.year,
                    padding: EdgeInsets.zero,
                    child: Text(
                      Language.instance.YEAR,
                    ),
                  ),
                  // Not implemented for mobile.
                  // CheckedPopupMenuItem(
                  //   checked:
                  //       Collection.instance.albumsSort == AlbumsSort.artist,
                  //   value: AlbumsSort.artist,
                  //   padding: EdgeInsets.zero,
                  //   child: ListTile(
                  //     title: Text(
                  //       Language.instance.ARTIST,
                  //     ),
                  //   ),
                  // ),
                ],
                1: <PopupMenuItem>[
                  CheckedPopupMenuItem(
                    checked: Collection.instance.tracksSort == TracksSort.aToZ,
                    value: TracksSort.aToZ,
                    padding: EdgeInsets.zero,
                    child: Text(
                      Language.instance.A_TO_Z,
                    ),
                  ),
                  CheckedPopupMenuItem(
                    checked:
                        Collection.instance.tracksSort == TracksSort.dateAdded,
                    value: TracksSort.dateAdded,
                    padding: EdgeInsets.zero,
                    child: Text(
                      Language.instance.DATE_ADDED,
                    ),
                  ),
                  CheckedPopupMenuItem(
                    checked: Collection.instance.tracksSort == TracksSort.year,
                    value: TracksSort.year,
                    padding: EdgeInsets.zero,
                    child: Text(
                      Language.instance.YEAR,
                    ),
                  ),
                ],
                2: <PopupMenuItem>[
                  CheckedPopupMenuItem(
                    checked:
                        Collection.instance.artistsSort == ArtistsSort.aToZ,
                    value: ArtistsSort.aToZ,
                    padding: EdgeInsets.zero,
                    child: Text(
                      Language.instance.A_TO_Z,
                    ),
                  ),
                  CheckedPopupMenuItem(
                    checked: Collection.instance.artistsSort ==
                        ArtistsSort.dateAdded,
                    value: ArtistsSort.dateAdded,
                    padding: EdgeInsets.zero,
                    child: Text(
                      Language.instance.DATE_ADDED,
                    ),
                  ),
                ],
                3: <PopupMenuItem>[
                  CheckedPopupMenuItem(
                    checked: Collection.instance.genresSort == GenresSort.aToZ,
                    value: GenresSort.aToZ,
                    padding: EdgeInsets.zero,
                    child: Text(
                      Language.instance.A_TO_Z,
                    ),
                  ),
                  CheckedPopupMenuItem(
                    checked:
                        Collection.instance.genresSort == GenresSort.dateAdded,
                    value: GenresSort.dateAdded,
                    padding: EdgeInsets.zero,
                    child: Text(
                      Language.instance.DATE_ADDED,
                    ),
                  ),
                ],
              }[tab]!,
              PopupMenuDivider(),
              ...[
                CheckedPopupMenuItem(
                  checked: {
                    0: Collection.instance.albumsOrderType ==
                        OrderType.ascending,
                    1: Collection.instance.tracksOrderType ==
                        OrderType.ascending,
                    2: Collection.instance.artistsOrderType ==
                        OrderType.ascending,
                    3: Collection.instance.genresOrderType ==
                        OrderType.ascending,
                  }[tab]!,
                  value: OrderType.ascending,
                  padding: EdgeInsets.zero,
                  child: Text(
                    Language.instance.ASCENDING,
                  ),
                ),
                CheckedPopupMenuItem(
                  checked: {
                    0: Collection.instance.albumsOrderType ==
                        OrderType.descending,
                    1: Collection.instance.tracksOrderType ==
                        OrderType.descending,
                    2: Collection.instance.artistsOrderType ==
                        OrderType.descending,
                    3: Collection.instance.genresOrderType ==
                        OrderType.descending,
                  }[tab]!,
                  value: OrderType.descending,
                  padding: EdgeInsets.zero,
                  child: Text(
                    Language.instance.DESCENDING,
                  ),
                ),
              ],
            ],
          );
          if (value is AlbumsSort) {
            await Collection.instance.sort(albumsSort: value);
            await Configuration.instance.save(albumsSort: value);
          }
          if (value is TracksSort) {
            await Collection.instance.sort(tracksSort: value);
            await Configuration.instance.save(tracksSort: value);
          }
          if (value is ArtistsSort) {
            await Collection.instance.sort(artistsSort: value);
            await Configuration.instance.save(artistsSort: value);
          }
          if (value is GenresSort) {
            await Collection.instance.sort(genresSort: value);
            await Configuration.instance.save(genresSort: value);
          }
          if (value is OrderType) {
            switch (tab) {
              case 0:
                {
                  await Collection.instance.sort(albumsOrderType: value);
                  await Configuration.instance.save(albumsOrderType: value);
                  break;
                }
              case 1:
                {
                  await Collection.instance.sort(tracksOrderType: value);
                  await Configuration.instance.save(tracksOrderType: value);
                  break;
                }
              case 2:
                {
                  await Collection.instance.sort(artistsOrderType: value);
                  await Configuration.instance.save(artistsOrderType: value);
                  break;
                }
              case 3:
                {
                  await Collection.instance.sort(genresOrderType: value);
                  await Configuration.instance.save(genresOrderType: value);
                  break;
                }
            }
          }
        },
      ),
    );
  }
}

class NowPlayingBarScrollHideNotifier extends StatelessWidget {
  final Widget child;
  const NowPlayingBarScrollHideNotifier({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isDesktop) {
      return child;
    } else {
      return NotificationListener<UserScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.axis == Axis.vertical &&
              [
                AxisDirection.up,
                AxisDirection.down,
              ].contains(notification.metrics.axisDirection)) {
            // Do not handle [ScrollDirection.idle].
            if (notification.direction == ScrollDirection.forward) {
              MobileNowPlayingController.instance.show();
            } else if (notification.direction == ScrollDirection.reverse) {
              MobileNowPlayingController.instance.hide();
            }
          }
          return false;
        },
        child: child,
      );
    }
  }
}

class CollectionMoreButton extends StatelessWidget {
  const CollectionMoreButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ContextMenuButton<int>(
      padding: EdgeInsets.zero,
      offset: Offset.fromDirection(pi / 2, 64.0),
      icon: Icon(
        Icons.more_vert,
        size: 20.0,
        color: Theme.of(context).appBarTheme.actionsIconTheme?.color,
      ),
      elevation: 4.0,
      onSelected: (value) async {
        switch (value) {
          case 0:
            {
              FileInfoScreen.show(context);
              break;
            }
          case 1:
            {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      FadeThroughTransition(
                    fillColor: Colors.transparent,
                    animation: animation,
                    secondaryAnimation: secondaryAnimation,
                    child: WebTab(),
                  ),
                ),
              );
              break;
            }
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 0,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            leading: Icon(Icons.code),
            title: Text(
              Language.instance.READ_METADATA,
              style: Theme.of(context).textTheme.headline4,
            ),
          ),
        ),
        PopupMenuItem(
          value: 1,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            leading: Icon(Icons.wifi_tethering),
            title: Text(
              Language.instance.STREAM,
              style: Theme.of(context).textTheme.headline4,
            ),
          ),
        ),
      ],
    );
  }
}

class PlayFileOrURLButton extends StatefulWidget {
  PlayFileOrURLButton({Key? key}) : super(key: key);

  @override
  State<PlayFileOrURLButton> createState() => _PlayFileOrURLButtonState();
}

class _PlayFileOrURLButtonState extends State<PlayFileOrURLButton> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: Language.instance.OPEN_FILE_OR_URL,
      icon: Icon(
        Icons.file_open,
        color: Theme.of(context).appBarTheme.actionsIconTheme?.color,
      ),
      splashRadius: 20.0,
      iconSize: 20.0,
      onPressed: () async {
        await showDialog(
          context: context,
          builder: (ctx) => SimpleDialog(
            title: Text(
              Language.instance.OPEN_FILE_OR_URL,
            ),
            children: [
              ListTile(
                onTap: () async {
                  final file = await pickFile(
                    label: Language.instance.MEDIA_FILES,
                    extensions: kSupportedFileTypes,
                  );
                  if (file != null) {
                    await Navigator.of(ctx).maybePop();
                    await Intent.instance.playUri(file.uri);
                  }
                },
                leading: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Theme.of(ctx).iconTheme.color,
                  child: Icon(
                    Icons.folder,
                  ),
                ),
                title: Text(
                  Language.instance.FILE,
                  style: isDesktop
                      ? Theme.of(ctx).textTheme.headline4
                      : Theme.of(ctx).textTheme.headline3?.copyWith(
                            fontSize: 16.0,
                          ),
                ),
              ),
              ListTile(
                onTap: () async {
                  await Navigator.of(ctx).maybePop();
                  String input = '';
                  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
                  await showDialog(
                    context: ctx,
                    builder: (ctx) => AlertDialog(
                      title: Text(
                        Language.instance.OPEN_FILE_OR_URL,
                      ),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 40.0,
                            width: 420.0,
                            alignment: Alignment.center,
                            margin: EdgeInsets.only(top: 0.0, bottom: 0.0),
                            padding: EdgeInsets.only(top: 2.0),
                            child: Focus(
                              onFocusChange: (hasFocus) {
                                if (hasFocus) {
                                  HotKeys.instance.disableSpaceHotKey();
                                } else {
                                  HotKeys.instance.enableSpaceHotKey();
                                }
                              },
                              child: Form(
                                key: formKey,
                                child: TextFormField(
                                  autofocus: true,
                                  cursorWidth: 1.0,
                                  onChanged: (value) => input = value,
                                  validator: (value) =>
                                      validate(value ?? '') == null ? '' : null,
                                  onFieldSubmitted: (value) async {
                                    if (value.isNotEmpty &&
                                        (formKey.currentState?.validate() ??
                                            false)) {
                                      Navigator.of(ctx).maybePop();
                                      await Intent.instance.playUri(
                                        validate(value)!,
                                      );
                                    }
                                  },
                                  cursorColor: Theme.of(ctx).brightness ==
                                          Brightness.light
                                      ? Colors.black
                                      : Colors.white,
                                  textAlignVertical: TextAlignVertical.bottom,
                                  style: Theme.of(ctx).textTheme.headline4,
                                  decoration: inputDecoration(
                                    ctx,
                                    Language.instance.PLAY_URL_SUBTITLE,
                                  ).copyWith(
                                    errorMaxLines: 1,
                                    errorStyle: TextStyle(height: 0),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          child: Text(
                            Language.instance.PLAY.toUpperCase(),
                            style: TextStyle(
                              color: Theme.of(ctx).primaryColor,
                            ),
                          ),
                          onPressed: () async {
                            if (input.isNotEmpty &&
                                (formKey.currentState?.validate() ?? false)) {
                              Navigator.of(ctx).maybePop();
                              await Intent.instance.playUri(validate(input)!);
                            }
                          },
                        ),
                        TextButton(
                          child: Text(
                            Language.instance.CANCEL.toUpperCase(),
                            style: TextStyle(
                              color: Theme.of(ctx).primaryColor,
                            ),
                          ),
                          onPressed: Navigator.of(ctx).maybePop,
                        ),
                      ],
                    ),
                  );
                },
                leading: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Theme.of(ctx).iconTheme.color,
                  child: Icon(
                    Icons.link,
                  ),
                ),
                title: Text(
                  Language.instance.URL,
                  style: isDesktop
                      ? Theme.of(ctx).textTheme.headline4
                      : Theme.of(ctx).textTheme.headline3?.copyWith(
                            fontSize: 16.0,
                          ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ContextMenuArea extends StatefulWidget {
  final Widget child;
  final void Function(PointerUpEvent) onPressed;
  ContextMenuArea({
    Key? key,
    required this.onPressed,
    required this.child,
  }) : super(key: key);

  @override
  State<ContextMenuArea> createState() => _ContextMenuAreaState();
}

class _ContextMenuAreaState extends State<ContextMenuArea> {
  bool reactToSecondaryPress = false;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (e) async {
        reactToSecondaryPress = e.kind == PointerDeviceKind.mouse &&
            e.buttons == kSecondaryMouseButton;
      },
      onPointerUp: (e) {
        if (!reactToSecondaryPress) return;
        widget.onPressed.call(e);
      },
      child: widget.child,
    );
  }
}

extension on Color {
  bool get isDark => (0.299 * red) + (0.587 * green) + (0.114 * blue) < 128.0;
}

class StillGIF extends StatefulWidget {
  final ImageProvider image;
  final double width;
  final double height;

  StillGIF({
    Key? key,
    required this.image,
    required this.width,
    required this.height,
  }) : super(key: key);

  factory StillGIF.asset(
    String image, {
    Key? key,
    required double width,
    required double height,
  }) =>
      StillGIF(
        key: key,
        image: AssetImage(image),
        width: width,
        height: height,
      );

  factory StillGIF.file(
    String image, {
    Key? key,
    required double width,
    required double height,
  }) =>
      StillGIF(
        key: key,
        image: FileImage(File(image)),
        width: width,
        height: height,
      );

  factory StillGIF.network(
    String image, {
    Key? key,
    required double width,
    required double height,
  }) =>
      StillGIF(
        key: key,
        image: NetworkImage(image),
        width: width,
        height: height,
      );

  @override
  State<StillGIF> createState() => _StillGIFState();
}

class _StillGIFState extends State<StillGIF> {
  RawImage? image;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Uint8List? data;
      if (widget.image is NetworkImage) {
        final resolved = Uri.base.resolve((widget.image as NetworkImage).url);
        final request = await HttpClient().getUrl(resolved);
        final HttpClientResponse response = await request.close();
        data = await consolidateHttpClientResponseBytes(response);
      } else if (widget.image is AssetImage) {
        final key =
            await (widget.image as AssetImage).obtainKey(ImageConfiguration());
        data = (await key.bundle.load(key.name)).buffer.asUint8List();
      } else if (widget.image is FileImage) {
        data = await (widget.image as FileImage).file.readAsBytes();
      }
      final codec = await PaintingBinding.instance
          // ignore: deprecated_member_use
          .instantiateImageCodec(data!.buffer.asUint8List());
      FrameInfo frame = await codec.getNextFrame();
      setState(() {
        image = RawImage(
          image: frame.image,
          height: widget.height,
          width: widget.width,
          fit: BoxFit.cover,
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return image ??
        SizedBox(
          width: widget.width,
          height: widget.height,
        );
  }
}

class FoldersNotFoundDialog extends StatefulWidget {
  FoldersNotFoundDialog({Key? key}) : super(key: key);

  @override
  State<FoldersNotFoundDialog> createState() => _FoldersNotFoundDialogState();
}

class _FoldersNotFoundDialogState extends State<FoldersNotFoundDialog> {
  List<String>? storages;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) async {
          final storages = await ExternalPath.getExternalStorageDirectories();
          setState(
            () => this.storages = storages,
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Collection>(
      builder: (context, collection, _) {
        Iterable<Directory> missingDirectories = collection
            .collectionDirectories
            .where((element) => !element.existsSync_());
        if (storages != null) {
          missingDirectories = missingDirectories.map(
            (e) => Directory(
              e.path
                  .replaceAll(
                    storages!.first,
                    Language.instance.PHONE,
                  )
                  .replaceAll(
                    storages!.last,
                    Language.instance.SD_CARD,
                  ),
            ),
          );
        }
        return AlertDialog(
          title: Text(
            missingDirectories.isEmpty
                ? Language.instance.AWESOME
                : Language.instance.ERROR,
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                child: Text(
                  missingDirectories.isEmpty
                      ? Language.instance.NOW_YOU_ARE_GOOD_TO_GO_BACK
                      : Language.instance.FOLDERS_NOT_FOUND,
                  style: Theme.of(context).textTheme.headline3,
                  textAlign: TextAlign.start,
                ),
                padding: EdgeInsets.only(
                  bottom: 16.0,
                ),
              ),
              ...missingDirectories
                  .map(
                    (directory) => Container(
                      height: isMobile ? 56.0 : 40.0,
                      margin: EdgeInsets.symmetric(vertical: 2.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          directory.existsSync_()
                              ? Container(
                                  width: 40.0,
                                  child: Icon(
                                    FluentIcons.folder_32_regular,
                                    size: 32.0,
                                  ),
                                )
                              : Tooltip(
                                  message: Language.instance.FOLDER_NOT_FOUND,
                                  verticalOffset: 24.0,
                                  waitDuration: Duration.zero,
                                  child: Container(
                                    width: 40.0,
                                    child: Icon(
                                      Icons.warning,
                                      size: 24.0,
                                    ),
                                  ),
                                ),
                          Expanded(
                            child: Text(
                              directory.path.overflow,
                              style: isMobile
                                  ? Theme.of(context).textTheme.subtitle1
                                  : Theme.of(context).textTheme.headline3,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              if (!CollectionRefresh.instance.isCompleted) {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor:
                                        Theme.of(context).cardColor,
                                    title: Text(
                                      Language.instance
                                          .INDEXING_ALREADY_GOING_ON_TITLE,
                                    ),
                                    content: Text(
                                      Language.instance
                                          .INDEXING_ALREADY_GOING_ON_SUBTITLE,
                                      style:
                                          Theme.of(context).textTheme.headline3,
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: Navigator.of(context).pop,
                                        child: Text(Language.instance.OK),
                                      ),
                                    ],
                                  ),
                                );
                                return;
                              }
                              if (Configuration
                                      .instance.collectionDirectories.length ==
                                  1) {
                                showDialog(
                                  context: context,
                                  builder: (subContext) => AlertDialog(
                                    title: Text(
                                      Language.instance.WARNING,
                                    ),
                                    content: Text(
                                      Language.instance
                                          .LAST_COLLECTION_DIRECTORY_REMOVED,
                                      style: Theme.of(subContext)
                                          .textTheme
                                          .headline3,
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () async {
                                          Navigator.of(subContext).pop();
                                        },
                                        child: Text(Language.instance.OK),
                                      ),
                                    ],
                                  ),
                                );
                                return;
                              }
                              await Collection.instance.removeDirectories(
                                directories: [directory],
                                onProgress: (progress, total, isCompleted) {
                                  CollectionRefresh.instance
                                      .set(progress, total);
                                },
                              );
                              await Configuration.instance.save(
                                collectionDirectories:
                                    Configuration.instance.collectionDirectories
                                      ..remove(directory),
                              );
                            },
                            child: Text(
                              Language.instance.REMOVE.toUpperCase(),
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ],
          ),
          actions: [
            TextButton(
              child: Text(
                Language.instance.GO_TO_SETTINGS.toUpperCase(),
              ),
              style: ButtonStyle(
                foregroundColor: _TextButtonDefaultColorCompat(
                  Theme.of(context).primaryColor,
                  Theme.of(context).disabledColor,
                ),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        FadeThroughTransition(
                      fillColor: Colors.transparent,
                      animation: animation,
                      secondaryAnimation: secondaryAnimation,
                      child: Settings(),
                    ),
                  ),
                );
              },
            ),
            TextButton(
              child: Text(
                Language.instance.DONE.toUpperCase(),
              ),
              style: ButtonStyle(
                foregroundColor: _TextButtonDefaultColorCompat(
                  Theme.of(context).primaryColor,
                  Theme.of(context).disabledColor,
                ),
              ),
              onPressed: missingDirectories.isEmpty
                  ? Navigator.of(context).maybePop
                  : null,
            ),
          ],
        );
      },
    );
  }
}

@immutable
class _TextButtonDefaultColorCompat extends MaterialStateProperty<Color?> {
  _TextButtonDefaultColorCompat(this.color, this.disabled);

  final Color? color;
  final Color? disabled;

  @override
  Color? resolve(Set<MaterialState> states) {
    if (states.contains(MaterialState.disabled)) {
      return disabled;
    }
    return color;
  }

  @override
  String toString() {
    return '{disabled: $disabled, otherwise: $color}';
  }
}

class MobileAppBarOverflowButton extends StatefulWidget {
  final Color? color;
  MobileAppBarOverflowButton({
    Key? key,
    this.color,
  }) : super(key: key);

  @override
  State<MobileAppBarOverflowButton> createState() =>
      _MobileAppBarOverflowButtonState();
}

class _MobileAppBarOverflowButtonState
    extends State<MobileAppBarOverflowButton> {
  @override
  Widget build(BuildContext context) {
    return CircularButton(
      icon: Icon(
        Icons.more_vert,
        color: widget.color ??
            Theme.of(context).appBarTheme.actionsIconTheme?.color,
      ),
      onPressed: () {
        final position = RelativeRect.fromRect(
          Offset(
                MediaQuery.of(context).size.width - tileMargin - 48.0,
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
            PopupMenuItem(
              value: 0,
              child: ListTile(
                leading: Icon(Icons.file_open),
                title: Text(Language.instance.OPEN_FILE_OR_URL),
              ),
            ),
            PopupMenuItem(
              value: 1,
              child: ListTile(
                leading: Icon(Icons.code),
                title: Text(Language.instance.READ_METADATA),
              ),
            ),
            PopupMenuItem(
              value: 2,
              child: ListTile(
                leading: Icon(Icons.settings),
                title: Text(Language.instance.SETTING),
              ),
            ),
            PopupMenuItem(
              value: 3,
              child: ListTile(
                leading: Icon(Icons.info),
                title: Text(Language.instance.ABOUT_TITLE),
              ),
            ),
          ],
        ).then((value) async {
          switch (value) {
            case 0:
              {
                await showDialog(
                  context: context,
                  builder: (ctx) => SimpleDialog(
                    title: Text(
                      Language.instance.OPEN_FILE_OR_URL,
                    ),
                    children: [
                      ListTile(
                        onTap: () async {
                          final file = await pickFile(
                            label: Language.instance.MEDIA_FILES,
                            extensions: kSupportedFileTypes,
                          );
                          if (file != null) {
                            await Navigator.of(ctx).maybePop();
                            await Intent.instance.playUri(file.uri);
                          }
                        },
                        leading: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Theme.of(ctx).iconTheme.color,
                          child: Icon(
                            Icons.folder,
                          ),
                        ),
                        title: Text(
                          Language.instance.FILE,
                          style: isDesktop
                              ? Theme.of(ctx).textTheme.headline4
                              : Theme.of(ctx).textTheme.headline3?.copyWith(
                                    fontSize: 16.0,
                                  ),
                        ),
                      ),
                      ListTile(
                        onTap: () async {
                          await Navigator.of(ctx).maybePop();
                          String input = '';
                          final GlobalKey<FormState> formKey =
                              GlobalKey<FormState>();
                          await showModalBottomSheet(
                            isScrollControlled: true,
                            context: context,
                            elevation: 8.0,
                            useRootNavigator: true,
                            backgroundColor: Theme.of(context).cardColor,
                            builder: (context) => StatefulBuilder(
                              builder: (context, setState) {
                                return Container(
                                  margin: EdgeInsets.only(
                                    bottom: MediaQuery.of(context)
                                            .viewInsets
                                            .bottom -
                                        MediaQuery.of(context).padding.bottom,
                                  ),
                                  padding: EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      const SizedBox(height: 4.0),
                                      Form(
                                        key: formKey,
                                        child: TextFormField(
                                          autofocus: true,
                                          autocorrect: false,
                                          validator: (value) {
                                            final error = value == null
                                                ? null
                                                : validate(value) == null
                                                    ? ''
                                                    : null;
                                            debugPrint(error.toString());
                                            return error;
                                          },
                                          onChanged: (value) => input = value,
                                          keyboardType: TextInputType.url,
                                          textCapitalization:
                                              TextCapitalization.none,
                                          textInputAction: TextInputAction.done,
                                          onFieldSubmitted: (value) async {
                                            if (formKey.currentState
                                                    ?.validate() ??
                                                false) {
                                              await Navigator.of(context)
                                                  .maybePop();
                                              await Intent.instance
                                                  .playUri(validate(value)!);
                                            }
                                          },
                                          decoration: InputDecoration(
                                            contentPadding: EdgeInsets.fromLTRB(
                                              12,
                                              30,
                                              12,
                                              6,
                                            ),
                                            hintText: Language
                                                .instance.FILE_PATH_OR_URL,
                                            border: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .iconTheme
                                                    .color!
                                                    .withOpacity(0.4),
                                                width: 1.8,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .iconTheme
                                                    .color!
                                                    .withOpacity(0.4),
                                                width: 1.8,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                width: 1.8,
                                              ),
                                            ),
                                            errorStyle: TextStyle(height: 0.0),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4.0),
                                      ElevatedButton(
                                        onPressed: () async {
                                          if (formKey.currentState
                                                  ?.validate() ??
                                              false) {
                                            await Navigator.of(context)
                                                .maybePop();
                                            await Intent.instance
                                                .playUri(validate(input)!);
                                          }
                                        },
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                            Theme.of(context).primaryColor,
                                          ),
                                        ),
                                        child: Text(
                                          Language.instance.PLAY.toUpperCase(),
                                          style: TextStyle(letterSpacing: 2.0),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                        },
                        leading: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Theme.of(ctx).iconTheme.color,
                          child: Icon(
                            Icons.link,
                          ),
                        ),
                        title: Text(
                          Language.instance.URL,
                          style: isDesktop
                              ? Theme.of(ctx).textTheme.headline4
                              : Theme.of(ctx).textTheme.headline3?.copyWith(
                                    fontSize: 16.0,
                                  ),
                        ),
                      ),
                    ],
                  ),
                );
                break;
              }
            case 1:
              {
                await FileInfoScreen.show(context);
                break;
              }
            case 2:
              {
                await Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        FadeThroughTransition(
                      animation: animation,
                      secondaryAnimation: secondaryAnimation,
                      child: Settings(),
                    ),
                  ),
                );
                break;
              }
            case 3:
              {
                await Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        FadeThroughTransition(
                      animation: animation,
                      secondaryAnimation: secondaryAnimation,
                      child: AboutPage(),
                    ),
                  ),
                );
                break;
              }
          }
        });
      },
    );
  }
}
