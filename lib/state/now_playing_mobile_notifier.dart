import 'package:flutter/widgets.dart';

/// {@template now_playing_mobile_notifier}
///
/// NowPlayingMobileNotifier
/// -------------------------
/// Implementation to notify now playing bar & screen on mobile.
///
/// {@endtemplate}
class NowPlayingMobileNotifier {
  /// Singleton instance.
  static final NowPlayingMobileNotifier instance = NowPlayingMobileNotifier._();

  /// {@macro now_playing_mobile_notifier}
  NowPlayingMobileNotifier._();

  /// [GlobalKey] to access now playing bar.
  // TODO:

  /// Whether the [NowPlayingBarMobile] is in restored state.
  // TODO:
  final bool restored = false;

  /// Offset for the bottom navigation bar & floating action button.
  final ValueNotifier<double> bottomNavigationBarOffset = ValueNotifier<double>(0.0);

  void show() {
    // TODO:
  }

  void hide() {
    // TODO:
  }

  void maximize() {
    // TODO:
  }

  void restore() {
    // TODO:
  }
}
