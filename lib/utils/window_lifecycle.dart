import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/material.dart' hide Intent;

import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/core/intent.dart';
import 'package:harmonoid/core/media_library.dart';
import 'package:harmonoid/core/media_player/media_player.dart';
import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/mappers/media_player_state.dart';
import 'package:harmonoid/ui/router.dart';
import 'package:harmonoid/utils/rendering.dart';

/// {@template window_lifecycle}
///
/// WindowLifecycle
/// ---------------
/// Implementation to handle window lifecycle events.
///
/// {@endtemplate}
class WindowLifecycle {
  /// Singleton instance.
  static final WindowLifecycle instance = WindowLifecycle._();

  /// Whether the [instance] is initialized.
  static bool initialized = false;

  /// {@macro window_lifecycle}
  WindowLifecycle._();

  /// Initializes the [instance].
  static void ensureInitialized() {
    if (initialized) return;
    initialized = true;
    WindowPlus.instance
      ..setSingleInstanceArgumentsHandler(singleInstanceArgumentsHandler)
      ..setWindowCloseHandler(windowCloseHandler);
  }

  /// Invoked when argument vector is received.
  static void singleInstanceArgumentsHandler(List<String> args) async {
    if (args.isNotEmpty) {
      await Intent.instance.play(args.first);
    }
  }

  /// Invoked when window is about to close.
  static Future<bool> windowCloseHandler({bool force = false}) async {
    try {
      if (!MediaLibrary.instance.refreshing || force) {
        MediaLibrary.instance.dispose();
        MediaPlayer.instance.dispose();
        Configuration.instance.set(mediaPlayerPlaybackState: MediaPlayer.instance.state.toPlaybackState());
        await Future.delayed(const Duration(seconds: 1));
        return true;
      } else {
        await showDialog(
          context: rootNavigatorKey.currentContext!,
          builder: (context) => AlertDialog(
            title: Text(Localization.instance.WARNING),
            content: Text(Localization.instance.MEDIA_LIBRARY_REFRESHING_DIALOG_SUBTITLE.replaceAll('\n', ' ')),
            actions: [
              TextButton(
                onPressed: Navigator.of(context).maybePop,
                child: Text(label(Localization.instance.OK)),
              ),
            ],
          ),
        );
        return false;
      }
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
      return true;
    }
  }
}
