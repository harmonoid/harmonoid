/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart'
    hide ReorderableDragStartListener, Intent;
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:uri_parser/uri_parser.dart';
import 'package:window_plus/window_plus.dart';
import 'package:media_library/media_library.dart';
import 'package:visual_assets/visual_assets.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:known_extents_list_view_builder/known_extents_list_view_builder.dart';

import 'package:harmonoid/core/intent.dart';
import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/utils/theme.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/constants.dart';
import 'package:harmonoid/utils/custom_popup_menu.dart';
import 'package:harmonoid/utils/keyboard_shortcuts.dart';
import 'package:harmonoid/state/collection_refresh.dart';
import 'package:harmonoid/state/mobile_now_playing_controller.dart';
import 'package:harmonoid/interface/file_info_screen.dart';
import 'package:harmonoid/interface/settings/settings.dart';
import 'package:harmonoid/interface/settings/about.dart';
import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/web/web.dart';

export 'package:harmonoid/utils/custom_popup_menu.dart';

import 'package:harmonoid/main.dart';

class CustomListView extends StatelessWidget {
  final List<Widget> children;
  final ScrollController? controller;
  final ScrollPhysics? physics;
  final double? cacheExtent;
  final Axis? scrollDirection;
  final bool? shrinkWrap;
  final EdgeInsets? padding;
  final double? itemExtent;
  final ScrollViewKeyboardDismissBehavior? keyboardDismissBehavior;

  CustomListView({
    required this.children,
    this.controller,
    this.physics,
    this.cacheExtent,
    this.scrollDirection,
    this.shrinkWrap,
    this.padding,
    this.itemExtent,
    this.keyboardDismissBehavior,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      cacheExtent: cacheExtent,
      physics: physics,
      keyboardDismissBehavior:
          keyboardDismissBehavior ?? ScrollViewKeyboardDismissBehavior.onDrag,
      padding: padding ?? EdgeInsets.zero,
      controller: controller,
      scrollDirection: scrollDirection ?? Axis.vertical,
      shrinkWrap: shrinkWrap ?? false,
      children: children,
      itemExtent: itemExtent,
    );
  }
}

class CustomListViewBuilder extends StatelessWidget {
  final int itemCount;
  final List<double> itemExtents;
  final Widget Function(BuildContext, int) itemBuilder;
  final ScrollController? controller;
  final Axis? scrollDirection;
  final bool? shrinkWrap;
  final EdgeInsets? padding;
  final ScrollPhysics? physics;

  CustomListViewBuilder({
    required this.itemCount,
    required this.itemExtents,
    required this.itemBuilder,
    this.controller,
    this.scrollDirection,
    this.shrinkWrap,
    this.padding,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return KnownExtentsListView.builder(
      itemExtents: itemExtents,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      controller: controller,
      scrollDirection: scrollDirection ?? Axis.vertical,
      padding: padding,
      physics: physics,
    );
  }
}

class CustomListViewSeparated extends StatelessWidget {
  final int itemCount;
  final double separatorExtent;
  final Widget Function(BuildContext, int) separatorBuilder;
  final List<double> itemExtents;
  final Widget Function(BuildContext, int) itemBuilder;
  final ScrollController? controller;
  final Axis? scrollDirection;
  final bool? shrinkWrap;
  final EdgeInsets? padding;
  final ScrollPhysics? physics;

  CustomListViewSeparated({
    required this.itemCount,
    required this.separatorExtent,
    required this.separatorBuilder,
    required this.itemExtents,
    required this.itemBuilder,
    this.controller,
    this.scrollDirection,
    this.shrinkWrap,
    this.padding,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return KnownExtentsListView.builder(
      itemExtents: List.generate(
        2 * itemCount - 1,
        (i) => i % 2 == 0 ? itemExtents[i ~/ 2] : separatorExtent,
      ),
      itemCount: 2 * itemCount - 1,
      itemBuilder: (context, i) => i % 2 == 0
          ? itemBuilder(context, i ~/ 2)
          : separatorBuilder(context, i ~/ 2),
      controller: controller,
      scrollDirection: scrollDirection ?? Axis.vertical,
      padding: padding,
      physics: physics,
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

/// Wraps vanilla [TextField] inside [KeyboardShortcutsInterceptor] to prevent keyboard shortcuts from being triggered while the text field is focused.
class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final double? cursorWidth;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final void Function()? onEditingComplete;
  final InputDecoration? decoration;
  final TextAlignVertical? textAlignVertical;
  final bool? autofocus;
  final bool? autocorrect;
  final bool? readOnly;
  final TextStyle? style;
  final TextInputType? keyboardType;
  final TextCapitalization? textCapitalization;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final ScrollPhysics? scrollPhysics;
  final TextAlign? textAlign;
  const CustomTextField({
    Key? key,
    this.controller,
    this.focusNode,
    this.cursorWidth,
    this.onChanged,
    this.onSubmitted,
    this.onEditingComplete,
    this.decoration,
    this.textAlignVertical,
    this.autofocus,
    this.autocorrect,
    this.readOnly,
    this.style,
    this.keyboardType,
    this.textCapitalization,
    this.textInputAction,
    this.inputFormatters,
    this.scrollPhysics,
    this.textAlign,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return KeyboardShortcutsInterceptor(
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        cursorWidth: cursorWidth ?? 2.0,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        onEditingComplete: onEditingComplete,
        decoration: decoration,
        textAlignVertical: textAlignVertical,
        autofocus: autofocus ?? false,
        autocorrect: autocorrect ?? true,
        readOnly: readOnly ?? false,
        style: style,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization ?? TextCapitalization.none,
        textInputAction: textInputAction,
        inputFormatters: inputFormatters,
        scrollPhysics: scrollPhysics,
        textAlign: textAlign ?? TextAlign.start,
      ),
    );
  }
}

/// Wraps vanilla [TextFormField] inside [KeyboardShortcutsInterceptor] to prevent keyboard shortcuts from being triggered while the text field is focused.
class CustomTextFormField extends StatelessWidget {
  final String? initialValue;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final double? cursorWidth;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final void Function()? onEditingComplete;
  final InputDecoration? decoration;
  final TextAlignVertical? textAlignVertical;
  final bool? autofocus;
  final bool? autocorrect;
  final bool? readOnly;
  final TextStyle? style;
  final TextInputType? keyboardType;
  final TextCapitalization? textCapitalization;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final ScrollPhysics? scrollPhysics;
  final TextAlign? textAlign;
  const CustomTextFormField({
    Key? key,
    this.initialValue,
    this.controller,
    this.focusNode,
    this.cursorWidth,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.onEditingComplete,
    this.decoration,
    this.textAlignVertical,
    this.autofocus,
    this.autocorrect,
    this.readOnly,
    this.style,
    this.keyboardType,
    this.textCapitalization,
    this.textInputAction,
    this.inputFormatters,
    this.scrollPhysics,
    this.textAlign,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return KeyboardShortcutsInterceptor(
      child: TextFormField(
        initialValue: initialValue,
        controller: controller,
        focusNode: focusNode,
        cursorWidth: cursorWidth ?? 2.0,
        validator: validator,
        onChanged: onChanged,
        onFieldSubmitted: onFieldSubmitted,
        onEditingComplete: onEditingComplete,
        decoration: decoration,
        textAlignVertical: textAlignVertical,
        autofocus: autofocus ?? false,
        autocorrect: autocorrect ?? true,
        readOnly: readOnly ?? false,
        style: style,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization ?? TextCapitalization.none,
        textInputAction: textInputAction,
        inputFormatters: inputFormatters,
        scrollPhysics: scrollPhysics,
        textAlign: textAlign ?? TextAlign.start,
      ),
    );
  }
}

class SortBarFixedHolder extends StatefulWidget {
  final int index;
  final Widget child;
  const SortBarFixedHolder({
    Key? key,
    required this.index,
    required this.child,
  }) : super(key: key);

  SortBarFixedHolderState createState() => SortBarFixedHolderState();
}

class SortBarFixedHolderState extends State<SortBarFixedHolder> {
  bool hover0 = false;
  bool hover1 = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 4.0),
        GestureDetector(
          onTap: () {
            if (widget.index == kAlbumTabIndex) {
              Playback.instance.open(
                Collection.instance.albums.expand((e) => e.tracks).toList(),
              );
            } else if (widget.index == kTrackTabIndex) {
              Playback.instance.open(
                Collection.instance.tracks,
              );
            } else if (widget.index == kArtistTabIndex) {
              Playback.instance.open(
                Collection.instance.artists.expand((e) => e.tracks).toList(),
              );
            } else if (widget.index == kGenreTabIndex) {
              Playback.instance.open(
                Collection.instance.genres.expand((e) => e.tracks).toList(),
              );
            }
          },
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => setState(() {
              hover0 = true;
            }),
            onExit: (_) => setState(() {
              hover0 = false;
            }),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 6.0,
                vertical: 2.0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.play_arrow,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(
                    width: 4.0,
                  ),
                  Text(
                    Language.instance.PLAY_ALL,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          decoration: hover0
                              ? TextDecoration.underline
                              : TextDecoration.none,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 4.0),
        GestureDetector(
          onTap: () {
            Playback.instance.open(
              [...Collection.instance.tracks]..shuffle(),
            );
          },
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => setState(() {
              hover1 = true;
            }),
            onExit: (_) => setState(() {
              hover1 = false;
            }),
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
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(
                    width: 4.0,
                  ),
                  Text(
                    Language.instance.SHUFFLE,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          decoration: hover1
                              ? TextDecoration.underline
                              : TextDecoration.none,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Spacer(),
        widget.child,
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
          // TODO(@alexmercerind): Genre support.
          const SizedBox(width: 8.0),
          GestureDetector(
            key: _key0,
            onTap: () async {
              final value = await showCustomMenu(
                elevation: 4.0,
                context: context,
                constraints: BoxConstraints(
                  maxWidth: double.infinity,
                ),
                position: RelativeRect.fromLTRB(
                  _key0.globalPaintBounds!.left - (widget.fixed ? 0.0 : 8.0),
                  _key0.globalPaintBounds!.bottom +
                      tileMargin(context) / (widget.fixed ? 2.0 : 1.0),
                  MediaQuery.of(context).size.width,
                  MediaQuery.of(context).size.height,
                ),
                items: <PopupMenuEntry>[
                  ...{
                    kAlbumTabIndex: <PopupMenuItem>[
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
                            style: isDesktop
                                ? Theme.of(context).textTheme.bodyLarge
                                : null,
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
                            style: isDesktop
                                ? Theme.of(context).textTheme.bodyLarge
                                : null,
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
                            style: isDesktop
                                ? Theme.of(context).textTheme.bodyLarge
                                : null,
                          ),
                        ),
                      ),
                      CheckedPopupMenuItem(
                        checked:
                            Collection.instance.albumsSort == AlbumsSort.artist,
                        value: AlbumsSort.artist,
                        padding: EdgeInsets.zero,
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          title: Text(
                            Language.instance.ALBUM_ARTIST,
                            style: isDesktop
                                ? Theme.of(context).textTheme.bodyLarge
                                : null,
                          ),
                        ),
                      ),
                    ],
                    kTrackTabIndex: <PopupMenuItem>[
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
                            style: isDesktop
                                ? Theme.of(context).textTheme.bodyLarge
                                : null,
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
                            style: isDesktop
                                ? Theme.of(context).textTheme.bodyLarge
                                : null,
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
                            style: isDesktop
                                ? Theme.of(context).textTheme.bodyLarge
                                : null,
                          ),
                        ),
                      ),
                    ],
                    kArtistTabIndex: <PopupMenuItem>[
                      CheckedPopupMenuItem(
                        checked:
                            Collection.instance.artistsSort == ArtistsSort.aToZ,
                        value: ArtistsSort.aToZ,
                        padding: EdgeInsets.zero,
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          title: Text(
                            Language.instance.A_TO_Z,
                            style: isDesktop
                                ? Theme.of(context).textTheme.bodyLarge
                                : null,
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
                            style: isDesktop
                                ? Theme.of(context).textTheme.bodyLarge
                                : null,
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
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              onEnter: (e) => setState(() => _hover0 = true),
              onExit: (e) => setState(() => _hover0 = false),
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
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          TextSpan(
                            text: {
                              kAlbumTabIndex: {
                                AlbumsSort.aToZ: Language.instance.A_TO_Z,
                                AlbumsSort.dateAdded:
                                    Language.instance.DATE_ADDED,
                                AlbumsSort.year: Language.instance.YEAR,
                                AlbumsSort.artist:
                                    Language.instance.ALBUM_ARTIST,
                              }[collection.albumsSort]!,
                              kTrackTabIndex: {
                                TracksSort.aToZ: Language.instance.A_TO_Z,
                                TracksSort.dateAdded:
                                    Language.instance.DATE_ADDED,
                                TracksSort.year: Language.instance.YEAR,
                              }[collection.tracksSort]!,
                              kArtistTabIndex: {
                                ArtistsSort.aToZ: Language.instance.A_TO_Z,
                                ArtistsSort.dateAdded:
                                    Language.instance.DATE_ADDED,
                              }[collection.artistsSort]!,
                            }[tab]!,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
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
                      color: Theme.of(context).colorScheme.primary,
                      size: 18.0,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 4.0),
          GestureDetector(
            key: _key1,
            onTap: () async {
              final value = await showCustomMenu(
                elevation: 4.0,
                context: context,
                constraints: BoxConstraints(
                  maxWidth: double.infinity,
                ),
                position: RelativeRect.fromLTRB(
                  MediaQuery.of(context).size.width,
                  _key1.globalPaintBounds!.bottom +
                      tileMargin(context) / (widget.fixed ? 2.0 : 1.0),
                  tileMargin(context) + (widget.fixed ? 8.0 : 0.0),
                  0.0,
                ),
                items: <PopupMenuEntry>[
                  CheckedPopupMenuItem(
                    checked: {
                      kAlbumTabIndex: Collection.instance.albumsOrderType ==
                          OrderType.ascending,
                      kTrackTabIndex: Collection.instance.tracksOrderType ==
                          OrderType.ascending,
                      kArtistTabIndex: Collection.instance.artistsOrderType ==
                          OrderType.ascending,
                    }[tab]!,
                    value: OrderType.ascending,
                    padding: EdgeInsets.zero,
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      title: Text(
                        Language.instance.ASCENDING,
                        style: isDesktop
                            ? Theme.of(context).textTheme.bodyLarge
                            : null,
                      ),
                    ),
                  ),
                  CheckedPopupMenuItem(
                    checked: {
                      kAlbumTabIndex: Collection.instance.albumsOrderType ==
                          OrderType.descending,
                      kTrackTabIndex: Collection.instance.tracksOrderType ==
                          OrderType.descending,
                      kArtistTabIndex: Collection.instance.artistsOrderType ==
                          OrderType.descending,
                    }[tab]!,
                    value: OrderType.descending,
                    padding: EdgeInsets.zero,
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      title: Text(
                        Language.instance.DESCENDING,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ),
                ],
              );
              if (value is OrderType) {
                switch (tab) {
                  case kAlbumTabIndex:
                    {
                      await Collection.instance.sort(albumsOrderType: value);
                      await Configuration.instance.save(albumsOrderType: value);
                      break;
                    }
                  case kTrackTabIndex:
                    {
                      await Collection.instance.sort(tracksOrderType: value);
                      await Configuration.instance.save(tracksOrderType: value);
                      break;
                    }
                  case kArtistTabIndex:
                    {
                      await Collection.instance.sort(artistsOrderType: value);
                      await Configuration.instance
                          .save(artistsOrderType: value);
                      break;
                    }
                }
              }
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              onEnter: (e) => setState(() => _hover1 = true),
              onExit: (e) => setState(() => _hover1 = false),
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
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          TextSpan(
                            text: {
                              kAlbumTabIndex: {
                                OrderType.ascending:
                                    Language.instance.ASCENDING,
                                OrderType.descending:
                                    Language.instance.DESCENDING,
                              }[collection.albumsOrderType]!,
                              kTrackTabIndex: {
                                OrderType.ascending:
                                    Language.instance.ASCENDING,
                                OrderType.descending:
                                    Language.instance.DESCENDING,
                              }[collection.tracksOrderType]!,
                              kArtistTabIndex: {
                                OrderType.ascending:
                                    Language.instance.ASCENDING,
                                OrderType.descending:
                                    Language.instance.DESCENDING,
                              }[collection.artistsOrderType]!,
                            }[tab]!,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
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
                      color: Theme.of(context).colorScheme.primary,
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
              padding: EdgeInsets.only(right: tileMargin(context)),
              child: child,
            ),
          )
        : ValueListenableBuilder<bool>(
            valueListenable: widget.hover,
            child: child,
            builder: (context, hover, child) => AnimatedPositioned(
              curve: Curves.easeInOut,
              duration:
                  Theme.of(context).extension<AnimationDuration>()?.fast ??
                      Duration.zero,
              top: hover
                  ? widget.tab == 1
                      ? 28.0
                      : 0
                  : -72.0,
              right: tileMargin(context),
              child: Card(
                color: Theme.of(context).appBarTheme.backgroundColor,
                margin: EdgeInsets.only(top: tileMargin(context)),
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
        duration: Theme.of(context).extension<AnimationDuration>()?.fast ??
            Duration.zero,
        tween: Tween<double>(begin: 1.0, end: scale),
        builder: (BuildContext context, double value, _) {
          return Transform.scale(scale: value, child: widget.child);
        },
      ),
    );
  }
}

class SubHeader extends StatelessWidget {
  final String text;
  final double height;
  final EdgeInsets? padding;

  const SubHeader(
    this.text, {
    this.height = 56.0,
    this.padding,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final horizontal = isDesktop ? 24.0 : 16.0;
    final fontSize = isDesktop ? 16.0 : null;
    final TextStyle? style;
    if (isMaterial2(context) && isMobile) {
      style = Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: fontSize,
          );
    } else if (isMaterial2(context) && isDesktop) {
      style = Theme.of(context).textTheme.titleSmall?.copyWith(
            fontSize: fontSize,
          );
    } else {
      style = Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontSize: fontSize,
          );
    }
    return Container(
      alignment: Alignment.centerLeft,
      height: height,
      padding: padding ?? EdgeInsets.symmetric(horizontal: horizontal),
      child: Text(
        text,
        style: style,
      ),
    );
  }
}

class NavigatorPopButton extends StatelessWidget {
  final Color? color;
  final void Function()? onTap;
  final bool disabled;
  NavigatorPopButton({
    Key? key,
    this.onTap,
    this.color,
    this.disabled = false,
  }) : super(key: key);

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
  final List<Widget>? actions;

  const DesktopAppBar({
    Key? key,
    this.title,
    this.child,
    this.color,
    this.leading,
    this.height,
    this.elevation,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      clipBehavior: Clip.antiAlias,
      child: Container(
        height: (height ?? kDesktopAppBarHeight) +
            WindowPlus.instance.captionHeight +
            8.0,
        alignment: Alignment.topLeft,
        padding: EdgeInsets.only(bottom: 8.0),
        child: Material(
          animationDuration: Duration.zero,
          elevation:
              elevation ?? Theme.of(context).appBarTheme.elevation ?? 4.0,
          color: color ?? Theme.of(context).appBarTheme.backgroundColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DesktopCaptionBar(
                color: color,
              ),
              Container(
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
                                      ?.appBarDark
                                  : Theme.of(context)
                                      .extension<IconColors>()
                                      ?.appBarLight
                              : null,
                        ),
                    SizedBox(
                      width: 16.0,
                    ),
                    if (title != null)
                      Text(
                        title!,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    if (actions != null) ...[
                      const Spacer(),
                      ...actions!,
                      const SizedBox(width: 16.0),
                    ] else if (child != null)
                      Expanded(
                        child: child!,
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
              heroTag: 'collection_refresh_button',
              child: Icon(
                Icons.refresh,
                color: widget.color == null
                    ? null
                    : (widget.color?.computeLuminance() ?? 0.0) < 0.5
                        ? kFABDarkForegroundColor
                        : kFABLightForegroundColor,
              ),
              onPressed: () {
                if (lock) return;
                lock = true;
                Collection.instance.refresh(
                    onProgress: (progress, total, completed) {
                  CollectionRefresh.instance.set(progress, total);
                  if (completed) {
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
  final String title;
  final String subtitle;

  const ExceptionWidget({
    Key? key,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          Image.memory(
            {
              Language.instance.NO_COLLECTION_TITLE: VisualAssets.library,
              Language.instance.NO_INTERNET_TITLE: VisualAssets.library,
              Language.instance.COLLECTION_SEARCH_NO_RESULTS_TITLE:
                  VisualAssets.searchPage,
              Language.instance.WEB_WELCOME_TITLE: VisualAssets.searchNotes,
              Language.instance.COLLECTION_SEARCH_LABEL:
                  VisualAssets.searchPage,
            }[title]!,
            height: 164.0,
            width: 164.0,
            filterQuality: FilterQuality.high,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 12.0),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4.0),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          if (title == Language.instance.NO_COLLECTION_TITLE) ...[
            const SizedBox(height: 8.0),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialRoute(
                    builder: (context) => Settings(),
                  ),
                );
              },
              child: Text(
                label(context, Language.instance.GO_TO_SETTINGS),
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

class DesktopCaptionBar extends StatelessWidget {
  final hideMaximizeAndRestoreButton;
  final Color? color;
  const DesktopCaptionBar({
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
    return WindowPlus.instance.captionHeight > 0.0
        ? Container(
            width: MediaQuery.of(context).size.width,
            height: WindowPlus.instance.captionHeight,
            color: color ?? Theme.of(context).appBarTheme.backgroundColor,
            alignment: Alignment.topCenter,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: WindowCaption(
                    brightness: brightness ?? Theme.of(context).brightness,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 14.0,
                        ),
                        Text(
                          kCaption,
                          style: TextStyle(
                            color:
                                (brightness ?? Theme.of(context).brightness) ==
                                        Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                            fontSize: 12.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        : Container();
  }

  Brightness? get brightness {
    if (color == null) {
      return null;
    }
    return (0.299 * (color?.red ?? 256.0)) +
                (0.587 * (color?.green ?? 256.0)) +
                (0.114 * (color?.blue ?? 256.0)) <
            128.0
        ? Brightness.dark
        : Brightness.light;
  }
}

class M2MobileBottomNavigationBar extends StatefulWidget {
  final ValueNotifier<TabRoute> tabControllerNotifier;
  M2MobileBottomNavigationBar({
    Key? key,
    required this.tabControllerNotifier,
  }) : super(key: key);

  @override
  State<M2MobileBottomNavigationBar> createState() =>
      _M2MobileBottomNavigationBarState();
}

class _M2MobileBottomNavigationBarState
    extends State<M2MobileBottomNavigationBar> {
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
        duration: Theme.of(context).extension<AnimationDuration>()?.medium ??
            Duration.zero,
        tween: ColorTween(
          begin: Theme.of(context).colorScheme.primary,
          end: value?.first ?? Theme.of(context).colorScheme.primary,
        ),
        builder: (context, color, _) => isMaterial3(context)
            ? NavigationBar(
                destinations: [
                  NavigationDestination(
                    icon: Icon(Icons.album),
                    label: Language.instance.ALBUM,
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.music_note),
                    label: Language.instance.TRACK,
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.person),
                    label: Language.instance.ARTIST,
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.playlist_play),
                    label: Language.instance.PLAYLIST,
                  ),
                ],
              )
            : Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(color: Colors.black45, blurRadius: 8.0),
                  ],
                ),
                child: BottomNavigationBar(
                  currentIndex: _index,
                  selectedItemColor: (color?.computeLuminance() ?? 0.0) < 0.5
                      ? null
                      : Colors.black87,
                  unselectedItemColor: (color?.computeLuminance() ?? 0.0) < 0.5
                      ? null
                      : Colors.black45,
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
                      icon: Icon(Icons.album),
                      label: Language.instance.ALBUM,
                      backgroundColor:
                          color ?? Theme.of(context).colorScheme.primary,
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.music_note),
                      label: Language.instance.TRACK,
                      backgroundColor:
                          color ?? Theme.of(context).colorScheme.primary,
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person),
                      label: Language.instance.ARTIST,
                      backgroundColor:
                          color ?? Theme.of(context).colorScheme.primary,
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.playlist_play),
                      label: Language.instance.PLAYLIST,
                      backgroundColor:
                          color ?? Theme.of(context).colorScheme.primary,
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
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(4.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8.0,
          vertical: 4.0,
        ),
        child: Row(
          children: [
            Icon(
              Icons.view_list,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(
              width: 4.0,
            ),
            Text(
              Language.instance.SEE_ALL,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ],
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
  final bool enabled;
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
    this.enabled = true,
    required this.value,
    this.color,
    this.secondaryColor,
    required this.onScrolledUp,
    required this.onScrolledDown,
    required this.onChanged,
    this.inferSliderInactiveTrackColor = true,
    this.mobile = false,
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
              (color ?? Theme.of(context).colorScheme.primary).withOpacity(0.4),
          thumbColor: enabled
              ? (color ?? Theme.of(context).colorScheme.primary)
              : Theme.of(context).disabledColor,
          activeTrackColor: enabled
              ? (color ?? Theme.of(context).colorScheme.primary)
              : Theme.of(context).disabledColor,
          inactiveTrackColor: enabled
              ? ((mobile && isMobile)
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                  : inferSliderInactiveTrackColor
                      ? ((secondaryColor != null
                              ? (secondaryColor?.computeLuminance() ?? 0.0) <
                                  0.5
                              : Theme.of(context).brightness == Brightness.dark)
                          ? Colors.white.withOpacity(0.4)
                          : Colors.black.withOpacity(0.2))
                      : Colors.white.withOpacity(0.4))
              : Theme.of(context).disabledColor.withOpacity(0.2),
        ),
        child: Slider(
          value: value,
          onChanged: enabled ? onChanged : null,
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
          if (extentAfter != 0.0 && isDesktop)
            Positioned(
              child: Container(
                height: c.maxHeight,
                child: Center(
                  child: FloatingActionButton(
                    mini: true,
                    heroTag: ValueKey(Random().nextInt(1 << 32)),
                    onPressed: () {
                      controller.animateTo(
                        controller.offset +
                            MediaQuery.of(context).size.width / 2,
                        duration: Theme.of(context)
                                .extension<AnimationDuration>()
                                ?.fast ??
                            Duration.zero,
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Icon(Icons.arrow_forward),
                  ),
                ),
              ),
              right: isDesktop ? 32.0 : tileMargin(context),
            ),
          if (extentBefore != 0.0 && isDesktop)
            Positioned(
              child: Container(
                height: c.maxHeight,
                child: Center(
                  child: FloatingActionButton(
                    mini: true,
                    heroTag: ValueKey(Random().nextInt(1 << 32)),
                    onPressed: () {
                      controller.animateTo(
                        controller.offset -
                            MediaQuery.of(context).size.width / 2,
                        duration: Theme.of(context)
                                .extension<AnimationDuration>()
                                ?.fast ??
                            Duration.zero,
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Icon(Icons.arrow_back),
                  ),
                ),
              ),
              left: isDesktop ? 32.0 : tileMargin(context),
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
      child: CustomPopupMenuButton<dynamic>(
        offset: Offset.fromDirection(pi / 2, 64.0),
        icon: Icon(
          Icons.sort_by_alpha,
          size: 20.0,
        ),
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
          if (value is OrderType) {
            switch (tab) {
              case kAlbumTabIndex:
                {
                  await Collection.instance.sort(albumsOrderType: value);
                  await Configuration.instance.save(albumsOrderType: value);
                  break;
                }
              case kTrackTabIndex:
                {
                  await Collection.instance.sort(tracksOrderType: value);
                  await Configuration.instance.save(tracksOrderType: value);
                  break;
                }
              case kArtistTabIndex:
                {
                  await Collection.instance.sort(artistsOrderType: value);
                  await Configuration.instance.save(artistsOrderType: value);
                  break;
                }
            }
          }
        },
        itemBuilder: (context) => [
          ...{
            kAlbumTabIndex: <PopupMenuItem>[
              CheckedPopupMenuItem(
                checked: Collection.instance.albumsSort == AlbumsSort.aToZ,
                value: AlbumsSort.aToZ,
                padding: EdgeInsets.zero,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(
                    Language.instance.A_TO_Z,
                    style: isDesktop
                        ? Theme.of(context).textTheme.bodyLarge
                        : null,
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
                    style: isDesktop
                        ? Theme.of(context).textTheme.bodyLarge
                        : null,
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
                    style: isDesktop
                        ? Theme.of(context).textTheme.bodyLarge
                        : null,
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
                    Language.instance.ALBUM_ARTIST,
                    style: isDesktop
                        ? Theme.of(context).textTheme.bodyLarge
                        : null,
                  ),
                ),
              ),
            ],
            kTrackTabIndex: <PopupMenuItem>[
              CheckedPopupMenuItem(
                checked: Collection.instance.tracksSort == TracksSort.aToZ,
                value: TracksSort.aToZ,
                padding: EdgeInsets.zero,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(
                    Language.instance.A_TO_Z,
                    style: isDesktop
                        ? isDesktop
                            ? Theme.of(context).textTheme.bodyLarge
                            : null
                        : null,
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
                    style: isDesktop
                        ? Theme.of(context).textTheme.bodyLarge
                        : null,
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
                    style: isDesktop
                        ? Theme.of(context).textTheme.bodyLarge
                        : null,
                  ),
                ),
              ),
            ],
            kArtistTabIndex: <PopupMenuItem>[
              CheckedPopupMenuItem(
                checked: Collection.instance.artistsSort == ArtistsSort.aToZ,
                value: ArtistsSort.aToZ,
                padding: EdgeInsets.zero,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(
                    Language.instance.A_TO_Z,
                    style: isDesktop
                        ? Theme.of(context).textTheme.bodyLarge
                        : null,
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
                    style: isDesktop
                        ? Theme.of(context).textTheme.bodyLarge
                        : null,
                  ),
                ),
              ),
            ],
          }[tab]!,
          PopupMenuDivider(),
          ...[
            CheckedPopupMenuItem(
              checked: {
                kAlbumTabIndex:
                    Collection.instance.albumsOrderType == OrderType.ascending,
                kTrackTabIndex:
                    Collection.instance.tracksOrderType == OrderType.ascending,
                kArtistTabIndex:
                    Collection.instance.artistsOrderType == OrderType.ascending,
              }[tab]!,
              value: OrderType.ascending,
              padding: EdgeInsets.zero,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: Text(
                  Language.instance.ASCENDING,
                  style:
                      isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
                ),
              ),
            ),
            CheckedPopupMenuItem(
              checked: {
                kAlbumTabIndex:
                    Collection.instance.albumsOrderType == OrderType.descending,
                kTrackTabIndex:
                    Collection.instance.tracksOrderType == OrderType.descending,
                kArtistTabIndex: Collection.instance.artistsOrderType ==
                    OrderType.descending,
              }[tab]!,
              value: OrderType.descending,
              padding: EdgeInsets.zero,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: Text(
                  Language.instance.DESCENDING,
                  style:
                      isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
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
        style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onChanged: (value) {
        onChanged.call(value);
      },
    );
  }
}

class MobileSortByButton extends StatefulWidget {
  final int tab;
  MobileSortByButton({
    Key? key,
    required this.tab,
  }) : super(key: key);

  @override
  State<MobileSortByButton> createState() => _MobileSortByButtonState();
}

class _MobileSortByButtonState extends State<MobileSortByButton> {
  Future<void> handle(dynamic value) async {
    if (value is AlbumsSort) {
      if (Collection.instance.albumsSort == value) {
        return;
      }
      await Collection.instance.sort(albumsSort: value);
      await Configuration.instance.save(albumsSort: value);
    }
    if (value is TracksSort) {
      if (Collection.instance.tracksSort == value) {
        return;
      }
      await Collection.instance.sort(tracksSort: value);
      await Configuration.instance.save(tracksSort: value);
    }
    if (value is ArtistsSort) {
      if (Collection.instance.artistsSort == value) {
        return;
      }
      await Collection.instance.sort(artistsSort: value);
      await Configuration.instance.save(artistsSort: value);
    }
    if (value is GenresSort) {
      if (Collection.instance.genresSort == value) {
        return;
      }
      await Collection.instance.sort(genresSort: value);
      await Configuration.instance.save(genresSort: value);
    }
    if (value is OrderType) {
      switch (widget.tab) {
        case kAlbumTabIndex:
          {
            if (Collection.instance.albumsOrderType == value) {
              return;
            }
            await Collection.instance.sort(albumsOrderType: value);
            await Configuration.instance.save(albumsOrderType: value);
            break;
          }
        case kTrackTabIndex:
          {
            if (Collection.instance.tracksOrderType == value) {
              return;
            }
            await Collection.instance.sort(tracksOrderType: value);
            await Configuration.instance.save(tracksOrderType: value);
            break;
          }
        case kArtistTabIndex:
          {
            if (Collection.instance.artistsOrderType == value) {
              return;
            }
            await Collection.instance.sort(artistsOrderType: value);
            await Configuration.instance.save(artistsOrderType: value);
            break;
          }
        case kGenreTabIndex:
          {
            if (Collection.instance.genresOrderType == value) {
              return;
            }
            await Collection.instance.sort(genresOrderType: value);
            await Configuration.instance.save(genresOrderType: value);
            break;
          }
      }
    }
    debugPrint(setStateCallback.toString());
    try {
      setStateCallback?.call(() {
        debugPrint('setState');
      });
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }
  }

  void Function(void Function())? setStateCallback;

  List<CustomCheckedPopupMenuItem> get sort => {
        kAlbumTabIndex: <CustomCheckedPopupMenuItem>[
          CustomCheckedPopupMenuItem(
            onTap: () => handle(AlbumsSort.aToZ),
            checked: Collection.instance.albumsSort == AlbumsSort.aToZ,
            value: AlbumsSort.aToZ,
            padding: EdgeInsets.zero,
            child: Text(
              Language.instance.A_TO_Z,
              style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
            ),
          ),
          CustomCheckedPopupMenuItem(
            onTap: () => handle(AlbumsSort.dateAdded),
            checked: Collection.instance.albumsSort == AlbumsSort.dateAdded,
            value: AlbumsSort.dateAdded,
            padding: EdgeInsets.zero,
            child: Text(
              Language.instance.DATE_ADDED,
              style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
            ),
          ),
          CustomCheckedPopupMenuItem(
            onTap: () => handle(AlbumsSort.year),
            checked: Collection.instance.albumsSort == AlbumsSort.year,
            value: AlbumsSort.year,
            padding: EdgeInsets.zero,
            child: Text(
              Language.instance.YEAR,
              style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
            ),
          ),
        ],
        kTrackTabIndex: <CustomCheckedPopupMenuItem>[
          CustomCheckedPopupMenuItem(
            onTap: () => handle(TracksSort.aToZ),
            checked: Collection.instance.tracksSort == TracksSort.aToZ,
            value: TracksSort.aToZ,
            padding: EdgeInsets.zero,
            child: Text(
              Language.instance.A_TO_Z,
              style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
            ),
          ),
          CustomCheckedPopupMenuItem(
            onTap: () => handle(TracksSort.dateAdded),
            checked: Collection.instance.tracksSort == TracksSort.dateAdded,
            value: TracksSort.dateAdded,
            padding: EdgeInsets.zero,
            child: Text(
              Language.instance.DATE_ADDED,
              style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
            ),
          ),
          CustomCheckedPopupMenuItem(
            onTap: () => handle(TracksSort.year),
            checked: Collection.instance.tracksSort == TracksSort.year,
            value: TracksSort.year,
            padding: EdgeInsets.zero,
            child: Text(
              Language.instance.YEAR,
              style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
            ),
          ),
        ],
        kArtistTabIndex: <CustomCheckedPopupMenuItem>[
          CustomCheckedPopupMenuItem(
            onTap: () => handle(ArtistsSort.aToZ),
            checked: Collection.instance.artistsSort == ArtistsSort.aToZ,
            value: ArtistsSort.aToZ,
            padding: EdgeInsets.zero,
            child: Text(
              Language.instance.A_TO_Z,
              style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
            ),
          ),
          CustomCheckedPopupMenuItem(
            onTap: () => handle(ArtistsSort.dateAdded),
            checked: Collection.instance.artistsSort == ArtistsSort.dateAdded,
            value: ArtistsSort.dateAdded,
            padding: EdgeInsets.zero,
            child: Text(
              Language.instance.DATE_ADDED,
              style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
            ),
          ),
        ],
        kGenreTabIndex: <CustomCheckedPopupMenuItem>[
          CustomCheckedPopupMenuItem(
            onTap: () => handle(GenresSort.aToZ),
            checked: Collection.instance.genresSort == GenresSort.aToZ,
            value: GenresSort.aToZ,
            padding: EdgeInsets.zero,
            child: Text(
              Language.instance.A_TO_Z,
              style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
            ),
          ),
          CustomCheckedPopupMenuItem(
            onTap: () => handle(GenresSort.dateAdded),
            checked: Collection.instance.genresSort == GenresSort.dateAdded,
            value: GenresSort.dateAdded,
            padding: EdgeInsets.zero,
            child: Text(
              Language.instance.DATE_ADDED,
              style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
            ),
          ),
        ],
      }[widget.tab]!;

  List<CustomCheckedPopupMenuItem> get order => [
        CustomCheckedPopupMenuItem(
          onTap: () => handle(OrderType.ascending),
          checked: {
            kAlbumTabIndex:
                Collection.instance.albumsOrderType == OrderType.ascending,
            kTrackTabIndex:
                Collection.instance.tracksOrderType == OrderType.ascending,
            kArtistTabIndex:
                Collection.instance.artistsOrderType == OrderType.ascending,
            kGenreTabIndex:
                Collection.instance.genresOrderType == OrderType.ascending,
          }[widget.tab]!,
          value: OrderType.ascending,
          padding: EdgeInsets.zero,
          child: Text(
            Language.instance.ASCENDING,
            style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
          ),
        ),
        CustomCheckedPopupMenuItem(
          onTap: () => handle(OrderType.descending),
          checked: {
            kAlbumTabIndex:
                Collection.instance.albumsOrderType == OrderType.descending,
            kTrackTabIndex:
                Collection.instance.tracksOrderType == OrderType.descending,
            kArtistTabIndex:
                Collection.instance.artistsOrderType == OrderType.descending,
            kGenreTabIndex:
                Collection.instance.genresOrderType == OrderType.descending,
          }[widget.tab]!,
          value: OrderType.descending,
          padding: EdgeInsets.zero,
          child: Text(
            Language.instance.DESCENDING,
            style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
          ),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final color =
        isMaterial2(context) && Theme.of(context).brightness == Brightness.light
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).textTheme.bodyLarge?.color;
    return InkWell(
      borderRadius: isMaterial2(context)
          ? BorderRadius.circular(4.0)
          : BorderRadius.circular(20.0),
      onTap: () async {
        if (widget.tab == 3) return;
        await showModalBottomSheet(
          isScrollControlled: true,
          context: context,
          elevation: kDefaultHeavyElevation,
          builder: (context) => StatefulBuilder(
            builder: (context, setState) {
              setStateCallback = setState;
              return Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ...sort,
                    PopupMenuDivider(),
                    ...order,
                    if (!isDesktop &&
                        !MobileNowPlayingController.instance.isHidden)
                      const SizedBox(height: kMobileNowPlayingBarHeight),
                  ],
                ),
              );
            },
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Text(
              String.fromCharCode(
                order.firstWhere((e) => e.checked).value == OrderType.ascending
                    ? Icons.arrow_upward.codePoint
                    : Icons.arrow_downward.codePoint,
              ),
              style: TextStyle(
                inherit: false,
                fontSize: 18.0,
                fontWeight: FontWeight.w700,
                fontFamily: Icons.arrow_downward.fontFamily,
                package: Icons.arrow_downward.fontPackage,
                color: color,
              ),
            ),
            const SizedBox(width: 10.0),
            Text(
              label(
                context,
                (sort.firstWhere((e) => e.checked).child as Text)
                    .data
                    .toString(),
              ),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: color,
                  ),
            ),
            const SizedBox(width: 4.0),
          ],
        ),
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
          return true;
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
    return CustomPopupMenuButton<int>(
      icon: Icon(
        Icons.more_vert,
        size: 20.0,
        color: Theme.of(context).appBarTheme.actionsIconTheme?.color,
      ),
      elevation: 4.0,
      splashRadius: 20.0,
      padding: EdgeInsets.zero,
      offset: Offset.fromDirection(pi / 2, 64.0),
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
                MaterialRoute(
                  builder: (context) => WebTab(),
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
              style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
            ),
          ),
        ),
        PopupMenuItem(
          value: 1,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            leading: Icon(Icons.waves),
            title: Text(
              Language.instance.STREAM,
              style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
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
                    await Intent.instance.playURI(file.uri.toString());
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
                  style: isDesktop ? Theme.of(ctx).textTheme.bodyLarge : null,
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
                              child: Form(
                                key: formKey,
                                child: CustomTextFormField(
                                  autofocus: true,
                                  cursorWidth: 1.0,
                                  onChanged: (value) => input = value,
                                  validator: (value) {
                                    final parser = URIParser(value);
                                    if (!parser.validate()) {
                                      debugPrint(value);
                                      // Empty [String] prevents the message from showing & does not distort the UI.
                                      return '';
                                    }
                                    return null;
                                  },
                                  onFieldSubmitted: (value) async {
                                    if (value.isNotEmpty &&
                                        (formKey.currentState?.validate() ??
                                            false)) {
                                      Navigator.of(ctx).maybePop();
                                      await Intent.instance.playURI(value);
                                    }
                                  },
                                  textAlignVertical: TextAlignVertical.center,
                                  style: Theme.of(ctx).textTheme.bodyLarge,
                                  decoration: inputDecoration(
                                    ctx,
                                    Language.instance.PLAY_URL_SUBTITLE,
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
                            label(
                              context,
                              Language.instance.PLAY,
                            ),
                          ),
                          onPressed: () async {
                            if (input.isNotEmpty &&
                                (formKey.currentState?.validate() ?? false)) {
                              Navigator.of(ctx).maybePop();
                              await Intent.instance.playURI(input);
                            }
                          },
                        ),
                        TextButton(
                          child: Text(
                            label(
                              context,
                              Language.instance.CANCEL,
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
                  style: isDesktop ? Theme.of(ctx).textTheme.bodyLarge : null,
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
  static const int _kMaximumDrawRetryCount = 5;

  int count = 0;
  RawImage? image;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Flutter 3.3.x seems to have a bug where the image is not drawn in some rare cases.
      while (image == null && count < _kMaximumDrawRetryCount) {
        await draw();
        count++;
        debugPrint('#$count draw: ${widget.image}');
      }
    });
  }

  Future<void> draw() async {
    // [ImageProvider.evict] is needed since Flutter 3.3.x.
    await widget.image.evict();
    if (widget.image is NetworkImage) {
      final resolved = Uri.base.resolve((widget.image as NetworkImage).url);
      final request = await HttpClient().getUrl(resolved);
      final HttpClientResponse response = await request.close();
      final data = await consolidateHttpClientResponseBytes(response);
      final buffer = await ImmutableBuffer.fromUint8List(data);
      final codec = await PaintingBinding.instance
          .instantiateImageCodecFromBuffer(buffer);
      final frame = await codec.getNextFrame();
      setState(() {
        image = RawImage(
          image: frame.image.clone(),
          height: widget.height,
          width: widget.width,
          fit: BoxFit.cover,
        );
      });
    } else if (widget.image is AssetImage) {
      final buffer = await ImmutableBuffer.fromAsset(
        (widget.image as AssetImage).assetName,
      );
      final codec = await PaintingBinding.instance
          .instantiateImageCodecFromBuffer(buffer);
      final frame = await codec.getNextFrame();
      setState(() {
        image = RawImage(
          image: frame.image.clone(),
          height: widget.height,
          width: widget.width,
          fit: BoxFit.cover,
        );
      });
    } else if (widget.image is FileImage) {
      final data = await (widget.image as FileImage).file.readAsBytes();
      final buffer = await ImmutableBuffer.fromUint8List(data);
      final codec = await PaintingBinding.instance
          .instantiateImageCodecFromBuffer(buffer);
      final frame = await codec.getNextFrame();
      setState(() {
        image = RawImage(
          image: frame.image.clone(),
          height: widget.height,
          width: widget.width,
          fit: BoxFit.cover,
        );
      });
    }
  }

  @override
  void dispose() {
    widget.image.evict();
    super.dispose();
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
      onPressed: () async {
        Completer<int> completer = Completer<int>();
        await showModalBottomSheet(
          isScrollControlled: true,
          context: context,
          elevation: kDefaultHeavyElevation,
          useRootNavigator: false,
          builder: (context) => Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PopupMenuItem(
                  onTap: () {
                    completer.complete(0);
                    Navigator.of(context).maybePop();
                  },
                  child: ListTile(
                    leading: Icon(Icons.file_open),
                    title: Text(
                      Language.instance.OPEN_FILE_OR_URL,
                      style: isDesktop
                          ? Theme.of(context).textTheme.bodyLarge
                          : null,
                    ),
                  ),
                ),
                PopupMenuItem(
                  onTap: () {
                    completer.complete(1);
                    Navigator.of(context).maybePop();
                  },
                  child: ListTile(
                    leading: Icon(Icons.code),
                    title: Text(
                      Language.instance.READ_METADATA,
                      style: isDesktop
                          ? Theme.of(context).textTheme.bodyLarge
                          : null,
                    ),
                  ),
                ),
                PopupMenuItem(
                  onTap: () {
                    completer.complete(2);
                    Navigator.of(context).maybePop();
                  },
                  child: ListTile(
                    leading: Icon(Icons.settings),
                    title: Text(
                      Language.instance.SETTING,
                      style: isDesktop
                          ? Theme.of(context).textTheme.bodyLarge
                          : null,
                    ),
                  ),
                ),
                PopupMenuItem(
                  onTap: () {
                    completer.complete(3);
                    Navigator.of(context).maybePop();
                  },
                  child: ListTile(
                    leading: Icon(Icons.info),
                    title: Text(
                      Language.instance.ABOUT_TITLE,
                      style: isDesktop
                          ? Theme.of(context).textTheme.bodyLarge
                          : null,
                    ),
                  ),
                ),
                if (!isDesktop && !MobileNowPlayingController.instance.isHidden)
                  const SizedBox(height: kMobileNowPlayingBarHeight),
              ],
            ),
          ),
        );
        completer.future.then((value) async {
          // Prevent visual glitches when pushing a new route into the view.
          await Future.delayed(const Duration(milliseconds: 300));
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
                            await Intent.instance.playURI(file.uri.toString());
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
                              ? Theme.of(ctx).textTheme.bodyLarge
                              : null,
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
                            elevation: kDefaultHeavyElevation,
                            useRootNavigator: true,
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
                                        child: CustomTextFormField(
                                          autofocus: true,
                                          autocorrect: false,
                                          validator: (value) {
                                            final parser = URIParser(value);
                                            if (!parser.validate()) {
                                              debugPrint(value);
                                              // Empty [String] prevents the message from showing & does not distort the UI.
                                              return '';
                                            }
                                            return null;
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
                                                  .playURI(value);
                                            }
                                          },
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                                fontSize: 16.0,
                                              ),
                                          decoration:
                                              mobileUnderlinedInputDecoration(
                                            context,
                                            Language.instance.FILE_PATH_OR_URL,
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
                                                .playURI(input);
                                          }
                                        },
                                        child: Text(
                                          label(
                                            context,
                                            Language.instance.PLAY,
                                          ),
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
                              ? Theme.of(ctx).textTheme.bodyLarge
                              : null,
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
                  MaterialRoute(
                    builder: (context) => Settings(),
                  ),
                );
                break;
              }
            case 3:
              {
                await Navigator.push(
                  context,
                  MaterialRoute(
                    builder: (context) => AboutPage(),
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

class NoOverscrollGlowBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

// FIX FOR: https://github.com/flutter/flutter/issues/120516
class ScrollUnderFlexibleSpace extends StatelessWidget {
  const ScrollUnderFlexibleSpace({
    this.title,
    this.centerCollapsedTitle,
    this.primary = true,
  });

  final Widget? title;
  final bool? centerCollapsedTitle;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    late final ThemeData theme = Theme.of(context);
    final FlexibleSpaceBarSettings settings =
        context.dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>()!;
    final double topPadding =
        primary ? MediaQuery.of(context).viewPadding.top : 0;
    final double collapsedHeight = settings.minExtent - topPadding;
    final double scrollUnderHeight = settings.maxExtent - settings.minExtent;
    final LargeScrollUnderFlexibleConfig config =
        LargeScrollUnderFlexibleConfig(context);

    late final Widget? collapsedTitle;
    late final Widget? expandedTitle;
    if (title != null) {
      collapsedTitle = config.collapsedTextStyle != null
          ? DefaultTextStyle(
              style: config.collapsedTextStyle!,
              child: title!,
            )
          : title;
      expandedTitle = config.expandedTextStyle != null
          ? DefaultTextStyle(
              style: config.expandedTextStyle!,
              child: title!,
            )
          : title;
    }

    late final bool centerTitle;
    {
      bool platformCenter() {
        switch (theme.platform) {
          case TargetPlatform.android:
          case TargetPlatform.fuchsia:
          case TargetPlatform.linux:
          case TargetPlatform.windows:
            return false;
          case TargetPlatform.iOS:
          case TargetPlatform.macOS:
            return true;
        }
      }

      centerTitle = centerCollapsedTitle ??
          theme.appBarTheme.centerTitle ??
          platformCenter();
    }

    final bool isCollapsed = settings.isScrolledUnder ?? false;
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: topPadding),
          child: Container(
            height: collapsedHeight,
            padding: centerTitle
                ? config.collapsedCenteredTitlePadding
                : config.collapsedTitlePadding,
            child: AnimatedOpacity(
              opacity: isCollapsed ? 1 : 0,
              duration: const Duration(milliseconds: 500),
              curve: const Cubic(0.2, 0.0, 0.0, 1.0),
              child: Align(
                  alignment: centerTitle
                      ? Alignment.center
                      : AlignmentDirectional.centerStart,
                  child: collapsedTitle),
            ),
          ),
        ),
        Flexible(
          child: ClipRect(
            child: OverflowBox(
              minHeight: scrollUnderHeight,
              maxHeight: scrollUnderHeight,
              alignment: Alignment.bottomLeft,
              child: Container(
                alignment: AlignmentDirectional.bottomStart,
                padding: config.expandedTitlePadding,
                child: expandedTitle,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class LargeScrollUnderFlexibleConfig {
  LargeScrollUnderFlexibleConfig(this.context);

  final BuildContext context;
  late final ThemeData _theme = Theme.of(context);
  late final ColorScheme _colors = _theme.colorScheme;
  late final TextTheme _textTheme = _theme.textTheme;

  static const double collapsedHeight = 64.0;
  static const double expandedHeight = 152.0;

  TextStyle? get collapsedTextStyle =>
      _textTheme.titleLarge?.apply(color: _colors.onSurface);

  TextStyle? get expandedTextStyle =>
      _textTheme.headlineMedium?.apply(color: _colors.onSurface);

  EdgeInsetsGeometry? get collapsedTitlePadding =>
      const EdgeInsets.fromLTRB(48 + 16, 0, 16, 0);

  EdgeInsetsGeometry? get collapsedCenteredTitlePadding =>
      const EdgeInsets.fromLTRB(16, 0, 16, 0);

  EdgeInsetsGeometry? get expandedTitlePadding =>
      const EdgeInsets.fromLTRB(16, 0, 16, 28);
}

class CustomCheckedPopupMenuItem<T> extends StatelessWidget {
  final T value;
  final bool checked;
  final VoidCallback onTap;
  final Widget child;
  final EdgeInsets? padding;

  const CustomCheckedPopupMenuItem({
    Key? key,
    required this.value,
    this.checked = false,
    required this.onTap,
    required this.child,
    required this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuItem(
      padding: padding,
      child: ListTile(
        onTap: () {
          onTap();
        },
        leading: AnimatedOpacity(
          opacity: checked ? 1.0 : 0.0,
          curve: Curves.easeInOut,
          duration: Theme.of(context).extension<AnimationDuration>()?.fast ??
              Duration.zero,
          child: Icon(Icons.done),
        ),
        title: child,
      ),
    );
  }
}
