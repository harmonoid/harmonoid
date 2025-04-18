import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mesh_gradient/mesh_gradient.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/state/now_playing_color_palette_notifier.dart';

class NowPlayingBackground extends StatelessWidget {
  const NowPlayingBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NowPlayingColorPaletteNotifier>(
      builder: (context, nowPlayingColorPaletteNotifier, _) {
        final palette = nowPlayingColorPaletteNotifier.palette?.where((e) => e.computeLuminance() < 0.5).toList() ?? [];
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
}
