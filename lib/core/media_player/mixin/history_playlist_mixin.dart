import 'package:flutter/foundation.dart';
import 'package:media_library/media_library.dart' hide FileSystemMediaLibrary;
import 'package:synchronized/synchronized.dart';

import 'package:harmonoid/core/filesystem_media_library.dart';
import 'package:harmonoid/core/media_player/base_media_player.dart';
import 'package:harmonoid/extensions/playable.dart';
import 'package:harmonoid/models/playable.dart';

/// {@template stub_mixin}
///
/// HistoryPlaylistMixin
/// --------------------
/// History playlist mixin for [BaseMediaPlayer].
///
/// {@endtemplate}
mixin HistoryPlaylistMixin implements BaseMediaPlayer {
  static bool get supported => true;

  Future<void> ensureInitializedHistoryPlaylist() async {
    if (!supported) return;
    // NO/OP
    try {
      addListener(_listenerHistoryPlaylist);
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }
  }

  Future<void> disposeHistoryPlaylist() async {
    if (!supported) return;
    // NO/OP
  }

  void resetFlagsHistoryPlaylist() {
    _flagPlayableHistoryPlaylist = null;
  }

  void _listenerHistoryPlaylist() {
    _lockHistoryPlaylist.synchronized(() async {
      if (_flagPlayableHistoryPlaylist != current) {
        _flagPlayableHistoryPlaylist = current;
        // TODO: Add support for HTTP URIs.
        if (await FileSystemMediaLibrary.instance.db.contains(current.uri)) {
          // Save as track i.e. hash + title.
          await FileSystemMediaLibrary.instance.playlists.addToHistory(track: FileSystemMediaLibrary.instance.lookupTrack(TrackLookupKey(uri: current.uri)));
        } else {
          // Save as uri + title.
          await FileSystemMediaLibrary.instance.playlists.addToHistory(uri: current.uri, title: current.playlistEntryTitle);
        }
      }
    });
  }

  final Lock _lockHistoryPlaylist = Lock();

  Playable? _flagPlayableHistoryPlaylist;
}
