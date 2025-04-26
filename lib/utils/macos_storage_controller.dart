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
  static const String kMethodChannelName = 'com.alexmercerind.harmonoid/storage_controller';
  static const String kPickDirectoryMethodName = 'pickDirectory';
  static const String kPickFileMethodName = 'pickFile';
  static const String kPreserveAccessMethodName = 'preserveAccess';
  static const String kInvalidateAccessMethodName = 'invalidateAccess';
  static const String kGetDefaultMediaLibraryDirectoryMethodName = 'getDefaultMediaLibraryDirectory';

  static const String kPickFileAllowedFileTypesArg = 'allowedFileTypes';
  static const String kPreserveAccessPathArg = 'path';
  static const String kInvalidateAccessPathArg = 'path';

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
        kPickFileAllowedFileTypesArg: allowedFileTypes,
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
        kPreserveAccessPathArg: path.normalize(fileSystemEntity.path),
      },
    );
  }

  Future<void> invalidateAccess(FileSystemEntity fileSystemEntity) async {
    await _channel.invokeMethod(
      kInvalidateAccessMethodName,
      {
        kInvalidateAccessPathArg: path.normalize(fileSystemEntity.path),
      },
    );
  }

  Future<Directory?> getDefaultMediaLibraryDirectory() async {
    final result = await _channel.invokeMethod(
      kGetDefaultMediaLibraryDirectoryMethodName,
    );
    if (result != null) {
      return Directory(path.normalize(result));
    }
    return null;
  }

  final MethodChannel _channel = const MethodChannel(kMethodChannelName);
}
