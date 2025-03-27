import 'package:flutter/material.dart';

import 'package:harmonoid/ui/now_playing/mobile/mobile_m2_now_playing_bar.dart';
import 'package:harmonoid/ui/now_playing/mobile/mobile_m3_now_playing_bar.dart';
import 'package:harmonoid/utils/rendering.dart';

class MobileNowPlayingBar extends StatelessWidget {
  const MobileNowPlayingBar({super.key});

  @override
  Widget build(BuildContext context) {
    if (isMaterial3) {
      return const MobileM3NowPlayingBar();
    }
    if (isMaterial2) {
      return const MobileM2NowPlayingBar();
    }
    throw UnimplementedError();
  }
}
