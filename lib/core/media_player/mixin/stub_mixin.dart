import 'package:flutter/foundation.dart';
import 'package:synchronized/synchronized.dart';

import 'package:harmonoid/core/media_player/media_player.dart';
import 'package:harmonoid/core/media_player/mixin/media_player_mixin.dart';
import 'package:harmonoid/models/media_player_state.dart';
import 'package:harmonoid/models/playable.dart';

/// {@template stub_mixin}
///
/// StubMixin
/// ---------
/// Stub (for reference) mixin for [MediaPlayer].
///
/// {@endtemplate}
final class StubMixin implements MediaPlayerMixin {
  static bool get supported => true;

  StubMixin(this._player);

  @override
  Future<void> ensureInitialized() async {
    const instance = null;

    _instance = instance;
  }

  @override
  Future<void> dispose() async {
    _instance = null;
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
        debugPrint(_instance.toString());
      }
    });
  }

  final MediaPlayer _player;

  Null _instance;
  final Lock _lock = Lock();

  Playable? _flagPlayable;
}
