import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/interface/home.dart';
import 'package:harmonoid/state/lyrics.dart';
import 'package:harmonoid/state/visuals.dart';
import 'package:harmonoid/state/collection_refresh.dart';
import 'package:harmonoid/state/now_playing_color_palette.dart';
import 'package:harmonoid/utils/keyboard_shortcuts.dart';
import 'package:harmonoid/constants/language.dart';

class Harmonoid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => Visuals.instance..update(context: context),
      builder: (context, _) => Consumer<Visuals>(
        builder: (context, visuals, _) => MultiProvider(
          builder: (context, _) => KeyboardShortcutsListener(
            child: MaterialApp(
              scrollBehavior: const ScrollBehavior(),
              debugShowCheckedModeBanner: false,
              theme: visuals.theme,
              darkTheme: visuals.darkTheme,
              themeMode: visuals.themeMode,
              home: Home(),
            ),
          ),
          providers: [
            ChangeNotifierProvider(
              create: (context) => Collection.instance,
            ),
            ChangeNotifierProvider(
              create: (context) => CollectionRefresh.instance,
            ),
            ChangeNotifierProvider(
              create: (_) => Playback.instance,
            ),
            ChangeNotifierProvider(
              create: (context) => Language.instance,
            ),
            ChangeNotifierProvider(
              create: (_) => Lyrics.instance,
            ),
            ChangeNotifierProvider(
              create: (_) => NowPlayingColorPalette.instance,
            ),
          ],
        ),
      ),
    );
  }
}

class ScrollBehavior extends MaterialScrollBehavior {
  const ScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    switch (getPlatform(context)) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        return const ClampingScrollPhysics();
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return CustomScrollPhysics();
      case TargetPlatform.iOS:
        return const BouncingScrollPhysics();
      case TargetPlatform.macOS:
        return BouncingScrollPhysics(
          decelerationRate: ScrollDecelerationRate.fast,
        );
    }
  }

  @override
  Set<PointerDeviceKind> get dragDevices =>
      // Specifically for GNU/Linux & Android-x86 family, where touch isn't interpreted as a drag device by Flutter apparently.
      Platform.isLinux || Platform.isAndroid
          ? PointerDeviceKind.values.toSet()
          : super.dragDevices;
}

class CustomScrollPhysics extends ScrollPhysics {
  const CustomScrollPhysics({super.parent});

  @override
  BouncingScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return BouncingScrollPhysics(parent: buildParent(ancestor));
  }

  double frictionFactor(double overscrollFraction) {
    return 0.07 * math.pow(1 - overscrollFraction, 2);
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    assert(offset != 0.0);
    assert(position.minScrollExtent <= position.maxScrollExtent);

    if (!position.outOfRange) {
      return offset;
    }

    final double overscrollPastStart =
        math.max(position.minScrollExtent - position.pixels, 0.0);
    final double overscrollPastEnd =
        math.max(position.pixels - position.maxScrollExtent, 0.0);
    final double overscrollPast =
        math.max(overscrollPastStart, overscrollPastEnd);
    final bool easing = (overscrollPastStart > 0.0 && offset < 0.0) ||
        (overscrollPastEnd > 0.0 && offset > 0.0);

    final double friction = easing
        ? frictionFactor(
            (overscrollPast - offset.abs()) / position.viewportDimension)
        : frictionFactor(overscrollPast / position.viewportDimension);
    final double direction = offset.sign;

    return direction * _applyFriction(overscrollPast, offset.abs(), friction);
  }

  static double _applyFriction(
      double extentOutside, double absDelta, double gamma) {
    assert(absDelta > 0);
    double total = 0.0;
    if (extentOutside > 0) {
      final double deltaToLimit = extentOutside / gamma;
      if (absDelta < deltaToLimit) {
        return absDelta * gamma;
      }
      total += extentOutside;
      absDelta -= deltaToLimit;
    }
    return total + absDelta;
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    // Taken from [ClampingScrollPhysics].
    // This disables over-scrolling past the edge of the content.
    if (value < position.pixels &&
        position.pixels <= position.minScrollExtent) {
      return value - position.pixels;
    }
    if (position.maxScrollExtent <= position.pixels &&
        position.pixels < value) {
      return value - position.pixels;
    }
    if (value < position.minScrollExtent &&
        position.minScrollExtent < position.pixels) {
      return value - position.minScrollExtent;
    }
    if (position.pixels < position.maxScrollExtent &&
        position.maxScrollExtent < value) {
      return value - position.maxScrollExtent;
    }
    return 0.0;
  }

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    if (velocity.abs() >= tolerance.velocity || position.outOfRange) {
      return BouncingScrollSimulation(
        spring: spring,
        position: position.pixels,
        velocity: velocity,
        leadingExtent: position.minScrollExtent,
        trailingExtent: position.maxScrollExtent,
        tolerance: tolerance,
        constantDeceleration: 1400.0,
      );
    }
    return null;
  }

  @override
  double get minFlingVelocity => kMinFlingVelocity * 2.0;

  @override
  double carriedMomentum(double existingVelocity) {
    return existingVelocity.sign *
        math.min(0.000816 * math.pow(existingVelocity.abs(), 1.967).toDouble(),
            40000.0);
  }

  @override
  double get dragStartDistanceMotionThreshold => 3.5;

  @override
  double get maxFlingVelocity {
    return kMaxFlingVelocity * 8.0;
  }

  @override
  SpringDescription get spring {
    return SpringDescription.withDampingRatio(
      mass: 0.3,
      stiffness: 75.0,
      ratio: 1.3,
    );
  }
}
