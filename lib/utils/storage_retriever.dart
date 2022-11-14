/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///
import 'dart:io';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

/// StorageRetriever
/// ----------------
///
/// This class is used to retrieve absolute storage paths for internal storage & SD card on Android.
///
/// This is the only solution.
///
/// By default, [getExternalFilesDirs] returns the application specific & private path e.g.
/// `/storage/emulated/0/Android/data/com.alexmercerind.harmonoid/files`.
///
/// This is because Android is promoting Scoped Storage & [MediaStore], which unfortunately
/// fail many of our use cases like custom or multiple directory selection for music indexing
/// or looking for .LRC files in the same directory as audio file etc.
///
/// This would also mean that all the application (in-theory) would have to be additionally
/// written in Kotlin just to support Android, because existing media library manager &
/// indexer written in Dart is completely file-system based, since Windows & Linux have no
/// such concepts as Android recently redundantly introduced.
///
class StorageRetriever {
  /// [StorageRetriever] singleton instance. Must call [initialize] before accessing.
  static final StorageRetriever instance = StorageRetriever._();

  StorageRetriever._() {
    _channel.setMethodCallHandler(
      (call) async {
        debugPrint(call.method.toString());
        debugPrint(call.arguments.toString());
        switch (call.method) {
          case 'com.alexmercerind.StorageRetriever/delete':
            {
              _deleteCompleter.complete(call.arguments);
              break;
            }
        }
      },
    );
  }

  /// Initializes the [StorageRetriever] singleton [instance].
  static Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    _initialized = true;
    // According to:
    // https://github.com/flutter/flutter/issues/58160#issuecomment-639139990
    // https://github.com/flutter/samples/blob/master/add_to_app/plugin/android_using_plugin/app/src/main/java/dev/flutter/example/androidusingplugin/MyApplication.kt
    //
    // There seems to be a race condition between Dart code's execution start & creation of [MethodChannel] on the native side.
    //
    // Personally, I have never experienced a [MissingPluginException], but a user has sent a report. So, for now I have decided to do polling on Dart side until
    // the [MethodChannel] correctly responds with the value instead of throwing a [MissingPluginException].
    // This hopefully will avoid any errors before Flutter starts, even though with a busy-waiting (if it ever takes place in any rare situation).
    int? result;
    while (result == null) {
      try {
        result = await instance._version;
      } catch (exception, stacktrace) {
        debugPrint(exception.toString());
        debugPrint(stacktrace.toString());
      }
    }
    instance.version = result;
  }

  /// The value of `android.os.Build.VERSION.SDK_INT`. This is used to determine the Android version.
  int version = -1;

  /// Returns the internal storage & SD card [Directory] (s) in a [List].
  ///
  /// First element of the list is the internal storage & second element is the SD card.
  ///
  /// If the length of the returned [List] is `1`, it may be assumed that there is no SD card.
  ///
  Future<List<Directory>> get volumes async {
    assert(Platform.isAndroid);
    final result = await _channel.invokeMethod('volumes');
    assert(result is List);
    return result
        .map((e) => Directory(path.normalize(e)))
        .toList()
        .cast<Directory>();
  }

  /// Returns the cache directory.
  /// The internal Harmonoid cache is stored here.
  Future<Directory> get cache async {
    assert(Platform.isAndroid);
    final result = await _channel.invokeMethod('cache');
    assert(result is String);
    return Directory(path.normalize(result));
  }

  /// Deletes given [File]s from the user's device.
  /// Returns [bool] based on success & user approval.
  ///
  /// Deleting multiple [File]s at once is not supported only on Android 10 (API 29).
  ///
  Future<bool> delete(Iterable<File> files) async {
    assert(Platform.isAndroid);
    debugPrint('StorageRetriever.delete: $files');
    _deleteCompleter = Completer();
    await _channel.invokeMethod(
      'delete',
      {
        'paths': files.map((e) => e.path).toList(),
      },
    );
    final result = await _deleteCompleter.future;
    debugPrint('StorageRetriever.delete: $files: $result');
    return result;
  }

  Future<int> get _version async {
    assert(Platform.isAndroid);
    final result = await _channel.invokeMethod('version');
    debugPrint(result.toString());
    assert(result is int);
    return result;
  }

  /// Used by [delete] to receive result from native code from [onActivityResult].
  ///
  Completer<bool> _deleteCompleter = Completer<bool>();

  /// Prevent registering method call handler on platform channel more than once.
  static bool _initialized = false;

  final MethodChannel _channel =
      const MethodChannel('com.alexmercerind.harmonoid.StorageRetriever');
}
