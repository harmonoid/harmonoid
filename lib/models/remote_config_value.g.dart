// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'remote_config_value.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LyricsTranslationLanguages _$LyricsTranslationLanguagesFromJson(
  Map<String, dynamic> json,
) => LyricsTranslationLanguages(
  (json['value'] as List<dynamic>)
      .map((e) => Language.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$LyricsTranslationLanguagesToJson(
  LyricsTranslationLanguages instance,
) => <String, dynamic>{'value': instance.value};
