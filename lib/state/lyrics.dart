/* 
 *  This file is part of Harmonoid (https://github.com/harmonoid/harmonoid).
 *  
 *  Harmonoid is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *  
 *  Harmonoid is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU General Public License for more details.
 *  
 *  You should have received a copy of the GNU General Public License
 *  along with Harmonoid. If not, see <https://www.gnu.org/licenses/>.
 * 
 *  Copyright 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
 */
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
          .toList();
    }
    notifyListeners();
  }
}
