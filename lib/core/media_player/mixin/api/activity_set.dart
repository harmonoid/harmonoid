// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';
import 'package:identity/identity.dart';

import 'package:harmonoid/core/media_player/models/playable.dart';

/// {@template activity_set}
///
/// ActivitySet
/// -----------
///
/// {@endtemplate}
class ActivitySet {
  Future<String?> call(String deviceId, Playable playable, File? cover) async {
    try {
      final response = await Supabase.instance.client.functions.invoke(
        'activity-set',
        method: HttpMethod.post,
        body: {
          'device-id': deviceId,
          'playable': json.encode(playable),
        },
        files: [
          if (cover != null)
            await MultipartFile.fromPath(
              'cover',
              cover.path,
              contentType: MediaType('image', 'jpeg'),
            ),
        ]
      );
      return response.data['cover'];
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }
    return null;
  }
}
