/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///
import 'dart:io';
import 'package:window_plus/window_plus.dart';
import 'package:flutter/material.dart' hide Intent;
import 'package:system_media_transport_controls/system_media_transport_controls.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/core/intent.dart';
import 'package:harmonoid/interface/home.dart';
import 'package:harmonoid/state/collection_refresh.dart';
import 'package:harmonoid/constants/language.dart';

/// WindowLifecycle
/// ---------------
/// Windows & Linux specific. Registers callbacks from `package:window_plus`.
///
/// Handles:
///
/// * Window close button interception (when some task within Harmonoid is in progress).
/// * Argument vector receiving i.e. `List<String> args` (due to single instance of Harmonoid).
///
abstract class WindowLifecycle {
  /// Initializes the window lifecycle handler.
  static void initialize() {
    if (_initialized) {
      return;
    }
    WindowPlus.instance
      ..setSingleInstanceArgumentsHandler(
        singleInstanceArgumentsHandler,
      )
      ..setWindowCloseHandler(
        windowCloseHandler,
      );
    _initialized = true;
  }

  /// Method invoked when user starts new instance of Harmonoid.
  /// Used to receive argument vector i.e. `List<String> args`.
  ///
  static void singleInstanceArgumentsHandler(List<String> args) async {
    if (args.isNotEmpty) {
      await Intent.instance.playURI(args.first);
    }
  }

  /// Method invoked when user closes the window i.e. process is about to exit.
  static Future<bool> windowCloseHandler({
    bool showInterruptAlert = true,
  }) async {
    if (!CollectionRefresh.instance.isCompleted) {
      if (showInterruptAlert) {
        await showDialog(
          context: navigatorKey.currentContext!,
          builder: (c) => AlertDialog(
            title: Text(Language.instance.WARNING),
            content: Text(
              Language.instance.COLLECTION_INDEXING_LABEL.replaceAll('\n', ' '),
              style: Theme.of(c).textTheme.displaySmall,
            ),
            actions: [
              TextButton(
                onPressed: Navigator.of(c).maybePop,
                child: Text(Language.instance.OK),
              ),
            ],
          ),
        );
      }
      return false;
    } else {
      try {
        await Playback.instance.saveAppState();
      } catch (exception, stacktrace) {
        debugPrint(exception.toString());
        debugPrint(stacktrace.toString());
      }
      try {
        await Collection.instance.dispose();
        await Playback.instance.libmpv?.dispose();
        await Intent.instance.tagger?.dispose();
        await Intent.instance.client?.dispose();
      } catch (exception, stacktrace) {
        debugPrint(exception.toString());
        debugPrint(stacktrace.toString());
      }
      try {
        if (Platform.isWindows) {
          SystemMediaTransportControls.instance.clear();
          SystemMediaTransportControls.instance.dispose();
        }
      } catch (exception, stacktrace) {
        debugPrint(exception.toString());
        debugPrint(stacktrace.toString());
      }
      return true;
    }
  }

  /// Prevent calling [initialize] more than once.
  static bool _initialized = false;
}
