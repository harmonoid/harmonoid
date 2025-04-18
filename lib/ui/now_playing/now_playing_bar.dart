import 'package:flutter/material.dart';

import 'package:harmonoid/ui/now_playing/desktop/desktop_now_playing_bar.dart';
import 'package:harmonoid/ui/now_playing/mobile/mobile_now_playing_bar.dart';
import 'package:harmonoid/utils/constants.dart';
import 'package:harmonoid/utils/rendering.dart';

class NowPlayingBar extends StatefulWidget {
  const NowPlayingBar({super.key});

  static double get height {
    if (isDesktop) {
      if (isMaterial3) {
        return kDesktopM3NowPlayingBarHeight;
      }
      if (isMaterial2) {
        return kDesktopM2NowPlayingBarHeight;
      }
      throw UnimplementedError();
    }
    if (isTablet) {
      throw UnimplementedError();
    }
    if (isMobile) {
      return kMobileNowPlayingBarHeight;
    }
    throw UnimplementedError();
  }

  @override
  State<NowPlayingBar> createState() => NowPlayingBarState();
}

class NowPlayingBarState extends State<NowPlayingBar> {
  Widget _buildDesktopLayout(BuildContext context) {
    return const DesktopNowPlayingBar();
  }

  Widget _buildTabletLayout(BuildContext context) {
    throw UnimplementedError();
  }

  Widget _buildMobileLayout(BuildContext context) {
    return const MobileNowPlayingBar();
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
