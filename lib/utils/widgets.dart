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

import 'dart:io';
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:harmonoid/utils/dimensions.dart';
import 'package:provider/provider.dart';
import 'package:flutter/rendering.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/interface/changenotifiers.dart';
import 'package:share_plus/share_plus.dart';
import 'package:harmonoid/core/configuration.dart';

class FractionallyScaledWidget extends StatelessWidget {
  final Widget child;
  const FractionallyScaledWidget({Key? key, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (configuration.enable125Scaling!)
      return FractionallySizedBox(
        heightFactor: 0.8,
        widthFactor: 0.8,
        child: Transform.scale(
          scale: 1 / 0.8,
          child: this.child,
        ),
      );
    return this.child;
  }
}

class CustomListView extends StatelessWidget {
  final ScrollController controller = ScrollController();
  final int velocity = 20;
  final List<Widget> children;
  final Axis? scrollDirection;
  final bool? shrinkWrap;
  final EdgeInsets? padding;

  CustomListView(
      {required this.children,
      this.scrollDirection,
      this.shrinkWrap,
      this.padding}) {
    if (Platform.isWindows) {
      controller.addListener(
        () {
          var scrollDirection = controller.position.userScrollDirection;
          if (scrollDirection != ScrollDirection.idle) {
            var scrollEnd = controller.offset +
                (scrollDirection == ScrollDirection.reverse
                    ? velocity
                    : -velocity);
            scrollEnd = math.min(controller.position.maxScrollExtent,
                math.max(controller.position.minScrollExtent, scrollEnd));
            controller.jumpTo(scrollEnd);
          }
        },
      );
    }
    if (kHorizontalBreakPoint >
        MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
            .size
            .width
            .normalized) {
      controller.addListener(
        () {
          var scrollDirection = controller.position.userScrollDirection;
          if (!nowPlayingBar.maximized) {
            if (scrollDirection != ScrollDirection.forward) {
              nowPlayingBar.height = 0.0;
            }
            if (scrollDirection != ScrollDirection.reverse) {
              if (nowPlaying.tracks.isNotEmpty) nowPlayingBar.height = 72.0;
            }
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: this.padding ?? EdgeInsets.zero,
      controller: this.controller,
      scrollDirection: this.scrollDirection ?? Axis.vertical,
      shrinkWrap: this.shrinkWrap ?? false,
      children: this.children,
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
        this.scale = 1.05;
      }),
      onExit: (e) => setState(() {
        this.scale = 1.00;
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
            height: 48,
            padding: EdgeInsets.fromLTRB(16.0, 0, 0, 0),
            child: Text(
              text!,
              style: Theme.of(context)
                  .textTheme
                  .subtitle1
                  ?.copyWith(fontSize: 16.0),
            ),
          )
        : Container();
  }
}

class NavigatorPopButton extends StatelessWidget {
  final void Function()? onTap;
  NavigatorPopButton({Key? key, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).pop();
            onTap?.call();
          },
          borderRadius: BorderRadius.circular(20.0),
          child: Container(
            height: 40.0,
            width: 40.0,
            child: Icon(
              Icons.arrow_back,
              size: 20.0,
            ),
          ),
        ),
      ),
    );
  }
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
    return Consumer<CollectionRefreshController>(
      builder: (context, refresh, _) => refresh.progress == refresh.total
          ? FloatingActionButton(
              elevation: 8.0,
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: TweenAnimationBuilder(
                child: Icon(
                  Icons.refresh,
                  color: Colors.white,
                ),
                tween: this.tween,
                duration: Duration(milliseconds: 800),
                builder: (_, dynamic value, child) => Transform.rotate(
                  alignment: Alignment.center,
                  angle: value,
                  child: child,
                ),
              ),
              onPressed: () {
                if (this.lock) return;
                this.setState(() {
                  this.lock = true;
                });
                this.tween = Tween<double>(begin: 0, end: this.turns);
                Provider.of<Collection>(context, listen: false).refresh(
                    onProgress: (progress, total, isCompleted) {
                  Provider.of<CollectionRefreshController>(context,
                          listen: false)
                      .set(progress, total);
                  if (isCompleted) {
                    this.setState(() {
                      this.lock = false;
                    });
                  }
                });
              },
            )
          : Container(),
    );
  }
}

class FadeFutureBuilder extends StatefulWidget {
  final Future<Object> Function() future;
  final Widget Function(BuildContext context) initialWidgetBuilder;
  final Widget Function(BuildContext context, Object? object)
      finalWidgetBuilder;
  final Widget Function(BuildContext context, Object object) errorWidgetBuilder;
  final Duration transitionDuration;

  const FadeFutureBuilder({
    Key? key,
    required this.future,
    required this.initialWidgetBuilder,
    required this.finalWidgetBuilder,
    required this.errorWidgetBuilder,
    required this.transitionDuration,
  }) : super(key: key);
  FadeFutureBuilderState createState() => FadeFutureBuilderState();
}

class FadeFutureBuilderState extends State<FadeFutureBuilder>
    with SingleTickerProviderStateMixin {
  bool _init = true;
  Widget _currentWidget = Container();
  late AnimationController _widgetOpacityController;
  late Animation<double> _widgetOpacity;
  Object? _futureResolve;

  @override
  void initState() {
    super.initState();
    this._currentWidget = widget.initialWidgetBuilder(context);
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if (this._init) {
      this._currentWidget = widget.initialWidgetBuilder(context);
      this._widgetOpacityController = new AnimationController(
        vsync: this,
        duration: widget.transitionDuration,
        reverseDuration: widget.transitionDuration,
      );
      this._widgetOpacity = new Tween<double>(
        begin: 1.0,
        end: 0.0,
      ).animate(new CurvedAnimation(
        parent: this._widgetOpacityController,
        curve: Curves.easeInOutCubic,
        reverseCurve: Curves.easeInOutCubic,
      ));
      try {
        this._futureResolve = await widget.future();
        this._widgetOpacityController.forward();
        Future.delayed(widget.transitionDuration, () {
          this.setState(() {
            this._currentWidget =
                widget.finalWidgetBuilder(context, this._futureResolve);
          });
          this._widgetOpacityController.reverse();
        });
      } catch (exception) {
        this._widgetOpacityController.forward();
        Future.delayed(widget.transitionDuration, () {
          this.setState(() {
            this._currentWidget = widget.errorWidgetBuilder(context, exception);
          });
          this._widgetOpacityController.reverse();
        });
      }
      this._init = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FadeTransition(
        opacity: this._widgetOpacity,
        child: this._currentWidget,
      ),
    );
  }
}

class ExceptionWidget extends StatelessWidget {
  final EdgeInsets margin;
  final double? height;
  final double? width;
  final Icon? icon;
  final String? title;
  final String? subtitle;

  const ExceptionWidget({
    Key? key,
    this.icon,
    required this.margin,
    this.height,
    this.width,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: this.width,
      height: this.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 4.0,
            ),
            width: this.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  this.title!,
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 16.0,
                  ),
                  textAlign: TextAlign.start,
                ),
                Divider(
                  color: Colors.transparent,
                  height: 4.0,
                ),
                Text(
                  this.subtitle!,
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withOpacity(0.8)
                        : Colors.black.withOpacity(0.8),
                    fontSize: 14.0,
                  ),
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FakeLinearProgressIndicator extends StatelessWidget {
  final String label;
  final Duration duration;
  final double? width;
  final EdgeInsets? margin;

  FakeLinearProgressIndicator({
    Key? key,
    required this.label,
    required this.duration,
    this.width,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: this.duration,
      child: Text(this.label),
      curve: Curves.linear,
      builder: (BuildContext context, double value, Widget? child) => Center(
        child: Container(
          margin: this.margin ?? EdgeInsets.zero,
          alignment: Alignment.center,
          width: this.width ?? 148.0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                this.label,
                style: Theme.of(context).textTheme.headline4,
              ),
              Divider(
                height: 12.0,
                color: Colors.transparent,
              ),
              LinearProgressIndicator(value: value),
            ],
          ),
        ),
      ),
    );
  }
}

class ClosedTile extends StatelessWidget {
  final String? title;
  final String? subtitle;
  const ClosedTile(
      {Key? key,
      required this.open,
      required this.title,
      required this.subtitle})
      : super(key: key);

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
          this.title!,
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 24.0,
          ),
        ),
        subtitle: Text(
          this.subtitle!,
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

    return InkWell(
      onTap: widget.enabled ? showButtonMenu : null,
      borderRadius: BorderRadius.circular(20.0),
      child: Container(
        height: 40.0,
        width: 40.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: widget.icon ??
            Icon(
              Icons.more_vert,
              size: 20.0,
              color: Colors.black,
            ),
      ),
    );
  }
}

class WindowTitleBar extends StatelessWidget {
  const WindowTitleBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid || Platform.isIOS)
      return Container(
        height: MediaQuery.of(context).padding.top,
        color: Theme.of(context).appBarTheme.backgroundColor,
      );
    return Platform.isWindows
        ? Container(
            width: MediaQuery.of(context).size.width.normalized,
            height: kTitleBarHeight,
            color: Theme.of(context).appBarTheme.backgroundColor,
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
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                      fontSize: 12.0,
                    ),
                  ),
                  Expanded(
                    child: Container(),
                  ),
                  MinimizeWindowButton(
                    colors: WindowButtonColors(
                      iconNormal:
                          Theme.of(context).brightness == Brightness.light
                              ? Colors.black
                              : Colors.white,
                      iconMouseDown:
                          Theme.of(context).brightness == Brightness.light
                              ? Colors.black
                              : Colors.white,
                      iconMouseOver:
                          Theme.of(context).brightness == Brightness.light
                              ? Colors.black
                              : Colors.white,
                      normal: Colors.transparent,
                      mouseOver:
                          Theme.of(context).brightness == Brightness.light
                              ? Colors.black.withOpacity(0.04)
                              : Colors.white.withOpacity(0.04),
                      mouseDown:
                          Theme.of(context).brightness == Brightness.light
                              ? Colors.black.withOpacity(0.08)
                              : Colors.white.withOpacity(0.08),
                    ),
                  ),
                  MaximizeWindowButton(
                    colors: WindowButtonColors(
                      iconNormal:
                          Theme.of(context).brightness == Brightness.light
                              ? Colors.black
                              : Colors.white,
                      iconMouseDown:
                          Theme.of(context).brightness == Brightness.light
                              ? Colors.black
                              : Colors.white,
                      iconMouseOver:
                          Theme.of(context).brightness == Brightness.light
                              ? Colors.black
                              : Colors.white,
                      normal: Colors.transparent,
                      mouseOver:
                          Theme.of(context).brightness == Brightness.light
                              ? Colors.black.withOpacity(0.04)
                              : Colors.white.withOpacity(0.04),
                      mouseDown:
                          Theme.of(context).brightness == Brightness.light
                              ? Colors.black.withOpacity(0.08)
                              : Colors.white.withOpacity(0.08),
                    ),
                  ),
                  CloseWindowButton(
                    onPressed: () {
                      if (Platform.isWindows) player.dispose();
                      appWindow.close();
                    },
                    colors: WindowButtonColors(
                      iconNormal:
                          Theme.of(context).brightness == Brightness.light
                              ? Colors.black
                              : Colors.white,
                      iconMouseDown:
                          Theme.of(context).brightness == Brightness.light
                              ? Colors.black
                              : Colors.white,
                      iconMouseOver:
                          Theme.of(context).brightness == Brightness.light
                              ? Colors.black
                              : Colors.white,
                      normal: Colors.transparent,
                      mouseOver:
                          Theme.of(context).brightness == Brightness.light
                              ? Colors.black.withOpacity(0.04)
                              : Colors.white.withOpacity(0.04),
                      mouseDown:
                          Theme.of(context).brightness == Brightness.light
                              ? Colors.black.withOpacity(0.08)
                              : Colors.white.withOpacity(0.08),
                    ),
                  ),
                ],
              ),
            ),
          )
        : Container();
  }
}

class CollectionTrackContextMenu extends StatelessWidget {
  final Track track;
  const CollectionTrackContextMenu({
    Key? key,
    required this.track,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<Collection>(
      builder: (context, collection, _) => ContextMenuButton(
        elevation: 4.0,
        onSelected: (index) {
          switch (index) {
            case 0:
              showDialog(
                context: context,
                builder: (subContext) => FractionallyScaledWidget(
                  child: AlertDialog(
                    backgroundColor:
                        Theme.of(context).appBarTheme.backgroundColor,
                    title: Text(
                      language.COLLECTION_ALBUM_TRACK_DELETE_DIALOG_HEADER,
                      style: Theme.of(subContext).textTheme.headline1,
                    ),
                    content: Text(
                      language.COLLECTION_ALBUM_TRACK_DELETE_DIALOG_BODY,
                      style: Theme.of(subContext).textTheme.headline3,
                    ),
                    actions: [
                      MaterialButton(
                        textColor: Theme.of(context).primaryColor,
                        onPressed: () async {
                          await collection.delete(track);
                          Navigator.of(subContext).pop();
                        },
                        child: Text(language.YES),
                      ),
                      MaterialButton(
                        textColor: Theme.of(context).primaryColor,
                        onPressed: Navigator.of(subContext).pop,
                        child: Text(language.NO),
                      ),
                    ],
                  ),
                ),
              );
              break;
            case 1:
              Share.shareFiles(
                [track.filePath!],
                subject:
                    '${track.trackName} • ${track.albumName}. Shared using Harmonoid!',
              );
              break;
            case 2:
              showDialog(
                context: context,
                builder: (subContext) => FractionallyScaledWidget(
                  child: AlertDialog(
                    backgroundColor:
                        Theme.of(context).appBarTheme.backgroundColor,
                    contentPadding: EdgeInsets.zero,
                    actionsPadding: EdgeInsets.zero,
                    title: Text(
                      language.PLAYLIST_ADD_DIALOG_TITLE,
                      style: Theme.of(subContext).textTheme.headline1,
                    ),
                    content: Container(
                      height: 280,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(24, 8, 0, 16),
                            child: Text(
                              language.PLAYLIST_ADD_DIALOG_BODY,
                              style: Theme.of(subContext).textTheme.headline3,
                            ),
                          ),
                          Container(
                            height: 236,
                            width: 280,
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: collection.playlists.length,
                              itemBuilder: (context, playlistIndex) {
                                return ListTile(
                                  title: Text(
                                    collection
                                        .playlists[playlistIndex].playlistName!,
                                    style:
                                        Theme.of(context).textTheme.headline2,
                                  ),
                                  leading: Icon(
                                    Icons.queue_music,
                                    size: Theme.of(context).iconTheme.size,
                                    color: Theme.of(context).iconTheme.color,
                                  ),
                                  onTap: () async {
                                    await collection.playlistAddTrack(
                                      collection.playlists[playlistIndex],
                                      track,
                                    );
                                    Navigator.of(subContext).pop();
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      MaterialButton(
                        textColor: Theme.of(context).primaryColor,
                        onPressed: Navigator.of(subContext).pop,
                        child: Text(language.CANCEL),
                      ),
                    ],
                  ),
                ),
              );
              break;
            case 3:
              Playback.add(
                [
                  track,
                ],
              );
              break;
          }
        },
        tooltip: language.OPTIONS,
        itemBuilder: (_) => <PopupMenuEntry>[
          PopupMenuItem(
            padding: EdgeInsets.zero,
            value: 0,
            child: ListTile(
              leading: Icon(FluentIcons.delete_16_regular),
              title: Text(
                language.DELETE,
                style: Theme.of(context).textTheme.headline4,
              ),
            ),
          ),
          PopupMenuItem(
            padding: EdgeInsets.zero,
            value: 1,
            child: ListTile(
              leading: Icon(FluentIcons.share_16_regular),
              title: Text(
                language.SHARE,
                style: Theme.of(context).textTheme.headline4,
              ),
            ),
          ),
          PopupMenuItem(
            padding: EdgeInsets.zero,
            value: 2,
            child: ListTile(
              leading: Icon(FluentIcons.list_16_regular),
              title: Text(
                language.ADD_TO_PLAYLIST,
                style: Theme.of(context).textTheme.headline4,
              ),
            ),
          ),
          PopupMenuItem(
            padding: EdgeInsets.zero,
            value: 3,
            child: ListTile(
              leading: Icon(FluentIcons.music_note_2_16_regular),
              title: Text(
                language.ADD_TO_NOW_PLAYING,
                style: Theme.of(context).textTheme.headline4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomScrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

extension ScalingExtension on double {
  double get normalized {
    return this * (configuration.enable125Scaling! ? 0.8 : 1.0);
  }
}
