/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'dart:io';
import 'package:flutter/material.dart' hide Intent;
import 'package:flutter_window_close/flutter_window_close.dart';
import 'package:system_media_transport_controls/system_media_transport_controls.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/core/intent.dart';
import 'package:harmonoid/interface/home.dart';
import 'package:harmonoid/state/collection_refresh.dart';
import 'package:harmonoid/constants/language.dart';

/// WindowCloseHandler
/// ------------------
///
/// Properly disposes instances before window close & asserts if some
/// indexing related operation is under progress.
///
/// **Previous Comments:**
///
/// Earlier this class was named `OverrideWindowDestroy` & was used to
/// intercept `delete-event` signal specifically on GTK embedder on Linux.
///
/// Overrides the `delete-event` signal of Flutter's GTK window on Linux.
/// A constantly running instance of `libmpv` causes `Segmentation Fault`
/// upon attempting to close the window.
///
/// Calling [OverrideWindowDestroy.initialize] ensures that all instances of
/// `libmpv` are properly disposed & then the same is notified to native side
/// of the source code, which then launches another thread to send `destroy`
/// signal to the window.
///
abstract class WindowCloseHandler {
  static void initialize() {
    if (_initialized) {
      return;
    }
    _initialized = true;
    FlutterWindowClose.setWindowShouldCloseHandler(onWindowClose);
    // const channel = const MethodChannel('override_window_destroy');
    // channel.setMethodCallHandler((call) async {
    //   await tagger.dispose();
    //   await Playback.instance.player.dispose();
    //   await Playback.instance.saveAppState();
    //   channel.invokeMethod('destroy_window');
    // });
  }

  /// Method which is invoked when a window is closed.
  static Future<bool> onWindowClose({
    bool showInterruptAlert = true,
  }) async {
    if (CollectionRefresh.instance.isOngoing) {
      if (showInterruptAlert) {
        await showDialog(
          context: navigatorKey.currentContext!,
          builder: (c) => AlertDialog(
            title: Text(
              Language.instance.WARNING,
            ),
            content: Text(
              Language.instance.COLLECTION_INDEXING_LABEL.replaceAll('\n', ' '),
              style: Theme.of(c).textTheme.headline3,
            ),
            actions: [
              MaterialButton(
                textColor: Theme.of(navigatorKey.currentContext!).primaryColor,
                onPressed: Navigator.of(c).pop,
                child: Text(Language.instance.OK),
              ),
            ],
          ),
        );
      }
      return false;
    } else {
      try {
        if (Platform.isLinux) {
          await Collection.instance.dispose();
          await Intent.instance.tagger.dispose();
          await Playback.instance.libmpv?.dispose();
        }
      } catch (exception, stacktrace) {
        debugPrint(exception.toString());
        debugPrint(stacktrace.toString());
      }
      try {
        await Playback.instance.saveAppState();
      } catch (exception, stacktrace) {
        debugPrint(exception.toString());
        debugPrint(stacktrace.toString());
      }
      try {
        if (Platform.isWindows) {
          smtc.clear();
          smtc.dispose();
        }
      } catch (exception, stacktrace) {
        debugPrint(exception.toString());
        debugPrint(stacktrace.toString());
      }
      return true;
    }
  }

  /// Prevent registering method call handler on platform channel more than once.
  static bool _initialized = false;
}
