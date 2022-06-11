/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///
import 'dart:async';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:flutter/widgets.dart';

import 'package:harmonoid/models/lyric.dart';

/// Lyrics
/// ------
///
/// Minimal [ChangeNotifier] to fetch & update the lyrics based on the currently playing track.
///
class Lyrics extends ChangeNotifier {
  /// [Lyrics] object instance.
  static late Lyrics instance = Lyrics();

  List<Lyric> current = <Lyric>[];

  Lyrics() {
    // Run as asynchronous suspension.
    () async {
      // `await for` to avoid race conditions.
      await for (final query in _controller.stream) {
        if (_query == query) continue;
        current = <Lyric>[];
        notifyListeners();
        _query = query;
        final uri = Uri.https(
          'harmonoid-lyrics.vercel.app',
          '/api/lyrics',
          {
            'name': _query,
          },
        );
        try {
          final response = await http.get(uri);
          if (response.statusCode == 200) {
            current.addAll(
              (convert.jsonDecode(response.body) as List<dynamic>)
                  .map((lyric) => Lyric.fromJson(lyric))
                  .toList()
                  .cast<Lyric>(),
            );
          }
        } catch (exception, stacktrace) {
          debugPrint(exception.toString());
          debugPrint(stacktrace.toString());
        }
        notifyListeners();
      }
    }();
  }

  void update(String query) async {
    _controller.add(query);
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  /// [StreamController] to avoid possible race condition when index
  /// switching in playlist takes place.
  /// * Using `await for` to handle this scenario.
  final StreamController<String> _controller = StreamController<String>();
  String? _query;
}
