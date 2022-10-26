/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Yehuda Kremer <yehudakremer@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'package:path/path.dart' as path;
import 'package:media_library/media_library.dart';
import 'package:safe_local_storage/safe_local_storage.dart';

import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/core/configuration.dart';

/// App State
/// ---------
///
/// App state persistence for [Harmonoid](https://github.com/harmonoid/harmonoid).
/// Used to resume the state of the app after a restart.
///
class AppState extends AppStateKeys {
  /// [AppState] object instance.
  static late AppState instance = AppState();

  /// [SafeLocalStorage] instance for cache read/write.
  late SafeLocalStorage storage;

  /// Initializes the [AppState] class.
  ///
  /// Called after the [Configuration.initialize] and load the app state.
  /// Generates from scratch if no state is found.
  ///
  static Future<void> initialize() async {
    instance.storage = SafeLocalStorage(
      path.join(
        Configuration.instance.cacheDirectory.path,
        'AppState.JSON',
      ),
      fallback: _defaultAppState,
    );
    await instance.read();
  }

  /// Updates and save the app state in the [file].
  Future<void> save(
    List<Track> playlist,
    int index,
    double rate,
    bool shuffle,
    PlaylistLoopMode playlistLoopMode,
    double volume,
    double pitch,
  ) async {
    this.playlist = playlist;
    this.index = index;
    this.rate = rate;
    this.shuffle = shuffle;
    this.playlistLoopMode = playlistLoopMode;
    this.volume = volume;
    this.pitch = pitch;

    await storage.write(
      {
        'playlist': playlist,
        'index': index,
        'rate': rate,
        'shuffle': shuffle,
        'playlistLoopMode': playlistLoopMode.index,
        'volume': volume,
        'pitch': pitch,
      },
    );
  }

  /// Reads the app state from the [file].
  Future<void> read({
    bool retry = true,
  }) async {
    final current = await storage.read();
    // Emblace default values for the keys that not found. Possibly due to app update.
    _defaultAppState.keys.forEach(
      (key) {
        if (!current.containsKey(key)) {
          current[key] = _defaultAppState[key];
        }
      },
    );

    playlist = (current['playlist'] as List)
        .map((e) => Track.fromJson(e))
        .toList()
        .cast<Track>();
    index = current['index'];
    rate = current['rate'];
    shuffle = current['shuffle'];
    playlistLoopMode = PlaylistLoopMode.values[current['playlistLoopMode']];
    volume = current['volume'];
    pitch = current['pitch'];
  }
}

abstract class AppStateKeys {
  late List<Track> playlist;
  late int index;
  late double rate;
  late bool shuffle;
  late PlaylistLoopMode playlistLoopMode;
  late double volume;
  late double pitch;
}

final Map<String, dynamic> _defaultAppState = {
  'playlist': DefaultPlaybackValues.tracks,
  'index': DefaultPlaybackValues.index,
  'rate': DefaultPlaybackValues.rate,
  'shuffle': DefaultPlaybackValues.isShuffling,
  'playlistLoopMode': DefaultPlaybackValues.playlistLoopMode.index,
  'volume': DefaultPlaybackValues.volume,
  'pitch': DefaultPlaybackValues.pitch,
};
