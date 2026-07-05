// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:harmonoid/localization/models/language.dart';

part 'remote_config_value.freezed.dart';
part 'remote_config_value.g.dart';

@freezed
sealed class RemoteConfigValue with _$RemoteConfigValue {
  const factory RemoteConfigValue.enableInAppReview(bool value) = EnableInAppReview;
  const factory RemoteConfigValue.lyricsTranslationLanguages(List<Language> value) = LyricsTranslationLanguages;
  const factory RemoteConfigValue.subscriptionPurchaseConfig(SubscriptionPurchaseConfig value) = SubscriptionPurchaseConfigValue;

  factory RemoteConfigValue.fromJson(Map<String, dynamic> json) => _$RemoteConfigValueFromJson(json);
}

@freezed
abstract class SubscriptionPurchaseConfig with _$SubscriptionPurchaseConfig {
  const factory SubscriptionPurchaseConfig({
    @JsonKey(name: 'max_version') required String maxVersion,
    @JsonKey(name: 'min_version') required String minVersion,
    @JsonKey(name: 'blacklisted_versions') required List<String> blacklistedVersions,
  }) = _SubscriptionPurchaseConfig;

  factory SubscriptionPurchaseConfig.fromJson(Map<String, dynamic> json) => _$SubscriptionPurchaseConfigFromJson(json);
}
