import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/material.dart';

import 'package:harmonoid/ui/now_playing/mobile/mobile_m2_now_playing_bar.dart';
import 'package:harmonoid/ui/now_playing/mobile/mobile_m3_now_playing_bar.dart';

class MobileNowPlayingBar extends StatelessWidget {
  const MobileNowPlayingBar({super.key});

  @override
  Widget build(BuildContext context) {
    final standard = Theme.of(context).extension<MaterialStandard>()?.value;
    return switch (standard) {
      3 => const MobileM3NowPlayingBar(),
      2 => const MobileM2NowPlayingBar(),
      _ => throw UnimplementedError(),
    };
  }
}
