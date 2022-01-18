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
 *  Copyright 2020-2021, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
 */

import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:flutter/widgets.dart';

/// Lyrics
/// ------
///
class Lyrics extends ChangeNotifier {
  static Lyrics get() => lyrics;

  List<Lyric> current = <Lyric>[];
  String query = '';

  Future<void> fromName(String name) async {
    this.current.clear();
    this.query = name;
    Uri uri = Uri.https(
      'harmonoid-lyrics.vercel.app',
      '/lyrics',
      {
        'name': name,
      },
    );
    http.Response response = await http.get(uri);
    if (response.statusCode == 200) {
      (convert.jsonDecode(response.body) as List).forEach(
        (map) {
          this.current.add(
                Lyric.fromJson(map),
              );
        },
      );
    }
    this.notifyListeners();
  }
}

/// Lyric
/// -----
///
/// A model class to keep lyrics & equivalent time stamps.
///
class Lyric {
  final int time;
  final String words;

  Lyric({
    required this.time,
    required this.words,
  });

  Map<String, dynamic> toJson(dynamic map) => {
        'time': this.time,
        'words': this.words,
      };

  static Lyric fromJson(dynamic map) => Lyric(
        time: map['time'],
        words: map['words'],
      );
}

var lyrics = Lyrics();
