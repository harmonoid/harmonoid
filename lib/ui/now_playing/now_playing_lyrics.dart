import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/state/lyrics_notifier.dart';
import 'package:harmonoid/utils/rendering.dart';

class NowPlayingLyrics extends StatefulWidget {
  const NowPlayingLyrics({super.key});

  @override
  State<NowPlayingLyrics> createState() => NowPlayingLyricsState();
}

class NowPlayingLyricsState extends State<NowPlayingLyrics> {
  Widget _buildDesktopLayout(BuildContext context) {
    return Consumer<LyricsNotifier>(
      builder: (context, lyricsNotifier, _) {
        return LyricsView(
          index: lyricsNotifier.index,
          lyrics: lyricsNotifier.lyrics.map((e) => e.text).toList(),
          padding: EdgeInsets.only(
            left: 32.0,
            right: 32.0,
            top: kDesktopAppBarHeight + MediaQuery.of(context).size.height * 0.1,
          ),
          focusedTextStyle: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: Configuration.instance.lyricsViewFocusedFontSize,
                height: Configuration.instance.lyricsViewFocusedLineHeight,
              ),
          unfocusedTextStyle: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: Configuration.instance.lyricsViewUnfocusedFontSize,
                height: Configuration.instance.lyricsViewUnfocusedLineHeight,
              ),
          textAlign: Configuration.instance.lyricsViewTextAlign,
        );
      },
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    throw UnimplementedError();
  }

  Widget _buildMobileLayout(BuildContext context) {
    throw UnimplementedError();
  }

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
