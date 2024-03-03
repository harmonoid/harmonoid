import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/material.dart' hide Intent;

import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/core/intent.dart';
import 'package:harmonoid/core/media_library.dart';
import 'package:harmonoid/core/media_player.dart';
// import 'package:harmonoid/ui/home_screen.dart';
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
    if (!MediaLibrary.instance.refreshing || force) {
      Intent.instance.dispose();
      MediaLibrary.instance.dispose();
      MediaPlayer.instance.dispose();
      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    } else {
      // await showDialog(
      //   context: navigatorKey.currentContext!,
      //   builder: (context) => AlertDialog(
      //     title: Text(Language.instance.WARNING),
      //     contentPadding: const EdgeInsets.fromLTRB(
      //       24.0,
      //       20.0,
      //       24.0,
      //       20.0,
      //     ),
      //     content: Text(
      //       Language.instance.INDEXING_LABEL.replaceAll('\n', ' '),
      //     ),
      //     actions: [
      //       TextButton(
      //         onPressed: Navigator.of(context).maybePop,
      //         child: Text(
      //           label(
      //             context,
      //             Language.instance.OK,
      //           ),
      //         ),
      //       ),
      //     ],
      //   ),
      // );
      return false;
    }
  }
}
