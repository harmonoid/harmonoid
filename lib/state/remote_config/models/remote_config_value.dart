// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:identity/identity.dart';

import 'package:harmonoid/localization/models/language.dart';

part 'remote_config_value.freezed.dart';
part 'remote_config_value.g.dart';

@freezed
sealed class RemoteConfigValue with _$RemoteConfigValue {
  const factory RemoteConfigValue.artistImageCacheVersion(int value) = ArtistImageCacheVersion;
  const factory RemoteConfigValue.enableInAppReview(bool value) = EnableInAppReview;
  const factory RemoteConfigValue.lyricsTranslationLanguages(List<Language> value) = LyricsTranslationLanguages;
  const factory RemoteConfigValue.subscriptionPurchaseConfig(SubscriptionPurchaseConfig value) = SubscriptionPurchaseConfigValue;

  factory RemoteConfigValue.fromJson(Map<String, dynamic> json) => _$RemoteConfigValueFromJson(json);
}
