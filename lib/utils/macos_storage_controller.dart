import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;

/// {@template macos_storage_controller}
///
/// MacOSStorageController
/// ----------------------
/// Implementation to handle macOS specific file operations.
///
/// {@endtemplate}
class MacOSStorageController {
  static const kMethodChannelName = 'com.alexmercerind.harmonoid/storage_controller';
  static const kPickDirectoryMethodName = 'pickDirectory';
  static const kPickFileMethodName = 'pickFile';
  static const kPreserveAccessMethodName = 'preserveAccess';
  static const kInvalidateAccessMethodName = 'invalidateAccess';

  /// Singleton instance.
  static const MacOSStorageController instance = MacOSStorageController._();

  /// Whether the [instance] is initialized.
  static bool initialized = false;

  /// Initializes the [instance].
  static Future<void> ensureInitialized({required Set<Directory> directories}) async {
    if (!Platform.isMacOS) return;
    if (initialized) return;
    initialized = true;

    for (final directory in directories) {
      await instance.preserveAccess(directory);
    }
  }

  /// {@macro macos_storage_controller}
  const MacOSStorageController._();

  Future<Directory?> pickDirectory({
    // It's important to preserve access to any directory picked by the user.
    bool usePreserveAccess = true,
  }) async {
    final result = await _channel.invokeMethod(
      kPickDirectoryMethodName,
    );

    if (result != null) {
      final directory = Directory(path.normalize(result));
      if (usePreserveAccess) {
        await preserveAccess(directory);
      }
      return directory;
    }
    return null;
  }

  Future<File?> pickFile(
    List<String> allowedFileTypes, {
    // It's not necessary to preserve access to any file picked by the user.
    bool usePreserveAccess = false,
  }) async {
    final result = await _channel.invokeMethod(
      kPickFileMethodName,
      {
        'allowedFileTypes': allowedFileTypes,
      },
    );

    if (result != null) {
      final file = File(path.normalize(result));
      if (usePreserveAccess) {
        await preserveAccess(file);
      }
      return file;
    }
    return null;
  }

  Future<void> preserveAccess(FileSystemEntity fileSystemEntity) async {
    await _channel.invokeMethod(
      kPreserveAccessMethodName,
      {
        'path': path.normalize(fileSystemEntity.path),
      },
    );
  }

  Future<void> invalidateAccess(FileSystemEntity fileSystemEntity) async {
    await _channel.invokeMethod(
      kInvalidateAccessMethodName,
      {
        'path': path.normalize(
          fileSystemEntity.path,
        ),
      },
    );
  }

  final MethodChannel _channel = const MethodChannel(kMethodChannelName);
}
