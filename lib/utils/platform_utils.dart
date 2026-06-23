import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

/// {@template platform_utils}
///
/// PlatformUtils
/// ------------
/// Implementation to invoke platform specific utility methods.
///
/// {@endtemplate}
class PlatformUtils {
  static const String kMethodChannelName = 'com.alexmercerind.harmonoid/utils';

  static const String kMoveTaskToBackMethodName = 'moveTaskToBack';
  static const String kShowToastMethodName = 'showToast';
  static const String kShowToastArgText = 'text';
  static const String kGetSystemAccentColorMethodName = 'getSystemAccentColor';

  /// Singleton instance.
  static final PlatformUtils instance = PlatformUtils._();

  /// {@macro platform_utils}
  PlatformUtils._();

  Future<void> moveTaskToBack() async {
    if (!Platform.isAndroid) return;

    return _channel.invokeMethod(kMoveTaskToBackMethodName);
  }

  Future<void> showToast(String text) async {
    if (!Platform.isAndroid) return;

    return _channel.invokeMethod(kShowToastMethodName, {kShowToastArgText: text});
  }

  Future<Color?> getSystemAccentColor() async {
    if (!Platform.isIOS) return null;

    final value = await _channel.invokeMethod<int>(kGetSystemAccentColorMethodName);
    if (value == null) return null;
    return Color(value);
  }

  final MethodChannel _channel = const MethodChannel(kMethodChannelName);
}
