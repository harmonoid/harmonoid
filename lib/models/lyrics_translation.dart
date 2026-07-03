import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:harmonoid/models/lyric.dart';
import 'package:harmonoid/models/lyrics.dart';

part 'lyrics_translation.freezed.dart';
part 'lyrics_translation.g.dart';

@freezed
abstract class LyricsTranslation with _$LyricsTranslation {
  const factory LyricsTranslation({
    required bool same,
    required Lyrics? lyrics,
  }) = _LyricsTranslation;

  factory LyricsTranslation.fromJson(Map<String, dynamic> json) => _$LyricsTranslationFromJson(json);
}
