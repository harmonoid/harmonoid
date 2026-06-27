import 'dart:async';
import 'dart:io';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';

import 'package:harmonoid/core/media_player/base_media_player.dart';

/// {@template audio_session_mixin}
///
/// AudioSessionMixin
/// -----------------
/// package:audio_session mixin for [BaseMediaPlayer].
///
/// {@endtemplate}
mixin AudioSessionMixin implements BaseMediaPlayer {
  static bool get supported => Platform.isAndroid || Platform.isIOS;

  Future<void> ensureInitializedAudioSession() async {
    if (!supported) return;

    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
      instanceAudioSession = session;

      _interruptionSubscription = session.interruptionEventStream.listen((event) {
        if (event.begin) {
          pause();
        } else {
          play();
        }
      });
      _becomingNoisySubscription = session.becomingNoisyEventStream.listen((_) {
        pause();
      });

      addListener(_listenerAudioSession);
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }
  }

  Future<void> disposeAudioSession() async {
    if (!supported) return;
    await _interruptionSubscription?.cancel();
    await _becomingNoisySubscription?.cancel();
  }

  void resetFlagsAudioSession() {
    // _flagPlayingAudioSession = null;
  }

  Future<void> setActiveAudioSession(bool active) async {
    await instanceAudioSession?.setActive(active);
  }

  void _listenerAudioSession() {
    // NOTE: Following causes issues on iOS upon index changes.
    //       Only being called for manual play/pause/playOrPause now.
    //       Calling setActive(false) blocks all audio output, media_kit flips playing stream along side completed stream.
    // _lockAudioSession.synchronized(() async {
    //   if (_flagPlayingAudioSession != state.playing) {
    //     _flagPlayingAudioSession = state.playing;
    //     await instanceAudioSession?.setActive(state.playing);
    //   }
    // });
  }

  AudioSession? instanceAudioSession;
  // final Lock _lockAudioSession = Lock();

  // bool? _flagPlayingAudioSession;

  StreamSubscription<AudioInterruptionEvent>? _interruptionSubscription;
  StreamSubscription<void>? _becomingNoisySubscription;
}
