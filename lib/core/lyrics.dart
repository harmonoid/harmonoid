import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:flutter/widgets.dart';

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
                Lyric.fromMap(map),
              );
        },
      );
    }
    this.notifyListeners();
  }
}

class Lyric {
  final int time;
  final String words;

  Lyric({
    required this.time,
    required this.words,
  });

  Map<String, dynamic> toMap(dynamic map) => {
        'time': this.time,
        'words': this.words,
      };

  static Lyric fromMap(dynamic map) => Lyric(
        time: map['time'],
        words: map['words'],
      );
}

var lyrics = Lyrics();
