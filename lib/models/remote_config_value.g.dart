// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'remote_config_value.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EnableInAppReview _$EnableInAppReviewFromJson(Map<String, dynamic> json) =>
    EnableInAppReview(
      json['value'] as bool,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$EnableInAppReviewToJson(EnableInAppReview instance) =>
    <String, dynamic>{'value': instance.value, 'runtimeType': instance.$type};

LyricsTranslationLanguages _$LyricsTranslationLanguagesFromJson(
  Map<String, dynamic> json,
) => LyricsTranslationLanguages(
  (json['value'] as List<dynamic>)
      .map((e) => Language.fromJson(e as Map<String, dynamic>))
      .toList(),
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$LyricsTranslationLanguagesToJson(
  LyricsTranslationLanguages instance,
) => <String, dynamic>{'value': instance.value, 'runtimeType': instance.$type};
