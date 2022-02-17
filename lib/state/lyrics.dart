/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///
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
  String query = '';

  void update(String name) async {
    if (query == name) return;
    current.clear();
    query = name;
    Uri uri = Uri.https(
      'harmonoid-lyrics.vercel.app',
      '/lyrics',
      {
        'name': name,
      },
    );
    http.Response response = await http.get(uri);
    if (response.statusCode == 200) {
      current = convert
          .jsonDecode(response.body)
          .map((lyric) => Lyric.fromJson(lyric))
          .toList()
          .cast<Lyric>();
    }
    notifyListeners();
  }
}
