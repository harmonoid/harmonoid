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

  /// Whether the now playing screen is restored.
  bool restored = true;

  /// Maximize the now playing screen.
  void maximize() {
    if (restored) {
      restored = false;
      notifyListeners();
      enter();
    }
  }

  /// Restore the now playing screen.
  void restore() {
    if (!restored) {
      restored = true;
      notifyListeners();
      exit();
    }
  }

  /// Show or hide the now playing screen.
  void maximizeOrRestore() {
    if (restored) {
      maximize();
    } else {
      restore();
    }
  }
}
