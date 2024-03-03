import 'package:flutter/widgets.dart';

import 'package:harmonoid/core/media_player.dart';
import 'package:harmonoid/extensions/media_player_state.dart';
// import 'package:harmonoid/ui/mobile_now_playing_bar.dart';

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
  MobileNowPlayingNotifier() {
    instance = this;
  }

  /// [GlobalKey] to access now playing bar.
  // final GlobalKey<MobileNowPlayingBarState> key;

  /// Offset for the bottom navigation bar & floating action button.
  final ValueNotifier<double> bottomNavigationBarOffset = ValueNotifier<double>(0.0);

  bool get restored =>  true;

  void show() {
    if (MediaPlayer.instance.state.isEmpty) return;
    // key.currentState?.show();
  }

  void hide() {
    // key.currentState?.hide();
  }

  void maximize() {
    // key.currentState?.maximize();
  }

  void restore() {
    // key.currentState?.restore();
  }
}
