/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Yehuda Kremer <yehudakremer@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';
import 'package:media_library/media_library.dart';
import 'package:safe_local_storage/safe_local_storage.dart';

import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/core/configuration.dart';

/// AppState
/// ---------
///
/// Current playback state persistence management for Harmonoid.
///
class AppState extends AppStateKeys {
  /// [AppState] object instance.
  static final AppState instance = AppState();

  /// [SafeLocalStorage] instance for cache read/write.
  final SafeLocalStorage storage = SafeLocalStorage(
    path.join(
      Configuration.instance.cacheDirectory.path,
      'AppState.JSON',
    ),
    fallback: _default,
  );

  /// Initializes the [AppState] class singleton.
  static Future<void> initialize() async {
    await instance.read();
  }

  Future<void> save(
    int index,
    List<Track> tracks,
    double rate,
    double pitch,
    double volume,
    bool shuffling,
    PlaylistLoopMode playlistLoopMode,
  ) async {
    this.index = index;
    this.tracks = tracks;
    this.rate = rate;
    this.pitch = pitch;
    this.volume = volume;
    this.shuffling = shuffling;
    this.playlistLoopMode = playlistLoopMode;
    await storage.write(
      {
        'index': index,
        'tracks': tracks,
        'rate': rate,
        'pitch': pitch,
        'volume': volume,
        'shuffling': shuffling,
        'playlistLoopMode': playlistLoopMode.index,
      },
    );
  }

  Future<void> read({
    bool retry = true,
  }) async {
    final current = await storage.read();
    final conf = _default;
    // Emplace default values for the keys that not found. Most likely due to update.
    for (final entry in conf.entries) {
      current[entry.key] ??= entry.value;
    }
    try {
      index = current['index'];
      tracks = current['tracks']
          .map((e) => Track.fromJson(e))
          .toList()
          .cast<Track>();
      rate = current['rate'];
      pitch = current['pitch'];
      volume = current['volume'];
      shuffling = current['shuffling'];
      playlistLoopMode = PlaylistLoopMode.values[current['playlistLoopMode']];
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }
  }

  static Map<String, dynamic> get _default => {
        'index': DefaultPlaybackValues.index,
        'tracks': DefaultPlaybackValues.tracks,
        'rate': DefaultPlaybackValues.rate,
        'pitch': DefaultPlaybackValues.pitch,
        'volume': DefaultPlaybackValues.volume,
        'shuffling': DefaultPlaybackValues.shuffling,
        'playlistLoopMode': DefaultPlaybackValues.playlistLoopMode.index,
      };
}

abstract class AppStateKeys {
  late int index;
  late List<Track> tracks;
  late double rate;
  late double pitch;
  late double volume;
  late bool shuffling;
  late PlaylistLoopMode playlistLoopMode;
}
