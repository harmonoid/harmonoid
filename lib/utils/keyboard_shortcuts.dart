import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';

import 'package:harmonoid/core/media_player/media_player.dart';
import 'package:harmonoid/ui/media_library/media_library_screen.dart';
import 'package:harmonoid/ui/router.dart';

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

  final Map<ShortcutActivator, VoidCallback> bindings = {
    const SingleActivator(LogicalKeyboardKey.space): MediaPlayer.instance.playOrPause,
    const SingleActivator(LogicalKeyboardKey.mediaPlayPause): MediaPlayer.instance.playOrPause,
    const SingleActivator(LogicalKeyboardKey.mediaTrackNext): MediaPlayer.instance.next,
    const SingleActivator(LogicalKeyboardKey.mediaTrackPrevious): MediaPlayer.instance.previous,
    const SingleActivator(LogicalKeyboardKey.keyS, control: true): MediaLibraryScreenState.desktopQueryTextFieldFocusNode.requestFocus,
    const SingleActivator(LogicalKeyboardKey.keyQ, control: true): SystemNavigator.pop,
    const SingleActivator(LogicalKeyboardKey.arrowLeft, control: true): router.pop,
    const SingleActivator(LogicalKeyboardKey.digit1, control: true): () => router.go('/$kMediaLibraryPath/$kAlbumsPath'),
    const SingleActivator(LogicalKeyboardKey.digit2, control: true): () => router.go('/$kMediaLibraryPath/$kTracksPath'),
    const SingleActivator(LogicalKeyboardKey.digit3, control: true): () => router.go('/$kMediaLibraryPath/$kArtistsPath'),
    const SingleActivator(LogicalKeyboardKey.digit4, control: true): () => router.go('/$kMediaLibraryPath/$kGenresPath'),
    const SingleActivator(LogicalKeyboardKey.digit5, control: true): () => router.go('/$kMediaLibraryPath/$kPlaylistsPath'),
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
      child: Focus(
        autofocus: true,
        child: child,
      ),
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
