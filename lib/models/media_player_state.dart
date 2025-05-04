import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:media_kit/media_kit.dart' show AudioParams;

import 'package:harmonoid/models/loop.dart';
import 'package:harmonoid/models/playable.dart';

part 'media_player_state.freezed.dart';

@freezed
class MediaPlayerState with _$MediaPlayerState {
  const factory MediaPlayerState({
    required int index,
    required List<Playable> playables,
    required double rate,
    required double pitch,
    required double volume,
    required bool shuffle,
    required Loop loop,
    required bool exclusiveAudio,
    required Duration position,
    required Duration duration,
    required bool playing,
    required bool buffering,
    required bool completed,
    required double audioBitrate,
    required AudioParams audioParams,
  }) = _MediaPlayerState;

  factory MediaPlayerState.defaults() => const MediaPlayerState(
        index: 0,
        playables: [],
        rate: 1.0,
        pitch: 1.0,
        volume: 100.0,
        shuffle: false,
        loop: Loop.off,
        exclusiveAudio: false,
        position: Duration.zero,
        duration: Duration.zero,
        playing: false,
        buffering: false,
        completed: false,
        audioBitrate: 0.0,
        audioParams: AudioParams(),
      );
}
