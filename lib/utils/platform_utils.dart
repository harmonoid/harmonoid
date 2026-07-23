import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

import 'package:harmonoid/utils/window_lifecycle.dart';

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
  static const String kNotifySceneDidDisconnectMethodName = 'notifySceneDidDisconnect';

  /// Singleton instance.
  static final PlatformUtils instance = PlatformUtils._();

  /// Whether the [instance] is initialized.
  static bool initialized = false;

  /// {@macro platform_utils}
  PlatformUtils._();

  /// Initializes the [instance].
  static void ensureInitialized() {
    if (initialized) return;
    initialized = true;
    if (Platform.isIOS) {
      instance._channel.setMethodCallHandler((call) async {
        if (call.method == kNotifySceneDidDisconnectMethodName) {
          return WindowLifecycle.windowCloseHandler(force: true);
        }
        throw MissingPluginException();
      });
    }
  }

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
