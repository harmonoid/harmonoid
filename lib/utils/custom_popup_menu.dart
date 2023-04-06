// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart';
import 'package:harmonoid/utils/theme.dart';

const Duration _kMenuDuration = Duration(milliseconds: 300);
const double _kMenuCloseIntervalEnd = 2.0 / 3.0;
const double _kMenuMaxWidth = 5.0 * _kMenuWidthStep;
const double _kMenuMinWidth = 2.0 * _kMenuWidthStep;
const double _kMenuVerticalPadding = 8.0;
const double _kMenuWidthStep = 56.0;
const double _kMenuScreenPadding = 8.0;

class _MenuItem extends SingleChildRenderObjectWidget {
  const _MenuItem({
    required this.onLayout,
    required super.child,
  });

  final ValueChanged<Size> onLayout;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderMenuItem(onLayout);
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant _RenderMenuItem renderObject) {
    renderObject.onLayout = onLayout;
  }
}

class _RenderMenuItem extends RenderShiftedBox {
  _RenderMenuItem(this.onLayout, [RenderBox? child]) : super(child);

  ValueChanged<Size> onLayout;

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    if (child == null) {
      return Size.zero;
    }
    return child!.getDryLayout(constraints);
  }

  @override
  void performLayout() {
    if (child == null) {
      size = Size.zero;
    } else {
      child!.layout(constraints, parentUsesSize: true);
      size = constraints.constrain(child!.size);
      final BoxParentData childParentData = child!.parentData! as BoxParentData;
      childParentData.offset = Offset.zero;
    }
    onLayout(size);
  }
}

class _CustomPopupMenu<T> extends StatelessWidget {
  const _CustomPopupMenu({
    super.key,
    required this.route,
    required this.semanticLabel,
    this.constraints,
    required this.clipBehavior,
  });

  final _CustomPopupMenuRoute<T> route;
  final String? semanticLabel;
  final BoxConstraints? constraints;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final double unit = 1.0 / (route.items.length + 1.5);
    final List<Widget> children = <Widget>[];
    final ThemeData theme = Theme.of(context);
    final PopupMenuThemeData popupMenuTheme = PopupMenuTheme.of(context);
    final PopupMenuThemeData defaults = theme.useMaterial3
        ? _CustomPopupMenuDefaultsM3(context)
        : _CustomPopupMenuDefaultsM2(context);

    for (int i = 0; i < route.items.length; i += 1) {
      final double start = (i + 1) * unit;
      final double end = clampDouble(start + 1.5 * unit, 0.0, 1.0);
      final CurvedAnimation opacity = CurvedAnimation(
        parent: route.animation!,
        curve: Interval(start, end),
      );
      Widget item = route.items[i];
      if (route.initialValue != null &&
          route.items[i].represents(route.initialValue)) {
        item = Container(
          color: Theme.of(context).highlightColor,
          child: item,
        );
      }
      children.add(
        _MenuItem(
          onLayout: (Size size) {
            route.itemSizes[i] = size;
          },
          child: FadeTransition(
            opacity: opacity,
            child: item,
          ),
        ),
      );
    }

    final CurveTween opacity =
        CurveTween(curve: const Interval(0.0, 1.0 / 3.0));
    final CurveTween width = CurveTween(curve: Interval(0.0, unit));
    final CurveTween height =
        CurveTween(curve: Interval(0.0, unit * route.items.length));

    final Widget child = ConstrainedBox(
      constraints: constraints ??
          const BoxConstraints(
            minWidth: _kMenuMinWidth,
            maxWidth: _kMenuMaxWidth,
          ),
      child: IntrinsicWidth(
        stepWidth: _kMenuWidthStep,
        child: Semantics(
          scopesRoute: true,
          namesRoute: true,
          explicitChildNodes: true,
          label: semanticLabel,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              vertical: _kMenuVerticalPadding,
            ),
            child: ListBody(children: children),
          ),
        ),
      ),
    );

    return AnimatedBuilder(
      animation: route.animation!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: opacity.animate(route.animation!),
          child: Material(
            shape: route.shape ?? popupMenuTheme.shape ?? defaults.shape,
            color: route.color ?? popupMenuTheme.color ?? defaults.color,
            clipBehavior: clipBehavior,
            type: MaterialType.card,
            elevation: route.elevation ??
                popupMenuTheme.elevation ??
                defaults.elevation!,
            shadowColor: route.shadowColor ??
                popupMenuTheme.shadowColor ??
                defaults.shadowColor,
            surfaceTintColor: route.surfaceTintColor ??
                popupMenuTheme.surfaceTintColor ??
                defaults.surfaceTintColor,
            child: Align(
              alignment: AlignmentDirectional.topEnd,
              widthFactor: width.evaluate(route.animation!),
              heightFactor: height.evaluate(route.animation!),
              child: child,
            ),
          ),
        );
      },
      child: child,
    );
  }
}

class _CustomPopupMenuRouteLayout extends SingleChildLayoutDelegate {
  _CustomPopupMenuRouteLayout(
    this.position,
    this.itemSizes,
    this.selectedItemIndex,
    this.textDirection,
    this.padding,
    this.avoidBounds,
  );

  final RelativeRect position;

  List<Size?> itemSizes;

  final int? selectedItemIndex;

  final TextDirection textDirection;

  EdgeInsets padding;

  final Set<Rect> avoidBounds;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints.loose(constraints.biggest).deflate(
      const EdgeInsets.all(_kMenuScreenPadding) + padding,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final double buttonHeight = size.height - position.top - position.bottom;
    double y = position.top;
    if (selectedItemIndex != null) {
      double selectedItemOffset = _kMenuVerticalPadding;
      for (int index = 0; index < selectedItemIndex!; index += 1) {
        selectedItemOffset += itemSizes[index]!.height;
      }
      selectedItemOffset += itemSizes[selectedItemIndex!]!.height / 2;
      y = y + buttonHeight / 2.0 - selectedItemOffset;
    }

    double x;
    if (position.left > position.right) {
      x = size.width - position.right - childSize.width;
    } else if (position.left < position.right) {
      x = position.left;
    } else {
      switch (textDirection) {
        case TextDirection.rtl:
          x = size.width - position.right - childSize.width;
          break;
        case TextDirection.ltr:
          x = position.left;
          break;
      }
    }
    final Offset wantedPosition = Offset(x, y);
    final Offset originCenter = position.toRect(Offset.zero & size).center;
    final Iterable<Rect> subScreens =
        DisplayFeatureSubScreen.subScreensInBounds(
            Offset.zero & size, avoidBounds);
    final Rect subScreen = _closestScreen(subScreens, originCenter);
    return _fitInsideScreen(subScreen, childSize, wantedPosition);
  }

  Rect _closestScreen(Iterable<Rect> screens, Offset point) {
    Rect closest = screens.first;
    for (final Rect screen in screens) {
      if ((screen.center - point).distance <
          (closest.center - point).distance) {
        closest = screen;
      }
    }
    return closest;
  }

  Offset _fitInsideScreen(Rect screen, Size childSize, Offset wantedPosition) {
    double x = wantedPosition.dx;
    double y = wantedPosition.dy;
    if (x < screen.left + _kMenuScreenPadding + padding.left) {
      x = screen.left + _kMenuScreenPadding + padding.left;
    } else if (x + childSize.width >
        screen.right - _kMenuScreenPadding - padding.right) {
      x = screen.right - childSize.width - _kMenuScreenPadding - padding.right;
    }
    if (y < screen.top + _kMenuScreenPadding + padding.top) {
      y = _kMenuScreenPadding + padding.top;
    } else if (y + childSize.height >
        screen.bottom - _kMenuScreenPadding - padding.bottom) {
      y = screen.bottom -
          childSize.height -
          _kMenuScreenPadding -
          padding.bottom;
    }

    return Offset(x, y);
  }

  @override
  bool shouldRelayout(_CustomPopupMenuRouteLayout oldDelegate) {
    assert(itemSizes.length == oldDelegate.itemSizes.length);

    return position != oldDelegate.position ||
        selectedItemIndex != oldDelegate.selectedItemIndex ||
        textDirection != oldDelegate.textDirection ||
        !listEquals(itemSizes, oldDelegate.itemSizes) ||
        padding != oldDelegate.padding ||
        !setEquals(avoidBounds, oldDelegate.avoidBounds);
  }
}

class _CustomPopupMenuRoute<T> extends PopupRoute<T> {
  _CustomPopupMenuRoute({
    required this.position,
    required this.items,
    this.initialValue,
    this.elevation,
    this.surfaceTintColor,
    this.shadowColor,
    required this.barrierLabel,
    this.semanticLabel,
    this.shape,
    this.color,
    required this.capturedThemes,
    this.constraints,
    required this.clipBehavior,
    required this.duration,
  }) : itemSizes = List<Size?>.filled(items.length, null);

  final RelativeRect position;
  final List<PopupMenuEntry<T>> items;
  final List<Size?> itemSizes;
  final T? initialValue;
  final double? elevation;
  final Color? surfaceTintColor;
  final Color? shadowColor;
  final String? semanticLabel;
  final ShapeBorder? shape;
  final Color? color;
  final CapturedThemes capturedThemes;
  final BoxConstraints? constraints;
  final Clip clipBehavior;
  final Duration duration;

  @override
  Animation<double> createAnimation() {
    return CurvedAnimation(
      parent: super.createAnimation(),
      curve: Curves.linear,
      reverseCurve: const Interval(0.0, _kMenuCloseIntervalEnd),
    );
  }

  @override
  Duration get transitionDuration => duration;

  @override
  bool get barrierDismissible => true;

  @override
  Color? get barrierColor => null;

  @override
  final String barrierLabel;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    int? selectedItemIndex;
    if (initialValue != null) {
      for (int index = 0;
          selectedItemIndex == null && index < items.length;
          index += 1) {
        if (items[index].represents(initialValue)) {
          selectedItemIndex = index;
        }
      }
    }

    final Widget menu = _CustomPopupMenu<T>(
      route: this,
      semanticLabel: semanticLabel,
      constraints: constraints,
      clipBehavior: clipBehavior,
    );
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      removeBottom: true,
      removeLeft: true,
      removeRight: true,
      child: Builder(
        builder: (BuildContext context) {
          return CustomSingleChildLayout(
            delegate: _CustomPopupMenuRouteLayout(
              position,
              itemSizes,
              selectedItemIndex,
              Directionality.of(context),
              mediaQuery.padding,
              _avoidBounds(mediaQuery),
            ),
            child: capturedThemes.wrap(menu),
          );
        },
      ),
    );
  }

  Set<Rect> _avoidBounds(MediaQueryData mediaQuery) {
    return DisplayFeatureSubScreen.avoidBounds(mediaQuery).toSet();
  }
}

Future<T?> showCustomMenu<T>({
  required BuildContext context,
  required RelativeRect position,
  required List<PopupMenuEntry<T>> items,
  T? initialValue,
  double? elevation,
  Color? shadowColor,
  Color? surfaceTintColor,
  String? semanticLabel,
  ShapeBorder? shape,
  Color? color,
  bool useRootNavigator = false,
  BoxConstraints? constraints,
  Clip clipBehavior = Clip.none,
}) {
  assert(items.isNotEmpty);
  assert(debugCheckHasMaterialLocalizations(context));

  switch (Theme.of(context).platform) {
    case TargetPlatform.iOS:
    case TargetPlatform.macOS:
      break;
    case TargetPlatform.android:
    case TargetPlatform.fuchsia:
    case TargetPlatform.linux:
    case TargetPlatform.windows:
      semanticLabel ??= MaterialLocalizations.of(context).popupMenuLabel;
  }

  final NavigatorState navigator =
      Navigator.of(context, rootNavigator: useRootNavigator);
  return navigator.push(
    _CustomPopupMenuRoute<T>(
      position: position,
      items: items,
      initialValue: initialValue,
      elevation: elevation,
      shadowColor: shadowColor,
      surfaceTintColor: surfaceTintColor,
      semanticLabel: semanticLabel,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      shape: shape,
      color: color,
      capturedThemes:
          InheritedTheme.capture(from: context, to: navigator.context),
      constraints: constraints,
      clipBehavior: clipBehavior,
      duration: Theme.of(context).extension<AnimationDuration>()?.medium ??
          _kMenuDuration,
    ),
  );
}

typedef CustomPopupMenuItemSelected<T> = void Function(T value);

typedef CustomPopupMenuCanceled = void Function();

typedef CustomPopupMenuItemBuilder<T> = List<PopupMenuEntry<T>> Function(
    BuildContext context);

class CustomPopupMenuButton<T> extends StatefulWidget {
  const CustomPopupMenuButton({
    super.key,
    required this.itemBuilder,
    this.initialValue,
    this.onOpened,
    this.onSelected,
    this.onCanceled,
    this.tooltip,
    this.elevation,
    this.shadowColor,
    this.padding = const EdgeInsets.all(8.0),
    this.child,
    this.splashRadius,
    this.icon,
    this.iconSize,
    this.offset = Offset.zero,
    this.enabled = true,
    this.shape,
    this.color,
    this.enableFeedback,
    this.constraints,
    this.position,
    this.clipBehavior = Clip.none,
  }) : assert(
          !(child != null && icon != null),
          'You can only pass [child] or [icon], not both.',
        );

  final CustomPopupMenuItemBuilder<T> itemBuilder;

  final T? initialValue;

  final VoidCallback? onOpened;

  final CustomPopupMenuItemSelected<T>? onSelected;

  final CustomPopupMenuCanceled? onCanceled;

  final String? tooltip;

  final double? elevation;

  final Color? shadowColor;

  final EdgeInsetsGeometry padding;

  final double? splashRadius;

  final Widget? child;

  final Widget? icon;

  final Offset offset;

  final bool enabled;

  final ShapeBorder? shape;

  final Color? color;

  final bool? enableFeedback;

  final double? iconSize;

  final BoxConstraints? constraints;

  final PopupMenuPosition? position;

  final Clip clipBehavior;

  @override
  CustomPopupMenuButtonState<T> createState() =>
      CustomPopupMenuButtonState<T>();
}

class CustomPopupMenuButtonState<T> extends State<CustomPopupMenuButton<T>> {
  void showButtonMenu() {
    final PopupMenuThemeData popupMenuTheme = PopupMenuTheme.of(context);
    final RenderBox button = context.findRenderObject()! as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject()! as RenderBox;
    final PopupMenuPosition popupMenuPosition =
        widget.position ?? popupMenuTheme.position ?? PopupMenuPosition.over;
    final Offset offset;
    switch (popupMenuPosition) {
      case PopupMenuPosition.over:
        offset = widget.offset;
        break;
      case PopupMenuPosition.under:
        offset =
            Offset(0.0, button.size.height - (widget.padding.vertical / 2)) +
                widget.offset;
        break;
    }
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(offset, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero) + offset,
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );
    final List<PopupMenuEntry<T>> items = widget.itemBuilder(context);
    if (items.isNotEmpty) {
      widget.onOpened?.call();
      showCustomMenu<T?>(
        context: context,
        elevation: widget.elevation ?? popupMenuTheme.elevation,
        shadowColor: widget.shadowColor ?? popupMenuTheme.shadowColor,
        items: items,
        initialValue: widget.initialValue,
        position: position,
        shape: widget.shape ?? popupMenuTheme.shape,
        color: widget.color ?? popupMenuTheme.color,
        constraints: widget.constraints,
        clipBehavior: widget.clipBehavior,
      ).then<void>((T? newValue) {
        if (!mounted) {
          return null;
        }
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
    final IconThemeData iconTheme = IconTheme.of(context);
    final bool enableFeedback = widget.enableFeedback ??
        PopupMenuTheme.of(context).enableFeedback ??
        true;

    assert(debugCheckHasMaterialLocalizations(context));

    if (widget.child != null) {
      return Tooltip(
        message:
            widget.tooltip ?? MaterialLocalizations.of(context).showMenuTooltip,
        child: InkWell(
          onTap: widget.enabled ? showButtonMenu : null,
          canRequestFocus: _canRequestFocus,
          radius: widget.splashRadius,
          enableFeedback: enableFeedback,
          child: widget.child,
        ),
      );
    }

    return IconButton(
      icon: widget.icon ??
          Icon(
            Icons.adaptive.more,
            size: 20.0,
            color: Theme.of(context).iconTheme.color,
          ),
      padding: widget.padding,
      splashRadius: widget.splashRadius ?? 20.0,
      iconSize: widget.iconSize ?? iconTheme.size,
      color: widget.color ?? iconTheme.color,
      tooltip:
          widget.tooltip ?? MaterialLocalizations.of(context).showMenuTooltip,
      onPressed: widget.enabled ? showButtonMenu : null,
      enableFeedback: enableFeedback,
    );
  }
}

class _CustomPopupMenuDefaultsM2 extends PopupMenuThemeData {
  _CustomPopupMenuDefaultsM2(this.context) : super(elevation: 8.0);

  final BuildContext context;
  late final ThemeData _theme = Theme.of(context);
  late final TextTheme _textTheme = _theme.textTheme;

  @override
  TextStyle? get textStyle => _textTheme.titleMedium;
}

class _CustomPopupMenuDefaultsM3 extends PopupMenuThemeData {
  _CustomPopupMenuDefaultsM3(this.context) : super(elevation: 3.0);

  final BuildContext context;
  late final ThemeData _theme = Theme.of(context);
  late final ColorScheme _colors = _theme.colorScheme;
  late final TextTheme _textTheme = _theme.textTheme;

  @override
  MaterialStateProperty<TextStyle?>? get labelTextStyle {
    return MaterialStateProperty.resolveWith((Set<MaterialState> states) {
      final TextStyle style = _textTheme.labelLarge!;
      if (states.contains(MaterialState.disabled)) {
        return style.apply(color: _colors.onSurface.withOpacity(0.38));
      }
      return style.apply(color: _colors.onSurface);
    });
  }

  @override
  Color? get color => _colors.surface;

  @override
  Color? get shadowColor => _colors.shadow;

  @override
  Color? get surfaceTintColor => _colors.surfaceTint;

  @override
  ShapeBorder? get shape => const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(4.0)));
}
