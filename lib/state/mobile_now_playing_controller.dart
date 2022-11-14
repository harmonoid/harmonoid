/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///
import 'package:flutter/material.dart';

import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/utils/dimensions.dart';
import 'package:harmonoid/interface/mini_now_playing_bar.dart';

class MobileNowPlayingController {
  static final MobileNowPlayingController instance =
      MobileNowPlayingController._();

  MobileNowPlayingController._();

  final GlobalKey<MiniNowPlayingBarState> barKey =
      GlobalKey<MiniNowPlayingBarState>();

  final ValueNotifier<Iterable<Color>?> palette = ValueNotifier(null);
  final ValueNotifier<double> bottomNavigationBar =
      ValueNotifier(kBottomNavigationBarHeight);
  final ValueNotifier<double> fabOffset = ValueNotifier<double>(0.0);

  bool get isHidden => barKey.currentState?.isHidden ?? true;

  void show() {
    try {
      if (Playback.instance.tracks.isEmpty) return;
      if (fabOffset.value == 0.0) {
        fabOffset.value = kMobileNowPlayingBarHeight;
      }
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }
    barKey.currentState?.show();
  }

  void hide() {
    try {
      if (fabOffset.value != 0.0) {
        fabOffset.value = 0.0;
      }
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }
    barKey.currentState?.hide();
  }

  void maximize() {
    barKey.currentState?.maximize();
  }

  void restore() {
    barKey.currentState?.restore();
  }
}
