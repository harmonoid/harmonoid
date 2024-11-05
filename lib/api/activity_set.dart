// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';

import 'package:harmonoid/api/utils/constants.dart';
import 'package:harmonoid/models/playable.dart';

/// {@template activity_set}
///
/// ActivitySet
/// -----------
///
/// {@endtemplate}
class ActivitySet {
  /// Singleton instance.
  static const ActivitySet instance = ActivitySet._();

  /// {@macro activity_set}
  const ActivitySet._();

  Future<String?> call(String deviceId, Playable playable, File? cover) async {
    try {
      // https://pub.dev/documentation/http/latest/http/MultipartRequest-class.html
      final uri = Uri.https(apiBaseUrl, '/functions/v1/activity-set');
      final request = http.MultipartRequest('POST', uri)
        ..fields['device-id'] = deviceId
        ..fields['playable'] = json.encode(playable)
        ..files.add(
          await http.MultipartFile.fromPath(
            'cover',
            cover!.path,
            contentType: MediaType('image', 'png'),
          ),
        )
        ..headers['Content-Type'] = 'application/json'
        ..headers['X-API-Key'] = apiKey;
      final response = await request.send();
      if (response.statusCode == 200) {
        final body = utf8.decode(await response.stream.toBytes());
        return json.decode(body)['cover'];
      }
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }
    return null;
  }
}
