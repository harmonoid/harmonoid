// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lyrics_translation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LyricsTranslation _$LyricsTranslationFromJson(Map<String, dynamic> json) =>
    _LyricsTranslation(
      same: json['same'] as bool,
      lyrics: (json['lyrics'] as List<dynamic>?)
          ?.map((e) => Lyric.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$LyricsTranslationToJson(_LyricsTranslation instance) =>
    <String, dynamic>{'same': instance.same, 'lyrics': instance.lyrics};
