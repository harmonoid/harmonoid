import 'dart:async';
import 'dart:io';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';

import 'package:harmonoid/core/media_player/media_player.dart';
import 'package:harmonoid/core/media_player/mixin/media_player_mixin.dart';
import 'package:harmonoid/core/media_player/models/media_player_state.dart';

/// {@template audio_session_mixin}
///
/// AudioSessionMixin
/// -----------------
/// package:audio_session mixin for [MediaPlayer].
///
/// {@endtemplate}
final class AudioSessionMixin implements MediaPlayerMixin {
  static bool get supported => Platform.isAndroid || Platform.isIOS;

  AudioSessionMixin(this._player);

  @override
  Future<void> ensureInitialized() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
      _instance = session;

      _interruptionSubscription = session.interruptionEventStream.listen((event) {
        if (event.begin) {
          _player.pause();
        } else {
          _player.play();
        }
      });
      _becomingNoisySubscription = session.becomingNoisyEventStream.listen((_) {
        _player.pause();
      });
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }
  }

  @override
  Future<void> dispose() async {
    await _interruptionSubscription?.cancel();
    await _becomingNoisySubscription?.cancel();
  }

  @override
  Future<void> resetFlags() async {
    // _flagPlaying = null;
  }

  @override
  Future<void> notifyState(MediaPlayerState state) async {
    // NOTE: Following causes issues on iOS upon index changes.
    //       Only being called for manual play/pause/playOrPause now.
    //       Calling setActive(false) blocks all audio output, media_kit flips playing stream along side completed stream.
    // _lock.synchronized(() async {
    //   if (_flagPlaying != state.playing) {
    //     _flagPlaying = state.playing;
    //     await _instance?.setActive(state.playing);
    //   }
    // });
  }

  Future<void> setActive(bool active) async {
    await _instance?.setActive(active);
  }

  Future<void> configure(AudioSessionConfiguration configuration) async {
    await _instance?.configure(configuration);
  }

  final MediaPlayer _player;

  AudioSession? _instance;
  // final Lock _lock = Lock();

  // bool? _flagPlaying;

  StreamSubscription<AudioInterruptionEvent>? _interruptionSubscription;
  StreamSubscription<void>? _becomingNoisySubscription;
}
