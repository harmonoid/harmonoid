import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import 'package:harmonoid/ui/update/models/github_release.dart';

/// {@template latest_release_get}
///
/// LatestReleaseGet
/// ----------------
///
/// {@endtemplate}
class LatestReleaseGet {
  Future<GithubRelease?> call() async {
    try {
      final response = await http.get(Uri.https('api.github.com', '/repos/harmonoid/harmonoid/releases/latest'));
      final body = json.decode(utf8.decode(response.bodyBytes));
      return GithubRelease.fromJson(body);
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }
    return null;
  }
}
