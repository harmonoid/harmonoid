import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:harmonoid/core/lyrics.dart';

import 'package:harmonoid/core/playback.dart';

class LyricsScreen extends StatelessWidget {
  List<String> getLyrics() {
    Lyrics lyrics = Lyrics.get();
    List<String> list = [];
    for (Lyric lyric in lyrics.current) {
      list.add(lyric.words);
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    List<String> list = getLyrics();
    List<Widget> widgets = [];
    for (String word in list) {
      widgets.add(Text(word));
    }
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: Theme.of(context).brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        child: Card(
            elevation: 2,
            clipBehavior: Clip.antiAlias,
            color: Theme.of(context).cardColor,
            margin: EdgeInsets.all(8.0),
            child: ListView(
                children: <Widget>[
                      Container(
                          width: width,
                          height: 30,
                          child: Center(
                              child: Text("Lyrics",
                                  style: TextStyle(fontSize: 25))))
                    ] +
                    widgets)),
      ),
    );
  }
}
