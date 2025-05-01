import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;

/// {@template android_storage_controller}
///
/// AndroidStorageController
/// ------------------------
/// Implementation to handle Android specific file operations.
///
/// {@endtemplate}
class AndroidStorageController {
  static const String kMethodChannelName = 'com.alexmercerind.harmonoid/storage_controller';
  static const String kGetStorageDirectoriesMethodName = 'getStorageDirectories';
  static const String kGetCacheDirectoryMethodName = 'getCacheDirectory';
  static const String kGetDefaultMediaLibraryDirectoryMethodName = 'getDefaultMediaLibraryDirectory';
  static const String kGetVersion = 'getVersion';
  static const String kDelete = 'delete';
  static const String kNotifyDeleteMethodName = 'notifyDelete';
  static const String kGetCoverFileMethodName = 'getCoverFile';

  static const String kDeletePathsArg = 'paths';
  static const String kGetCoverFilePathArg = 'path';

  /// Singleton instance.
  static final AndroidStorageController instance = AndroidStorageController._();

  /// Whether the [instance] is initialized.
  static bool initialized = false;

  /// Initializes the [instance].
  static Future<void> ensureInitialized() async {
    if (!Platform.isAndroid) return;
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
          case kNotifyDeleteMethodName:
            {
              _deleteCompleter.complete(call.arguments);
              break;
            }
        }
      },
    );
  }

  int version = -1;

  Future<List<Directory>> getStorageDirectories() async {
    final result = await _channel.invokeMethod(kGetStorageDirectoriesMethodName);
    return result.map((e) => Directory(path.normalize(e))).toList().cast<Directory>();
  }

  Future<Directory> getCacheDirectory() async {
    final result = await _channel.invokeMethod(kGetCacheDirectoryMethodName);
    return Directory(path.normalize(result));
  }

  Future<Directory> getDefaultMediaLibraryDirectory() async {
    final result = await _channel.invokeMethod(kGetDefaultMediaLibraryDirectoryMethodName);
    return Directory(path.normalize(result));
  }

  Future<int> getVersion() async {
    final result = await _channel.invokeMethod(kGetVersion);
    return result;
  }

  Future<bool> delete(Iterable<File> files) async {
    _deleteCompleter = Completer();
    await _channel.invokeMethod(
      kDelete,
      {
        kDeletePathsArg: files.map((e) => path.normalize(e.path)).toList(),
      },
    );
    final result = await _deleteCompleter.future;
    return result;
  }

  Future<File?> getCoverFile(File file) async {
    final result = await _channel.invokeMethod(
      kGetCoverFileMethodName,
      {
        kGetCoverFilePathArg: file.path,
      },
    );
    if (result != null) {
      return File(path.normalize(result));
    }
    return null;
  }

  Completer<bool> _deleteCompleter = Completer<bool>();

  final MethodChannel _channel = const MethodChannel(kMethodChannelName);
}
