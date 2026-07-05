// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playback_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PlaybackState _$PlaybackStateFromJson(Map<String, dynamic> json) => _PlaybackState(
  index: (json['index'] as num).toInt(),
  playables: (json['playables'] as List<dynamic>).map((e) => Playable.fromJson(e as Map<String, dynamic>)).toList(),
  rate: (json['rate'] as num).toDouble(),
  pitch: (json['pitch'] as num).toDouble(),
  volume: (json['volume'] as num).toDouble(),
  shuffle: json['shuffle'] as bool,
  loop: $enumDecode(_$LoopEnumMap, json['loop']),
  replayGain: $enumDecode(_$ReplayGainEnumMap, json['replay_gain']),
  replayGainPreamp: (json['replay_gain_preamp'] as num).toDouble(),
  crossfadeDuration: Duration(
    microseconds: (json['crossfade_duration'] as num).toInt(),
  ),
);

Map<String, dynamic> _$PlaybackStateToJson(_PlaybackState instance) => <String, dynamic>{
  'index': instance.index,
  'playables': instance.playables,
  'rate': instance.rate,
  'pitch': instance.pitch,
  'volume': instance.volume,
  'shuffle': instance.shuffle,
  'loop': _$LoopEnumMap[instance.loop]!,
  'replay_gain': _$ReplayGainEnumMap[instance.replayGain]!,
  'replay_gain_preamp': instance.replayGainPreamp,
  'crossfade_duration': instance.crossfadeDuration.inMicroseconds,
};

const _$LoopEnumMap = {Loop.off: 'off', Loop.one: 'one', Loop.all: 'all'};

const _$ReplayGainEnumMap = {
  ReplayGain.off: 'off',
  ReplayGain.track: 'track',
  ReplayGain.album: 'album',
};
