// ignore_for_file: depend_on_referenced_packages

import 'dart:math';
import 'dart:ui';
import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:collection/collection.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide CarouselView, CarouselController, ReorderableDragStartListener;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:m3_expressive_shapes/rounded_polygon_border.dart';
import 'package:m3_expressive_shapes/shapes/material_shapes.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/features/now_playing/state/now_playing_mobile_notifier.dart';
import 'package:harmonoid/features/now_playing/now_playing_bar.dart';
import 'package:harmonoid/utils/dimensions.dart';
import 'package:harmonoid/utils/keyboard_shortcuts.dart';
import 'package:harmonoid/utils/rendering.dart';

class MobileNowPlayingBarScrollNotifier extends StatelessWidget {
  final Widget child;

  const MobileNowPlayingBarScrollNotifier({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (isDesktop) {
      return child;
    } else {
      return NotificationListener<UserScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.axis == Axis.vertical && (notification.metrics.axisDirection == AxisDirection.up || notification.metrics.axisDirection == AxisDirection.down)) {
            if (notification.direction == ScrollDirection.forward) {
              NowPlayingMobileNotifier.instance.showNowPlayingBar();
            } else if (notification.direction == ScrollDirection.reverse) {
              NowPlayingMobileNotifier.instance.hideNowPlayingBar();
            }
          }
          return true;
        },
        child: child,
      );
    }
  }
}

// --------------------------------------------------

class ScaleOnHover extends StatefulWidget {
  final Widget child;

  const ScaleOnHover({super.key, required this.child});

  @override
  ScaleOnHoverState createState() => ScaleOnHoverState();
}

class ScaleOnHoverState extends State<ScaleOnHover> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (e) => setState(() => _scale = 1.05),
      onExit: (e) => setState(() => _scale = 1.00),
      child: AnimatedScale(
        scale: _scale,
        duration: Theme.of(context).extension<AnimationDuration>()?.fast ?? Duration.zero,
        child: widget.child,
      ),
    );
  }
}

// --------------------------------------------------

class RippleSurface extends StatefulWidget {
  final Color? color;
  final Duration? duration;
  final Curve? curve;

  const RippleSurface({
    super.key,
    this.color,
    this.duration,
    this.curve,
  });

  @override
  State<RippleSurface> createState() => RippleSurfaceState();
}

class RippleSurfaceState extends State<RippleSurface> {
  static const _kRippleDimension = 2.0;

  double _width = 1.0;
  double _height = 1.0;
  Widget? _background;
  Widget? _ripple;

  @override
  void initState() {
    super.initState();
    _background = Positioned.fill(child: Container(color: widget.color));
  }

  @override
  void didUpdateWidget(covariant RippleSurface oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.color != widget.color) {
      // The change in color was very fast, so we don't need to animate the ripple.
      if (_ripple != null) {
        setState(() {
          _ripple = null;
          _background = Positioned.fill(child: Container(color: widget.color));
        });
      }

      setState(() {
        _ripple = TweenAnimationBuilder<double>(
          key: ValueKey(Random().nextDouble()),
          tween: Tween<double>(
            begin: 1.0,
            end: max(_width / _kRippleDimension, _height / _kRippleDimension) * 2.0,
          ),
          duration: widget.duration ?? Theme.of(context).extension<AnimationDuration>()?.slow ?? Duration.zero,
          curve: widget.curve ?? Curves.easeInOut,
          onEnd: () {
            setState(() {
              _background = Positioned.fill(child: Container(color: widget.color));
              _ripple = null;
            });
          },
          builder: (context, scale, _) {
            return Transform.scale(
              scale: scale,
              child: Container(
                width: _kRippleDimension,
                height: _kRippleDimension,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color,
                ),
              ),
            );
          },
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: LayoutBuilder(
        builder: (context, constraints) {
          _width = constraints.maxWidth;
          _height = constraints.maxHeight;
          return Stack(
            alignment: Alignment.center,
            children: [
              if (_background != null) _background!,
              if (_ripple != null) _ripple!,
            ],
          );
        },
      ),
    );
  }
}

// --------------------------------------------------

class SlideOnEnter extends StatefulWidget {
  final Widget child;
  final Duration? duration;
  final Curve? curve;
  const SlideOnEnter({
    super.key,
    required this.child,
    this.duration,
    this.curve,
  });

  @override
  State<SlideOnEnter> createState() => SlideOnEnterState();
}

class SlideOnEnterState extends State<SlideOnEnter> {
  Offset offset = const Offset(0.0, 1.0);

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () => setState(() => offset = Offset.zero));
  }

  @override
  Widget build(BuildContext context) {
    final duration = widget.duration ?? Theme.of(context).extension<AnimationDuration>()?.medium ?? Duration.zero;
    final curve = widget.curve ?? Curves.easeInOut;
    return AnimatedSlide(
      offset: offset,
      duration: duration,
      curve: curve,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () async {
                setState(() => offset = const Offset(0.0, 1.0));
                await Navigator.of(context).maybePop();
              },
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: widget.child,
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------

final class HoverActionsData {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const HoverActionsData({
    required this.label,
    required this.icon,
    required this.onTap,
  });
}

class HoverActions extends StatefulWidget {
  final Widget child;
  final List<HoverActionsData> actions;
  const HoverActions({
    super.key,
    required this.child,
    required this.actions,
  });

  @override
  State<HoverActions> createState() => HoverActionsState();
}

class HoverActionsState extends State<HoverActions> {
  bool _hovered = isMobile;
  int? _hoveredAction;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: isMobile ? null : (e) => setState(() => _hovered = true),
      onExit: isMobile ? null : (e) => setState(() => _hovered = false),
      child: Stack(
        alignment: Alignment.center,
        children: [
          widget.child,
          AnimatedOpacity(
            opacity: _hovered ? 1.0 : 0.0,
            duration: Theme.of(context).extension<AnimationDuration>()?.medium ?? Duration.zero,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 8.0,
              children: widget.actions
                  .mapIndexed(
                    (i, e) => isMaterial2
                        ? FloatingActionButton.small(
                            onPressed: e.onTap,
                            tooltip: e.label,
                            child: Icon(e.icon),
                          )
                        : GestureDetector(
                            onTap: e.onTap,
                            onPanStart: (e) => setState(() => _hoveredAction = i),
                            onPanEnd: (e) => setState(() => _hoveredAction = null),
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              onEnter: (e) => setState(() => _hoveredAction = i),
                              onExit: (e) => setState(() => _hoveredAction = null),
                              child: AnimatedContainer(
                                curve: const ElasticOutCurve(0.85),
                                width: 48.0,
                                height: 48.0,
                                duration: Theme.of(context).extension<AnimationDuration>()?.medium ?? Duration.zero,
                                decoration: ShapeDecoration(
                                  color: Theme.of(context).colorScheme.primaryContainer,
                                  shape: RoundedPolygonBorder(polygon: _hoveredAction == i ? MaterialShapes.sunny : MaterialShapes.circle),
                                ),
                                child: Tooltip(
                                  message: e.label,
                                  child: Center(
                                    child: Icon(
                                      e.icon,
                                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------

class SubHeader extends StatelessWidget {
  final String text;
  final double? height;
  final EdgeInsets? padding;
  final Widget? leading;
  final Widget? trailing;

  const SubHeader(
    this.text, {
    super.key,
    this.height,
    this.padding,
    this.leading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final horizontal = isDesktop ? 24.0 : 16.0;
    final fontSize = isDesktop ? 16.0 : null;
    final TextStyle? style;
    if (isMaterial2 && isMobile) {
      style = Theme.of(context).textTheme.titleSmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontSize: fontSize,
      );
    } else if (isMaterial2 && isDesktop) {
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
      height: height ?? 56.0,
      padding: padding ?? EdgeInsets.symmetric(horizontal: horizontal),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (leading != null) ...[
            IconTheme(
              data: IconTheme.of(context).copyWith(color: style?.color),
              child: leading!,
            ),
            const SizedBox(width: 8.0),
          ],
          Text(text, style: style),
          if (trailing != null) ...[
            const SizedBox(width: 8.0),
            trailing!,
          ],
        ],
      ),
    );
  }
}

// --------------------------------------------------

class ShowAllButton extends StatelessWidget {
  final void Function()? onPressed;

  const ShowAllButton({super.key, this.onPressed});

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
              Localization.instance.SEE_ALL,
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

// --------------------------------------------------

class ScrollableSlider extends StatefulWidget {
  final double min;
  final double max;
  final double? value;
  final List<double>? values;
  final double? interval;
  final double? stepSize;
  final bool showLabels;
  final void Function(dynamic)? onChanged;
  final void Function(dynamic)? onChangeEnd;
  final VoidCallback? onScrolledUp;
  final VoidCallback? onScrolledDown;
  final LabelFormatterCallback? labelFormatterCallback;

  const ScrollableSlider({
    super.key,
    this.min = 0.0,
    double max = 1.0,
    this.value,
    this.values,
    this.interval,
    this.stepSize,
    this.showLabels = false,
    this.onChanged,
    this.onChangeEnd,
    this.onScrolledUp,
    this.onScrolledDown,
    this.labelFormatterCallback,
  }) : max = min >= max ? 4294967296.0 /* 2^32 */ : max;

  @override
  State<ScrollableSlider> createState() => ScrollableSliderState();
}

class ScrollableSliderState extends State<ScrollableSlider> {
  double? _value;
  List<double>? _values;

  bool get _usesLocalValue => widget.onChanged == null && widget.onChangeEnd != null;

  @override
  void initState() {
    super.initState();
    _syncLocalValues();
  }

  @override
  void didUpdateWidget(covariant ScrollableSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value || !const ListEquality().equals(oldWidget.values, widget.values)) {
      _syncLocalValues();
    }
  }

  void _syncLocalValues() {
    _value = widget.value;
    _values = widget.values == null ? null : List<double>.of(widget.values!);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.onChanged == null && widget.onChangeEnd == null ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      child: Listener(
        onPointerSignal: (event) {
          if (event is PointerScrollEvent) {
            if (event.scrollDelta.dy < 0) {
              widget.onScrolledUp?.call();
            }
            if (event.scrollDelta.dy > 0) {
              widget.onScrolledDown?.call();
            }
          }
        },
        child: () {
          if (widget.value != null) {
            return SfSliderTheme(
              data: SfSliderThemeData(
                activeTrackHeight: 4.0,
                inactiveTrackHeight: 2.0,
                thumbRadius: 6.0,
                overlayRadius: 12.0,
                // Map colors from Slider (package:flutter) to SfSlider (package:syncfusion_flutter_sliders).
                thumbColor: SliderTheme.of(context).thumbColor,
                overlayColor: SliderTheme.of(context).overlayColor,
                activeTrackColor: SliderTheme.of(context).activeTrackColor,
                inactiveTrackColor: SliderTheme.of(context).inactiveTrackColor,
                disabledActiveTrackColor: SliderTheme.of(context).disabledActiveTrackColor,
              ),
              child: SfSlider(
                min: widget.min,
                max: widget.max,
                value: _usesLocalValue ? _value : widget.value,
                interval: widget.interval,
                stepSize: widget.stepSize,
                showLabels: widget.showLabels,
                labelFormatterCallback: widget.labelFormatterCallback,
                edgeLabelPlacement: EdgeLabelPlacement.inside,
                onChanged: widget.onChanged == null && widget.onChangeEnd == null
                    ? null
                    : (result) {
                        if (_usesLocalValue) {
                          setState(() => _value = (result as num).toDouble());
                        }
                        widget.onChanged?.call(result);
                      },
                onChangeEnd: widget.onChangeEnd == null ? null : (result) => widget.onChangeEnd?.call(result),
              ),
            );
          }
          if (widget.values != null) {
            return SfRangeSliderTheme(
              data: SfRangeSliderThemeData(
                activeTrackHeight: 4.0,
                inactiveTrackHeight: 2.0,
                thumbRadius: 6.0,
                overlayRadius: 12.0,
                // Map colors from Slider (package:flutter) to SfSlider (package:syncfusion_flutter_sliders).
                thumbColor: SliderTheme.of(context).thumbColor,
                overlayColor: SliderTheme.of(context).overlayColor,
                activeTrackColor: SliderTheme.of(context).activeTrackColor,
                inactiveTrackColor: SliderTheme.of(context).inactiveTrackColor,
                disabledActiveTrackColor: SliderTheme.of(context).disabledActiveTrackColor,
              ),
              child: SfRangeSlider(
                min: widget.min,
                max: widget.max,
                values: SfRangeValues(
                  _usesLocalValue ? _values![0] : widget.values![0],
                  _usesLocalValue ? _values![1] : widget.values![1],
                ),
                interval: widget.interval,
                stepSize: widget.stepSize,
                showLabels: widget.showLabels,
                labelFormatterCallback: widget.labelFormatterCallback,
                edgeLabelPlacement: EdgeLabelPlacement.inside,
                onChanged: widget.onChanged == null && widget.onChangeEnd == null
                    ? null
                    : (result) {
                        final values = <double>[
                          (result.start as num).toDouble(),
                          (result.end as num).toDouble(),
                        ];
                        if (_usesLocalValue) {
                          setState(() => _values = values);
                        }
                        widget.onChanged?.call(values);
                      },
                onChangeEnd: widget.onChangeEnd == null ? null : (result) => widget.onChangeEnd?.call([result.start, result.end]),
              ),
            );
          }
          return const SizedBox.shrink();
        }(),
      ),
    );
  }
}

// --------------------------------------------------

class DefaultTextFormField extends StatelessWidget {
  final Object groupId;
  final TextEditingController? controller;
  final String? initialValue;
  final FocusNode? focusNode;
  final String? forceErrorText;
  final InputDecoration? decoration;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextDirection? textDirection;
  final TextAlign textAlign;
  final TextAlignVertical? textAlignVertical;
  final bool autofocus;
  final bool readOnly;
  final bool? showCursor;
  final String obscuringCharacter;
  final bool obscureText;
  final bool autocorrect;
  final SmartDashesType? smartDashesType;
  final SmartQuotesType? smartQuotesType;
  final bool enableSuggestions;
  final MaxLengthEnforcement? maxLengthEnforcement;
  final int? maxLines;
  final int? minLines;
  final bool expands;
  final int? maxLength;
  final void Function(String)? onChanged;
  final GestureTapCallback? onTap;
  final bool onTapAlwaysCalled;
  final TapRegionCallback? onTapOutside;
  final TapRegionUpCallback? onTapUpOutside;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onFieldSubmitted;
  final void Function(String?)? onSaved;
  final String? Function(String?)? validator;
  final FormFieldErrorBuilder? errorBuilder;
  final List<TextInputFormatter>? inputFormatters;
  final bool? enabled;
  final bool? ignorePointers;
  final double cursorWidth;
  final double? cursorHeight;
  final Radius? cursorRadius;
  final Color? cursorColor;
  final Color? cursorErrorColor;
  final Brightness? keyboardAppearance;
  final EdgeInsets scrollPadding;
  final bool? enableInteractiveSelection;
  final TextSelectionControls? selectionControls;
  final InputCounterWidgetBuilder? buildCounter;
  final ScrollPhysics? scrollPhysics;
  final Iterable<String>? autofillHints;
  final AutovalidateMode? autovalidateMode;
  final ScrollController? scrollController;
  final String? restorationId;
  final bool enableIMEPersonalizedLearning;
  final MouseCursor? mouseCursor;
  final EditableTextContextMenuBuilder? contextMenuBuilder;
  final SpellCheckConfiguration? spellCheckConfiguration;
  final TextMagnifierConfiguration? magnifierConfiguration;
  final UndoHistoryController? undoController;
  final AppPrivateCommandCallback? onAppPrivateCommand;
  final bool? cursorOpacityAnimates;
  final BoxHeightStyle selectionHeightStyle;
  final BoxWidthStyle selectionWidthStyle;
  final DragStartBehavior dragStartBehavior;
  final ContentInsertionConfiguration? contentInsertionConfiguration;
  final Clip clipBehavior;
  final bool stylusHandwritingEnabled;
  final bool canRequestFocus;

  const DefaultTextFormField({
    super.key,
    this.groupId = EditableText,
    this.controller,
    this.initialValue,
    this.focusNode,
    this.forceErrorText,
    this.decoration = const InputDecoration(),
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.style,
    this.strutStyle,
    this.textDirection,
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
    this.autofocus = false,
    this.readOnly = false,
    this.showCursor,
    this.obscuringCharacter = '•',
    this.obscureText = false,
    this.autocorrect = true,
    this.smartDashesType,
    this.smartQuotesType,
    this.enableSuggestions = true,
    this.maxLengthEnforcement,
    this.maxLines = 1,
    this.minLines,
    this.expands = false,
    this.maxLength,
    this.onChanged,
    this.onTap,
    this.onTapAlwaysCalled = false,
    this.onTapOutside,
    this.onTapUpOutside,
    this.onEditingComplete,
    this.onFieldSubmitted,
    this.onSaved,
    this.validator,
    this.errorBuilder,
    this.inputFormatters,
    this.enabled,
    this.ignorePointers,
    this.cursorWidth = 2.0,
    this.cursorHeight,
    this.cursorRadius,
    this.cursorColor,
    this.cursorErrorColor,
    this.keyboardAppearance,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.enableInteractiveSelection,
    this.selectionControls,
    this.buildCounter,
    this.scrollPhysics,
    this.autofillHints,
    this.autovalidateMode,
    this.scrollController,
    this.restorationId,
    this.enableIMEPersonalizedLearning = true,
    this.mouseCursor,
    this.contextMenuBuilder,
    this.spellCheckConfiguration,
    this.magnifierConfiguration,
    this.undoController,
    this.onAppPrivateCommand,
    this.cursorOpacityAnimates,
    this.selectionHeightStyle = BoxHeightStyle.tight,
    this.selectionWidthStyle = BoxWidthStyle.tight,
    this.dragStartBehavior = DragStartBehavior.start,
    this.contentInsertionConfiguration,
    this.clipBehavior = Clip.hardEdge,
    this.stylusHandwritingEnabled = EditableText.defaultStylusHandwritingEnabled,
    this.canRequestFocus = true,
  });

  @override
  Widget build(BuildContext context) {
    return KeyboardShortcutsInterceptor(
      child: TextFormField(
        groupId: groupId,
        controller: controller,
        initialValue: initialValue,
        focusNode: focusNode,
        forceErrorText: forceErrorText,
        decoration: decoration,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        textInputAction: textInputAction,
        style: style,
        strutStyle: strutStyle,
        textDirection: textDirection,
        textAlign: textAlign,
        textAlignVertical: textAlignVertical,
        autofocus: autofocus,
        readOnly: readOnly,
        showCursor: showCursor,
        obscuringCharacter: obscuringCharacter,
        obscureText: obscureText,
        autocorrect: autocorrect,
        smartDashesType: smartDashesType,
        smartQuotesType: smartQuotesType,
        enableSuggestions: enableSuggestions,
        maxLengthEnforcement: maxLengthEnforcement,
        maxLines: maxLines,
        minLines: minLines,
        expands: expands,
        maxLength: maxLength,
        onChanged: onChanged,
        onTap: onTap,
        onTapAlwaysCalled: onTapAlwaysCalled,
        onTapOutside: onTapOutside,
        onTapUpOutside: onTapUpOutside,
        onEditingComplete: onEditingComplete,
        onFieldSubmitted: onFieldSubmitted,
        onSaved: onSaved,
        validator: validator,
        errorBuilder: errorBuilder,
        inputFormatters: inputFormatters,
        enabled: enabled,
        ignorePointers: ignorePointers,
        cursorWidth: cursorWidth,
        cursorHeight: cursorHeight,
        cursorRadius: cursorRadius,
        cursorColor: cursorColor,
        cursorErrorColor: cursorErrorColor,
        keyboardAppearance: keyboardAppearance,
        scrollPadding: scrollPadding,
        enableInteractiveSelection: enableInteractiveSelection,
        selectionControls: selectionControls,
        buildCounter: buildCounter,
        scrollPhysics: scrollPhysics,
        autofillHints: autofillHints,
        autovalidateMode: autovalidateMode,
        scrollController: scrollController,
        restorationId: restorationId,
        enableIMEPersonalizedLearning: enableIMEPersonalizedLearning,
        mouseCursor: mouseCursor,
        contextMenuBuilder: contextMenuBuilder,
        spellCheckConfiguration: spellCheckConfiguration,
        magnifierConfiguration: magnifierConfiguration,
        undoController: undoController,
        onAppPrivateCommand: onAppPrivateCommand,
        cursorOpacityAnimates: cursorOpacityAnimates,
        selectionHeightStyle: selectionHeightStyle,
        selectionWidthStyle: selectionWidthStyle,
        dragStartBehavior: dragStartBehavior,
        contentInsertionConfiguration: contentInsertionConfiguration,
        clipBehavior: clipBehavior,
        stylusHandwritingEnabled: stylusHandwritingEnabled,
        canRequestFocus: canRequestFocus,
      ),
    );
  }
}

// --------------------------------------------------

class ListItem extends StatefulWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  // https://github.com/flutter/flutter/issues/29549
  // https://stackoverflow.com/a/54113677/12825435

  const ListItem({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
  });

  @override
  State<ListItem> createState() => ListItemState();
}

class ListItemState extends State<ListItem> {
  final ValueNotifier<bool> isThreeLineNotifier = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isThreeLineNotifier,
      builder: (context, isThreeLine, _) {
        return ListTile(
          leading: widget.leading,
          trailing: widget.trailing,
          title: Text(
            widget.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).listTileTheme.titleTextStyle,
          ),
          subtitle: widget.subtitle == null
              ? null
              : Stack(
                  children: [
                    Positioned.fill(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final textSpan = TextSpan(
                            text: widget.subtitle,
                            style: Theme.of(context).listTileTheme.subtitleTextStyle,
                          );
                          final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
                          textPainter.layout(maxWidth: constraints.maxWidth);
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (textPainter.computeLineMetrics().length >= 2) {
                              isThreeLineNotifier.value = true;
                            } else {
                              isThreeLineNotifier.value = false;
                            }
                          });
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    Text(
                      widget.subtitle!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
          isThreeLine: isThreeLine,
          onTap: widget.onTap,
        );
      },
    );
  }
}

// --------------------------------------------------

class StatefulAnimatedIcon extends StatefulWidget {
  final bool dismissed;
  final AnimatedIconData icon;
  final double size;
  final Color? color;
  final Curve curve;
  final Duration duration;

  const StatefulAnimatedIcon({
    super.key,
    required this.dismissed,
    required this.icon,
    this.size = 24.0,
    this.color,
    this.curve = Curves.easeInOut,
    this.duration = const Duration(milliseconds: 200),
  });

  @override
  State<StatefulAnimatedIcon> createState() => StatefulAnimatedIconState();
}

class StatefulAnimatedIconState extends State<StatefulAnimatedIcon> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
    reverseDuration: widget.duration,
  );
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: widget.curve,
    reverseCurve: widget.curve,
  );

  @override
  void initState() {
    super.initState();
    if (widget.dismissed) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(StatefulAnimatedIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dismissed != widget.dismissed) {
      if (widget.dismissed) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedIcon(
      progress: _animation,
      icon: widget.icon,
      size: widget.size,
      color: widget.color,
    );
  }
}

// --------------------------------------------------

class StatefulPageViewBuilder extends StatefulWidget {
  final int index;
  final Widget Function(BuildContext, int) itemBuilder;
  final int? itemCount;
  final ScrollPhysics? physics;

  const StatefulPageViewBuilder({
    super.key,
    required this.index,
    required this.itemBuilder,
    this.itemCount,
    this.physics,
  });

  @override
  State<StatefulPageViewBuilder> createState() => StatefulPageViewBuilderState();
}

class StatefulPageViewBuilderState extends State<StatefulPageViewBuilder> {
  // https://github.com/flutter/flutter/issues/31191
  late final PageController _controller = PageController(
    initialPage: widget.index,
    viewportFraction: 0.9999999999,
  );

  @override
  void didUpdateWidget(covariant StatefulPageViewBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      final duration = Theme.of(context).extension<AnimationDuration>()?.medium ?? Duration.zero;
      if ((oldWidget.index - widget.index).abs() > 5 || duration == Duration.zero) {
        _controller.jumpToPage(widget.index);
      } else {
        _controller.animateToPage(
          widget.index,
          duration: duration,
          curve: Curves.easeInOut,
        );
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _controller,
      physics: widget.physics,
      itemCount: widget.itemCount,
      itemBuilder: (context, index) => widget.itemBuilder(context, index),
    );
  }
}

// --------------------------------------------------

class StatefulCarouselViewBuilder extends StatefulWidget {
  final int index;
  final Widget Function(BuildContext, int) itemBuilder;
  final int itemCount;
  final EdgeInsets padding;
  final List<int> flexWeights;
  final void Function(int)? onTap;

  const StatefulCarouselViewBuilder({
    super.key,
    required this.index,
    required this.itemBuilder,
    required this.itemCount,
    this.padding = const EdgeInsets.symmetric(horizontal: 4.0),
    required this.flexWeights,
    this.onTap,
  });

  @override
  State<StatefulCarouselViewBuilder> createState() => StatefulCarouselViewBuilderState();
}

class StatefulCarouselViewBuilderState extends State<StatefulCarouselViewBuilder> {
  late final CarouselController _controller = CarouselController(initialItem: widget.index);

  @override
  void didUpdateWidget(covariant StatefulCarouselViewBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      final duration = Theme.of(context).extension<AnimationDuration>()?.medium ?? Duration.zero;
      if ((oldWidget.index - widget.index).abs() > 5 || duration == Duration.zero) {
        _controller.jumpToItem(widget.index);
      } else {
        _controller.animateToItem(
          widget.index,
          duration: duration,
          curve: Curves.easeInOut,
        );
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CarouselView.weighted(
      padding: widget.padding,
      itemSnapping: true,
      controller: _controller,
      itemCount: widget.itemCount,
      itemBuilder: widget.itemBuilder,
      flexWeights: widget.flexWeights,
      onTap: widget.onTap,
    );
  }
}

// --------------------------------------------------

class SliverSpacer extends StatelessWidget {
  const SliverSpacer({super.key});

  Widget _buildDesktopLayout(BuildContext context) => const SizedBox(height: kDesktopSliverTileSpacerHeight);

  Widget _buildTabletLayout(BuildContext context) => throw UnimplementedError();

  Widget _buildMobileLayout(BuildContext context) => const SizedBox(height: kMobileSliverTileSpacerHeight);

  @override
  Widget build(BuildContext context) {
    if (isDesktop) {
      return _buildDesktopLayout(context);
    }
    if (isTablet) {
      return _buildTabletLayout(context);
    }
    if (isMobile) {
      return _buildMobileLayout(context);
    }
    throw UnimplementedError();
  }
}

// --------------------------------------------------

class MusicAnimation extends StatelessWidget {
  final Color? color;
  final double width;
  final double height;
  final int separatorFlex;

  const MusicAnimation({
    super.key,
    this.color,
    this.width = double.infinity,
    this.height = double.infinity,
    this.separatorFlex = 1,
  });

  @override
  Widget build(BuildContext context) {
    const durations = <int>[1000, 1250, 1500];

    return SizedBox(
      width: width,
      height: height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final duration in durations) ...[
            Expanded(
              flex: 4,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return _MusicAnimationComponent(
                    curve: Curves.bounceOut,
                    color: color ?? Theme.of(context).iconTheme.color ?? Theme.of(context).colorScheme.primary,
                    duration: Duration(milliseconds: duration),
                    height: constraints.maxHeight,
                  );
                },
              ),
            ),
            Spacer(flex: separatorFlex),
          ],
        ]..removeLast(),
      ),
    );
  }
}

class _MusicAnimationComponent extends StatefulWidget {
  final Curve curve;
  final Color color;
  final Duration duration;
  final double height;

  const _MusicAnimationComponent({
    required this.curve,
    required this.color,
    required this.duration,
    required this.height,
  });

  @override
  _MusicAnimationComponentState createState() => _MusicAnimationComponentState();
}

class _MusicAnimationComponentState extends State<_MusicAnimationComponent> with SingleTickerProviderStateMixin {
  late final AnimationController controller = AnimationController(duration: widget.duration, vsync: this);
  late final Animation<double> animation = Tween<double>(begin: 0.0, end: widget.height).animate(CurvedAnimation(parent: controller, curve: widget.curve));

  @override
  void initState() {
    super.initState();
    controller
      ..value = widget.height * Random().nextDouble() * 0.5
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) => Container(
        height: animation.value,
        color: widget.color,
      ),
    );
  }
}

// --------------------------------------------------

class HoverOverlay extends StatefulWidget {
  final Size overlaySize;
  final WidgetBuilder overlayBuilder;
  final EdgeInsets overlayPadding;
  final Widget child;

  const HoverOverlay({
    super.key,
    required this.overlaySize,
    this.overlayPadding = const EdgeInsets.all(16.0),
    required this.overlayBuilder,
    required this.child,
  });

  @override
  State<HoverOverlay> createState() => HoverOverlayState();
}

class HoverOverlayState extends State<HoverOverlay> {
  OverlayEntry? _overlayEntry;
  Offset? _mousePosition;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _updateOverlayPosition(PointerEvent event) {
    _mousePosition = event.position;
    _overlayEntry?.markNeedsBuild();
  }

  void _showOverlay(BuildContext context) {
    _overlayEntry = OverlayEntry(
      builder: (context) {
        final screenSize = MediaQuery.sizeOf(context);
        final position = _mousePosition ?? Offset.zero;

        double screenWidth = screenSize.width;
        double screenHeight = screenSize.height;

        double left = position.dx;
        double top = position.dy;

        screenHeight -= kDesktopAppBarHeight + WindowPlus.instance.captionHeight + NowPlayingBar.height;
        top -= kDesktopAppBarHeight + WindowPlus.instance.captionHeight;

        if (left + widget.overlaySize.width + widget.overlayPadding.right > screenWidth) {
          left = left - widget.overlaySize.width;
        }
        if (screenWidth - (left + widget.overlaySize.width) < widget.overlayPadding.right) {
          left = screenWidth - widget.overlaySize.width - widget.overlayPadding.right;
        }

        if (top + widget.overlaySize.height + widget.overlayPadding.bottom > screenHeight) {
          top = top - widget.overlaySize.height;
        }
        if (screenHeight - (top + widget.overlaySize.height) < widget.overlayPadding.bottom) {
          top = screenHeight - widget.overlaySize.height - widget.overlayPadding.bottom;
        }

        left = left.clamp(widget.overlayPadding.left, screenWidth - widget.overlaySize.width);
        top = top.clamp(widget.overlayPadding.top, screenHeight - widget.overlaySize.height);

        return Positioned(
          left: left,
          top: top,
          width: widget.overlaySize.width,
          height: widget.overlaySize.height,
          child: widget.overlayBuilder(context),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) {
        _mousePosition = event.position;
        _showOverlay(context);
      },
      onExit: (_) {
        _removeOverlay();
      },
      onHover: (event) {
        _updateOverlayPosition(event);
      },
      child: widget.child,
    );
  }
}
