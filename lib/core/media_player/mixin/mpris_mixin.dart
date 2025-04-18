import 'dart:io';
import 'package:mpris_service/mpris_service.dart';
import 'package:synchronized/synchronized.dart';

import 'package:harmonoid/core/intent.dart';
import 'package:harmonoid/core/media_player/base_media_player.dart';
import 'package:harmonoid/extensions/media_player_state.dart';
import 'package:harmonoid/mappers/playable.dart';
import 'package:harmonoid/models/loop.dart';
import 'package:harmonoid/models/playable.dart';

/// {@template mpris_mixin}
///
/// MprisMixin
/// ----------
/// package:mpris_service mixin for [BaseMediaPlayer].
///
/// {@endtemplate}
mixin MprisMixin implements BaseMediaPlayer {
  static const String kBusName = 'org.mpris.MediaPlayer2.harmonoid';
  static const String kIdentity = 'Harmonoid';
  static const String kDesktopEntry = '/usr/share/applications/harmonoid';

  static bool get supported => Platform.isLinux;

  Future<void> ensureInitializedMpris() async {
    if (!supported) return;

    final instance = await MPRIS.create(
      busName: kBusName,
      identity: kIdentity,
      desktopEntry: kDesktopEntry,
    )
      ..minimumRate = 0.5
      ..maximumRate = 2.0
      ..setEventHandler(
        MPRISEventHandler(
          next: () => next(),
          previous: () => previous(),
          pause: () => pause(),
          playPause: () => playOrPause(),
          play: () => play(),
          seek: (value) => seek(value),
          setPosition: (_, value) => seek(Duration(microseconds: value)),
          openUri: (value) => Intent.instance.play(value.toString()),
          loopStatus: (value) => setLoop(
            switch (value) {
              MPRISLoopStatus.none => Loop.off,
              MPRISLoopStatus.track => Loop.one,
              MPRISLoopStatus.playlist => Loop.all,
            },
          ),
          rate: (value) => setRate(value),
          shuffle: (value) => setShuffle(value),
          volume: (value) => setVolume(value * 100.0),
        ),
      );

    _instanceMpris = instance;

    addListener(_listenerMpris);
  }

  Future<void> disposeMpris() async {
    if (!supported) return;

    await _instanceMpris?.dispose();
  }

  void resetFlagsMpris() {
    _flagPlayableMpris = null;
  }

  void _listenerMpris() {
    _lockMpris.synchronized(() async {
      _instanceMpris
        ?..playbackStatus = switch ((state.completed, state.playing)) {
          (true, _) => MPRISPlaybackStatus.stopped,
          (false, true) => MPRISPlaybackStatus.playing,
          (false, false) => MPRISPlaybackStatus.paused,
        }
        ..loopStatus = switch (state.loop) {
          Loop.off => MPRISLoopStatus.none,
          Loop.one => MPRISLoopStatus.track,
          Loop.all => MPRISLoopStatus.playlist,
        }
        ..rate = state.rate
        ..volume = state.volume
        ..shuffle = state.shuffle
        ..position = state.position
        ..canGoPrevious = !state.isFirst
        ..canGoNext = !state.isLast;

      if (_flagPlayableMpris != current && state.duration > Duration.zero) {
        _flagPlayableMpris = current;
        _instanceMpris?.metadata = await current.toMPRISMetadata(state);
      }
    });
  }

  MPRIS? _instanceMpris;
  final Lock _lockMpris = Lock();

  Playable? _flagPlayableMpris;
}
