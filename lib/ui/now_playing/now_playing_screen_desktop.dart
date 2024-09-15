import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/material.dart';
import 'package:harmonoid/core/media_player.dart';
import 'package:harmonoid/state/now_playing_color_palette_notifier.dart';
import 'package:harmonoid/utils/constants.dart';
import 'package:mesh_gradient/mesh_gradient.dart';
import 'package:provider/provider.dart';

class NowPlayingScreenDesktop extends StatefulWidget {
  const NowPlayingScreenDesktop({super.key});

  @override
  State<NowPlayingScreenDesktop> createState() => _NowPlayingScreenDesktopState();
}

class _NowPlayingScreenDesktopState extends State<NowPlayingScreenDesktop> {
  @override
  Widget build(BuildContext context) {
    return Consumer<MediaPlayer>(
      builder: (context, mediaPlayer, _) {
        return Stack(
          children: [
            Positioned.fill(
              child: Consumer<NowPlayingColorPaletteNotifier>(
                builder: (context, nowPlayingColorPaletteNotifier, _) {
                  final palette = nowPlayingColorPaletteNotifier.palette ?? [];
                  final colors = switch (palette.length) {
                    0 => [Colors.black, Colors.black, Colors.black, Colors.black],
                    1 => [palette.elementAt(0), palette.elementAt(0), palette.elementAt(0), palette.elementAt(0)],
                    2 => [palette.reversed.elementAt(0), palette.elementAt(0), palette.reversed.elementAt(0), palette.elementAt(0)],
                    3 => [palette.reversed.elementAt(0), palette.elementAt(0), palette.reversed.elementAt(1), palette.elementAt(0)],
                    _ => [palette.reversed.elementAt(0), palette.elementAt(0), palette.reversed.elementAt(1), palette.elementAt(1)],
                  };
                  return AnimatedMeshGradient(
                    colors: colors,
                    options: AnimatedMeshGradientOptions(),
                  );
                },
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.2, 0.5, 0.8],
                    colors: [
                      Colors.black.withOpacity(0.4),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withOpacity(0.4),
                    ],
                  ),
                ),
              ),
            ),
            const Positioned(
              top: 0.0,
              left: 0.0,
              right: 0.0,
              child: DesktopAppBar(
                caption: kCaption,
                color: Colors.transparent,
                elevation: 0.0,
              ),
            ),
          ],
        );
      },
    );
  }
}
