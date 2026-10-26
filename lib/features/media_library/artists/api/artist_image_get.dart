import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:identity/identity.dart';

import 'package:harmonoid/extensions/supabase_client.dart';

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
        Supabase.instance.client.functionUri(
          'artist-image-get',
          {
            'query': query,
          },
        ),
      );
      request.headers.addAll(Supabase.instance.client.functions.headers);

      final response = await client.send(request);

      if (response.statusCode == 200) {
        final sink = file.openWrite();
        try {
          await response.stream.pipe(sink);
          return true;
        } finally {
          await sink.close();
        }
      }

      // Only cache a definitive "not found" response. Other errors should be retried later.
      return response.statusCode != 404;
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
      return true;
    } finally {
      client.close();
    }
  }
}
