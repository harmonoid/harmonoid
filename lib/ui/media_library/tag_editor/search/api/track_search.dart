import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import 'package:harmonoid/api/utils/constants.dart';
import 'package:harmonoid/ui/media_library/tag_editor/search/models/track_search_result.dart';

/// {@template track_search}
///
/// TrackSearch
/// -----------
///
/// {@endtemplate}
class TrackSearch {
  Future<List<TrackSearchResult>?> call(String query, {int limit = 20}) async {
    try {
      final uri = Uri.https(
        apiBaseUrl,
        '/functions/v1/track-search',
        {
          'query': query,
          'limit': limit.toString(),
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': apiKey,
        },
      );

      final body = json.decode(utf8.decode(response.bodyBytes));
      return body.map<TrackSearchResult>((e) => TrackSearchResult.fromJson(e)).toList();
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }
    return null;
  }
}
