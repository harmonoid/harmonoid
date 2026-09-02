/// MIT License
///
/// Copyright (c) 2022 Hitesh Kumar Saini <saini123hitesh@gmail.com>
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in all
/// copies or substantial portions of the Software.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
/// SOFTWARE.

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

  double? _current;
  late bool _paused = widget.paused;
  late bool _running = !widget.paused;
  late final AnimationController _phaseController;

  @override
  void didUpdateWidget(covariant MaterialWaveSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.velocity != oldWidget.velocity) {
      _phaseController.duration = _phaseDuration;
      if (_running) {
        _syncPhaseAnimation();
      }
    }
    if (widget.paused != oldWidget.paused) {
      _paused = widget.paused;
      _running = !widget.paused && _current == null;
      _syncPhaseAnimation();
    }
  }

  void pause() {
    if (_paused) return;
    _paused = true;
    _running = false;
    _syncPhaseAnimation();
    setState(() {});
  }

  void resume() {
    if (!_paused) return;
    _paused = false;
    _running = true;
    _syncPhaseAnimation();
    setState(() {});
  }

  Duration get _phaseDuration => Duration(milliseconds: max(1, widget.velocity.round()));

  void _syncPhaseAnimation() {
    if (_running) {
      _phaseController.repeat();
    } else {
      _phaseController.stop();
    }
  }

  void _onPointerDown(PointerDownEvent e, BoxConstraints constraints) {
    if (widget.onChanged != null) {
      setState(() {
        if (widget.transitionOnChange && !_paused) {
          _running = false;
          _syncPhaseAnimation();
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
          _syncPhaseAnimation();
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
          _syncPhaseAnimation();
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
    _phaseController = AnimationController(vsync: this, duration: _phaseDuration);
    _syncPhaseAnimation();
  }

  @override
  void dispose() {
    _phaseController.dispose();
    super.dispose();
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
                    child: RepaintBoundary(
                      child: SizedBox(
                        width: constraints.maxWidth,
                        height: widget.height,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween<double>(end: _running ? _amplitude : 0.0),
                          curve: widget.transitionCurve,
                          duration: widget.transitionDuration,
                          builder: (context, amplitude, _) => CustomPaint(
                            painter: _WavePainter(
                              color: sliderTheme.activeTrackColor!,
                              animation: _phaseController,
                              amplitude: amplitude,
                              period: widget.height,
                              sampleInterval: widget.height / 25.0,
                              strokeWidth: sliderTheme.trackHeight!,
                            ),
                          ),
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
                    child:
                        widget.thumbBuilder?.call(context) ??
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

class _WavePainter extends CustomPainter {
  final Color color;
  final Animation<double> animation;
  final double amplitude;
  final double period;
  final double sampleInterval;
  final double strokeWidth;
  Path? _path;
  Size? _pathSize;

  _WavePainter({
    required this.color,
    required this.animation,
    required this.amplitude,
    required this.period,
    required this.sampleInterval,
    required this.strokeWidth,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    if (_path == null || _pathSize != size) {
      final path = Path();
      for (double x = 0.0; x <= size.width + period * 2.0 + sampleInterval; x += sampleInterval) {
        final y = size.height / 2.0 + amplitude * sin(x / period * 2.0 * pi);
        if (x == 0.0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      _path = path;
      _pathSize = size;
    }

    canvas.save();
    canvas.translate(-period * (1.0 + animation.value), 0.0);
    canvas.drawPath(_path!, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    final previous = oldDelegate as _WavePainter;
    return color != previous.color ||
        animation != previous.animation ||
        amplitude != previous.amplitude ||
        period != previous.period ||
        sampleInterval != previous.sampleInterval ||
        strokeWidth != previous.strokeWidth;
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
  Color? get inactiveTrackColor => _colors.primary.withValues(alpha: 0.38);

  @override
  Color? get secondaryActiveTrackColor => _colors.primary.withValues(alpha: 0.54);

  @override
  Color? get disabledActiveTrackColor => _colors.onSurface.withValues(alpha: 0.38);

  @override
  Color? get disabledInactiveTrackColor => _colors.onSurface.withValues(alpha: 0.12);

  @override
  Color? get disabledSecondaryActiveTrackColor => _colors.onSurface.withValues(alpha: 0.12);

  @override
  Color? get activeTickMarkColor => _colors.onPrimary.withValues(alpha: 0.38);

  @override
  Color? get inactiveTickMarkColor => _colors.onSurfaceVariant.withValues(alpha: 0.38);

  @override
  Color? get disabledActiveTickMarkColor => _colors.onSurface.withValues(alpha: 0.38);

  @override
  Color? get disabledInactiveTickMarkColor => _colors.onSurface.withValues(alpha: 0.38);

  @override
  Color? get thumbColor => _colors.primary;

  @override
  Color? get disabledThumbColor => Color.alphaBlend(_colors.onSurface.withValues(alpha: 0.38), _colors.surface);

  @override
  Color? get overlayColor => WidgetStateColor.resolveWith((Set<WidgetState> states) {
    if (states.contains(WidgetState.dragged)) {
      return _colors.primary.withValues(alpha: 0.12);
    }
    if (states.contains(WidgetState.hovered)) {
      return _colors.primary.withValues(alpha: 0.08);
    }
    if (states.contains(WidgetState.focused)) {
      return _colors.primary.withValues(alpha: 0.12);
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
  _SliderDefaultsM2(this.context) : _colors = Theme.of(context).colorScheme, super(trackHeight: 2.5);

  final BuildContext context;
  final ColorScheme _colors;

  @override
  Color? get activeTrackColor => _colors.primary;

  @override
  Color? get inactiveTrackColor => _colors.primary.withValues(alpha: 0.24);

  @override
  Color? get secondaryActiveTrackColor => _colors.primary.withValues(alpha: 0.54);

  @override
  Color? get disabledActiveTrackColor => _colors.onSurface.withValues(alpha: 0.32);

  @override
  Color? get disabledInactiveTrackColor => _colors.onSurface.withValues(alpha: 0.12);

  @override
  Color? get disabledSecondaryActiveTrackColor => _colors.onSurface.withValues(alpha: 0.12);

  @override
  Color? get activeTickMarkColor => _colors.onPrimary.withValues(alpha: 0.54);

  @override
  Color? get inactiveTickMarkColor => _colors.primary.withValues(alpha: 0.54);

  @override
  Color? get disabledActiveTickMarkColor => _colors.onPrimary.withValues(alpha: 0.12);

  @override
  Color? get disabledInactiveTickMarkColor => _colors.onSurface.withValues(alpha: 0.12);

  @override
  Color? get thumbColor => _colors.primary;

  @override
  Color? get disabledThumbColor => Color.alphaBlend(_colors.onSurface.withValues(alpha: .38), _colors.surface);

  @override
  Color? get overlayColor => _colors.primary.withValues(alpha: 0.12);

  @override
  TextStyle? get valueIndicatorTextStyle => Theme.of(context).textTheme.bodyLarge!.copyWith(color: _colors.onPrimary);

  @override
  SliderComponentShape? get valueIndicatorShape => const RectangularSliderValueIndicatorShape();
}

// --------------------------------------------------

extension on double {
  double limit(double value) => max(min(this, value), 0.0);
}
