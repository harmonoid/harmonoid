import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';

import 'package:harmonoid/core/media_player/media_player.dart';

/// {@template keyboard_shortcuts}
///
/// KeyboardShortcuts
/// -----------------
/// Implementation to handle keyboard shortcuts.
///
/// {@endtemplate}
class KeyboardShortcuts {
  /// Singleton instance.
  static final KeyboardShortcuts instance = KeyboardShortcuts._();

  /// {@macro keyboard_shortcuts}
  KeyboardShortcuts._();

  final Map<LogicalKeySet, VoidCallback> bindings = {
    LogicalKeySet(LogicalKeyboardKey.space): MediaPlayer.instance.playOrPause,
    LogicalKeySet(LogicalKeyboardKey.mediaPlayPause): MediaPlayer.instance.playOrPause,
    LogicalKeySet(LogicalKeyboardKey.mediaTrackNext): MediaPlayer.instance.next,
    LogicalKeySet(LogicalKeyboardKey.mediaTrackPrevious): MediaPlayer.instance.previous,
    LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyQ): SystemNavigator.pop,
  };
}

/// {@template keyboard_shortcuts_listener}
///
/// KeyboardShortcutsListener
/// -------------------------
/// Implementation to listen to keyboard shortcuts.
///
/// {@endtemplate}
class KeyboardShortcutsListener extends StatelessWidget {
  final Widget child;

  /// {@macro keyboard_shortcuts_listener}
  const KeyboardShortcutsListener({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: KeyboardShortcuts.instance.bindings,
      child: child,
    );
  }
}

/// {@template keyboard_shortcuts_interceptor}
///
/// KeyboardShortcutsInterceptor
/// ----------------------------
/// Implementation to intercept keyboard shortcuts.
///
/// {@endtemplate}
class KeyboardShortcutsInterceptor extends StatelessWidget {
  final Widget child;

  /// {@macro keyboard_shortcuts_interceptor}
  const KeyboardShortcutsInterceptor({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: KeyboardShortcuts.instance.bindings.map(
        (key, _) => MapEntry(key, const DoNothingAndStopPropagationTextIntent()),
      ),
      child: child,
    );
  }
}
