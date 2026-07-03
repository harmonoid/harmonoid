import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:harmonoid/models/language.dart';

part 'remote_config_value.freezed.dart';
part 'remote_config_value.g.dart';

@freezed
sealed class RemoteConfigValue with _$RemoteConfigValue {
  const factory RemoteConfigValue.enableInAppReview(bool value) = EnableInAppReview;
  const factory RemoteConfigValue.lyricsTranslationLanguages(List<Language> value) = LyricsTranslationLanguages;

  factory RemoteConfigValue.fromJson(Map<String, dynamic> json) => _$RemoteConfigValueFromJson(json);
}
