/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///
import 'dart:io';
import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:harmonoid/core/collection.dart';

extension DirectoryExtension on Directory {
  /// Recursively lists all the present [File]s inside the [Directory].
  ///
  /// * Safely handles long file-paths on Windows (https://github.com/dart-lang/sdk/issues/27825).
  /// * Does not terminate on errors e.g. an encounter of `Access Is Denied`.
  /// * Does not follow links.
  /// * Returns only [List] of [File]s.
  ///
  Future<List<File>> list_() async {
    final prefix =
        Platform.isWindows && !path.startsWith('\\\\') ? r'\\?\' : '';
    final completer = Completer();
    final files = <File>[];
    Directory(prefix + path)
        .list(
      recursive: true,
      followLinks: false,
    )
        .listen(
      (event) {
        // Explicitly restricting to [kSupportedFileTypes] for avoiding long iterations in later operations.
        if (event is File && kSupportedFileTypes.contains(event.extension)) {
          files.add(File(event.path.substring(prefix.isNotEmpty ? 4: 0)));
        }
      },
      onError: (error) {
        // For debugging. In case any future error is reported.
        debugPrint('Directory.list_: ${error}');
      },
      onDone: completer.complete,
    );
    await completer.future;
    return files;
  }
}

extension FileSystemEntityExtension on FileSystemEntity {
  /// Safely deletes a [FileSystemEntity].
  FutureOr<void> delete_() async {
    if (await exists_()) {
      final prefix =
          Platform.isWindows && !path.startsWith('\\\\') ? r'\\?\' : '';
      if (this is File) {
        await File(prefix + path).delete();
      } else if (this is Directory) {
        await Directory(prefix + path).delete();
      }
    }
  }

  /// Safely checks whether a [FileSystemEntity] exists or not.
  FutureOr<bool> exists_() {
    final prefix =
        Platform.isWindows && !path.startsWith('\\\\') ? r'\\?\' : '';
    if (this is File) {
      return File(prefix + path).exists();
    } else if (this is Directory) {
      return Directory(prefix + path).exists();
    } else {
      return false;
    }
  }

  /// Safely checks whether a [FileSystemEntity] exists or not.
  bool existsSync_() {
    final prefix =
        Platform.isWindows && !path.startsWith('\\\\') ? r'\\?\' : '';
    if (this is File) {
      return File(prefix + path).existsSync();
    } else if (this is Directory) {
      return Directory(prefix + path).existsSync();
    } else {
      return false;
    }
  }
}
