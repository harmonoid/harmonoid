import 'dart:math';

import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/material.dart';

/// {@template ripple_surface}
///
/// RippleSurface
/// -------------
/// Implementation to render ripple effect using the provided [color].
///
/// {@endtemplate}
class RippleSurface extends StatefulWidget {
  final Color? color;
  final Duration? duration;
  final Curve? curve;

  /// {@macro ripple_surface}
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
