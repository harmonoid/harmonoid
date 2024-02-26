import 'package:flutter/widgets.dart';

import 'package:harmonoid/core/media_player.dart';
import 'package:harmonoid/extensions/media_player_state.dart';
import 'package:harmonoid/interface/mini_now_playing_bar.dart';
import 'package:harmonoid/utils/constants.dart';

/// {@template mobile_now_playing_notifier}
///
/// MobileNowPlayingNotifier
/// -------------------------
/// Implementation to notify now playing bar & screen on mobile.
///
/// {@endtemplate}
class MobileNowPlayingNotifier {
  /// Singleton instance.
  static late MobileNowPlayingNotifier instance;

  /// {@macro desktop_now_playing_notifier}
  MobileNowPlayingNotifier({required this.key}) {
    instance = this;
  }

  /// [GlobalKey] to access now playing bar.
  final GlobalKey<MiniNowPlayingBarState> key;

  /// Offset for the bottom navigation bar & floating action button.
  final ValueNotifier<double> bottomNavigationBarAndFloatingActionButtonOffset = ValueNotifier<double>(0.0);

  bool get hidden => key.currentState?.hidden ?? true;

  /// Color palette.
  final ValueNotifier<Iterable<Color>?> palette = ValueNotifier(null);

  void show() {
    try {
      if (MediaPlayer.instance.state.isEmpty) return;
      if (bottomNavigationBarAndFloatingActionButtonOffset.value == 0.0) {
        bottomNavigationBarAndFloatingActionButtonOffset.value = kMobileNowPlayingBarHeight;
      }
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }
    key.currentState?.show();
  }

  void hide() {
    try {
      if (bottomNavigationBarAndFloatingActionButtonOffset.value != 0.0) {
        bottomNavigationBarAndFloatingActionButtonOffset.value = 0.0;
      }
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }
    key.currentState?.hide();
  }

  void maximize() {
    key.currentState?.maximize();
  }

  void restore() {
    key.currentState?.restore();
  }
}
