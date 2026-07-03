import 'package:freezed_annotation/freezed_annotation.dart';

part 'lyrics_translation_key.freezed.dart';
part 'lyrics_translation_key.g.dart';

@freezed
abstract class LyricsTranslationKey with _$LyricsTranslationKey {
  const factory LyricsTranslationKey({
    required String track,
    required String artist,
    required int duration,
    required String language,
  }) = _LyricsTranslationKey;

  factory LyricsTranslationKey.fromJson(Map<String, dynamic> json) => _$LyricsTranslationKeyFromJson(json);
}
