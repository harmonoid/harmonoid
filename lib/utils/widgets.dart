/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'dart:io';
import 'dart:math' as math;
import 'dart:math';
import 'package:animations/animations.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide ReorderableDragStartListener;
import 'package:provider/provider.dart';
import 'package:flutter/rendering.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:known_extents_list_view_builder/known_extents_list_view_builder.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/utils/dimensions.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/state/collection_refresh.dart';
import 'package:harmonoid/interface/settings/settings.dart';
import 'package:harmonoid/constants/language.dart';

class CustomListView extends StatelessWidget {
  late final ScrollController controller;
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

  const SubHeader(this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return text != null
        ? Container(
            alignment: Alignment.centerLeft,
            height: 56.0,
            padding: EdgeInsets.fromLTRB(24.0, 0, 0, 0),
            child: Text(
              text!,
              style: Theme.of(context).textTheme.headline1,
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
  final Color? color;
  final Widget? leading;
  final double? height;
  final double? elevation;

  const DesktopAppBar({
    Key? key,
    this.title,
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
  RefreshCollectionButton({Key? key}) : super(key: key);

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
              mini: true,
              elevation: 8.0,
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: TweenAnimationBuilder(
                child: Icon(
                  Icons.refresh,
                  color: Colors.white,
                  size: 20.0,
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
    return isDesktop
        ? Container(
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
                  scale: 1.4,
                  child: Image.memory(
                    {
                      Language.instance.NO_COLLECTION_TITLE:
                          visualAssets.collection,
                      Language.instance.NO_INTERNET_TITLE:
                          visualAssets.collection,
                      Language.instance.COLLECTION_SEARCH_NO_RESULTS_TITLE:
                          visualAssets.searchPage,
                      Language.instance.YOUTUBE_WELCOME_TITLE:
                          visualAssets.searchNotes,
                    }[title]!,
                    height: 196.0,
                    width: 196.0,
                    filterQuality: FilterQuality.high,
                    fit: BoxFit.contain,
                  ),
                ),
                Text(
                  title!,
                  style: Theme.of(context)
                      .textTheme
                      .headline1
                      ?.copyWith(fontSize: 20.0),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 2.0,
                ),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.headline3,
                  textAlign: TextAlign.center,
                ),
                if (title == Language.instance.NO_COLLECTION_TITLE) ...[
                  const SizedBox(
                    height: 8.0,
                  ),
                  MaterialButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
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
          )
        : Center(
            child: Text(
              this.subtitle!,
              style: Theme.of(context).textTheme.headline3,
              textAlign: TextAlign.center,
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
        color: Theme.of(context).dialogBackgroundColor,
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
            child: Row(
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
                  onPressed: () {
                    if (CollectionRefresh.instance.isCompleted) {
                      appWindow.close();
                    } else {
                      CollectionRefresh.instance.addListener(() {
                        if (CollectionRefresh.instance.isCompleted) {
                          appWindow.close();
                        }
                      });
                    }
                  },
                  colors: windowButtonColors(context),
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
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(color: Colors.black45, blurRadius: 8.0),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _index,
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
            icon: Icon(Icons.queue),
            label: Language.instance.PLAYLIST,
            backgroundColor: Theme.of(context).primaryColor,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.music_note),
            label: Language.instance.TRACK,
            backgroundColor: Theme.of(context).primaryColor,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.album),
            label: Language.instance.ALBUM,
            backgroundColor: Theme.of(context).primaryColor,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: Language.instance.ARTIST,
            backgroundColor: Theme.of(context).primaryColor,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.play_circle),
            label: Language.instance.YOUTUBE,
            backgroundColor: Theme.of(context).primaryColor,
          ),
        ],
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
  final VoidCallback onScrolledUp;
  final VoidCallback onScrolledDown;
  final void Function(double) onChanged;

  const ScrollableSlider({
    Key? key,
    required this.min,
    required this.max,
    required this.value,
    required this.onScrolledUp,
    required this.onScrolledDown,
    required this.onChanged,
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
          overlayColor: Theme.of(context).primaryColor.withOpacity(0.4),
          thumbColor: Theme.of(context).primaryColor,
          activeTrackColor: Theme.of(context).primaryColor,
          inactiveTrackColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withOpacity(0.4)
              : Colors.black.withOpacity(0.2),
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
          Icons.sort,
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
                    (tab != 0 &&
                        Collection.instance.collectionSortType ==
                            CollectionSort.artist),
            value: CollectionSort.aToZ,
            child: Text(
              Language.instance.A_TO_Z,
              style: Theme.of(context).textTheme.headline4,
            ),
          ),
          if (tab == 0 || tab == 1)
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
          if (tab == 0 || tab == 1)
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
