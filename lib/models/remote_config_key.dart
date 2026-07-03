enum RemoteConfigKey {
  enableInAppReview('enable_in_app_review'),
  lyricsTranslationLanguages('lyrics_translation_languages');

  const RemoteConfigKey(this.key);

  final String key;
}
