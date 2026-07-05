import 'package:media_library/media_library.dart' hide FileSystemMediaLibrary;
import 'package:synchronized/synchronized.dart';

import 'package:harmonoid/core/filesystem_media_library.dart';
import 'package:harmonoid/core/media_player/media_player.dart';
import 'package:harmonoid/core/media_player/mixin/media_player_mixin.dart';
import 'package:harmonoid/extensions/playable.dart';
import 'package:harmonoid/models/media_player_state.dart';
import 'package:harmonoid/models/playable.dart';

/// {@template history_playlist_mixin}
///
/// HistoryPlaylistMixin
/// --------------------
/// History playlist mixin for [MediaPlayer].
///
/// {@endtemplate}
final class HistoryPlaylistMixin implements MediaPlayerMixin {
  static bool get supported => true;

  HistoryPlaylistMixin(this._player);

  @override
  Future<void> ensureInitialized() async {
    // NO/OP
  }

  @override
  Future<void> dispose() async {
    // NO/OP
  }

  @override
  Future<void> resetFlags() async {
    _flagPlayable = null;
  }

  @override
  Future<void> notifyState(MediaPlayerState state) {
    return _lock.synchronized(() async {
      final current = _player.current;
      if (_flagPlayable != current) {
        _flagPlayable = current;
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

  final MediaPlayer _player;
  final Lock _lock = Lock();

  Playable? _flagPlayable;
}
