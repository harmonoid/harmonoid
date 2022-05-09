/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///
import 'dart:io';
import 'dart:async';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';
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
    final prefix = Platform.isWindows &&
            !path.startsWith('\\\\') &&
            !path.startsWith(r'\\?\')
        ? r'\\?\'
        : '';
    final completer = Completer();
    final files = <File>[];
    Directory(prefix + path)
        .list(
      recursive: true,
      followLinks: false,
    )
        .listen(
      (event) async {
        // Not a good way, but whatever for performance.
        // Explicitly restricting to [kSupportedFileTypes] for avoiding long iterations in later operations.
        if (event is File && kSupportedFileTypes.contains(event.extension)) {
          // 1 MB or greater in size.
          if (await event.length() > 1024 * 1024) {
            files.add(File(event.path.substring(prefix.isNotEmpty ? 4 : 0)));
          }
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

extension FileExtension on File {
  /// Safely writes [String] [content] to a [File].
  ///
  /// Does not modify the contents of the original file, but
  /// creates a new randomly named file & copies it to the
  /// original [File]'s path for ensured safety & no possible
  /// corruption.
  ///
  /// Thanks to @raitonoberu for the idea.
  ///
  Future<File> write_(String content) async {
    final prefix = Platform.isWindows &&
            !path.startsWith('\\\\') &&
            !path.startsWith(r'\\?\')
        ? r'\\?\'
        : '';
    final file = File(join(prefix + parent.path, 'Temp', const Uuid().v4()));
    if (!await file.exists_()) {
      file.create(recursive: true);
    }
    await file.writeAsString(content, flush: true);
    await file.rename_(prefix + path);
    return this;
  }

  /// Safely [rename]s a [File].
  FutureOr<File> rename_(String newPath) {
    final prefix = Platform.isWindows &&
            !path.startsWith('\\\\') &&
            !path.startsWith(r'\\?\')
        ? r'\\?\'
        : '';
    return File(prefix + path).rename(newPath);
  }
}

extension FileSystemEntityExtension on FileSystemEntity {
  /// Safely deletes a [FileSystemEntity].
  FutureOr<void> delete_() async {
    if (await exists_()) {
      final prefix = Platform.isWindows &&
              !path.startsWith('\\\\') &&
              !path.startsWith(r'\\?\')
          ? r'\\?\'
          : '';
      if (this is File) {
        await File(prefix + path).delete();
      } else if (this is Directory) {
        await Directory(prefix + path).delete();
      }
    }
  }

  /// Safely checks whether a [FileSystemEntity] exists or not.
  FutureOr<bool> exists_() {
    final prefix = Platform.isWindows &&
            !path.startsWith('\\\\') &&
            !path.startsWith(r'\\?\')
        ? r'\\?\'
        : '';
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
    final prefix = Platform.isWindows &&
            !path.startsWith('\\\\') &&
            !path.startsWith(r'\\?\')
        ? r'\\?\'
        : '';
    if (this is File) {
      return File(prefix + path).existsSync();
    } else if (this is Directory) {
      return Directory(prefix + path).existsSync();
    } else {
      return false;
    }
  }
}
