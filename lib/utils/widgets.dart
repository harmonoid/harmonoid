/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'dart:io';
import 'dart:ui';
import 'dart:math';
// ignore: unnecessary_import
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart'
    hide ReorderableDragStartListener, Intent;
import 'package:flutter/foundation.dart';
import 'package:animations/animations.dart';
import 'package:provider/provider.dart';
import 'package:flutter/rendering.dart';
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
import 'package:harmonoid/state/collection_refresh.dart';
import 'package:harmonoid/state/mobile_now_playing_controller.dart';
import 'package:harmonoid/interface/settings/settings.dart';
import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/web/web.dart';

class CustomListView extends StatelessWidget {
  late final ScrollController controller;
  final double? cacheExtent;
  final int velocity = 40;
  final List<Widget> children;
  final Axis? scrollDirection;
  final bool? shrinkWrap;
  final EdgeInsets? padding;
  final double? itemExtent;

  CustomListView({
    ScrollController? controller,
    required this.children,
    this.scrollDirection,
    this.shrinkWrap,
    this.padding,
    this.itemExtent,
    this.cacheExtent,
  }) {
    if (controller != null) {
      this.controller = controller;
    } else {
      this.controller = ScrollController();
    }
    if (Platform.isWindows) {
      this.controller.addListener(
        () {
          final scrollDirection = this.controller.position.userScrollDirection;
          if (scrollDirection != ScrollDirection.idle) {
            var scrollEnd = this.controller.offset +
                (scrollDirection == ScrollDirection.reverse
                    ? velocity
                    : -velocity);
            scrollEnd = math.min(this.controller.position.maxScrollExtent,
                math.max(this.controller.position.minScrollExtent, scrollEnd));
            this.controller.jumpTo(scrollEnd);
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      cacheExtent: cacheExtent,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
  late final ScrollController controller;
  final int velocity = 40;
  final int itemCount;
  final List<double> itemExtents;
  final Widget Function(BuildContext, int) itemBuilder;
  final Axis? scrollDirection;
  final bool? shrinkWrap;
  final EdgeInsets? padding;

  CustomListViewBuilder({
    ScrollController? controller,
    required this.itemCount,
    required this.itemExtents,
    required this.itemBuilder,
    this.scrollDirection,
    this.shrinkWrap,
    this.padding,
  }) {
    if (controller != null) {
      this.controller = controller;
    } else {
      this.controller = ScrollController();
    }
    if (Platform.isWindows) {
      this.controller.addListener(
        () {
          final scrollDirection = this.controller.position.userScrollDirection;
          if (scrollDirection != ScrollDirection.idle) {
            var scrollEnd = this.controller.offset +
                (scrollDirection == ScrollDirection.reverse
                    ? velocity
                    : -velocity);
            scrollEnd = math.min(this.controller.position.maxScrollExtent,
                math.max(this.controller.position.minScrollExtent, scrollEnd));
            this.controller.jumpTo(scrollEnd);
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return KnownExtentsListView.builder(
      controller: controller,
      itemExtents: itemExtents,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      padding: padding,
    );
  }
}

class PickerButton extends StatefulWidget {
  final String label;
  final int selected;
  final void Function(dynamic) onSelected;
  final List<PopupMenuItem> items;
  PickerButton({
    Key? key,
    required this.label,
    required this.selected,
    required this.onSelected,
    required this.items,
  }) : super(key: key);

  @override
  State<PickerButton> createState() => _PickerButtonState();
}

class _PickerButtonState extends State<PickerButton> {
  final key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        final position = RelativeRect.fromRect(
          Offset(
                key.globalPaintBounds!.left,
                key.globalPaintBounds!.top + 40.0,
              ) &
              Size(228.0, 320.0),
          Rect.fromLTWH(
            0,
            0,
            MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height,
          ),
        );
        showMenu(
          context: context,
          position: position,
          items: widget.items,
        ).then((value) {
          widget.onSelected(value);
        });
      },
      child: Container(
        key: key,
        height: 36.0,
        padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
        alignment: Alignment.centerLeft,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              widget.label + ':',
              style: Theme.of(context).textTheme.headline4,
            ),
            const SizedBox(width: 4.0),
            Text(
              (widget.items[widget.selected].child as Text).data!,
              style: Theme.of(context).textTheme.headline4?.copyWith(
                    color: Theme.of(context).primaryColor,
                  ),
            ),
          ],
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
                  style: Theme.of(context).textTheme.overline?.copyWith(
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
              color: color,
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
                                      ? Colors.white
                                      : Colors.black
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
  final double turns = 2 * math.pi;
  late Tween<double> tween;

  @override
  void initState() {
    super.initState();
    this.tween = Tween<double>(begin: 0, end: this.turns);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CollectionRefresh>(
      builder: (context, refresh, _) => refresh.progress == refresh.total
          ? FloatingActionButton(
              elevation: 8.0,
              heroTag: 'collection_refresh_button',
              backgroundColor:
                  widget.color ?? Theme.of(context).colorScheme.secondary,
              child: TweenAnimationBuilder(
                child: Icon(
                  Icons.refresh,
                  color: widget.color?.isDark ?? true
                      ? Colors.white
                      : Colors.black87,
                ),
                tween: tween,
                duration: Duration(milliseconds: 800),
                builder: (_, dynamic value, child) => Transform.rotate(
                  alignment: Alignment.center,
                  angle: value,
                  child: child,
                ),
              ),
              onPressed: () {
                if (lock) return;
                setState(() {
                  lock = true;
                });
                tween = Tween<double>(begin: 0, end: turns);
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
            scale: title == Language.instance.NO_COLLECTION_TITLE ? 1.4 : 1.2,
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
              height: 196.0,
              width: 196.0,
              filterQuality: FilterQuality.high,
              fit: BoxFit.contain,
            ),
          ),
          Text(
            title!,
            style:
                Theme.of(context).textTheme.headline1?.copyWith(fontSize: 20.0),
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
            MaterialButton(
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
  final Color? color;
  const DesktopTitleBar({Key? key, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid || Platform.isIOS)
      return Container(
        height: MediaQuery.of(context).padding.top,
        color: color ?? Theme.of(context).appBarTheme.backgroundColor,
      );
    return Platform.isWindows
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
                icon: Icon(Icons.play_circle),
                label: Language.instance.WEB.split(' ').first,
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
          trackHeight: 2.0,
          trackShape: CustomTrackShape(),
          thumbShape: RoundSliderThumbShape(
            enabledThumbRadius: 6.0,
            pressedElevation: 4.0,
            elevation: 2.0,
          ),
          overlayShape: RoundSliderOverlayShape(overlayRadius: 12.0),
          overlayColor:
              (color ?? Theme.of(context).primaryColor).withOpacity(0.4),
          thumbColor: (color ?? Theme.of(context).primaryColor),
          activeTrackColor: (color ?? Theme.of(context).primaryColor),
          inactiveTrackColor: inferSliderInactiveTrackColor
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
    if (isDesktop) {
      controller.addListener(() {
        setState(() {});
      });
    }
  }

  @override
  void didChangeDependencies() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isDesktop) {
        setState(() {});
      }
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
          if (extentAfter != 0 && isDesktop)
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
              right: 32.0,
            ),
          if (extentBefore != 0 && isDesktop)
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
              left: 32.0,
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
        elevation: 4.0,
        onSelected: (value) async {
          if (value is CollectionSort) {
            Provider.of<Collection>(context, listen: false).sort(type: value);
            await Configuration.instance.save(
              collectionSortType: value,
            );
          } else if (value is CollectionOrder) {
            Provider.of<Collection>(context, listen: false).order(type: value);
            await Configuration.instance.save(
              collectionOrderType: value,
            );
          }
        },
        itemBuilder: (context) => [
          CheckedPopupMenuItem(
            padding: EdgeInsets.zero,
            checked:
                Collection.instance.collectionSortType == CollectionSort.aToZ ||
                    (tab == 1 &&
                        Collection.instance.collectionSortType ==
                            CollectionSort.artist) ||
                    (tab == 2 &&
                        Collection.instance.collectionSortType !=
                            CollectionSort.aToZ),
            value: CollectionSort.aToZ,
            child: Text(
              Language.instance.A_TO_Z,
              style: Theme.of(context).textTheme.headline4,
            ),
          ),
          if (tab == 0 || tab == 1 || tab == 4)
            CheckedPopupMenuItem(
              padding: EdgeInsets.zero,
              checked: Collection.instance.collectionSortType ==
                  CollectionSort.dateAdded,
              value: CollectionSort.dateAdded,
              child: Text(
                Language.instance.DATE_ADDED,
                style: Theme.of(context).textTheme.headline4,
              ),
            ),
          if (tab == 0 || tab == 1 || tab == 4)
            CheckedPopupMenuItem(
              padding: EdgeInsets.zero,
              checked:
                  Collection.instance.collectionSortType == CollectionSort.year,
              value: CollectionSort.year,
              child: Text(
                Language.instance.YEAR,
                style: Theme.of(context).textTheme.headline4,
              ),
            ),
          if (tab == 0)
            CheckedPopupMenuItem(
              padding: EdgeInsets.zero,
              checked: Collection.instance.collectionSortType ==
                  CollectionSort.artist,
              value: CollectionSort.artist,
              child: Text(
                Language.instance.ARTIST_SINGLE,
                style: Theme.of(context).textTheme.headline4,
              ),
            ),
          PopupMenuDivider(),
          CheckedPopupMenuItem(
            padding: EdgeInsets.zero,
            checked: Collection.instance.collectionOrderType ==
                CollectionOrder.ascending,
            value: CollectionOrder.ascending,
            child: Text(
              Language.instance.ASCENDING,
              style: Theme.of(context).textTheme.headline4,
            ),
          ),
          CheckedPopupMenuItem(
            padding: EdgeInsets.zero,
            checked: Collection.instance.collectionOrderType ==
                CollectionOrder.descending,
            value: CollectionOrder.descending,
            child: Text(
              Language.instance.DESCENDING,
              style: Theme.of(context).textTheme.headline4,
            ),
          ),
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
    if (isDesktop) {
      return SwitchListTile(
        value: value,
        title: Text(
          subtitle,
          style: Theme.of(context).textTheme.headline4,
        ),
        onChanged: (value) {
          onChanged.call(value);
        },
      );
    } else {
      return InkWell(
        onTap: () {
          onChanged.call(!value);
        },
        child: Container(
          height: 88.0,
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      subtitle,
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
              Switch(
                value: value,
                onChanged: (value) {
                  onChanged.call(value);
                },
              ),
            ],
          ),
        ),
      );
    }
  }
}

class CorrectedListTile extends StatelessWidget {
  final void Function()? onTap;
  final IconData iconData;
  final String title;
  final String? subtitle;
  final double? height;
  CorrectedListTile({
    Key? key,
    required this.iconData,
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
    return AnimatedOpacity(
      opacity: [1, 2, 3].contains(index) ? 1.0 : 0.0,
      duration: Duration(milliseconds: 50),
      child: CircularButton(
        icon: const Icon(Icons.sort_by_alpha),
        onPressed: () async {
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
          final value = await showMenu<dynamic>(
            context: context,
            position: position,
            elevation: 4.0,
            items: [
              if (index == 1 || index == 2 || index == 3)
                CheckedPopupMenuItem(
                  padding: EdgeInsets.zero,
                  checked: Collection.instance.collectionSortType ==
                          CollectionSort.aToZ ||
                      index == 3,
                  value: CollectionSort.aToZ,
                  child: Text(
                    Language.instance.A_TO_Z,
                  ),
                ),
              if (index == 1 || index == 2)
                CheckedPopupMenuItem(
                  padding: EdgeInsets.zero,
                  checked: Collection.instance.collectionSortType ==
                      CollectionSort.dateAdded,
                  value: CollectionSort.dateAdded,
                  child: Text(
                    Language.instance.DATE_ADDED,
                  ),
                ),
              if (index == 1 || index == 2)
                CheckedPopupMenuItem(
                  padding: EdgeInsets.zero,
                  checked: Collection.instance.collectionSortType ==
                      CollectionSort.year,
                  value: CollectionSort.year,
                  child: Text(
                    Language.instance.YEAR,
                  ),
                ),
              PopupMenuDivider(),
              CheckedPopupMenuItem(
                padding: EdgeInsets.zero,
                checked: Collection.instance.collectionOrderType ==
                    CollectionOrder.ascending,
                value: CollectionOrder.ascending,
                child: Text(
                  Language.instance.ASCENDING,
                ),
              ),
              CheckedPopupMenuItem(
                padding: EdgeInsets.zero,
                checked: Collection.instance.collectionOrderType ==
                    CollectionOrder.descending,
                value: CollectionOrder.descending,
                child: Text(
                  Language.instance.DESCENDING,
                ),
              ),
            ],
          );
          if (value is CollectionSort) {
            Provider.of<Collection>(context, listen: false).sort(type: value);
            await Configuration.instance.save(
              collectionSortType: value,
            );
          } else if (value is CollectionOrder) {
            Provider.of<Collection>(context, listen: false).order(type: value);
            await Configuration.instance.save(
              collectionOrderType: value,
            );
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
    return Tooltip(
      message: Language.instance.PLAY_INTERNET,
      child: ContextMenuButton<int>(
        padding: EdgeInsets.zero,
        offset: Offset.fromDirection(pi / 2, 64.0),
        icon: Icon(
          Icons.public,
          size: 20.0,
        ),
        elevation: 4.0,
        onSelected: (value) async {
          switch (value) {
            case 0:
              {
                final controller = TextEditingController();
                await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    contentPadding:
                        const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          child: Text(
                            Language.instance.PLAY_URL,
                            style: Theme.of(context).textTheme.headline1,
                            textAlign: TextAlign.start,
                          ),
                          padding: EdgeInsets.only(
                            bottom: 16.0,
                            left: 4.0,
                          ),
                        ),
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
                            child: TextField(
                              autofocus: true,
                              controller: controller,
                              cursorWidth: 1.0,
                              onSubmitted: (String value) async {
                                if (value.isNotEmpty) {
                                  FocusScope.of(context).unfocus();
                                  await Intent.instance
                                      .playUri(Uri.parse(value));
                                }
                              },
                              cursorColor: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Colors.black
                                  : Colors.white,
                              textAlignVertical: TextAlignVertical.bottom,
                              style: Theme.of(context).textTheme.headline4,
                              decoration: inputDecoration(
                                context,
                                Language.instance.PLAY_URL_SUBTITLE,
                                trailingIcon: Icon(
                                  Icons.add,
                                  size: 20.0,
                                  color: Theme.of(context).iconTheme.color,
                                ),
                                trailingIconOnPressed: () async {
                                  if (controller.text.isNotEmpty) {
                                    FocusScope.of(context).unfocus();
                                    await Intent.instance
                                        .playUri(Uri.parse(controller.text));
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      MaterialButton(
                        child: Text(
                          Language.instance.PLAY.toUpperCase(),
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        onPressed: () async {
                          if (controller.text.isNotEmpty) {
                            await Intent.instance
                                .playUri(Uri.parse(controller.text));
                          }
                        },
                      ),
                      MaterialButton(
                        child: Text(
                          Language.instance.CANCEL.toUpperCase(),
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        onPressed: Navigator.of(context).maybePop,
                      ),
                    ],
                  ),
                );
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
              leading: Icon(Icons.link),
              title: Text(
                Language.instance.PLAY_URL,
                style: Theme.of(context).textTheme.headline4,
              ),
            ),
          ),
          PopupMenuItem(
            value: 1,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.play_circle),
              title: Text(
                Language.instance.WEB,
                style: Theme.of(context).textTheme.headline4,
              ),
            ),
          ),
        ],
      ),
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
  @override
  Widget build(BuildContext context) {
    return Consumer<Collection>(
      builder: (context, collection, _) {
        final missingDirectories = collection.collectionDirectories
            .where((element) => !element.existsSync_());
        return AlertDialog(
          contentPadding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 4.0),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                child: Text(
                  missingDirectories.isEmpty
                      ? Language.instance.AWESOME
                      : Language.instance.ERROR,
                  style: Theme.of(context).textTheme.headline1,
                  textAlign: TextAlign.start,
                ),
                padding: EdgeInsets.only(
                  bottom: 16.0,
                  left: 4.0,
                ),
              ),
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
                  left: 4.0,
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
                              directory.path
                                  .replaceAll(
                                    '/storage/emulated/0/',
                                    '',
                                  )
                                  .overflow,
                              style: isMobile
                                  ? Theme.of(context).textTheme.subtitle1
                                  : Theme.of(context).textTheme.headline3,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          MaterialButton(
                            padding: EdgeInsets.zero,
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
                                      style:
                                          Theme.of(context).textTheme.headline1,
                                    ),
                                    content: Text(
                                      Language.instance
                                          .INDEXING_ALREADY_GOING_ON_SUBTITLE,
                                      style:
                                          Theme.of(context).textTheme.headline3,
                                    ),
                                    actions: [
                                      MaterialButton(
                                        textColor:
                                            Theme.of(context).primaryColor,
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
                                      style: Theme.of(subContext)
                                          .textTheme
                                          .headline1,
                                    ),
                                    content: Text(
                                      Language.instance
                                          .LAST_COLLECTION_DIRECTORY_REMOVED,
                                      style: Theme.of(subContext)
                                          .textTheme
                                          .headline3,
                                    ),
                                    actions: [
                                      MaterialButton(
                                        textColor:
                                            Theme.of(context).primaryColor,
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
            MaterialButton(
              child: Text(
                Language.instance.DONE.toUpperCase(),
              ),
              onPressed: missingDirectories.isEmpty
                  ? Navigator.of(context).maybePop
                  : null,
              textColor: Theme.of(context).primaryColor,
              disabledTextColor: Theme.of(context).iconTheme.color,
            ),
          ],
        );
      },
    );
  }
}
