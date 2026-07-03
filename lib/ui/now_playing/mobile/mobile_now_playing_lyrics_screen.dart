import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/state/lyrics/lyrics_notifier.dart';
import 'package:harmonoid/state/now_playing_color_palette_notifier.dart';
import 'package:harmonoid/state/theme_notifier.dart';
import 'package:harmonoid/ui/now_playing/now_playing_background.dart';
import 'package:harmonoid/ui/now_playing/now_playing_colors.dart';
import 'package:harmonoid/ui/now_playing/now_playing_lyrics.dart';
import 'package:harmonoid/ui/now_playing/now_playing_lyrics_control_panel.dart';
import 'package:harmonoid/utils/rendering.dart';

class MobileNowPlayingLyricsScreen extends StatefulWidget {
  const MobileNowPlayingLyricsScreen({super.key});

  @override
  State<MobileNowPlayingLyricsScreen> createState() => _MobileNowPlayingLyricsScreenState();
}

class _MobileNowPlayingLyricsScreenState extends State<MobileNowPlayingLyricsScreen> {
  final ValueNotifier<bool> _selectionModeNotifier = ValueNotifier<bool>(false);

  @override
  void dispose() {
    super.dispose();
    _selectionModeNotifier.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
        systemStatusBarContrastEnforced: false,
        systemNavigationBarContrastEnforced: false,
      ),
      child: Consumer<NowPlayingColorPaletteNotifier>(
        builder: (context, nowPlayingColorPaletteNotifier, _) {
          return Provider<NowPlayingColors>.value(
            value: NowPlayingColors.fromPalette(
              context,
              null,
            ),
            builder: (context, _) {
              return Theme(
                data: ThemeNotifier.instance.darkTheme,
                child: Scaffold(
                  body: Stack(
                    children: [
                      const Positioned.fill(child: NowPlayingBackground()),
                      Positioned.fill(
                        child: ColoredBox(color: Colors.black.withValues(alpha: 0.2)),
                      ),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: const [0.0, 0.2, 0.5, 0.8],
                              colors: [
                                Colors.black.withValues(alpha: 0.2),
                                Colors.transparent,
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.2),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned.fill(child: NowPlayingLyrics(selectionModeNotifier: _selectionModeNotifier)),
                      Positioned(
                        top: MediaQuery.paddingOf(context).top + 8.0,
                        left: MediaQuery.paddingOf(context).left + 8.0,
                        child: IconButton(
                          onPressed: context.pop,
                          color: Theme.of(context).extension<IconColors>()?.appBarDark,
                          icon: const Icon(Icons.arrow_back),
                        ),
                      ),
                      Positioned(
                        top: MediaQuery.paddingOf(context).top + 8.0,
                        right: MediaQuery.paddingOf(context).right + 8.0,
                        child: Consumer<LyricsNotifier>(
                          builder: (context, lyricsNotifier, _) {
                            final color = Theme.of(context).extension<IconColors>()?.appBarDark;
                            return IconButton(
                              onPressed: () => NowPlayingLyricsControlPanel.showTranslationLanguageSelection(context, subscription: true),
                              color: color,
                              tooltip: Localization.instance.TRANSLATION,
                              icon: lyricsNotifier.translationLoading
                                  ? SizedBox.square(
                                      dimension: 18.0,
                                      child: CircularProgressIndicator(color: color),
                                    )
                                  : const Icon(Icons.translate),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        bottom: 16.0 + MediaQuery.paddingOf(context).bottom,
                        left: 16.0 + MediaQuery.paddingOf(context).left,
                        right: 16.0 + MediaQuery.paddingOf(context).right,
                        child: ValueListenableBuilder<bool>(
                          valueListenable: _selectionModeNotifier,
                          builder: (context, selectionMode, child) {
                            return IgnorePointer(
                              ignoring: !selectionMode,
                              child: AnimatedOpacity(
                                opacity: selectionMode ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 200),
                                child: child,
                              ),
                            );
                          },
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: context.read<NowPlayingColors>().foreground,
                              foregroundColor: context.read<NowPlayingColors>().foregroundIcon,
                            ),
                            onPressed: () {
                              _selectionModeNotifier.value = false;
                            },
                            child: Text(label(Localization.instance.CANCEL)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
