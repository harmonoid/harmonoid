import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:media_library/media_library.dart';

import 'package:harmonoid/core/media_player/media_player.dart';
import 'package:harmonoid/ui/media_library/media_library_screen.dart';
import 'package:harmonoid/ui/router.dart';
import 'package:provider/provider.dart';

/// {@template keyboard_shortcuts}
///
/// KeyboardShortcuts
/// -----------------
/// Implementation to handle keyboard shortcuts.
///
/// {@endtemplate}
class KeyboardShortcuts {
  /// {@macro keyboard_shortcuts}
  KeyboardShortcuts({required this.mediaLibrary});

  final MediaLibrary mediaLibrary;

  final bool control = !Platform.isMacOS;

  late final Map<ShortcutActivator, VoidCallback> bindings = {
    const SingleActivator(LogicalKeyboardKey.space): MediaPlayer.instance.playOrPause,
    const SingleActivator(LogicalKeyboardKey.mediaPlayPause): MediaPlayer.instance.playOrPause,
    const SingleActivator(LogicalKeyboardKey.mediaTrackNext): MediaPlayer.instance.next,
    const SingleActivator(LogicalKeyboardKey.mediaTrackPrevious): MediaPlayer.instance.previous,
    SingleActivator(LogicalKeyboardKey.keyF, control: control, meta: !control): MediaLibraryScreenState.desktopQueryTextFieldFocusNode.requestFocus,
    SingleActivator(LogicalKeyboardKey.keyS, control: control, meta: !control): MediaLibraryScreenState.desktopQueryTextFieldFocusNode.requestFocus,
    SingleActivator(LogicalKeyboardKey.keyQ, control: control, meta: !control): SystemNavigator.pop,
    SingleActivator(LogicalKeyboardKey.keyR, control: control, meta: !control): mediaLibrary.refresh,
    SingleActivator(LogicalKeyboardKey.arrowLeft, control: control, meta: !control): router.pop,
    SingleActivator(LogicalKeyboardKey.digit1, control: control, meta: !control): () => router.go('/$kMediaLibraryPath/$kAlbumsPath'),
    SingleActivator(LogicalKeyboardKey.digit2, control: control, meta: !control): () => router.go('/$kMediaLibraryPath/$kTracksPath'),
    SingleActivator(LogicalKeyboardKey.digit3, control: control, meta: !control): () => router.go('/$kMediaLibraryPath/$kArtistsPath'),
    SingleActivator(LogicalKeyboardKey.digit4, control: control, meta: !control): () => router.go('/$kMediaLibraryPath/$kGenresPath'),
    SingleActivator(LogicalKeyboardKey.digit5, control: control, meta: !control): () => router.go('/$kMediaLibraryPath/$kFoldersPath'),
    SingleActivator(LogicalKeyboardKey.digit6, control: control, meta: !control): () => router.go('/$kMediaLibraryPath/$kPlaylistsPath'),
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
      bindings: KeyboardShortcuts(mediaLibrary: context.read()).bindings,
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
      shortcuts: KeyboardShortcuts(mediaLibrary: context.read()).bindings.map(
        (key, _) => MapEntry(key, const DoNothingAndStopPropagationTextIntent()),
      ),
      child: child,
    );
  }
}
