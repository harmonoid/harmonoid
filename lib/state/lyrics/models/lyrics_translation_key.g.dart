// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lyrics_translation_key.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LyricsTranslationKey _$LyricsTranslationKeyFromJson(
  Map<String, dynamic> json,
) => _LyricsTranslationKey(
  track: json['track'] as String,
  artist: json['artist'] as String,
  duration: (json['duration'] as num).toInt(),
  language: json['language'] as String,
);

Map<String, dynamic> _$LyricsTranslationKeyToJson(
  _LyricsTranslationKey instance,
) => <String, dynamic>{
  'track': instance.track,
  'artist': instance.artist,
  'duration': instance.duration,
  'language': instance.language,
};
