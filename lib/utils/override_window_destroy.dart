/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'package:flutter/services.dart';

import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/core/collection.dart';

/// OverrideWindowDestroy
/// ---------------------
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
abstract class OverrideWindowDestroy {
  static void initialize() async {
    const channel = const MethodChannel('override_window_destroy');
    channel.setMethodCallHandler((call) async {
      await tagger.dispose();
      await Playback.instance.player.dispose();
      await Playback.instance.saveAppState();
      channel.invokeMethod('destroy_window');
    });
  }
}
