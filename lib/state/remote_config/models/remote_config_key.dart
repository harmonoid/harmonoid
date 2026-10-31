enum RemoteConfigKey {
  artistImageCacheVersion('artist_image_cache_version'),
  enableInAppReview('enable_in_app_review'),
  lyricsTranslationLanguages('lyrics_translation_languages'),
  subscriptionPurchaseConfig('subscription_purchase_config'),
  splashConfig('splash_config'),
  desktopLyricsGateVersion('desktop_lyrics_gate_version');

  const RemoteConfigKey(this.key);

  final String key;
}
