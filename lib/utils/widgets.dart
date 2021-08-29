import 'dart:async';
import 'dart:math' as math;
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:harmonoid/interface/changenotifiers.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/core/collection.dart';

List<Widget> tileGridListWidgets({
  required double tileHeight,
  required double tileWidth,
  required String? subHeader,
  required BuildContext context,
  required int widgetCount,
  required Widget Function(BuildContext context, int index) builder,
  required String? leadingSubHeader,
  required Widget leadingWidget,
  required int elementsPerRow,
}) {
  List<Widget> widgets = <Widget>[];
  widgets.addAll([
    SubHeader(leadingSubHeader),
    leadingWidget,
    SubHeader(subHeader),
  ]);
  int rowIndex = 0;
  List<Widget> rowChildren = <Widget>[];
  for (int index = 0; index < widgetCount; index++) {
    rowChildren.add(
      builder(context, index),
    );
    rowIndex++;
    if (rowIndex > elementsPerRow - 1) {
      widgets.add(
        new Container(
          height: tileHeight + 8.0,
          margin: EdgeInsets.only(left: 8, right: 8),
          alignment: Alignment.topCenter,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: rowChildren,
          ),
        ),
      );
      rowIndex = 0;
      rowChildren = <Widget>[];
    }
  }
  if (widgetCount % elementsPerRow != 0) {
    rowChildren = <Widget>[];
    for (int index = widgetCount - (widgetCount % elementsPerRow);
        index < widgetCount;
        index++) {
      rowChildren.add(
        builder(context, index),
      );
    }
    for (int index = 0;
        index < elementsPerRow - (widgetCount % elementsPerRow);
        index++) {
      rowChildren.add(
        Container(
          height: tileHeight,
          width: tileWidth,
        ),
      );
    }
    widgets.add(
      new Container(
        height: tileHeight + 8.0,
        margin: EdgeInsets.only(left: 8, right: 8),
        alignment: Alignment.topCenter,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: rowChildren,
        ),
      ),
    );
  }
  return widgets;
}

class SubHeader extends StatelessWidget {
  final String? text;

  const SubHeader(this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      height: 48,
      padding: EdgeInsets.fromLTRB(16.0, 0, 0, 0),
      child: Text(
        text!,
        style: Theme.of(context).textTheme.subtitle1,
      ),
    );
  }
}

class NavigatorPopButton extends StatelessWidget {
  const NavigatorPopButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: InkWell(
        onTap: Navigator.of(context).pop,
        borderRadius: BorderRadius.all(
          Radius.circular(8.0),
        ),
        child: Container(
          height: 40.0,
          width: 40.0,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withOpacity(0.04)
                : Colors.black.withOpacity(0.04),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Icon(
            FluentIcons.arrow_left_20_filled,
            size: 20.0,
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
  late double turns;
  late Tween<double> tween;

  @override
  void initState() {
    super.initState();
    this.turns = 0;
    this.tween = Tween<double>(begin: 0, end: this.turns);
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Theme.of(context).accentColor,
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
      onPressed: this.lock
          ? () {}
          : () async {
              this.lock = true;
              this.turns += 2 * math.pi;
              this.tween = Tween<double>(begin: 0, end: this.turns);
              Provider.of<Collection>(context, listen: false).refresh(
                  onProgress: (progress, total, isCompleted) {
                Provider.of<CollectionRefresh>(context, listen: false)
                    .set(progress, total);
                this.lock = !isCompleted;
              });
              this.setState(() {});
            },
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
      margin: EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 4.0,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ListTile(
        title: Text(
          this.title!,
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 14.0,
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
    final PopupMenuThemeData popupMenuTheme = PopupMenuTheme.of(context);
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
        elevation: widget.elevation ?? popupMenuTheme.elevation,
        items: items,
        initialValue: widget.initialValue,
        position: position,
        shape: widget.shape ??
            RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(8.0),
              ),
            ),
        color: widget.color ?? popupMenuTheme.color,
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

    return Padding(
      padding: EdgeInsets.all(4.0),
      child: InkWell(
        onTap: widget.enabled ? showButtonMenu : null,
        borderRadius: BorderRadius.all(
          Radius.circular(8.0),
        ),
        child: Container(
          height: 40.0,
          width: 40.0,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withOpacity(0.04)
                : Colors.black.withOpacity(0.04),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: widget.icon ??
              Icon(
                FluentIcons.more_vertical_20_regular,
                size: 20.0,
              ),
        ),
      ),
    );
  }
}

class WindowTitleBar extends StatelessWidget {
  const WindowTitleBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 32.0,
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.white.withOpacity(0.08)
          : Colors.black.withOpacity(0.08),
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
                iconNormal: Theme.of(context).brightness == Brightness.light
                    ? Colors.black
                    : Colors.white,
                iconMouseDown: Theme.of(context).brightness == Brightness.light
                    ? Colors.black
                    : Colors.white,
                iconMouseOver: Theme.of(context).brightness == Brightness.light
                    ? Colors.black
                    : Colors.white,
                normal: Colors.transparent,
                mouseOver: Theme.of(context).brightness == Brightness.light
                    ? Colors.black.withOpacity(0.04)
                    : Colors.white.withOpacity(0.04),
                mouseDown: Theme.of(context).brightness == Brightness.light
                    ? Colors.black.withOpacity(0.08)
                    : Colors.white.withOpacity(0.08),
              ),
            ),
            MaximizeWindowButton(
              colors: WindowButtonColors(
                iconNormal: Theme.of(context).brightness == Brightness.light
                    ? Colors.black
                    : Colors.white,
                iconMouseDown: Theme.of(context).brightness == Brightness.light
                    ? Colors.black
                    : Colors.white,
                iconMouseOver: Theme.of(context).brightness == Brightness.light
                    ? Colors.black
                    : Colors.white,
                normal: Colors.transparent,
                mouseOver: Theme.of(context).brightness == Brightness.light
                    ? Colors.black.withOpacity(0.04)
                    : Colors.white.withOpacity(0.04),
                mouseDown: Theme.of(context).brightness == Brightness.light
                    ? Colors.black.withOpacity(0.08)
                    : Colors.white.withOpacity(0.08),
              ),
            ),
            CloseWindowButton(
              colors: WindowButtonColors(
                iconNormal: Theme.of(context).brightness == Brightness.light
                    ? Colors.black
                    : Colors.white,
                iconMouseDown: Theme.of(context).brightness == Brightness.light
                    ? Colors.black
                    : Colors.white,
                iconMouseOver: Theme.of(context).brightness == Brightness.light
                    ? Colors.black
                    : Colors.white,
                normal: Colors.transparent,
                mouseOver: Theme.of(context).brightness == Brightness.light
                    ? Colors.black.withOpacity(0.04)
                    : Colors.white.withOpacity(0.04),
                mouseDown: Theme.of(context).brightness == Brightness.light
                    ? Colors.black.withOpacity(0.08)
                    : Colors.white.withOpacity(0.08),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
