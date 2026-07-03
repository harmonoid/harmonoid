import 'package:harmonoid/state/lyrics/models/lyrics_key.dart';
import 'package:harmonoid/state/lyrics/models/lyrics_translation_key.dart';

/// Mappers for [LyricsKey].
extension LyricsKeyMappers on LyricsKey {
  /// Converts to [LyricsTranslationKey].
  LyricsTranslationKey toLyricsTranslationKey(String language) {
    return LyricsTranslationKey(
      track: track,
      artist: artist,
      duration: duration,
      language: language,
    );
  }
}
