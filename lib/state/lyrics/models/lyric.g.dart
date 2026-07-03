// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lyric.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Lyric _$LyricFromJson(Map<String, dynamic> json) => _Lyric(
  timestamp: (json['timestamp'] as num).toInt(),
  text: json['text'] as String,
);

Map<String, dynamic> _$LyricToJson(_Lyric instance) => <String, dynamic>{
  'timestamp': instance.timestamp,
  'text': instance.text,
};
