// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lyrics_key.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LyricsKey _$LyricsKeyFromJson(Map<String, dynamic> json) => _LyricsKey(
  track: json['track'] as String,
  artist: json['artist'] as String,
  duration: (json['duration'] as num).toInt(),
);

Map<String, dynamic> _$LyricsKeyToJson(_LyricsKey instance) => <String, dynamic>{
  'track': instance.track,
  'artist': instance.artist,
  'duration': instance.duration,
};
