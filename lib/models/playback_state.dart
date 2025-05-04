import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:harmonoid/models/loop.dart';
import 'package:harmonoid/models/playable.dart';

part 'playback_state.freezed.dart';
part 'playback_state.g.dart';

@freezed
class PlaybackState with _$PlaybackState {
  const factory PlaybackState({
    required int index,
    required List<Playable> playables,
    required double rate,
    required double pitch,
    required double volume,
    required bool shuffle,
    required Loop loop,
    required bool exclusiveAudio,
  }) = _PlaybackState;

  factory PlaybackState.fromJson(Map<String, dynamic> json) => _$PlaybackStateFromJson(json);
}
