import 'dart:async';

import 'package:flutter/services.dart';

/// {@template android_utils}
///
/// AndroidUtils
/// ------------
/// Implementation to invoke Android specific utility methods.
///
/// {@endtemplate}
class AndroidUtils {
  static const kMethodChannelName = 'com.alexmercerind.harmonoid/utils';
  static const kMoveTaskToBackMethodName = 'moveTaskToBack';
  static const kShowToastMethodName = 'showToast';

  static const kShowToastArgText = 'text';

  /// Singleton instance.
  static final AndroidUtils instance = AndroidUtils._();

  /// {@macro android_utils}
  AndroidUtils._();

  Future<void> moveTaskToBack() {
    return _channel.invokeMethod(kMoveTaskToBackMethodName);
  }

  Future<void> showToast(String text) {
    return _channel.invokeMethod(kShowToastMethodName, {kShowToastArgText: text});
  }

  final MethodChannel _channel = const MethodChannel(kMethodChannelName);
}
