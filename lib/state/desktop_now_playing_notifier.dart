import 'package:flutter/widgets.dart';

/// {@template desktop_now_playing_notifier}
///
/// DesktopNowPlayingNotifier
/// -------------------------
/// Implementation to notify now playing bar & screen on desktop.
///
/// {@endtemplate}
class DesktopNowPlayingNotifier extends ChangeNotifier {
  /// Singleton instance.
  static late DesktopNowPlayingNotifier instance;

  /// {@macro desktop_now_playing_notifier}
  DesktopNowPlayingNotifier({
    required this.enter,
    required this.exit,
  }) {
    instance = this;
  }

  /// Invoked when the now playing screen is entered.
  final VoidCallback enter;

  /// Invoked when the now playing screen is exited.
  final VoidCallback exit;

  /// Whether the now playing screen is hidden.
  bool hidden = true;

  /// Color palette.
  final ValueNotifier<Iterable<Color>?> palette = ValueNotifier(null);

  /// Show the now playing screen.
  void show() {
    if (hidden) {
      hidden = false;
      notifyListeners();
      enter();
    }
  }

  /// Hide the now playing screen.
  void hide() {
    if (!hidden) {
      hidden = true;
      notifyListeners();
      exit();
    }
  }

  /// Show or hide the now playing screen.
  void showOrHide() {
    if (hidden) {
      show();
    } else {
      hide();
    }
  }
}
