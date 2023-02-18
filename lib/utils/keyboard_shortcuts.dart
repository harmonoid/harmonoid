/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:window_plus/window_plus.dart';

import 'package:harmonoid/core/playback.dart';

/// KeyboardShortcuts
/// -----------------
///
/// This class handles all the registered keyboard shortcuts in Harmonoid.
///
/// This class is a singleton class for accessing inside the relevant widgets i.e. [KeyboardShortcutsListener] & [KeyboardShortcutsInterceptor].
///
class KeyboardShortcuts {
  /// [KeyboardShortcuts] object instance.
  static final KeyboardShortcuts instance = KeyboardShortcuts();

  /// List of all registered shortcuts.
  final Map<LogicalKeySet, VoidCallback> bindings = {
    // Harmonoid specific shortcuts.
    LogicalKeySet(LogicalKeyboardKey.space): Playback.instance.playOrPause,
    // Keyboard keys specifically for media playback control.
    // Although these are already registered using System Media Transport Controls on Windows & MPRIS on Linux.
    LogicalKeySet(
      LogicalKeyboardKey.mediaPlayPause,
    ): Playback.instance.playOrPause,
    LogicalKeySet(
      LogicalKeyboardKey.mediaTrackNext,
    ): Playback.instance.next,
    LogicalKeySet(
      LogicalKeyboardKey.mediaTrackPrevious,
    ): Playback.instance.previous,
    LogicalKeySet(
      LogicalKeyboardKey.control,
      LogicalKeyboardKey.keyQ,
    ): WindowPlus.instance.close,
  };
}

/// This widget listens all the keyboard shortcuts defined by [KeyboardShortcuts].
/// This is placed right above the [MaterialApp].
class KeyboardShortcutsListener extends StatelessWidget {
  /// The descendant [Widget] of this [KeyboardShortcutsListener].
  final Widget child;
  const KeyboardShortcutsListener({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: KeyboardShortcuts.instance.bindings,
      child: child,
    );
  }
}

/// This widget intercepts all the keyboard shortcuts defined by [KeyboardShortcuts].
///
/// This must be used where the keyboard shortcuts must be ignored e.g. [CustomTextField] or [CustomTextFormField] etc.
/// Until the [child] wrapped by [KeyboardShortcutsInterceptor] stays focused, the keyboard shortcuts will be ignored.
class KeyboardShortcutsInterceptor extends StatelessWidget {
  /// The descendant [Widget] of this [KeyboardShortcutsInterceptor].
  final Widget child;
  const KeyboardShortcutsInterceptor({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: KeyboardShortcuts.instance.bindings.map(
        (key, _) => MapEntry(
          key,
          DoNothingAndStopPropagationTextIntent(),
        ),
      ),
      child: child,
    );
  }
}
