import 'package:flutter/foundation.dart';
import 'package:identity/identity.dart';

import 'package:harmonoid/state/lyrics/models/lyric.dart';
import 'package:harmonoid/state/lyrics/models/lyrics.dart';

/// {@template lyrics_get}
///
/// LyricsGet
/// ---------
///
/// {@endtemplate}
class LyricsGet {
  Future<Lyrics?> call(String track, String artist, int duration) async {
    try {
      final response = await Supabase.instance.client.functions.invoke(
        'lyrics-get',
        method: HttpMethod.get,
        queryParameters: {
          'track': track,
          'artist': artist,
          'duration': duration.toString(),
        }
      );
      return (response.data as List).map<Lyric>((e) => Lyric.fromJson(e)).toList();
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }
    return null;
  }
}
