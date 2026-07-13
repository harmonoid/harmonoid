import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:mpris_service/mpris_service.dart';
import 'package:synchronized/synchronized.dart';

import 'package:harmonoid/core/intent.dart';
import 'package:harmonoid/core/media_player/media_player.dart';
import 'package:harmonoid/core/media_player/mixin/media_player_mixin.dart';
import 'package:harmonoid/extensions/media_player_state.dart';
import 'package:harmonoid/mappers/playable.dart';
import 'package:harmonoid/core/media_player/models/media_player_state.dart';
import 'package:harmonoid/core/media_player/models/loop.dart';
import 'package:harmonoid/core/media_player/models/playable.dart';

/// {@template mpris_mixin}
///
/// MprisMixin
/// ----------
/// package:mpris_service mixin for [MediaPlayer].
///
/// {@endtemplate}
final class MprisMixin implements MediaPlayerMixin {
  static const String kBusName = 'org.mpris.MediaPlayer2.harmonoid';
  static const String kIdentity = 'Harmonoid';
  static const String kDesktopEntry = '/usr/share/applications/harmonoid';

  static bool get supported => Platform.isLinux;

  MprisMixin(this._player);

  @override
  Future<void> ensureInitialized() async {
    try {
      final instance =
          await MPRIS.create(
              busName: kBusName,
              identity: kIdentity,
              desktopEntry: kDesktopEntry,
            )
            ..minimumRate = 0.5
            ..maximumRate = 2.0
            ..setEventHandler(
              MPRISEventHandler(
                next: () => _player.next(),
                previous: () => _player.previous(),
                pause: () => _player.pause(),
                playPause: () => _player.playOrPause(),
                play: () => _player.play(),
                seek: (value) => _player.seek(value),
                setPosition: (_, value) => _player.seek(Duration(microseconds: value)),
                openUri: (value) => Intent.instance.play(value.toString()),
                loopStatus: (value) => _player.setLoop(
                  switch (value) {
                    MPRISLoopStatus.none => Loop.off,
                    MPRISLoopStatus.track => Loop.one,
                    MPRISLoopStatus.playlist => Loop.all,
                  },
                ),
                rate: (value) => _player.setRate(value),
                shuffle: (value) => _player.setShuffle(value),
                volume: (value) => _player.setVolume(value * 100.0),
              ),
            );

      _instance = instance;
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }
  }

  @override
  Future<void> dispose() async {
    await _instance?.dispose();
  }

  @override
  Future<void> resetFlags() async {
    _flagPlayable = null;
    _flagPlaybackStatus = null;
    _flagLoop = null;
    _flagRate = null;
    _flagVolume = null;
    _flagShuffle = null;
    _flagPosition = null;
    _flagCanGoPrevious = null;
    _flagCanGoNext = null;
  }

  @override
  Future<void> notifyState(MediaPlayerState state) {
    return _lock.synchronized(() async {
      final current = _player.current;

      final playbackStatus = switch ((state.completed, state.playing)) {
        (true, _) => MPRISPlaybackStatus.stopped,
        (false, true) => MPRISPlaybackStatus.playing,
        (false, false) => MPRISPlaybackStatus.paused,
      };
      if (_flagPlaybackStatus != playbackStatus) {
        _flagPlaybackStatus = playbackStatus;
        _instance?.playbackStatus = playbackStatus;
      }

      final loop = switch (state.loop) {
        Loop.off => MPRISLoopStatus.none,
        Loop.one => MPRISLoopStatus.track,
        Loop.all => MPRISLoopStatus.playlist,
      };
      if (_flagLoop != loop) {
        _flagLoop = loop;
        _instance?.loopStatus = loop;
      }

      if (_flagRate != state.rate) {
        _flagRate = state.rate;
        _instance?.rate = state.rate;
      }

      if (_flagVolume != state.volume) {
        _flagVolume = state.volume;
        _instance?.volume = state.volume;
      }

      if (_flagShuffle != state.shuffle) {
        _flagShuffle = state.shuffle;
        _instance?.shuffle = state.shuffle;
      }

      if (_flagPosition == null || (state.position - _flagPosition!).abs() > const Duration(seconds: 1)) {
        _flagPosition = state.position;
        _instance?.position = state.position;
      }

      final canGoPrevious = !state.isFirst;
      if (_flagCanGoPrevious != canGoPrevious) {
        _flagCanGoPrevious = canGoPrevious;
        _instance?.canGoPrevious = canGoPrevious;
      }

      final canGoNext = !state.isLast;
      if (_flagCanGoNext != canGoNext) {
        _flagCanGoNext = canGoNext;
        _instance?.canGoNext = canGoNext;
      }

      if (_flagPlayable != current && _flagDuration != state.duration && state.duration > Duration.zero) {
        _flagPlayable = current;
        _flagDuration = state.duration;
        _instance?.metadata = await current.toMPRISMetadata(state);
      }
    });
  }

  final MediaPlayer _player;

  MPRIS? _instance;
  final Lock _lock = Lock();

  MPRISPlaybackStatus? _flagPlaybackStatus;
  MPRISLoopStatus? _flagLoop;
  double? _flagRate;
  double? _flagVolume;
  bool? _flagShuffle;
  Duration? _flagPosition;
  bool? _flagCanGoPrevious;
  bool? _flagCanGoNext;
  Playable? _flagPlayable;
  Duration? _flagDuration;
}
