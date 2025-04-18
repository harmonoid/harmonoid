import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import 'package:harmonoid/api/utils/constants.dart';
import 'package:harmonoid/models/lyric.dart';
import 'package:harmonoid/models/lyrics.dart';

/// {@template lyrics_get}
///
/// LyricsGet
/// ---------
///
/// {@endtemplate}
class LyricsGet {
  Future<Lyrics?> call(String query, int? duration) async {
    try {
      final response = await http.get(
        Uri.https(
          apiBaseUrl,
          '/functions/v1/lyrics-get',
          {
            'query': query.toString(),
            if (duration != null) 'duration': duration.toString(),
          },
        ),
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': apiKey,
        },
      );
      final body = json.decode(utf8.decode(response.bodyBytes));
      return body.map<Lyric>((e) => Lyric.fromJson(e)).toList();
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }
    return null;
  }
}
