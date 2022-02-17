/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///
import 'package:flutter/widgets.dart';

class NowPlayingLauncher extends ChangeNotifier {
  static late NowPlayingLauncher instance;

  final VoidCallback launch;
  final VoidCallback exit;

  NowPlayingLauncher({
    required this.launch,
    required this.exit,
  }) {
    NowPlayingLauncher.instance = this;
  }

  void toggle() => maximized = !maximized;

  bool get maximized => _maximized;

  set maximized(bool value) {
    if (value == _maximized) return;
    if (value) {
      launch();
    } else {
      exit();
    }
    _maximized = value;
    notifyListeners();
  }

  bool _maximized = false;
}
