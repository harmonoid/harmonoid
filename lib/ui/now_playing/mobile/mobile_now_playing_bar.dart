import 'package:flutter/material.dart';

import 'package:harmonoid/ui/now_playing/mobile/m2_mobile_now_playing_bar.dart';
import 'package:harmonoid/ui/now_playing/mobile/m3_mobile_now_playing_bar.dart';
import 'package:harmonoid/utils/rendering.dart';

class MobileNowPlayingBar extends StatelessWidget {
  const MobileNowPlayingBar({super.key});

  @override
  Widget build(BuildContext context) {
    if (isMaterial3) {
      return const M3MobileNowPlayingBar();
    }
    if (isMaterial2) {
      return const M2MobileNowPlayingBar();
    }
    throw UnimplementedError();
  }
}
