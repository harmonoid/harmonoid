import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:identity/identity.dart';

import 'package:harmonoid/api/utils/constants.dart';
import 'package:harmonoid/state/lyrics/models/lyrics.dart';
import 'package:harmonoid/state/lyrics/models/lyrics_translation.dart';

/// {@template lyrics_translation_get}
///
/// LyricsTranslationGet
/// --------------------
///
/// {@endtemplate}
class LyricsTranslationGet {
  Future<LyricsTranslation?> call(Lyrics lyrics, String language, String track, String artist, int duration) async {
    if (lyrics.isEmpty || language.isEmpty) return null;
    try {
      final response = await Supabase.instance.client.functions.invoke(
        'lyrics-translation',
        method: HttpMethod.post,
        body: json.encode({
          'lyrics': lyrics.map((e) => e.toJson()).toList(),
          'language': language,
          'track': track,
          'artist': artist,
          'duration': duration,
        }),
        headers: {'X-API-Key': apiKey},
      );
      if (response.status != 200) return null;
      return LyricsTranslation.fromJson(response.data);
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }
    return null;
  }
}
