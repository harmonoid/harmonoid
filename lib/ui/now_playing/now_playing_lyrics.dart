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
          key: ValueKey(MediaQuery.sizeOf(context)),
          index: lyricsNotifier.index,
          lyrics: lyricsNotifier.lyrics.map((e) => e.text).toList(),
          padding: EdgeInsets.only(
            left: 32.0,
            right: 32.0,
            top: kDesktopAppBarHeight + MediaQuery.sizeOf(context).height * 0.1,
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
          alignment: Alignment.topCenter,
        );
      },
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    throw UnimplementedError();
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Consumer<LyricsNotifier>(
      builder: (context, lyricsNotifier, _) {
        return LyricsView(
          index: lyricsNotifier.index,
          lyrics: lyricsNotifier.lyrics.map((e) => e.text).toList(),
          padding: EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: -1.0 * MediaQuery.sizeOf(context).height * 0.2,
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
          viewportWidth: MediaQuery.sizeOf(context).width,
          viewportHeight: MediaQuery.sizeOf(context).height,
          alignment: Alignment.center,
        );
      },
    );
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
