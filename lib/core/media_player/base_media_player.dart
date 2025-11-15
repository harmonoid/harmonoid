import 'package:flutter/foundation.dart';

import 'package:harmonoid/models/loop.dart';
import 'package:harmonoid/models/media_player_state.dart';
import 'package:harmonoid/models/playable.dart';
import 'package:harmonoid/models/replaygain.dart';
import 'package:harmonoid/utils/actions.dart';

/// {@template base_media_player}
///
/// BaseMediaPlayer
/// ---------------
/// Interface implemented by the [MediaPlayer].
///
/// {@endtemplate}
abstract interface class BaseMediaPlayer with ChangeNotifier {
  Playable get current;

  MediaPlayerState get state;

  Future<void> play();

  Future<void> pause();

  Future<void> playOrPause();

  Future<void> next();

  Future<void> previous();

  Future<void> jump(int index);

  Future<void> seek(Duration position);

  Future<void> setLoop(Loop loop);

  Future<void> setRate(double rate);

  Future<void> setPitch(double pitch);

  Future<void> setVolume(double volume);

  Future<void> setMute(bool mute);

  Future<void> setShuffle(bool shuffle);

  Future<void> muteOrUnmute();

  Future<void> open(
    List<Playable> playables, {
    int index = 0,
    bool play = true,
    void Function()? onOpen = mediaPlayerOpenOnOpen,
  });

  Future<void> move(int from, int to);

  Future<void> remove(int index);

  Future<void> add(List<Playable> playables);

  Future<void> insert(int index, Playable playable);

  Future<void> setExclusiveAudio(bool exclusiveAudio);

  Future<void> setReplayGain(ReplayGain replayGain);

  Future<void> setReplayGainPreamp(double replayGainPreamp);

  Future<void> setCrossfadeDuration(Duration crossfadeDuration);
}
