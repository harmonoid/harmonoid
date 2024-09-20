import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import 'package:harmonoid/models/lyric.dart';
import 'package:harmonoid/models/lyrics.dart';

/// {@template lyrics_api}
///
/// LyricsApi
/// ---------
/// API to fetch lyrics.
///
/// {@endtemplate}
class LyricsApi {
  /// Singleton instance.
  static const LyricsApi instance = LyricsApi._();

  /// {@macro lyrics_api}
  const LyricsApi._();

  Future<Lyrics?> lyrics(String name) async {
    try {
      final response = await http.get(
        Uri.https(
          _base,
          _lyrics,
          {
            'name': name,
          },
        ),
      );
      final body = json.decode(response.body);
      return body.map<Lyric>((e) => Lyric.fromJson(e)).toList();
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
      return null;
    }
  }

  /// Base URL.
  static const String _base = 'harmonoid-lyrics.vercel.app';

  /// Endpoint: [lyrics].
  static const String _lyrics = '/api/lyrics';
}
