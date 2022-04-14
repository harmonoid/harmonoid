/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///
import 'package:flutter/widgets.dart';

import 'package:harmonoid/interface/mini_now_playing_bar.dart';

class NowPlayingScrollHider {
  static late NowPlayingScrollHider instance;

  final GlobalKey<MiniNowPlayingBarState> key =
      GlobalKey<MiniNowPlayingBarState>();

  void show() => key.currentState!.show();
  void hide() => key.currentState!.hide();
  bool get isHidden => key.currentState!.isHidden;

  NowPlayingScrollHider() {
    NowPlayingScrollHider.instance = this;
  }
}
