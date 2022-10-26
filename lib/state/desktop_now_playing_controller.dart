/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///
import 'package:flutter/widgets.dart';

class DesktopNowPlayingController extends ChangeNotifier {
  static late DesktopNowPlayingController instance;

  final VoidCallback launch;
  final VoidCallback exit;
  bool isHidden = true;

  DesktopNowPlayingController({
    required this.launch,
    required this.exit,
  }) {
    DesktopNowPlayingController.instance = this;
  }

  void maximize() {
    if (isHidden) {
      launch();
      isHidden = false;
      notifyListeners();
    }
  }

  void hide() {
    if (!isHidden) {
      exit();
      isHidden = true;
      notifyListeners();
    }
  }

  void toggle() {
    if (isHidden) {
      launch();
      isHidden = false;
    } else {
      exit();
      isHidden = true;
    }
    notifyListeners();
  }
}
