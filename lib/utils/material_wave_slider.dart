import 'dart:math';
import 'package:flutter/material.dart';

/// {@template material_wave_slider}
///
/// MaterialWaveSlider
/// ------------------
/// Material Design 3 / Material You inspired waveform slider.
///
/// [SliderTheme] & [SliderThemeData] may be used to customize the visual appearance of the slider.
///
/// {@endtemplate}
class MaterialWaveSlider extends StatefulWidget {
  // --------------------------------------------------

  /// The current value of the slider.
  final double value;

  /// The minimum value the user can select.
  final double min;

  /// The maximum value the user can select.
  final double max;

  /// Called during a drag when the user is selecting a new value for the slider by dragging.
  final void Function(double)? onChanged;

  // --------------------------------------------------

  /// The height of the slider.
  final double height;

  /// The amplitude of the wave.
  final double? amplitude;

  /// The velocity of the wave.
  final double velocity;

  /// Whether the wave is currently paused.
  final bool paused;

  /// The [Curve] of the amplitude change transition.
  final Curve transitionCurve;

  /// The [Duration] of the amplitude change transition.
  final Duration transitionDuration;

  /// Whether to show amplitude change transition upon value change.
  final bool transitionOnChange;

  /// Builder that may be used to customize the default thumb.
  final Widget Function(BuildContext)? thumbBuilder;

  /// The width of the default thumb.
  final double thumbWidth;

  // --------------------------------------------------

  /// {@macro material_wave_slider}
  const MaterialWaveSlider({
    super.key,
    required this.value,
    this.min = 0.0,
    this.max = 1.0,
    required this.onChanged,
    this.height = 48.0,
    this.velocity = 2600.0,
    this.paused = false,
    this.amplitude,
    this.transitionCurve = Curves.easeInOut,
    this.transitionDuration = const Duration(milliseconds: 200),
    this.transitionOnChange = true,
    this.thumbBuilder,
    this.thumbWidth = 6.0,
  });

  @override
  State<MaterialWaveSlider> createState() => MaterialWaveSliderState();
}

class MaterialWaveSliderState extends State<MaterialWaveSlider> with SingleTickerProviderStateMixin {
  double get _amplitude => widget.amplitude ?? (widget.height / 12.0);
  double get _percent => widget.value == 0.0 ? 0.0 : ((_current ?? widget.value) / (widget.max - widget.min)).clamp(0.0, 1.0);

  late bool _paused = widget.paused;
  late bool _running = !widget.paused;

  double? _current;

  late final ScrollController _controller = ScrollController();

  Color? color;
  Path? defaultPath;
  Widget? defaultPaint;

  @override
  void didUpdateWidget(covariant MaterialWaveSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_current == null) {
      if (widget.paused) {
        pause();
      } else {
        resume();
      }
    }
  }

  void pause() {
    _paused = true;
    _running = false;
    setState(() {});
  }

  void resume() {
    _paused = false;
    _running = true;
    setState(() {});
  }

  void _onPointerDown(PointerDownEvent e, BoxConstraints constraints) {
    if (widget.onChanged != null) {
      setState(() {
        if (widget.transitionOnChange && !_paused) {
          _running = false;
        }
        _current = e.localPosition.dx / constraints.maxWidth * (widget.max - widget.min);
      });
    }
  }

  void _onPointerMove(PointerMoveEvent e, BoxConstraints constraints) {
    if (widget.onChanged != null) {
      setState(() {
        if (widget.transitionOnChange && !_paused) {
          _running = false;
        }
        _current = e.localPosition.dx / constraints.maxWidth * (widget.max - widget.min);
      });
    }
  }

  void _onPointerUp(PointerUpEvent e, BoxConstraints constraints) {
    if (widget.onChanged != null) {
      setState(() {
        if (widget.transitionOnChange && !_paused) {
          _running = true;
        }
        _current = null;
      });
      final value = e.localPosition.dx / constraints.maxWidth * (widget.max - widget.min);
      widget.onChanged?.call(value.clamp(widget.min, widget.max));
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      const multiplier = 1 << 32;
      final distance = widget.height * multiplier;
      final duration = widget.velocity * multiplier;
      _controller.animateTo(
        distance,
        duration: Duration(milliseconds: duration.round()),
        curve: Curves.linear,
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaults = theme.useMaterial3 ? _SliderDefaultsM3(context) : _SliderDefaultsM2(context);

    SliderThemeData sliderTheme = SliderTheme.of(context);
    sliderTheme = sliderTheme.copyWith(
      trackHeight: sliderTheme.trackHeight ?? defaults.trackHeight,
      activeTrackColor: sliderTheme.activeTrackColor ?? defaults.activeTrackColor,
      inactiveTrackColor: sliderTheme.inactiveTrackColor ?? defaults.inactiveTrackColor,
      secondaryActiveTrackColor: sliderTheme.secondaryActiveTrackColor ?? defaults.secondaryActiveTrackColor,
      disabledActiveTrackColor: sliderTheme.disabledActiveTrackColor ?? defaults.disabledActiveTrackColor,
      disabledInactiveTrackColor: sliderTheme.disabledInactiveTrackColor ?? defaults.disabledInactiveTrackColor,
      disabledSecondaryActiveTrackColor: sliderTheme.disabledSecondaryActiveTrackColor ?? defaults.disabledSecondaryActiveTrackColor,
      activeTickMarkColor: sliderTheme.activeTickMarkColor ?? defaults.activeTickMarkColor,
      inactiveTickMarkColor: sliderTheme.inactiveTickMarkColor ?? defaults.inactiveTickMarkColor,
      disabledActiveTickMarkColor: sliderTheme.disabledActiveTickMarkColor ?? defaults.disabledActiveTickMarkColor,
      disabledInactiveTickMarkColor: sliderTheme.disabledInactiveTickMarkColor ?? defaults.disabledInactiveTickMarkColor,
      thumbColor: sliderTheme.thumbColor ?? defaults.thumbColor,
      disabledThumbColor: sliderTheme.disabledThumbColor ?? defaults.disabledThumbColor,
      valueIndicatorTextStyle: sliderTheme.valueIndicatorTextStyle ?? defaults.valueIndicatorTextStyle,
    );

    if (color != sliderTheme.activeTrackColor) {
      defaultPath = null;
      defaultPaint = null;
    }

    color ??= sliderTheme.activeTrackColor;
    defaultPath ??= SinePainter.calculatePath(widget.height / 25.0, _amplitude, 0.0, widget.height, widget.height);
    defaultPaint ??= CustomPaint(
      key: const ValueKey(true),
      painter: SinePainter(
        color: sliderTheme.activeTrackColor!,
        delta: widget.height / 25.0,
        phase: 0.0,
        amplitude: _amplitude,
        strokeWidth: sliderTheme.trackHeight!,
        path: defaultPath,
      ),
      size: Size(widget.height, widget.height),
    );

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Listener(
            onPointerDown: (e) => _onPointerDown(e, constraints),
            onPointerMove: (e) => _onPointerMove(e, constraints),
            onPointerUp: (e) => _onPointerUp(e, constraints),
            child: Container(
              color: Colors.transparent,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipRect(
                    clipper: RectClipper(_percent),
                    child: SizedBox(
                      width: constraints.maxWidth,
                      height: widget.height,
                      child: ListView.builder(
                        controller: _controller,
                        itemExtent: widget.height,
                        padding: EdgeInsets.zero,
                        scrollDirection: Axis.horizontal,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, _) => TweenAnimationBuilder<double>(
                          tween: Tween<double>(
                            begin: _running ? _amplitude : 0.0,
                            end: _running ? _amplitude : 0.0,
                          ),
                          curve: widget.transitionCurve,
                          duration: widget.transitionDuration,
                          builder: (context, value, _) {
                            if (value == _amplitude) {
                              return defaultPaint!;
                            }
                            return CustomPaint(
                              key: ValueKey(value),
                              painter: SinePainter(
                                color: sliderTheme.activeTrackColor!,
                                delta: widget.height / 25.0,
                                phase: 0.0,
                                amplitude: value,
                                strokeWidth: sliderTheme.trackHeight!,
                              ),
                              size: Size(widget.height, widget.height),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: constraints.maxWidth * _percent - widget.thumbWidth / 2.0,
                    right: 0.0,
                    child: Container(
                      color: sliderTheme.inactiveTrackColor!,
                      height: sliderTheme.trackHeight!,
                    ),
                  ),
                  Positioned(
                    left: (constraints.maxWidth * _percent - widget.thumbWidth / 3.0).limit(constraints.maxWidth * _percent - widget.thumbWidth),
                    child: widget.thumbBuilder?.call(context) ??
                        Container(
                          width: widget.thumbWidth,
                          height: widget.height * 0.6,
                          decoration: BoxDecoration(
                            color: sliderTheme.thumbColor!,
                            borderRadius: BorderRadius.circular(
                              widget.thumbWidth / 2.0,
                            ),
                          ),
                        ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// {@template sine_painter}
///
/// SinePainter
/// -----------
/// A [CustomPainter] to draw a sine wave.
///
/// {@endtemplate}
class SinePainter extends CustomPainter {
  /// The color of the wave.
  final Color color;

  /// The delta used to calculate the [sin] value when drawing the path.
  final double delta;

  /// The phase of the wave.
  final double phase;

  /// The amplitude of the wave.
  final double amplitude;

  /// The stroke-cap of the wave.
  final StrokeCap strokeCap;

  /// The stroke-width of the wave.
  final double strokeWidth;

  /// Pre-calculated [Path] to draw the wave.
  final Path? path;

  /// {@macro sine_painter}
  SinePainter({
    required this.color,
    this.delta = 2.0,
    this.phase = pi,
    this.amplitude = 16.0,
    this.strokeCap = StrokeCap.butt,
    this.strokeWidth = 2.0,
    this.path,
  });

  static Path calculatePath(double delta, double amplitude, double phase, double width, double height) {
    final path = Path();
    for (double x = 0.0; x <= width + delta; x += delta) {
      final y = height / 2.0 + amplitude * sin(x / width * 2 * pi + phase);
      if (x == 0.0) {
        path.moveTo(x, y);
      }
      path.lineTo(x, y);
    }
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeCap = strokeCap
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    canvas.drawPath(
      path ?? calculatePath(delta, amplitude, phase, size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    final previous = (oldDelegate as SinePainter);
    return color != previous.color || delta != previous.delta || phase != previous.phase || amplitude != previous.amplitude || strokeCap != previous.strokeCap || strokeWidth != previous.strokeWidth;
  }
}

/// {@template rect_clipper}
///
/// RectClipper
/// -----------
/// A [CustomClipper] to clip the wave.
///
/// {@endtemplate}
class RectClipper extends CustomClipper<Rect> {
  /// The percentage of the clip.
  final double percent;

  /// {@macro rect_clipper}
  const RectClipper(this.percent);

  @override
  Rect getClip(Size size) => Rect.fromLTRB(0.0, 0.0, size.width * percent, size.height);

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) => (oldClipper as RectClipper).percent != percent;
}

// --------------------------------------------------

class _SliderDefaultsM3 extends SliderThemeData {
  _SliderDefaultsM3(this.context) : super(trackHeight: 2.5);

  final BuildContext context;
  late final ColorScheme _colors = Theme.of(context).colorScheme;

  @override
  Color? get activeTrackColor => _colors.primary;

  @override
  Color? get inactiveTrackColor => _colors.primary.withOpacity(0.54);

  @override
  Color? get secondaryActiveTrackColor => _colors.primary.withOpacity(0.54);

  @override
  Color? get disabledActiveTrackColor => _colors.onSurface.withOpacity(0.38);

  @override
  Color? get disabledInactiveTrackColor => _colors.onSurface.withOpacity(0.12);

  @override
  Color? get disabledSecondaryActiveTrackColor => _colors.onSurface.withOpacity(0.12);

  @override
  Color? get activeTickMarkColor => _colors.onPrimary.withOpacity(0.38);

  @override
  Color? get inactiveTickMarkColor => _colors.onSurfaceVariant.withOpacity(0.38);

  @override
  Color? get disabledActiveTickMarkColor => _colors.onSurface.withOpacity(0.38);

  @override
  Color? get disabledInactiveTickMarkColor => _colors.onSurface.withOpacity(0.38);

  @override
  Color? get thumbColor => _colors.primary;

  @override
  Color? get disabledThumbColor => Color.alphaBlend(_colors.onSurface.withOpacity(0.38), _colors.surface);

  @override
  Color? get overlayColor => WidgetStateColor.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.dragged)) {
          return _colors.primary.withOpacity(0.12);
        }
        if (states.contains(WidgetState.hovered)) {
          return _colors.primary.withOpacity(0.08);
        }
        if (states.contains(WidgetState.focused)) {
          return _colors.primary.withOpacity(0.12);
        }

        return Colors.transparent;
      });

  @override
  TextStyle? get valueIndicatorTextStyle => Theme.of(context).textTheme.labelMedium!.copyWith(
        color: _colors.onPrimary,
      );

  @override
  SliderComponentShape? get valueIndicatorShape => const DropSliderValueIndicatorShape();
}

class _SliderDefaultsM2 extends SliderThemeData {
  _SliderDefaultsM2(this.context)
      : _colors = Theme.of(context).colorScheme,
        super(trackHeight: 2.5);

  final BuildContext context;
  final ColorScheme _colors;

  @override
  Color? get activeTrackColor => _colors.primary;

  @override
  Color? get inactiveTrackColor => _colors.primary.withOpacity(0.24);

  @override
  Color? get secondaryActiveTrackColor => _colors.primary.withOpacity(0.54);

  @override
  Color? get disabledActiveTrackColor => _colors.onSurface.withOpacity(0.32);

  @override
  Color? get disabledInactiveTrackColor => _colors.onSurface.withOpacity(0.12);

  @override
  Color? get disabledSecondaryActiveTrackColor => _colors.onSurface.withOpacity(0.12);

  @override
  Color? get activeTickMarkColor => _colors.onPrimary.withOpacity(0.54);

  @override
  Color? get inactiveTickMarkColor => _colors.primary.withOpacity(0.54);

  @override
  Color? get disabledActiveTickMarkColor => _colors.onPrimary.withOpacity(0.12);

  @override
  Color? get disabledInactiveTickMarkColor => _colors.onSurface.withOpacity(0.12);

  @override
  Color? get thumbColor => _colors.primary;

  @override
  Color? get disabledThumbColor => Color.alphaBlend(_colors.onSurface.withOpacity(.38), _colors.surface);

  @override
  Color? get overlayColor => _colors.primary.withOpacity(0.12);

  @override
  TextStyle? get valueIndicatorTextStyle => Theme.of(context).textTheme.bodyLarge!.copyWith(
        color: _colors.onPrimary,
      );

  @override
  SliderComponentShape? get valueIndicatorShape => const RectangularSliderValueIndicatorShape();
}

// --------------------------------------------------

extension on double {
  double limit(double value) => max(min(this, value), 0.0);
}
