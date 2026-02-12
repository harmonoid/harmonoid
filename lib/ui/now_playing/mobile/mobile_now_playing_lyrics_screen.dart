import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/state/now_playing_color_palette_notifier.dart';
import 'package:harmonoid/state/theme_notifier.dart';
import 'package:harmonoid/ui/now_playing/now_playing_background.dart';
import 'package:harmonoid/ui/now_playing/now_playing_colors.dart';
import 'package:harmonoid/ui/now_playing/now_playing_lyrics.dart';
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
              Configuration.instance.mobileNowPlayingRipple ? nowPlayingColorPaletteNotifier.palette : null,
            ),
            builder: (context, _) {
              return Theme(
                data: ThemeNotifier.instance.darkTheme,
                child: Scaffold(
                  body: Stack(
                    children: [
                      const Positioned.fill(child: NowPlayingBackground()),
                      Positioned.fill(child: NowPlayingLyrics(selectionModeNotifier: _selectionModeNotifier)),
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
