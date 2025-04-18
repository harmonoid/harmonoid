import 'dart:io';

import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:path/path.dart';

/// Extensions for [Configuration].
extension ConfigurationExtensions on Configuration {
  /// Adds a directory to [mediaLibraryDirectories].
  Future<void> addMediaLibraryDirectory(Directory directory) async {
    final current = mediaLibraryDirectories.map((e) => normalize(e.path)).toList();
    current.add(normalize(directory.path));
    await set(mediaLibraryDirectories: current.toSet().map((e) => Directory(e)).toSet());
  }

  /// Removes a directory from [mediaLibraryDirectories].
  Future<void> removeMediaLibraryDirectory(Directory directory) async {
    final current = mediaLibraryDirectories.map((e) => normalize(e.path)).toList();
    current.remove(normalize(directory.path));
    await set(mediaLibraryDirectories: current.toSet().map((e) => Directory(e)).toSet());
  }
}
