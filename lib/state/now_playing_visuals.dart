/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///
import 'dart:io';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';
import 'package:safe_local_storage/safe_local_storage.dart';

import 'package:harmonoid/core/configuration.dart';

/// This class handles the visuals shown in the [NowPlayingScreen].
/// Must call [NowPlayingVisuals.initialize].
///
/// There are two kinds of visuals:
/// * Pre-loaded visuals i.e. bundled as app assets.
/// * User-added visuals i.e. added by user from local storage.
///
class NowPlayingVisuals {
  /// [NowPlayingVisuals] object instance. Must call [NowPlayingVisuals.initialize].
  static NowPlayingVisuals instance = NowPlayingVisuals();

  final List<String> preloaded = List.generate(
    kPreloadedNowPlayingVisualsCount,
    (index) => 'assets/preloaded_visuals/$index.gif',
  );

  final List<String> user = <String>[];

  late final Directory directory;

  static Future<void> initialize() async {
    instance.directory = Directory(
      join(
        Configuration.instance.cacheDirectory.path,
        'UserVisuals',
      ),
    );
    if (await instance.directory.exists_()) {
      final directory = await instance.directory.list_();
      for (final entity in directory) {
        instance.user.add(entity.path);
      }
    } else {
      await instance.directory.create_();
    }
  }

  /// Adds a new user provided visual to the list of user visuals & saves it to app's cache [Directory].
  Future<void> add(File file) async {
    final path = join(
      instance.directory.path,
      Uuid().v4(),
    );
    await file.copy_(path);
    instance.user.add(path);
  }

  /// Removes a previously added visual & deletes it from app's cache [Directory].
  Future<void> remove(String path) {
    user.remove(path);
    return File(path).delete_();
  }
}

/// Count of preloaded visuals present in app's assets.
/// Used for generating the asset path.
const kPreloadedNowPlayingVisualsCount = 9;

/// [List] of image file extensions to filter the [File]s correctly.
const kSupportedImageFormats = [
  'JPG',
  'JPEG',
  'PNG',
  'WEBP',
  'GIF',
  'BMP',
  'TIF',
  'TIFF',
  'TGA',
];
