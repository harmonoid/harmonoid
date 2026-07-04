enum RemoteConfigKey {
  enableInAppReview('enable_in_app_review'),
  lyricsTranslationLanguages('lyrics_translation_languages'),
  subscriptionPurchaseConfig('subscription_purchase_config');

  const RemoteConfigKey(this.key);

  final String key;
}
