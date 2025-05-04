// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playback_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PlaybackStateImpl _$$PlaybackStateImplFromJson(Map<String, dynamic> json) =>
    _$PlaybackStateImpl(
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
    );

Map<String, dynamic> _$$PlaybackStateImplToJson(_$PlaybackStateImpl instance) =>
    <String, dynamic>{
      'index': instance.index,
      'playables': instance.playables,
      'rate': instance.rate,
      'pitch': instance.pitch,
      'volume': instance.volume,
      'shuffle': instance.shuffle,
      'loop': _$LoopEnumMap[instance.loop]!,
      'exclusiveAudio': instance.exclusiveAudio,
    };

const _$LoopEnumMap = {
  Loop.off: 'off',
  Loop.one: 'one',
  Loop.all: 'all',
};
