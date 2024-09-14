import 'package:flutter/material.dart';

import 'package:harmonoid/ui/now_playing/now_playing_bar_desktop.dart';
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
  State<NowPlayingBar> createState() => _NowPlayingBarState();
}

class _NowPlayingBarState extends State<NowPlayingBar> {
  Widget _buildDesktopLayout(BuildContext context) {
    return const NowPlayingBarDesktop();
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
