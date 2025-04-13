import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// {@template latest_version_get}
///
/// LatestVersionGet
/// ----------------
///
/// {@endtemplate}
class LatestVersionGet {
  Future<String?> call() async {
    try {
      final response = await http.get(Uri.https('api.github.com', '/repos/harmonoid/harmonoid/releases/latest'));
      final body = json.decode(utf8.decode(response.bodyBytes));
      return body['tag_name'];
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }
    return null;
  }
}
