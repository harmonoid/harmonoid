import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:harmonoid/state/theme_notifier.dart';
import 'package:harmonoid/ui/now_playing/now_playing_background.dart';
import 'package:harmonoid/ui/now_playing/now_playing_lyrics.dart';

class MobileNowPlayingLyricsScreen extends StatelessWidget {
  const MobileNowPlayingLyricsScreen({super.key});

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
      child: Theme(
        data: ThemeNotifier.instance.darkTheme,
        child: const Scaffold(
          body: Stack(
            alignment: Alignment.center,
            children: [
              NowPlayingBackground(),
              NowPlayingLyrics(),
            ],
          ),
        ),
      ),
    );
  }
}
