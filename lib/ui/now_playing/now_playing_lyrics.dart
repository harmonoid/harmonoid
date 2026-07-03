import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:system_fonts/system_fonts.dart';

import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/core/media_player/media_player.dart';
import 'package:harmonoid/extensions/string.dart';
import 'package:harmonoid/state/lyrics_notifier.dart';
import 'package:harmonoid/utils/rendering.dart';

class NowPlayingLyrics extends StatefulWidget {
  final ValueNotifier<bool>? selectionModeNotifier;
  const NowPlayingLyrics({super.key, this.selectionModeNotifier});

  @override
  State<NowPlayingLyrics> createState() => _NowPlayingLyricsState();
}

class _NowPlayingLyricsState extends State<NowPlayingLyrics> {
  String? _fontFamily;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final fontFamily = Configuration.instance.lyricsViewFontFamily;
        _fontFamily = fontFamily.isEmpty ? '' : await SystemFonts().loadFont(fontFamily);
      } catch (exception, stacktrace) {
        debugPrint(exception.toString());
        debugPrint(stacktrace.toString());
        _fontFamily = '';
      }
      setState(() {});
    });
  }

  void Function(int)? _onLyricTap(LyricsNotifier lyricsNotifier) {
    if (lyricsNotifier.lyrics.isEmpty) return null;
    return (i) {
      if (i >= 0 && i < lyricsNotifier.lyrics.length) {
        lyricsNotifier.setIndex(i);
        MediaPlayer.instance.seek(Duration(milliseconds: lyricsNotifier.lyrics[i].timestamp) + const Duration(milliseconds: 100));
      }
    };
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return AnimatedOpacity(
      curve: Curves.easeInOut,
      opacity: _fontFamily == null ? 0.0 : 1.0,
      duration: Theme.of(context).extension<AnimationDuration>()?.fast ?? Duration.zero,
      child: Consumer<LyricsNotifier>(
        builder: (context, lyricsNotifier, _) {
          final lyricsList = lyricsNotifier.lyrics.map((e) => e.text).toList();
          final subscriptsList = lyricsNotifier.translation.map((e) => e.text).toList();
          return LyricsView(
            selectionModeNotifier: widget.selectionModeNotifier,
            index: lyricsNotifier.index,
            lyrics: lyricsList,
            subscripts: subscriptsList,
            onLyricTap: _onLyricTap(lyricsNotifier),
            padding: const EdgeInsets.only(left: 32.0, right: 32.0),
            focusedTextStyle: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontSize: Configuration.instance.lyricsViewFocusedFontSize,
              height: Configuration.instance.lyricsViewFocusedLineHeight,
              fontFamily: _fontFamily?.nullIfBlank(),
            ),
            unfocusedTextStyle: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontSize: Configuration.instance.lyricsViewUnfocusedFontSize,
              height: Configuration.instance.lyricsViewUnfocusedLineHeight,
              fontFamily: _fontFamily?.nullIfBlank(),
            ),
            textAlign: Configuration.instance.lyricsViewTextAlign,
            alignment: Alignment.center,
            viewportWidth: 1920.0 * 1.0,
            viewportHeight: 1080.0 * 0.6,
          );
        },
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    throw UnimplementedError();
  }

  Widget _buildMobileLayout(BuildContext context) {
    return AnimatedOpacity(
      curve: Curves.easeInOut,
      opacity: _fontFamily == null ? 0.0 : 1.0,
      duration: Theme.of(context).extension<AnimationDuration>()?.fast ?? Duration.zero,
      child: Consumer<LyricsNotifier>(
        builder: (context, lyricsNotifier, _) {
          final lyricsList = lyricsNotifier.lyrics.map((e) => e.text).toList();
          final subscriptsList = lyricsNotifier.translation.map((e) => e.text).toList();
          return LyricsView(
            selectionModeNotifier: widget.selectionModeNotifier,
            index: lyricsNotifier.index,
            lyrics: lyricsList,
            subscripts: subscriptsList,
            onLyricTap: _onLyricTap(lyricsNotifier),
            padding: EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: MediaQuery.sizeOf(context).height * -0.2,
            ),
            focusedTextStyle: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontSize: Configuration.instance.lyricsViewFocusedFontSize,
              height: Configuration.instance.lyricsViewFocusedLineHeight,
              fontFamily: _fontFamily?.nullIfBlank(),
            ),
            unfocusedTextStyle: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontSize: Configuration.instance.lyricsViewUnfocusedFontSize,
              height: Configuration.instance.lyricsViewUnfocusedLineHeight,
              fontFamily: _fontFamily?.nullIfBlank(),
            ),
            textAlign: Configuration.instance.lyricsViewTextAlign,
            alignment: Alignment.center,
            viewportWidth: MediaQuery.sizeOf(context).width,
            viewportHeight: MediaQuery.sizeOf(context).height,
          );
        },
      ),
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
