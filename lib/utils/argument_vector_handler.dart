/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'package:flutter/services.dart';

import 'package:harmonoid/core/intent.dart';

const _kMethodChannelName = 'com.alexmercerind/harmonoid';

/// ArgumentVectorHandler
/// ---------------------
///
/// It receives the `args` if an instance of Harmonoid was already opened.
/// Works only on Windows.
///
/// Currently only first argument of the `wchar_t**` is sent through the
/// channel & is the only exclusive message that will be sent, thus directly
/// fed into [Intent.playUri].
///
abstract class ArgumentVectorHandler {
  static void initialize() {
    MethodChannel(_kMethodChannelName).setMethodCallHandler((call) async {
      Intent.instance.playUri(Uri.file(call.arguments));
    });
  }
}
