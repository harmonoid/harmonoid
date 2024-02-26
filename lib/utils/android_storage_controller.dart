import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;

/// {@template android_storage_controller}
///
/// AndroidStorageController
/// ------------------------
/// Implementation to retrieve cache & external storage directories on Android.
///
/// {@endtemplate}
class AndroidStorageController {
  /// Singleton instance.
  static final AndroidStorageController instance = AndroidStorageController._();

  /// Whether the [instance] is initialized.
  static bool initialized = false;

  /// Initializes the [instance].
  static Future<void> ensureInitialized() async {
    if (initialized) return;
    initialized = true;
    // According to:
    // https://github.com/flutter/flutter/issues/58160#issuecomment-639139990
    // https://github.com/flutter/samples/blob/master/add_to_app/plugin/android_using_plugin/app/src/main/java/dev/flutter/example/androidusingplugin/MyApplication.kt
    //
    // There seems to be a race condition between Dart code's execution start & creation of [MethodChannel] on the native side.
    //
    // Personally, I have never experienced a [MissingPluginException], but few users have sent us report. So, for now I have decided to do polling on Dart side until the [MethodChannel] correctly responds with the value instead of throwing a [MissingPluginException].
    // This hopefully will avoid any errors before Flutter engine starts, even though with a busy-waiting (if it ever takes place in any rare situation).
    int? result;
    while (result == null) {
      try {
        result = await instance.getVersion();
      } catch (exception, stacktrace) {
        debugPrint(exception.toString());
        debugPrint(stacktrace.toString());
      }
    }
    instance.version = result;
  }

  /// {@macro android_storage_controller}
  AndroidStorageController._() {
    _channel.setMethodCallHandler(
      (call) async {
        debugPrint(call.method.toString());
        debugPrint(call.arguments.toString());
        switch (call.method) {
          case 'delete':
            {
              _deleteCompleter.complete(call.arguments);
              break;
            }
        }
      },
    );
  }

  /// The value of `android.os.Build.VERSION.SDK_INT`. This is used to determine the Android version.
  int version = -1;

  /// Returns the cache directory.
  Future<Directory> get cache async {
    final result = await _channel.invokeMethod('cache');
    return Directory(path.normalize(result));
  }

  /// Returns the [List] of available external storages e.g. internal storage & SD card.
  Future<List<Directory>> get external async {
    final result = await _channel.invokeMethod('external');
    return result.map((e) => Directory(path.normalize(e))).toList().cast<Directory>();
  }

  /// Deletes given [File]s from the user's device.
  /// Returns [bool] based on success & user approval.
  ///
  /// Deleting multiple [File]s at once is not supported only on Android 10 (API 29).
  ///
  Future<bool> delete(Iterable<File> files) async {
    _deleteCompleter = Completer();
    await _channel.invokeMethod(
      'delete',
      {
        'paths': files.map((e) => e.path).toList(),
      },
    );
    final result = await _deleteCompleter.future;
    return result;
  }

  /// Returns the value of `android.os.Build.VERSION.SDK_INT`. This is used to determine the Android version.
  Future<int> getVersion() async {
    final result = await _channel.invokeMethod('version');
    return result;
  }

  /// Used by [delete] to receive pending result from platform channels.
  Completer<bool> _deleteCompleter = Completer<bool>();

  /// [MethodChannel] used to communicate with the native platform.
  final MethodChannel _channel = const MethodChannel('com.alexmercerind.harmonoid.AndroidStorageController');
}
