import 'dart:io';
import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mesh_gradient/mesh_gradient.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/state/now_playing_color_palette_notifier.dart';
import 'package:harmonoid/state/now_playing_visuals_notifier.dart';
import 'package:harmonoid/utils/widgets.dart';

class DesktopNowPlayingScreenCarousel extends StatelessWidget {
  final int value;
  const DesktopNowPlayingScreenCarousel({super.key, required this.value});

  static const int kBuiltInCount = 2;
  static int get itemCount => kBuiltInCount + NowPlayingVisualsNotifier.instance.bundled.length + NowPlayingVisualsNotifier.instance.external.length;

  @override
  Widget build(BuildContext context) {
    return StatefulPageViewBuilder(
      index: value,
      itemBuilder: (context, i) {
        i = i % itemCount;
        if (i == 0) {
          return Consumer<NowPlayingColorPaletteNotifier>(
            builder: (context, nowPlayingColorPaletteNotifier, _) {
              final palette = nowPlayingColorPaletteNotifier.palette ?? [];
              final colors = switch (palette.length) {
                0 => [Colors.black, Colors.black, Colors.black, Colors.black],
                1 => [palette.elementAt(0), palette.elementAt(0), palette.elementAt(0), palette.elementAt(0)],
                2 => [palette.reversed.elementAt(0), palette.elementAt(0), palette.reversed.elementAt(0), palette.elementAt(0)],
                3 => [palette.reversed.elementAt(0), palette.elementAt(0), palette.reversed.elementAt(0), palette.elementAt(1)],
                _ => [palette.reversed.elementAt(0), palette.elementAt(0), palette.reversed.elementAt(1), palette.elementAt(1)],
              };
              return AnimatedSwitcher(
                duration: Theme.of(context).extension<AnimationDuration>()?.slow ?? Duration.zero,
                switchInCurve: Curves.easeInOut,
                switchOutCurve: Curves.easeInOut,
                transitionBuilder: (child, animation) {
                  return Builder(
                    builder: (context) {
                      return FadeTransition(
                        key: ValueKey<Key?>(child.key),
                        opacity: animation.status == AnimationStatus.reverse || animation.status == AnimationStatus.completed ? const AlwaysStoppedAnimation(1.0) : animation,
                        child: child,
                      );
                    },
                  );
                },
                child: SizedBox(
                  key: ValueKey(const ListEquality().hash(colors)),
                  width: double.infinity,
                  height: double.infinity,
                  child: AnimatedMeshGradient(
                    colors: colors,
                    options: AnimatedMeshGradientOptions(),
                  ),
                ),
              );
            },
          );
        }
        if (i == 1) {
          return Consumer<NowPlayingColorPaletteNotifier>(
            builder: (context, nowPlayingColorPaletteNotifier, _) {
              final palette = nowPlayingColorPaletteNotifier.palette ?? [];
              return AnimatedSwitcher(
                duration: Theme.of(context).extension<AnimationDuration>()?.slow ?? Duration.zero,
                switchInCurve: Curves.easeInOut,
                switchOutCurve: Curves.easeInOut,
                transitionBuilder: (child, animation) {
                  return Builder(
                    builder: (context) {
                      return FadeTransition(
                        key: ValueKey<Key?>(child.key),
                        opacity: animation.status == AnimationStatus.reverse || animation.status == AnimationStatus.completed ? const AlwaysStoppedAnimation(1.0) : animation,
                        child: child,
                      );
                    },
                  );
                },
                child: SizedBox(
                  key: ValueKey(const ListEquality().hash(palette)),
                  width: double.infinity,
                  height: double.infinity,
                  child: ColoredBox(color: palette.lastOrNull ?? Colors.black),
                ),
              );
            },
          );
        }
        if (i >= kBuiltInCount && i < kBuiltInCount + NowPlayingVisualsNotifier.instance.bundled.length) {
          i -= kBuiltInCount;
          return Image.asset(
            NowPlayingVisualsNotifier.instance.bundled[i],
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            filterQuality: FilterQuality.none,
          );
        }
        if (i >= kBuiltInCount + NowPlayingVisualsNotifier.instance.bundled.length && i < itemCount) {
          i -= kBuiltInCount + NowPlayingVisualsNotifier.instance.bundled.length;
          return Image.file(
            File(NowPlayingVisualsNotifier.instance.external[i]),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            filterQuality: FilterQuality.none,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
