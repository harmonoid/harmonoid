import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:flutter/widgets.dart';


const String HOME = 'harmonoid-lyrics.herokuapp.com';

late Lyrics lyrics = new Lyrics();


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

  static Lyric fromMap(dynamic map) => new Lyric(
    time: map['time'],
    words: map['words'],
  );
}


class Lyrics extends ChangeNotifier {
  static Lyrics get() => lyrics;
  
  List<Lyric> current = <Lyric>[];
  String query = '';

  Future<void> fromName(String name) async {
    this.current.clear();
    this.query = name;
    Uri uri = Uri.https(
      HOME,
      '/lyrics', {
        'name': name,
      },
    );
    try {
      http.Response response = await http.get(uri);
      if (response.statusCode == 200) {
        (convert.jsonDecode(response.body) as List).forEach((objectMap) {
          this.current.add(
            Lyric.fromMap(objectMap),
          );
        });
      }
      else {
        throw 'Exception: Invalid status code.';
      }
    }
    catch(exception) {
      throw 'Exception: Please check your internet connection.';
    }
    this.notifyListeners();
  }
}
