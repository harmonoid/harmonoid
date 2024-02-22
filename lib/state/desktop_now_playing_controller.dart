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
