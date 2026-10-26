import 'package:flutter/foundation.dart';
import 'package:identity/identity.dart';

import 'package:harmonoid/features/media_library/tag_editor/search/models/track_search_result.dart';

/// {@template track_search}
///
/// TrackSearch
/// -----------
///
/// {@endtemplate}
class TrackSearch {
  Future<List<TrackSearchResult>?> call(String query, {int limit = 20}) async {
    try {
      final response = await Supabase.instance.client.functions.invoke(
        'track-search',
        method: HttpMethod.get,
        queryParameters: {
          'query': query,
          'limit': limit.toString(),
        }
      );

      return (response.data as List).map<TrackSearchResult>((e) => TrackSearchResult.fromJson(e)).toList();
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }
    return null;
  }
}
