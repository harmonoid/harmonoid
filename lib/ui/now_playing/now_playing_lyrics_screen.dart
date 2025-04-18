import 'package:flutter/material.dart';
import 'package:harmonoid/ui/now_playing/mobile/mobile_now_playing_lyrics_screen.dart';
import 'package:harmonoid/utils/rendering.dart';

class NowPlayingLyricsScreen extends StatefulWidget {
  const NowPlayingLyricsScreen({super.key});

  @override
  State<NowPlayingLyricsScreen> createState() => NowPlayingLyricsScreenState();
}

class NowPlayingLyricsScreenState extends State<NowPlayingLyricsScreen> {
  Widget _buildDesktopLayout(BuildContext context) {
    throw UnimplementedError();
  }

  Widget _buildTabletLayout(BuildContext context) {
    throw UnimplementedError();
  }

  Widget _buildMobileLayout(BuildContext context) {
    return const MobileNowPlayingLyricsScreen();
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
