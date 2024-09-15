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
  static const kRippleDimension = 2.0;

  double width = 1.0;
  double height = 1.0;
  Widget? background;
  Widget? ripple;

  @override
  void didUpdateWidget(covariant RippleSurface oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.color != widget.color) {
      // The change in color was very fast, so we don't need to animate the ripple.
      if (ripple != null) {
        setState(() {
          ripple = null;
          background = Positioned.fill(child: Container(color: widget.color));
        });
      }

      setState(() {
        ripple = TweenAnimationBuilder<double>(
          key: ValueKey(Random().nextDouble()),
          tween: Tween<double>(
            begin: 1.0,
            end: max(width / kRippleDimension, height / kRippleDimension) * 2.0,
          ),
          duration: widget.duration ?? Theme.of(context).extension<AnimationDuration>()?.slow ?? Duration.zero,
          curve: widget.curve ?? Curves.easeInOut,
          onEnd: () {
            setState(() {
              background = Positioned.fill(child: Container(color: widget.color));
              ripple = null;
            });
          },
          builder: (context, scale, _) {
            return Transform.scale(
              scale: scale,
              child: Container(
                width: kRippleDimension,
                height: kRippleDimension,
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
          width = constraints.maxWidth;
          height = constraints.maxHeight;
          return Stack(
            alignment: Alignment.center,
            children: [
              if (background != null) background!,
              if (ripple != null) ripple!,
            ],
          );
        },
      ),
    );
  }
}
