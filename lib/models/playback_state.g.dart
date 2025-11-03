// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playback_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PlaybackState _$PlaybackStateFromJson(Map<String, dynamic> json) =>
    _PlaybackState(
      index: (json['index'] as num).toInt(),
      playables: (json['playables'] as List<dynamic>)
          .map((e) => Playable.fromJson(e as Map<String, dynamic>))
          .toList(),
      rate: (json['rate'] as num).toDouble(),
      pitch: (json['pitch'] as num).toDouble(),
      volume: (json['volume'] as num).toDouble(),
      shuffle: json['shuffle'] as bool,
      loop: $enumDecode(_$LoopEnumMap, json['loop']),
      exclusiveAudio: json['exclusiveAudio'] as bool,
      replayGain: $enumDecode(_$ReplayGainEnumMap, json['replayGain']),
      replayGainPreamp: (json['replayGainPreamp'] as num).toDouble(),
    );

Map<String, dynamic> _$PlaybackStateToJson(_PlaybackState instance) =>
    <String, dynamic>{
      'index': instance.index,
      'playables': instance.playables,
      'rate': instance.rate,
      'pitch': instance.pitch,
      'volume': instance.volume,
      'shuffle': instance.shuffle,
      'loop': _$LoopEnumMap[instance.loop]!,
      'exclusiveAudio': instance.exclusiveAudio,
      'replayGain': _$ReplayGainEnumMap[instance.replayGain]!,
      'replayGainPreamp': instance.replayGainPreamp,
    };

const _$LoopEnumMap = {Loop.off: 'off', Loop.one: 'one', Loop.all: 'all'};

const _$ReplayGainEnumMap = {
  ReplayGain.off: 'off',
  ReplayGain.track: 'track',
  ReplayGain.album: 'album',
};
