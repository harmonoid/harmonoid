import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import 'package:harmonoid/api/utils/constants.dart';

/// {@template artist_image_get}
///
/// ArtistImageGet
/// --------------
///
/// {@endtemplate}
class ArtistImageGet {
  Future<bool> call(String query, File file) async {
    final client = http.Client();
    try {
      final request = http.Request(
        'GET',
        Uri.https(apiBaseUrl, '/functions/v1/artist-image-get', {
          'query': query,
        }),
      );

      request.headers['X-API-Key'] = apiKey;

      final response = await client.send(request);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final sink = file.openWrite();
        try {
          await response.stream.pipe(sink);
          return true;
        } finally {
          await sink.close();
        }
      }

      return false;
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
      return true;
    } finally {
      client.close();
    }
  }
}
